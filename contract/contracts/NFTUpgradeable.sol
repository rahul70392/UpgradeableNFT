// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTUpgradeable is ERC721Upgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIds;


    uint public constant MAX_SUPPLY = 10000; //Max nfts that can be minted
    uint public constant MAX_PER_MINT = 50; //max mints per txn
    
    string public baseTokenURI; //ipfs url of folder with JSON meta
    uint256 public mintPrice;
    address public commissionAddress;

    mapping(uint256 => uint256) public tokenId_to_erc20; //tokenID to erc20balance
    mapping(address => uint256) public depositer_to_erc20balance; //to track the desposits

    event LogTokenMinted(address indexed minter, uint256 indexed tokenId);
    event BaseURIUpdated(string indexed oldValue, string indexed newValue);
    event MintPriceUpdated(uint256 indexed oldValue, uint256 indexed newValue);
    event ERC20Deposited(address erc20, uint256 erc20Amount, address owner, uint256 tokenId);

    function initialize() public initializer {
        __ERC721_init("NFTUpgradeable", "NFTU");  //initializers of parent contracts need to be called manually, unlike constructors
        __Ownable_init();                         // solidity calls constructors of parent contracts itself

        baseTokenURI = "ipfs://xxx/";
        mintPrice = 0.0001 ether;
        commissionAddress = address(0xd8FAb48021a04b17F08Ee478491c84fccae3F66E);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        emit BaseURIUpdated(baseTokenURI, _newBaseURI);
        baseTokenURI = _newBaseURI;
    }

    function setMintPrice(uint256 _newPrice) external onlyOwner {
        // Mint price in wei
        emit MintPriceUpdated(mintPrice, _newPrice);
        mintPrice = _newPrice;
    }

    function reserveNFTs() public onlyOwner{
        uint totalMinted = _tokenIds.current();

        require(
            totalMinted.add(10) < MAX_SUPPLY, "No NFTs Left"
        );

        for(uint i=0;i<10;i++){
            _mintSingleNFT();
        }
    }

    function _baseURI() internal 
                    view 
                    virtual 
                    override 
                    returns (string memory) {
        return baseTokenURI;
    }

    function mintNFTs(uint _count) public payable {
        //Check there is enough supply to mint 
        uint totalMinted = _tokenIds.current();
        require(
        totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFT Supply!"
        );
        //mint >0 and less than max txn limit
        require(
        _count > 0 && _count <= MAX_PER_MINT, 
        "Cannot mint NFTs as Max allowed limit reached."
        );
        //enough ether to mint requested nfts 
        require(
        msg.value >= mintPrice.mul(_count), 
        "Not enough ether to purchase NFTs."
        );

        //Mint the NFT 
        for (uint i = 0; i < _count; i++) {
                    _mintSingleNFT();
            }
    }

    //Mint a single NFT and increment the counter
    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    //Withdraw the balance -> ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "Zero Balance");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    //deposit ERC20 token into an NFT to upgrade your NFT level
    function depositERC20(address erc20Address, uint256 _erc20amount, uint256 _tokenID ) public returns(bool){
        IERC20 token;
        token = IERC20(erc20Address);
        require(_erc20amount <= token.allowance(msg.sender, address(this)), "Please approve tokens before transferring");
        require(msg.sender == ownerOf(_tokenID));
        token.transferFrom(msg.sender, address(this), _erc20amount);
        tokenId_to_erc20[_tokenID] = tokenId_to_erc20[_tokenID].add(_erc20amount);
        depositer_to_erc20balance[msg.sender] = depositer_to_erc20balance[msg.sender].add(_erc20amount);
        emit ERC20Deposited(erc20Address, _erc20amount, msg.sender, _tokenID);
        return true;
    }

    // This function allow you to see contract balance of a particular erc20
    function getBalanceForTokenID(uint256 _tokenID) public view returns(uint256){
        return tokenId_to_erc20[_tokenID];
    }

        // This function allow you to see contract balance of a particular erc20
    function getBalanceForDepositer(address depositer) public view returns(uint256){
        return depositer_to_erc20balance[depositer];
    }


    function withdrawERC20(address erc20Address, uint256 _erc20amount, uint256 _tokenID)public returns(bool){
        IERC20 token;
        token = IERC20(erc20Address);
        require(depositer_to_erc20balance[msg.sender] >= _erc20amount);
        require(msg.sender == ownerOf(_tokenID));
        require(tokenId_to_erc20[_tokenID] >= _erc20amount);
        tokenId_to_erc20[_tokenID] = tokenId_to_erc20[_tokenID].sub(_erc20amount);
        uint256 amountToTransfer = _erc20amount.mul(90).div(100);
        uint256 remainingAmount = _erc20amount.sub(amountToTransfer);
        token.transfer(msg.sender,amountToTransfer);
        token.transfer(commissionAddress,remainingAmount);
        return true;
    }
}
