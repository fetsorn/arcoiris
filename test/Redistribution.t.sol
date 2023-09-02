pragma solidity 0.8.19;

import {Test, Vm} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC721PresetMinterPauserAutoId} from "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Even} from "contracts/redistributions/Even.sol";
import {Proportional} from "contracts/redistributions/Proportional.sol";
import {IRedistribution} from "contracts/interfaces/IRedistribution.sol";

contract ArcoirisTestHarness is Arcoiris {}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;
    ERC721PresetMinterPauserAutoId token;
    uint256 gatheringID;
    uint256 ceremonyID;
    address addressAlice = address(1);
    address addressBob = address(2);
    address addressTony = address(3);
    address addressMC = address(4);
    uint256 tokenAlice;
    uint256 tokenBob;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();

        token = new ERC721PresetMinterPauserAutoId(
            "Base",
            "BASE",
            "https://example.com"
        );

        // mint token to Alice
        vm.prank(addressAlice);
        token.setApprovalForAll(address(arcoiris), true);
        token.mint(addressAlice);
        token.mint(addressAlice);
        token.mint(addressAlice);
        token.mint(addressAlice);
        token.mint(addressAlice);

        // mint token to Bob
        vm.prank(addressBob);
        token.setApprovalForAll(address(arcoiris), true);
        token.mint(addressBob);
        token.mint(addressBob);
        token.mint(addressBob);
        token.mint(addressBob);
        token.mint(addressBob);

        // mint token to Tony
        vm.prank(addressTony);
        token.setApprovalForAll(address(arcoiris), true);
        token.mint(addressTony);
        token.mint(addressTony);
        token.mint(addressTony);
        token.mint(addressTony);
        token.mint(addressTony);
    }

    function create(address redistribution) public {
        gatheringID = arcoiris.createGathering(
            address(token),
            redistribution,
            addressMC,
            false
        );

        vm.prank(addressMC);

        ceremonyID = arcoiris.createCeremony(gatheringID);
    }

    function contribute(address sibling, uint256 amount) public {
        vm.prank(sibling);

        arcoiris.contributeBatch(
            gatheringID,
            ceremonyID,
            address(token),
            amount
        );
    }

    function redistribute(
        uint256 shareAlice,
        uint256 shareBob,
        uint256 shareTony
    ) public {
        // mc ends collection
        vm.prank(addressMC);
        arcoiris.endCollection(gatheringID, ceremonyID);

        // mc redistributes

        address[] memory siblings = new address[](3);
        siblings[0] = addressAlice;
        siblings[1] = addressBob;
        siblings[2] = addressTony;

        uint256[] memory priorities = new uint256[](3);
        priorities[0] = shareAlice;
        priorities[1] = shareBob;
        priorities[2] = shareTony;

        vm.prank(addressMC);

        arcoiris.redistribute(gatheringID, ceremonyID, siblings, priorities);
    }

    function validate(
        uint256 balanceAlice,
        uint256 balanceBob,
        uint256 balanceTony
    ) public {
        assertEq(token.balanceOf(addressAlice), balanceAlice);
        assertEq(token.balanceOf(addressBob), balanceBob);
        assertEq(token.balanceOf(addressTony), balanceTony);
    }

    function test_even_111_equal() public {
        create(address(new Even()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,1,1);

        validate(5,5,5);
    }

    function test_even_111_alice_takes_all() public {
        create(address(new Even()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,0,0);

        validate(5,5,5);
    }

    function test_even_111_alice_and_bob() public {
        create(address(new Even()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,1,0);

        validate(5,5,5);
    }

    function test_proporitonal_111_alice_takes_all() public {
        create(address(new Proportional()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,0,0);

        validate(7,4,4);
    }

    function test_proportional_111_alice_and_bob() public {
        create(address(new Proportional()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,1,0);

        validate(6,5,4);
    }

    function test_proporitonal_reverse_111_alice_takes_all() public {
        create(address(new Proportional()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        // least priority is winner
        // TODO: should 0 be winner or loser?
        redistribute(0,1,1);

        validate(4,7,6);
    }

    function test_proportional_reverse_111_alice_and_bob() public {
        create(address(new Proportional()));

        contribute(addressAlice, 1);

        contribute(addressBob, 1);

        contribute(addressTony, 1);

        redistribute(1,1,0);

        validate(6,5,4);
    }
}
