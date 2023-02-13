#[contract]
mod HelloStarknet {
    struct Storage {
        balance: felt,
        balance_mapping: LegacyMap::<felt, u256>
    }

    #[event]
    fn balance_update(balance: felt) {}

    #[constructor]
    fn constructor() {
        balance::write(0);
    }

    #[external]
    fn increase_balance(amount: felt) {
        assert(amount > 0, 'Amount should be bigger than 0');
        let res = balance::read();
        balance::write(res + amount);
        balance_update(res + amount);
    }

    #[view]
    fn read_Balance() -> felt {
        balance::read()
    }
}
