// SPDX-License: MIT
pragma solidity 0.8.19;
import {MyNFTAirDrop} from "./MyNFTAirDrop.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

contract TokenAndDataReceiver is CCIPReceiver {
    uint256 public messageCount;
    uint256 constant public price=2;
    MyNFTAirDrop public nft;

 
    // sepholia router address
    constructor(address router) CCIPReceiver(router) {
        nft = new MyNFTAirDrop();
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
                require(message.destTokenAmounts[0].amount >= price, "Not enough CCIP-BnM for mint");
        (bool success, ) = address(nft).call(message.data);
        require(success, "Failed to mint nft ");

        ++messageCount;
    }
}


