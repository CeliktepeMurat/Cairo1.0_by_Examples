use array::ArrayTrait;

#[derive(Copy, Drop)]
#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::contract_address_const;
    use starknet::FeltTryIntoContractAddress;
    use traits::TryInto;
    use traits::Into;
    use option::OptionTrait;

    struct Storage {
        name: felt,
        symbol: felt,
        _ownerOf: LegacyMap::<u256, felt>,
        _balanceOf: LegacyMap::<ContractAddress, felt>,
        _approvals: LegacyMap::<u256, felt>,
        isApprovedForAll: LegacyMap::<(ContractAddress, ContractAddress), bool>,
    }

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, token_id: u256) {}

    #[event]
    fn Transfer(_from: ContractAddress, _to: ContractAddress, token_id: u256) {}

    #[event]
    fn ApprovalForAll(owner: ContractAddress, operator: ContractAddress, approved: bool) {}

    trait IERC721 {
        fn balance_of(address: ContractAddress) -> felt;
        fn owner_of(token_id: u256) -> felt;
        fn get_approved(token_id: u256) -> felt;
        fn mint(to: ContractAddress, token_id: u256);
        fn burn(token_id: u256);
        fn approve(to: ContractAddress, token_id: u256);
        fn transfer_from(_from: ContractAddress, _to: ContractAddress, token_id: u256);
        fn setApprovalForAll(operator: ContractAddress, approved: bool);
        fn _mint(to: ContractAddress, token_id: u256);
        fn isApprovedOrOwner(owner: ContractAddress, spender: ContractAddress, token_id: u256) -> bool;
        fn _burn(token_id: u256);
       
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
        fn mint(to: ContractAddress, token_id: u256) {
            IERC721::_mint(to, token_id);
        }

        #[external]
        fn burn(token_id: u256) {
            assert(_ownerOf::read(token_id) == get_caller_address().into(), 'ERC721: not authorized');
            IERC721::_burn(token_id);
        }

        #[external]
        fn approve(spender: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            let owner= _ownerOf::read(token_id);
            assert(caller.into() == owner | isApprovedForAll::read((owner.try_into().unwrap(), caller)), 'ERC721: not authorized');

            _approvals::write(token_id, spender.into());
            Approval(caller, spender, token_id);
        }

        #[external]
        fn transfer_from(_from: ContractAddress, _to: ContractAddress, token_id: u256) {
            let caller = get_caller_address(); 
            assert(_from.into() == _ownerOf::read(token_id), 'ERC721: from != owner');
            assert(!_to.is_zero(), 'ERC721: to is Zero');
            assert(IERC721::isApprovedOrOwner(caller, _to, token_id), 'ERC721: not authorized');

            _balanceOf::write(_from, _balanceOf::read(_from) - 1);
            _balanceOf::write(_to, _balanceOf::read(_to) + 1);
            _ownerOf::write(token_id, _to.into());

            _approvals::write(token_id, 0);
            Transfer(_from, _to, token_id);
        }

        #[external]
        fn setApprovalForAll(operator: ContractAddress, approved: bool) {
            let caller = get_caller_address();
            isApprovedForAll::write((caller, operator), approved);
            ApprovalForAll(caller, operator, approved);
        }

        #[internal]
        fn _mint(to: ContractAddress, token_id: u256) {
            assert(!to.is_zero(), 'ERC721: to is Zero');
            assert(!_ownerOf::read(token_id).is_zero(), 'ERC721: token already exists');

            _balanceOf::write(to, _balanceOf::read(to) + 1);
            _ownerOf::write(token_id, to.into());

            Transfer(contract_address_const::<0>(), to, token_id);
        }

        #[internal]
        fn isApprovedOrOwner(owner: ContractAddress, spender: ContractAddress, token_id: u256) -> bool {
            spender.into() == owner.into() | 
                isApprovedForAll::read((owner, spender)) |
                spender.into() == _approvals::read(token_id)  
        }

        #[internal]
        fn _burn(token_id: u256) {
            let owner_as_felt = _ownerOf::read(token_id);
            let owner = owner_as_felt.try_into().unwrap();
            assert(!owner.is_zero(), 'ERC721: token does not exist');

            _balanceOf::write(owner, _balanceOf::read(owner) - 1);
            
            _ownerOf::write(token_id, 0);
            _approvals::write(token_id, 0);

            Transfer(owner, contract_address_const::<0>(), token_id);
        }
    }
}