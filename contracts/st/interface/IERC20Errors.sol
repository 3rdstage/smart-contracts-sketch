// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

/**
 *
 * @custom:see https://eips.ethereum.org/EIPS/eip-6093
 * @custom:see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/draft-IERC6093.sol
 */
interface IERC20Errors{

  /**
   * @dev Indicates an error related to the current balance of a sender. Used in transfers.
   */
  error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

  /**
   * @dev Indicates a failure with the token sender. Used in transfers.
   * <p>
   * Recommended for disallowed transfers from the zero address.<br/>
   */
  error ERC20InvalidSender(address sender);

  /**
   * @dev Indicates a failure with the token receiver. Used in transfers.
   * <p>
   * Recommended for disallowed transfers to the zero address.<br/>
   * Recommended for disallowed transfers to non-compatible addresses (eg. contract addresses).
   */
  error ERC20InvalidReceiver(address receiver);

  /**
   * @dev Indicates a failure with the spender’s allowance. Used in transfers.
   */
  error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

  /**
   * @dev Indicates a failure with the approver of a token to be approved. Used in approvals.
   * <p>
   * Recommended for disallowed approvals from the zero address.
   */
  error ERC20InvalidApprover(address approver);

  /**
   * @dev Indicates a failure with the spender to be approved. Used in approvals.
   * <p>
   * Recommended for disallowed approvals to the zero address.
   * Recommended for disallowed approvals to the owner itself.
   */
  error ERC20InvalidSpender(address spender);
}