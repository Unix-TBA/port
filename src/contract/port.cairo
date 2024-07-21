#[starknet::contract]
mod Port {
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use port::interface::factory_interface::{DeployedTokenData, IPort};
    use starknet::{ContractAddress, ClassHash, SyscallResultTrait};
    use starknet::syscalls::deploy_syscall;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ============= Event ===============
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Create: Create,
        Update: Update,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    pub struct Create {
        #[key]
        contract: ContractAddress,
        token_data: DeployedTokenData
    }

    #[derive(Drop, starknet::Event)]
    pub struct Update {
        #[key]
        prev_class_hash: ClassHash,
        new_class_hash: ClassHash
    }

    // ============= Storage ==============
    #[storage]
    struct Storage {
        register_address: LegacyMap::<ContractAddress, DeployedTokenData>,
        class_hash: ClassHash,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl PortImpl of IPort<ContractState> {
        fn create(
            ref self: ContractState,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
            recipient: ContractAddress,
            token_id: u256
        ) -> ContractAddress {
            let mut calldata: Array::<felt252> = array![];

            name.serialize(ref calldata);
            symbol.serialize(ref calldata);
            base_uri.serialize(ref calldata);
            recipient.serialize(ref calldata);
            token_id.serialize(ref calldata);

            let class_hash = self.class_hash.read();

            let (deployed_address, _) = deploy_syscall(
                class_hash, 0, calldata.span(), false
            ).unwrap_syscall();

            let data = DeployedTokenData { base_uri, token_id};

            self.emit(Create { contract: deployed_address, token_data: data});

            deployed_address
        }

        // Only owner can update class hash
        fn update_class_hash(ref self: ContractState, class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            let prev_class_hash = self.class_hash.read();
            self.class_hash.write(class_hash);
            let new_class_hash = self.class_hash.read();

            self.emit(Update { prev_class_hash, new_class_hash});
        }

        // ================ View functions =================

        fn get_deployed(self: @ContractState, contract: ContractAddress) -> DeployedTokenData {
            let deployed_data = self.register_address.read(contract);

            deployed_data
        }
    }
}
// Sepolia
// Class Hash = 0x042ae2241df814db17dd2538263bc22b8bff402a38d67809f569d6114802119e