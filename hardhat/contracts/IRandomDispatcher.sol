//SPDX-License-Identifier: None
pragma solidity ^0.8.5;

interface IRandomDispatcher {

    enum Destination {Knight, Tournament, Battle}

    struct DispatchRequest {
        Destination dest;
        uint id;
    }

    function requestRandomNumber(IRandomDispatcher.Destination dest, uint id) external;

}