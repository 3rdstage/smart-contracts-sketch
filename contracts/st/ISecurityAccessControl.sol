// SPDX-License-Identifier: UNLICENSED
// cspell:ignore
pragma solidity ^0.8.0;

/**
 * @title Interface to control access to security token contract
 * @author Sangmoon Oh
 * @notice
 * @custom:since 2023-05-25
 * @custom:see https://github.com/ethereum/EIPs/issues/1411
 * @custom:see https://eips.ethereum.org/EIPS/eip-20
 */
interface ISecurityAccessControl {

  event AdminRoleGranted(address indexed account, uint256 count);

  event AdminRoleRevoked(address indexed account, uint256 count);

  event IssuerRoleGranted(address indexed account, uint256 count);

  event IssuerRoleRevoked(address indexed account, uint256 count);

  event ControllerRoleGranted(address indexed account, uint256 count);

  event ControllerRoleRevoked(address indexed account, uint256 count);

  error ACUnauthorizedAccess(bytes role, address account);

  error ACInvalidRoleMember(bytes role, address account);

  error ACMissingRoleMember(bytes role);

  error ACOnlyOneRoleMember(bytes role);

  error ACInsufficientRoleMember(bytes role, uint8 min);

  /**
   * @dev Grants an admin role to the specified account.
   *      <p>
   *      It doesn't matter whether or not the account already has admin role.
   *      This function require caller (`msg.sender`) has admin role.
   *      `AdminRoleGranted` event will be emitted, when successfully completed.
   * @param account to whom the admin role is granted
   * @return count the number of admin accounts after this grant
   * @custom:emit `AdminRoleGranted`
   * @custom:role `ADMIN_ROLE`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACInvalidRoleMember`
   */
  function grantAdminRole(address account) external returns(uint256 count);

  /**
   * @dev Revokes an admin role from the specified `account`.
   *      <p>
   *      If the specified account is the only account who has an admin role,
   *      this function will fail.
   *      It doesn't matter whether or not the account currently has admin role.
   *      This function require caller (`msg.sender`) has admin role.
   *      `AdminRoleRevoked` event will be emitted, when successfully completed.
   * @param account from whom the admin role is revoked
   * @return count the number of admin accounts after this revocation
   * @custom:emit `AdminRoleRevoked`
   * @custom:role `ADMIN_ROLE`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACOnlyOneRoleMember`
   */
  function revokeAdminRole(address account) external returns(uint256 count);

  function hasAdminRole(address account) external view returns(bool);

  function countAdminRoleMembers() external view returns(uint256 count);

  /**
   *
   * @param account to whom the issuer role is granted
   * @custom:role `ADMIN_ROLE`
   * @custom:emit `IssuerRoleGranted`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACInvalidRoleMember`
   */
  function grantIssuerRole(address account) external returns(uint256 count);

  /**
   *
   * @param account from whom the issuer role is revoked
   * @custom:role `ADMIN_ROLE`
   * @custom:emit `IssuerRoleRevoked`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACOnlyOneRoleMember`
   */
  function revokeIssuerRole(address account) external returns(uint256 count);

  function hasIssuerRole(address account) external view returns(bool);

  function countIssuerRoleMembers() external view returns(uint256 count);

  /**
   * @dev Grant a controller role to the specified `account`
   *      <p>
   *      controller : executor, enforcer(https://www.ldoceonline.com/dictionary/enforcer)
   *
   * @param account to whom the controller role is granted
   * @custom:role `ADMIN_ROLE`
   * @custom:emit `ControllerRoleGranted`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACInvalidRoleMember`
   */
  function grantControllerRole(address account) external returns(uint256 count);

  /**
   *
   * @param account from whom the controller role is revoked
   * @custom:role `ADMIN_ROLE`
   * @custom:emit `ControllerRoleRevoked`
   * @custom:throw `ACUnauthorizedAccess`
   * @custom:throw `ACOnlyOneRoleMember`
   */
  function revokeControllerRole(address account) external returns(uint256 count);

  function hasControllerRole(address account) external view returns(bool);

  function countControllerRoleMembers() external view returns(uint256 count);

}