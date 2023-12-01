// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

import {IERC20Errors} from "./interface/IERC20Errors.sol";
import {ISecurityTokenErrors} from "./interface/ISecurityTokenErrors.sol";
import {IRegularSecurity} from "./IRegularSecurity.sol";
import {SecurityAccessControlBase} from "./SecurityAccessControlBase.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RegularSecurity is Context, IERC20Errors, ISecurityTokenErrors, IRegularSecurity, SecurityAccessControlBase{
  using EnumerableSet for EnumerableSet.AddressSet;

  string private _name;
  string private _symbol;
  uint8 private immutable _decimals;
  uint256 private _supply; // total supply = circulating + locked = SUM(issued) - SUM(redeemed)
  uint256 private _cap; // max supply or supply cap : total supply <= cap

  mapping(address => uint256) private _balances;

  EnumerableSet.AddressSet private _vholders; // virtual holders for indirect transfers
  mapping(address => int256) private _vbalances; // balances for virtual holders

  mapping(address => mapping(address => bool)) internal _operators;  // holder/operator/boolean

  mapping(address => mapping(address => uint256)) internal _allowances; // holder/spender/amount

  bool private _issuable = true;

  bool private _paused = false;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    uint256 cap,
    address[] memory admins,
    address[] memory issuers,
    address[] memory controllers
  ) SecurityAccessControlBase(admins, issuers, controllers){

    if(issuers.length == 0){ revert ACMissingRoleMember(ISSUER_ROLE); }
    if(controllers.length == 0){ revert ACMissingRoleMember(CONTROLLER_ROLE); }

    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _cap = cap;

  }

  function name() external view override returns(string memory){
    return _name;
  }

  function symbol() external view override returns(string memory){
    return _symbol;
  }

  function decimals() external view override returns(uint8){
    return _decimals;
  }

  function totalSupply() external view override returns(uint256){
    return _supply;
  }

  function isPaused() external view override returns (bool){
    return _isPaused();
  }

  function _isPaused() internal view virtual returns (bool){
    return _paused;
  }

  function setPaused(bool paused) external{

    address invoker = _msgSender();
    if(!_hasAdminRole(invoker)){
      revert ACUnauthorizedAccess(ADMIN_ROLE, invoker);
    }

    _paused = paused;
    if(paused){ emit Paused(invoker); }
    else { emit Unpaused(invoker); }
  }

  function balanceOf(address account)
      external view override returns(uint256 balance){
    require(!_vholders.contains(account), "Virtual holder");

    balance = _balances[account];
  }

  function approve(address spender, uint256 amount)
    external override returns (bool success){

    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address holder, address spender, uint256 amount) internal virtual{
    if(holder == address(0)){ revert ERC20InvalidApprover(address(0)); }
    if(spender == address(0)){ revert ERC20InvalidSpender(address(0)); }
    _allowances[holder][spender] = amount;

    emit Approval(holder, spender, amount);
  }

  function allowance(address holder, address spender)
    external override view returns (uint256 remaining){
    return _allowances[holder][spender];
  }

  function transfer(address recipient, uint256 amount)
      external override returns(bool success){

    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)
    external override returns (bool success){

    _transferFrom(sender, recipient, _msgSender(), amount);
    return true;
  }

  function _transferFrom(
    address sender, address recipient, address spender, uint256 amount)
    internal virtual{

    if(spender == sender || _operators[sender][spender]){
      _transfer(sender, recipient, amount);
    }else{ // approved spender maybe
      if(_allowances[sender][spender] >= amount){
        _approve(sender, spender, _allowances[sender][spender] - amount);
        _transfer(sender, recipient, amount);
      }else{
        revert ERC20InsufficientAllowance(spender, _allowances[sender][spender], amount);
      }
    }
  }

  function _transfer(
    address sender, address recipient, uint256 amount) internal virtual{

    if(_isPaused()){ revert STPausedState(); }
    if(sender == address(0)){ revert ERC20InvalidSender(address(0)); }  // @NOTE Is this redundant?
    if(recipient == address(0)){ revert ERC20InvalidReceiver(address(0)); }

    if(_balances[sender] < amount){
      revert ERC20InsufficientBalance(sender, _balances[sender], amount);
    }

    _beforeTransfer(sender, recipient, amount, false, false);
    unchecked{
      _balances[sender] -= amount;
      _balances[recipient] += amount;
    }
    _afterTransfer(sender, recipient, amount, false, false);

    emit Transfer(sender, recipient, amount);
  }

  function _beforeTransfer(
    address sender, address recipient, uint256 amount,
    bool fromVirtual, bool toVirtual) internal virtual{ // solhint-disable-line no-empty-blocks
  }

  function _afterTransfer(
    address sender, address recipient, uint256 amount,
    bool fromVirtual, bool toVirtual) internal virtual{ } // solhint-disable-line no-empty-blocks


  function balanceOfVirtual(address account)
      external view override returns(int256 balance){
    if(!_vholders.contains(account)){ revert STNotVirtualAccount(account); }

    balance = _vbalances[account];
  }

  function transferFromVirtual(address recipient, uint256 amount)
      external override{

    if(_isPaused()){ revert STPausedState(); }
    if(recipient == address(0)){ revert ERC20InvalidReceiver(address(0)); }
    address sender = _msgSender();
    if(!_vholders.contains(sender)){ revert STNotVirtualSender(sender); }

    _beforeTransfer(sender, recipient, amount, true, false);
    unchecked{
      _vbalances[sender] -= int256(amount);
      _balances[recipient] += amount;
    }
    _afterTransfer(sender, recipient, amount, true, false);

    emit Transfer(sender, recipient, amount);
  }

  function transferToVirtual(address recipient, uint256 amount)
      external override{

    if(_isPaused()){ revert STPausedState(); }
    if(recipient == address(0)){ revert ERC20InvalidReceiver(address(0)); }
    if(!_vholders.contains(recipient)){ revert STNotVirtualReceiver(recipient); }

    address sender = _msgSender();
    if(_balances[sender] < amount){
      revert ERC20InsufficientBalance(sender, _balances[sender], amount);
    }

    _beforeTransfer(sender, recipient, amount, false, true);
    unchecked{
      _balances[sender] -= amount;
      _vbalances[recipient] += int256(amount);
    }
    _afterTransfer(sender, recipient, amount, false, true);

    emit Transfer(sender, recipient, amount);
  }

  function authorizeOperator(address operator) external override{

    if(operator == address(0)){ revert STInvalidOperator(address(0)); }
    address holder = _msgSender();
    if(holder == operator){ revert STInvalidOperator(operator); }

    _operators[holder][operator] = true;
    emit AuthorizedOperator(operator, holder);
  }

  function revokeOperator(address operator) external override{

    if(operator == address(0)){ revert STInvalidOperator(address(0)); }
    address holder = _msgSender();
    if(holder == operator){ revert STInvalidOperator(operator); }

    _operators[holder][operator] = false;
    emit RevokedOperator(operator, holder);
  }

  function isOperator(address operator, address holder)
    external override view returns (bool){
      return _operators[holder][operator];
  }


  function canTransfer(address recipient, uint256 amount, bytes memory data)
    external override virtual view returns (bool, bytes1, bytes32){

    // @TODO
  }

  function canTransferFrom(address sender, address recipient, uint256 amount, bytes memory data)
    external override virtual view returns (bool, bytes1, bytes32){

    // @TODO
  }

  /***
   *
   * @custom:see https://eips.ethereum.org/EIPS/eip-1066#0x5-tokens-funds--finance
   */
  function _canTransfer(address sender, address recipient, uint256 amount, bytes memory data)
    internal virtual view returns(bool, bytes1, bytes32){
      if(sender == address(0)){ // issuance case
        if(_cap > 0){
          unchecked{
            if(_supply + amount > _cap) return (false, 0x5A, bytes32(0));
          }
        }
      }

      // @TODO
      return (true, 0x51, bytes32(0)); // 0x51 : Transfer Successful
  }


  function transferWithData(address recipient, uint256 amount, bytes memory data)
    external override virtual{

    // @NOTE Currently same with `transfer()`, 'cause `data` is not used at all.
    _transfer(_msgSender(), recipient, amount);
  }

  function transferFromWithData(address sender, address recipient, uint256 amount, bytes memory data)
    external override virtual{

    // @NOTE Currently same with `transferFrom()`, 'cause `data` is not used at all.
    _transferFrom(sender, recipient, _msgSender(), amount);
  }

  function isIssuable() external override view returns (bool){
   return _isIssuable();
  }

  function _isIssuable() internal virtual view returns (bool) {
    return _issuable;
  }

  function setIssuable(bool issuable) external override{
    address invoker = _msgSender();
    if(!_hasAdminRole(invoker)){
      revert ACUnauthorizedAccess(ADMIN_ROLE, invoker);
    }

    _issuable = issuable;
    if(issuable){ emit Issuable(invoker); }
    else{ emit Unissuable(invoker); }
  }

  function issue(address holder, uint256 amount, bytes memory data)
    external override{

    address spender = _msgSender();
    if(!_hasIssuerRole(spender)){
      revert ACUnauthorizedAccess(ISSUER_ROLE, spender);
    }

    if(!_isIssuable()){ revert STUnissuableState(); }
    if(_isPaused()){ revert STPausedState(); }
    if(holder == address(0)){ revert ERC20InvalidReceiver(address(0)); }
    if(amount == 0){ revert STDisallowedAmount(0); }
    if(_cap > 0){
      unchecked{
        if(_cap < _supply + amount){ revert STOverflowingSupply(); }
      }
    }

    unchecked{
      _balances[holder] += amount;
      _supply += amount;
    }

    emit Issued(spender, holder, amount, data);
    emit Transfer(address(0), holder, amount);
  }

  function redeem(uint256 amount, bytes memory data)
    external override{

    address holder = _msgSender();
    _redeem(holder, holder, amount, data, false);
  }

  function redeemFrom(address holder, uint256 amount, bytes memory data)
    external override{

    address spender = _msgSender();

    if(spender == holder || _operators[holder][spender]){
      _redeem(spender, holder, amount, data, false);
    }else{ // approved spender maybe
      if(_allowances[holder][spender] >= amount){
        _approve(holder, spender, _allowances[holder][spender] - amount);
        _redeem(spender, holder, amount, data, false);
      }else{
        revert ERC20InsufficientAllowance(spender, _allowances[holder][spender], amount);
      }
    }
  }

  function _redeem(address spender, address holder, uint256 amount,
    bytes memory data, bool forced) internal virtual{

    if(_isPaused()){ revert STPausedState(); }
    if(amount == 0){ revert STDisallowedAmount(0); }
    uint256 balance = _balances[holder];
    if(amount > balance){
      revert ERC20InsufficientBalance(holder, balance, amount);
    }

    unchecked{
      _balances[holder] = balance - amount;
      _supply -= amount;
    }

    if(!forced){ emit Redeemed(spender, holder, amount, data); }
    emit Transfer(holder, address(0), amount);
  }


  function isControllable() external override view returns (bool){
    return true;
  }

  function controllerTransfer(
    address sender, address recipient, uint256 amount,
    bytes calldata data, bytes calldata controllerData)
    external override{

    address controller = _msgSender();
    if(!_hasControllerRole(controller)){
      revert ACUnauthorizedAccess(CONTROLLER_ROLE, controller);
    }

    _transfer(sender, recipient, amount);
    emit ControllerTransfer(controller, sender, recipient, amount, data, controllerData);
  }

  function controllerRedeem(
    address holder, uint256 amount,
    bytes calldata data, bytes calldata controllerData) external override{

    address controller = _msgSender();
    if(!_hasControllerRole(controller)){
      revert ACUnauthorizedAccess(CONTROLLER_ROLE, controller);
    }

    _redeem(controller, holder, amount, data, true);
    emit ControllerRedemption(controller, holder, amount, data, controllerData);
  }


  function supplyCap() external override view returns(uint256 cap){
    return _cap;
  }

  function setSupplyCap(uint256 cap) external override{

    if(!_hasIssuerRole(_msgSender())){
      revert ACUnauthorizedAccess(ISSUER_ROLE, _msgSender());
    }

    _updateSupplyCap(cap);
  }

  function _updateSupplyCap(uint256 cap) internal virtual{

    if(cap > 0 && cap < _supply){ revert STInsufficientSupplyCap(cap, _supply); }
    emit SupplyCapChanged(_cap, cap);
    _cap = cap;
  }

  function increaseSupplyCap(uint256 delta) external override returns(uint256 cap){

    if(!_hasIssuerRole(_msgSender())){
      revert ACUnauthorizedAccess(ISSUER_ROLE, _msgSender());
    }

    unchecked{
      _updateSupplyCap(_cap + delta);
    }
    return _cap;
  }

  function decreaseSupplyCap(uint256 delta) external override returns(uint256 cap){

    if(!_hasIssuerRole(_msgSender())){
      revert ACUnauthorizedAccess(ISSUER_ROLE, _msgSender());
    }
    if(delta > _cap){
      revert STExcessiveSupplyCapDecrease(_cap, delta, _supply);
    }

    _updateSupplyCap(_cap - delta);
    return _cap;
  }

  function removeSupplyCap() external override{

    if(!_hasIssuerRole(_msgSender())){
      revert ACUnauthorizedAccess(ISSUER_ROLE, _msgSender());
    }

    _updateSupplyCap(0);
  }


  function circulatingSupply() external override view returns(uint256 supply){

    revert STNotYetImplemented();

    // @TODO Needs implementation

  }

  function lockedSupply() external override view returns(uint256 supply){

    revert STNotYetImplemented();

    // @TODO Needs implementation
  }
}