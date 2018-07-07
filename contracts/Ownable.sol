pragma solidity 0.4.24;

contract Ownable {
    address public owner;
    address public admin;

    function Ownable() public {
        owner = msg.sender;
        admin = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function changeAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0));
        admin = newAdmin;   
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));      
        owner = newOwner;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    function allowed(address user) public view returns (bool) {
        if (user != owner && user != admin) {
            return false;
        }
        
        return true;
    }
}