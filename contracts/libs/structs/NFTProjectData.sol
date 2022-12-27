pragma solidity ^0.8.0;

library NFTProjectData {
    struct TokenURIContext {
        string _name;
        string _desc;
        string _baseURI;
        string _animationURI;
        string _image;
    }

    struct ProjectURIContext {
        string _creator;
        address _creatorAddr;
        string _name;
        string _image;
        string _desc;
        string _animationURI;
        address _genNFTAddr;
        string _attributes;
    }
}
