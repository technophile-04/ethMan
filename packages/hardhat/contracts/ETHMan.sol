//SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

contract ETHMan is ERC721Enumerable {
    using Strings for uint256;
    using Strings for uint160;
    using Strings for uint16;

    struct EthManProperties {
        string faceColor;
        string eyesColor;
        string mouthColor;
        string handsColor;
        string legsColor;
        string btn1Color;
        string btn2Color;
        string tieBtnColor;
        string tieBtnStrokeColor;
        string tieColor;
        string tieStroke;
    }

    /* ========== STATE VARIABLES ========== */

    /* == constants and immutables == */
    uint16 private constant MAX_SUPPLY = 1000;
    address payable constant buildGuild =
        payable(0x97843608a00e2bbc75ab0C1911387E002565DEDE);
    uint public constant PRICE = 0.001 ether;
    AggregatorV3Interface public immutable i_priceFeed;

    /* == states == */
    uint16 private _tokenIds;
    uint256 private lastPrice = 0;
    mapping(uint16 => uint16[7]) public tokenIdToHue;
    mapping(uint16 => uint256) public tokenIdToRandomNumber;
    mapping(uint16 => bool) public isHappy;
    mapping(uint16 => EthManProperties) public tokenIdToProperties;

    /* ========== Functions ========== */
    constructor(address _priceFeed) ERC721("ETH Man", "EMAN") {
        i_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function mintItem() public payable returns (uint256) {
        require(_tokenIds <= MAX_SUPPLY, "DONE MINTING");
        require(msg.value >= PRICE, "Price is 0.001 matic");

        _tokenIds = _tokenIds + 1;

        uint16 id = _tokenIds;

        _mint(msg.sender, id);

        (
            ,
            /*uint80 roundID*/
            int price,
            ,
            ,
            /* uint startedAt */
            /*uint timeStamp*/
            uint80 answeredInRound
        ) = i_priceFeed.latestRoundData();

        if (uint256(price) > lastPrice) {
            isHappy[id] = true;
            lastPrice = uint256(price);
        } else {
            // by defalut its false
            // isHappy[id] = false;
            lastPrice = uint256(price);
        }

        uint16[7] memory HUES = [0, 60, 120, 180, 240, 300, 340];

        uint256 pseudoRandomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    address(this),
                    block.chainid,
                    id,
                    block.timestamp,
                    block.difficulty,
                    price
                )
            )
        );

        // reorder the HUES randomly
        for (uint256 i = 0; i < 7; i++) {
            uint256 randomIndex = i +
                ((pseudoRandomNumber + answeredInRound) % (7 - i));
            uint16 temp = HUES[randomIndex];
            HUES[randomIndex] = HUES[i];
            HUES[i] = temp;
        }

        tokenIdToHue[id] = HUES;
        tokenIdToRandomNumber[id] = pseudoRandomNumber;
        tokenIdToProperties[id] = getPropertiesById(id);
        (bool success, ) = buildGuild.call{value: msg.value}("");
        require(success, "Failed sending funds to BuildGuild");

        return id;
    }

    function renderTokenById(uint16 id) public view returns (string memory) {
        EthManProperties memory properites = tokenIdToProperties[id];

        // string memory mouth;

        // if (isHappy[id]) {
        //     mouth = string.concat(
        //         "<path d='M-11,-45 A2,2 0 1,0 11,-44.5' stroke-width='2' stroke='",
        //         properites.mouthColor,
        //         "' fill='none' />"
        //     );
        // } else {
        //     mouth = string.concat(
        //         "<path d='M-11,-35 A2,2 0 1,1 11,-35' stroke-width='2' stroke='",
        //         properites.mouthColor,
        //         "' fill='none' />"
        //     );
        // }

        string memory render = string(
            abi.encodePacked(
                // Face
                '<circle cx="0" cy="-50" r="32" fill="',
                properites.faceColor,
                '"/>',
                // Eyes
                '<circle cx="-12" cy="-55" r="3" fill="',
                properites.eyesColor,
                '"/>',
                '<circle cx="12" cy="-55" r="3" fill="',
                properites.eyesColor,
                '"/>',
                // Hand
                '<line class="limb" x1="-40" y1="-10" x2="40" y2="-10" stroke="',
                properites.handsColor,
                '"stroke-width="28px" stroke-linecap="round" />',
                // legs
                '<line class="limb" x1="-25" y1="50" x2="0" y2="-5" stroke="',
                properites.legsColor,
                '"stroke-width="33px" stroke-linecap="round" />',
                '<line class="limb" x1="25" y1="50" x2="0" y2="-5"  stroke="',
                properites.legsColor,
                '"stroke-width="33px" stroke-linecap="round" />',
                //Buttons
                '<circle class="button" cx="0" cy="14" r="3" fill="',
                properites.btn1Color,
                '" />',
                '<circle class="button" cx="0" cy="0" r="3" fill="',
                properites.btn2Color,
                '" />',
                // tie
                '<rect class="tie" x="-16" y="-27" width="32" height="9" rx="5" fill="',
                properites.tieColor,
                '" stroke="',
                properites.tieStroke,
                '" />',
                // tie button
                '<circle class="button" cx="0" cy="-22" r="6" fill="',
                properites.tieBtnColor,
                '" stroke="',
                properites.tieBtnStrokeColor,
                '" />'
                // mouth
                // mouth
            )
        );

        return render;
    }

    function getPropertiesById(uint16 id)
        public
        view
        returns (EthManProperties memory properites)
    {
        // 7 is length of HUEs array
        uint256 pseudoRandomNumber = tokenIdToRandomNumber[id];
        uint8 randomFaceIndex = uint8(pseudoRandomNumber % 7);

        properites.faceColor = string.concat(
            "hsl(",
            tokenIdToHue[id][randomFaceIndex].toString(),
            "%",
            ",90%",
            ",70%)"
        );

        // 9 means not assigned
        uint8 eyesIndex = 9;
        uint8 smileIndex = 9;

        for (uint8 i = 0; i < 7; i++) {
            if (i != randomFaceIndex && eyesIndex == 9) {
                properites.eyesColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][i].toString(),
                    "%",
                    ",90%",
                    ",70%)"
                );
                eyesIndex = i;
            } else if (eyesIndex != smileIndex && smileIndex == 9) {
                properites.mouthColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][i].toString(),
                    "%",
                    ",90%",
                    ",70%)"
                );
                smileIndex = i;
            }
        }

        properites.legsColor = string.concat(
            "hsl(",
            tokenIdToHue[id][3].toString(),
            "%",
            ",90%",
            ",70%)"
        );

        properites.btn1Color = string.concat(
            "hsl(",
            tokenIdToHue[id][4].toString(),
            "%",
            ",90%",
            ",70%)"
        );

        properites.btn2Color = string.concat(
            "hsl(",
            tokenIdToHue[id][5].toString(),
            "%",
            ",90%",
            ",70%)"
        );

        uint8 handColorIndex = uint8((pseudoRandomNumber + 4) % 7);

        if (handColorIndex != 3) {
            properites.handsColor = string.concat(
                "hsl(",
                tokenIdToHue[id][handColorIndex].toString(),
                "%",
                ",90%",
                ",70%)"
            );
        } else {
            handColorIndex = uint8((pseudoRandomNumber + 5) % 7);
            properites.handsColor = string.concat(
                "hsl(",
                tokenIdToHue[id][handColorIndex].toString(),
                "%",
                ",90%",
                ",70%)"
            );
        }

        uint8 tieColorIndex = 9;
        uint8 tieBtnColorIndex = 9;

        for (uint8 i = 0; i < 7; i++) {
            if (i != handColorIndex && i != 3 && tieColorIndex == 9) {
                properites.tieColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][i].toString(),
                    "%",
                    ",90%",
                    ",70%)"
                );
                tieBtnColorIndex = i;
            } else if (
                tieColorIndex != tieBtnColorIndex && tieBtnColorIndex == 9
            ) {
                properites.tieBtnColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][i].toString(),
                    "%",
                    ",90%",
                    ",70%)"
                );
                tieBtnColorIndex = i;
            }
        }

        // now using it for stroke
        tieColorIndex = uint8((tieColorIndex + pseudoRandomNumber) % 7);

        properites.tieStroke = string.concat(
            "hsl(",
            tokenIdToHue[id][tieColorIndex].toString(),
            "%",
            ",90%",
            ",60%)"
        );

        // now using it for stroke
        tieBtnColorIndex = uint8((tieBtnColorIndex + pseudoRandomNumber) % 7);

        properites.tieBtnStrokeColor = string.concat(
            "hsl(",
            tokenIdToHue[id][tieBtnColorIndex].toString(),
            "%",
            ",90%",
            ",60%)"
        );

        return properites;
    }
}

