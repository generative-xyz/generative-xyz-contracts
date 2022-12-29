pragma solidity ^0.8.0;

library NFTProject {
    event CompleteProject(uint256 indexed projectId, uint256 indexed time);
    event UpdateProjectSocial(uint256 indexed projectId, ProjectSocial data);
    event UpdateProjectName(uint256 indexed projectId, string indexed data);
    event UpdateProjectLicense(uint256 indexed projectId, string indexed data);
    event UpdateProjectCreatorName(uint256 indexed projectId, string indexed data);
    event SetProjectStatus(uint256 indexed projectId, bool indexed enable);

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
        string[] _scriptType;// not require
        string[] _scripts;// required
        string _styles;// not require
        uint256 _completeTime;// init = 0
        address _genNFTAddr; // init = 0x0
        string _itemDesc; // not require
        address[] _reserves;// list address for GenerativeNFT.reserveMint
        uint256 _royalty;//% royalty second sale
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
        uint256 _projectId;// parent project id
        uint24 _maxSupply;// max
        uint24 _limit; // limit for not reserve
        uint24 _index;// index for not reserve
        uint24 _indexReserve;// index for reserve
        string _creator;
        uint256 _mintPrice;
        address _mintPriceAddr; // erc20 addr if possible
        string _name;
        ProjectMintingSchedule _mintingSchedule;
        address[] _reserves;
        uint256 _royalty;//% royalty second sale
    }

    struct ProjectMintingSchedule {
        uint256 _initBlockTime; // current block.timestamp of project
        uint256 _openingTime; // time for open minting
    }
}
