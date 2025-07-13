// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Auth {
    struct Items {
        string name;
        string email;
        string password;
        string role;
    }

    Items[] public ItemsInInventory; //Inventory`s Array    
    function addItem( string memory email,string memory name, string memory password,string memory role) public{
        ItemsInInventory.push(Items(name,email, password,role));
    }

   

    
     function getUser(string memory email) public view returns (string [] memory ) {
        
        string []memory res=new string[](3);
        
        for (uint256 k=0;k<ItemsInInventory.length;k++){
            if (keccak256(bytes(ItemsInInventory[k].email)) == keccak256(bytes(email))) {
                res[0]=ItemsInInventory[k].name;
                res[1]=ItemsInInventory[k].email;
                res[2]=ItemsInInventory[k].password;
                res[3]=ItemsInInventory[k].role;
                
            }
        
        }
        return res;
        
    }




}

