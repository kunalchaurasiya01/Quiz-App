import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delhi University Quiz',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: QuizPage(),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [
    Question(
      questionText: 'In which year was the University of Delhi established?',
      options: ['1905', '1922', '1947', '1950'],
      correctAnswerIndex: 1,
      explanation: 'DU was established in 1922 under the act of the Central Legislative Assembly.',
    ),
    Question(
      questionText: 'Which of the following is NOT a college under Delhi University?',
      options: ['Miranda House', 'Lady Shri Ram College', 'St. Stephen\'s College', 'IIT Delhi'],
      correctAnswerIndex: 3,
      explanation: 'IIT Delhi is a separate institute and not part of Delhi University.',
    ),
    Question(
      questionText: 'What is the motto of the University of Delhi?',
      options: ['Knowledge is Power', 'Nishtha Dhriti Satyam', 'Truth Alone Triumphs', 'Service Before Self'],
      correctAnswerIndex: 1,
      explanation: '“Nishtha Dhriti Satyam” is the official Sanskrit motto of DU.',
    ),
    Question(
      questionText: 'Which college is known for its Commerce program?',
      options: ['Kirori Mal College', 'Hansraj College', 'Shri Ram College of Commerce', 'Daulat Ram College'],
      correctAnswerIndex: 2,
      explanation: 'SRCC is globally recognized for its excellence in Commerce and Economics.',
    ),
    Question(
      questionText: 'Which entrance exam is currently used for UG admissions in DU?',
      options: ['CUET', 'JEE', 'DUET', 'CAT'],
      correctAnswerIndex: 0,
      explanation: 'As of 2022, CUET is the national entrance test for DU UG admissions.',
    ),
    Question(
      questionText: 'Which college under DU is exclusively for women?',
      options: ['Ramjas College', 'Miranda House', 'Hindu College', 'Hansraj College'],
      correctAnswerIndex: 1,
      explanation: 'Miranda House is a prestigious women’s college under DU.',
    ),
    Question(
      questionText: 'Who is the Chancellor of the University of Delhi?',
      options: ['Vice President of India', 'President of India', 'Prime Minister of India', 'Governor of Delhi'],
      correctAnswerIndex: 1,
      explanation: 'The President of India is the Chancellor of all central universities including DU.',
    ),
    Question(
      questionText: 'Which DU college is famous for dramatics and theatre?',
      options: ['Sri Venkateswara College', 'Hansraj College', 'Kirori Mal College', 'Zakir Husain College'],
      correctAnswerIndex: 2,
      explanation: 'Kirori Mal College is widely known for its dramatics society “The Players”.',
    ),
    Question(
      questionText: 'What is the name of DU’s central library?',
      options: ['Delhi Knowledge Centre', 'Arts Faculty Library', 'Central Reference Library', 'DU Central Library'],
      correctAnswerIndex: 2,
      explanation: 'The Central Reference Library is DU’s main library with rich academic resources.',
    ),
    Question(
      questionText: 'How many campuses does Delhi University have?',
      options: ['1', '2', '3', '4'],
      correctAnswerIndex: 1,
      explanation: 'DU has North and South campuses — hence, 2 major ones.',
    ),
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  List<int?> userAnswers = [];
  Set<int> skippedQuestions = {};
  Set<int> visitedQuestions = {};
  Set<int> reviewQuestions = {};
  Timer? timer;
  Duration remainingTime = Duration(minutes: 5);
  bool showInstructions = true;

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, null);
  }

  void startQuiz() {
    setState(() {
      questions.shuffle(Random());
      userAnswers = List.filled(questions.length, null);
      skippedQuestions.clear();
      visitedQuestions.clear();
      reviewQuestions.clear();
      currentQuestionIndex = 0;
      score = 0;
      remainingTime = Duration(minutes: 5);
      showInstructions = false;
      startTimer();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= Duration(seconds: 1);
        } else {
          t.cancel();
          currentQuestionIndex = questions.length;
        }
      });
    });
  }

  void selectAnswer(int selectedIndex) {
    setState(() {
      if (userAnswers[currentQuestionIndex] == selectedIndex) {
        userAnswers[currentQuestionIndex] = null;
      } else {
        userAnswers[currentQuestionIndex] = selectedIndex;
        skippedQuestions.remove(currentQuestionIndex);
        reviewQuestions.remove(currentQuestionIndex);
      }
      visitedQuestions.add(currentQuestionIndex);
    });
  }

  void markForReview() {
    setState(() {
      reviewQuestions.add(currentQuestionIndex);
      visitedQuestions.add(currentQuestionIndex);
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      }
    });
  }

  void skipQuestion() {
    setState(() {
      skippedQuestions.add(currentQuestionIndex);
      userAnswers[currentQuestionIndex] = null;

      // Remove from reviewQuestions if it was marked before
      reviewQuestions.remove(currentQuestionIndex);

      visitedQuestions.add(currentQuestionIndex);
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        visitedQuestions.add(currentQuestionIndex);
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        visitedQuestions.add(currentQuestionIndex);
      });
    }
  }

  void goToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
      visitedQuestions.add(index);
    });
  }

  void submitQuiz() {
    timer?.cancel();
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) count++;
    }
    setState(() {
      score = count;
      currentQuestionIndex = questions.length;
    });
  }

  void restartQuiz() {
    setState(() {
      showInstructions = true;
      timer?.cancel();
    });
  }

  String formatTime(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (showInstructions) {
      return Scaffold(
        appBar: AppBar(title: Text(' Quiz Instructions')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📘 Welcome to the Delhi University Quiz!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('⏱️ Total Time: 5 minutes'),
              SizedBox(height: 10),
              Text('✅ Green: Answered'),
              Text('🟥 Red: Unattempted'),
              Text('🟨 Yellow: Skipped or unanswered '),
              SizedBox(height: 20),
              Text('📌 Controls:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('➡️ Next / ⬅️ Back – Navigate questions'),
              Text('⏭️ Skip – Mark question as skipped'),
              Text('📤 Submit – Finish the quiz'),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: startQuiz,
                  child: Text('Start Quiz'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQuestionIndex >= questions.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Results')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('Your Score: $score / ${questions.length}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ...List.generate(questions.length, (index) {
                final q = questions[index];
                final userAns = userAnswers[index];
                final correct = userAns == q.correctAnswerIndex;

                return Card(
                  color: correct
                      ? Colors.green[50]
                      : (userAns == null ? Colors.yellow[50] : Colors.red[50]),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${index + 1}: ${q.questionText}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Your Answer: ${userAns != null ? q.options[userAns] : "None"}',
                            style: TextStyle(color: correct ? Colors.green : Colors.red)),
                        Text('Correct Answer: ${q.options[q.correctAnswerIndex]}',
                            style: TextStyle(color: Colors.green)),
                        Text('Explanation: ${q.explanation}'),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(onPressed: restartQuiz, child: Text('Restart')),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('DU Quiz')),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Colors.grey[300],
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                Color bgColor = Colors.red;
                if (reviewQuestions.contains(index)) {
                  bgColor = Colors.blue;
                } else if (userAnswers[index] != null) {
                  bgColor = Colors.green;
                } else if (skippedQuestions.contains(index) || visitedQuestions.contains(index)) {
                  bgColor = Colors.yellow;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: GestureDetector(
                    onTap: () => goToQuestion(index),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: bgColor,
                      child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(formatTime(remainingTime),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ),
                  SizedBox(height: 10),
                  Text('Question ${currentQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text(question.questionText, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),

                  // Options
                  ...List.generate((question.options.length / 2).ceil(), (rowIndex) {
                    return Row(
                      children: List.generate(2, (i) {
                        int optionIndex = rowIndex * 2 + i;
                        if (optionIndex >= question.options.length) return Expanded(child: SizedBox());

                        bool isSelected = userAnswers[currentQuestionIndex] == optionIndex;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                                foregroundColor: isSelected ? Colors.white : Colors.black,
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                              onPressed: () => selectAnswer(optionIndex),
                              child: Text(question.options[optionIndex]),
                            ),
                          ),
                        );
                      }),
                    );
                  }),

                  Spacer(),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(onPressed: currentQuestionIndex > 0 ? previousQuestion : null, child: Text('Back')),
                      ElevatedButton(onPressed: skipQuestion, child: Text('Skip')),
                      ElevatedButton(onPressed: markForReview, child: Text('Mark for Review')),
                      ElevatedButton(onPressed: submitQuiz, child: Text('Submit')),
                      ElevatedButton(
                        onPressed: currentQuestionIndex < questions.length - 1 ? nextQuestion : null,
                        child: Text('Next')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
