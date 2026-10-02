use starknet::{ContractAddress, eth::ethereum::EthereumAddress, crypto::get_sha256_hash, eth::transfer_eth::transfer_eth};
use openzeppelin::access::ownable::ownable::OwnableComponent;

#[starknet::interface]
trait IResolver<T> {
    fn register_endpoint(
        ref self: T,
        endpoint: eth::ethereum::EthereumAddress,
        url: felt252,
    );

    fn deregister_endpoint(ref self: T, endpoint: eth::ethereum::EthereumAddress);

    fn get_endpoint(endpoint: eth::ethereum::EthereumAddress) -> Option<felt252>;

    fn get_all_endpoints() -> Array<eth::ethereum::EthereumAddress>;

    fn register_token(
        ref self: T,
        token_address: eth::ethereum::EthereumAddress,
        gateway_fee_limit_multiplier: u128,
        gas_limit_multiplier: u128,
    );

    fn register_protocol_contract(
        ref self: T,
        endpoint: eth::ethereum::EthereumAddress,
        contract_address: ContractAddress,
    );

    fn get_gateway_fee_limit_multiplier(token_address: eth::ethereum::EthereumAddress) -> u128;

    fn get_gas_limit_multiplier(token_address: eth::ethereum::EthereumAddress) -> u128;

    fn is_contract_registered(contract_address: ContractAddress) -> bool;

    fn transfer_eth_to_dest(
        ref self: T,
        from: eth::ethereum::EthereumAddress,
        to: eth::ethereum::EthereumAddress,
        value: u256,
        gateway_fee: u256,
        extra_args: bytes31,
    );
}

#[starknet::contract]
contract Resolver {
    use core::traits::TryInto;
    use core::num::traits::One;
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::ownable::OwnableDispatcher;
    use starknet::ContractAddress;
    use starknet::eth::ethereum::EthereumAddress;
    use starknet::eth::transfer_eth::transfer_eth;
    use starknet::eth::gas_utils::get_gas_price_from_l1_bounds;
    use starknet::eth::gas_utils::L1_GAS;
    use starknet::eth::gas_utils::L1_GAS_PRICE;
    use starknet::syscalls::storage_read_syscall;
    use starknet::syscalls::StorageReadResponse;
    use starknet::syscalls::StorageWriteSyscall;
    use starknet::syscalls::StorageWriteResponse;

    #[abi(embed_v0)]
    pub ownable: OwnableComponent<ContractState>;

    #[storage]
    struct Storage {
        endpoints: HashMap<EthereumAddress, felt252>,
        token_to_gateway_fee_limit_multiplier: HashMap<EthereumAddress, u128>,
        token_to_gas_limit_multiplier: HashMap<EthereumAddress, u128>,
        registered_contracts: HashSet<ContractAddress>,
        protocol_contracts: HashMap<EthereumAddress, ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        EndpointRegistered: EndpointRegistered,
        EndpointDeregistered: EndpointDeregistered,
        TokenRegistered: TokenRegistered,
        ContractRegistered: ContractRegistered,
        EthTransferred: EthTransferred,
        OwnershipTransferred: ownership::transfer_ownership::OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct EndpointRegistered {
        endpoint: EthereumAddress,
        url: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct EndpointDeregistered {
        endpoint: EthereumAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenRegistered {
        token_address: EthereumAddress,
        gateway_fee_limit_multiplier: u128,
        gas_limit_multiplier: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractRegistered {
        endpoint: EthereumAddress,
        contract_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct EthTransferred {
        from: EthereumAddress,
        to: EthereumAddress,
        value: u256,
        gateway_fee: u256,
        extra_args: bytes31,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let owner = starknet::contract_address_from_bytes31(starknet::msg_sender().try_into().unwrap());
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent<ContractState>;

    #[external(v0)]
    fn register_endpoint(
        ref self: ContractState,
        endpoint: EthereumAddress,
        url: felt252,
    ) {
        require(
            self.ownable.owner() == starknet::msg_sender(),
            'OnlyOwner',
        );
        self.endpoints.insert(endpoint, url);
        emit EndpointRegistered { endpoint, url };
    }

    #[external(v0)]
    fn deregister_endpoint(
        ref self: ContractState,
        endpoint: EthereumAddress,
    ) {
        require(
            self.ownable.owner() == starknet::msg_sender(),
            'OnlyOwner',
        );
        assert(self.endpoints.contains(endpoint), 'Endpoint not registered');
        self.endpoints.remove(endpoint);
        emit EndpointDeregistered { endpoint };
    }

    #[external(v0)]
    fn get_endpoint(endpoint: EthereumAddress) -> Option<felt252> {
        return self.endpoints.try_get(endpoint).into();
    }

    #[external(v0)]
    fn get_all_endpoints() -> Array<EthereumAddress> {
        let mut endpoints: Array<EthereumAddress> = array![];
        for endpoint in self.endpoints.iter() {
            endpoints.append(*endpoint);
        }
        endpoints
    }

    #[external(v0)]
    fn register_token(
        ref self: ContractState,
        token_address: EthereumAddress,
        gateway_fee_limit_multiplier: u128,
        gas_limit_multiplier: u128,
    ) {
        require(
            self.ownable.owner() == starknet::msg_sender(),
            'OnlyOwner',
        );
        self.token_to_gateway_fee_limit_multiplier.insert(token_address, gateway_fee_limit_multiplier);
        self.token_to_gas_limit_multiplier.insert(token_address, gas_limit_multiplier);
        emit TokenRegistered {
            token_address,
            gateway_fee_limit_multiplier,
            gas_limit_multiplier,
        };
    }

    #[external(v0)]
    fn register_protocol_contract(
        ref self: ContractState,
        endpoint: EthereumAddress,
        contract_address: ContractAddress,
    ) {
        require(
            self.ownable.owner() == starknet::msg_sender(),
            'OnlyOwner',
        );
        self.protocol_contracts.insert(endpoint, contract_address);
        self.registered_contracts.insert(contract_address);
        emit ContractRegistered { endpoint, contract_address };
    }

    #[external(v0)]
    fn get_gateway_fee_limit_multiplier(token_address: EthereumAddress) -> u128 {
        return *self.token_to_gateway_fee_limit_multiplier.try_get(token_address).unwrap();
    }

    #[external(v0)]
    fn get_gas_limit_multiplier(token_address: EthereumAddress) -> u128 {
        return *self.token_to_gas_limit_multiplier.try_get(token_address).unwrap();
    }

    #[external(v0)]
    fn is_contract_registered(contract_address: ContractAddress) -> bool {
        return self.registered_contracts.contains(contract_address);
    }

    #[external(v0)]
    fn transfer_eth_to_dest(
        ref self: ContractState,
        from: EthereumAddress,
        to: EthereumAddress,
        value: u256,
        gateway_fee: u256,
        extra_args: bytes31,
    ) {
        require(
            self.registered_contracts.contains(starknet::contract_address_from_bytes31(starknet::msg_sender().try_into().unwrap())),
            'Not a registered contract',
        );
        transfer_eth(
            from,
            to,
            value,
            gateway_fee,
            extra_args,
        );
        emit EthTransferred { from, to, value, gateway_fee, extra_args };
    }
}
