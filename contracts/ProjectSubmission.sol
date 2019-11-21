pragma solidity ^0.5.0; // Step 1

contract ProjectSubmission { // Step 1
    uint constant public PROJECT_FEE = 1 ether;

    address payable public owner = msg.sender; // Step 1 (state variable)
    uint public ownerBalance; // Step 4 (state variable)
    modifier onlyOwner() { // Step 1
      require(msg.sender == owner, 'Forbidden');
      _;
    }

    struct University { // Step 1
        bool available;
        uint balance;
    }
    mapping(address => University) public universities; // Step 1 (state variable)

    enum ProjectStatus { Waiting, Rejected, Approved, Disabled } // Step 2
    struct Project { // Step 2
        address payable author;
        address payable university;
        ProjectStatus status;
        uint balance;
    }
    mapping(bytes32 => Project) public projects; // Step 2 (state variable)

    function registerUniversity(address payable _universityAddress) public onlyOwner { // Step 1
      University memory newUniversity = University(true, 0);
      universities[_universityAddress] = newUniversity;
    }

    function disableUniversity(address payable _universityAddress) public onlyOwner { // Step 1
      universities[_universityAddress].available = false;
    }

    function submitProject(bytes32 _hash, address payable _university) public payable { // Step 2 and 4
      require(msg.value == PROJECT_FEE, 'Fee required');
      require(universities[_university].available == true, 'Univesity not available');
      Project memory newProject = Project(msg.sender, _university, ProjectStatus.Waiting, 0);
      projects[_hash] = newProject;
      ownerBalance += PROJECT_FEE;
    }

    function disableProject(bytes32 _hash) public onlyOwner { // Step 3
      projects[_hash].status = ProjectStatus.Disabled;
    }

    function reviewProject(bytes32 _hash, ProjectStatus _status) public onlyOwner { // Step 3
      require(projects[_hash].status == ProjectStatus.Waiting, "Project can't be reviewed");
      require(_status == ProjectStatus.Rejected || _status == ProjectStatus.Approved, "Only Rejected or Approved statuses accepted");
      projects[_hash].status = _status;
    }

    function donate(bytes32 _hash) public payable { // Step 4
      require(projects[_hash].status == ProjectStatus.Approved, "Only approved projects can accept donations.");
      projects[_hash].balance += msg.value * 7 / 10;
      universities[projects[_hash].university].balance += msg.value * 2 / 10;
      ownerBalance += msg.value * 1 / 10;
    }

    function withdraw() public { // Step 5
      uint value;
      if(msg.sender == owner) {
        value = ownerBalance;
        ownerBalance = 0;
        owner.transfer(value);
      } else {
        value = universities[msg.sender].balance;
        universities[msg.sender].balance = 0;
        msg.sender.transfer(value);
      }
    }

    function withdraw(bytes32 _hash) public {  // Step 5 (Overloading Function)
      require(msg.sender == projects[_hash].author, "Only the author can withdraw donations.");
      uint value = projects[_hash].balance;
      projects[_hash].balance = 0;
      msg.sender.transfer(value);
    }
}
