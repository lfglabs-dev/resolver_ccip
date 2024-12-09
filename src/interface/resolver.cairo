#[starknet::interface]
pub trait IResolver<TContractState> {
    fn resolve(
        self: @TContractState, domain: Span<felt252>, field: felt252, hint: Span<felt252>
    ) -> felt252;

    fn get_uris(self: @TContractState) -> Array<felt252>;
    fn add_uri(ref self: TContractState, new_uri: Span<felt252>);
    fn remove_uri(ref self: TContractState, index: felt252);
}
