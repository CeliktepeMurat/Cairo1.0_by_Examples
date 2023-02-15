#[contract]
mod Features {
    struct Storage {
        sum: u256,
        product: u256,
        token_array: LegacyMap::<ContractAddress>
    }

    #[external]
    fn sum_integers(x: u256) -> u256 {
        let previous_sum = sum::read();
        let new_sum = previous_sum + x;
        sum::write(new_sum);
        new_sum
    }

    #[external]
    fn product_of_integers(x: u256, y: u256) -> u256 {
        let previous_product = product::read();
        let new_product = previous_product + x * y;
        product::write(new_product);
        new_product
    }
}