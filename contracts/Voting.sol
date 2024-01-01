// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

contract Voting {
    enum ElectionState {
        NotStarted,
        InProgress,
        Ended
    }

    struct CandidateInfo {
        uint256 id;
        string candidateName;
        uint256 voteCount;
    }

    address public contractOwner;
    ElectionState public electionState;

    struct VoterInfo {
        uint256 id;
        string voterName;
    }

    mapping(uint256 => CandidateInfo) candidatesInfo;
    mapping(address => bool) hasVoted;
    mapping(address => bool) isRegisteredVoter;

    uint256 public totalCandidates = 0;
    uint256 public totalVoters = 0;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call this function");
        _;
    }

    modifier onlyVoter() {
        require(isRegisteredVoter[msg.sender], "Only registered voters can call this function");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        electionState = ElectionState.NotStarted;
        addCandidate("Alice");
        addCandidate("John");
        registerVoter(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        registerVoter(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        registerVoter(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
    }

    event Voted(uint256 indexed candidateId);

    function initiateElection() public onlyOwner{
        require(electionState == ElectionState.NotStarted);
        electionState = ElectionState.InProgress;
    }

    function concludeElection() public onlyOwner{
        require(electionState == ElectionState.InProgress);
        electionState = ElectionState.Ended;
    }

    function addCandidate(string memory _name) public onlyOwner{
        require(
            electionState == ElectionState.NotStarted,
            "Election has already started"
        );

        candidatesInfo[totalCandidates] = CandidateInfo(totalCandidates, _name, 0);
        totalCandidates++;
    }

    function registerVoter(address _voter) public onlyOwner{
        require(!isRegisteredVoter[_voter], "Voter already added");
        require(
            electionState == ElectionState.NotStarted,
            "Voter can't be added after election started"
        );

        isRegisteredVoter[_voter] = true;
        totalVoters++;
    }

    function castVote(uint256 _candidateId) public onlyVoter{
        require(
            electionState == ElectionState.InProgress,
            "Election is not in progress"
        );
        require(!hasVoted[msg.sender], "You have already voted");
        require(
            _candidateId >= 0 && _candidateId < totalCandidates,
            "Invalid candidate ID"
        );

        candidatesInfo[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;

        emit Voted(_candidateId);
    }

    function getCandidateDetails(uint256 _candidateId)
        public
        view
        returns (string memory)
    {
        require(
            _candidateId >= 0 && _candidateId < totalCandidates,
            "Invalid candidate ID"
        );
        return (
            candidatesInfo[_candidateId].candidateName
        );
    }

    function getResult() public view returns (uint256[] memory, string[] memory, uint256[] memory) {
        uint256[] memory candidateIds = new uint256[](totalCandidates);
        string[] memory candidateNames = new string[](totalCandidates);
        uint256[] memory voteCounts = new uint256[](totalCandidates);

        require(
            electionState == ElectionState.Ended,
            "Election has not ended yet"
        );

        for (uint256 i = 0; i < totalCandidates; i++) {
            candidateIds[i] = i;
            candidateNames[i] = candidatesInfo[i].candidateName;
            voteCounts[i] = candidatesInfo[i].voteCount;
        }

        return (candidateIds, candidateNames, voteCounts);
    }

    function checkUserRole(address _current) public view returns (string memory) {
        if (contractOwner == _current) {
            return "Owner";
        } else if (isRegisteredVoter[_current]) {
            return "Registered Voter";
        } else {
            return "Non-Registered Voter";
        }
    }

    // Convert ElectionState to string
    function getElectionState() public view returns (string memory) {
        if (electionState == ElectionState.NotStarted) {
            return "Not Started";
        } else if (electionState == ElectionState.InProgress) {
            return "In Progress";
        } else {
            return "Ended";
        }
    }
}