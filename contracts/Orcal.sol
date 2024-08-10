// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/provable-things/ethereum-api/blob/master/contracts/solc-v0.8.x/provableAPI.sol";

contract Orcale is usingProvable {
    string public ETH;

    function getEthProce() public {
        provable_query(
            "URL",
            "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD"
        );
    }

    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == provable.cbAddress());
        ETH = _result;
        _myid;
    }
}
