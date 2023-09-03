# Base
[Git Source](https://github.com/fetsorn/arcoiris/blob/d0f67eb60567b86d8beac180c1a7eb8942f4bbfc/contracts/Base.sol)

**Inherits:**
IERC721Receiver

**Author:**
Anton Davydov


## State Variables
### gatheringCounter
The number of created gatherings


```solidity
uint256 internal gatheringCounter;
```


### gatherings
Indexed map of gathering structs


```solidity
mapping(uint256 => Gathering) internal gatherings;
```


### VERSION
Version of the contract, bumped on each deployment


```solidity
string public constant VERSION = "0.0.1";
```


## Functions
### getGatheringCounter

Get the number of created gatherings


```solidity
function getGatheringCounter() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The number of created gatherings|


### getFocalizer

Get the address of the creator of the gathering


```solidity
function getFocalizer(uint256 gatheringID) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The creator of the gathering|


### getCollection

Get the address of the token valid for the gathering


```solidity
function getCollection(uint256 gatheringID) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The token valid for the gathering|


### getMC

Get the address of the master of ceremonies for the gathering


```solidity
function getMC(uint256 gatheringID) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The master of ceremonies for the gathering|


### getIsMutable

Get true if focalizer can change gathering settings


```solidity
function getIsMutable(uint256 gatheringID) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if focalizer can change gathering settings|


### getContributors

Get the list of ceremony members


```solidity
function getContributors(uint256 gatheringID, uint256 ceremonyID) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`ceremonyID`|`uint256`|The index of the ceremony|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|The list of ceremony members|


### getContributions

Get the list of token IDs contributed to the ceremony


```solidity
function getContributions(uint256 gatheringID, uint256 ceremonyID) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`ceremonyID`|`uint256`|The index of the ceremony|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|The list of token IDs contributed to the ceremony|


### getIsCollectionEnded

Get true if collection of contributions for the ceremony has stopped


```solidity
function getIsCollectionEnded(uint256 gatheringID, uint256 ceremonyID) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gatheringID`|`uint256`|The index of the gathering|
|`ceremonyID`|`uint256`|The index of the ceremony|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if collection of contributions for the ceremony has stopped|


### onERC721Received

Callback to support ERC721 safeTransferFrom


```solidity
function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external
    pure
    returns (bytes4);
```

## Structs
### Gathering
Information about a redistribution community


```solidity
struct Gathering {
    address focalizer;
    bool isMutable;
    address collection;
    IRedistribution redistribution;
    address mc;
    uint256 ceremonyCounter;
    mapping(uint256 => Ceremony) ceremonies;
}
```

### Ceremony
Information about a redistribution ceremony


```solidity
struct Ceremony {
    bool isCollectionEnded;
    uint256[] contributions;
    address[] contributors;
}
```

