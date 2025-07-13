import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';

class QuestionData {
  final int id;
  final String text;
  final List<String> choices;
  final List<int> votes;
  final int price;
  final EthereumAddress creator;
  final int deadline; // ➕ ajoute ce champ ici

  QuestionData(this.id,this.text, this.choices, this.votes, this.price, this.creator  ,  this.deadline
);
}

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  late Web3Client client;
  late DeployedContract contract;
  late Credentials creds;
late EtherAmount totalStake = EtherAmount.inWei(BigInt.zero);
Map<int, int> correctAnswerSelected = {};
  final String rpcUrl = "http://127.0.0.1:7545";
  final String privateKey = "0xcb19d6e37bbcdea36a35d8d0b23dbf51bbcdcf8f56beef118d1d7342bd6380bd";
  final String contractAddr = "0x5CF6fF9A75Debdd9033333ecFe61fFd5De44FC19";

  int questionCount = 0;
  List<QuestionData> questions = [];

  final questionCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final delayCtrl = TextEditingController();
  List<TextEditingController> choiceCtrls = [TextEditingController(), TextEditingController()];
  int? correctChoiceIndex;

  @override
  void initState() {
    super.initState();
    client = Web3Client(rpcUrl, Client());
    creds = EthPrivateKey.fromHex(privateKey);
    loadContractAndData();
  }

  Future<void> loadContractAndData() async {
    
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
      EthereumAddress.fromHex(contractAddr),
    );
//s
    final questionCountFunction = contract.function("questionCount");
    final countList = await client.call(contract: contract, function: questionCountFunction, params: []);
    questionCount = (countList[0] as BigInt).toInt();

    List<QuestionData> loadedQuestions = [];
    final getQuestionFunc = contract.function("getQuestion");
