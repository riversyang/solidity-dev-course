pragma solidity 0.4.24;

contract GasOptimizeSample {
    // The total amount of Ether bet for this current game
    uint public totalBets;
    // Array of players
    address[] public players;
    // Each number has an array of players. Associate each number with a bunch of players
    mapping(uint256 => address[]) numberBetPlayers;
    // The number that each player has bet for
    mapping(address => uint256) playerBetsNumber;
    // The balance that each player owns
    mapping(address => uint256) playerBalances;

    constructor() public {
    }

    function bet(uint256 _betNumber) public payable {
        require(_betNumber > 0 && _betNumber < 11);
        require(players.length < 10);
        require(playerBetsNumber[msg.sender] == 0);
        players.push(msg.sender);
        numberBetPlayers[_betNumber].push(msg.sender);
        playerBetsNumber[msg.sender] = _betNumber;
        totalBets += msg.value;
        if (players.length == 10) {
            distributePrizes1(5);
        }
    }

    function playerBalance() public view returns (uint256) {
        return playerBalances[msg.sender];
    }

    function distributePrizes1(uint256 _numberWinner) private {
        // Calculate winner's balance amount
        uint256 winnerBalance;
        uint i;

        if (numberBetPlayers[_numberWinner].length > 0) {
            winnerBalance = totalBets / numberBetPlayers[_numberWinner].length;
            // Apply rewards
            for (i = 0; i < numberBetPlayers[_numberWinner].length; i++) {
                playerBalances[numberBetPlayers[_numberWinner][i]] += winnerBalance;
            }
        } else {
            winnerBalance = totalBets / players.length;
            // Apply rewards
            for (i = 0; i < players.length; i++) {
                playerBalances[players[i]] += winnerBalance;
            }
        }
        // Delete all the players for each number
        for (uint j = 1; j <= 10; j++) {
            for (uint k = 0; k < numberBetPlayers[j].length; k++) {
                playerBetsNumber[numberBetPlayers[j][k]] = 0;
                numberBetPlayers[j][k] = 0;
            }
            numberBetPlayers[j].length = 0;
        }
        for (i = 0; i < players.length; i++) {
            players[i] = 0;
        }
        players.length = 0;
        totalBets = 0;
    }

    function distributePrizes2(uint256 _numberWinner) private {
        // Calculate winner's balance amount
        uint256 winnerBalance;
        uint256 winnerCount = numberBetPlayers[_numberWinner].length;
        uint i;

        if (winnerCount > 0) {
            winnerBalance = totalBets / winnerCount;
            // 发放奖金
            for (i = 0; i < winnerCount; i++) {
                playerBalances[numberBetPlayers[_numberWinner][i]] += winnerBalance;
            }
            // 清除下注记录
            for (i = 0; i < players.length; i++) {
                playerBetsNumber[players[i]] = 0;
            }
        } else {
            winnerCount = players.length;
            winnerBalance = totalBets / winnerCount;
            // 发放奖金并清除下注记录
            for (i = 0; i < winnerCount; i++) {
                playerBalances[players[i]] += winnerBalance;
                playerBetsNumber[players[i]] = 0;
            }
        }
        // Delete 下注统计
        for (i = 1; i <= 10; i++) {
            delete numberBetPlayers[i];
        }
        delete players;
        totalBets = 0;
    }

}