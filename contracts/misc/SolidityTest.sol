pragma solidity ^0.8.5;
pragma experimental ABIEncoderV2; 


struct Land{
    string name;
    uint256 area; // area in square killometers
}

contract SolidityTest{
    
    
    function testArrayInitialization() public pure returns(uint256[] memory, bytes[3] memory, string[] memory, Land[] memory){
        
        //creating arrays without explicit initializing.
        uint256 len = 5;
        uint[] memory scores = new uint[](len); // initialized with default value

        //initializing fixed-size arrays using array literals
        bytes[3] memory rgb = [bytes('RED'), 'GREEN', 'BLUE'];

        //initializing dynamic-size arrays
        //''If you want to initialize dynamically-sized arrays, you have to assign the individual elements'' (from Solidity documentation)
        string[] memory innerPlanets  = new string[](2);
        innerPlanets[0] = 'Mercury';
        innerPlanets[1] = 'Venus';

        Land[] memory continents = new Land[](7);
        continents[0] = Land('Africa', 30_370_000);
        continents[1] = Land('Antarctica', 14_000_000);
        continents[2] = Land('Asia', 44_579_000);
        continents[3] = Land('Europe', 10_180_000);
        continents[4] = Land('North America', 24_709_000);
        continents[5] = Land('South America', 17_840_000);
        continents[6] = Land('Australia', 8_600_000);
        
        return(scores, rgb, innerPlanets, continents);
    }
    
    
    function testStaticBytesDynamicBytesAndString() public pure returns(bytes[7] memory, bytes32[] memory, bytes[] memory, string[] memory){
        
        bytes[7] memory rainbow = [bytes('Red'), 'Orange', 'Yellow', 'Green', 'Blue', 'Indigo', 'Viloet'];

        uint256 n = rainbow.length;
        bytes32[] memory colorsInBytes32 = new bytes32[](n);
        for(uint i = 0; i < n; i++){
            colorsInBytes32[i] = bytes32(rainbow[i]); // explicit conversion from `bytes`(dynamic bytes) to `bytes32` (supported from Solidity 0.8.5)
        }
        
        bytes[] memory colorsInBytes = new bytes[](n);
        string[] memory colorsInString = new string[](n);
        
        for(uint i = 0; i < n; i++){
            colorsInBytes[i] = bytes.concat(colorsInBytes32[i]);
            colorsInString[i] = string(bytes.concat(colorsInBytes32[i])); // explicit conversion from `bytes32`, via `bytes`, to `string` 
        }

        return (rainbow, colorsInBytes32, colorsInBytes, colorsInString);

    }    
}