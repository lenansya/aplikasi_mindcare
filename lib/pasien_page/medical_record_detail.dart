import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicalRecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const MedicalRecordDetailPage({required this.record, super.key});

  @override
  Widget build(BuildContext context) {
    final createdAt = record['createdAt'] is Timestamp
        ? (record['createdAt'] as Timestamp).toDate().toString()
        : record['createdAt'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Rekam Medis', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Pasien: ${record['patientName']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('No RM: ${record['patientRecordNumber']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Psikolog: ${record['psychologistName']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Tanggal: ${record['date']}', style: TextStyle(fontSize: 16)),
            Text('Waktu: ${record['time']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Keluhan: ${record['keluhan']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Diagnosis: ${record['diagnosis']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Saran Terapi: ${record['therapySuggestion']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Kontrol Berikutnya: ${record['nextControl']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Dibuat Pada: $createdAt', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
