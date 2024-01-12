// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

/**
 *
 * @title Common Errors for Security Token Contract
 * @custom:see https://eips.ethereum.org/EIPS/eip-6093
 */
interface ISecurityTokenErrors{

  error STInvalidOperator(address operator, address holder);

  error STDisallowedAmount(uint256 amount);

  /// @notice Indicates that the security is currently NOT allowed
  ///         to issue tokens (for example, before the public offering)
  ///         but a transaction requiring the token issuance has arrived.
  error STUnissuableState();

  /// @notice Indicates that the security contract is currently paused
  ///         and a transaction prohibited when paused has arrived.
  error STPausedState();

  /// @notice Indicates an disallowed situation where total supply would
  ///         surpass the supply cap. Usually in issuances.
  error STOverflowingSupply();

  /// @notice Indicate a failure when the supply cap to set is less than
  ///         current total supply
  error STInsufficientSupplyCap(uint256 cap, uint256 supply);

  /// @notice Indicates a failure where the supply cap decrease is too large
  ///         to keep current total supply or larger than current cap
  error STExcessiveSupplyCapDecrease(uint256 cap, uint256 decrease, uint256 supply);

  /// @notice Indicate a failure when current locked balance of the <code>holder</code> is
  ///         NOT enough to unlock the <code>needed</code> tokens
  error STInsufficientLockedBalance(address holder, uint256 lockedBalance, uint256 needed);

  /// @notice Indicate that a specified <code>value</code> for the bundle max size
  ///         is out of the allowed range (between <code>upperLimit</code> and
  ///         <code>lowerLimit</code> inclusively)
  ///
  /// @param upperLimit the inclusive upper limit for the max bundle size
  /// @param lowerLimit the inclusive lower limit for the max bundle size
  error STInvalidBundleMaxSize(uint256 upperLimit, uint256 lowerLimit, uint256 value);

  /// @notice Indicate that bundle size(<code>size</code>) is larger than the
  ///         max bundle size
  ///
  /// @param max current max size for bundle
  /// @param size bundle size under processing
  error STTooLargeBundle(uint256 max, uint256 size);


  /// @notice Indicates a failure that an account is not virtual account
  ///         where virtual account is expected
  error STNotVirtualAccount(address account);

  /// @notice Indicates a failure that a sender is not virtual account
  ///         where virtual account is expected
  error STNotVirtualSender(address account);

  /// @notice Indicates a failure that a receiver(recipient) is not virtual
  ///         account where virtual account is expected
  error STNotVirtualReceiver(address account);

  /// @notice Indicate a failure that an account is virtual account
  ///         where virtual account is never expected
  error STUnexpectedVirtualAccount(address account);

  /// @notice Indicates a failure where the invoker(`msg.sender`) of the
  ///         function has not authorized
  /// @custom:deprecated
  //error STUnauthorizedInvoker(bytes32 role, address invoker);


  /// @notice Indicates that the function is not yet implemented even
  ///         though declared.
  error STNotYetImplemented();
}