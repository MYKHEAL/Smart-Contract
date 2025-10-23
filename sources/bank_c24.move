/// Module: bank_c24
module bank_c24::bank_c24{
   

    use std::string::String;
    use sui::table;
    use std::address;
    use sui::object::delete;
    use sui::table::drop;
    use sui::tx_context::dummy;


    const EBankNotFound: u64 = 0;
    const EAccountNotFound: u64 = 1;
    const EAccountNotAdded: u64 = 3;
    const EAccountAlreadyExists: u64 = 4;
    const EBalanceNotCorrect: u64 = 5;
    const EDepositLesserThanZero: u64 = 6;
    const EInvalidAmount: u64 = 7;


    public struct Account has key, store {
        id: UID,
        name: String,
        pin: String,
        balance: u64
    }

    public struct Bank has key, store {
        id: UID,
        name: String,
        accounts: table::Table<address, Account>
    }

    public fun create_bank(name: String, ctx: &mut TxContext): Bank{
        let id = object::new(ctx);
        let accounts = table::new<address, Account>(ctx);

        Bank{
            id,
            name,
            accounts
        }

    }
    
    public fun create_account(name: String, pin: String, ctx: &mut TxContext): Account{
        let id = object::new(ctx);

        Account{
            id,
            name,
            pin,
            balance: 0
        }

    }

    public fun add_account_to_bank(user_address: address, account_to_be_added: Account, bank: &mut Bank){
        assert!(!bank.accounts.contains(user_address), EAccountAlreadyExists);
        bank.accounts.add(user_address, account_to_be_added);

    }

    public fun dummy_drop(obj: Bank, user: address){
        transfer::public_transfer(obj, user)
    }

    public fun deposit(bank: &mut Bank, user_address: address, amount: u64){
        assert!(amount > 0, EDepositLesserThanZero);
        let user_account =  table::borrow_mut<address, Account>(&mut bank.accounts, user_address);
        user_account.balance = user_account.balance + amount;
    }

    public fun withdraw(bank: &mut Bank, user_address: address, amount: u64){
        let user_account =  table::borrow_mut<address, Account>(&mut bank.accounts, user_address);
        assert!(user_account.balance >= amount, EBalanceNotCorrect);
        user_account.balance = user_account.balance - amount;
    }

   public fun transfer(
    bank_from: &mut Bank,
    bank_to: &mut Bank,
    from_address: address,
    to_address: address,
    amount: u64
) {
    // Validate amount
    assert!(amount > 0, EInvalidAmount);

    let from_account = table::borrow_mut<address, Account>(&mut bank_from.accounts, from_address);
    let to_account = table::borrow_mut<address, Account>(&mut bank_to.accounts, to_address);

    assert!(from_account.balance >= amount, EInvalidAmount);

    from_account.balance = from_account.balance - amount;
    to_account.balance = to_account.balance + amount;
}



    
    #[test]
    public fun test_create_bank() {
        let mut ctx = dummy();

        let mut zenith_bank = create_bank(b"Zenith".to_string(), &mut ctx);
        assert!(zenith_bank.name == b"Zenith".to_string(), EBankNotFound);

        let ericalli_account = create_account(b"Ericalli".to_string(), b"1234".to_string(), &mut ctx);
        assert!(ericalli_account.name == b"Ericalli".to_string(), EAccountNotFound);
        assert!(ericalli_account.pin == b"1234".to_string(), EAccountNotFound);

        let user_address = @ericalli_address;


        add_account_to_bank(user_address, ericalli_account,&mut zenith_bank);
        dummy_drop(zenith_bank, @zenith_address);

    }

    #[test]
    public fun test_deposit() {
        let mut ctx = dummy();

        let mut zenith_bank = create_bank(b"Zenith".to_string(), &mut ctx);
        assert!(zenith_bank.name == b"Zenith".to_string(), EBankNotFound);

        let ericalli_account = create_account(b"Ericalli".to_string(), b"1234".to_string(), &mut ctx);
        assert!(ericalli_account.name == b"Ericalli".to_string(), EAccountNotFound);
        assert!(ericalli_account.pin == b"1234".to_string(), EAccountNotFound);

        let user_address = @ericalli_address;


        add_account_to_bank(user_address, ericalli_account,&mut zenith_bank);
        assert!(zenith_bank.accounts.contains(user_address), EAccountNotFound);
        let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);

