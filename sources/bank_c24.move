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
        dummy_drop(zenith_bank, @bank_address);

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

        dummy_drop(zenith_bank, @bank_address);

    }
}
