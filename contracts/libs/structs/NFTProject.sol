pragma solidity ^0.8.0;

library NFTProject {
    struct Project {
        uint24 _maxSupply; // required
        uint24 _limit;// required
        uint256 _mintPrice;
        string _name;// required
        string _creator;// required
        address _creatorAddr;// required
        string _desc;
        string _image;// base64 of image
        ProjectSocial _social;
        string[] scripts;// required
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

    struct ProjectURIContext {
        string script;
        string imageURI;
        string animationURI;
        string name;
    }
}
