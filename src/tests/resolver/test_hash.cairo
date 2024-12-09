use resolver::resolver::Resolver;
use resolver::resolver::Resolver::InternalImpl;

#[test]
#[available_gas(20000000000)]
fn test_hash_function() {
    let mut unsafe_state = Resolver::unsafe_new_contract_state();

    // testing an empty array
    let input_0 = array![];
    let output_0 = InternalImpl::hash_domain(@unsafe_state, input_0.span());
    assert(output_0 == 0, 'Should return 0');

    // testing an encoded root domain iris
    let input_1 = array![999902];
    let output_1 = InternalImpl::hash_domain(@unsafe_state, input_1.span());
    assert(
        output_1 == 2819968515778978195378012518635693386896866121180586187462905840795338238772,
        'Wrong output value'
    );

    // testing an encoded subdomain iris.notion
    let output_2 = InternalImpl::hash_domain(@unsafe_state, array![999902, 1059716045].span());
    assert(
        output_2 == 743232737575968623292492568916248379498607022315110255883250117418490029830,
        'Wrong output value'
    );
}
