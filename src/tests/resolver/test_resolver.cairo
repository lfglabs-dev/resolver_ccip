use starknet::ContractAddress;
// use starknet::contract_address::ContractAddressZeroable;
use starknet::contract_address_const;
use starknet::testing::{set_contract_address, set_block_timestamp};
use openzeppelin_utils::serde::SerializedAppend;
use openzeppelin_token::erc20::interface::{IERC20, IERC20Dispatcher};

use super::super::utils;
use super::erc20::ERC20;
// use identity::{
//     identity::main::Identity, interface::identity::{IIdentityDispatcher,
//     IIdentityDispatcherTrait}
// };
// use naming::interface::naming::{INamingDispatcher, INamingDispatcherTrait};
// use naming::interface::pricing::{IPricingDispatcher, IPricingDispatcherTrait};
// use naming::naming::main::Naming;
// use naming::pricing::Pricing;
use resolver::interface::resolver::{IResolverDispatcher, IResolverDispatcherTrait};
use resolver::resolver::Resolver;

fn deploy(pub_key: felt252) -> (IERC20Dispatcher, // IPricingDispatcher,
 // IIdentityDispatcher,
// INamingDispatcher,
IResolverDispatcher) {
    let admin = 0x123;
    // erc20
    let mut erc20_calldata = array![];
    erc20_calldata.append_serde(contract_address_const::<0x123>());
    erc20_calldata.append_serde(0x100000000000000000000000000000000_u256);
    let eth = utils::deploy(ERC20::TEST_CLASS_HASH, erc20_calldata);

    // // pricing
    // let pricing = utils::deploy(Pricing::TEST_CLASS_HASH, array![eth.into()]);

    // // identity
    // let identity = utils::deploy(Identity::TEST_CLASS_HASH, array![admin, 0]);

    // // naming
    // let address = utils::deploy(
    //     Naming::TEST_CLASS_HASH, array![identity.into(), pricing.into(), 0, admin]
    // );

    let resolver = utils::deploy(Resolver::TEST_CLASS_HASH, array![admin, pub_key]);
    (
        IERC20Dispatcher {
            contract_address: eth
        }, // IPricingDispatcher { contract_address: pricing },
        // IIdentityDispatcher { contract_address: identity },
        // INamingDispatcher { contract_address: address },
        IResolverDispatcher { contract_address: resolver }
    )
}

#[test]
#[available_gas(20000000000)]
fn test_uri() {
    // let (eth, pricing, identity, naming, resolver) = deploy(
    //     0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4
    // );
    let (_, resolver) = deploy(0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4);

    let caller = contract_address_const::<0x123>();
    set_contract_address(caller);

    // add some uris
    resolver.add_uri(array!['http://0.0.0.0:8090/resolve?dom', 'ain='].span());
    resolver.add_uri(array!['http://sepolia.starknet.id/reso', 'lve?domain='].span());
    resolver.add_uri(array!['http://sepolia_2.starknet.id/re', 'solve?domain='].span());

    let uris = resolver.get_uris();
    assert(uris.len() == 9, 'wrong length');
    assert(uris.at(0) == @2, 'wrong nb of arg');
    assert(uris.at(1) == @'http://0.0.0.0:8090/resolve?dom', 'wrong uri');
    assert(uris.at(2) == @'ain=', 'wrong uri');
    assert(uris.at(3) == @2, 'wrong nb of arg');
    assert(uris.at(4) == @'http://sepolia.starknet.id/reso', 'wrong 2nd uri');
    assert(uris.at(5) == @'lve?domain=', 'wrong 2nd uri');
    assert(uris.at(6) == @2, 'wrong nb of arg');
    assert(uris.at(7) == @'http://sepolia_2.starknet.id/re', 'wrong 2nd uri');
    assert(uris.at(8) == @'solve?domain=', 'wrong 2nd uri');
    // remove the uri at index 1
    resolver.remove_uri(1);
    let uris = resolver.get_uris();
    assert(uris.len() == 6, 'wrong length');
    assert(uris.at(0) == @2, 'wrong nb of arg');
    assert(uris.at(1) == @'http://0.0.0.0:8090/resolve?dom', 'wrong uri');
    assert(uris.at(2) == @'ain=', 'wrong uri');
    assert(uris.at(3) == @2, 'wrong nb of arg');
    assert(uris.at(4) == @'http://sepolia_2.starknet.id/re', 'wrong 2nd uri');
    assert(uris.at(5) == @'solve?domain=', 'wrong 2nd uri');
}
// #[test]
// #[available_gas(20000000000)]
// #[should_panic(
//     expected: (
//         'offchain_resolving',
//         1,
//         999902,
//         1,
//         'http://0.0.0.0:8090',
//         2,
//         'http://0.0.0.0:8090/resolve?dom',
//         'ain=',
//         'ENTRYPOINT_FAILED',
//         'ENTRYPOINT_FAILED'
//     )
// )]
// fn test_offchain_resolving_no_hint() {
//     // setup
//     let (eth, pricing, identity, naming, resolver) = deploy(
//         0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4
//     );
//     let caller = contract_address_const::<0x123>();
//     set_contract_address(caller);
//     let id1: u128 = 1;
//     let iris: felt252 = 999902;
//     let notion: felt252 = 1059716045;

//     // add uri
//     resolver.add_uri(array!['http://0.0.0.0:8090'].span());
//     resolver.add_uri(array!['http://0.0.0.0:8090/resolve?dom', 'ain='].span());

//     //we mint an identity
//     identity.mint(id1);

//     // we check how much a domain costs
//     let (_, price) = pricing.compute_buy_price(6, 365);

//     // we allow the naming to take our money
//     eth.approve(naming.contract_address, price);

