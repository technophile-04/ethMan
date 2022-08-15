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

    /* ========== Functions ========== */
    constructor(address _priceFeed) ERC721("ETH Man", "EMAN") {
        i_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function mintItem() public payable returns (uint256) {
        require(_tokenIds <= MAX_SUPPLY, "DONE MINTING");
        require(msg.value >= PRICE, "Price is 0.001 ETH");

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
        (bool success, ) = buildGuild.call{value: msg.value}("");
        require(success, "Failed sending funds to BuildGuild");

        return id;
    }

    function tokenURI(uint256 id)
        public
        view
        override
        returns (string memory json)
    {
        require(_exists(id), "!exist");

        EthManProperties memory properites = getPropertiesById(uint16(id));

        if (isHappy[uint16(id)]) {
            return
                string.concat(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string.concat(
                                '{"name":"',
                                string.concat("ETH Man #", id.toString()),
                                '","description":"',
                                string.concat(
                                    "This ETH Man was born with a Happy face! with face color ",
                                    properites.faceColor
                                ),
                                '","attributes":[{"trait_type":"Eyes Color","value":"',
                                properites.eyesColor,
                                '"},{"trait_type":"Hands Color","value":"',
                                properites.handsColor,
                                '"},{"trait_type":"Legs Color","value":"',
                                properites.legsColor,
                                '"},{"trait_type":"Happy","value":"Yes',
                                '"}],"owner":"',
                                (uint160(ownerOf(id))).toHexString(20),
                                '","image": "',
                                "data:image/svg+xml;base64,",
                                Base64.encode(
                                    bytes(generateSVGofTokenById(uint16(id)))
                                ),
                                '"}'
                            )
                        )
                    )
                );
        } else {
            return
                string.concat(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string.concat(
                                '{"name":"',
                                string.concat("ETH Man #", id.toString()),
                                '","description":"',
                                string.concat(
                                    "This ETH Man was born with a Sad face! ! with face color ",
                                    properites.faceColor
                                ),
                                '","attributes":[{"trait_type":"Eyes Color","value":"',
                                properites.eyesColor,
                                '"},{"trait_type":"Hands Color","value":"',
                                properites.handsColor,
                                '"},{"trait_type":"Legs Color","value":"',
                                properites.legsColor,
                                '"},{"trait_type":"Happy","value":"No',
                                '"}]',
                                ',"image": "',
                                "data:image/svg+xml;base64,",
                                Base64.encode(
                                    bytes(generateSVGofTokenById(uint16(id)))
                                ),
                                '"}'
                            )
                        )
                    )
                );
        }
    }

    function generateSVGofTokenById(uint16 id)
        internal
        view
        returns (string memory)
    {
        string memory svg = string.concat(
            "<svg xmlns='http://www.w3.org/2000/svg'  width='200' height='200' viewBox='-100 -100 200 200'>",
            renderTokenById(id),
            "</svg>"
        );
        return svg;
    }

    function renderTokenById(uint16 id) public view returns (string memory) {
        EthManProperties memory properites = getPropertiesById(id);
        bool happy = isHappy[id];

        string memory render;

        if (happy) {
            render = string.concat(
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
                // legs
                '<line x1="-25" y1="50" x2="0" y2="-5" stroke="',
                properites.legsColor,
                '" stroke-width="33px" stroke-linecap="round" />',
                '<line x1="25" y1="50" x2="0" y2="-5"  stroke="',
                properites.legsColor,
                '" stroke-width="33px" stroke-linecap="round" />',
                // Hand
                '<line x1="-40" y1="-10" x2="40" y2="-10" stroke="',
                properites.handsColor,
                '" stroke-width="28px" stroke-linecap="round" />',
                "<path d='M-11,-45 A2,2 0 1,0 11,-44.5' stroke-width='2' stroke='",
                properites.mouthColor,
                "' fill='none' />"
            );
        } else {
            render = string.concat(
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
                // legs
                '<line x1="-25" y1="50" x2="0" y2="-5" stroke="',
                properites.legsColor,
                '" stroke-width="33px" stroke-linecap="round" />',
                '<line x1="25" y1="50" x2="0" y2="-5"  stroke="',
                properites.legsColor,
                '" stroke-width="33px" stroke-linecap="round" />',
                // Hand
                '<line x1="-40" y1="-10" x2="40" y2="-10" stroke="',
                properites.handsColor,
                '" stroke-width="28px" stroke-linecap="round" />',
                "<path d='M-11,-35 A2,2 0 1,1 11,-35' stroke-width='2' stroke='",
                properites.mouthColor,
                "' fill='none' />"
            );
        }

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
            ",90%",
            ",70%)"
        );

        uint8 eyesIndex = uint8((pseudoRandomNumber + 1) % 7);
        properites.eyesColor = string.concat(
            "hsl(",
            tokenIdToHue[id][eyesIndex].toString(),
            ",90%",
            ",60%)"
        );

        // 9 means not assigned
        uint8 smileIndex = 9;

        for (uint8 i = 0; i < 7; i++) {
            smileIndex = uint8((pseudoRandomNumber + i + 2) % 7);
            if (smileIndex != randomFaceIndex) {
                properites.mouthColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][i].toString(),
                    ",90%",
                    ",60%)"
                );
                break;
            } else if (i == 6) {
                smileIndex = uint8((pseudoRandomNumber + 9) % 7);
                properites.mouthColor = string.concat(
                    "hsl(",
                    tokenIdToHue[id][smileIndex].toString(),
                    ",90%",
                    ",60%)"
                );
            }
        }

        properites.legsColor = string.concat(
            "hsl(",
            tokenIdToHue[id][6].toString(),
            ",90%",
            ",70%)"
        );

        uint8 handColorIndex = uint8((pseudoRandomNumber + 4) % 7);

        if (handColorIndex != 6) {
            properites.handsColor = string.concat(
                "hsl(",
                tokenIdToHue[id][handColorIndex].toString(),
                ",90%",
                ",70%)"
            );
        } else {
            handColorIndex = uint8((pseudoRandomNumber + 5) % 7);
            properites.handsColor = string.concat(
                "hsl(",
                tokenIdToHue[id][handColorIndex].toString(),
                ",90%",
                ",70%)"
            );
        }

        return properites;
    }
}
