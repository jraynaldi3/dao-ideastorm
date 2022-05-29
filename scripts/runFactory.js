const main = async()=>{
    const [signer, rand1,rand2] = await hre.ethers.getSigners();
    const factory = await hre.ethers.getContractFactory("IdeaStormFactory");
    const contract = await factory.deploy();
    await contract.deployed()

    console.log("contract deployed to:", contract.address);
    console.log("deployed by:" , signer.address);

    let tx = await contract.createIdeaStorm("GDAO","0x16862d99F549532EfE34E7FA454F8D93F121a35D",0,0);
    await tx.wait();

    let daos = await contract.getAllDAOs();
    console.log(daos)
}

const runMain = async()=>{
    try {
        await main();
        process.exit(0);
    } catch(error){
        console.error(error);
        process.exit(1);
    }
}

runMain();