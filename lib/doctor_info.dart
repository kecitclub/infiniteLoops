import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const DoctorInfoPage(),
    );
  }
}

class DoctorInfoPage extends StatefulWidget {
  const DoctorInfoPage({super.key});

  @override
  _DoctorInfoPageState createState() => _DoctorInfoPageState();
}

class _DoctorInfoPageState extends State<DoctorInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  bool _isLoading = false;

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    _degreeController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> addData(Doctor doctor) async {
    setState(() => _isLoading = true);
    try {
      await databaseRef.child("doctors").push().set(doctor.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doctor registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _degreeController.clear();
    _specializationController.clear();
    _experienceController.clear();
    _licenseNumberController.clear();
    _institutionController.clear();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    Doctor doctor = Doctor(
      degree: _degreeController.text,
      specialization: _specializationController.text,
      experience: _experienceController.text,
      licenseNumber: _licenseNumberController.text,
      institution: _institutionController.text,
    );

    addData(doctor);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Doctor Registration Form',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _degreeController,
                            decoration: const InputDecoration(
                              labelText: "Medical Degree",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.school),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your degree';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _specializationController,
                            decoration: const InputDecoration(
                              labelText: "Specialization",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your specialization';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _experienceController,
                            decoration: const InputDecoration(
                              labelText: "Years of Experience",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter years of experience';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _licenseNumberController,
                            decoration: const InputDecoration(
                              labelText: "Medical License Number",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter license number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _institutionController,
                            decoration: const InputDecoration(
                              labelText: "Working Institution",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter institution name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Register Doctor",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class Doctor {
  String degree;
  String specialization;
  String experience;
  String licenseNumber;
  String institution;

  Doctor({
    required this.degree,
    required this.specialization,
    required this.experience,
    required this.licenseNumber,
    required this.institution,
  });

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'specialization': specialization,
      'experience': experience,
      'licenseNumber': licenseNumber,
      'institution': institution,
      'registrationDate': ServerValue.timestamp,
    };
  }
}
