// SPDX-License-Identifier: UNLICENSED
// cspell:ignore
pragma solidity ^0.8.0;

import {ISecurityAccessControl} from './ISecurityAccessControl.sol';
import {AccessControl} from './access/AccessControl.sol'; //library
import {Context} from "@openzeppelin/contracts-4/utils/Context.sol";

/**
 * @title Typical access control implementation for security token contracts.
 * @author Sang-moon Oh
 * @notice Provides normal implementation for access control on security token contracts.
 *         <p>
 *         This implementation manages three roles - admin role(`ADMIN_ROLE`),
 *         issuer role(`ISSUER_ROLE`), and controller role(`CONTROLLER_ROLE`).
 *         <br/>
 *         Granting or revoking any role to an account requires admin role. So
 *         this contract needs at least one admin account at construction time.
 *         Once instantiated, the contract disallow the last member of each role
 *         to be revoked. In other words, a transaction to revoke the last
 *         member of each role will fail.
 *         <br/>
 *         Granting or revoking roles are idempotent. In other words, granting a
 *         role to an account who was already granted the role before will not
 *         cause any exception but emit an event same with a grant for an
 *         account that hasn't the role yet.  For revoking, idempotence is similar.
 *
 */
abstract contract SecurityAccessControlBase is Context, ISecurityAccessControl{
  using AccessControl for AccessControl.Role;

  // @TODO adding `allowsNoIssuer`, `allowsNoController`

  bytes public constant ADMIN_ROLE = 'ADMIN_ROLE';
  bytes public constant ISSUER_ROLE = 'ISSUER_ROLE';
  bytes public constant CONTROLLER_ROLE = 'CONTROLLER_ROLE';

  AccessControl.Role private _admins;
  AccessControl.Role private _issuers;
  AccessControl.Role private _controllers;

  /**
   * @dev Requires at least one address for admin role.
   *
   * @param admins accounts to whom admin role will be granted
   * @param issuers accounts to whom issuer role will be granted
   * @param controllers accounts to whom controller role will be granted
   */
  constructor(
    address[] memory admins, address[] memory issuers, address[] memory controllers){

    _admins.name = ADMIN_ROLE;
    _issuers.name = ISSUER_ROLE;
    _controllers.name = CONTROLLER_ROLE;

    uint256 n = admins.length;
    if(n == 0){ revert ACMissingRoleMember(ADMIN_ROLE); }
    for(uint256 i = 0; i < n; i++){ _grant(admins[i], _admins); }

    n = issuers.length;
    for(uint256 i = 0; i < n; i++){ _grant(issuers[i], _issuers); }

    n = controllers.length;
    for(uint256 i = 0; i < n; i++){ _grant(controllers[i], _controllers); }

  }
  /**
   * @dev Grant a `role` to an `account`
   *      <p>
   *      If the `account` already has the `role` before the function
   *      call, this function throws no exception and changes no states.
   *      </P.
   *      This function doesn't emit any event.
   *
   * @custom:throw `ACInvalidRoleMember`
   */
  function _grant(address account, AccessControl.Role storage role)
    internal returns (uint256 count){

    if(account == address(0)){
      revert ACInvalidRoleMember(role.name, account);
    }
    role.grant(account);
    count = role.count();
  }

  /**
   * @dev Revoke a `role` from an `account`
   *      <p>
   *      If the `account` doesn't have the `role` before the function
   *      call, this function throws no exception and changes no states.
   *      <p>
   *      This function doesn't emit any event.
   * @param account from whom the role is revoked
   * @param role the role to revoke
   */
  function _revoke(address account, AccessControl.Role storage role)
    internal returns (uint256 count){

    role.revoke(account);
    count = role.count();
  }

  function grantAdminRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _grant(account, _admins);
    emit AdminRoleGranted(account, count);
  }

  function revokeAdminRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _revoke(account, _admins);
    if(count == 0){
      revert ACOnlyOneRoleMember(ADMIN_ROLE);
    }else{
      emit AdminRoleRevoked(account, count);
    }
  }

  function hasAdminRole(address account)
    external override view returns(bool){
    return _hasAdminRole(account);
  }

  function _hasAdminRole(address account)
    internal virtual view returns(bool){
    return _admins.has(account);
  }

  function countAdminRoleMembers()
    external override view returns (uint256 count){

    return _admins.count();
  }


  function grantIssuerRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _grant(account, _issuers);
    emit IssuerRoleGranted(account, count);
  }

  function revokeIssuerRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _revoke(account, _admins);
    if(count == 0){
      revert ACOnlyOneRoleMember(ISSUER_ROLE);
    }else{
      emit IssuerRoleRevoked(account, count);
    }
  }

  function hasIssuerRole(address account)
    external override view returns(bool){
    return _hasIssuerRole(account);
  }

  function _hasIssuerRole(address account)
    internal virtual view returns(bool){
    return _issuers.has(account);
  }

  function countIssuerRoleMembers()
    external override view returns (uint256 count){

    return _issuers.count();
  }

  function grantControllerRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _grant(account, _controllers);
    emit ControllerRoleGranted(account, count);
  }

  function revokeControllerRole(address account)
    external override returns(uint256 count){

    if(!_admins.has(_msgSender())){
      revert ACUnauthorizedAccess(ADMIN_ROLE, _msgSender());
    }
    count = _revoke(account, _controllers);
    if(count == 0){
      revert ACOnlyOneRoleMember(CONTROLLER_ROLE);
    }else{
      emit ControllerRoleRevoked(account, count);
    }
  }

  function hasControllerRole(address account)
    external override view returns(bool){
    return _hasControllerRole(account);
  }

  function _hasControllerRole(address account)
    internal view returns(bool){
    return _controllers.has(account);
  }

  function countControllerRoleMembers() external override view returns (uint256 count){
    return _controllers.count();
  }

}