final ContractFunction getDeadlineFunc = contract.function("getDeadline");

    for (int i = 0; i < questionCount; i++) {
      final qData = await client.call(contract: contract, function: getQuestionFunc, params: [BigInt.from(i)]);

      String text = qData[0] as String;
      List<String> choices = (qData[1] as List).map((c) => c as String).toList();
      List<int> votes = (qData[2] as List).map((v) => (v as BigInt).toInt()).toList();
      int price = (qData[3] as BigInt).toInt();
      EthereumAddress creator = qData[4] as EthereumAddress;
 final deadlineData = await client.call(
    contract: contract,
    function: getDeadlineFunc, // assure-toi que cette fonction est bien définie dans le contratss
    params: [BigInt.from(i)],
  );

  int deadline = (deadlineData[0] as BigInt).toInt();
      loadedQuestions.add(QuestionData(i, text, choices, votes, price, creator, deadline));

    }

    setState(() {
      questions = loadedQuestions;
    });
  }

  Future<void> addQuestionToBlockchain({
    required String text,
    required List<String> choices,
    required int price,
    
    required int deadlineUnix,
  }) async {
    final func = contract.function("addQuestion");
    await client.sendTransaction(
      creds,
      Transaction.callContract(
        contract: contract,
        function: func,
        parameters: [
          text,
          choices,
          BigInt.from(price),
          
          BigInt.from(deadlineUnix),
        ],
        maxGas: 300000,
      ),
      chainId: 1337,
    );
//sss
    await loadContractAndData();
  }//ss
  Future<EtherAmount> getTotalClientStake() async {
  final totalStakeFunc = contract.function("getTotalClientStake");
  final res = await client.call(
    contract: contract,
    function: totalStakeFunc,
    params: [],
  );
  //totalStake = EtherAmount.inWei(res[0] as BigInt);ssqssss

  return EtherAmount.inWei(res[0] as BigInt);
}


  void showAddQuestionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Ajouter une question"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: questionCtrl, decoration: const InputDecoration(labelText: "Question")),
                    const SizedBox(height: 10),
                    ...choiceCtrls.asMap().entries.map((entry) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(labelText: "Choix ${entry.key + 1}"),
                            ),
                          ),
                          IconButton(
                            onPressed: choiceCtrls.length > 2
                                ? () {
                                    setDialogState(() => choiceCtrls.removeAt(entry.key));
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          )
                        ],
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setDialogState(() => choiceCtrls.add(TextEditingController())),
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter un choix"),
                    ),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Prix en wei"),
                    ),
                    TextField(
                      controller: delayCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Délai (en minutes)"),
                    ),
                    const SizedBox(height: 10),
                    /*DropdownButton<int>(
                      hint: const Text("Choisir la réponse correcte"),
                      value: correctChoiceIndex,
                      items: List.generate(choiceCtrls.length, (i) {
                        final txt = choiceCtrls[i].text.isNotEmpty ? choiceCtrls[i].text : "Choix ${i + 1}";
                        return DropdownMenuItem(value: i, child: Text(txt));
                      }),
                      onChanged: (val) => setDialogState(() => correctChoiceIndex = val),
                    ),*/
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final text = questionCtrl.text;
                    final price = int.tryParse(priceCtrl.text) ?? 0;
                    final delayMinutes = int.tryParse(delayCtrl.text) ?? 0;
                    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                    final deadline = now + delayMinutes * 60;
                    final choices = choiceCtrls.map((c) => c.text).where((c) => c.isNotEmpty).toList();

                   // if (text.isEmpty || choices.length < 2 || correctChoiceIndex == null || price <= 0) return;

                    await addQuestionToBlockchain(
                      text: text,
                      choices: choices,
                      price: price,
                      deadlineUnix: deadline,
                    );

                    questionCtrl.clear();
                    priceCtrl.clear();
                    delayCtrl.clear();
                    correctChoiceIndex = null;
                    choiceCtrls = [TextEditingController(), TextEditingController()];
                    Navigator.pop(ctx);
                  },
                  child: const Text("Ajouter"),
                )
              ],
            );
          },
        );
      },
    );
  }

  List<BarChartGroupData> buildBarChartData(QuestionData question) {
    int totalVotes = question.votes.fold(0, (a, b) => a + b);
    return List.generate(question.choices.length, (i) {
      double percentage = totalVotes > 0 ? (question.votes[i] / totalVotes) * 100 : 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: percentage, width: 20, color: Colors.blue),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
Future<void> setCorrectAnswer(int questionId, int correctIndex) async {
  final setAnswerFunc = contract.function("setCorrectAnswer");

  try {
    await client.sendTransaction(
      creds,
      Transaction.callContract(
        contract: contract,
        function: setAnswerFunc,
        parameters: [
          BigInt.from(questionId),
          BigInt.from(correctIndex),
        ],
        maxGas: 100000,
      ),
      chainId: 1337, // adapte si besoin
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Réponse correcte définie.")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Erreur : $e")),
    );
  }
}
//
  Widget buildChart(QuestionData question) {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: buildBarChartData(question),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  int index = val.toInt();
                  if (index >= 0 && index < question.choices.length) {
                    return Text(question.choices[index], style: const TextStyle(fontSize: 12));
                  }
                  return const Text("");
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 20),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Owner Dashboard - Questions")),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "💰 Total Stake des Clients : ${totalStake.getValueInUnit(EtherUnit.ether).toStringAsFixed(4)} ETH",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ElevatedButton.icon(
          onPressed: showAddQuestionDialog,
          icon: const Icon(Icons.add),
          label: const Text("Ajouter une nouvelle question"),
        ),
        Expanded(
          child: questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    int totalVotes = q.votes.fold(0, (a, b) => a + b);
                    bool isDeadlinePassed = DateTime.now().millisecondsSinceEpoch ~/ 1000 > q.deadline;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("❓ ${q.text}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("💰 Prix : ${q.price} wei"),
                            Text("🧮 Total réponses : $totalVotes"),
                            const SizedBox(height: 12),
                            buildChart(q),

                            if (isDeadlinePassed) ...[
                              const Divider(),
                              const Text("⚠️ Deadline dépassée"),
                              const SizedBox(height: 5),
                              DropdownButton<int>(
                                hint: const Text("Choisir la bonne réponse"),
                                value: correctAnswerSelected[q.id],
                                items: List.generate(q.choices.length, (i) {
                                  return DropdownMenuItem(
                                    value: i,
                                    child: Text(q.choices[i]),
                                  );
                                }),
                                onChanged: (val) {
                                  setState(() {
                                    correctAnswerSelected[q.id] = val!;
                                  });
                                },
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (correctAnswerSelected[q.id] != null) {
                                    setCorrectAnswer(q.id, correctAnswerSelected[q.id]!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("❗ Veuillez choisir une réponse.")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Définir la bonne réponse"),
                              ),
                            ]
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