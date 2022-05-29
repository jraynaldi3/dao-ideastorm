const main = async()=>{
    const [signer, rand1,rand2] = await hre.ethers.getSigners();
    const factory = await hre.ethers.getContractFactory("IdeaStorm");
    const contract = await factory.deploy("0x16862d99F549532EfE34E7FA454F8D93F121a35D",0,0);
    await contract.deployed()

    console.log("contract deployed to:", contract.address);
    console.log("deployed by:" , signer.address);

    let tx = await contract.submitTopic("lala","lolo");
    await tx.wait();

    let topics = await contract.getAllTopics();
    console.log(topics);

    tx = await contract.submitIdea(0,"korokoro");
    await tx.wait()

    tx = await contract.upvoteIdea(0,0);
    await tx.wait()

    tx = await contract.downvoteIdea(0,0);
    await tx.wait()

    let ideas = await contract.getIdeasOfTopic(0);
    console.log(ideas);


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