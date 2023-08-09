// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "./Helper.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {BasicERC20TokenSender} from "../src/ERC20Transfer/BasicERC20TokenSender.sol";
contract BasicMessenger is Script, Helper {
    // run sepholia to avalanche fujji
    function deploySender(
        SupportedNetworks source
    ) external returns (BasicERC20TokenSender sender) {

        
     
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address sourceRouter, address linkToken, , ) = getConfigFromNetwork(
            source
        );
 
 
        sender = new BasicERC20TokenSender(sourceRouter, linkToken);
 
     // send some link token to the contract to be used to pay fees
     IERC20(linkToken).transfer(address(sender),1 ether);

        console.log(
            " your contract is deployed at address: ",address(sender)  );
        

        vm.stopBroadcast();
         
    }

     // reciver 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
     // token address 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4
     // sender 0x69CEAA83993F2Cd1AABf3849A2Dc32AB2baA740a

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
            data: "",
            tokenAmounts: tokens,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0, strict: false})),
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
        address _token,
        uint256 _amount
     ) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);
        IERC20(_token).transfer(sender, _amount);
         bytes32 messageId = BasicERC20TokenSender(sender).send(
           
            receiver,   _token,   _amount,   destinationChainId
             
        );

        console.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console.logBytes32(messageId);

        vm.stopBroadcast();
    }
  

}
