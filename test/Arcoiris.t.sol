pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";.
import {Arcoiris} from "contracts/Arcoiris.sol";

contract ArcoirisTestHarness is Arcoiris {
}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;

    function setUp() public {
    }

    function test_createGathering() public {
        arcoiris.createGathering(address(0), address(0), address(msg.sender), false)
    }
}
