pragma solidity ^0.8.0;

library NFTProject {
    struct Project {
        uint24 _maxSupply; // required
        uint24 _limit;// required
        uint256 _mintPrice;// not require
        address _mintPriceAddr; // erc20 addr if possible, not require
        string _name;// required
        string _creator;// required
        address _creatorAddr;// required
        string _license;
        string _desc;// not require
        string _image;// base64 of image
        ProjectSocial _social;// not require
        string _scriptType;// not require
        string[] _scripts;// required
        string _styles;// not require
        uint256 _completeTime;// init = 0
        address _genNFTAddr; // init = 0x0
    }

    struct ProjectSocial {
        string _web;
        string _twitter;
        string _discord;
        string _medium;
        string _instagram;
    }

    struct ProjectMinting {
        address _projectAddr;// parent project addr
        address _projectDataAddr;
        uint256 _projectId;// parent project id
        uint24 _maxSupply;// max
        uint24 _limit; // limit for not reserve
        uint24 _index;// index for not reserve
        uint24 _indexReserve;// index for reserve
        string _creator;
        address _creatorAddr;
        uint256 _mintPrice;
        address _mintPriceAddr; // erc20 addr if possible
    }
}
