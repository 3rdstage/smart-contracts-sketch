// SPDX-License-Identifier: UNLICENSED
// cspell:ignore vholder vholders vbalances
pragma solidity ^0.8.0;

import {IERC20Errors} from "./interface/IERC20Errors.sol";
import {ISecurityTokenErrors} from "./interface/ISecurityTokenErrors.sol";
import {IRegularSecurity} from "./IRegularSecurity.sol";
import {SecurityAccessControlBase} from "./SecurityAccessControlBase.sol";
import {Context} from "@openzeppelin/contracts-4/utils/Context.sol";
import {EnumerableSet} from "@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";

contract RegularSecurity is Context, IERC20Errors, ISecurityTokenErrors, IRegularSecurity, SecurityAccessControlBase{
  using EnumerableSet for EnumerableSet.AddressSet;


  string private _name;

  string private _symbol;

  uint8 private immutable _decimals;

  uint256 private _supply; // total supply = circulating + locked = SUM(issued) - SUM(redeemed)

  uint256 private _lockedSupply;

  uint256 private _cap; // max supply or supply cap : total supply <= cap

  bool private _issuable = true;

  bool private _paused = false;

  uint16 private _maxBundleSize = 20;

  // balance by holder
  // this balance includes both transferable tokens and locked tokens
  mapping(address => uint256) private _balances;

  mapping(address => uint256) private _lockedBalances;

  mapping(address => mapping(address => bool)) internal _operators;  // holder/operator/boolean

  mapping(address => mapping(address => uint256)) internal _allowances; // holder/spender/amount

  /// @notice Deploys a new instance of this contract
  ///
  /// @param name_  name (human readable title) of this security
  /// @param symbol_  code or number to identify this security - usually governed by the authorities
  /// @param decimals_  decimal
  /// @param cap  max supply
  /// @param admins  the array of accounts granted admin role - at least one account should be included
  /// @param issuers  the array of accounts granted issuer role - at least one account should be included
  /// @param controllers the array of accounts granted controller role - at least one account should be included
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

  /// @inheritdoc IRegularSecurity
  function name() external view override returns(string memory name_){
    name_ = _name;
  }

  /// @inheritdoc IRegularSecurity
  function symbol() external view override returns(string memory symbol_){
    symbol_ = _symbol;
  }

  /// @inheritdoc IRegularSecurity
  function decimals() external view override returns(uint8 decimals_){
    return _decimals;
  }

  function totalSupply() external view override returns(uint256 supply_){
    return _supply;
  }

  function isPaused() external view override returns (bool paused_){
    return _isPaused();
  }

  function _isPaused() internal view virtual returns (bool paused_){
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

    if(_balances[sender] - _lockedBalances[sender] < amount){
      revert STInsufficientUnlockedBalance(sender, _balances[sender] - _lockedBalances[sender], amount);
    }

    _beforeTransfer(sender, recipient, amount);
    unchecked{
      _balances[sender] -= amount;
      _balances[recipient] += amount;
    }
    _afterTransfer(sender, recipient, amount);

    emit Transfer(sender, recipient, amount);
  }

  function _beforeTransfer(address sender, address recipient,
    uint256 amount) internal virtual{ // solhint-disable-line no-empty-blocks
  }

  function _afterTransfer(address sender, address recipient,
      uint256 amount) internal virtual{ // solhint-disable-line no-empty-blocks
  }

  function authorizeOperator(address operator) external override{

    address holder = _msgSender();
    if(operator == address(0)){ revert STInvalidOperator(address(0), holder); }
    if(holder == operator){ revert STInvalidOperator(operator, holder); }

    _operators[holder][operator] = true;
    emit AuthorizedOperator(operator, holder);
  }

  function revokeOperator(address operator) external override{

    address holder = _msgSender();
    if(operator == address(0)){ revert STInvalidOperator(address(0), holder); }
    if(holder == operator){ revert STInvalidOperator(operator, holder); }

    _operators[holder][operator] = false;
    emit RevokedOperator(operator, holder);
  }

  function isOperator(address operator, address holder)
    external override view returns (bool){
      return _operators[holder][operator];
  }

  /// @notice
  ///    Using this function is not recommended
  function canTransfer(address recipient, uint256 amount, bytes memory data)
    external override virtual view returns (bool, bytes1, bytes32){

    return _canTransfer(_msgSender(), recipient, amount, data);
  }

  /// @notice
  ///    Using this function is not recommended
  function canTransferFrom(address sender, address recipient, uint256 amount, bytes memory data)
    external override virtual view returns (bool, bytes1, bytes32){

    return _canTransfer(sender, recipient, amount, data);
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
      } else { // transfer or redemption

        unchecked{ // check holder/sender's unlocked balance
          if(amount > _balances[sender] - _lockedBalances[sender]) return (false, 0x5A, bytes32(0));
        }
      }

      // finally, no abnormality
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
    uint256 unlocked = _balances[holder] - _lockedBalances[holder];
    if(amount > unlocked){
      revert STInsufficientUnlockedBalance(holder, unlocked, amount);
    }

    unchecked{
      _balances[holder] -= amount;
      _supply -= amount;
    }

    if(!forced){ emit Redeemed(spender, holder, amount, data); }
    emit Transfer(holder, address(0), amount);
  }

  // solhint-disable-next-line
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
    emit SupplyCapUpdated(_cap, cap);
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


  function lockedBalanceOf(address holder)
    public view returns(uint256 lockedBalance){

    lockedBalance = _lockedBalances[holder];
  }

  /// @inheritdoc IRegularSecurity
  function lock(address holder, uint256 more)
    public returns(uint256 lockedBalance){

    if(_isPaused()){ revert STPausedState(); }
    if(!_hasControllerRole(_msgSender())){
      revert ACUnauthorizedAccess(CONTROLLER_ROLE, _msgSender());
    }
    if(more == 0){ revert STDisallowedAmount(0); }

    uint256 balance = _balances[holder];
    uint256 locked = _lockedBalances[holder];
    if(more > balance - locked){
      revert ERC20InsufficientBalance(holder, balance, locked + more);
    }

    unchecked{
      _lockedBalances[holder] += more;
      _lockedSupply += more;
    }

    lockedBalance = locked + more;
    emit Locked(_msgSender(), holder, more, lockedBalance);
  }

  /// @inheritdoc IRegularSecurity
  function unlock(address holder, uint256 less)
    public returns(uint256 lockedBalance){

    if(_isPaused()){ revert STPausedState(); }
    if(!_hasControllerRole(_msgSender())){
      revert ACUnauthorizedAccess(CONTROLLER_ROLE, _msgSender());
    }
    if(less == 0){ revert STDisallowedAmount(0); }

    uint256 locked = _lockedBalances[holder];
    if(less > locked){
      revert STInsufficientLockedBalance(holder, locked, less);
    }

    unchecked{
      _lockedBalances[holder] -= less;
      _lockedSupply -= less;
    }

    lockedBalance = locked - less;
    emit Unlocked(_msgSender(), holder, less, lockedBalance);
  }

  /// @inheritdoc IRegularSecurity
  function circulatingSupply() external override view returns(uint256 supply){

    supply = _supply - _lockedSupply;
  }

  /// @inheritdoc IRegularSecurity
  function lockedSupply() external override view returns(uint256 supply){

    supply = _lockedSupply;
  }

  /// @inheritdoc IRegularSecurity
  function bundleMaxSize() public view returns(uint16 max){

    max = _maxBundleSize;
  }

  /// @inheritdoc IRegularSecurity
  function setBundleMaxSize(uint16 max) public{

    if(max == 0){ revert STDisallowedNumber(max); }

    _maxBundleSize = max;
    emit BundleMaxSizeUpdated(max);
  }

  /// @inheritdoc IRegularSecurity
  function bundleIssue(address[] memory holders, uint256[] memory amounts) public {

    address spender = _msgSender();
    if(!_hasIssuerRole(spender)){
      revert ACUnauthorizedAccess(ISSUER_ROLE, spender);
    }
    if(!_isIssuable()){ revert STUnissuableState(); }
    if(_isPaused()){ revert STPausedState(); }

    uint256 length1 = holders.length;
    uint256 length2 = amounts.length;

    if(length1 != length2){
      uint256[] memory lengths = new uint256[](2);
      lengths[0] = length1;
      lengths[1] = length2;
      revert STUnevenSizedPairedArgs(lengths);
    }else if(length1 > _maxBundleSize){
      revert STTooLargeBundle(_maxBundleSize, length1);
    }

    address holder;
    uint256 amount;
    for(uint256 i = 0; i < length1; i++){
      holder = holders[i];
      amount = amounts[i];

      if(holder == address(0)){ revert ERC20InvalidReceiver(address(0)); }
      if(amount == 0){ revert STDisallowedAmount(0); }
      if(_cap > 0){  // ensures total supply is not more than supply cap
        unchecked{
          if(_cap < _supply + amount){ revert STOverflowingSupply(); }
        }
      }

      unchecked{  // increases holder's balance and total supply
        _balances[holder] += amount;
        _supply += amount;
      }

      emit Issued(spender, holder, amount, "");
      emit Transfer(address(0), holder, amount);
    }
  }

  /// @inheritdoc IRegularSecurity
  function bundleTransfer(address[] memory recipients, uint256[] memory amounts) public{

    if(_isPaused()){ revert STPausedState(); }
    address sender = _msgSender();
    if(sender == address(0)){ revert ERC20InvalidSender(address(0)); }

    uint256 length1 = recipients.length;
    uint256 length2 = amounts.length;
    if(length1 != length2){
      uint256[] memory lengths = new uint256[](3);
      lengths[0] = length1;
      lengths[1] = length2;
      revert STUnevenSizedPairedArgs(lengths);
    }else if(length1 > _maxBundleSize){
      revert STTooLargeBundle(_maxBundleSize, length1);
    }

    address recipient;
    uint256 amount;
    for(uint256 i = 0; i < length1; i++){
      recipient = recipients[i];
      amount = amounts[i];

      if(recipient == address(0)){ revert ERC20InvalidReceiver(address(0)); }
      if(amount == 0){ revert STDisallowedAmount(0); }
      if(_balances[sender] < amount){
        revert ERC20InsufficientBalance(sender, _balances[sender], amount);
      }

      _beforeTransfer(sender, recipient, amount);
      unchecked{  // increases sender's balance and decreases recipient's balance
        _balances[sender] -= amount;
        _balances[recipient] += amount;
      }
      _afterTransfer(sender, recipient, amount);

      emit Transfer(sender, recipient, amount);
    }
  }

  /// @inheritdoc IRegularSecurity
  function bundleTransfer(address[] memory senders,
      address[] memory recipients, uint256[] memory amounts) public{

    address spender = _msgSender();
    if(!_hasControllerRole(spender)){
      revert ACUnauthorizedAccess(CONTROLLER_ROLE, spender);
    }
    if(_isPaused()){ revert STPausedState(); }

    uint256 length1 = senders.length;
    uint256 length2 = recipients.length;
    uint256 length3 = amounts.length;

    if((length1 != length2) || (length2 != length3)){
      uint256[] memory lengths = new uint256[](3);
      lengths[0] = length1;
      lengths[1] = length2;
      lengths[2] = length3;
      revert STUnevenSizedPairedArgs(lengths);
    }else if(length1 > _maxBundleSize){
      revert STTooLargeBundle(_maxBundleSize, length1);
    }

    address sender;
    address recipient;
    uint256 amount;
    for(uint256 i = 0; i < length1; i++){
      sender = senders[i];
      recipient = recipients[i];
      amount = amounts[i];

      if(sender == address(0)){ revert ERC20InvalidSender(address(0)); }
      if(recipient == address(0)){ revert ERC20InvalidReceiver(address(0)); }
      if(amount == 0){ revert STDisallowedAmount(0); }
      if(_balances[sender] < amount){
        revert ERC20InsufficientBalance(sender, _balances[sender], amount);
      }

      _beforeTransfer(sender, recipient, amount);
      unchecked{  // increases sender's balance and decreases recipient's balance
        _balances[sender] -= amount;
        _balances[recipient] += amount;
      }
      _afterTransfer(sender, recipient, amount);

      emit Transfer(sender, recipient, amount);
    }
  }

  /// @inheritdoc IRegularSecurity
  function bundleBalanceOf(address[] memory holders) public view
    returns(uint256[] memory balances, uint256[] memory lockedBalances){

    uint256 length = holders.length;
    if(length > _maxBundleSize){
      revert STTooLargeBundle(_maxBundleSize, length);
    }

    balances = new uint256[](length);
    lockedBalances = new uint256[](length);

    for(uint256 i = 0; i < length; i++){
      balances[i] = _balances[holders[i]];
      lockedBalances[i] = _lockedBalances[holders[i]];
    }

  }



}