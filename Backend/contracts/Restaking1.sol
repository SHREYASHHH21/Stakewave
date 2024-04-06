// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Mytoken.sol";
import "./Mytoken1.sol";

contract Restaking1 {
    Mytoken public myToken;
    Mytoken1 public anotherToken;
    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount,uint256 indexed timestamp);
    event RewardsClaimed(address indexed user, uint256 indexed amount);
    event unboundingPeriodInitiated (address indexed user,uint256 indexed amount, uint256 indexed timestamp )
    uint256 public RewardRate=100;
    uint256 public s_totalSupply;
    uint256 public s_lastUpdateTime; // everytime we call stake,withdraw,claim reward we need to update time;
    uint256 public s_rewardPerTokenStored;
    
    //   uint256 public withdrawTimeStamp;

    struct entry{
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => uint256) s_userStakedAmount;
    mapping(address => uint256) s_rewards;
    mapping(address => uint256) s_userRewardsPerToken_Paid;
    mapping(address => uint256) withdrawTimeStamp;
    mapping (address=>uint256) public StakersBalance;
    mapping(address => entry[]) userData;


    modifier updateReward() {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[msg.sender] = earned(msg.sender);
        s_userRewardsPerToken_Paid[msg.sender] = s_rewardPerTokenStored;
        _;
    }

    error stake__transferFailed();
    error withdraw__transferFailed();
    error claimReward__transferFailed();
    error staking__needMoreThanZero();
    error waitingPeriod_notCompleted();
     error unstakeNot_called();

    constructor(Mytoken _myToken, Mytoken1 _anotherToken) {
        myToken = _myToken;
        anotherToken = _anotherToken;
        s_lastUpdateTime = block.timestamp;

    }


    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_userStakedAmount[account];
        uint256 amountPaid = s_userRewardsPerToken_Paid[account]; // used while claim reward function call
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        return((currentBalance * (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
    }

    function transferTokens(uint256 _amount) public  {
        s_userStakedAmount[msg.sender] =
        s_userStakedAmount[msg.sender] + _amount;
        s_totalSupply = s_totalSupply + _amount;

        // myToken.mint(address(this), _amount);
        // myToken.burn(msg.sender, _amount);
        try myToken.transfer(address(this),_amount){
            emit Staked (msg.sender,_amount);
        }catch{
            revert (stake__transferFailed("not enough LST!!!"))
        }
        anotherToken.mint(msg.sender, _amount);
    }

    function rewardPerTokenUpdate() public returns (uint256){
        s_rewardPerTokenStored=s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * RewardRate * 1e18) /
                s_totalSupply);
                return s_rewardPerTokenStored;
        s_lastUpdateTime = block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime) * RewardRate * 1e18) / s_totalSupply);
    } 

 
    function unstake(uint256 amount) public {
        require(s_userStakedAmount[msg.sender] >=0, "No amount staked");
        s_userStakedAmount[msg.sender] =
                s_userStakedAmount[msg.sender] -
                amount;
        userData[msg.sender].push(entry(block.timestamp,amount));    
        emit unboundingPeriodInitiated(msg.sender, amount,block.timestamp);
    }

    function withdraw(uint256 requiredTimestamp)
    external
    updateReward()
        // needMoreThanZero()
        
    {   
        mapping(address => entry[]) memory user=userData;
        entry[] memory temp;
        for(uint256 i =0 ; i < user[msg.sender].size(); i++ ){
            uint256 memory timestamp=user[msg.sender][i].timestamp;
            uint256 memory amount = user[msg.sender][i].amount;
        if( timestamp-block.timestamp>=1000 & requiredTimestamp == timestamp){
        try anotherToken.burn(msg.sender, amount) {
            emit WithdrewStake(msg.sender, amount, block.timestamp); 
            withdrawTimeStamp[msg.sender] = block.timestamp;
            s_totalSupply = s_totalSupply - amount;
            // emit WithdrewStake(msg.sender, amount);
            rewardPerToken=rewardPerToken();
            amount=(amount * rewardPerToken) + amount;
            myToken.mint(msg.sender, amount);
            emit RewardsClaimed(msg.sender,amount);
        } catch (error) {
            temp.push(entry(timestamp,amount));
            revert("not enough LRT"); 
        }
        }
        else{
            temp.push(entry(timestamp,amount));
        }
        }
            user[msg.sender]=temp;
    }

    function getAnotherTokenBalance() public  view returns (uint256) {
        return myToken.balanceOf(address(this));
    }
    function mintTokensForStacker(uint256 amount) public  {
            myToken.mint(msg.sender, amount);
    }
    function getTotalSupply() public view returns(uint256){
        return s_totalSupply;
    }
     function getRewardsPerTokenShared() public view returns(uint256){
        return s_rewardPerTokenStored;
    }
     function getUserBalance() public view returns(uint256){
        return s_userStakedAmount[msg.sender];
    }

     function getUserRewardsPerToken() public view returns(uint256){
        return s_userRewardsPerToken_Paid[msg.sender];
    }

    function getCurrentTimestamp() public view returns(uint256){
        return block.timestamp;
    }
}