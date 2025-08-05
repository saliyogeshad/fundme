// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give USER some ether
    }

    function testMinimumDollarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        // for this test to pass , watch video:9 running tests on chains forks to run on test/main nets
        uint256 version = fundMe.getVersion(); //
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER); // Simulate a transaction from USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStrcture() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundertoArrayOfFuders() public funded {
        // vm.prank(USER); // Simulate a transaction from USER
        // fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm.prank(USER); // Simulate a transaction from USER
        // fundMe.fund{value: SEND_VALUE}();
        vm.prank(USER);
        vm.expectRevert("FundMe__NotOwner()");
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice;
        vm.prank(fundMe.getOwner()); // Simulate a transaction from the owner
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used for withdraw:", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithDrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; //why 1? because 0 is USER , and other problems might arise if we use 0
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); //===> prank + deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner()); // Simulate a transaction from the owner
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
