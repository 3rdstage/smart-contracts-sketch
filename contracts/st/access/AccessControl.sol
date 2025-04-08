// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

import {EnumerableSet} from "@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";

library AccessControl{
  using EnumerableSet for EnumerableSet.AddressSet;

  struct Role{
    bytes name;
    mapping(address => bool) _has;
    EnumerableSet.AddressSet _members;
  }

  function grant(Role storage role, address account) internal{
    role._has[account] = true;
    role._members.add(account);
  }

  function revoke(Role storage role, address account) internal{
    role._has[account] = false;
    role._members.remove(account);
  }

  function has(Role storage role, address account) internal view returns(bool){
    return role._has[account];
  }

  function count(Role storage role) internal view returns(uint256){
    return role._members.length();
  }

  function at(Role storage role, uint256 i) internal view returns(address){
    return role._members.at(i);
  }

}