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
 
#[test]
fun test_multiple_tips() {
    let mut scenario = test_scenario::begin(OWNER);
 
    // Initialize the tip jar
    {
        let ctx = test_scenario::ctx(&mut scenario);
        tip_jar::init_for_testing(ctx);
    };
    
    //tipper 1 -> 0.5 SUI
    test_scenario::next_tx(&mut scenario, TIPPER_1);
    {
        let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);

        let tip_coin = create_test_coin(500_000_000, ctx);
    
        tip_jar::send_tip(&mut tip_jar, tip_coin, ctx);

        assert!(tip_jar::get_total_tips(&tip_jar) == 500_000_000, 0);
        assert!(tip_jar::get_tip_count(&tip_jar) == 1, 1);

        test_scenario::return_shared(tip_jar);
    

    };

    test_scenario::next_tx(&mut scenario, TIPPER_2);
    {
        let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let tip_coin = create_test_coin(1_500_000_000, ctx);
    
        tip_jar::send_tip(&mut tip_jar, tip_coin, ctx);

        assert!(tip_jar::get_total_tips(&tip_jar) == 2_000_000_000, 2);
        assert!(tip_jar::get_tip_count(&tip_jar) == 2, 3);

        test_scenario::return_shared(tip_jar);
    
    };

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let coin1 = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
        let coin2 = test_scenario::take_from_sender<Coin<SUI>>(&scenario);

        let value1 = coin::value(&coin);
        let value2 = coin::value(&coin2);
        let total_received = value1 + value2;

        assert!(total_received == 2_000_000_000, 4);
        assert!((value1 == 500_000_000 && value2 == 1_500_000_000) || (value1 == 1_500_000_000 && value2 = 500_000_000), 5);

        test_scenario::return_to_sender(&scenario, coin1);
        test_scenario::return_to_sender(&scenario, coin2);
    };

    test_scenario::end(&scenario);
}   

