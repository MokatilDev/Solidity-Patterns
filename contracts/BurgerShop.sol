// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Orcal.sol";

contract BurgerShop is Orcale {
    uint256 public normalCost = 0.1 ether;
    uint256 public deluxCost = 0.3 ether;
    address public owner; 

    constructor() payable {
        owner = msg.sender;
    }

    event BoughetBurger(address indexed _from, uint256 _cost);

    enum Stages {
        readyToOrder,
        makeBurger,
        deliverBuger
    }

    Stages public burgerShopStage = Stages.readyToOrder;

    modifier shouldPay(uint256 _cost) {
        require(msg.value >= _cost, "The burger cost more!");
        _;
    }

    modifier checkAddress(address _addrs) {
        require(_addrs != address(0),"Invalid address");
        _;
    }

    modifier isAtStage(Stages _stage) {
        require(burgerShopStage == _stage, "Not in correct stage.");
        _;
    }

    function buyBurger() public payable shouldPay(normalCost) isAtStage(Stages.readyToOrder) {
        updateStage(Stages.makeBurger);
        emit BoughetBurger(msg.sender, normalCost);
    }

    function buyDeluxBurge() public payable shouldPay(deluxCost) isAtStage(Stages.readyToOrder)  {
        updateStage(Stages.makeBurger);
        emit BoughetBurger(msg.sender, deluxCost);
    }

    function refund(address _to, uint256 _cost)
        public
        payable
        checkAddress(_to)
    {

        require(
            _cost == normalCost || _cost == deluxCost,
            "You are trying refund the wrong amount!"
        );

        uint256 currentBalance = address(this).balance;
        if (currentBalance >= _cost) {
            (bool success, ) = payable(_to).call{value: _cost}("");
            require(success);
        }else {
            revert("Not enough funds");
        }

        assert(address(this).balance == currentBalance - _cost);
    }

    function deliverBurger() public isAtStage(Stages.makeBurger) {
        updateStage(Stages.deliverBuger);
    }

    function pickUpBurger() public isAtStage(Stages.deliverBuger){
        updateStage(Stages.readyToOrder);
    }

    function getFunds() public view returns (uint256 balance) {
        return address(this).balance;
    }

    function updateStage(Stages _stage) public {
        burgerShopStage = _stage;
    }
}
