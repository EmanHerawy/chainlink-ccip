// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

contract BasicMessageReceiver is CCIPReceiver {
    string public lastMessage;
    mapping(bytes32 => string) public Messages;

    // sepholia router address
    constructor(address router) CCIPReceiver(router) {}

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        lastMessage = abi.decode(message.data, (string));
        Messages[message.messageId] = lastMessage;
    }
}

// deployed at 0xb8112B68A956B2d05F5cC11D7B52103748DCc6Ee
