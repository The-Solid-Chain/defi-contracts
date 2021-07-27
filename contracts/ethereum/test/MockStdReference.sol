// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStdReference.sol";

contract MockStdReference is IStdReference {
    uint256 testRate = 1e18;

    bytes32 encodedANT;
    bytes32 encodedBNB;
    bytes32 encodedBUSD;

    constructor() {
        encodedANT = keccak256(abi.encodePacked("ANT"));
        encodedBNB = keccak256(abi.encodePacked("BNB"));
        encodedBUSD = keccak256(abi.encodePacked("BUSD"));
    }

    /// Returns the price data for the given base/quote pair. Revert if not available.
    function getReferenceData(
        string memory _base,
        string memory /*_quote*/
    ) public view override returns (ReferenceData memory) {
        ReferenceData memory data;

        bytes32 encodedBase = keccak256(abi.encodePacked(_base));

        if (encodedBase == encodedANT) {
            data.rate = testRate;
            data.lastUpdatedBase = 0;
            data.lastUpdatedQuote = 0;
        } else if (encodedBase == encodedBNB) {
            data.rate = 300 * 1e18;
            data.lastUpdatedBase = 0;
            data.lastUpdatedQuote = 0;
        } else if (encodedBase == encodedBUSD) {
            data.rate = 1e18;
            data.lastUpdatedBase = 0;
            data.lastUpdatedQuote = 0;
        } else {
            data.rate = 1e18;
            data.lastUpdatedBase = 0;
            data.lastUpdatedQuote = 0;
        }

        return data;
    }

    /// Similar to getReferenceData, but with multiple base/quote pairs at once.
    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes)
        external
        view
        override
        returns (ReferenceData[] memory)
    {
        ReferenceData[] memory data = new ReferenceData[](_bases.length);

        for (uint256 i = 0; i < data.length; ++i) {
            data[i] = getReferenceData(_bases[i], _quotes[i]);
        }

        return data;
    }

    function setTestRate(uint256 rate) external {
        testRate = rate;
    }
}
