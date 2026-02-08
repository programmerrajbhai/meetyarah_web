import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/education/screens/mcq_exam_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String className;
  final String subCategory;
  final Color themeColor;

  const SubjectSelectionScreen({Key? key, required this.className, required this.subCategory, required this.themeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subjects = _getSubjects(className, subCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          Positioned(top: -80, right: -60, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: themeColor.withOpacity(0.15), ))),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    InkWell(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_new_rounded)),
                    const SizedBox(width: 15),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(className, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                      Text(subCategory, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                  ]),
                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [themeColor, themeColor.withOpacity(0.7)]), borderRadius: BorderRadius.circular(24)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Select Subject", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Start practicing MCQs chapter wise.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 30),

                  ListView.builder(
                    itemCount: subjects.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final sub = subjects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
                        child: ListTile(
                          leading: Icon(sub['icon'], color: themeColor),
                          title: Text(sub['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          subtitle: Text("10 Chapters • 100 MCQs", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {
                            // ✅ Go to MCQ Exam
                            Get.to(() => McqExamScreen(subjectName: sub['name'], themeColor: themeColor));
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSubjects(String cls, String sub) {
    if (sub == 'Science') return [{'name': 'Physics', 'icon': Icons.science}, {'name': 'Chemistry', 'icon': Icons.science_outlined}, {'name': 'Biology', 'icon': Icons.biotech}, {'name': 'Higher Math', 'icon': Icons.functions}];
    if (sub == 'Commerce' || sub == 'Business') return [{'name': 'Accounting', 'icon': Icons.calculate}, {'name': 'Finance', 'icon': Icons.monetization_on}];
    return [{'name': 'Bangla', 'icon': Icons.book}, {'name': 'English', 'icon': Icons.language}, {'name': 'ICT', 'icon': Icons.computer}];
  }
}