import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RegistrationFormPage extends StatefulWidget {
  const RegistrationFormPage({super.key});

  @override
  _RegistrationFormPageState createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedBloodType == null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap isi semua form'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception("User is not logged in.");
        }

        // Create medical record number based on timestamp
        String newRM = "MC${DateTime.now().millisecondsSinceEpoch}";

        // Save patient data to Firestore
        await _firestore.collection('patients').doc(user.uid).set({
          "noRM": newRM,
          "userId": user.uid,
          "nik": _nikController.text,
          "nama": _nameController.text,
          "tempatLahir": _birthPlaceController.text,
          "tanggalLahir": _birthDateController.text,
          "jenisKelamin": _selectedGender,
          "noTelp": _phoneController.text,
          "namaIbu": _motherNameController.text,
          "golonganDarah": _selectedBloodType,
          "alamat": _addressController.text,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        
        // Return to ProfilePage with a success result
        Navigator.pop(context, true);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration', style: (TextStyle(color: Colors.white))),
        backgroundColor: const Color(0xFF5EA8A7),
      ),
      body: Container(
      color: Colors.white, 
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nikController, 'NIK', 'NIK', TextInputType.number),
              _buildTextField(_nameController, 'Nama', 'Nama lengkap'),
              _buildTextField(_birthPlaceController, 'Tempat lahir', 'ex: Jakarta'),
              _buildDatePickerField(),
              _buildGenderSelection(),
              _buildTextField(_phoneController, 'No telp', '08xxxxxxxxxx', TextInputType.phone),
              _buildTextField(_motherNameController, 'Nama ibu', 'Nama ibu'),
              _buildBloodTypeSelection(),
              _buildTextField(_addressController, 'Alamat', 'Alamat lengkap', TextInputType.streetAddress),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5EA8A7),
                      ),
                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      [TextInputType inputType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Tanggal lahir',
          hintText: '(YYYY-MM-DD)',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderSelection() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Kelamin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: const Text('Laki-laki'),
          value: 'Laki-laki',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Perempuan'),
          value: 'Perempuan',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        if (_selectedGender == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Silakan pilih jenis kelamin',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
      ],
    ),
  );
}

  Widget _buildBloodTypeSelection() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Golongan Darah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: const Text('A'),
          value: 'A',
          groupValue: _selectedBloodType,
          onChanged: (value) {
            setState(() {
              _selectedBloodType = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('B'),
          value: 'B',
          groupValue: _selectedBloodType,
          onChanged: (value) {
            setState(() {
              _selectedBloodType = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('O'),
          value: 'O',
          groupValue: _selectedBloodType,
          onChanged: (value) {
            setState(() {
              _selectedBloodType = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('AB'),
          value: 'AB',
          groupValue: _selectedBloodType,
          onChanged: (value) {
            setState(() {
              _selectedBloodType = value;
            });
          },
        ),
        if (_selectedBloodType == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Silakan pilih golongan darah',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
      ],
    ),
  );
}
}