        assert!(user_account.balance == 0, EBalanceNotCorrect);


        deposit(&mut zenith_bank, user_address, 1000);
        


        let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);

        assert!(user_account.balance == 1000, EBalanceNotCorrect);

        dummy_drop(zenith_bank, @zenith_address);

    }

    #[test]
    public fun test_withdrawal(){
        let mut ctx = dummy();

        let mut zenith_bank = create_bank(b"Zenith".to_string(), &mut ctx);
        assert!(zenith_bank.name == b"Zenith".to_string(), EBankNotFound);

        let mykheal_account = create_account(b"Mykheal".to_string(), b"1234".to_string(), &mut ctx);
        assert!(mykheal_account.name == b"Mykheal".to_string(), EAccountNotAdded);

        let user_address = @mykheal_address;

        add_account_to_bank(user_address, mykheal_account,&mut zenith_bank);
        assert!(zenith_bank.accounts.contains(user_address), EAccountNotFound);

        // let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        // assert!(zenith_bank_account.balance == 0, EBalanceNotCorrect);
        deposit(&mut zenith_bank, user_address, 2000);
        // assert!(mykheal_account.balance == 2000, EBalanceNotCorrect);

         let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        assert!(user_account.balance == 2000, EBalanceNotCorrect);
        withdraw(&mut zenith_bank, user_address, 500);

            


        let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        assert!(user_account.balance == 1500, EBalanceNotCorrect);
        dummy_drop(zenith_bank, @zenith_address);


     
    }

    #[test]
    public fun test_transfer(){
        let mut ctx = dummy();

        let mut zenith_bank = create_bank(b"Zenith".to_string(), &mut ctx);
        let mut palmpay_bank = create_bank(b"Palmpay".to_string(), &mut ctx);
        assert!(zenith_bank.name == b"Zenith".to_string(), EBankNotFound);
        assert!(palmpay_bank.name == b"Palmpay".to_string(), EBankNotFound);

        let mykheal_account = create_account(b"Mykheal".to_string(), b"1234".to_string(), &mut ctx);
        let usman_account = create_account(b"Usman".to_string(), b"0987".to_string(), &mut ctx);
        assert!(mykheal_account.name == b"Mykheal".to_string(), EAccountNotAdded);
        assert!(usman_account.name == b"Usman".to_string(), EAccountNotAdded);

        let user_address = @mykheal_address;
        let receiver_address = @noble_address;

        add_account_to_bank(user_address, mykheal_account,&mut zenith_bank);
        assert!(zenith_bank.accounts.contains(user_address), EAccountNotFound);
        add_account_to_bank(receiver_address, usman_account, &mut palmpay_bank);
        assert!(palmpay_bank.accounts.contains(receiver_address), EAccountNotFound);

        // let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        // assert!(zenith_bank_account.balance == 0, EBalanceNotCorrect);
        deposit(&mut zenith_bank, user_address, 2000);

        // assert!(mykheal_account.balance == 2000, EBalanceNotCorrect);

         let user_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        assert!(user_account.balance == 2000, EBalanceNotCorrect);

        let receiver_account = table::borrow_mut<address, Account>(&mut palmpay_bank.accounts, receiver_address);
        assert!(receiver_account.balance == 0, EBalanceNotCorrect);

transfer(&mut zenith_bank, &mut palmpay_bank, user_address, receiver_address, 1000);

        let mykheal_account =  table::borrow_mut<address, Account>(&mut zenith_bank.accounts, user_address);
        assert!(mykheal_account.balance == 1000, EBalanceNotCorrect);

        let usman_account = table::borrow_mut<address, Account>(&mut palmpay_bank.accounts, receiver_address);
        assert!(usman_account.balance == 1000, EBalanceNotCorrect);
        dummy_drop(zenith_bank, @zenith_address);
        dummy_drop(palmpay_bank, @palmpay_address);

    }


}
