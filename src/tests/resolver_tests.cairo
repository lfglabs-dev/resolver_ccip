use snforge_std::{test, assert, log_debug};
use openzeppelin::access::ownable::ownable::OwnableDispatcher;
use resolver_ccip::resolver::{ResolverDispatcher, ResolverTrait};

#[test]
fn test_register_and_get_endpoint() {
    let (dispatcher, _) = deploy_resolver();
    
    let endpoint = starknet::eth::ethereum::EthereumAddress { low: 123 };
    let url = 'http://example.com';
    
    dispatcher.register_endpoint(endpoint, url);
    
    assert!(dispatcher.get_endpoint(endpoint) == Some(url));
}

#[test]
fn test_deregister_endpoint() {
    let (dispatcher, _) = deploy_resolver();
    
    let endpoint = starknet::eth::ethereum::EthereumAddress { low: 123 };
    let url = 'http://example.com';
    
    dispatcher.register_endpoint(endpoint, url);
    dispatcher.deregister_endpoint(endpoint);
    
    assert!(dispatcher.get_endpoint(endpoint) == None);
}

#[test]
fn test_register_token() {
    let (dispatcher, _) = deploy_resolver();
    
    let token_address = starknet::eth::ethereum::EthereumAddress { low: 456 };
    let gateway_fee_limit_multiplier: u128 = 100;
    let gas_limit_multiplier: u128 = 200;
    
    dispatcher.register_token(token_address, gateway_fee_limit_multiplier, gas_limit_multiplier);
    
    assert!(dispatcher.get_gateway_fee_limit_multiplier(token_address) == gateway_fee_limit_multiplier);
    assert!(dispatcher.get_gas_limit_multiplier(token_address) == gas_limit_multiplier);
}

#[test]
fn test_register_protocol_contract() {
    let (dispatcher, _) = deploy_resolver();
    
    let endpoint = starknet::eth::ethereum::EthereumAddress { low: 123 };
    let contract_address = starknet::contract_address_from_bytes31(starknet::eth::ethereum::EthereumAddress { low: 456 }.low.try_into().unwrap());
    
    dispatcher.register_protocol_contract(endpoint, contract_address);
    
    assert!(dispatcher.is_contract_registered(contract_address));
}

fn deploy_resolver() -> (ResolverDispatcher, starknet::ContractAddress) {
    let contract_address = starknet::contract_address_from_bytes31(starknet::eth::ethereum::EthereumAddress { low: 123 }.low.try_into().unwrap());
    let dispatcher = ResolverDispatcher { contract_address };
    (dispatcher, contract_address)
}
