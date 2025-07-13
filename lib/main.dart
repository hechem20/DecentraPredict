//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prediction/registre.dart';
import 'package:prediction/client.dart';
import 'package:prediction/owner.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
//import 'package:web3dart/crypto.dart';
import 'package:path/path.dart' as p;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "client";
  // List result = [];ss
  String email2 = "";
  String password2 = "";
  String role2 = "";
  String nom2 = "";
  List<String> l1 = ["", ""];
  
   final String rpcUrl = "HTTP://127.0.0.1:7545";
  final String wsUrl = "ws://127.0.0.1:7545";
  final String contractAddress = "0x2C24DA4308D1b47d8eCa72114BE315673279e301";
  

  Future<void> loginUser(String email, String password, String role) async {
    final client = Web3Client(rpcUrl, Client());
   
    try {
      final String contractAbi = '''
[
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "ItemsInInventory",
		"outputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "role",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "role",
				"type": "string"
			}
		],
		"name": "addItem",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			}
		],
		"name": "getUser",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
 ''';

      final contract = DeployedContract(
        ContractAbi.fromJson(contractAbi, "Auth"),
        EthereumAddress.fromHex(contractAddress),
      );

      final function =
          contract.function('getUser'); // Récupérer la fonction du contrat

      final data = await client.call(
        contract: contract,
        function: function,
        params: [email], // Aucun paramètre pour cette fonction
      );

      List<dynamic> userData = data[0] as List<dynamic>;
      email2 = userData[1] as String;
      password2 = userData[2] as String;
      role2 = userData[3] as String;
      l1 = [email2, password2, role2];
      print(l1);
    } catch (e) {
      //log(e.toString()); // Afficher l'erreur pour le débogagesssss
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: $e")),
      );
      l1 = ["", ""];
    }
    if ((l1[0] == email) && (l1[1] == password) && (l1[2] == role)&& (role=='client')) {
      
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientPage()),
      );
    }
     if ((l1[0] == email) && (l1[1] == password) && (l1[2] == role)&& (role=='owner')) {
      
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OwnerDashboard()),
      );
    }
    /* } finally {
      client
          .dispose(); // Fermez correctement le client pour éviter les fuites mémoire
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 80, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                "Prediction Markets",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: [
                  "owner",
                  "client", 
                ]
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: "Sélectionnez votre rôle",
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await loginUser(emailController.text, passwordController.text,
                      selectedRole);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.show_chart, size: 40, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}//s