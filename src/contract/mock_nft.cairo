#[starknet::contract]
mod MOCK_NFT {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
    ) {

        let name = "ETH NPCs";
        let symbol = "ENPC";
        let base_uri = "https://ipfs.moralis.io:2053/ipfs/bafybeiennpexxhjsmgpi2z52hqcpl7oxapc46zgpvzfm7q5nngo7awspia/00000000000000000000000000000000000000000000000000000000000000c4";
        let token_id = 196;

        self.erc721.initializer(name, symbol, base_uri);
        self.erc721.mint(recipient, token_id);
    }

}