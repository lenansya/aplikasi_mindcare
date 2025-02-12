import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'time_selection.dart';

class DateSelectionScreen extends StatefulWidget {
  final String userId;
  final String psychologistId;
  final String psychologistName;

  const DateSelectionScreen({
    super.key, 
    required this.userId, 
    required this.psychologistId,
    required this.psychologistName, 
  });

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime currentDateTime = DateTime.now(); // Langsung inisialisasi
  Timer? _timer; // Timer dibuat nullable untuk menghindari error

  @override
  void initState() {
    super.initState();

    // Timer untuk memperbarui waktu setiap menit
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dihentikan saat widget dihancurkan
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!isSameDay(currentDateTime, now)) {
      setState(() {
        currentDateTime = now; // Perbarui waktu hanya jika hari berubah
      });
    }
  }

  // Daftar hari libur nasional
  final List<DateTime> nationalHolidays = [
    DateTime(2025, 1, 1), // Tahun Baru
    DateTime(2025, 2, 19), // Contoh libur nasional
    // Tambahkan libur lainnya
  ];

  // Fungsi untuk mengecek apakah tanggal adalah hari libur
  bool isHoliday(DateTime day) {
    return nationalHolidays.any((holiday) => isSameDay(day, holiday));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Tanggal Konseling',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5EA8A7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Psikolog: ${widget.psychologistName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(DateTime.now().year, DateTime.now().month + 3, 0),
                  focusedDay: currentDateTime,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  selectedDayPredicate: (day) => isSameDay(currentDateTime, day),
                  enabledDayPredicate: (day) {
                    return day.weekday >= DateTime.monday &&
                        day.weekday <= DateTime.thursday &&
                        !isHoliday(day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      currentDateTime = selectedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, _) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5EA8A7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5EA8A7),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                // Navigasi ke layar pemilihan waktu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeSelectionScreen(
                      selectedDate: currentDateTime, 
                      psychologistId: widget.psychologistId, 
                      psychologistName: widget.psychologistName,
                    ),
                  ),
                );
              },
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
}
