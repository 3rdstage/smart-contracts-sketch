// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;


struct Planet{
    string name;
    uint256 radius; // in km
    uint256 distance; // in km
    bool rings;
}

contract Web3TestContract{
    
    uint256 private _count = 0;
    
    string private _memo;

    uint256[] private _fibonacciNumbers  = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229];

    string[] private _monthFullNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    string[] private _monthShortNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    string[] private _planetNames = ['Mercury', 'Venus'];
    
    Planet[] private _planets;
    
    event CountUp(uint256 count);
    
    event MemoUpdated(string memo);

    constructor(){
        _planets.push(Planet('Mercury',  2_440,    57_909_050, false));
        _planets.push(Planet('Venus',    6_052,   108_208_000, false));
        _planets.push(Planet('Earth',    6_371,   149_598_023, false));
        _planets.push(Planet('Mars',     3_390,   227_939_200, false));
        _planets.push(Planet('Jupiter', 69_911,   778_570_000, true));
        _planets.push(Planet('Saturn',  58_232, 1_433_000_000, true));
        _planets.push(Planet('Uranus',  25_362, 2_875_040_000, true));
        _planets.push(Planet('Saturn',  24_622, 4_500_000_000, true));
    }

    function sum(uint128 a, uint128 b) public pure returns(uint144){
        
        return a + b;
    }
    
    
    function sum(uint128[] memory nums) public pure returns(uint256){
        
        uint256 s = 0;
        uint256 n = nums.length;
        for(uint256 i = 0; i < n; i++){
            s = s + nums[i];
        }
        
        return s;
    }

    function fibonnaci(uint8 cnt) public view returns(uint256[] memory){
        
        require(cnt < 31, "Currently only upto first 30 Fibonacci numbers are supported.");
        
        uint256[] memory nums = new uint256[](cnt);
        
        for(uint256 i = 0; i < cnt; i++){
            nums[i] = _fibonacciNumbers[i];
        }
        
        return nums;
    }
    
    
    function monthNames() public view returns(string[] memory names){
        
        names = _monthFullNames;
    }
    
    function monthNamesFullAndShort() public view returns(string[] memory fullNames, string[] memory shortNames){
        
        fullNames = _monthFullNames;
        shortNames = _monthShortNames;
    }
    
    function rainbow() public pure returns(bytes[] memory colors){
        
        colors[0] = 'Red';
        colors[1] = 'Orange';
        colors[2] = 'Yello';
        colors[3] = 'Green';
        colors[4] = 'Blue';
        colors[5] = 'Indigo';
        colors[6] = 'Violet';
        
        return colors;
    }
    
    function planets() public view returns(Planet[] memory){
        
        Planet[] memory plnts = _planets;
        return plnts;
    }
    
    function innerPlanets() public view returns(Planet[] memory){
        
        Planet[] memory plnts = new Planet[](2);
        plnts[0] = _planets[0];
        plnts[1] = _planets[1];
        return plnts;
    }
    
    function outerPlanets() public view returns(Planet[] memory){
        
        Planet[] memory plnts = new Planet[](5);
        for(uint256 i = 0; i < 5; i++){
            plnts[i] = _planets[4 + i];
        }
        return plnts;
    }
    
    function ringedPlanets() public view returns(Planet[] memory){
        
        Planet[] memory plnts = new Planet[](4);
        for(uint256 i = 0; i < 4; i++){
            plnts[i] = _planets[i + 5];
        }
        return plnts;
    }
    
    
    function countUp() public returns(uint256){
        uint256 cnt = _count;
        _count++;
        
        emit CountUp(cnt);
        return cnt;
    }
    
    function setMemo(string memory memo) public{
        _memo = memo;
        
        emit MemoUpdated(memo);
    }
    
    function getMemo() public view returns(string memory){
        return _memo;
    }


}