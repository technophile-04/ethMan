//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract ETHMan is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Strings for uint160;
    using Strings for uint16;

    /* ========== STATE VARIABLES ========== */
    uint16 private _tokenIds;

    uint16 private constant MAX_SUPPLY = 1000;
    address payable constant buildGuild =
        payable(0x97843608a00e2bbc75ab0C1911387E002565DEDE);
    uint public constant PRICE = 0.001 ether;

    mapping(uint16 => uint16[7]) public tokenIdToHue;
    mapping(uint16 => uint256) public tokenIdToRandomNumber;

    constructor() ERC721("ETH Man", "EMAN") {}

    function mintItem() public payable returns (uint256) {
        require(_tokenIds <= MAX_SUPPLY, "DONE MINTING");
        require(msg.value >= PRICE, "Price is 0.01 matic");

        _tokenIds = _tokenIds + 1;

        uint16 id = _tokenIds;

        _mint(msg.sender, id);

        uint16[7] memory HUES = [0, 60, 120, 180, 240, 300, 340];

        uint256 pseudoRandomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    address(this),
                    block.chainid,
                    id,
                    block.timestamp,
                    block.difficulty
                )
            )
        );

        // reorder the HUES randomly
        for (uint256 i = 0; i < 7; i++) {
            uint256 randomIndex = i + pseudoRandomNumber % (7 - i);
            uint16 temp = HUES[randomIndex];
            HUES[randomIndex] = HUES[i];
            HUES[i] = temp;
        }

        tokenIdToHue[id] = HUES;
        tokenIdToRandomNumber[id] = pseudoRandomNumber;

        (bool success, ) = buildGuild.call{value: msg.value}("");
        require(success, "Failed sending to BuildGuild")

        return id;
    }
}
