// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

interface Redistribution {

    function redistribute(bytes calldata _missions) external;
}
