// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

/**
 *
 * @title Common Errors for Security Token Contract
 * @author Sangmoon Oh
 * @custom:see https://eips.ethereum.org/EIPS/eip-6093
 */
interface ISecurityTokenErrors{


  error STInvalidOperator(address operator);

  error STDisallowedAmount(uint256 amount);

  error STUnissuableState();

  error STPausedState();

  /**
   * @dev Indicates an disallowed situation where total supply would
   *      surpass the supply cap. Usually in issuances.
   */
  error STOverflowingSupply();

  /**
   * @dev Indicate a failure when the supply cap to set is less than
   *      current total supply
   */
  error STInsufficientSupplyCap(uint256 cap, uint256 supply);

  /**
   * @dev Indicates a failure where the supply cap decrease is too large
   *      to keep current total supply or larger than current cap
   */
  error STExcessiveSupplyCapDecrease(uint256 cap, uint256 decrease, uint256 supply);

  /**
   * @dev Indicates a failure that an account is not virtual account
   *      where virtual account is expected
   */
  error STNotVirtualAccount(address account);

  /**
   * @dev Indicates a failure that a sender is not virtual account
   *      where virtual account is expected
   */
  error STNotVirtualSender(address account);

  /**
   * @dev Indicates a failure that a receiver(recipient) is not virtual
   *      account where virtual account is expected
   */
  error STNotVirtualReceiver(address account);

  /**
   * @dev Indicate a failure that an account is virtual account
   *      where virtual account is never expected
   */
  error STUnexpectedVirtualAccount(address account);

  /**
   * @dev Indicates a failure where the invoker(`msg.sender`) of the
   *      function has not authorized
   */
  //error STUnauthorizedInvoker(bytes32 role, address invoker);


  /**
   * @dev Indicates that the function is not yet implemented even
   *      though declared.
   */
  error STNotYetImplemented();
}