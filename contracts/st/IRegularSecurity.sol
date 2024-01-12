// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder consensys thead tbody nowrap
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/access/IAccessControl.sol';
import {ISecurityAccessControl} from './ISecurityAccessControl.sol';


/// @title Interface for practical and regular security token contract
/// @notice
///      - Initially the contract is issuable and not paused.
///      - The operator **MUST** **NOT** be the owner of the approved tokens.
///      - The owner **CAN** **NOT** approve him or herself.
///      - Zero amount token movements (transfer, issuance, redemption) is **NOT** allowed.
///      - Zero supply cap means there's no upper-limit on total supply.
///      - Idempotence is preferred for state change.
///      - Both **<code>Issued</code>** and **<code>Transfer</code>** events are emitted for token issuance to comply ERC-20 and ERC-1400.
///      - Both **<code>Redeemed</code>** and **<code>Transfer</code>** events are emitted for token redemption to comply ERC-20 and ERC-1400.
///
/// <h3States and Functions</h3>
/// <table>
/// <thead>
///   <tr>
///     <th>Function\State</th>
///     <th><strong>Unissuable</strong></th>
///     <th><strong>Paused</strong></th>
///   </tr>
/// </thead>
/// <tbody>
///   <tr>
///     <td><code>issue()</code></td>
///     <td style="text-align:center">X</td>
///     <td style="text-align:center">X</td>
///   </tr><tr>
///     <td><code>transfer()<code>, <code>transferFrom()</code></td>
///     <td style="text-align:center">O</td>
///     <td style="text-align:center">X</td>
///   </tr><tr>
///     <td><code>redeem()</code>, <code>redeemFrom()</code></td>
///     <td style="text-align:center">O</td>
///     <td style="text-align:center">X</td>
///   </tr><tr>
///     <td style='white-space:nowrap'><code>controllerTransfer()</code>, <code>controllerRedeem()</code></td>
///     <td style="text-align:center">O</td>
///     <td style="text-align:center">X</td>
///   </tr><tr>
///     <td><code>lock()</code>, <code>unlock()</code></td>
///     <td style="text-align:center">O</td>
///     <td style="text-align:center">X</td>
///   </tr>
/// </tbody>
/// </table>
///
/// <h3>Access Control and Events</h3>
/// <table>
/// <thead>
///   <tr>
///     <th>Function</th>
///     <th>Role(s)</th>
///     <th>Event(s)</th>
///   </tr>
/// </thead>
/// <tbody>
///   <tr>
///     <td><code>transfer()</code></td>
///     <td><i>holder</i></td>
///     <td><code>Transfer</code></td>
///   </tr><tr>
///     <td><code>issue()</code></td>
///     <td><code>ISSUER</code></td>
///     <td><code>Issued</code>, <code>Transfer</code></td>
///   </tr><tr>
///     <td><code>redeem()</code></td>
///     <td><i>holder</i></td>
///     <td><code>Redeemed</code>, <code>Transfer</code></td>
///   </tr><tr>
///     <td><code>controllerTransfer()</code></td>
///     <td><code>CONTROLLER</code></td>
///     <td><code>ControllerTransfer</code>, <code>Transfer</code></td>
///   </tr><tr>
///     <td><code>controllerRedeem()</code></td>
///     <td><code>CONTROLLER</code></td>
///     <td><code>ControllerRedemption</code>, <code>Transfer</code></td>
///   </tr><tr>
///     <td><code>   </code></td>
///     <td><code>   </code></td>
///     <td><code>   </td>
///   </tr><tr>
///     <td><code>grantAdminRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>AdminRoleGranted</code></td>
///   </tr><tr>
///     <td><code>revokeAdminRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>AdminRoleRevoked</code></td>
///   </tr><tr>
///     <td><code>grantIssuerRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>IssuerRoleGranted</code></td>
///   </tr><tr>
///     <td><code>revokeIssuerRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>IssuerRoleRevoked</code></td>
///   </tr><tr>
///     <td><code>grantControllerRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>ControllerRoleGranted</code></td>
///   </tr><tr>
///     <td><code>revokeControllerRole()</code></td>
///     <td><code>ADMIN</code></td>
///     <td><code>ControllerRoleRevoked</code></td>
///   </tr>
/// </tbody>
/// </table>
///
/// @custom:see 'https://github.com/ethereum/EIPs/issues/1411'
/// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
interface IRegularSecurity is ISecurityAccessControl{

