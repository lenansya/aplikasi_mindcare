import 'package:coba/pasien_page/psikolog_selection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleSelection extends StatefulWidget {
  const ScheduleSelection({super.key});

  @override
  _ScheduleSelectionState createState() => _ScheduleSelectionState();
}

class _ScheduleSelectionState extends State<ScheduleSelection> {
  bool isRegistered = false;
  bool hasPendingConsultation = false;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      checkRegistrationStatus();
      checkPendingConsultation();
    }
  }

  Future<void> checkRegistrationStatus() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('patients').doc(userId).get();
      setState(() {
        isRegistered = doc.exists;
      });
    } catch (e) {
      print('Error checking registration status: $e');
    }
  }

  Future<void> checkPendingConsultation() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('userId', isEqualTo: userId)
          .where('statusConsultation', isEqualTo: 'booked')
          .get();

      setState(() {
        hasPendingConsultation = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking pending consultation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingin melakukan konsultasi?', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/article3.png',
              height: 380,
            ),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5EA8A7)),
                  onPressed: (){
                    if(!isRegistered){
                      //Jika belum terdaftar sebagai pasien
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Anda belum terdaftar sebagai pasien, harap lakukan pendaftaran terlebih dahulu'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (hasPendingConsultation){
                      //Jika memiliki jadwal konsultasi yang belum selesai
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Harap selesaikan konsultasi Anda sebelum membuat jadwal baru'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      //Jika semua kondisi terpenuhi, navigasi ke halaman pemilihan psikolog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PsychologistSelectionScreen(userId: userId)),
                      );
                    }
                  }, 
                  child: Text('Buat jadwal sekarang!', style: TextStyle(color: Colors.white)),
                ),
              )
            ),
          ],
        )
      ),
    );
  }
}