import 'package:coba/pasien_page/asesmen.dart';
import 'package:coba/pasien_page/video_call.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  late Future<List<Map<String, dynamic>>> consultations;

  @override
  void initState() {
    super.initState();
    consultations = fetchBookedSchedules();
  }

  Future<List<Map<String, dynamic>>> fetchBookedSchedules() async {
    List<Map<String, dynamic>> consultations = [];
    final schedulesCollection = FirebaseFirestore.instance.collection('schedules');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in.');
      return consultations;
    }

    final currentUserId = user.uid;

    try {
      final scheduleSnapshot = await schedulesCollection
          .where('userId', isEqualTo: currentUserId)
          .where('statusConsultation', isEqualTo: 'booked')
          .get();

      for (var scheduleDoc in scheduleSnapshot.docs) {
        final scheduleData = scheduleDoc.data();
        if (scheduleData.isEmpty) continue;

        final patientDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUserId)
            .get();
        final patientData = patientDoc.data();

        if (patientData != null) {
          final channelName = '${currentUserId}_${scheduleData['date']}';

          if (!scheduleData.containsKey('channelName') || scheduleData['channelName'] != channelName) {
            try {
              await schedulesCollection.doc(scheduleDoc.id).update({
                'channelName': channelName,
              });
              print('ChannelName successfully saved: $channelName');
            } catch (e) {
              print('Error saving channelName: $e');
            }
          }

          consultations.add({
            'patientName': patientData['nama'],
            'patientRecordNumber': patientData['noRM'],
            'date': scheduleData['date'],
            'time': scheduleData['time'],
            'channelName': channelName,
            'scheduleId': scheduleDoc.id,
            'isAssessmentCompleted': patientData['isAssessmentCompleted'] ?? false,
            'scheduledTime': DateFormat('yyyy-MM-dd HH:mm').parse('${scheduleData['date']} ${scheduleData['time']}'),
            'statusConsultation': scheduleData['statusConsultation'] ?? 'booked',
            'psychologistName': scheduleData['psychologistName'] ?? "Tidak Diketahui",
          });
        } else {
          print('Patient data not found for userId: $currentUserId');
        }
      }
    } catch (e) {
      print('Error fetching booked schedules: $e');
    }

    return consultations;
  }

  Future<void>markConsultationAsDone(String scheduleId, Map<String, dynamic> consultation)async{
    try{
      await FirebaseFirestore.instance
        .collection('schedules')
        .doc(scheduleId)
        .update({'statusConsultation': 'done'});
      await FirebaseFirestore.instance.collection('schedules').doc(scheduleId).update({
        'statusConsultation': 'done',
      });
      await FirebaseFirestore.instance.collection('medical_records').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'patientName': consultation['patientName'],
        'patientRecordNumber': consultation['patientRecordNumber'],
        'psychologistName': consultation['psychologistName'],
        'date': consultation['date'],
        'time': consultation['time'],
        'keluhan': 'Keluhan akan diisi oleh psikolog',
        'diagnosis': 'Diagnosis akan diisi oleh psikolog',
        'therapySuggestion': 'Saran terapi akan diisi oleh psikolog',
        'nextControl': 'Tanggal kontrol berikutnya akan diisi oleh psikolog',
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konsultasi telah ditandai sebagai selesai'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e){
      print('Error update status konsultasi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status konsultasi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void startVideoCall(String channelName, bool isAssessmentCompleted, String date, String time) {
    if (!isAssessmentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi asesmen terlebih dahulu sebelum memulai konsultasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } 
  try{
    if(date.isEmpty || time.isEmpty){
      throw FormatException("Tanggal atau waktu kosong");
    }
    String dateTimeString = '$date $time';
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeString);
    DateTime startAllowed = scheduledTime.subtract(Duration(minutes: 5));
    DateTime endAllowed = scheduledTime.add(Duration(minutes: 40));

    if(now.isBefore(startAllowed)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Belum waktu Anda untuk melakukan konsultasi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    } else if(now.isAfter(endAllowed)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waktu konsultasi Anda telah berakhir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallPage(channelName: channelName),
        ),
      );
    } catch (e){
      print("Error parsing date/time: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanggal atau waktu tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openAssessmentForm(bool isAssessmentCompleted) {
    if (isAssessmentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form asesmen sudah diisi. Anda tidak dapat mengisi lagi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AssessmentForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Jadwal Konsultasi'),
          backgroundColor: Color(0xFF5EA8A7),
        ),
        body: Center(
          child: Text('Silakan login untuk melihat jadwal konsultasi.'),
        ),
      );
    }

    final currentUserId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Konsultasi', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (patientSnapshot.hasError) {
            return Center(child: Text('Error: ${patientSnapshot.error}'));
          }

          final patientData = patientSnapshot.data?.data() as Map<String, dynamic>?;
          final isAssessmentCompleted = patientData?['isAssessmentCompleted'] ?? false;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: consultations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Image.asset(
                        'assets/article10.png', 
                        height: 350, 
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16), 
                      Text(
                        'Anda tidak memiliki jadwal konsultasi',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final consultationWidgets = snapshot.data!.map((consultation) {
                final now = DateTime.now();
                final scheduledTime = consultation['scheduledTime'];
                final startAllowed = scheduledTime.subtract(Duration(minutes: 5));
                final endAllowed = scheduledTime.add(Duration(minutes: 40));
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(consultation['patientName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No RM: ${consultation['patientRecordNumber']}'),
                        Text('Psikolog: ${consultation['psychologistName']}'),
                        Text('Tanggal: ${consultation['date']}'),
                        Text('Jam: ${consultation['time']}'),
                        Text(
                          isAssessmentCompleted
                              ? 'Form asesmen telah diisi'
                              : 'Form asesmen belum diisi',
                          style: TextStyle(
                            color: isAssessmentCompleted ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!consultation['isAssessmentCompleted'] && consultation['statusConsultation'] != 'done')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssessmentForm(),
                              ),
                            );
                          },
                          child: const Text('Isi Form Asesmen'),
                        ),
                        if (consultation['statusConsultation'] == 'done')
                          Text(
                            'Konsultasi Selesai',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if(now.isAfter(endAllowed) && consultation['statusConsultation']!='done')
                          ElevatedButton(
                            onPressed: () => markConsultationAsDone(
                              consultation['scheduleId'],
                              consultation,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ), 
                            child: Text('Selesai', style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.video_call),
                      onPressed: () {
                      if (now.isAfter(startAllowed) && now.isBefore(endAllowed)) {
                        startVideoCall(
                          consultation['channelName'],
                          isAssessmentCompleted,
                          consultation['date'],
                          consultation['time'],
                        );
                      } else if (now.isBefore(startAllowed)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Konsultasi belum tersedia. Tunggu hingga waktu konsultasi dimulai.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else if (now.isAfter(endAllowed)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Waktu konsultasi telah berakhir.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                      color: now.isAfter(startAllowed) && now.isBefore(endAllowed)
                      ? Colors.blue
                      : Colors.grey,
                    ),
                  ),
                );
              }).toList();
              return ListView(
                children: consultationWidgets,
              );
            },
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}