  //////////////////////////////////////////////////
  //
  // ERC-20 Compliance : Complete
  //
  //////////////////////////////////////////////////

  /// @notice MUST trigger when tokens are transferred.
  event Transfer(address indexed sender, address indexed recipient, uint256 amount);

  /// @notice MUST trigger on any successful call to approve allowance to `spender` from `holder`
  event Approval(address indexed holder, address indexed spender, uint256 amount);

  /// @notice Returns the name of the security (token).
  ///
  /// @return _name name of this security (token)
  /// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
  function name() external view returns (string calldata _name);

  /// @notice Returns the symbol of the security (token).
  ///
  /// @return _symbol symbol of this security (token)
  /// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
  function symbol() external view returns (string calldata _symbol);

  /// @notice Returns the number of decimals the security (token) uses
  ///      <p>
  ///      : e.g. 8, means to divide the token amount by 100000000 to get its user representation.
  ///
  /// @return _decimals number of decimals this security (token) uses
  /// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
  function decimals() external view returns (uint8 _decimals);

  /// @notice Returns the total token supply.
  ///      <p>
  ///      Total supply is sum of current balances from all the holders.<br/>
  ///      It includes both circulating(i.e. normal and transferrable)
  ///      balance and locked (i.e. unable to transfer)
  ///      </p>
  ///
  /// @return _total the amount of total tokens
  /// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
  function totalSupply() external view returns (uint256 _total);

  /// @notice Returns the balance of account(amount of tokens owned by the account)
  ///      whose address is `holder`.
  ///
  /// @param holder address who may holds the balance on this security (token)
  /// @return balance the amount of tokens owned by the specified `holder`
  /// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
  function balanceOf(address holder) external view returns (uint256 balance);

  /// @notice Allows `spender` to withdraw from your account multiple times, up to
  ///      the `amount`. If this function is called again it overwrites the
  ///      current allowance with `amount`.
  ///
  /// @param spender the approved account who would be allowed to spend the
  ///        holder(current message sender)'s tokens up to specified amount
  /// @param amount allowed amount
  function approve(address spender, uint256 amount) external returns (bool success);

  /// @notice Returns the amount which `spender` is still allowed to withdraw from `holder`.
  /// @return remaining currently allowed amount to `operator` from `holder`
  function allowance(address holder, address operator)
      external view returns (uint256 remaining);

  /// @notice Transfers `amount` of tokens to address `recipient`, and MUST fire the
  ///      `Transfer` event.
  ///      <p>
  ///      This function SHOULD throw if the message caller’s account balance does
  ///      not have enough tokens to spend.
  ///
  /// @param recipient address of account who would receive tokens
  /// @param amount the number of tokens to transfer
  /// @return success whether or not this transfer has succeeded.
  /// @custom:emit `Transfer`
  function transfer(address recipient, uint256 amount)
      external returns (bool success);

  /// @notice Transfers the specified `amount` of tokens from the `sender`'s account
  ///      to the `recipient`'s account as a holder or on behalf of holder.
  ///      <p>
  ///      This function is granted to the following addresses
  ///
  ///      <li>current token holder (= <code>sender</code>)
  ///      <li>an operator of <code>sender</code>
  ///      <li>an approved address of <code>sender</code> up to the allowance
  ///
  /// @param sender address of account who sends tokens
  /// @param recipient address of account who receives tokens
  /// @param amount the number of tokens to transfer
  /// @return success whether or not this transfer has succeeded.
  /// @custom:emit `Transfer`
  function transferFrom(address sender, address recipient, uint256 amount)
      external returns (bool success);

  //////////////////////////////////////////////////
  //
  // ERC-1410 Compliance : Partial
  // https://github.com/ethereum/EIPs/issues/1410)
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when an operator is authorized for an holder
  event AuthorizedOperator(address indexed operator, address indexed holder);

