// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "./Helper.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {BasicMessageSender} from "../src/BasicMessenger/BasicMessageSender.sol";
import {BasicMessageReceiver} from "../src/BasicMessenger/BasicMessageReceiver.sol";
contract BasicMessenger is Script, Helper {
    // run sepholia to avalanche fujji
    function deploySender(
        SupportedNetworks source
    ) external returns (BasicMessageSender sender) {

        
     
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address sourceRouter, address linkToken, , ) = getConfigFromNetwork(
            source
        );
 
 
        sender = new BasicMessageSender(sourceRouter, linkToken);
 
     

        console.log(
            " your contract is deployed at address: ",address(sender)  );
        

        vm.stopBroadcast();
         
    }

     
    function deployReceiver(
       SupportedNetworks destination
    ) external returns ( BasicMessageReceiver receiver) {

      
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

  
        (address desinationRouter, , , ) = getConfigFromNetwork(destination);

 
         receiver = new BasicMessageReceiver(desinationRouter);

 

        console.log( " your contract is deployed at address: ",address(receiver)  );
 
        vm.stopBroadcast();

        
    }
    function getFees(
        
        string memory message,
        SupportedNetworks source,
        SupportedNetworks destination,
         address receiver
    ) external returns (uint256 fees) {
 
     
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address sourceRouter, address linkToken, , ) = getConfigFromNetwork(
            source
        );
        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);

 
        

        Client.EVM2AnyMessage memory _message = Client.EVM2AnyMessage({
            receiver: abi.encode(address(receiver)),
            data: abi.encode(message),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs:"",// let's leave the default for now
            feeToken: linkToken
        });

          fees = IRouterClient(sourceRouter).getFee(
            destinationChainId,
            _message
        );
 
     

        console.log("fees: ", fees);
 
        vm.stopBroadcast();
    }
    function sendMessage(
         address payable sender,
        SupportedNetworks destination,
        address receiver,
        string memory message
     ) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);
         bytes32 messageId = BasicMessageSender(sender).sendMessageWithLinkFee(
           
            receiver,
            message,
             destinationChainId
             
        );

        console.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console.logBytes32(messageId);

        vm.stopBroadcast();
    }
    function sendMessageWithEth(
         address payable sender,
        SupportedNetworks destination,
        address receiver,
        string memory message
     ) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);
         bytes32 messageId = BasicMessageSender(sender).sendMessageWithEthFee{value:0.2 ether}(
           
            receiver,
            message,
             destinationChainId
             
        );

        console.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console.logBytes32(messageId);

        vm.stopBroadcast();
    }

}
