// SPDX-License-Identifier: GPL-3.0
/*
   _  ____________  ___   ___  ___  ___   ___  ______ 
  / |/ / __/_  __/ / _ | / _ \/ _ \/ _ | / _ \/ __/ / 
 /    / _/  / /   / __ |/ ___/ ___/ __ |/ , _/ _// /__
/_/|_/_/   /_/   /_/ |_/_/  /_/  /_/ |_/_/|_/___/____/
                    NFT Apparel

Website: nftapparel.com.au 
Telegram: t.me/NFTApparelOfficial

                                                     
 █▀▄▀█ █▀▀ ▀█▀ █ █▀ █▄░█ █ █▄░█ ░░█ ▄▀█ █▀
 █░▀░█ ██▄ ░█░ █ ▄█ █░▀█ █ █░▀█ █▄█ █▀█ ▄█
*/

pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; 
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./interfaces/INetswapRouter02.sol";


contract MetisNinjas is ERC2981, ERC721Enumerable, Ownable, ReentrancyGuard, AccessControl {
    using SafeMath for uint256;
    using Address for address;
    using Address for address payable;

    uint256 public MAX_TOTAL_MINT;
    uint256 private _currentTokenId = 0;

    string private _contractURI;
    string public baseTokenURI;
    string public baseTokenURIExtension;
    
    address public treasury = 0x935de4a7AC0A4386604dE82f235f73829F5a32af;
    address public artist = 0xe5d100bF6b44F54e0371EDCDE29018c8B54f4b46;
    address public proToken = 0x259EF6776648500D7F1A8aBA3651E38b1121e65e;
    address public constant WMETIS = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;
    address public constant NETSWAP_ROUTER_ADDRESS = 0x1E876cCe41B7b844FDe09E38Fa1cf00f213bFf56;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bool public saleActive = false;

    INetswapRouter02 public netswapRouter;
    
    constructor (uint256 _count) ERC721("Metis Ninjas", "NINJAS") {
        MAX_TOTAL_MINT = 5000;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        netswapRouter = INetswapRouter02(NETSWAP_ROUTER_ADDRESS);
        for (uint256 i = 0; i < _count; i++) {
            uint256 newTokenId = _getNextTokenId();
            _safeMint(0x835cFE8ed412177F55e55633dA6Ec15969eaA6a3, newTokenId);
            _incrementTokenId();
        }
    }

    function setBaseURI(string memory _setBaseURI) external onlyOwner {
        baseTokenURI = _setBaseURI;
    }

    function setBaseURIExtension(string memory _baseTokenURIExtension) external onlyOwner {
        baseTokenURIExtension = _baseTokenURIExtension;
    }

    function setContractURI(string memory uri) external onlyOwner {
        _contractURI = uri;
    }

    function setSaleState (bool _saleActive) public onlyOwner {
        require (saleActive != _saleActive, "Sale state is same as previous value");
        saleActive = _saleActive;
    }

    function setTreasuryWallet (address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setArtistWallet (address _artist) external onlyOwner {
        artist = _artist;
    }

    function setProToken (address _proToken) external onlyOwner {
        proToken = _proToken;
    }

    // PUBLIC
    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControl, ERC2981, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), baseTokenURIExtension)) : "";
    }

    function getInfo() external view returns (
        uint256,
        uint256,
        uint256
    ) {
        return (
        this.totalSupply(),
        msg.sender == address(0) ? 0 : this.balanceOf(msg.sender),
        MAX_TOTAL_MINT
        );
    }

    /**
     * Accepts required payment and mints a specified number of tokens to an address.
     */
    function purchase(uint256 count) public payable nonReentrant {

        // Make sure minting is allowed
        requireMintingConditions(count);

        uint256 price;

        if (count >= 1 && count <= 2) {
            price = 2.5 ether;
        }
        else if (count >= 3 && count <= 5) {
            price = 2.0 ether;
        }
        else if (count >= 6 && count <= 10) {
            price = 1.7 ether;
        }
        else if (count > 10) {
            price = 1.5 ether;
        }

        // Sent value matches required ETH amount
        require(price * count <= msg.value, "ERC721_COLLECTION/INSUFFICIENT_ETH_AMOUNT");

        for (uint256 i = 0; i < count; i++) {
            uint256 newTokenId = _getNextTokenId();
            _safeMint(msg.sender, newTokenId);
            _incrementTokenId();
        }
    }

    function withdraw () public onlyOwner {
        _withdraw();
    }

    function _withdraw() internal {
        uint256 balance = address(this).balance;
        uint256 treasuryAmt = balance.mul(65).div(100);
        uint256 artistAmt = balance.mul(25).div(100);
        uint256 buybackAmt = balance.sub(treasuryAmt).sub(artistAmt);
        require(treasuryAmt.add(artistAmt).add(buybackAmt) == balance, "Subtraction overflow error");
        payable(treasury).transfer(treasuryAmt);
        payable(artist).transfer(artistAmt);
        swapMetisWithToken(buybackAmt, proToken, treasury);
    }

    // PRIVATE

    /**
     * This method checks if ONE of these conditions are met:
     *   - Public sale is active.
     *   - Pre-sale is active and receiver is allowlisted.
     *
     * Additionally ALL of these conditions must be met:
     *   - Gas fee must be equal or less than maximum allowed.
     *   - Newly requested number of tokens will not exceed maximum total supply.
     */
    function requireMintingConditions(uint256 count) internal view {
        require (count >0 , "count must be greater than zero");
        require(totalSupply() + count <= MAX_TOTAL_MINT, "Minting exceeds max supply");
        require (saleActive, "Sale did not start yet");
    }

    /**
     * Calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId.add(1);
    }

    /**
     * Increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
        Airdrop by admin
     */
    function airdropNFT (address [] memory _to ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 _count = _to.length;
        require(totalSupply() + _count <= MAX_TOTAL_MINT, "Minting exceeds max supply");

        for (uint256 i = 0; i < _count; i++) {
            uint256 newTokenId = _getNextTokenId();
            _safeMint(_to[i], newTokenId);
            _incrementTokenId();
        }
    }
    
    /***
        Swap tokens with metis using NetSwap Interface
     */
    function swapMetisWithToken(uint256 metisAmount, address token, address to) public {
        uint deadline = block.timestamp + 15;
        address[] memory path = new address[](2);
        path[0] = WMETIS;
        path[1] = token;
        netswapRouter.swapExactMetisForTokens {value: metisAmount} (
            0,
            path,
            to,
            deadline
        );
    }
}
