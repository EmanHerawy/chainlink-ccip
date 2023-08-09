// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
// import ERC20 and ChainLinkCCIP Client and router 

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";


contract BasicERC20TokenSender {


    IRouterClient router;
    LinkTokenInterface linkToken;

    constructor(address _router,address _linktoken){


        router=IRouterClient(_router);
        linkToken = LinkTokenInterface(_linktoken);
        // approve router to spend any amount of link as fee
        linkToken.approve(_router, type(uint256).max);
    }


    function send( address _receiver, address _token, uint256 _amount, uint64 destinationChainSelector) external returns (bytes32 messageId) {
        Client.EVMTokenAmount [] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0]=   Client.EVMTokenAmount({
            token:_token,
            amount:_amount
        });
                Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
        receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 0, strict: false})
            ),
            feeToken: address(linkToken)
        });
// approve the token 
    IERC20(_token).approve(address(router), _amount);
     messageId=   router.ccipSend(destinationChainSelector, message);

    }

}