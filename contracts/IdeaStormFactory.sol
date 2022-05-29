//SPDX-License-Identifier: Nolicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IdeaStorm.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract IdeaStormFactory is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter ids;

    event DAOCreated(uint id, address owner, address contractAddress, string name);

    struct DAO{
        uint id;
        address owner;
        address contractAddress;
        string name;   
    }

    DAO[] DAOs;

    function createIdeaStorm(string memory _name, address _linkedNFT, uint _nftType, uint _nftId) external {
        uint newId = ids.current();
        address DAOAddress = address(new IdeaStorm{salt: keccak256(abi.encodePacked(_linkedNFT, _nftType, _nftId)) }(_linkedNFT, _nftType, _nftId));

        DAOs.push(DAO({
            id: newId,
            owner: msg.sender,
            contractAddress:DAOAddress,
            name: _name
        }));
    }

    function getAllDAOs() external view returns(DAO[] memory){
        return DAOs;
    }
}