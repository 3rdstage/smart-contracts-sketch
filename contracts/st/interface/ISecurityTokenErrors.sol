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

  error STDisallowedNumber(uint256 number);

  /// @notice Indicates that tow or more input arguments in array type
  ///     have different length(size), although they are expected
  ///     to have same length.
  ///
  /// @param lengths an array containing lengths of arguments under the concern
  error STUnevenSizedPairedArgs(uint256[] lengths);

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

  /// @notice Indicates an error related to the current **unlocked** balance of
  ///     a <code>holder</code>.
  ///     <p>
  ///     Usually used in transfers or locks.
  error STInsufficientUnlockedBalance(address holder, uint256 unlockedBalance, uint256 needed);

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

  /// @notice Indicates that the function is not yet implemented even
  ///         though declared.
  error STNotYetImplemented();
}