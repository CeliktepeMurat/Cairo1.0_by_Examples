#[contract]
mod HelloStarknet {
    struct Storage {
        balance: felt,
        balance_mapping: LegacyMap<felt, u256>,
    }

}
