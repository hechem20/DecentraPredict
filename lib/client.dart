import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Web3Client client;
  late DeployedContract contract;
  late Credentials creds;
  EthereumAddress? myAddress;

  final String rpcUrl = "http://127.0.0.1:7545"; // Ganache
  final String privateKey = "0xcb19d6e37bbcdea36a35d8d0b23dbf51bbcdcf8f56beef118d1d7342bd6380bd";
  final String contractAddress = "0x5CF6fF9A75Debdd9033333ecFe61fFd5De44FC19";

  int questionCount = 0;
  List<QuestionData> questions = [];
  Map<int, int> selectedChoices = {}; // questionId => choiceIndex
  //BigInt userBalance = BigInt.zero;s
  late EtherAmount userBalance=EtherAmount.inWei(BigInt.from(10));
late EtherAmount balance;


  final voteAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initWeb3();
  }

  Future<void> initWeb3() async {
    client = Web3Client(rpcUrl, Client());
    creds = EthPrivateKey.fromHex(privateKey);
    myAddress = await creds.extractAddress();

    await loadContract();
    await loadQuestions();
    await loadUserVotes();
    await loadBalance();
  }
//
  Future<void> loadContract() async {
   
    final abiJson = """[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "questionId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "correctIndex",
				"type": "uint256"
			}
		],
		"name": "CorrectAnswerSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "text",
				"type": "string"
			}
		],
		"name": "QuestionAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "questionId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "voter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "choiceIndex",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "stake",
				"type": "uint256"
			}
		],
		"name": "Voted",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_text",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "_choices",
				"type": "string[]"
			},
			{
				"internalType": "uint256",
				"name": "_price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_deadline",
				"type": "uint256"
			}
		],
		"name": "addQuestion",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "deleteQuestion",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getCorrectAnswer",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getDeadline",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getQuestion",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getTotalClientStake",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getUserStake",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getUserVote",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "questionCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "questions",
		"outputs": [
			{
				"internalType": "string",
				"name": "text",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "correctIndex",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "creator",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "hasCorrectAnswer",
				"type": "bool"
			},
			{
				"internalType": "bool",
				"name": "exists",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_correctIndex",
				"type": "uint256"
			}
		],
		"name": "setCorrectAnswer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "userStakes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "userVotes",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_choiceIndex",
				"type": "uint256"
			}
		],
		"name": "vote",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	}
]""";
    contract = DeployedContract(
      ContractAbi.fromJson(abiJson, "PredictionMarket"),
      EthereumAddress.fromHex(contractAddress),
    );
  }

Future<void> loadQuestions() async {
  final countFunction = contract.function("questionCount");
  final countResult = await client.call(contract: contract, function: countFunction, params: []);
  questionCount = (countResult[0] as BigInt).toInt();

  final getQuestionFunc = contract.function("getQuestion");
  final getDeadlineFunc = contract.function("getDeadline");

  List<QuestionData> loaded = [];

  for (int i = 0; i < questionCount; i++) {
    final res = await client.call(
      contract: contract,
      function: getQuestionFunc,
      params: [BigInt.from(i)],
    );

    final deadlineRes = await client.call(
      contract: contract,
      function: getDeadlineFunc,
      params: [BigInt.from(i)],
    );

    final String text = res[0];
    final List<String> choices = (res[1] as List).map((e) => e as String).toList();
    final List<int> votes = (res[2] as List).map((e) => (e as BigInt).toInt()).toList();
    final int price = (res[3] as BigInt).toInt();
    final EthereumAddress creator = res[4];
   final deadline = (deadlineRes[0] as BigInt).toInt();
 
loaded.add(QuestionData(i, text, choices, votes, price, creator, deadline));
   
  }

  setState(() {
    questions = loaded;
  });
}


  Future<void> loadUserVotes() async {
    final func = contract.function("getUserVote");
    Map<int, int> userVotesMap = {};

    for (int i = 0; i < questionCount; i++) {
      final result = await client.call(
        contract: contract,
        function: func,
        params: [BigInt.from(i), myAddress],
      );

      int voteIndex = (result[0] as BigInt).toInt();
      if (voteIndex >= 0) {
        userVotesMap[i] = voteIndex;
      }
    }

    setState(() {
      selectedChoices = userVotesMap;
    });
  }

  Future<void> loadBalance() async {
    userBalance = await client.getBalance(myAddress!);
    setState(() {});
  }

  Future<void> vote(int questionId, int choiceIndex, int amount) async {
    final voteFunc = contract.function("vote");
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final question = questions.firstWhere((q) => q.id == questionId);
    if (now > question.deadline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⏳ Délai dépassé pour cette question.")),
      );
      return;
    }

    try {
      await client.sendTransaction(
        creds,
        Transaction.callContract(
          contract: contract,
          function: voteFunc,
          parameters: [BigInt.from(questionId), BigInt.from(choiceIndex)],
          value: EtherAmount.inWei(BigInt.from(amount)),
          maxGas: 500000,
        ),
              chainId: 1337,

      );

      setState(() {
        selectedChoices[questionId] = choiceIndex;
      });
      await loadBalance();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Vote envoyé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur : $e")),
      );
    }
  }
//ss
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🗳️ Client - Voter")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("💰 Solde: ${userBalance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4)}GUI "),
          ),
          Expanded(
            child: questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return Card(
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("❓ ${q.text}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("🕒 Deadline: ${DateTime.fromMillisecondsSinceEpoch(q.deadline * 1000)}"),
                              const SizedBox(height: 10),
                              TextField(
                                controller: voteAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: "Montant en GUI"),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(q.choices.length, (choiceIndex) {
                                return RadioListTile<int>(
                                  title: Text(q.choices[choiceIndex]),
                                  value: choiceIndex,
                                  groupValue: selectedChoices[q.id],
                                  onChanged: (val) {
                                    if (val != null) {
                                      final amt = int.tryParse(voteAmountController.text) ?? 0;
                                      if (amt > 0) vote(q.id, val, amt);
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class QuestionData {
  final int id;
  final String text;
  final List<String> choices;
  final List<int> votes;
  final int price;
  final EthereumAddress creator;
  final int deadline;

  QuestionData(this.id, this.text, this.choices, this.votes, this.price, this.creator, this.deadline);
}
//sss
