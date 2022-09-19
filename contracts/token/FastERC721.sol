import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/ERC721Burnable.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/ERC721Pausable.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/ERC721URIStorage.sol";

contract FastERC721 is ERC721Pausable, ERC721Burnarable, ERC721URIStorage{


  constructor(string memory name, string memory symbol, string memory baseURI)
    ERC721{


  }




}