import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swasthasewa_final/consult_page.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('symptoms_records');
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _databaseRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final List<Map<String, dynamic>> fetchedRecords = [];
          data.forEach((key, value) {
            fetchedRecords.add({
              'id': key, // Firebase key
              'symptoms': value['symptoms'] ?? [],
              'description': value['description'] ?? '',
              'status': value['status'] ?? 'Pending',
            });
          });

          setState(() {
            _records = fetchedRecords;
            _isLoading = false;
          });
        } else {
          setState(() {
            _records = [];
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _databaseRef.child(id).update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const Center(child: Text('No records found.'))
          : ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptoms: ${record['symptoms'].join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Description: ${record['description']}'),
                  const SizedBox(height: 8),
                  Text('Status: ${record['status']}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [


                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  ),
                  onPressed: () {
              // Retrieve the current logged-in user
                  final User? currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser != null) {
                  final userId = record['id']; // Assuming the record ID represents the user
                  final doctorId = currentUser.uid; // Get the current doctor's UID

                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultPage(
                      userId: userId,
                      doctorId: doctorId,
                       ),
                    ),
                 );
                 } else {
                   // Show error message if no doctor is logged in
                    ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text('Error: Doctor is not logged in.'),
                       backgroundColor: Colors.red,
                      ),
                   );
                 }
               },
                child: const Text('Consult'),
          ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                        ),
                        onPressed: record['status'] == 'Book Appointment'
                            ? null
                            : () => _updateStatus(record['id'], 'Book Appointment'),
                        child: const Text('Book Appointment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
