#[contract]
mod ERC20 {
    use starknet::get_caller_address;

    struct Storage {
        name: felt,
        symbol: felt,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap::<felt, u256>,
        allowances: LegacyMap::<(felt, felt), u256>
    }

    #[event]
    fn Transfer(from: felt, to: felt, amount: u256) {}

    #[event]
    fn Approval(owner: felt, spender: felt, amount: u256) {}

    #[constructor]
    fn constructor(_name: felt, _symbol: felt, _decimals: u8, init_supply: u256, recepient: felt) {
        name::write(_name);
        symbol::write(_symbol);
        decimals::write(_decimals);
        total_supply::write(init_supply);
        balances::write(recepient, init_supply);
        Transfer(0, recepient, init_supply);
    }

    #[view]
    fn get_name() -> felt {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt {
        symbol::read()
    }

    #[view]
    fn get_decimals() -> u8 {
        decimals::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        total_supply::read()
    }

    #[view]
    fn get_balance_of(account: felt) -> u256 {
        balances::read(account)
    }

    #[view]
    fn get_allowance(owner: felt, spender: felt) -> felt {
        allowances::read((owner, spender))
    }

    #[external]
    fn transfer(recepient: felt, amount: u256) {
        let sender = get_caller_address();
        _transfer(sender, recepient, amount);
    }

    #[external]
    fn transferFrom(owner: felt, recepient: felt, amount: u256) {
        let caller = get_caller_address();
        _spend_allowance(owner, caller, amount);
        _transfer(owner, recepient, amount);
    }

    #[external]
    fn increase_allowance(spender: felt, amount: u256) {
        let owner = get_caller_address();
        let allowance = allowances::read((owner, spender));
        _approve(owner, spender, allowance + amount);
    }

    #[external]
    fn decrease_allowance(spender: felt, amount: u256) {
        let owner = get_caller_address();
        let allowance = allowances::read((owner, spender));
        _approve(owner, spender, allowance - amount);
    }

    #[internal]
    fn _spend_allowance(owner: felt, spender: felt, amount: u256) {
        let allowance = allowances::read((owner, spender));
        let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;

        let is_unlimited_allowance = allowance.high == ONES_MASK & allowance.low == ONES_MASK;
        if !is_unlimited_allowance {
            _approve(owner, spender, allowance - amount);
        }
    }

    #[internal]
    fn _approve(owner: felt, spender: felt, amount: u256) {
        assert(owner != 0, 'ERC20: approve from the zero address');
        assert(spender != 0, 'ERC20: approve to the zero address');

        allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    #[internal]
    fn _transfer(sender: felt, recepient: felt, amount: u256) {
        assert(sender != 0, 'ERC20: transfer from the zero address');
        assert(recepient != 0, 'ERC20: transfer to the zero address');

        let sender_balance = balances::read(sender);
        assert(sender_balance >= amount, 'ERC20: transfer amount exceeds balance');

        let recepient_balance = balances::read(recepient);

        balances::write(sender, sender_balance - amount);
        balances::write(recepient, recepient_balance + amount);
        Transfer(sender, recepient, amount);
    }
}
