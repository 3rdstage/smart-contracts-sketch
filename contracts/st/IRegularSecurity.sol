// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder consensys
pragma solidity ^0.8.0;

//import '@openzeppelin/contracts/access/IAccessControl.sol';
import {ISecurityAccessControl} from './ISecurityAccessControl.sol';


/// @title Interface for practical and regular security token contract
/// @author Sangmoon Oh
/// @notice
///      - Initially the contract is issuable and not paused.
///      - The operator **MUST** **NOT** be the owner of the approved tokens.
///      - The owner **CAN** **NOT** approve him or herself.
///      - Zero amount token movements (transfer, issuance, redemption) is **NOT** allowed.
///      - Zero supply cap means there's no upper-limit on total supply.
///      - Idempotence is preferred for state change.
///      - Both **`Issued`** and **`Transfer`** events are emitted for token issuance to comply ERC-20 and ERC-1400.
///      - Both **`Redeemed`** and **`Transfer`** events are emitted for token redemption to comply ERC-20 and ERC-1400.
/// @custom:since 2023-04-06
/// @custom:see 'https://github.com/ethereum/EIPs/issues/1411'
/// @custom:see 'https://eips.ethereum.org/EIPS/eip-20'
interface IRegularSecurity is ISecurityAccessControl{


  // ERC-20 Compliance : Complete

  event Transfer(address indexed sender, address indexed recipient, uint256 amount);

  event Approval(address indexed holder, address indexed spender, uint256 amount);

  function name() external view returns (string calldata);

