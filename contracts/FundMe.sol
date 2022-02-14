//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmount;

    uint256 public minimumUSD = 50 * 10**18;

    uint256 public value = msg.value;
    address[] public funders;

    function fund() public payable {
        require(
            getConvertionRate(msg.value) >= minimumUSD,
            "You need to sent more ETH"
        );
        addressToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrices() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1000000000000000000);
    }

    function getConvertionRate(uint256 ethAmt) public view returns (uint256) {
        uint256 ethPrice = getPrices();
        uint256 ethInUSD = (ethAmt * ethPrice) / 1000000000000000000;
        return ethInUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrices();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY OWNER");
        _;
    }

    function widthdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (uint256 i = 0; i < funders.length; i++) {
            addressToAmount[funders[i]] = 0;
        }
        funders = new address[](0);
    }
}
