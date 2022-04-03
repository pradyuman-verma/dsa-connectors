//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import { TokenInterface } from "../../common/interfaces.sol";
import { DSMath } from "../../common/math.sol";
import { Basic } from "../../common/basic.sol";
import "./interface.sol";

contract Helpers is DSMath, Basic {
	/**
	 * @param token The address of token to be bridged.(For USDC: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)
	 * @param chainId The Id of the destination chain.(For MAINNET : 1)
	 * @param recipient The address to recieve the token on destination chain.
	 * @param amount The total amount sent by user (Includes bonder fee, destination chain Tx cost).
	 * @param bonderFee The fee to be recieved by bonder at destination chain.
	 * @param amountOutMin minimum amount of token out for swap
	 * @param deadline The deadline for the transaction (Recommended - Date.now() + 604800 (1 week))
	 * @param destinationAmountOutMin minimum amount of token out for bridge, zero for L1 bridging
	 * @param destinationDeadline The deadline for the transaction (Recommended - Date.now() + 604800 (1 week)), zero for L1 bridging
	 */
	struct BridgeParams {
		address token;
		uint256 chainId;
		address recipient;
		uint256 amount;
		uint256 bonderFee;
		uint256 amountOutMin;
		uint256 deadline;
		uint256 destinationAmountOutMin;
		uint256 destinationDeadline;
	}

	function _swapAndSend(BridgeParams memory params) internal {
		IHopRouter router = _getRouter(params.token);

		TokenInterface tokenContract = TokenInterface(params.token);
		approve(tokenContract, address(router), params.amount);

		router.swapAndSend(
			params.chainId,
			params.recipient,
			params.amount,
			params.bonderFee,
			params.amountOutMin,
			params.deadline,
			params.destinationAmountOutMin,
			params.destinationDeadline
		);
	}

	function _getRouter(address token_)
		internal
		pure
		returns (IHopRouter router)
	{
		if (token_ == 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)
			//USDC l2AmmWrapper
			router = IHopRouter(0x76b22b8C1079A44F1211D867D68b1eda76a635A7);
		else if (token_ == 0xc2132D05D31c914a87C6611C10748AEb04B58e8F)
			//USDT l2AmmWrapper
			router = IHopRouter(0x8741Ba6225A6BF91f9D73531A98A89807857a2B3);
		else if (token_ == 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270)
			//WMATIC l2AmmWrapper
			router = IHopRouter(0x884d1Aa15F9957E1aEAA86a82a72e49Bc2bfCbe3);
		else if (token_ == 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063)
			//DAI l2AmmWrapper
			router = IHopRouter(0x28529fec439cfF6d7D1D5917e956dEE62Cd3BE5c);
		else if (token_ == 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619)
			//WETH l2AmmWrapper
			router = IHopRouter(0xc315239cFb05F1E130E7E28E603CEa4C014c57f0);
		else if (token_ == 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6)
			//WBTC l2AmmWrapper
			router = IHopRouter(0xCd1d7AEfA8055e020db0d0e98bbF3FeD1A16aad6);
		else revert("Invalid token migration");
	}
}
