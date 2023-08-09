// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "./Helper.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
 import {TokenAndDataReceiver} from "../src/TokenAndDataTransfer/TokenAndDataReceiver.sol";
import {TokenAndDataSender} from "../src/TokenAndDataTransfer/TokenAndDataSender.sol";
import {MyNFTAirDrop} from "../src/TokenAndDataTransfer/MyNFTAirDrop.sol";
contract NFTMinter is Script, Helper {
    // run sepholia to avalanche fujji
    function deploySender(
        SupportedNetworks source
    ) external returns (TokenAndDataSender sender) {

        
     
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address sourceRouter, address linkToken, , ) = getConfigFromNetwork(
            source
        );
 
 
        sender = new TokenAndDataSender(sourceRouter, linkToken);
 
     // send some link token to the contract to be used to pay fees
     IERC20(linkToken).transfer(address(sender),1 ether);

        console.log(
            " your contract is deployed at address: ",address(sender)  );
        

        vm.stopBroadcast();
         
    }

    

    function getFees(
        
         address  _token,
         uint256 _amount,
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

 
        Client.EVMTokenAmount[]  memory tokens = new Client.EVMTokenAmount[](1);
        tokens[0]=  Client.EVMTokenAmount({
            token:_token,
            amount:_amount
        });

        Client.EVM2AnyMessage memory _message = Client.EVM2AnyMessage({
            receiver: abi.encode(address(receiver)),
              data:abi.encodeWithSignature("mint(address)",msg.sender),
            tokenAmounts: tokens,
            extraArgs:"",
            feeToken: linkToken
        });

          fees = IRouterClient(sourceRouter).getFee(
            destinationChainId,
            _message
        );
 
     

        console.log("fees: ", fees);
 
        vm.stopBroadcast();
    }
    function send(
         address payable sender,
      
        address receiver,
          SupportedNetworks destination,
          SupportedNetworks source,
        address _token,
        uint256 _amount,
        uint256 fees
     ) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
           (, address linkToken, , ) = getConfigFromNetwork(
            source
        );
         IERC20(linkToken).transfer(sender,fees);
        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);
        IERC20(_token).transfer(sender, _amount);
         bytes32 messageId = TokenAndDataSender(sender).send(
           
            receiver,   _token,   _amount,   destinationChainId
             
        );

        console.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console.logBytes32(messageId);

        vm.stopBroadcast();
    }
  
    function deployReceiver(
       SupportedNetworks destination
    ) external returns ( TokenAndDataReceiver receiver) {

      
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

  
        (address desinationRouter, , , ) = getConfigFromNetwork(destination);

 
         receiver = new TokenAndDataReceiver(desinationRouter);

 

        console.log( " your contract is deployed at address: ",address(receiver)  );
 
        vm.stopBroadcast();

        
    }
}
