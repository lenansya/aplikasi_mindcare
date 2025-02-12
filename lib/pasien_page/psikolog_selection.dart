import 'package:coba/pasien_page/date_selection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PsychologistSelectionScreen extends StatelessWidget {
  final String userId;

  const PsychologistSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Psikolog',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5EA8A7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('psychologists').snapshots(),
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for the stream
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if the collection is empty or there's no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada psikolog yang tersedia.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          // Get the list of psychologists from the snapshot
          final psychologists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: psychologists.length,
            itemBuilder: (context, index) {
              final data = psychologists[index].data() as Map<String, dynamic>;

              // Ensure data consistency by handling potential null fields
              final psychologistName = data['name'] ?? 'Nama tidak tersedia';
              final specialization = data['specialization'] ?? 'Spesialisasi tidak tersedia';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      psychologistName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(psychologistName),
                  subtitle: Text(specialization),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DateSelectionScreen(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          psychologistId: psychologists[index].id,
                          psychologistName: psychologistName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}
