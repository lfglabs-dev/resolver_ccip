use starknet::{ContractAddress, SyscallResultTrait};
use starknet::syscalls::deploy_syscall;

pub fn deploy(contract_class_hash: felt252, calldata: Array<felt252>) -> ContractAddress {
    let (address, _) = deploy_syscall(
        contract_class_hash.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap_syscall();
    address
}
