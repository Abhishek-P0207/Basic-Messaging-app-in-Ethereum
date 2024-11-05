// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.26;

contract twitter{

    uint16 public Max_Length = 280;  

    // This is a struct to store the content of tweet
    struct Tweet{
        uint256 id;
        address author;
        string content;
        uint256 timeStamp;
        uint256 likes;
    }

    // mapping is used to map an account with the tweets that it done
    mapping (address => Tweet[]) public tweets;

    address public owner;

    // events are like notifications

    event tweetCreated(uint256 id, address author, string content , uint256 timeStamp);
    event tweetLiked(address liker,address tweetAuthor,uint256 tweetId,uint256 newLikeCount);
    event tweetUnlike(address unliker , address tweetAuthor,uint256 tweetId,uint256 newUnlikeCount);

    // constructor is created only when the contract is deployed
    // so msg.sender will be the deployer
    constructor() {
        owner = msg.sender;
    }

    // modifier is used to create extra functionality to functions , like giving access to specific persons
    // "_;" is used to tell compiler that whichever func we use the content of that function will start after this modifier 
    
    modifier onlyOwner(){
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    // we use onlyOwner in this function to restrict the use 
    function changeTweetlength(uint16 newTweetLength) public onlyOwner{
        Max_Length = newTweetLength;
    }

    function createTweet(string memory _tweet) public{
    // Using require we restrict the length of tweet content
    // require is like a if conditional
    require(bytes(_tweet).length <= Max_Length , "Message is too long");

        Tweet memory newTweet = Tweet({
            id : tweets[msg.sender].length,
            author : msg.sender,
            content : _tweet,
            timeStamp : block.timestamp,
            likes : 0
        });

        tweets[msg.sender].push(newTweet);

        // emit uses the event to send the notification in the blockchain

        emit tweetCreated(newTweet.id , newTweet.author , newTweet.content , newTweet.timeStamp);
    }

    // tweets is array of structs
    // so we index to find that specific tweet using author(address of tweet)
    // we then index to which tweet using i
    // now we select the id parameter and update it
    function likeTweet(address author,uint256 i) external{
        // we are trying to see if the tweet which we are trying to access is existing
        require(tweets[author][i].id==i , "No Tweet Available");

        tweets[author][i].likes++;

        emit tweetLiked(msg.sender,author,i,tweets[author][i].likes);
    }

    function dislikeTweet(address author,uint256 i) external{
        // we are trying to see if the tweet which we are trying to access is existing
        require(tweets[author][i].id==i , "No Tweet Available");
        require(tweets[author][i].likes > 0 , "There are No Likes");

        tweets[author][i].likes--;
        emit tweetUnlike(msg.sender,author,i,tweets[author][i].likes);

    }

    // for loops

    function getTotalLikes(address _author) external view returns(uint256){
        uint tLikes;
        for(uint i=0 ;i<tweets[_author].length ; i++){
            tLikes += tweets[_author][i].likes;
        }
        return tLikes;
    }

    function getTweet(address _owner, uint _i) public view returns (Tweet memory){
        return tweets[_owner][_i];
    }

    function getAllTweet(address _owner) public view returns (Tweet[] memory){
        return tweets[_owner];
    }
}