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

  /// @notice Emitted when an account is granted the admin role
  ///
  /// @param account an account granted the admin role
  /// @param count the number of accounts having admin role after this grant
  event AdminRoleGranted(address indexed account, uint256 count);

  /// @notice Emitted when an account is revoked the admin role
  ///
  /// @param account an account revoked the admin role
  /// @param count the number of accounts having admin role after this revoke
  event AdminRoleRevoked(address indexed account, uint256 count);

  /// @notice Emitted when an account is granted the issuer role
  ///
  /// @param account an account granted the issuer role
  /// @param count the number of accounts having issuer role after this grant
  event IssuerRoleGranted(address indexed account, uint256 count);

  /// @notice Emitted when an account is revoked the issuer role
  ///
  /// @param account an account revoked the issuer role
  /// @param count the number of accounts having issuer role after this revoke
  event IssuerRoleRevoked(address indexed account, uint256 count);

  /// @notice Emitted when an account is granted the controller role
  ///
  /// @param account an account granted the controller role
  /// @param count the number of accounts having controller role after this grant
  event ControllerRoleGranted(address indexed account, uint256 count);

  /// @notice Emitted when an account is revoked the controller role
  ///
  /// @param account an account revoked the controller role
  /// @param count the number of accounts having controller role after this revoke
  event ControllerRoleRevoked(address indexed account, uint256 count);

  /// @notice Indicates the caller (`msg.sender`) do NOT have a role required
  ///         for the called function.
  /// @param role a role required
  /// @param account the caller (`msg.sender`)
  error ACUnauthorizedAccess(bytes role, address account);

  /// @notice Indicates an `account` can NOT be granted the specified `role`
  ///         for the called function.
  ///         <p>
  ///         Usually zero address (<code>0x00</code>) can NOT be granted a role
  ///         </p>
  /// @param role a role to grant
  /// @param account an account to grant the role
  error ACInvalidRoleMember(bytes role, address account);

  /// @notice Indicate a role has no member account, which is usually unexpected
  error ACMissingRoleMember(bytes role);

  /// @notice Indicate a role has only one member account, which implies
  ///         that revoking more account may make the role without any member.
  error ACOnlyOneRoleMember(bytes role);

  error ACInsufficientRoleMember(bytes role, uint8 min);

  /// @notice Grants an admin role to the specified account.
  ///      <p>
  ///      <li>It doesn't matter whether or not the account already has admin role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>AdminRoleGranted</code> event will be emitted, when successfully
  ///      completed.
  ///      </p>
  /// @param account to whom the admin role is granted
  /// @return count the number of admin accounts after this grant
  /// @custom:emit `AdminRoleGranted`
  /// @custom:role `ADMIN_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACInvalidRoleMember`
  function grantAdminRole(address account) external returns(uint256 count);

  /// @notice Revokes an admin role from the specified `account`.
  ///      <p>
  ///      <li>If the specified account is the only account who has an admin role,
  ///      this function will fail.
  ///      <li>It doesn't matter whether or NOT the account currently has admin role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>AdminRoleRevoked</code> event will be emitted, when successfully
  ///      completed.
  ///      </p>
  /// @param account from whom the admin role is revoked
  /// @return count the number of admin accounts after this revocation
  /// @custom:emit `AdminRoleRevoked`
  /// @custom:role `ADMIN_ROLE`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACOnlyOneRoleMember`
  function revokeAdminRole(address account) external returns(uint256 count);

  /// @notice Checks whether or not the specified `account` has **admin** role.
  ///
  /// @param account the account to check
  /// @return has whether or not the `account` hash admin role.
  function hasAdminRole(address account) external view returns(bool has);

  /// @notice Counts the number of accounts currently granted **admin** role.
  ///
  /// @return count the number of accounts granted admin role
  function countAdminRoleMembers() external view returns(uint256 count);

  /// @notice Gets all the accounts currently granted **admin** role.
  ///
  /// @return accounts an array of addresses granted admin role
  function getAllAdminRoleMembers()
    external view returns(address[] memory accounts);

  /// @notice Grants an issuer role to the specified account.
  ///      <p>
  ///      <li>It doesn't matter whether or not the account already has issuer role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>IssuerRoleGranted</code> event will be emitted, when successfully
  ///      completed.
  ///      </p>
  /// @param account to whom the issuer role is granted
  /// @custom:role `ADMIN_ROLE`
  /// @custom:emit `IssuerRoleGranted`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACInvalidRoleMember`
  function grantIssuerRole(address account) external returns(uint256 count);

  /// @notice Revokes an issuer role from the specified `account`.
  ///      <p>
  ///      <li>If the specified account is the only account who has an issuer role,
  ///      this function will fail.
  ///      <li>It doesn't matter whether or NOT the account currently has issuer role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>IssuerRoleRevoked</code> event will be emitted, when successfully
  ///      completed.
  ///      </p>
  /// @param account from whom the issuer role is revoked
  /// @custom:role `ADMIN_ROLE`
  /// @custom:emit `IssuerRoleRevoked`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACOnlyOneRoleMember`
  function revokeIssuerRole(address account) external returns(uint256 count);

  /// @notice Checks whether or not the specified `account` has **issuer** role.
  ///
  /// @param account the account to check
  /// @return has whether or not the `account` hash issuer role.
  function hasIssuerRole(address account) external view returns(bool);

  /// @notice Counts the number of accounts currently granted **issuer** role.
  ///
  /// @return count the number of accounts granted issuer role
  function countIssuerRoleMembers() external view returns(uint256 count);

  /// @notice Gets all the accounts currently granted **issuer** role.
  ///
  /// @return accounts an array of addresses granted issuer role
  function getAllIssuerRoleMembers()
    external view returns(address[] memory accounts);

  /// @notice Grants an controller role to the specified account.
  ///      <p>
  ///      <li>It doesn't matter whether or not the account already has controller role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>ControllerRoleGranted</code> event will be emitted, when successfully
  ///      completed.
  ///      </p><p>
  ///      <strong>controller</strong> : executor, enforcer(https://www.ldoceonline.com/dictionary/enforcer)
  ///      </p>
  /// @param account to whom the controller role is granted
  /// @custom:role `ADMIN_ROLE`
  /// @custom:emit `ControllerRoleGranted`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACInvalidRoleMember`
  function grantControllerRole(address account) external returns(uint256 count);

  /// @notice Revokes an controller role from the specified `account`.
  ///      <p>
  ///      <li>If the specified account is the only account who has an controller role,
  ///      this function will fail.
  ///      <li>It doesn't matter whether or NOT the account currently has controller role.
  ///      <li>This function requires caller (<code>msg.sender</code>) has admin role.
  ///      <li><code>ControllerRoleRevoked</code> event will be emitted, when successfully
  ///      completed.
  ///      </p>
  /// @param account from whom the controller role is revoked
  /// @custom:role `ADMIN_ROLE`
  /// @custom:emit `ControllerRoleRevoked`
  /// @custom:throw `ACUnauthorizedAccess`
  /// @custom:throw `ACOnlyOneRoleMember`
  function revokeControllerRole(address account) external returns(uint256 count);

  /// @notice Checks whether or not the specified `account` has **controller** role.
  ///
  /// @param account the account to check
  /// @return has whether or not the `account` hash controller role.
  function hasControllerRole(address account) external view returns(bool);

  /// @notice Counts the number of accounts currently granted **controller** role.
  ///
  /// @return count the number of accounts granted controller role
  function countControllerRoleMembers()
    external view returns(uint256 count);

  /// @notice Gets all the accounts currently granted **controller** role.
  ///
  /// @return accounts an array of addresses granted controller role
  function getAllControllerRoleMembers()
    external view returns(address[] memory accounts);

}