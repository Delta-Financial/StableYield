// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./Vm/CheatCodes.sol";
import "../StableYield.sol";

contract ContractTest is DSTest {
    IERC20 constant DELTA = IERC20(0x9EA3b5b4EC044b70375236A281986106457b20EF);
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    StableYield sYield;
    function setUp() public {
        sYield = new StableYield();
    }

    function testExample() public {
        vm.startPrank(0x5A16552f59ea34E44ec81E58b3817833E9fD5436);
        sYield.enableWithDefaults();

        // supply with some delta
        DELTA.transfer(address(sYield), 90000e18);

        sYield.distribute();
        assertTrue(true);
    }
}
