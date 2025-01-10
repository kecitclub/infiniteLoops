import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:swasthasewa_final/doctor_info.dart';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  // Grouped symptoms by category
  final Map<String, List<Map<String, dynamic>>> _symptomCategories = {
    'General': [
      {'name': 'Fever', 'isSelected': false},
      {'name': 'Fatigue', 'isSelected': false},
      {'name': 'Chills', 'isSelected': false},
      {'name': 'Night Sweats', 'isSelected': false},
    ],
    'Head & Neck': [
      {'name': 'Headache', 'isSelected': false},
      {'name': 'Sore Throat', 'isSelected': false},
      {'name': 'Runny Nose', 'isSelected': false},
      {'name': 'Swollen Lymph Nodes', 'isSelected': false},
    ],
    'Chest & Breathing': [
      {'name': 'Cough', 'isSelected': false},
      {'name': 'Shortness of Breath', 'isSelected': false},
      {'name': 'Chest Pain', 'isSelected': false},
    ],
    'Digestive': [
      {'name': 'Nausea', 'isSelected': false},
      {'name': 'Loss of Appetite', 'isSelected': false},
      {'name': 'Diarrhea', 'isSelected': false},
      {'name': 'Vomiting', 'isSelected': false},
      {'name': 'Abdominal Pain', 'isSelected': false},
    ],
    'Pain & Discomfort': [
      {'name': 'Body Pain', 'isSelected': false},
      {'name': 'Joint Pain', 'isSelected': false},
    ],
    'Other': [
      {'name': 'Dizziness', 'isSelected': false},
      {'name': 'Rash', 'isSelected': false},
    ],
  };

  final TextEditingController _descriptionController = TextEditingController();
  final int _maxWords = 500;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  int _getWordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  List<Map<String, dynamic>> _getAllSelectedSymptoms() {
    List<Map<String, dynamic>> selected = [];
    _symptomCategories.forEach((category, symptoms) {
      selected.addAll(symptoms.where((symptom) => symptom['isSelected']));
    });
    return selected;
  }

  void addData() async {
    setState(() => _isLoading = true);
    
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      final DatabaseReference symptomsRef = databaseRef.child('symptoms_records');
      
      final selectedSymptoms = _getAllSelectedSymptoms()
          .map((symptom) => symptom['name'])
          .toList();

      final description = _descriptionController.text;

      final Map<String, dynamic> data = {
        'symptoms': selectedSymptoms,
        'description': description,
        'timestamp': ServerValue.timestamp,
      };

      await symptomsRef.push().set(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Symptoms recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _symptomCategories.forEach((_, symptoms) {
            for (var symptom in symptoms) {
              symptom['isSelected'] = false;
            }
          });
          _descriptionController.clear();
        });
      }
    } catch (e) {
      print('Error details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms Selection'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Your Symptoms:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._symptomCategories.entries.map((category) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            category.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: category.value.map((symptom) {
                            return CheckboxListTile(
                              title: Text(symptom['name']),
                              value: symptom['isSelected'],
                              onChanged: (bool? value) {
                                setState(() {
                                  symptom['isSelected'] = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Text(
                      'Describe your symptoms in detail:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter description (max 500 words)',
                        border: const OutlineInputBorder(),
                        counterText:
                            '${_getWordCount(_descriptionController.text)}/$_maxWords words',
                      ),
                      onChanged: (text) {
                        setState(() {});
                        if (_getWordCount(text) > _maxWords) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You have exceeded the maximum word limit'),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final selectedSymptoms = _getAllSelectedSymptoms();
                          final description = _descriptionController.text;

                          if (selectedSymptoms.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select at least one symptom'),
                              ),
                            );
                            return;
                          }

                          if (_getWordCount(description) > _maxWords) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please reduce the description length'),
                              ),
                            );
                            return;
                          }
                          addData();
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorInfo()));                        },
                        child: Text('Doctor Page'))
                  ],
                ),
              ),
            ),
    );
  }
}
