// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket {
    struct Question {
        string text;
        string[] choices;
        uint[] votes;
        uint price;         // Prix d'une action
        uint correctIndex;  // Index de la bonne réponse (non défini au début)
        uint deadline;
        address creator;
        bool hasCorrectAnswer;
        bool exists;
    }

    uint public questionCount = 0;
    mapping(uint => Question) public questions;

    // questionId => user => choice index (ou -1 si pas encore voté)
    mapping(uint => mapping(address => int)) public userVotes;

    // questionId => user => nombre d'actions (wei)
    mapping(uint => mapping(address => uint)) public userStakes;

    // Événements
    event QuestionAdded(uint id, string text);
    event Voted(uint questionId, address voter, uint choiceIndex, uint stake);
    event CorrectAnswerSet(uint questionId, uint correctIndex);

    // Ajouter une question sans définir la réponse correcte
    function addQuestion(
        string memory _text,
        string[] memory _choices,
        uint _price,
        uint _deadline
    ) public {
        require(_choices.length >= 2, "Au moins 2 choix");
        require(_deadline > block.timestamp, "Deadline doit etre dans le futur");

        uint[] memory initVotes = new uint[](_choices.length);

        questions[questionCount] = Question({
            text: _text,
            choices: _choices,
            votes: initVotes,
            price: _price,
            correctIndex: 0,
            deadline: _deadline,
            creator: msg.sender,
            hasCorrectAnswer: false,
            exists: true
        });

        emit QuestionAdded(questionCount, _text);
        questionCount++;
    }

    // Voter avec un montant personnalisé
    function vote(uint _id, uint _choiceIndex) public payable {
        Question storage q = questions[_id];
        require(q.exists, "Question inexistante");
        require(block.timestamp <= q.deadline, "Deadline depasse");
        require(_choiceIndex < q.choices.length, "Choix invalide");
        require(msg.value >= q.price, "Paiement insuffisant");

        uint numberOfActions = msg.value / q.price;
        require(numberOfActions > 0, "Montant trop faible pour une action");

        int previousVote = userVotes[_id][msg.sender];

        if (previousVote >= 0) {
            uint oldStake = userStakes[_id][msg.sender];
            q.votes[uint(previousVote)] -= oldStake;
        }

        q.votes[_choiceIndex] += numberOfActions;

        userVotes[_id][msg.sender] = int(_choiceIndex);
        userStakes[_id][msg.sender] = numberOfActions;

        emit Voted(_id, msg.sender, _choiceIndex, numberOfActions);
    }

    // Définir la bonne réponse (uniquement après deadline, par le créateur)s
    function setCorrectAnswer(uint _id, uint _correctIndex) public {
        Question storage q = questions[_id];
        require(q.exists, "Question inexistante");
        require(msg.sender == q.creator, "Seul le createur peut definir");
        require(block.timestamp > q.deadline, "Trop tot pour definir la reponse");
        require(_correctIndex < q.choices.length, "Index invalide");
        require(!q.hasCorrectAnswer, "Réponse déjà définie");

        q.correctIndex = _correctIndex;
        q.hasCorrectAnswer = true;

        emit CorrectAnswerSet(_id, _correctIndex);
    }

    // Lire infos question
    function getQuestion(uint _id)
        public
        view
        returns (
            string memory,
            string[] memory,
            uint[] memory,
            uint,
            address
        )
    {
        Question storage q = questions[_id];
        require(q.exists, "Question inexistante");
        return (q.text, q.choices, q.votes, q.price, q.creator);
    }

    function getUserVote(uint _id, address _user) public view returns (int) {
        return userVotes[_id][_user];
    }

    function getUserStake(uint _id, address _user) public view returns (uint) {
        return userStakes[_id][_user];
    }

    function getCorrectAnswer(uint _id) public view returns (uint) {
        require(questions[_id].exists, "Question inexistante");
        require(questions[_id].hasCorrectAnswer, "Réponse non encore définie");
        return questions[_id].correctIndex;
    }

    function getDeadline(uint _id) public view returns (uint) {
        require(questions[_id].exists, "Question inexistante");
        return questions[_id].deadline;
    }

    // Supprimer une question
    function deleteQuestion(uint _id) public {
        require(questions[_id].exists, "Question inexistante");
        require(questions[_id].creator == msg.sender, "Seul le createur peut supprimer");
        delete questions[_id];
    }

    // Total des mises de tous les clients
    function getTotalClientStake() public view returns (uint) {
        uint totalStake = 0;
        for (uint qId = 0; qId < questionCount; qId++) {
            Question storage q = questions[qId];
            if (!q.exists) continue;

            uint totalVotes = 0;
            for (uint i = 0; i < q.votes.length; i++) {
                totalVotes += q.votes[i];
            }

            totalStake += totalVotes * q.price;
        }
        return totalStake;
    }
}
