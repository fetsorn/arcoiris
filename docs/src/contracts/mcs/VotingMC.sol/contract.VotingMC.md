# VotingMC
[Git Source](https://github.com/fetsorn/arcoiris/blob/d0f67eb60567b86d8beac180c1a7eb8942f4bbfc/contracts/mcs/VotingMC.sol)

**Author:**
Anton Davydov


## State Variables
### arcoiris
The Arcoíris contract


```solidity
Arcoiris arcoiris;
```


### pollCounter
The number of created polls


```solidity
uint256 public pollCounter;
```


### polls
Indexed map of poll structs


```solidity
mapping(uint256 => Poll) internal polls;
```


## Functions
### onlyPoller

Only allows functions if msg.sender is the organizer of the poll


```solidity
modifier onlyPoller(uint256 pollID);
```

### constructor


```solidity
constructor(address _arcoiris);
```

### getGatheringID

Get ID of the gathering associated with a poll


```solidity
function getGatheringID(uint256 pollID) external view returns (uint256 gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of a poll|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of a gathering|


### getCeremonyID

Get ID of the ceremony associated with a poll


```solidity
function getCeremonyID(uint256 pollID) external view returns (uint256 ceremonyID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of a poll|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ceremonyID`|`uint256`|The index of a ceremony|


### createPoll

Create a poll and a redistribution ceremony


```solidity
function createPoll(uint256 gatheringID) external returns (uint256 pollID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of the new poll|


### beginVoting

End collection and start accepting votes


```solidity
function beginVoting(uint256 pollID) external onlyPoller(pollID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of the poll|


### vote

Place a vote for priority of each ceremony member


```solidity
function vote(uint256 pollID, Mission[] memory votes) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of the poll|
|`votes`|`Mission[]`|Votes on priority of each ceremony member|


### completePoll

Redistribute wealth according to voting results


```solidity
function completePoll(uint256 pollID) external onlyPoller(pollID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollID`|`uint256`|The index of the poll|


## Events
### CreatePoll
Emits when a new poll is created


```solidity
event CreatePoll(uint256 indexed pollID, uint256 indexed gatheringID, uint256 indexed ceremonyID, address poller);
```

### BeginVoting
Emits when the collection ends and voting begins


```solidity
event BeginVoting(uint256 indexed pollID);
```

### Vote
Emits when the voting ends and wealth is redistributed


```solidity
event Vote(uint256 indexed pollID, address indexed voter, Mission[] votes);
```

### CompletePoll
Emits when the voting ends and wealth is redistributed


```solidity
event CompletePoll(uint256 indexed pollID);
```

## Structs
### Poll
Information about a poll


```solidity
struct Poll {
    uint256 gatheringID;
    uint256 ceremonyID;
    address poller;
    mapping(address => bool) isEligibleVoter;
    address[] voters;
    mapping(address => Mission[]) votes;
    mapping(address => uint256) points;
}
```

