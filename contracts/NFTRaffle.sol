// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract NFTRaffle {
    address public owner;
    mapping(address => uint256) public entryCount;
    address[] public players;
    address[] private playerSelector; //will be using this only in the contract
    bool public raffleStatus;
    uint256 public entryCost;
    address public nftAddress;
    uint256 public nftId;
    uint256 public totalEntries;
    uint256 public maxEntries;
    address public winner;

    event NewEntry(address player);
    event RaffleStarted();
    event RaffleEnded();
    event WinnerSelected(address winner);
    event EntryCostChanged(uint256 newCost);
    event NFTPrizeSet(address nftAddress, uint256 nftId);
    event BalanceWithdrawn(uint256 amount);
    event RaffleCancelled();

    constructor(uint256 _entryCost, address _owner, uint256 _maxEntries) {
        owner = _owner;
        entryCost = _entryCost;
        maxEntries = _maxEntries;
        raffleStatus = false;
        totalEntries = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this contract");
        _;
    }


    function raffleStarted(address _nftAddress, uint256 _nftId)
        external 
        onlyOwner
    {
        require(!raffleStatus, "Raffle is already started");
        require(
            nftAddress == address(0),
            "NFT prize is already set. Please select the winner"
        );
        require(
            ERC721Base(_nftAddress).ownerOf(_nftId) == owner,
            "Owner does not own the NFT"
        );

        nftAddress = _nftAddress;
        nftId = _nftId;
        raffleStatus = true;
        ERC721Base(nftAddress).transferFrom(owner, address(this), nftId);
        emit RaffleStarted();
        emit NFTPrizeSet(_nftAddress, _nftId);
    }

    function isPlayer(address _player) public view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == _player) {
                return true;
            }
        }
        return false;
    }

    function buyEntry(uint256 _numberOfEntries) public payable {
        require(raffleStatus, "Raffle has not started");
        require(
            msg.value == entryCost * _numberOfEntries,
            "Incorrect amount sent"
        );
        require(totalEntries + _numberOfEntries <= maxEntries, "The number of tickets purchased exceeds the remaining tickets available for the raffle.");

        entryCount[msg.sender] += _numberOfEntries;
        totalEntries += _numberOfEntries;

        if (!isPlayer(msg.sender)) {
            players.push(msg.sender);
        }

        for (uint256 i = 0; i < _numberOfEntries; i++) {
            playerSelector.push(msg.sender);
        }

        if (totalEntries >= maxEntries) {
            selectWinner();
        }

        emit NewEntry(msg.sender);
    }

    function endRaffle() private onlyOwner {
        require(raffleStatus, "Raffle is not started");
        raffleStatus = false;
        emit RaffleEnded();
    }

    function selectWinner() public onlyOwner {
        endRaffle();
        require(totalEntries > 0, "No entries in the raffle");
        require(nftAddress != address(0), "NFT Prize not set");

        uint256 winnerIndex = random() % playerSelector.length;
        winner = playerSelector[winnerIndex];

        ERC721Base(nftAddress).transferFrom(address(this), winner, nftId);
        emit WinnerSelected(winner);
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    function changeEntryCost(uint256 _newEntryCost) external onlyOwner {
        require(!raffleStatus, "Cant be changed when raffle is running");
        entryCost = _newEntryCost;
        emit EntryCostChanged(_newEntryCost);
    }

    function withdrawBalance() external onlyOwner {
        require(raffleStatus == false, "Cannot withdraw until raffle is closed");

        payable(owner).transfer(address(this).balance);
        emit BalanceWithdrawn(address(this).balance);
    }

    function getPlayer() public view returns (address[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function cancelRaffle() external onlyOwner {
        endRaffle();

        // Refund all players
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 amount = entryCount[player] * entryCost;
            if (amount > 0) {
                payable(player).transfer(amount);
                entryCount[player] = 0; // Reset entry count for the player
            }
        }

        // Return the NFT to the owner
        if (
            nftAddress != address(0) &&
            ERC721Base(nftAddress).ownerOf(nftId) == address(this)
        ) {
            ERC721Base(nftAddress).transferFrom(address(this), owner, nftId);
        }

        emit RaffleCancelled();
    }
}