// function renderTokenById(uint16 id) public view returns (string memory) {
//         EthManProperties memory properites = tokenIdToProperties[id];

//         string memory mouth;

//         if (isHappy[id]) {
//             mouth = string.concat(
//                 "<path d='M-11,-45 A2,2 0 1,0 11,-44.5' stroke-width='2' stroke='",
//                 properites.mouthColor,
//                 "' fill='none' />"
//             );
//         } else {
//             mouth = string.concat(
//                 "<path d='M-11,-35 A2,2 0 1,1 11,-35' stroke-width='2' stroke='",
//                 properites.mouthColor,
//                 "' fill='none' />"
//             );
//         }
//         string memory render = string(
//             abi.encodePacked(
//                 // Face
//                 '<circle cx="0" cy="-50" r="32" fill="',
//                 properites.faceColor,
//                 '"/>',
//                 // Eyes
//                 '<circle cx="-12" cy="-55" r="3" fill="',
//                 properites.eyesColor,
//                 '"/>',
//                 '<circle cx="12" cy="-55" r="3" fill="',
//                 properites.eyesColor,
//                 '"/>',
//                 // Hand
//                 '<line class="limb" x1="-40" y1="-10" x2="40" y2="-10" stroke="',
//                 properites.handsColor,
//                 '"stroke-width="28px" stroke-linecap="round" />',
//                 // legs
//                 '<line class="limb" x1="-25" y1="50" x2="0" y2="-5" stroke="',
//                 properites.legsColor,
//                 '"stroke-width="33px" stroke-linecap="round" />',
//                 '<line class="limb" x1="25" y1="50" x2="0" y2="-5"  stroke="',
//                 properites.legsColor,
//                 '"stroke-width="33px" stroke-linecap="round" />',
//                 //Buttons
//                 '<circle class="button" cx="0" cy="14" r="3" fill="',
//                 properites.btn1Color,
//                 '" />',
//                 '<circle class="button" cx="0" cy="0" r="3" fill="',
//                 properites.btn2Color,
//                 '" />',
//                 // tie
//                 '<rect class="tie" x="-16" y="-27" width="32" height="9" rx="5" fill="',
//                 properites.tieColor,
//                 '" stroke="',
//                 properites.tieStroke,
//                 '" />',
//                 // tie button
//                 '<circle class="button" cx="0" cy="-22" r="6" fill="',
//                 properites.tieBtnColor,
//                 '" stroke="',
//                 properites.tieBtnStrokeColor,
//                 '" />',
//                 // mouth
//                 mouth
//             )
//         );

//         return render;
//     }
