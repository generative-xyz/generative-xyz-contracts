const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
// const {  } = require("@openzeppelin/hardhat-upgrades");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
require("@nomicfoundation/hardhat-chai-matchers");

// Use chai-as-promised for async assertions
chai.use(chaiAsPromised);

describe("CryptoAI and CryptoAIData", function () {
    // Define contract variables
    let cryptoAI;
    let cryptoAIData;
    let owner;
    let admin;
    let user;

    // Fixture to deploy contracts
    async function deployContractsFixture() {
        // Get signers
        [owner, admin, user] = await ethers.getSigners();

        // Deploy CryptoAIData first using upgrades
        const CryptoAIData = await ethers.getContractFactory("CryptoAIData");
        cryptoAIData = await upgrades.deployProxy(CryptoAIData, [owner.address]);
        await cryptoAIData.deployed();
        console.log("cryptoAIData deployed at", cryptoAIData.address);

        // Deploy CryptoAI using upgrades
        const CryptoAI = await ethers.getContractFactory("CryptoAI");
        cryptoAI = await upgrades.deployProxy(
            CryptoAI,
            ["CryptoAI", "CAI", owner.address]
        );
        await cryptoAI.deployed();
        console.log("cryptoAI deployed at", cryptoAI.address);

        return { cryptoAI, cryptoAIData, owner, admin, user };
    }

    describe("Deployment", function () {
        it("Should deploy both contracts successfully", async function () {
            console.log("deploying contracts ...");
            const { cryptoAI, cryptoAIData } = await loadFixture(
                deployContractsFixture
            );

            expect(cryptoAI.address).to.be.a("string");
            expect(cryptoAIData.address).to.be.a("string");
        });

        it("Should set the correct deployer address", async function () {
            const { cryptoAI, cryptoAIData, owner } = await loadFixture(
                deployContractsFixture
            );

            expect(await cryptoAI._deployer()).to.equal(owner.address);
            expect(await cryptoAIData._deployer()).to.equal(owner.address);
        });
    });

    describe("Configuration", function () {
        it("Should allow deployer to change CryptoAIData address", async function () {
            const { cryptoAI, cryptoAIData, owner, user } = await loadFixture(
                deployContractsFixture
            );

            // Deploy a new CryptoAIData contract
            const CryptoAIData = await ethers.getContractFactory("CryptoAIData");
            const newCryptoAIData = await upgrades.deployProxy(
                CryptoAIData,
                [owner.address]
            );
            await newCryptoAIData.deployed();
            const newCryptoAIDataAddress = await newCryptoAIData.address;
            console.log("newCryptoAIDataAddress", newCryptoAIDataAddress);

            // Change the address
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(newCryptoAIData.address);

            expect(await cryptoAI._cryptoAiDataAddr()).to.equal(
                newCryptoAIData.address
            );
        });

        it("Should not allow non-deployer to change CryptoAIData address", async function () {
            const { cryptoAI, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAI.connect(user).changeCryptoAiDataAddress(user.address)
            ).to.be.rejectedWith("ONLY_DEPLOYER");
        });

        it("Should allow deployer to change CryptoAIAgent address", async function () {
            const { cryptoAIData, owner } = await loadFixture(deployContractsFixture);

            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(owner.address);
            expect(await cryptoAIData._cryptoAIAgentAddr()).to.equal(owner.address);
        });

        it("Should not allow non-deployer to change CryptoAIAgent address", async function () {
            const { cryptoAIData, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAIData.connect(user).changeCryptoAIAgentAddress(user.address)
            ).to.be.rejectedWith("Ownable: caller is not the owner");
        });

        it("Should allow deployer to seal the contract", async function () {
            const { cryptoAIData, owner } = await loadFixture(deployContractsFixture);

            await cryptoAIData.connect(owner).sealContract();

            // Try to change CryptoAIAgent address after sealing (should fail)
            await expect(
                cryptoAIData.connect(owner).changeCryptoAIAgentAddress(owner.address)
            ).to.be.rejectedWith("CONTRACT_SEALED");
        });

        it("Should not allow non-deployer to seal the contract", async function () {
            const { cryptoAIData, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAIData.connect(user).sealContract()
            ).to.be.rejectedWith("Ownable: caller is not the owner");
        });
    });

    describe("Admin and Minting", function () {
        it("Should allow deployer to grant admin privileges", async function () {
            const { cryptoAI, owner, admin } = await loadFixture(
                deployContractsFixture
            );

            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            expect(await cryptoAI._admins(admin.address)).to.be.true;
        });

        it("Should not allow non-deployer to grant admin privileges", async function () {
            const { cryptoAI, user, admin } = await loadFixture(
                deployContractsFixture
            );

            await expect(
                cryptoAI.connect(user).allowAdmin(admin.address, true)
            ).to.be.rejectedWith("ONLY_DEPLOYER");
        });

        it("Should allow admin to mint NFT", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0];
            const codeLanguage = "Solidity";
            const ability = "Smart";
            const pointers = [];
            const depsAgents = [];

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    codeLanguage,
                    ability,
                    pointers,
                    depsAgents
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);
        });

        it("Should not allow non-admin to mint NFT", async function () {
            const { cryptoAI, cryptoAIData, owner, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0];
            const codeLanguage = "Solidity";
            const ability = "Smart";
            const pointers = [];
            const depsAgents = [];

            // Attempt to mint NFT (should fail)
            await expect(
                cryptoAI
                    .connect(user)
                    .mint(
                        user.address,
                        dna,
                        traits,
                        codeLanguage,
                        ability,
                        pointers,
                        depsAgents
                    )
            ).to.be.rejectedWith("ONLY_DEPLOYER");
        });

        it("Should correctly store and retrieve agent properties after minting", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0];
            const codeLanguage = "Solidity";
            const ability = "Smart";
            const pointers = [];
            const depsAgents = [];

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    codeLanguage,
                    ability,
                    pointers,
                    depsAgents
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);

            // Verify agent properties
            expect(await cryptoAI.getCodeLanguage(1)).to.equal(codeLanguage);
            expect(await cryptoAI.getAgentAbility(1)).to.equal(ability);

            expect(await cryptoAI.getCurrentVersion(1)).to.equal(1);
            const code = await cryptoAI.getAgentCode(1, 1);
            expect(code).to.be.equal("");
            expect(code.length).to.be.equal(0);
        });

        it("Should directly publish agent code with nft-owner role", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters with realistic values
            const dna = 12345; // Unique DNA identifier
            const traits = [1, 2, 3, 4, 5]; // Different trait values
            const codeLanguage = "Python"; // Using Python as the code language
            const ability = "Advanced Code Generation"; // Specific ability
            const pointers = [
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000", // Using IPFS (zero address)
                    fileType: 0, // LIBRARY type
                    fileName: "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco" // Example IPFS hash
                },
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000",
                    fileType: 1, // MAIN_SCRIPT type
                    fileName: "QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ"
                }
            ];
            const depsAgents = [
                "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", // Example dependency agent address
                "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
            ];

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    codeLanguage,
                    ability,
                    pointers,
                    depsAgents
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);

            // Verify agent properties
            expect(await cryptoAI.getCodeLanguage(1)).to.equal(codeLanguage);
            expect(await cryptoAI.getAgentAbility(1)).to.equal(ability);

            // Verify version and code
            expect(await cryptoAI.getCurrentVersion(1)).to.equal(1);

            // Verify code pointers and dependencies
            const deps = await cryptoAI.getDepsAgents(1, 1);
            expect(deps).to.have.lengthOf(2);
            expect(deps[0]).to.equal(depsAgents[0]);
            expect(deps[1]).to.equal(depsAgents[1]);

            // Get and verify code (should be IPFS hashes since we used zero address)
            const code = await cryptoAI.getAgentCode(1, 1);
            console.log("code: ", code);
            expect(code).to.include(pointers[0].fileName);
            expect(code).to.include(pointers[1].fileName);

            // Publish agent code
            await cryptoAI.connect(user).publishAgentCode(1, [], depsAgents);
            expect(await cryptoAI.getCurrentVersion(1)).to.equal(2);
            const code2 = await cryptoAI.getAgentCode(1, 2);
            expect(code2).to.be.equal("");
            expect(code2.length).to.be.equal(0);
        });

        it("Should publish agent code with valid signature from NFT owner", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT to user
            const dna = 12345;
            const traits = [1, 2, 3, 4, 5];
            const codeLanguage = "Python";
            const ability = "Code Generation";
            const initialPointers = [];
            const initialDepsAgents = [];

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    codeLanguage,
                    ability,
                    initialPointers,
                    initialDepsAgents
                );

            // Prepare new code pointers and dependencies for publishing
            const newPointers = [
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000",
                    fileType: 0,
                    fileName: "QmNewPointer1"
                }
            ];
            const newDepsAgents = [
                "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
            ];

            // Get current version
            const initialVersion = await cryptoAI.getCurrentVersion(1);

            // Get chain ID for domain
            const chainId = await ethers.provider.getNetwork().then(n => n.chainId);

            // Define domain for EIP-712
            const domain = {
                name: "CryptoAI", // This should match the name used in contract initialization
                version: "1.0",
                chainId: chainId,
                verifyingContract: cryptoAI.address
            };

            // Define types for EIP-712
            const types = {
                SignData: [
                    { name: "pointers", type: "CodePointer[]" },
                    { name: "depsAgents", type: "address[]" },
                    { name: "tokenId", type: "uint256" },
                    { name: "currentVersion", type: "uint16" }
                ],
                CodePointer: [
                    { name: "retrieveAddress", type: "address" },
                    { name: "fileType", type: "uint8" },
                    { name: "fileName", type: "string" }
                ]
            };

            // Create the message to sign
            const message = {
                pointers: newPointers,
                depsAgents: newDepsAgents,
                tokenId: 1,
                currentVersion: Number(initialVersion)
            };

            // Sign the typed data with NFT owner's private key
            const signature = await user._signTypedData(domain, types, message);

            // Publish code with signature
            await cryptoAI.publishAgentCodeWithSignature(1, newPointers, newDepsAgents, signature);

            // Verify the new version was created
            const newVersion = await cryptoAI.getCurrentVersion(1);
            expect(newVersion).to.equal(initialVersion + 1);

            // Verify the new code pointers and dependencies
            const deps = await cryptoAI.getDepsAgents(1, newVersion);
            expect(deps).to.have.lengthOf(1);
            expect(deps[0]).to.equal(newDepsAgents[0]);

            // Try to use the same signature again(should fail)
            // await expect(
            //     cryptoAI.publishAgentCodeWithSignature(1, newPointers, newDepsAgents, signature)
            // ).to.be.rejectedWith("DigestAlreadyUsed");

            // Try to use signature from non-owner (should fail)
            // const nonOwnerSignature = await admin._signTypedData(domain, types, message);
            // await expect(
            //     cryptoAI.publishAgentCodeWithSignature(1, newPointers, newDepsAgents, nonOwnerSignature)
            // ).to.be.rejectedWith("Unauthenticated");
        });
    });
}); 