// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./Vm/CheatCodes.sol";
import "../StableYield.sol";

contract ContractTest is DSTest {
    IERC20 constant DELTA = IERC20(0x9EA3b5b4EC044b70375236A281986106457b20EF);
    IDFV constant vault = IDFV(0x9fE9Bb6B66958f2271C4B0aD23F6E8DDA8C221BE);

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    StableYield sYield;
    function setUp() public {
        sYield = new StableYield();
    }

    function testExample() public {
        vm.startPrank(0x5A16552f59ea34E44ec81E58b3817833E9fD5436);

        IDFV.VaultInformation memory vaultInfoBefore = vault.vaultInfo();
        sYield.setEnabled(true);

        // supply with some delta
        DELTA.transfer(address(sYield), 90000 ether);

        sYield.distribute();

        IDFV.VaultInformation memory vaultInfoAfter = vault.vaultInfo();

        console.log("before", vaultInfoBefore.accumulatedDELTAPerShareE12);
        console.log("after", vaultInfoAfter.accumulatedDELTAPerShareE12);
        assertTrue(vaultInfoAfter.accumulatedDELTAPerShareE12 - vaultInfoBefore.accumulatedDELTAPerShareE12 > 0);
    }
}
