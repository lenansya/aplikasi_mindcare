import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coba/pasien_page/home.dart';

class TimeSelectionScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String psychologistId;
  final String psychologistName;

  const TimeSelectionScreen({
    super.key, 
    required this.selectedDate,
    required this.psychologistId,
    required this.psychologistName,
  });

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  String? _selectedTime;
  List<String> _availableTimes = [];
  List<String> _bookedTimes = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimes();
  }

  List<String> _generateAvailableTimes() {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(
        widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 13, 00);
    DateTime endTime = DateTime(
        widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 17, 00);

    List<String> availableTimes = [];

    while (startTime.isBefore(endTime)) {
      String formattedTime =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      if (widget.selectedDate.day > now.day || (widget.selectedDate.day == now.day && startTime.isAfter(now))) {
        availableTimes.add(formattedTime);
      }
      startTime = startTime.add(const Duration(minutes: 40));
    }

    return availableTimes;
  }

  Future<void> _fetchAvailableTimes() async {
    final formattedDate = "${widget.selectedDate.toLocal()}".split(' ')[0];

    final snapshots = await FirebaseFirestore.instance
        .collection('schedules')
        .where('date', isEqualTo: formattedDate)
        .where('statusConsultation', isEqualTo: 'booked')
        .get();

    List<String> bookedTimes = snapshots.docs.map((doc) => doc['time'] as String).toList();

    setState(() {
      _bookedTimes = bookedTimes;
      _availableTimes = _generateAvailableTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${widget.selectedDate.toLocal()}".split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Waktu Konseling', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5EA8A7),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Psikolog: ${widget.psychologistName}', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Tanggal: $formattedDate', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _availableTimes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final time = _availableTimes[index];
                  bool isSelected = _selectedTime == time;
                  bool isBooked = _bookedTimes.contains(time);

                  return GestureDetector(
                    onTap: isBooked
                        ? null
                        : () {
                            setState(() {
                              _selectedTime = isSelected ? null : time;
                            });
                          },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.grey[300]
                            : isSelected
                                ? const Color(0xFF5EA8A7)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF5EA8A7) : Colors.grey[400]!,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: isBooked
                              ? Colors.grey[600]
                              : isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30), // Mengatur jarak presisi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5EA8A7),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: _selectedTime != null
                  ? () {
                      _bookSchedule();
                    }
                  : null,
              child: const Text(
                'Lanjutkan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _bookSchedule() async {
    try {
      final formattedDate = "${widget.selectedDate.toLocal()}".split(' ')[0];
      final userId = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('schedules').add({
        'userId': userId,
        'date': formattedDate,
        'time': _selectedTime,
        'statusConsultation': 'booked',
        'psychologistName': widget.psychologistName,
        'channelName': '${userId}_$formattedDate',
      });

      await FirebaseFirestore.instance.collection('patients').doc(userId).update({
      'isAssessmentCompleted': false, 
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                const SizedBox(height: 10),
                const Text(
                  'Reservasi Berhasil!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Psikolog: ${widget.psychologistName}\nTanggal: $formattedDate\nJam: $_selectedTime',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage(username: '')),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error booking schedule: $e');
    }
  }
}