//     // we buy with a resolver, no sponsor, no discount and empty metadata
//     naming.buy(id1, notion, 365, resolver.contract_address, ContractAddressZeroable::zero(), 0,
//     0);

//     // we call resolve on the naming contract for subdomain iris.notion.stark
//     // It should panic with 'offchain_resolving' and the external uri to call
//     let result = naming
//         .resolve(array![999902, 1059716045].span(), 121424973492078, array![].span());
// }
// #[test]
// #[available_gas(20000000000)]
// fn test_offchain_resolving_with_hint() {
//     // setup
//     let (eth, pricing, identity, naming, resolver) = deploy(
//         0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4
//     );
//     let caller = contract_address_const::<0x123>();
//     set_contract_address(caller);
//     let id1: u128 = 1;
//     let notion: felt252 = 1059716045;
//     let iris: felt252 = 999902;

//     // add uri
//     resolver.add_uri(array!['http://0.0.0.0:8090'].span());
//     resolver.add_uri(array!['http://0.0.0.0:8090/resolve?dom', 'ain='].span());

//     let max_validity: felt252 = 1701167467;
//     let timestamp: u64 = 1701167467 - 1800; // max_validity - 30 minutes
//     set_block_timestamp(timestamp);

//     //we mint an identity
//     identity.mint(id1);

//     // we check how much a domain costs
//     let (_, price) = pricing.compute_buy_price(6, 365);

//     // we allow the naming to take our money
//     eth.approve(naming.contract_address, price);

//     // we buy with a resolver, no sponsor, no discount and empty metadata
//     naming.buy(id1, notion, 365, resolver.contract_address, ContractAddressZeroable::zero(), 0,
//     0);

//     // we call resolve on the naming contract for subdomain iris.notion.stark
//     // It should return the address of the user
//     let result = naming
//         .resolve(
//             array![999902, 1059716045].span(),
//             'starknet',
//             array![
//                 0x04a8173e2F008282aC9793FB929974Cc7CEd6cEb76c79A0A9e0D163e60d08b6f,
//                 245371453901460459147748049728129673559137408586661778136962765820508164010,
//                 3537788104880290368328032579969034182821490439553457951875836525032598257669,
//                 max_validity,
//             ]
//                 .span()
//         );
//     assert(
//         result == 0x04a8173e2F008282aC9793FB929974Cc7CEd6cEb76c79A0A9e0D163e60d08b6f,
//         'wrong address'
//     );
// }

// #[test]
// #[available_gas(20000000000)]
// #[should_panic(expected: ('Signature expired', 'ENTRYPOINT_FAILED', 'ENTRYPOINT_FAILED'))]
// fn test_offchain_resolving_with_hint_expired_sig() {
//     // setup
//     let (eth, pricing, identity, naming, resolver) = deploy(
//         0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4
//     );
//     let caller = contract_address_const::<0x123>();
//     set_contract_address(caller);
//     let id1: u128 = 1;
//     let notion: felt252 = 1059716045;
//     let iris: felt252 = 999902;

//     let max_validity: felt252 = 1701167467;
//     let timestamp: u64 = 1701167467 + 1800; // max_validity + 30 minutes
//     set_block_timestamp(timestamp);

//     //we mint an identity
//     identity.mint(id1);

//     // we check how much a domain costs
//     let (_, price) = pricing.compute_buy_price(6, 365);

//     // we allow the naming to take our money
//     eth.approve(naming.contract_address, price);

//     // we buy with a resolver, no sponsor, no discount and empty metadata
//     naming.buy(id1, notion, 365, resolver.contract_address, ContractAddressZeroable::zero(), 0,
//     0);

//     // we call resolve on the naming contract for subdomain iris.notion.stark
//     // It should panic as signature is invalid
//     let result = naming
//         .resolve(
//             array![999902, 1059716045].span(),
//             'starknet',
//             array![
//                 0x04a8173e2F008282aC9793FB929974Cc7CEd6cEb76c79A0A9e0D163e60d08b6f,
//                 1,
//                 2,
//                 max_validity
//             ]
//                 .span()
//         );
// }

// #[test]
// #[available_gas(20000000000)]
// #[should_panic(expected: ('Invalid signature', 'ENTRYPOINT_FAILED', 'ENTRYPOINT_FAILED'))]
// fn test_offchain_resolving_with_hint_invalid_sig() {
//     // setup
//     let (eth, pricing, identity, naming, resolver) = deploy(
//         0x64018d8ea7829641419aff38ea79efd3eafedf3a5c1fe001d35339b889d48f4
//     );
//     let caller = contract_address_const::<0x123>();
//     set_contract_address(caller);
//     let id1: u128 = 1;
//     let notion: felt252 = 1059716045;
//     let iris: felt252 = 999902;

//     let max_validity: felt252 = 1701167467;
//     let timestamp: u64 = 1701167467 - 1800; // max_validity - 30 minutes
//     set_block_timestamp(timestamp);

//     //we mint an identity
//     identity.mint(id1);

//     // we check how much a domain costs
//     let (_, price) = pricing.compute_buy_price(6, 365);

//     // we allow the naming to take our money
//     eth.approve(naming.contract_address, price);

//     // we buy with a resolver, no sponsor, no discount and empty metadata
//     naming.buy(id1, notion, 365, resolver.contract_address, ContractAddressZeroable::zero(), 0,
//     0);

//     // we call resolve on the naming contract for subdomain iris.notion.stark
//     // It should panic as signature is invalid
//     let result = naming
//         .resolve(
//             array![999902, 1059716045].span(),
//             'starknet',
//             array![
//                 0x04a8173e2F008282aC9793FB929974Cc7CEd6cEb76c79A0A9e0D163e60d08b6f,
//                 1,
//                 2,
//                 max_validity
//             ]
//                 .span()
//         );
// }


