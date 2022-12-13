pragma solidity ^0.8.0;

library NFTProject {
    struct Project {
        uint24 _maxSupply;
        uint24 _limit;
        bool _active;
        bool _paused;
        string _name;
        string _creator;
        address _creatorAddr;
        string _desc;
        ProjectSocial _social;
        mapping(uint256 => string) scripts;
        uint256[] scriptIndex;
        uint256 _completeTime;
        address _genNFTAddr;
    }

    struct ProjectSocial {
        string _web;
        string _twitter;
        string _discord;
        string _medium;
        string _instagram;
    }

    struct ProjectData {
        address _projectAddr;// parent project addr
        uint256 _projectId;// parent project id
        uint24 _index;// index for not reserve
        uint24 _limit; // limit for not reserve
        uint24 _indexReserve;// index for reserve
        uint24 _maxSupply;// max
        bool _active;// 1st priority status
        bool _paused;// 2st priority status
        string _creator;
        address _creatorAddr;
    }
}
