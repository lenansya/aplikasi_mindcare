import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssessmentForm extends StatefulWidget {
  const AssessmentForm({super.key});

  @override
  _AssessmentFormState createState() => _AssessmentFormState();
}

class _AssessmentFormState extends State<AssessmentForm> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Apakah Anda merasa segar setelah bangun tidur di pagi hari?',
      'options': ['Sangat segar', 'Cukup segar', 'Tidak segar', 'Sangat tidak segar'],
      'score': [3, 2, 1, 0],
    },
    {
      'question': 'Apakah Anda sering terbangun di tengah malam tanpa alasan yang jelas?',
      'options': ['Tidak pernah', 'Kadang-kadang', 'Sering', 'Selalu'],
      'score': [3, 2, 1, 0],
    },
    {
      'question': 'Bagaimana perasaan Anda secara umum dalam satu minggu terakhir?',
      'options': ['Sangat baik', 'Cukup baik', 'Sedang', 'Tidak baik', 'Sangat tidak baik'],
      'score': [4, 3, 2, 1, 0],
    },
    {
      'question': 'Apakah Anda masih bisa menikmati hal-hal yang biasanya Anda sukai?',
      'options': ['Selalu', 'Sering', 'Kadang-kadang', 'Tidak pernah'],
      'score': [3, 2, 1, 0],
    },
    {
      'question': 'Apakah Anda memiliki teman dekat yang bisa diajak berbicara ketika memiliki masalah?',
      'options': ['Ya, selalu', 'Ya, kadang-kadang', 'Tidak, jarang', 'Tidak pernah'],
      'score': [3, 2, 1, 0],
    },
  ];

  Map<int, int> answers = {};
  int currentIndex = 0;
  int totalScore = 0;
  String riskLevel = "";
  String riskMessage = "";

  void submitAnswers() async {
    final assessmentsCollection = FirebaseFirestore.instance.collection('assessments');
    final patientsCollection = FirebaseFirestore.instance.collection('patients');
    final schedulesCollection = FirebaseFirestore.instance.collection('schedules');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan asesmen. Anda harus login.')),
      );
      return;
    }

    final userId = user.uid;
    final now = Timestamp.now();

    // Tentukan tingkat risiko berdasarkan skor
    determineRiskLevel();

    try {
      // Ambil jadwal terbaru yang statusnya masih "booked"
    QuerySnapshot scheduleSnapshot = await schedulesCollection
        .where('userId', isEqualTo: userId)
        .where('statusConsultation', isEqualTo: 'booked') // Hanya jadwal yang masih aktif
        .orderBy('date', descending: true) // Urutkan dari jadwal terbaru
        .limit(1)
        .get();

    String? scheduleId;
    if (scheduleSnapshot.docs.isNotEmpty) {
      scheduleId = scheduleSnapshot.docs.first.id; // Ambil ID jadwal terbaru yang aktif
    }
      // Simpan asesmen ke koleksi assessments
      final assessmentId = assessmentsCollection.doc().id; 
      await assessmentsCollection.add({
        'userId': userId,
        'assessmentId': assessmentId,
        'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
        'questions': questions.map((q) => q['question']).toList(),
        'score': totalScore,
        'riskLevel': riskLevel,
        'submittedAt': now,
        'scheduleId': scheduleId,
      });

      // Perbarui status isAssessmentCompleted ke true di koleksi patients
      await patientsCollection.doc(userId).update({
        'isAssessmentCompleted': true,
      });

      // Tampilkan dialog hasil
      showFinalScore();
    } catch (e) {
      print('Error saving assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan asesmen.')),
      );
    }
  }

  void determineRiskLevel() {
    if (totalScore >= 12) {
      riskLevel = "Rendah";
      riskMessage =
          "Anda menunjukkan tingkat distres psikologis yang rendah. Tetap jaga kesehatan mental Anda.";
    } else if (totalScore >= 6) {
      riskLevel = "Sedang";
      riskMessage =
          "Anda mungkin mengalami beberapa tantangan psikologis. Konsultasi dengan psikolog bisa membantu.";
    } else {
      riskLevel = "Tinggi";
      riskMessage =
          "Anda menunjukkan tanda-tanda distres psikologis yang signifikan. Sangat disarankan untuk berkonsultasi dengan psikolog.";
    }
  }

  void showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text('Hasil Akhir'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skor: $totalScore', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'Tingkat Risiko: $riskLevel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(riskMessage),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Menutup dialog
              Navigator.pop(context); // Kembali ke halaman Consultation
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void calculateScore() {
    totalScore = answers.entries
        .map((entry) => questions[entry.key]['score'][entry.value])
        .reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Formulir Asesmen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
            ),
            SizedBox(height: 16.0),
            Text(
              'Pertanyaan ${currentIndex + 1} dari ${questions.length}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              question['question'],
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            ...List<Widget>.generate(
              question['options'].length,
              (optionIndex) {
                return RadioListTile<int>(
                  title: Text(question['options'][optionIndex]),
                  value: optionIndex,
                  groupValue: answers[currentIndex],
                  onChanged: (value) {
                    setState(() {
                      answers[currentIndex] = value!;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentIndex > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex--;
                  });
                },
                child: Text('Sebelumnya'),
              ),
            if (currentIndex < questions.length - 1)
              ElevatedButton(
                onPressed: () {
                  if (answers[currentIndex] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mohon jawab pertanyaan terlebih dahulu.'),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    currentIndex++;
                  });
                },
                child: Text('Selanjutnya'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (answers[currentIndex] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mohon jawab pertanyaan terlebih dahulu.'),
                      ),
                    );
                    return;
                  }
                  calculateScore();
                  submitAnswers();
                },
                child: Text('Selesai'),
              ),
          ],
        ),
      ),
    );
  }
}
