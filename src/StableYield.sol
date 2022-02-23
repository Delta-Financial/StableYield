// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./console.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDFV {
    struct VaultInformation {
        uint256 totalFarmingPower;
        uint256 accumulatedDELTAPerShareE12;
        uint256 accumulatedETHPerShareE12;
    }

    function deposit(uint256 numberRLP, uint256 numberDELTA) external;
    function addNewRewards(uint256 amountDELTA, uint256 amountWETH) external;
    function vaultInfo() external view returns (VaultInformation memory vaultInfo);
}

contract StableYield {

    address constant DEV_ADDRESS = 0x5A16552f59ea34E44ec81E58b3817833E9fD5436;
    IERC20 constant DELTA = IERC20(0x9EA3b5b4EC044b70375236A281986106457b20EF);
    address constant DFV_ADDRESS = 0x9fE9Bb6B66958f2271C4B0aD23F6E8DDA8C221BE;
    IDFV constant DFV = IDFV(DFV_ADDRESS);

    uint256 constant WEEKLY_DELTA_TO_SEND = 25000 ether;
    uint256 constant SECONDS_PER_WEEK = 7 days;

    // Amount of DELTA you get per block for calling distribute()
    uint256 constant WEEKLY_TIP = 20 ether;

    uint256 public lastDistributionTime;
    bool public enabled;

    modifier onlyDev() {
        require(msg.sender == DEV_ADDRESS, "Nope");
        _;
    }

    constructor() {
        lastDistributionTime = 1645115480;
        DELTA.approve(DFV_ADDRESS, type(uint256).max);
    }

    function setEnabled(bool _enabled) public onlyDev {
        enabled = _enabled;
    }

    function updateAllowance() external {
        DELTA.approve(DFV_ADDRESS, type(uint256).max);
    }

    function distribute() external {
        require(block.timestamp > lastDistributionTime + 120, "Too soon");
        require(enabled, "Distributions disabled");
        // uint256 blockDelta = block.number - lastDistributionBlock;
        uint256 timeDelta = block.timestamp - lastDistributionTime;
        if(timeDelta >= SECONDS_PER_WEEK) {
            // Capped at one week worth of rewards per distribution. Better call it :o
            timeDelta = SECONDS_PER_WEEK;
        }
        uint256 percentageOfAWeekPassede4 = (timeDelta * 1e4) / SECONDS_PER_WEEK;
        console.log("timeDelta",timeDelta);
        console.log("SECONDS_PER_WEEK",SECONDS_PER_WEEK);
        console.log("percentageOfAWeekPassed",percentageOfAWeekPassede4);
        uint256 distribution = (WEEKLY_DELTA_TO_SEND * percentageOfAWeekPassede4) / 1e4;
        console.log("WEEKLY_DELTA_TO_SEND / percentageOfAWeekPassede4", WEEKLY_DELTA_TO_SEND, percentageOfAWeekPassede4);
        uint256 tip = (WEEKLY_TIP * percentageOfAWeekPassede4) / 1e4;
        require(distribution > 0);
        console.log("distribution", distribution, distribution/1e18);
        console.log("tip", tip, tip/1e18);

        DFV.addNewRewards(distribution, 0);
        console.log("distribute6");
        DELTA.transfer(msg.sender, tip);
        console.log("distribute7");
        DFV.deposit(0,1);
        lastDistributionTime = block.timestamp;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external virtual onlyDev {
        IERC20(tokenAddress).transfer(DEV_ADDRESS, tokenAmount);
    }

    function die(uint256 nofuckery) external onlyDev payable {
        require(nofuckery==175, "Oooops");
        selfdestruct(payable(DEV_ADDRESS));
    }

}
