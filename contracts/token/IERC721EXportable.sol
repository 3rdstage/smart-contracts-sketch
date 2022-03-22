// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/IERC721.sol";


interface IERC721Exportable is IERC721{

    enum State { Exporting, Exported, Imported }

    /**
     * Only owner or approved of a token can start exporting the token.
     *
     * @param escrowee the address to whom the token is temporarily owned while exporting (before exported.)
     */
    function exporting(uint256 tokenId, address escrowee) external;

    /**
     * Only token onwer can set the token exported (finished exporting).
     *
     */
    function exported(uint256 tokenId) external;

    /**
     * Only token minter (who has MINTER role) can import a token
     *
     * @param owner a new owner of the specified token - shoudn't be zero address
     */
    function imported(uint256 preferredTokenId, address owner) external returns(uint256 tokenId);


    /**
     * @return the number of tokens in exporting state
     */
    function countExportingTokens() external view returns(uint256);

    /**
     * @return the IDs of tokens in exporting state
     */
    function exportingTokens() external view returns(uint256[] memory);


    function countExportedTokens() external view returns(uint256);

    function exportedTokens() external view returns(uint256[] memory);

    function countImportedTokens() external view returns(uint256);

    function importedTokens() external view returns(uint256[] memory);

}