  function symbol() external view returns (string calldata);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address holder) external view returns (uint256 balance);

  /**
   * @dev Setting `amount` to zero means the approval would be removed.
   *
   * @param spender the approved account who would be allowed to spend the
   *        holder(current message sender)'s tokens up to specified amount
   * @param amount allowed amount
   */
  function approve(address spender, uint256 amount) external returns (bool success);

  function allowance(address holder, address operator) external view returns (uint256 remaining);

  function transfer(address recipient, uint256 amount) external returns (bool success);

  /**
   * @dev Transfers the specified `amount` of tokens from the `sender`'s account
   *      to the `recipient`'s account as a holder or on behalf of holder.
   *      <p>
   *      This function is granted to the following addresses
   *      <ul>
   *      <li>current token holder (= `sender`)</li>
   *      <li>an operator of `sender`</li>
   *      <li>an approved address of `sender` up to the allowance</li>
   *      </ul>
   * @param sender an address who sends tokens
   * @param recipient and address who receives tokens
   * @param amount the number of tokens to send
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);

  // ERC-1410 Compliance : Partial
  // https://github.com/ethereum/EIPs/issues/1410)

  event AuthorizedOperator(address indexed operator, address indexed holder);

  event RevokedOperator(address indexed operator, address indexed holder);

  /**
   * @dev Allows the `msg.sender` to set an operator for his/her tokens
   *      <p>
   *      This function must emit the event `AuthorizedOperator` every time it
   *      is called.<br/>
   *      The `operator` shouldn't be zero address nor holder(current message
   *      sender)
   * @param operator operator - shouldn't be zero address nor holder(message sender)
   */
  function authorizeOperator(address operator) external;

  /**
   * @dev Allows the `msg.sender` to revoke an operator
   *      This function must emit the event `RevokedOperator` every time it is called.
   * @param operator operator - shouldn't be zero address not holder(message sender)
   */
  function revokeOperator(address operator) external;

  /**
   * @dev Returns whether a specified address is an operator for the given token holder.
   *      Note that holder can't be his or her operator, so calling this function
   *      for a holder as an operator would return `false`. But, the UniversalToken
   *      (implementation of ERC-1400 by ConsenSys) has different semantics for this
   *      function.
   * @param operator operator
   * @param holder token holder
   */
  function isOperator(address operator, address holder) external view returns (bool);


  // ERC-1594 Compliance : Partial
  // https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md)

  event Issued(address indexed operator, address indexed holder, uint256 amount, bytes data);

  event Redeemed(address indexed operator, address indexed holder, uint256 amount, bytes data);

  /**
   * @dev The function will return both a ESC (Ethereum Status Code) following
   *      the EIP-1066 standard, and an additional bytes32 parameter that can
   *      be used to define application specific reason codes with additional
   *      details (for example the transfer restriction rule responsible for
   *      making the transfer operation invalid).
   * @param recipient account who receives tokens
   * @param amount token amount to transfer
   * @custom:see https://eips.ethereum.org/EIPS/eip-1066#0x5-tokens-funds--finance
   */
  function canTransfer(address recipient, uint256 amount, bytes memory data) external view returns (bool, bytes1, bytes32);

  /**
   *
   * @param sender an account who sends tokens
   * @param recipient an account who receives tokens
   * @param amount token amount to transfer
   * @param data optional arbitrary data to be submitted alongside the transfer
   * @return `true` if the specified transfer is allowed, unless `false`
   * @return single byte status code following EIP-1066 (https://eips.ethereum.org/EIPS/eip-1066#0x5-tokens-funds--finance)
   * @return detail code for failure
   */
  function canTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) external view returns (bool, bytes1, bytes32);

  /**
   * @dev This function must emit a `Transfer` event with details of the transfer.
   * @param recipient an account who receives tokens
   * @param amount token amount to transfer
   * @param data arbitrary data to be submitted alongside the transfer, for the token contract to interpret or record
   * @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#transferwithdata
   */
  function transferWithData(address recipient, uint256 amount, bytes memory data) external;

  /**
   * @dev The spender (`msg.sender`) MUST have a sufficient `allowance` set and this `allowance` must be debited by the `amount`.
   * @param sender an account who sends tokens
   * @param recipient an account who receives tokens
   * @param amount token amount to transfer
   * @param data arbitrary data to be submitted alongside the transfer, for the token contract to interpret or record
   * @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#transferfromwithdata
   */
  function transferFromWithData(address sender, address recipient, uint256 amount, bytes memory data) external;

  /**
   * @dev Semantics of this function is a little bit different from EIP-1410 in that
   *      token contract once set not to be issuable can be set back to be issuable later.
   *
   * @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#isissuable
   */
  function isIssuable() external view returns (bool);

  /**
   * @dev Increases the holder's balance as much.
   *      <p>
   *      This function must increase total supply and emit the
   *      `Issued` event.
   *      <p>
   *      This function requires `msg.sender` has issuer role.
   *      The `holder` shouldn't be zero address and `amount` shouldn't be zero.
   * If this security is in unissuable state, this function will fail.
   * If the total supply after the issuance surpasses the supply cap,
   * this function will fail.
   *
   * @param holder account who receive issued tokens
   * @param amount token amount to issue
   * @param data arbitrary data to be submitted alongside the issue, for the token contract to interpret or record
   * @custom:emit `Issued`
   * @custom:emit `Transfer`
   * @custom:role `ISSUER_ROLE`
   * @custom:throw `STUnissuableState`
   * @custom:throw `STPausedState`
   * @custom:throw `ERC20InvalidReceiver`
   * @custom:throw `STDisallowedAmount`
   * @custom:throw `STOverflowingSupply`
   * @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#issue
   */
  function issue(address holder, uint256 amount, bytes memory data) external;

  /**
   * @dev Redeem tokens from the caller's balances.
   *      <p>
   *      The redeemed tokens must be subtracted from the total supply and the balance of the token holder.
   *      The `Redeemed` event must be emitted every time this function is called.
   *      Redemption will fail if this security contract is in paused state.
   *      Redemption of zero amount is disallowed.
   *
   * @param amount token amount to redeem
   * @param data arbitrary data to be submitted alongside the redemption, for the token contract to interpret or record
   * @custom:emit `Redeemed`
   * @custom:emit `Transfer`
   * @custom:throw `STPausedState`
   * @custom:throw `ERC20InsufficientBalance`
   * @custom:throw `STDisallowedAmount`
   * @custom:see https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1594.md#redeem
   */
  function redeem(uint256 amount, bytes memory data) external;

  /**
   * @dev Allows a token holder, approved spenders or operators of the holder
   *      to redeem holder's tokens.
   *      <p>
   *      If the message sender is an approved spender of `holder`, he or she
   *      must have a sufficient allowance and this allowance will be debited
   *      by the `amount`.<br/>
   *      The `Redeemed` event must be emitted every time this function is called.

   * @custom:emit `Redeemed`
   * @custom:emit `Transfer`
   * @custom:emit `Approval`
   * @custom:throw `STPausedState`
   * @custom:throw `STDisallowedAmount`
   * @custom:throw `ERC20InsufficientAllowance`
   * @custom:throw `ERC20InsufficientBalance`
   * @param holder account who holds tokens to be redeemed
   * @param amount token amount to redeem
   * @param data arbitrary data to be submitted alongside the redemption, for the token contract to interpret or record
   */
  function redeemFrom(address holder, uint256 amount, bytes memory data) external;


  // ERC-1644 Compliance
  // A standard to support controller operations (aka forced transfers) on tokens
  // https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1644.md

  event ControllerTransfer(address controller, address indexed sender, address indexed recipient, uint256 amount, bytes data, bytes controllerData);

  event ControllerRedemption(address controller, address indexed holder, uint256 amount, bytes data, bytes controllerData);

  function isControllable() external view returns (bool);

  /**
   * @dev Transfers tokens regardless of the holder's intent or approval.
   *      <p>
   *      After successful transfer, Both `Transfer` and
   *      `ControllerTransfer` events are emitted.
   *      <p>
   *      The message sender is expected to have controller role.
   *
   * @param sender an account who sends tokens
   * @param recipient an account who receives tokens
   * @param amount the number of tokens to transfer
   * @custom:emit `Transfer`
   * @custom:emit `ControllerTransfer`
   * @custom:role `CONTROLLER_ROLE`
   * @custom:throw `STUnauthorizedInvoker`
   * @custom:throw `STPausedState`
   * @custom:throw `ERC20InvalidSender`
   * @custom:throw `ERC20InvalidReceiver`
   * @custom:throw `ERC20InsufficientBalance`
   */
  function controllerTransfer(address sender, address recipient, uint256 amount, bytes calldata data, bytes calldata controllerData) external;

  /***
   * @dev Redeems tokens regardless of the holder's intent or approval.
   *      <p>
   *      After successful redemption, Both `Transfer` and
   *      `ControllerRedemption` events are emitted. But `Redeemed`
   *      event are not.
   *      <p>
   *      Ths message sender is expected to have controller role.
   *
   * @param holder an account who owns tokens to be redeemed
   * @param amount the number of tokens to be redeemed
   * @custom:emit `Transfer`
   * @custom:emit `ControllerRedemption`
   * @custom:role `CONTROLLER_ROLE`
   * @custom:throw `STUnauthorizedInvoker`
   * @custom:throw `STPausedState`
   * @custom:throw `STDisallowedAmount`
   * @custom:throw `ERC20InsufficientBalance`
   */
  function controllerRedeem(address holder, uint256 amount, bytes calldata data, bytes calldata controllerData) external;

  // Extra function

  // Issuable or Not

  /**
   * @dev Emitted when this contract is set to issuable
   * @param account who set this contract issuable
   */
  event Issuable(address account);

  /**
   * @dev Emitted when this contract is set to unissuable
   * @param account who set this contract unissuable
   */
  event Unissuable(address account);

  /**
   * @dev Makes this token contract able to issue more tokens or not
   *      <p>
   *      This function requires `msg.sender` has admin role.
   *      <p>
   *      Setting issuable on already issuable state or unissuable on already
   *      unissuable state causes no effect without any exception. In other
   *      words this function is reentrant and idempotent.
   *
   * @param issuable able or unable to issue more tokens
   * @custom:emit `Issuable`
   * @custom:emit `Unissuable`
   * @custom:role `ADMIN_ROLE`
   */
  function setIssuable(bool issuable) external;


  // 'Pause' related
  /**
   * @dev Emitted when this contract is set to be paused
   * @param account who set this contract to be paused
   */
  event Paused(address account);

  /**
   * @dev Emitted when this contract is set to be unpaused
   * @param account who set this contract to be unpaused
   */
  event Unpaused(address account);

  function isPaused() external view returns (bool);

  /**
   *
   * @param paused whether or not to pause this contract
   * @custom:rol `ADMIN_ROLE`
   * @custom:emit `Paused`
   * @custom:emit `Unpaused`
   */
  function setPaused(bool paused) external;


  // 'Supply Cap' related
  event SupplyCapChanged(uint256 prevCap, uint256 currentCap);

  /**
   * @dev Gets the supply cap(upper limit for supply including circulating and locked tokens)
   *      `0` means that there's no supply cap which means tokens can be supplied as needed.
   */
  function supplyCap() external view returns(uint256 cap);

  /**
   * @dev Sets the supply cap.
   *      The value(`cap`) should be equal to or more than current total supply.
   *      If the cap is frozen or this security is paused, this function would fail.
   *      <p>
   *      The supply cap can be changed even when the contract is paused.
   *
   * @param cap upper limit for tokens including both circulating and locked
   * @custom:emit `SupplyCapChanged`
   * @custom:role `ISSUER_ROLE`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `STInsufficientSupplyCap`
   */
  function setSupplyCap(uint256 cap) external;

  /**
   * @dev Increases the supply cap.
   *      If the cap is frozen or this security is paused, this function would fail.
   *
   * @param delta the amount to increase for supply cap : expected to be positive
   * @custom:emit `SupplyCapChanged`
   * @custom:role `ISSUER_ROLE`
   * @custom:throw `STInsufficientSupplyCap`
   */
  function increaseSupplyCap(uint256 delta) external returns(uint256 cap);

  /**
   * @dev Decreases the supply cap.
   *      The decreased value(current supply cap - `delta`) should be equal to or more than current total supply.
   *      If the cap is frozen or this security is paused, this function would fail.
   *
   * @param delta the amount to decrease for supply cap : expected to be positive
   * @custom:emit `SupplyCapChanged`
   * @custom:role `ISSUER_ROLE`
   * @custom:throw `STInsufficientSupplyCap`
   */
  function decreaseSupplyCap(uint256 delta) external returns(uint256 cap);

  /**
   * @dev Removes supply cap.
   *      If completed successfully, tokens can be issued as needed without limit.
   *      If the cap is frozen or this security is paused, this function would fail.
   * @custom:emit `SupplyCapChanged`
   * @custom:role `ISSUER_ROLE`
   */
  function removeSupplyCap() external;

  // 'Locking Tokens' related

  function circulatingSupply() external view returns(uint256 supply);

  function lockedSupply() external view returns(uint256 supply);

  // 'Virtual Account' related
  function balanceOfVirtual(address account) external view returns(int256 balance);

  /**
   * @dev Transfers tokens to an virtual account.
   *      <p>
   *      It is expected that a token holder calls this function.
   *
   * @param recipient an account who receives tokens
   * @param amount the number of tokens to transfer
   * @custom:emit `Transfer`
   * @custom:throw `STPausedState`
   * @custom:throw `ERC20InvalidReceiver`
   * @custom:throw `STNotVirtualReceiver`
   * @custom:throw `ERC20InsufficientBalance`
   */
  function transferToVirtual(address recipient, uint256 amount) external;

  /**
   * @dev Transfers tokens from an virtual account
   *      <p>
   *      It is expected that a virtual account calls this function.
   *
   * @param recipient an account who receives tokens
   * @param amount the number of tokens to transfer
   * @custom:emit `Transfer`
   * @custom:throw `STPausedState`
   * @custom:throw `ERC20InvalidReceiver`
   * @custom:throw `STNotVirtualSender`
   */
  function transferFromVirtual(address recipient, uint256 amount) external;

  // 'Bundled Processing' related




}