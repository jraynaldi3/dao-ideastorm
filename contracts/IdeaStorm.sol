//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract IdeaStorm is Ownable {

    event TopicSubmitted(uint id, string title);
    event TopicClosed(uint id);
    event IdeaSubmitted(uint topicId, uint ideaId, address submitter, string idea);
    event IdeaUpvoted(uint topicId, uint ideaId, address voter);
    event IdeaDownvoted(uint topicId, uint ideaId, address voter);

    error AlreadyVote();

    using Counters for Counters.Counter;
    Counters.Counter topicIds;
    mapping(uint=>Counters.Counter) ideaIds;

    struct Idea {
        uint id;
        address submitter;
        string idea;
        int vote;
    }

    struct Topic {
        uint id;
        string title;
        string description;
        bool isClosed;
    }

    enum Vote{
        Novote,
        Upvote,
        Downvote
    }

    enum NFT{
        NFT721,
        NFT1155
    }

    NFT public nftType;
    uint public nftId;
    address public linkedNFT;

    Topic[] topics;
    mapping(uint=>mapping(uint=>mapping(address=>Vote))) public voteOfAddress;
    mapping(uint=> Idea[]) public ideasOfTopic;
    

    modifier onlyHolder(){
        if (nftType == NFT.NFT1155){
            require(IERC1155(linkedNFT).balanceOf(msg.sender, nftId)>0,"not a NFT Holder");
        } 
        if (nftType == NFT.NFT721){
            require(IERC721(linkedNFT).balanceOf(msg.sender)>0, "Not a NFT Holder");
        }
        _;
    }

    modifier openTopic(uint id){
        Topic memory topic = getTopicById(id);
        require(topic.isClosed ==false,"IdeaStorm: Topic Already Closed");
        _;
    }

    constructor (
        address _linkedNFT,
        uint _nftType,
        uint _nftId,
        address creator
    ){
        changeLinkedNFT(_linkedNFT,_nftType,_nftId);
        transferOwnership(creator);
    }

    function submitTopic(string memory title, string memory description) external onlyOwner(){
        uint id = topicIds.current();
        topics.push(Topic({
            id: id,
            title: title,
            description: description,
            isClosed:false
        }));
        topicIds.increment();
        emit TopicSubmitted(id, title);
    }

    function closeTopic(uint id) external onlyOwner(){
        Topic storage topic = topics[id];
        topic.isClosed = true;
        emit TopicClosed(id);
    }

    function getTopicById(uint _id) internal view returns(Topic memory) {
        uint index;
        for(uint i = 0; i < topics.length; i++){
            if(topics[i].id == _id){
                index = i;
                break;
            }
        }
        Topic memory topic = topics[index];
        return topic;
    }

    function submitIdea(uint topicId,string memory _idea) external onlyHolder() openTopic(topicId){
        
        uint newIdeaId = ideaIds[topicId].current();
        ideasOfTopic[topicId].push(Idea({
            id: newIdeaId,
            submitter: msg.sender,
            idea: _idea,
            vote: 0
        }));

        ideaIds[topicId].increment();
        emit IdeaSubmitted(topicId, newIdeaId, msg.sender, _idea);
    }

    function getIdeaById(uint topicId, uint ideaId) external view returns(Idea memory){
        uint index;
        for(uint i = 0; i > ideasOfTopic[topicId].length;i++){
            if(ideasOfTopic[topicId][i].id == ideaId){
                index = i;
                break;
            }
        }
        Idea storage idea = ideasOfTopic[topicId][index];
        return idea;
    }

    function upvoteIdea(uint topicId, uint ideaId) external onlyHolder() openTopic(topicId){
        Idea storage idea = ideasOfTopic[topicId][ideaId];
        if(voteOfAddress[topicId][ideaId][msg.sender]==Vote.Upvote){
            revert AlreadyVote();
        }
        if(voteOfAddress[topicId][ideaId][msg.sender]==Vote.Downvote){
            idea.vote++;
        }
        voteOfAddress[topicId][ideaId][msg.sender] = Vote.Upvote;
        idea.vote++;
        emit IdeaUpvoted(topicId, ideaId, msg.sender);
    }

    function downvoteIdea(uint topicId, uint ideaId) external onlyHolder() openTopic(topicId){
        Idea storage idea = ideasOfTopic[topicId][ideaId];
        if(voteOfAddress[topicId][ideaId][msg.sender]==Vote.Downvote){
            revert AlreadyVote();
        }
        if(voteOfAddress[topicId][ideaId][msg.sender]==Vote.Upvote){
            idea.vote--;
        }
        voteOfAddress[topicId][ideaId][msg.sender] = Vote.Downvote;
        idea.vote--;
        emit IdeaDownvoted(topicId, ideaId, msg.sender);
    }

    function changeLinkedNFT(address _nftAddress, uint _nftId, uint _nftType) public onlyOwner(){
        linkedNFT = _nftAddress;
        nftId = _nftId;
        nftType = NFT(_nftType);
    }

    

    function getAllTopics() external view returns(Topic[] memory){
        return topics;
    }

    function getIdeasOfTopic(uint topicId) external view returns(Idea[] memory){
        return ideasOfTopic[topicId];
    }

    
}
