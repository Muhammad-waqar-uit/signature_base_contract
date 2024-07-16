// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.2/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts@5.0.2/utils/cryptography/EIP712.sol";

contract MyToken is ERC721, ERC721URIStorage,EIP712 {

    address public minter;

    constructor(address initialOwner)
        ERC721("MyToken", "MTK")
        EIP712("Voucher-Domain","1")
    {
        minter=initialOwner;
    }


    struct LazyNFTVoucher{
        uint256 tokenId;
        string uri;
        address buyer;
        bytes signature;
    }

    function recover(LazyNFTVoucher calldata voucher) public view returns(address){
        bytes32 digest=_hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("LazyNFTVoucher(uint256 tokenId,string uri,address buyer)"),
                    voucher.tokenId,
                    keccak256(
                        bytes(voucher.uri)
                    ),
                    voucher.buyer
                )
            )
        );

        address recoverSignature=ECDSA.recover(digest,voucher.signature);
        return recoverSignature;
    }

    function safeMint(LazyNFTVoucher calldata voucher)
        public
    {
        require(minter==recover(voucher),"ERROR minter is not the signer");
        address creator=recover(voucher);
        _safeMint(creator, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
        _transfer(creator, voucher.buyer, voucher.tokenId);
    }

    // The following functions are overrides required by Solidity.

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
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
