pragma solidity ^0.8.0;

library NFTProject {
    struct Project {
        uint24 _maxSupply;
        bool _active;
        bool _paused;
        string _name;
        string _creator;
        address _creatorAddr;
        string _desc;
        ProjectSocial _social;
        mapping(uint256 => string) scripts;
        uint256[] scriptIndex;
    }

    struct ProjectSocial {
        string _web;
        string _twitter;
        string _discord;
        string _medium;
        string _instagram;
    }

    struct ProjectData {
        uint256 _projectId;
        uint24 _index;
        uint24 _maxSupply;
        bool _active;
        bool _paused;
        string _creator;
        address _creatorAddr;
    }
}
