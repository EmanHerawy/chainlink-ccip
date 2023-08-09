

// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
// import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
// import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
 
// /**
//  * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
//  * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
//  * DO NOT USE THIS CODE IN PRODUCTION.
//  */
// contract BasicMessageSender   {
//     enum PayFeesIn {
//         Native,
//         LINK
//     }

//     address immutable i_router;
//     address immutable i_link;

//     event MessageSent(bytes32 messageId);

//     constructor(address router, address link) {
//         i_router = router;
//         i_link = link;
//         LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
//     }

//     receive() external payable {}

//     function send(
//         uint64 destinationChainSelector,
//         address receiver,
//         string memory messageText
//     ) external returns (bytes32 messageId) {
//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(receiver),
//             data: abi.encode(messageText),
//             tokenAmounts: new Client.EVMTokenAmount[](0),
//             extraArgs: "",
//             feeToken:  i_link  
//         });

//         uint256 fee = IRouterClient(i_router).getFee(
//             destinationChainSelector,
//             message
//         );

//        LinkTokenInterface(i_link).approve(i_router, fee);
//             messageId = IRouterClient(i_router).ccipSend(
//                 destinationChainSelector,
//                 message
//             );

//         emit MessageSent(messageId);
//     }
// }




pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";


contract BasicMessageSender{
 address link;
 address router;

  constructor(address _router, address _link) {
        router = _router;
        link = _link;
    }


    function sendMessageWithLinkFee(address _receiver,string memory _message, uint64 destinationChainSelector) public   returns (bytes32 messageId) {

        // compose the message

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver:abi.encode(_receiver),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            data: abi.encode(_message),
            extraArgs:"", // let's keep the default for now 
            feeToken: link
        });

        // let's now calulate the fee
        uint256 fee = IRouterClient(router).getFee(destinationChainSelector, message);
        // approve the router to spend the fee
        IERC20(link).approve(router, fee);
     
        // send the message
       messageId=       IRouterClient(router).ccipSend(destinationChainSelector, message);

    }
    function sendMessageWithEthFee(address _receiver,string memory _message, uint64 destinationChainSelector)  public  payable  returns (bytes32 messageId) {

        // compose the message

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver:abi.encode(_receiver),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            data: abi.encode(_message),
            extraArgs:"", // let's keep the default for now 
            feeToken: address(0)
        });

        // let's now calulate the fee
        uint256 fee = IRouterClient(router).getFee(destinationChainSelector, message);
        // approve the router to spend the fee
        
     
        // send the message
       messageId=       IRouterClient(router).ccipSend{value:fee}(destinationChainSelector, message);

    }



    function refund(address token) external {
        if(token==address(0)){
            // refund eth 
            uint256 amount = address(this).balance;
      (bool success,)=      payable (msg.sender).call{value:amount}("");
      if(!success){
          revert("refund failed");
      }
        }else{
         uint256 amount=   IERC20(token).balanceOf(address(this));
         IERC20(token).transfer(msg.sender,amount);
        }
    }


}


// deployed at 0xD14F82988755643D64d4222788464F2b262D73E2 , 
// first one 0x25995C0cDbdF593AB3f105Cb2C5f1b721179421f



//"0xb8112B68A956B2d05F5cC11D7B52103748DCc6Ee", "Hi There", 16015286601757825753