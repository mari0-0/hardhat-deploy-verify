// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./NFTRaffle.sol";

contract NFTRaffleFactory {
    mapping(address => address[]) private usersToNFTRaffles;
    mapping(address => NFTRaffle) public allRaffles;
    event RaffleCreated(address raffleAddress, address creator);

    function createRaffle(uint256 _entryCost, uint256 _maxEntries)
        external
        returns (address)
    {
        NFTRaffle newRaffle = new NFTRaffle(
            _entryCost,
            msg.sender,
            _maxEntries
        );
        usersToNFTRaffles[msg.sender].push(address(newRaffle));
        allRaffles[address(newRaffle)] = newRaffle;
        emit RaffleCreated(address(newRaffle), msg.sender);
        return address(newRaffle);
    }

    function getUserActiveRaffles(address _userAddress)
        public
        view
        returns (address[] memory)
    {
        address[] memory activeRaffles = new address[](
            usersToNFTRaffles[_userAddress].length
        );
        for (uint256 i = 0; i < usersToNFTRaffles[_userAddress].length; i++) {
            address raffle = usersToNFTRaffles[_userAddress][i];
            if (allRaffles[raffle].raffleStatus()) {
                activeRaffles[i] = raffle;
            }
        }
        return activeRaffles;
    }

    function getUserCompletedRaffles(address _userAddress)
        public
        view
        returns (address[] memory)
    {
        address[] memory completedRaffles = new address[](
            usersToNFTRaffles[_userAddress].length
        );
        for (uint256 i = 0; i < usersToNFTRaffles[_userAddress].length; i++) {
            address raffle = usersToNFTRaffles[_userAddress][i];
            if (!allRaffles[raffle].raffleStatus()) {
                completedRaffles[i] = raffle;
            }
        }
        return completedRaffles;
    }
}
