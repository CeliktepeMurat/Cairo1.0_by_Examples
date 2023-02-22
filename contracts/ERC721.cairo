use array::ArrayTrait;

#[derive(Copy, Drop)]
#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::FeltTryIntoContractAddress;
    use traits::TryInto;
    use traits::Into;
    use option::OptionTrait;

    struct Storage {
        _ownerOf: LegacyMap::<u256, felt>,
        _balanceOf: LegacyMap::<ContractAddress, felt>,
        _approvals: LegacyMap::<u256, felt>,
    }

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, token_id: u256) {}

    #[event]
    fn Transfer(_from: ContractAddress, _to: ContractAddress, token_id: u256) {}

    trait IERC721 {
        fn balance_of(address: ContractAddress) -> felt;
        fn owner_of(token_id: u256) -> felt;
        fn get_approved(token_id: u256) -> felt;
        fn approve(to: ContractAddress, token_id: u256);
        fn transfer_from(_from: ContractAddress, _to: ContractAddress, token_id: u256);
       
    }

    impl ERC721_Impl of IERC721 {
        
        #[view]
        fn balance_of(address: ContractAddress) -> felt {
            _balanceOf::read(address)
        }

        #[view]
        fn owner_of(token_id: u256) -> felt {
            let owner = _ownerOf::read(token_id);
            assert(!owner.is_zero(), 'ERC721: address is Zero');
            owner
        }
        
        #[view]
        fn get_approved(token_id: u256) -> felt {
            assert(!_ownerOf::read(token_id).is_zero(), 'ERC721: token does not exist');
            _approvals::read(token_id)
        }

        #[external]
        fn approve(spender: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            let owner= _ownerOf::read(token_id);
            assert(caller.into() == owner, 'ERC721: caller is not the owner');

            _approvals::write(token_id, spender.into());
            Approval(caller, spender, token_id);
        }

        #[external]
        fn transfer_from(_from: ContractAddress, _to: ContractAddress, token_id: u256) {
            let caller = get_caller_address(); 
            assert(_from.into() == _ownerOf::read(token_id), 'ERC721: from != owner');
            assert(!_to.is_zero(), 'ERC721: to is Zero');
            assert(caller.into() == _ownerOf::read(token_id) | caller.into() == _approvals::read(token_id), 'ERC721: not authorized');

            _balanceOf::write(_from, _balanceOf::read(_from) - 1);
            _balanceOf::write(_to, _balanceOf::read(_to) + 1);
            _ownerOf::write(token_id, _to.into());

            _approvals::write(token_id, 0);
            Transfer(_from, _to, token_id);
            
        }
  
    }
}