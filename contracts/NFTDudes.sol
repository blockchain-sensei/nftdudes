// contracts/NFTDudes.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract NFTDudes is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    ERC721Pausable,
    AccessControl,
    ERC721Holder
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string private _baseTokenURI;

    uint256 public salePrice = 50000000000000000;

    constructor() ERC721("Coomiverse Game NFT", "COOMI") {
        _baseTokenURI = "ipfs://";

        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setPrice(uint256 price)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        salePrice = price;
        return true;
    }

    receive() external payable {
        require(msg.value >= salePrice, "Not enough funds to purchase token");
        uint256 tokenAmount = msg.value / salePrice;
        for (uint256 i = 0; i < tokenAmount; ++i) {
            _mint(msg.sender, _tokenIds.current());
            _setTokenURI(_tokenIds.current(), "");

            _tokenIds.increment();
        }
    }

    function safeMint(address player, string memory URI)
        public
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _safeMint(player, newItemId);
        _setTokenURI(newItemId, URI);

        _tokenIds.increment();

        return newItemId;
    }

    function setTokenURI(uint256 tokenId, string memory URI) public {
        //check if token belongs to user
        require(ownerOf(tokenId) == msg.sender, "You do not own this NFT");
        _setTokenURI(tokenId, URI);
    }

    function addMinter(address newMinter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, newMinter);
    }

    //role management
    function addPauser(address newPauser) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PAUSER_ROLE, newPauser);
    }

    function removeMinter(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, minter);
    }

    function removePauser(address pauser) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(PAUSER_ROLE, pauser);
    }

    function withdraw(address payable owner) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        owner.transfer(address(this).balance);
        return true;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}
