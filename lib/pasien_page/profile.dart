import 'package:coba/pasien_page/login.dart';
import 'package:coba/pasien_page/registration_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required String username, required email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? username;
  String? email;
  String password = '******';
  bool isLoading = true;
  bool isPatientRegistered = false;
  String? nik, nama, tempatLahir, tanggalLahir, jenisKelamin, noTelp, namaIbu, golonganDarah, alamat, noRM;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPatientData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          username = userData['username'] as String?;
          email = user.email;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchPatientData() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot patientData = await _firestore
            .collection('patients')
            .doc(userId)
            .get();

        if (patientData.exists) {
          setState(() {
            nik = patientData['nik'];
            nama = patientData['nama'];
            tempatLahir = patientData['tempatLahir'];
            tanggalLahir = patientData['tanggalLahir'];
            jenisKelamin = patientData['jenisKelamin'];
            noTelp = patientData['noTelp'];
            namaIbu = patientData['namaIbu'];
            golonganDarah = patientData['golonganDarah'];
            alamat = patientData['alamat'];
            noRM = patientData['noRM'];
            isPatientRegistered = true;
          });
        } else {
          setState(() {
            isPatientRegistered = false;
          });
        }
      } catch (e) {
        print('Error fetching patient data: $e');
      }
    }
  }

  void _navigateToRegistrationForm() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrationFormPage(),
      ),
    );

    // Refresh patient data if registration was successful
    if (result == true) {
      _fetchPatientData();
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildPatientCard(),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _showLogoutConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: const Color(0xFF5EA8A7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileField('Username', username ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField('Email', email ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField('Password', password),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    if (!isPatientRegistered) {
      return Card(
        color: const Color(0xFF5EA8A7),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Anda belum terdaftar sebagai pasien",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: _navigateToRegistrationForm,
                child: const Text("Klik di sini untuk mendaftar", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF5EA8A7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildProfileField("No RM", noRM ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("NIK", nik ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Nama", nama ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Tempat Lahir", tempatLahir ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Tanggal Lahir", tanggalLahir ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Jenis Kelamin", jenisKelamin ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("No Telp", noTelp ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Nama Ibu", namaIbu ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Golongan Darah", golonganDarah ?? 'N/A'),
            const SizedBox(height: 10),
            _buildProfileField("Alamat", alamat ?? 'N/A'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
