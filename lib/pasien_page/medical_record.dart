import 'package:coba/pasien_page/medical_record_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalRecordPage extends StatelessWidget {
  const MedicalRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Rekam Medis')),
        body: Center(
          child: Text('Silakan login untuk melihat rekam medis.'),
        ),
      );
    }

    final currentUserId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rekam Medis', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medical_records')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada rekam medis.'));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('No RM: ${record['patientRecordNumber']}'),
                  subtitle: Text('Tanggal: ${record['date']}'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalRecordDetailPage(
                          record: {
                            'patientName': record['patientName'],
                            'patientRecordNumber': record['patientRecordNumber'],
                            'psychologistName': record['psychologistName'],
                            'date': record['date'],
                            'time': record['time'],
                            'keluhan': record['keluhan'],
                            'diagnosis': record['diagnosis'],
                            'therapySuggestion': record['therapySuggestion'],
                            'nextControl': record['nextControl'],
                            'createdAt': record['createdAt'],
                          }
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
