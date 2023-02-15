#[contract]
mod AMM {
    use starknet::get_caller_address;

    const BALANCE_UPPER_BOUND: felt = 1048284;
    const POOL_UPPER_BOUND: felt = 103748;
    const ACCOUNT_BALANCE_UPPER_BOUND: felt = 1073741;
    const TOKEN_TYPE_A: felt = 1;
    const TOKEN_TYPE_B: felt = 2;

    struct Storage {
        pool_balance: LegacyMap::<felt, felt>,
        account_balance: LegacyMap::<(felt, felt), felt>
    }

    #[view]
    fn get_account_token_balance(account: felt, token_type: felt) -> felt {
        account_balance::read((account, token_type))
    }

    #[view]
    fn get_pool_token_balance(token_type: felt) -> felt {
        pool_balance::read(token_type)
    }

    #[external]
    fn set_pool_token_balance(token_type: felt, amount: felt) {
        assert(amount < (POOL_UPPER_BOUND - 1), 'Exceeds pool upper bound');
        pool_balance::write(token_type, amount);
    }

    #[internal]
    fn update_account_balance(account: felt, token_type:felt, amount: felt) {
        let current_balance = account_balance::read((account, token_type));
        let new_balance = current_balance + amount;
        assert(new_balance < (ACCOUNT_BALANCE_UPPER_BOUND - 1), 'Exceeds account upper bound');
        account_balance::write((account, token_type), amount);
    }

    #[external]
    fn add_demo_tokens(token_A_amount: felt, token_B_amount: felt) {
        let caller = get_caller_address();

        update_account_balance(caller, TOKEN_TYPE_A, token_A_amount);
        update_account_balance(caller, TOKEN_TYPE_B, token_B_amount);
    }
}