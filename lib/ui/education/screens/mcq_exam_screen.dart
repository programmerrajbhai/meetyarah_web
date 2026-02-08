import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class McqExamScreen extends StatefulWidget {
  final String subjectName;
  final Color themeColor;

  const McqExamScreen({Key? key, required this.subjectName, required this.themeColor}) : super(key: key);

  @override
  State<McqExamScreen> createState() => _McqExamScreenState();
}

class _McqExamScreenState extends State<McqExamScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 20; // 20 seconds per question
  Timer? _timer;
  bool isAnswered = false;
  int? selectedOptionIndex;

  // Demo Questions (10 Questions)
  final List<Map<String, dynamic>> questions = [
    {'q': 'What is the unit of Force?', 'options': ['Newton', 'Joule', 'Watt', 'Pascal'], 'ans': 0},
    {'q': 'Value of g on Earth?', 'options': ['9.8 ms^-2', '10 ms^-2', '9.8 cm^-2', 'None'], 'ans': 0},
    {'q': 'H2O is the formula of?', 'options': ['Oxygen', 'Water', 'Salt', 'Acid'], 'ans': 1},
    {'q': 'Capital of Bangladesh?', 'options': ['Ctg', 'Sylhet', 'Dhaka', 'Khulna'], 'ans': 2},
    {'q': '3 + 5 x 2 = ?', 'options': ['16', '13', '10', '20'], 'ans': 1},
    {'q': 'King of Jungle?', 'options': ['Tiger', 'Lion', 'Elephant', 'Bear'], 'ans': 1},
    {'q': 'Lightest Gas?', 'options': ['Oxygen', 'Hydrogen', 'Helium', 'Nitrogen'], 'ans': 1},
    {'q': 'Smallest Prime Number?', 'options': ['0', '1', '2', '3'], 'ans': 2},
    {'q': 'Currency of USA?', 'options': ['Euro', 'Yen', 'Dollar', 'Taka'], 'ans': 2},
    {'q': 'Fifa World Cup 2022 Winner?', 'options': ['France', 'Brazil', 'Argentina', 'Germany'], 'ans': 2},
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        nextQuestion();
      }
    });
  }

  void checkAnswer(int index) {
    if (isAnswered) return;
    setState(() {
      isAnswered = true;
      selectedOptionIndex = index;
      if (index == questions[currentQuestionIndex]['ans']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOptionIndex = null;
      });
      startTimer();
    } else {
      _timer?.cancel();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    Get.defaultDialog(
      title: "Exam Finished! 🎉",
      content: Column(
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          Text("Score: $score / 10", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(score > 7 ? "Excellent!" : "Keep Practicing!", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
        onPressed: () {
          Get.back(); // Close Dialog
          Get.back(); // Back to Subject List
        },
        child: const Text("Finish"),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        title: Text(widget.subjectName, style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Q: ${currentQuestionIndex + 1}/10", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer Bar
            LinearProgressIndicator(value: timeLeft / 20, color: widget.themeColor, backgroundColor: Colors.grey.shade300),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: Text("$timeLeft s", style: const TextStyle(fontWeight: FontWeight.bold))),

            const SizedBox(height: 30),

            // Question Card
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
              child: Text(question['q'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 30),

            // Options
            ...List.generate(4, (index) {
              Color optionColor = Colors.white;
              if (isAnswered) {
                if (index == question['ans']) optionColor = Colors.green.shade100;
                else if (index == selectedOptionIndex) optionColor = Colors.red.shade100;
              }

              return GestureDetector(
                onTap: () => checkAnswer(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: optionColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isAnswered && index == selectedOptionIndex ? Colors.red : Colors.transparent),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Row(children: [
                    CircleAvatar(radius: 12, backgroundColor: widget.themeColor.withOpacity(0.1), child: Text("${index + 1}", style: TextStyle(fontSize: 12, color: widget.themeColor))),
                    const SizedBox(width: 15),
                    Text(question['options'][index], style: GoogleFonts.poppins(fontSize: 15)),
                  ]),
                ),
              );
            }),

            const Spacer(),

            // Next Button
            if (isAnswered)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: nextQuestion,
                  child: Text(currentQuestionIndex == 9 ? "Submit" : "Next Question", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}