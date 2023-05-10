
pragma solidity ^0.8.0;

import "./ERC721Regular.sol";

contract ERC721Factory{

    function deployERC721Regular(string memory name, string memory symbol,
        address minter, address backupMinter,
        address pauser, address backupPauser) public returns(address){

        require(minter != address(0), "Zero address can't be minter.");
        require(pauser != address(0), "Zero address can't be pauser.");
        
        ERC721Regular contr = new ERC721Regular(name, symbol);
        contr.grantRole(contr.MINTER_ROLE(), minter);
        if(backupMinter != address(0)) { contr.grantRole(contr.MINTER_ROLE(), minter); }
        contr.grantRole(contr.PAUSER_ROLE(), pauser);
        if(backupPauser != address(0)) { contr.grantRole(contr.PAUSER_ROLE(), backupPauser); }

        return address(contr);
    }



}