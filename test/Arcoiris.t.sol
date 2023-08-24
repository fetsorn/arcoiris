pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Even} from "contracts/redistributions/Even.sol";

contract ArcoirisTestHarness is Arcoiris {
}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();
    }

    function test_createGathering() public {
        Even even = Even(address(0));

        uint256 gatheringID = arcoiris.createGathering(
            address(0),
            even,
            address(msg.sender),
            false
        );

        assertEq(gatheringID, 0);
    }
}