  /// @notice Emitted when an operator is revoked for an holder
  event RevokedOperator(address indexed operator, address indexed holder);

  /// @notice Allows the `msg.sender` to set an operator for his/her tokens
  ///      <p>
  ///      This function must emit the event <code>AuthorizedOperator</code>
  ///      every time it is called.<br/>
  ///      The <code>operator</code> shouldn't be zero address nor holder(current
  ///      message sender)
  ///
  /// @param operator operator - shouldn't be zero address nor holder(message sender)
  /// @custom:emit `AuthorizedOperator`
  /// @custom:throw `STInvalidOperator`
  function authorizeOperator(address operator) external;

  /// @notice Allows the `msg.sender` to revoke an operator.
  ///      <p>
  ///      This function must emit the event <code>RevokedOperator</code> every
  ///      time it is called.
  ///
  /// @param operator operator - shouldn't be zero address not holder(message sender)
  /// @custom:emit `RevokedOperator`
  /// @custom:throw `STInvalidOperator`
  function revokeOperator(address operator) external;

  /// @notice Returns whether a specified address is an operator for the given token holder.
  ///      <p>
  ///      Note that holder can't be his or her operator, so calling this function
  ///      for a holder as an operator would return <code>false</code>. But,
  ///      the UniversalToken (implementation of ERC-1400 by ConsenSys) has
  ///      different semantics for this function.
  ///
  /// @param operator operator
  /// @param holder token holder
  function isOperator(address operator, address holder) external view returns (bool);

  //////////////////////////////////////////////////
  //
  // ERC-1594 Compliance : Partial
  // https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md)
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when tokens are issued to a holder, increasing total supply
  event Issued(address indexed operator, address indexed holder, uint256 amount, bytes data);

  /// @notice Emitted when tokens are redeemed from a holder, decreasing total supply
  event Redeemed(address indexed operator, address indexed holder, uint256 amount, bytes data);

  /// @notice The function will return both a ESC (Ethereum Status Code) following
  ///      the EIP-1066 standard, and an additional bytes32 parameter that can
  ///      be used to define application specific reason codes with additional
  ///      details (for example the transfer restriction rule responsible for
  ///      making the transfer operation invalid).
  ///
  /// @param recipient account who receives tokens
  /// @param amount token amount to transfer
  /// @custom:see https://eips.ethereum.org/EIPS/eip-1066#0x5-tokens-funds--finance
  function canTransfer(address recipient, uint256 amount, bytes memory data) external view returns (bool, bytes1, bytes32);

