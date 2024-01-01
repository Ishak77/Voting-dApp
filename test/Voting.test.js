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

  // Add more tests based on your contract's functions and requirements
});