# Even
[Git Source](https://github.com/fetsorn/arcoiris/blob/d0f67eb60567b86d8beac180c1a7eb8942f4bbfc/contracts/redistributions/Even.sol)

**Inherits:**
[IRedistribution](/contracts/interfaces/IRedistribution.sol/interface.IRedistribution.md)

**Author:**
Anton Davydov


## Functions
### redistribute

Redistribute contributions among siblings evenly, ignoring the priorities


```solidity
function redistribute(address[] calldata siblings, uint256[] calldata priorities, uint256 amount)
    external
    pure
    returns (Mission[] memory missions);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`siblings`|`address[]`|The list of ceremony members|
|`priorities`|`uint256[]`|Arbitrary number associated with each ceremony member|
|`amount`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`missions`|`Mission[]`|Shares of wealth for each ceremony member|


