#[test_only]
module tip_jar::tip_jar_tests;
 
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::test_scenario;
use tip_jar::tip_jar::{Self, TipJar};
 
const OWNER: address = @0xA11CE;
const TIPPER_1: address = @0xB0B;
const TIPPER_2: address = @0xCAFE;
 
fun create_test_coin(amount: u64, ctx: &mut TxContext): Coin<SUI> {
    coin::mint_for_testing<SUI>(amount, ctx)
}
 
#[test]
fun test_init_creates_tip_jar() {
    let mut scenario = test_scenario::begin(OWNER);
    let ctx = test_scenario::ctx(&mut scenario);
 
    tip_jar::init_for_testing(ctx);
 
    test_scenario::next_tx(&mut scenario, OWNER);
 
    let tip_jar = test_scenario::take_shared<TipJar>(&scenario);
 
    assert!(tip_jar::get_owner(&tip_jar) == OWNER, 0);
    assert!(tip_jar::get_total_tips(&tip_jar) == 0, 1);
    assert!(tip_jar::get_tip_count(&tip_jar) == 0, 2);
    assert!(tip_jar::is_owner(&tip_jar, OWNER) == true, 3);
    assert!(tip_jar::is_owner(&tip_jar, TIPPER_1) == false, 4);
 
    test_scenario::return_shared(tip_jar);
    test_scenario::end(scenario);
}
 