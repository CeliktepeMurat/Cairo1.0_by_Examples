#[contract]
mod Traits {
    use starknet::get_caller_address;

    struct Storage {
        names: LegacyMap::<ContractAddress, felt>
    }

    trait IEns{
        fn store_name(_name: felt);
        fn get_name(address: ContractAddress) -> felt;
    }

    impl Trait of IEns {
        fn store_name(_name: felt) {
            let caller = get_caller_address();
            names::write(caller, _name);
        }

        fn get_name(address: ContractAddress) -> felt {
            names::read(address)
        }
    }

    #[external]
    fn set_name(_name: felt) {
        IEns::store_name(_name);
    }
}