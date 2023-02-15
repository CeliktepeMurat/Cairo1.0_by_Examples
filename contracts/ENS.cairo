#[contract]
mod ENS {
    use starknet::get_caller_address;

    struct Storage {
        names: LegacyMap::<ContractAddress, felt>
    }

    #[event]
    fn NameStored(address: ContractAddress, name: felt) {}

    #[constructor]
    fn constructor(_name: felt) {
        let caller = get_caller_address();
        names::write(caller, _name);
    }

    #[external]
    fn store_name(_name: felt) {
        let caller = get_caller_address();
        names::write(caller, _name);
        NameStored(caller, _name);
    }

    #[view]
    fn get_name(address: ContractAddress) -> felt {
        names::read(address)
    }
}