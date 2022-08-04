import { expect } from 'chai';
import { ethers, network, upgrades, waffle } from 'hardhat';
import { arrayify, id } from 'ethers/lib/utils'
import keccak256 from 'keccak256'
import { randomBytes } from 'crypto'
import { utils, Wallet } from 'ethers'
import { MerkleTree } from 'merkletreejs'
import { BimkonEyes } from '../typechain'

describe("MultiSender", (): void => {
    let owner: any;
    let user0: any, team: any, priceManager: any, sellPhaseManager: any, whiteListManager: any, user5: any, user6: any, user7: any, user8: any, user9: any;
    let bimkonEyes: BimkonEyes;
    let root: any;
    let merkleTree: any;
    let signatureChecker: any;
    let minterSignature: any;


    beforeEach(async () => {
        [owner, user0, team, priceManager, sellPhaseManager, whiteListManager, user5, user6, user7, user8, user9] = await ethers.getSigners();
        const SignatureChecker = await ethers.getContractFactory("SignatureChecker");
        signatureChecker = await SignatureChecker.deploy();
        await signatureChecker.deployed();
        const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
        bimkonEyes = await BimkonEyes.deploy(priceManager.address, sellPhaseManager.address, whiteListManager.address, signatureChecker.address);
        await bimkonEyes.deployed();
        const randomAddresses = new Array(15)
            .fill(0)
            .map(() => new Wallet(randomBytes(32).toString('hex')).address)
        merkleTree = new MerkleTree(
            randomAddresses.concat(owner.address),
            keccak256,
            { hashLeaves: true, sortPairs: true }
        )
        root = merkleTree.getHexRoot()
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);


    });

    // it("contract deployed", async () => {
    //     expect(await bimkonEyes.deployed()).to.equal(bimkonEyes);
    //     expect(await bimkonEyes.name()).to.equal("BimkonEyes");
    //     expect(await bimkonEyes.symbol()).to.equal("BYS");
    //     expect(await bimkonEyes.MAX_SUPPLY()).to.equal(2000);
    //     expect(await bimkonEyes.MAX_PUBLIC_MINT()).to.equal(10);
    //     expect(await bimkonEyes.MAX_WHITELIST_MINT()).to.equal(3);
    //     expect(await bimkonEyes.publicSalePrice()).to.equal(ethers.utils.parseEther('1'));
    //     expect(await bimkonEyes.whiteListSalePrice()).to.equal(ethers.utils.parseEther('0.5'));
    //     expect(await bimkonEyes.isRevealed()).to.equal(false);
    //     expect(await bimkonEyes.publicSale()).to.equal(false);
    //     expect(await bimkonEyes.whiteListSale()).to.equal(false);
    //     expect(await bimkonEyes.totalSupply()).to.equal(0);
    // });

    it("should not let mint coz invalid signature", async () => {
        const catHash = await signatureChecker.CAT();
        expect(catHash).to.eq(id('Cat'));
        minterSignature = await owner.signMessage(arrayify(catHash))
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        await expect(bimkonEyes.mint(11, minterSignature)).to.not.be.revertedWith("BimkonEyes :: Invalid Signature.");

        const friendSignature = await user0.signMessage(arrayify(catHash))
        await expect(bimkonEyes.mint(1, friendSignature, { value: ethers.utils.parseEther('5') })).to.be.revertedWith("BimkonEyes :: Invalid Signature.");
    });

    it("should not let mint coz publicSale=false", async () => {
        await expect(bimkonEyes.mint(1, minterSignature)).to.be.revertedWith('BimkonEyes :: Not Yet Active.');
    });

    it("should not let mint coz Beyond Max Supply", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.connect(team).mint(2001, minterSignature)).to.be.revertedWith('BimkonEyes :: Beyond Max Supply');
    });

    it("should not let mint coz Beyond Max public mint", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        const catHash = await signatureChecker.CAT();
        expect(catHash).to.eq(id('Cat'));
        minterSignature = await owner.signMessage(arrayify(catHash))
        await expect(bimkonEyes.mint(11, minterSignature)).to.be.revertedWith('BimkonEyes :: Cant mint more!');
    });

    it("should not let mint coz Beyond Max public mint / duble mint test", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') });
        await bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') });
        await expect(bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') })).to.be.revertedWith('BimkonEyes :: Cant mint more!');
    });

    it("should not let mint coz low sent ether", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.mint(9, minterSignature, { value: ethers.utils.parseEther('0.099') })).to.be.revertedWith('BimkonEyes :: low sent ether');
    });

    it("should  mint nft", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') })).to.not.be.revertedWith('BimkonEyes :: low sent ether');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('5');
    });

    it("should not let mint while whiteListSale = false ", async () => {
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        await expect(bimkonEyes.connect(whiteListManager).whitelistMint(proof, 5)).to.be.revertedWith('BimkonEyes :: Minting is on Pause');
    });

    it("should not let mint while max beyond  supply ", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        const badProof = merkleTree.getHexProof(keccak256(user0.address))
        await expect(bimkonEyes.whitelistMint(badProof, 2001)).to.be.revertedWith("BimkonEyes :: Beyond Max Supply");
    });

    it("should not let mint while beyond max whitelist mint", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const badProof = merkleTree.getHexProof(keccak256(user0.address))
        await expect(bimkonEyes.whitelistMint(badProof, 4)).to.be.revertedWith('BimkonEyes :: Cannot mint beyond whitelist max mint!');
    });

    it("should not let mint while payment is below the price", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const badProof = merkleTree.getHexProof(keccak256(user0.address))
        await expect(bimkonEyes.whitelistMint(badProof, 3, { value: ethers.utils.parseEther('0.5') })).to.be.revertedWith('BimkonEyes :: Payment is below the price');
    });

    it("should not let mint while coz badProof - no in white list", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const badProof = merkleTree.getHexProof(keccak256(user0.address))
        await expect(bimkonEyes.whitelistMint(badProof, 3, { value: ethers.utils.parseEther('1.5') })).to.be.revertedWith('BimkonEyes :: You are not whitelisted');
    });

    it("should mint nft to whitelisted addresses", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        await expect(bimkonEyes.whitelistMint(proof, 3, { value: ethers.utils.parseEther('1.5') })).to.not.be.revertedWith('BimkonEyes :: You are not whitelisted');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
    });

    it("should mint nft to team address", async () => {
        await bimkonEyes.transferOwnership(team.address);
        await bimkonEyes.connect(team).teamMint();
        expect(await bimkonEyes.balanceOf(team.address)).to.eq('200');
    });

    it("claimAirdrop should let claim AirDrop", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleAirDrop();
        await bimkonEyes.connect(whiteListManager).setMerkleRootAirDrop(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        expect(await bimkonEyes.canClaimAirDrop(proof)).to.eq(true);
        await bimkonEyes.claimAirdrop(proof, 2)
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('2');
    });

    it("claimAirdrop should not let claim AirDrop coz of beyond max airdrop quantity", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleAirDrop();
        await bimkonEyes.connect(whiteListManager).setMerkleRootAirDrop(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        expect(await bimkonEyes.canClaimAirDrop(proof)).to.eq(true);
        await expect(bimkonEyes.claimAirdrop(proof, 3)).to.be.revertedWith('BimkonEyes :: Cannot mint beyond airdrop max mint!');
    });

    it("tokenURI method should return placeholderTokenUri when isRevealed=false", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        await expect(bimkonEyes.whitelistMint(proof, 3, { value: ethers.utils.parseEther('1.5') })).to.not.be.revertedWith('BimkonEyes :: You are not whitelisted');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
        await bimkonEyes.setTokenUri('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/')
        await bimkonEyes.setPlaceHolderUri('ipfs://setPlaceHolderUri');
        expect(await bimkonEyes.isRevealed()).to.eq(false);
        expect(await bimkonEyes.tokenURI(0)).to.eq('ipfs://setPlaceHolderUri');
        expect(await bimkonEyes.tokenURI(1)).to.eq('ipfs://setPlaceHolderUri');
        expect(await bimkonEyes.tokenURI(2)).to.eq('ipfs://setPlaceHolderUri');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
    });

    it("tokenURI method should return baseURI when isRevealed=true", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        await expect(bimkonEyes.whitelistMint(proof, 3, { value: ethers.utils.parseEther('1.5') })).to.not.be.revertedWith('BimkonEyes :: You are not whitelisted');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
        await bimkonEyes.setTokenUri('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/')
        await bimkonEyes.setPlaceHolderUri('ipfs://setPlaceHolderUri');
        await bimkonEyes.connect(sellPhaseManager).toggleReveal();
        expect(await bimkonEyes.isRevealed()).to.eq(true);
        expect(await bimkonEyes.tokenURI(0)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/1.json');
        expect(await bimkonEyes.tokenURI(1)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/2.json');
        expect(await bimkonEyes.tokenURI(2)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/3.json');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
    });

    it("tokenURI method should return baseURI when isRevealed=true", async () => {
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList(root);
        const proof = merkleTree.getHexProof(keccak256(owner.address))
        await expect(bimkonEyes.whitelistMint(proof, 3, { value: ethers.utils.parseEther('1.5') })).to.not.be.revertedWith('BimkonEyes :: You are not whitelisted');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
        await bimkonEyes.setTokenUri('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/')
        await bimkonEyes.setPlaceHolderUri('ipfs://setPlaceHolderUri');
        await bimkonEyes.connect(sellPhaseManager).toggleReveal();
        expect(await bimkonEyes.isRevealed()).to.eq(true);
        expect(await bimkonEyes.tokenURI(0)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/1.json');
        expect(await bimkonEyes.tokenURI(1)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/2.json');
        expect(await bimkonEyes.tokenURI(2)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/3.json');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('3');
    });

    it("setPublicSalePrice method set publicSalePrice", async () => {
        expect(await bimkonEyes.publicSalePrice()).to.eq(ethers.utils.parseEther('1'));
        await bimkonEyes.connect(priceManager).setPublicSalePrice(ethers.utils.parseEther('1.5'));
        expect(await bimkonEyes.publicSalePrice()).to.eq(ethers.utils.parseEther('1.5'));
    });

    it("setWhiteListSalePrice method set whiteListSalePrice", async () => {
        expect(await bimkonEyes.whiteListSalePrice()).to.eq(ethers.utils.parseEther('0.5'));
        await bimkonEyes.connect(priceManager).setWhiteListSalePrice(ethers.utils.parseEther('1'));
        expect(await bimkonEyes.whiteListSalePrice()).to.eq(ethers.utils.parseEther('1'));
    });

    it("setTokenUri method set _baseTokenUri", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') })).to.not.be.revertedWith('BimkonEyes :: low sent ether');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('5');
        await bimkonEyes.connect(sellPhaseManager).toggleReveal();

        await bimkonEyes.setTokenUri('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/')
        expect(await bimkonEyes.tokenURI(0)).to.eq('ipfs://QmURNiFVdDrvhqHtDfoFdfGfNxgFsjQCnGbvaUGpqP8qJV/1.json');
    });

    it("setPlaceHolderUri method set placeholderTokenUri", async () => {
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('5') })).to.not.be.revertedWith('BimkonEyes :: low sent ether');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('5');

        await bimkonEyes.setPlaceHolderUri('ipfs://QmURNiFVdDrvhqH/')
        expect(await bimkonEyes.placeholderTokenUri()).to.eq('ipfs://QmURNiFVdDrvhqH/');
    });

    it("setMerkleRootWhiteList method should set _merkleRootWhiteList", async () => {
        await bimkonEyes.connect(whiteListManager).setMerkleRootWhiteList('0x626c756500000000000000000000000000000000000000000000000000000000');
        expect(await bimkonEyes.getMerkleRootWhiteList()).to.equal('0x626c756500000000000000000000000000000000000000000000000000000000');
    });

    it("setMerkleRootAirDrop method should set _merkleRootAirDrop", async () => {
        await bimkonEyes.connect(whiteListManager).setMerkleRootAirDrop('0x626c756500000000000000000000000000000000000000000000000000000000');
        expect(await bimkonEyes.getMerkleRootAirDrop()).to.equal('0x626c756500000000000000000000000000000000000000000000000000000000');
    });

    it("toggleWhiteListSale method toggle whiteListSale", async () => {
        expect(await bimkonEyes.whiteListSale()).to.equal(false);
        await bimkonEyes.connect(sellPhaseManager).toggleWhiteListSale();
        expect(await bimkonEyes.whiteListSale()).to.equal(true);
    });

    it("togglePublicSale method toggle publicSale", async () => {
        expect(await bimkonEyes.publicSale()).to.equal(false);
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
    });

    it("toggleReveal method toggle reveal", async () => {
        expect(await bimkonEyes.isRevealed()).to.equal(false);
        await bimkonEyes.connect(sellPhaseManager).toggleReveal();
        expect(await bimkonEyes.isRevealed()).to.equal(true);
    });

    it("toggleAirDrop method toggle AirDrop", async () => {
        expect(await bimkonEyes.airDrop()).to.equal(false);
        await bimkonEyes.connect(sellPhaseManager).toggleAirDrop();
        expect(await bimkonEyes.airDrop()).to.equal(true);
    });

    it("should withdraw ether from contract to owner", async () => {
        const provider = waffle.provider;
        expect(await provider.getBalance(bimkonEyes.address)).to.eq(0);
        await bimkonEyes.connect(sellPhaseManager).togglePublicSale();
        expect(await bimkonEyes.publicSale()).to.equal(true);
        await expect(bimkonEyes.mint(5, minterSignature, { value: ethers.utils.parseEther('3005') })).to.not.be.revertedWith('BimkonEyes :: low sent ether');
        expect(await bimkonEyes.balanceOf(owner.address)).to.eq('5');
        expect(await provider.getBalance(bimkonEyes.address)).to.eq(ethers.utils.parseEther("3005"));
        await bimkonEyes.withdraw(user0.address, ethers.utils.parseEther("3005"));
        expect(await provider.getBalance(bimkonEyes.address)).to.eq(0);
    });

    it("Multisend should send 721A tokens to addresses ", async () => {
        await bimkonEyes.transferOwnership(team.address);
        await bimkonEyes.connect(team).teamMint();
        expect(await bimkonEyes.balanceOf(team.address)).to.eq('200');
        const usersAddresses = [user0.address, user5.address, user6.address];
        const tokenValues = [10, 20, 30];
        await bimkonEyes.connect(team).setApprovalForAll(bimkonEyes.address, true);
        await bimkonEyes.connect(team).multiSendERC721(bimkonEyes.address, usersAddresses, tokenValues);
        expect(await bimkonEyes.ownerOf(10)).eq(user0.address);
        expect(await bimkonEyes.ownerOf(20)).eq(user5.address);
        expect(await bimkonEyes.ownerOf(30)).eq(user6.address);
        expect(await bimkonEyes.balanceOf(team.address)).eq(197);

    });

});