  /// @param sender an account who sends tokens
  /// @param recipient an account who receives tokens
  /// @param amount token amount to transfer
  /// @param data optional arbitrary data to be submitted alongside the transfer
  /// @return `true` if the specified transfer is allowed, unless `false`
  /// @return single byte status code following EIP-1066 (https://eips.ethereum.org/EIPS/eip-1066#0x5-tokens-funds--finance)
  /// @return detail code for failure
  function canTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) external view returns (bool, bytes1, bytes32);

  /// @notice This function must emit a `Transfer` event with details of the transfer.
  /// @param recipient an account who receives tokens
  /// @param amount token amount to transfer
  /// @param data arbitrary data to be submitted alongside the transfer, for the token contract to interpret or record
  /// @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#transferwithdata
  function transferWithData(address recipient, uint256 amount, bytes memory data) external;

  /// @notice The spender (`msg.sender`) MUST have a sufficient `allowance` set and this `allowance` must be debited by the `amount`.
  /// @param sender an account who sends tokens
  /// @param recipient an account who receives tokens
  /// @param amount token amount to transfer
  /// @param data arbitrary data to be submitted alongside the transfer, for the token contract to interpret or record
  /// @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#transferfromwithdata
  function transferFromWithData(address sender, address recipient, uint256 amount, bytes memory data) external;

  /// @notice Semantics of this function is a little bit different from EIP-1410 in that
  ///         token contract once set not to be issuable can be set back to be issuable later.
  /// @custom:see 'https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#isissuable'
  function isIssuable() external view returns (bool);

  /// @notice Increases the holder's balance as much.
  ///         <p>
  ///         This function must increase total supply and emit the
  ///         <code>Issued</code> event.
  ///         <p>
  ///         This function requires <code>msg.sender</code> has issuer role.
  ///         The <code>holder</code> shouldn't be zero address and <code>amount</code> shouldn't be zero.
  ///         If this security is in unissuable state, this function will fail.
  ///         If the total supply after the issuance surpasses the supply cap,
  ///         this function will fail.
  ///
  /// @param holder account who receive issued tokens
  /// @param amount token amount to issue
  /// @param data optional arbitrary data to be submitted alongside the issue, for the token contract to interpret or record
  /// @custom:emit `Issued`
  /// @custom:emit `Transfer`
  /// @custom:role `ISSUER_ROLE`
  /// @custom:throw `STUnissuableState`
  /// @custom:throw `STPausedState`
  /// @custom:throw `ERC20InvalidReceiver`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:throw `STOverflowingSupply`
  /// @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#issue
  function issue(address holder, uint256 amount, bytes memory data) external;

  /// @notice Redeem tokens from the caller's balances.
  ///      <p>
  ///      The redeemed tokens must be subtracted from the total supply and the balance of the token holder.
  ///      The <code>Redeemed</code> event must be emitted every time this function is called.
  ///      Redemption will fail if this security contract is in paused state.
  ///      Redemption of zero amount is disallowed.
  ///
  /// @param amount token amount to redeem
  /// @param data arbitrary data to be submitted alongside the redemption, for the token contract to interpret or record
  /// @custom:emit `Redeemed`
  /// @custom:emit `Transfer`
  /// @custom:throw `STPausedState`
  /// @custom:throw `ERC20InsufficientBalance`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#redeem
  function redeem(uint256 amount, bytes memory data) external;

  /// @notice Allows a token holder, approved spenders or operators of the holder
  ///      to redeem holder's tokens.
  ///      <p>
  ///      If the message sender is an approved spender of <code>holder</code>, he or she
  ///      must have a sufficient allowance and this allowance will be debited
  ///      by the <code>amount</code>.<br/>
  ///      The <code>Redeemed</code> event must be emitted every time this function is called.
  ///
  /// @custom:emit `Redeemed`
  /// @custom:emit `Transfer`
  /// @custom:emit `Approval`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:throw `ERC20InsufficientAllowance`
  /// @custom:throw `ERC20InsufficientBalance`
  /// @param holder account who holds tokens to be redeemed
  /// @param amount token amount to redeem
  /// @param data arbitrary data to be submitted alongside the redemption, for the token contract to interpret or record
  function redeemFrom(address holder, uint256 amount, bytes memory data) external;


  //////////////////////////////////////////////////
  //
  // ERC-1644 Compliance
  // A standard to support controller operations (aka forced transfers) on tokens
  // https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1644.md
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when tokens are transferred by force via `controllerTransfer()`
  ///
  /// @param controller the account who executes this forced transfer
  /// @param sender the owner whose tokens are transferred by force
  /// @param recipient the account who receives tokens
  /// @param amount the number of tokens to be transferred
  /// @custom:see `controllerTransfer()`
  event ControllerTransfer(address controller, address indexed sender, address indexed recipient, uint256 amount, bytes data, bytes controllerData);

  /// @notice Emitted when tokens are redeemed by force via `controllerRedeem()`
  ///
  /// @param controller the account who executes this forced redemption
  /// @param holder the owner whose tokens are redeemed by force
  /// @param amount the number of tokens to be redeemed
  /// @custom:see `controllerRedeem()`
  event ControllerRedemption(address controller, address indexed holder, uint256 amount, bytes data, bytes controllerData);


  /// @notice Check whether or not forced transfer and forced redemption is
  ///         possible for this security contract
  ///
  /// @return whether or not forced transfer and forced redemption is possible
  /// @custom:see [EIP-1644](https://github.com/ethereum/EIPs/issues/1644)
  function isControllable() external view returns (bool);

  /// @notice Transfers tokens regardless of the holder's intent or approval.
  ///      <p>
  ///      After successful transfer, Both <code>Transfer</code> and
  ///      <code>ControllerTransfer</code> events are emitted.
  ///      <p>
  ///      The message sender is expected to have controller role.
  ///
  /// @param sender an account who sends tokens
  /// @param recipient an account who receives tokens
  /// @param amount the number of tokens to transfer
  /// @custom:emit `Transfer`
  /// @custom:emit `ControllerTransfer`
  /// @custom:role `CONTROLLER_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STPausedState`
  /// @custom:throw `ERC20InvalidSender`
  /// @custom:throw `ERC20InvalidReceiver`
  /// @custom:throw `ERC20InsufficientBalance`
  function controllerTransfer(address sender, address recipient, uint256 amount, bytes calldata data, bytes calldata controllerData) external;

  /// @notice Redeems tokens regardless of the holder's intent or approval.
  ///      <p>
  ///      After successful redemption, Both <code>Transfer</code> and
  ///      <code>ControllerRedemption</code> events are emitted. But <code>Redeemed</code>
  ///      event are not.
  ///      <p>
  ///      Ths message sender is expected to have controller role.
  ///
  /// @param holder an account who owns tokens to be redeemed
  /// @param amount the number of tokens to be redeemed
  /// @custom:emit `Transfer`
  /// @custom:emit `ControllerRedemption`
  /// @custom:role `CONTROLLER_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:throw `ERC20InsufficientBalance`
  function controllerRedeem(address holder, uint256 amount, bytes calldata data, bytes calldata controllerData) external;

  // Extra function

  // Issuable or Not

  /// @notice Emitted when this contract is set to issuable
  ///
  /// @param account who set this contract issuable
  event Issuable(address account);

  /// @notice Emitted when this contract is set to unissuable
  ///
  /// @param account who set this contract unissuable
  event Unissuable(address account);

  /// @notice Makes this token contract able to issue more tokens or not
  ///      <p>
  ///      This function requires <code>msg.sender</code> has admin role.
  ///      <p>
  ///      Setting issuable on already issuable state or unissuable on already
  ///      unissuable state causes no effect without any exception. In other
  ///      words this function is reentrant and idempotent.
  ///
  /// @param issuable able or unable to issue more tokens
  /// @custom:emit `Issuable`
  /// @custom:emit `Unissuable`
  /// @custom:role `ADMIN_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  function setIssuable(bool issuable) external;

  //////////////////////////////////////////////////
  //
  // Feature : 'Security Pause' (a.k.a. Sidecar)
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when this contract is set to be paused
  ///
  /// @param account who set this contract to be paused
  event Paused(address account);

  /// @notice Emitted when this contract is set to be unpaused
  ///
  /// @param account who set this contract to be unpaused
  event Unpaused(address account);

  /// @notice Check whether or not this security is paused.
  ///         <p>
  ///         For paused securities, all transactions including issuance, transfers and redemptions
  ///         are prohibited.
  ///
  /// @return paused Whether or not this security is paused
  function isPaused() external view returns (bool paused);

  /// @param paused whether or not to pause this contract
  ///
  /// @custom:emit `Paused`
  /// @custom:emit `Unpaused`
  /// @custom:role `ADMIN_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  function setPaused(bool paused) external;


  //////////////////////////////////////////////////
  //
  // Feature : 'Supply Cap'
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when the supply cap for this security is updated.
  ///         <p>
  ///         This event is expected to be fired even when <code>prevCap</code>
  ///         and <code>currentCap</code> is equal, in other words the supply
  ///         cap actually remains same after update.
  ///         <p>
  ///         Zero(<code>0</code>) for supply cap means there's no supply cap,
  ///         in other words the total supply has no upper limit.
  ///
  /// @param prevCap the supply cap before update
  /// @param currentCap the supply cap after successful update
  /// @custom:see `setSupplyCap()`
  /// @custom:see `increaseSupplyCap()`
  /// @custom:see `decreaseSupplyCap()`
  /// @custom:see `removeSupplyCap()`
  event SupplyCapUpdated(uint256 prevCap, uint256 currentCap);

  /// @notice Gets the supply cap(upper limit for supply including circulating
  ///         and locked tokens)
  ///         <p>
  ///         <code>0</code> means that there's no supply cap which means tokens can be
  ///         supplied as needed.
  function supplyCap() external view returns(uint256 cap);

  /// @notice Sets the supply cap.
  ///      The value(`cap`) should be equal to or more than current total supply.
  ///      If the cap is frozen or this security is paused, this function would fail.
  ///      <p>
  ///      The supply cap can be changed even when the contract is paused.
  ///
  /// @param cap upper limit for tokens including both circulating and locked
  /// @custom:emit `SupplyCapUpdated`
  /// @custom:role `ISSUER_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STInsufficientSupplyCap`
  function setSupplyCap(uint256 cap) external;

  /// @notice Increases the supply cap.
  ///         <p>
  ///         If the cap is frozen or this security is paused, this function
  ///         would fail.
  ///
  /// @param delta the amount to increase for supply cap : expected to be positive
  /// @custom:emit `SupplyCapUpdated`
  /// @custom:role `ISSUER_ROLE`
  /// @custom:throw `STInsufficientSupplyCap`
  function increaseSupplyCap(uint256 delta) external returns(uint256 cap);

  /// @notice Decreases the supply cap.
  ///         <p>
  ///         The decreased value(current supply cap - <code>delta</code>) should be equal
  ///         to or more than current total supply. If the cap is frozen or this
  ///         security is paused, this function would fail.
  ///
  /// @param delta the amount to decrease for supply cap : expected to be positive
  /// @custom:emit `SupplyCapUpdated`
  /// @custom:role `ISSUER_ROLE`
  /// @custom:throw `STInsufficientSupplyCap`
  function decreaseSupplyCap(uint256 delta) external returns(uint256 cap);

  /// @notice Removes supply cap.
  ///         <p>
  ///         When completed successfully, tokens can be issued as needed without
  ///         limit.  If the cap is frozen or this security is paused, this
  ///         function would fail.
  ///
  /// @custom:role `ISSUER_ROLE`
  /// @custom:emit `SupplyCapUpdated`
  function removeSupplyCap() external;


  //////////////////////////////////////////////////
  //
  // Feature : 'Locked Tokens'
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when some of holder's tokens are locked more
  ///
  /// @param operator the account who signed the transaction for this lock
  /// @param holder the account whose tokens would be locked
  /// @param more the number of tokens locked this time
  /// @param lockedBalance the number of all tokens locked for the `holder`
  ///        after this lock
  event Locked(address operator, address holder, uint256 more, uint256 lockedBalance);


  /// @notice Emitted when some of holder's tokens are unlocked
  ///
  /// @param operator the account who signed the transaction for this unlock
  /// @param holder the account whose tokens would be unlocked
  /// @param less the number of tokens unlocked this time
  /// @param lockedBalance the number of all tokens locked for the `holder`
  ///        after this unlock
  event Unlocked(address operator, address holder, uint256 less, uint256 lockedBalance);

  /// @notice Lock some of holder's tokens.
  ///         <p>
  ///         Locked tokens are prohibited to transfer to others until unlocked later
  ///         , although they are still considered to be owned by the <code>holder</code>
  ///         <p>
  ///         Preconditions :
  ///         <li><code>hasControllerRole(msg.sender)</code>
  ///         <li><code>isPaused()</code> <tt>==</tt> <code>false</code>
  ///         <li><code>more</code> <tt>></tt> <code>0</code>
  ///         <li><code>balanceOf(holder)</code> <tt>&ge;</tt> <code>more</code>
  ///
  /// @param holder the account whose tokens would be locked
  /// @param more the number of tokens to lock
  /// @return lockedBalance the number of all tokens locked for the `holder`
  ///         after this lock
  /// @custom:emit `Locked`
  /// @custom:role `CONTROLLER_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STDisallowedAmount(0)`
  /// @custom:throw `ERC20InsufficientBalance`
  function lock(address holder, uint256 more) external returns(uint256 lockedBalance);

  /// @notice Unlock some of holder's tokens.
  ///         <p>
  ///         Locked tokens are prohibited to transfer to others until unlocked later
  ///         , although they are still considered to be owned by the <code>holder</code>
  ///         <p>
  ///         Preconditions :
  ///         <li><code>hasControllerRole(msg.sender)</code>
  ///         <li><code>isPaused()</code> <tt>==</tt> <code>false</code>
  ///         <li><code>less</code> <tt>></tt> <code>0</code>
  ///         <li><code>lockedBalanceOf(holder)</code> <tt>&ge;</tt> <code>less</code>
  ///
  /// @param holder the account whose tokens would be unlocked
  /// @param less the number of tokens to unlock
  /// @return lockedBalance the number of all tokens locked for the `holder`
  ///         after this unlock
  ///
  /// @custom:emit `Unlocked`
  /// @custom:role `CONTROLLER_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STDisallowedAmount(0)`
  /// @custom:throw `STInsufficientLockedBalance`
  function unlock(address holder, uint256 less) external returns(uint256 lockedBalance);

  /// @notice Returns the locked balance of specified <code>holder</code>
  ///         <p>
  ///         Locked balances are still considered to be owned by the holder but
  ///         can't be transferred or redeemed until unlocked explicitly
  ///
  /// @param holder the owner of tokens
  /// @return lockedBalance locked balance of specified <code>holder</code>
  /// @custom:see `lock(address, uint256)`
  /// @custom:see `unlock(address, uint256)`
  /// @custom:see `balanceOf(address)`
  function lockedBalanceOf(address holder) external view returns(uint256 lockedBalance);

  /// @notice Returns the sum of locked balances from all the holders
  ///         <p>
  ///         <li><code>total supply = circulating supply + locked supply</code>
  ///         <li><code>total supply</code> : sum of <code>balanceOf(holder)</code> for all the holders
  ///         <li><code>locked supply</code> : sum of <code>lockedBalanceOf(holder)</code> for all the holders
  ///
  /// @return supply sum of locked balances from all the holders for this security
  /// @custom:see `totalSupply()`
  /// @custom:see `circulatingSupply()`
  function lockedSupply() external view returns(uint256 supply);

  /// @notice Returns the sum of transferrable balances from all the holders
  ///         <p>
  ///         <li><code>total supply = circulating supply + locked supply</code>
  ///         <li><code>total supply</code> : sum of <code>balanceOf(holder)</code> for all the holders
  ///         <li><code>locked supply</code> : sum of <code>lockedBalanceOf(holder)</code> for all the holders
  ///
  /// @return supply sum of transferrable balances from all the holders for this security
  /// @custom:see `totalSupply()`
  /// @custom:see `lockedSupply()`
  function circulatingSupply() external view returns(uint256 supply);

  //////////////////////////////////////////////////
  //
  // Feature : 'Bundled Processing'
  //
  //////////////////////////////////////////////////

  /// @notice Emitted when the max size of bundle is updated.
  ///         <p>
  ///         Note that this event will be fired even when the max size is
  ///         actually unchanged after the update.
  event BundleMaxSizeUpdated(uint256 max);

  /// @notice Returns the maximum size of bundle for bundled processing
  ///         <p>
  ///         Max bundle size can be set through <code>setBundleMaxSize()</code> function
  ///
  /// @return max the maximum size of bundle
  /// @custom:see `setBundleMaxSize()`
  function bundleMaxSize() external view returns(uint256 max);

  /// @notice Updates the maximum size of bundle for bundled processing
  ///         <p>
  ///         Considering the block size or block gas limit, bundle size
  ///         for the Ethereum transaction need to be ranged more tightly.
  ///         So, the implementations of this interface are expected to
  ///         define the upper limit and the lower limit for the max size
  ///         to prevent too large value or too small value (e.g. <code>2</code>)
  ///         is set.
  ///
  /// @param max the max size of bundle - expected to be in the range of lower limit
  ///            to upper limit usually defined at implementation
  /// @custom:role `ADMIN_ROLE`
  /// @custom:emit `BundleMaxSizeUpdated`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STInvalidBundleMaxSize`
  function setBundleMaxSize(uint256 max) external;

  /// @notice Increases the specified <code>holders</code>' balances as much as
  ///         specified <code>amounts</code>
  ///         <p>
  ///         The list of accounts for those who would receive tokens and the list
  ///         of amounts to issue for those accounts are expected to have same
  ///         length and to be matched at each index. In other words, an account
  ///         in the account list(<code>holders</code>) and an amount in the
  ///         amount list(<code>amounts</code>) with same index should be paired.
  ///         <p>
  ///         Simply, this function processes multiple issuances in a single
  ///         transaction.
  ///         The processing is atomic, so if one issuance among them is NOT
  ///         valid (for example if the holder address is zero address or the
  ///         amount is zero), all the issuances in this function will be failed.
  ///         <p>
  ///         When successfully processed, this function will emit multiple pairs
  ///         of <code>Issued</code> and <code>Transfer</code> events as much as
  ///         the number of included issuances
  ///
  /// @param holders accounts for those who receive issued tokens
  /// @param amounts token amounts to issue
  /// @custom:role `ISSUER_ROLE`
  /// @custom:emit `Issued`
  /// @custom:emit `Transfer`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STUnissuableState`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STTooLargeBundle`
  /// @custom:throw `ERC20InvalidReceiver`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:throw `STOverflowingSupply`
  /// @custom:see `issue(address, uint256, bytes)`
  /// @custom:see `bundleMaxSize()`
  function bundleIssue(address[] memory holders,
      uint256[] memory amounts) external;

  /// @notice Processes multiple transfers in a single transaction.
  ///         <p>
  ///         Simply, this function processes multiple transfers in a single transaction.
  ///         The processing is atomic, so if one transfer among them is NOT valid
  ///         (for example if the recipient address is zero address or the amount is beyond
  ///         the owner's balance), all the transfers in this function will be failed.
  ///         <p>
  ///         The list of accounts for those who would receive tokens and the list
  ///         of amounts to transfer to those accounts are expected to have same
  ///         length and to be matched at each index. In other words, an address
  ///         in the recipient list(<code>recipients</code>) and an amount in the
  ///         amount list(<code>amounts</code>) with same index should be paired.
  ///         <p>
  ///         When successfully processed, this function will emit multiple
  ///         <code>Transfer</code> events as much as the number of included transfers.
  ///
  /// @param recipients accounts for those who receive issued tokens
  /// @param amounts token amounts to issue
  /// @custom:emit `Transfer`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STTooLargeBundle`
  /// @custom:throw `ERC20InvalidReceiver`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:see `transfer(address, uint256)`
  /// @custom:see `bundleMaxSize()`
  /// @custom:see `bundleTransfer(address[], address[], uint256[])`
  function bundleTransfer(address[] memory recipients,
      uint256[] memory amounts) external;


  /// @notice Processes multiple transfers in a single transaction.
  ///         <p>
  ///         The processing is atomic, so if one transfer among them is NOT valid
  ///         (for example if the recipient address is zero address or the amount is beyond
  ///         the owner's balance), all the transfers in this function will be failed.
  ///         <p>
  ///         The list of accounts(<code>senders</code>) for those who would
  ///         send tokens, the list of accounts(<code>recipients</code>) for
  ///         those who would receive tokens, and the list of amounts(<code>amounts</code>)
  ///         to transfer to those accounts are expected to have same length
  ///         and to be matched at each index. In other words, an address
  ///         in the sender list(<code>senders</code>), an address in the
  ///         recipient list(<code>recipients</code>), and an amount in the
  ///         amount list(<code>amounts</code>) with same index should be paired.
  ///         <p>
  ///         When successfully processed, this function will emit multiple
  ///         <code>Transfer</code> events as much as the number of included transfers.
  ///
  /// @param recipients accounts for those who receive issued tokens
  /// @param amounts token amounts to issue
  /// @custom:role `CONTROLLER_ROLE`
  /// @custom:emit `Transfer`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `STPausedState`
  /// @custom:throw `STTooLargeBundle`
  /// @custom:throw `ERC20InvalidSender`
  /// @custom:throw `ERC20InvalidReceiver`
  /// @custom:throw `STDisallowedAmount`
  /// @custom:see `transfer(address, uint256)`
  /// @custom:see `bundleMaxSize()`
  /// @custom:see `bundleTransfer(address[], uint256[])`
  function bundleTransfer(address[] memory senders,
      address[] memory recipients, uint256[] memory amounts) external;


}