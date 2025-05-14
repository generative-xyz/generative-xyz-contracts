const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
// const {  } = require("@openzeppelin/hardhat-upgrades");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
require("@nomicfoundation/hardhat-chai-matchers");

// Use chai-as-promised for async assertions
chai.use(chaiAsPromised);

// Get Agent contract artifact and interface
const AgentArtifact = require("../artifacts/contracts/nfts/utilities/AgentUpgradeable.sol/AgentUpgradeable.json");

// Helper function to get contract instance from address and ABI
async function getContractInstance(address, abi, signer) {
    if (!address || !abi) {
        throw new Error("Address and ABI are required");
    }
    return new ethers.Contract(address, abi, signer || ethers.provider);
}


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
            const newCryptoAIDataAddress = newCryptoAIData.address;

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
            ).to.be.rejectedWith("103");
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
            ).to.be.revertedWith("103");
        });

        it("Should allow deployer to seal the contract", async function () {
            const { cryptoAIData, owner } = await loadFixture(deployContractsFixture);

            await cryptoAIData.connect(owner).sealContract();

            // Try to change CryptoAIAgent address after sealing (should fail)
            await expect(
                cryptoAIData.connect(owner).changeCryptoAIAgentAddress(owner.address)
            ).to.be.rejectedWith("500");
        });

        it("Should not allow non-deployer to seal the contract", async function () {
            const { cryptoAIData, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAIData.connect(user).sealContract()
            ).to.be.rejectedWith("103");
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
            ).to.be.revertedWith("103");
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
            const agentName = "Test Agent";
            const ability = "Smart";

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    agentName,
                    ability
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);
            expect(await cryptoAI.getAgentName(1)).to.equal(agentName);
            expect(await cryptoAI.getAgentAbility(1)).to.equal(ability);
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
            const agentName = "Test Agent";
            const ability = "Smart";

            // Attempt to mint NFT (should fail)
            await expect(
                cryptoAI
                    .connect(user)
                    .mint(
                        user.address,
                        dna,
                        traits,
                        agentName,
                        ability
                    )
            ).to.be.revertedWith("103");
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
            const agentName = "Test Agent";
            const ability = "Smart";

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    agentName,
                    ability
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);

            // Verify agent properties
            expect(await cryptoAI.getAgentName(1)).to.equal(agentName);
            expect(await cryptoAI.getAgentAbility(1)).to.equal(ability);
            expect(await cryptoAI.getCurrentVersion(1)).to.equal(0);
            expect(await cryptoAI.getCodeLanguage(1)).to.equal("");
            expect(await cryptoAI.getDepsAgents(1, 0)).to.deep.equal([]);
            expect(await cryptoAI.getAgentCode(1, 0)).to.equal("");
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
            const agentName = "Code Generator Agent"; // Agent name
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
                2, // Example dependency agent ID
                3  // Example dependency agent ID
            ];

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    agentName,
                    ability
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);
            expect(await cryptoAI.getAgentName(1)).to.equal(agentName);
            expect(await cryptoAI.getAgentAbility(1)).to.equal(ability);
            expect(await cryptoAI.getCurrentVersion(1)).to.equal(0);
            expect(await cryptoAI.getCodeLanguage(1)).to.equal("");
            expect(await cryptoAI.getDepsAgents(1, 0)).to.deep.equal([]);
            expect(await cryptoAI.getAgentCode(1, 0)).to.equal("");

            await cryptoAI.connect(user).publishAgentCode(1, codeLanguage, pointers, depsAgents);

            // Verify agent properties
            expect(await cryptoAI.getCodeLanguage(1)).to.equal(codeLanguage);
            expect(await cryptoAI.getCurrentVersion(1)).to.equal(1);

            // Verify code pointers and dependencies
            const deps = await cryptoAI.getDepsAgents(1, 1);
            expect(deps).to.have.lengthOf(2);
            expect(deps[0]).to.equal(ethers.BigNumber.from(depsAgents[0]));
            expect(deps[1]).to.equal(ethers.BigNumber.from(depsAgents[1]));

            // Get and verify code (should be IPFS hashes since we used zero address)
            const code = await cryptoAI.getAgentCode(1, 1);
            console.log("code: ", code);
            expect(code).to.include(pointers[0].fileName);
            expect(code).to.include(pointers[1].fileName);
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
            const agentName = "Code Generator Agent";
            const ability = "Code Generation";
            const initialPointers = [];
            const initialDepsAgents = [];

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    dna,
                    traits,
                    agentName,
                    ability
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
                2 // Example dependency agent ID
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
                    { name: "depsAgents", type: "uint256[]" },
                    { name: "agentId", type: "uint256" },
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
                agentId: 1,
                currentVersion: Number(initialVersion)
            };

            // Sign the typed data with NFT owner's private key
            const signature = await user._signTypedData(domain, types, message);

            // Publish code with signature
            await cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, signature);

            // Verify the new version was created
            const newVersion = await cryptoAI.getCurrentVersion(1);
            expect(newVersion).to.equal(initialVersion + 1);

            // Verify the new code pointers and dependencies
            const deps = await cryptoAI.getDepsAgents(1, newVersion);
            expect(deps).to.have.lengthOf(1);
            expect(deps[0]).to.equal(ethers.BigNumber.from(newDepsAgents[0]));

            // Try to use the same signature again(should fail)

            // await expect(
            //     cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, signature)
            // ).to.be.rejectedWith("DigestAlreadyUsed");

            // Try to use signature from non-owner (should fail)
            const nonOwnerSignature = await admin._signTypedData(domain, types, message);
            await expect(
                cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, nonOwnerSignature)
            ).to.be.rejectedWith("Unauthenticated");
        });

        it("Should allow NFT owner to update agent name", async function () {
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

            // Mint NFT
            const initialName = "Initial Agent";
            const ability = "Code Generation";
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    initialName,
                    ability
                );

            // Verify initial name
            expect(await cryptoAI.getAgentName(1)).to.equal(initialName);

            // Update name
            const newName = "Updated Agent Name";
            await cryptoAI.connect(user).updateAgentName(1, newName);

            // Verify updated name
            expect(await cryptoAI.getAgentName(1)).to.equal(newName);
        });

        it("Should not allow non-owner to update agent name", async function () {
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

            // Mint NFT
            const initialName = "Initial Agent";
            const ability = "Code Generation";
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    initialName,
                    ability
                );

            // Try to update name as non-owner (should fail)
            const newName = "Updated Agent Name";

            await expect(
                cryptoAI.connect(admin).updateAgentName(1, newName)
            ).to.be.rejectedWith("Unauthenticated");

            // Verify name remains unchanged
            expect(await cryptoAI.getAgentName(1)).to.equal(initialName);
        });
    });

    describe("Rating System", function () {
        it("Should allow users to rate an agent", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses and mint an NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    "Test Agent",
                    "Code Generation"
                );

            // Rate the agent
            await cryptoAI.connect(user).rateStar(1, 5);

            // Verify rating
            expect(await cryptoAI.getRatingScore(1)).to.equal(500); // 5.00 * 100
            expect(await cryptoAI.getRatingCount(1)).to.equal(1);
        });

        it("Should allow users to update their rating", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    "Test Agent",
                    "Code Generation"
                );

            // Initial rating
            await cryptoAI.connect(user).rateStar(1, 3);

            // Update rating
            await cryptoAI.connect(user).rateStar(1, 4);

            // Verify updated rating
            expect(await cryptoAI.getRatingScore(1)).to.equal(350n); // 4.00 * 100
            expect(await cryptoAI.getRatingCount(1)).to.equal(2);
        });

        it("Should not allow rating outside valid range", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    "Test Agent",
                    "Code Generation"
                );

            // Try to rate with invalid values
            await expect(cryptoAI.connect(user).rateStar(1, 0)).to.be.rejectedWith("RatingOutOfRange");
            await expect(cryptoAI.connect(user).rateStar(1, 6)).to.be.rejectedWith("RatingOutOfRange");
        });

        it("Should calculate average rating correctly with multiple ratings", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    "Code Generation",
                    "Code Generation"
                );

            // Get additional signers for multiple ratings
            const [, , , rater1, rater2, rater3] = await ethers.getSigners();

            // Multiple users rate the agent
            await cryptoAI.connect(user).rateStar(1, 5);
            await cryptoAI.connect(rater1).rateStar(1, 4);
            await cryptoAI.connect(rater2).rateStar(1, 3);
            await cryptoAI.connect(rater3).rateStar(1, 5);

            // Verify average rating (5 + 4 + 3 + 5) / 4 = 4.25
            expect(await cryptoAI.getRatingScore(1)).to.equal(425n); // 4.25 * 100
            expect(await cryptoAI.getRatingCount(1)).to.equal(4n);
        });

        it("Should return 0 for rating score when no ratings exist", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5],
                    "Code Generation",
                    "Code Generation"
                );

            // Verify initial state
            expect(await cryptoAI.getRatingScore(1)).to.equal(0);
            expect(await cryptoAI.getRatingCount(1)).to.equal(0);
        });
    });
    describe("Minting 10.000 NFTs", function () {
        it.skip("Should mint 10.000 NFTs", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );
            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAiDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Create array with 10000 elements
            const nftArray = Array.from({ length: 10000 }, (_, i) => i + 1);
            const dna = 12345;
            const agentName = "Test Agent";
            const ability = "Code Generation";

            for await (let i of nftArray) {
                console.log("Minting NFT ", i);
                const traits = Array(5).fill(0).map(() => Math.floor(Math.random() * 100) + 1);
                await cryptoAI.connect(admin).mint(user.address, dna, traits, agentName, ability);
            }
            expect(await cryptoAI.balanceOf(user.address)).to.equal(10000);
        });
    });
}); 