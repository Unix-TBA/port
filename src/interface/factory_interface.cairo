use starknet::{ContractAddress, ClassHash};

#[derive(Drop, Serde, starknet::Store)]
pub struct DeployedTokenData {
    pub base_uri: ByteArray,
    pub token_id: u256
}

#[starknet::interface]
pub trait IPort<TContractState> {
    fn create(
        ref self: TContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        recipient: ContractAddress,
        token_id: u256
    ) -> ContractAddress;
    fn update_class_hash(ref self: TContractState, class_hash: ClassHash);
    fn get_deployed(self: @TContractState, contract: ContractAddress) -> DeployedTokenData;
}