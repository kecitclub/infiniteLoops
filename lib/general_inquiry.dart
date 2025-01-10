import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GeneralInquiryPage extends StatefulWidget {
  const GeneralInquiryPage({super.key});

  @override
  State<GeneralInquiryPage> createState() => _GeneralInquiryPageState();
}

class _GeneralInquiryPageState extends State<GeneralInquiryPage> {
  // List of symptoms with potential causes
  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Fever', 'cause': 'Fever is typically caused by infections (e.g., viral or bacterial), inflammation, or heat exhaustion.'},
    {'name': 'Fatigue', 'cause': 'Fatigue can be caused by overexertion, lack of sleep, stress, anemia, or chronic conditions like diabetes.'},
    {'name': 'Chills', 'cause': 'Chills are usually caused by infections (like the flu), fever, or exposure to cold weather.'},
    {'name': 'Night Sweats', 'cause': 'Night sweats can result from infections (e.g., tuberculosis), menopause, certain medications, or hormonal disorders.'},
    {'name': 'Headache', 'cause': 'Headaches can be triggered by stress, dehydration, sinus infections, or underlying conditions like migraines or tension.'},
    {'name': 'Sore Throat', 'cause': 'A sore throat is often caused by viral infections like the common cold or strep throat, or irritants like smoke.'},
    {'name': 'Runny Nose', 'cause': 'Runny noses are commonly caused by colds, allergies, or sinus infections.'},
    {'name': 'Cough', 'cause': 'A cough is usually caused by respiratory infections (cold, flu), allergies, or irritants like smoke or pollution.'},
    {'name': 'Abdominal Pain', 'cause': 'Abdominal pain can be caused by digestive issues like indigestion, constipation, or more serious conditions like ulcers or appendicitis.'},
    {'name': 'Body Pain', 'cause': 'Body aches can result from viral infections like flu, overexertion, fibromyalgia, or autoimmune conditions.'},
    {'name': 'Joint Pain', 'cause': 'Joint pain is often caused by conditions like arthritis, overuse, or injury.'},
    {'name': 'Dizziness', 'cause': 'Dizziness can be caused by dehydration, low blood pressure, inner ear problems, or even anxiety.'},
    {'name': 'Rash', 'cause': 'Rashes can be caused by allergic reactions, infections (e.g., chickenpox), or conditions like eczema or psoriasis.'},
  ];

  bool _isLoading = false;

  final TextEditingController _causeController = TextEditingController();

  @override
  void dispose() {
    _causeController.dispose();
    super.dispose();
  }

  // Method to add data to Firebase
  void addData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      final DatabaseReference inquiryRef = databaseRef.child('general_inquiries');

      // Collect all selected symptoms with their described causes
      final List<Map<String, dynamic>> causeDescriptions = [];
      for (var symptom in _symptoms) {
        if (symptom['cause'].isNotEmpty) {
          causeDescriptions.add({
            'symptom': symptom['name'],
            'cause': symptom['cause'],
          });
        }
      }

      if (causeDescriptions.isNotEmpty) {
        // Push data to Firebase
        await inquiryRef.push().set({
          'cause_descriptions': causeDescriptions,
          'timestamp': ServerValue.timestamp,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cause descriptions recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            // Clear the cause descriptions for the next entry
            for (var symptom in _symptoms) {
              symptom['cause'] = '';
            }
            _causeController.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide a cause for at least one symptom.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Inquiry - Cause of Symptoms'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the cause of your symptoms:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // List symptoms and their cause description text fields
            Expanded(
              child: ListView.builder(
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _symptoms[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            symptom['cause'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _causeController,
                            onChanged: (text) {
                              setState(() {
                                symptom['cause'] = text;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Describe the cause of ${symptom['name']}',
                              hintText: 'Enter possible cause...',
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: addData,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}