# Settings
[Git Source](https://github.com/fetsorn/arcoiris/blob/d0f67eb60567b86d8beac180c1a7eb8942f4bbfc/contracts/Settings.sol)

**Inherits:**
[Base](/contracts/Base.sol/contract.Base.md)

**Author:**
Anton Davydov


## Functions
### onlyFocalizer

Only allows functions if msg.sender is focalizer of the gathering


```solidity
modifier onlyFocalizer(uint256 gatheringID);
```

### onlyMutable

Only allows functions if the gathering is mutable


```solidity
modifier onlyMutable(uint256 gatheringID);
```

### setFocalizer

Set address that can change gathering settings


```solidity
function setFocalizer(uint256 gatheringID, address focalizerNew)
    external
    onlyFocalizer(gatheringID)
    onlyMutable(gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`focalizerNew`|`address`|The address of new focalizer|


### setMC

Set address that can organize ceremonies


```solidity
function setMC(uint256 gatheringID, address mcNew) external onlyFocalizer(gatheringID) onlyMutable(gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`mcNew`|`address`|The address of new master of ceremonies|


### setCollection

Set token valid for the gathering


```solidity
function setCollection(uint256 gatheringID, address collectionNew)
    external
    onlyFocalizer(gatheringID)
    onlyMutable(gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`collectionNew`|`address`|The address of new token|


## Events
### SetFocalizer
Emits when a gathering focalizer is changed


```solidity
event SetFocalizer(uint256 indexed gatheringID, address indexed focalizerOld, address indexed focalizerNew);
```

### SetMC
Emits when a master of ceremonies is changed


```solidity
event SetMC(uint256 indexed gatheringID, address indexed mcOld, address indexed mcNew);
```

### SetCollection
Emits when a token valid for gathering is changed


```solidity
event SetCollection(uint256 indexed gatheringID, address indexed collectionOld, address indexed collectionNew);
```

