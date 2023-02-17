use array::ArrayTrait;
#[derive(Copy, Drop)]
#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::ContractAddressZeroable;

    struct Storage {
        owner: felt,
        _balanceOf: LegacyMap::<felt, felt>,
        _ownerOf: LegacyMap::<felt, ContractAddress>,
        _approvals: LegacyMap::<u256, felt>,
    }

    #[event]
    fn Approval(owner: felt, spender: felt, value: u256) {}

    trait IERC721 {
        fn balance_of(owner: felt) -> felt;
        fn owner_of(token_id: felt) -> felt;
        fn approve(to: felt, token_id: felt);

       
    }

    impl ERC721_Impl of IERC721 {
        
        #[view]
        fn balance_of(owner: felt) -> felt {
            _balanceOf::read(owner)
        }

        #[view]
        fn owner_of(token_id: felt) -> felt {
            let owner = _ownerOf::read(token_id);
            assert(!owner.is_zero(), 'ERC721: address is Zero');
            owner
        }

        #[external]
        fn approve(spender: felt, token_id: felt) {
            let caller = get_caller_address();
            let owner = _ownerOf::read(token_id);
            assert(caller == owner, 'ERC721: caller is not the owner');
            
            _approvals::write(token_id, spender);
            Approval(caller, spender, token_id);
        }
  
    }
}