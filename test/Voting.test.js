const Voting = artifacts.require("Voting");

contract("Voting", (accounts) => {
  let votingInstance;

  beforeEach(async () => {
    votingInstance = await Voting.new();
  });

  it("should initialize with correct values", async () => {
    const owner = await votingInstance.contractOwner();
    assert.equal(owner, accounts[0], "Owner is not set correctly");

    const state = await votingInstance.electionState();
    assert.equal(state, 0, "Initial state should be NotStarted");
  });

  it("should allow the owner to add candidates", async () => {
    await votingInstance.addCandidate("Alice");
    const candidateName = await votingInstance.getCandidateDetails(0);
    assert.equal(candidateName, "Alice", "Candidate not added successfully");
  });

  it("should allow a registered voter to cast a vote", async () => {
    await votingInstance.registerVoter(accounts[1]);
    await votingInstance.initiateElection();
    await votingInstance.castVote(0, { from: accounts[1] });
    await votingInstance.concludeElection();
  
    // Retrieve the result without destructuring
    const result = await votingInstance.getResult();
  
    // Log the result for debugging
    console.log("Result:", result);
  
    // Assuming 'result' structure: { '0': [BN, BN], '1': ['Alice', 'John'], '2': [BN, BN] }
    // Get the index of 'Alice' in the candidate names array
    const aliceIndex = result['1'].indexOf('Alice');
    
    // Access the corresponding vote count for 'Alice'
    const voteCountForAlice = result['2'][aliceIndex].toNumber();
  
    // Now, you can make your assertion
    assert.equal(voteCountForAlice, 1, "Vote not cast successfully for Alice");
  });

  // Add more tests based on your contract's functions and requirements
});