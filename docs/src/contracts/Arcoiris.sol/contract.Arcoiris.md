# Arcoiris
[Git Source](https://github.com/fetsorn/arcoiris/blob/d0f67eb60567b86d8beac180c1a7eb8942f4bbfc/contracts/Arcoiris.sol)

**Inherits:**
[Settings](/contracts/Settings.sol/contract.Settings.md)

**Author:**
Anton Davydov


## Functions
### onlyMC

Only allows functions if msg.sender is the master of ceremonies for the gathering


```solidity
modifier onlyMC(uint256 gatheringID);
```

### createGathering

Create a community with common redistribution settings


```solidity
function createGathering(address collection, address redistribution, address mc, bool isMutable)
    external
    returns (uint256 gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The token valid for redistribution|
|`redistribution`|`address`|The contract that implements IRedistribution interface|
|`mc`|`address`|The master of ceremonies|
|`isMutable`|`bool`|True if focalizer can change gathering settings|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of new gathering|


### createCeremony

Create a redistribution ceremony


```solidity
function createCeremony(uint256 gatheringID) external onlyMC(gatheringID) returns (uint256 ceremonyID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ceremonyID`|`uint256`|The index of new ceremony|


### contribute

Transfer token to join the ceremony


```solidity
function contribute(uint256 gatheringID, uint256 ceremonyID, address tokenAddress, uint256 tokenID) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of gathering|
|`ceremonyID`|`uint256`|The index of new ceremony|
|`tokenAddress`|`address`|The ERC721 token contract address|
|`tokenID`|`uint256`|The ERC721 token ID|


### contributeBatch

Transfer several tokens to join the ceremony


```solidity
function contributeBatch(uint256 gatheringID, uint256 ceremonyID, address tokenAddress, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of gathering|
|`ceremonyID`|`uint256`|The index of new ceremony|
|`tokenAddress`|`address`|The IERC721Enumerable token contract address|
|`amount`|`uint256`|The number of tokens to transfer|


### endCollection

Stop accepting contributions for the ceremony


```solidity
function endCollection(uint256 gatheringID, uint256 ceremonyID) external onlyMC(gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of gathering|
|`ceremonyID`|`uint256`|The index of new ceremony|


### redistribute

Invoke redistribution algorithm and transfer shares


```solidity
function redistribute(uint256 gatheringID, uint256 ceremonyID, address[] memory siblings, uint256[] memory priorities)
    external
    onlyMC(gatheringID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of gathering|
|`ceremonyID`|`uint256`|The index of new ceremony|
|`siblings`|`address[]`|The list of ceremony members|
|`priorities`|`uint256[]`|Arbitrary number associated with each ceremony member|


## Events
### CreateGathering
Emits when a redistribution community is created


```solidity
event CreateGathering(
    uint256 indexed gatheringID,
    address indexed focalizer,
    address indexed mc,
    address collection,
    address redistribution,
    bool isMutable
);
```

### CreateCeremony
Emits when a redistribution ceremony is created


```solidity
event CreateCeremony(uint256 indexed gatheringID, uint256 indexed ceremonyID);
```

