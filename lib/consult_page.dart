import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final int timestamp;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });
}

class ConsultPage extends StatefulWidget {
  final String userId;
  final String doctorId;

  const ConsultPage({
    required this.userId,
    required this.doctorId,
    super.key,
  });

  @override
  State<ConsultPage> createState() => _ConsultPageState();
}

class _ConsultPageState extends State<ConsultPage> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref().child('chats');
  final TextEditingController _messageController = TextEditingController();

  late String _chatId;
  late String _senderId;
  late bool _isDoctor;

  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();

    _chatId = '${widget.userId}_${widget.doctorId}';
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _senderId = currentUser.uid;
      _isDoctor = _senderId == widget.doctorId;
    }

    _setupMessageListener();
  }

  void _setupMessageListener() {
    _messagesRef.child('-OGE3MeNBdWzZ-diQuxw_ruQMvqMqJkS62Svi2hyhqKDzZJg1/messages').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _updateMessages(data);
      }
    });
  }

  void _updateMessages(Map<String, dynamic> messages) {
    setState(() {
      _messages = messages.entries.map((entry) {
        final message = entry.value as Map<String, dynamic>;
        return MessageModel(
          id: entry.key,
          text: message['text'],
          senderId: message['senderId'],
          timestamp: message['timestamp'],
        );
      }).toList();
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    try {
      final messageRef = _messagesRef.child('-OGE3MeNBdWzZ-diQuxw_ruQMvqMqJkS62Svi2hyhqKDzZJg1/messages').push();
      final messageData = {
        'senderId': _senderId,
        'text': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await messageRef.set(messageData);
      setState(() {
        _messages.add(MessageModel(
          id: messageRef.key!,
          text: message,
          senderId: _senderId,
          timestamp: messageData['timestamp'] as int,
        ));
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.child('-OGE3MeNBdWzZ-diQuxw_ruQMvqMqJkS62Svi2hyhqKDzZJg1/messages').orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final messages = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

                  final sortedMessages = messages.entries.toList()
                    ..sort((a, b) => a.value['timestamp'].compareTo(b.value['timestamp']));

                  return ListView.builder(
                    itemCount: sortedMessages.length,
                    itemBuilder: (context, index) {
                      final message = sortedMessages[index].value;
                      final isSender = message['senderId'] == _senderId;

                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.green[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(message['text']),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('No messages yet.'));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Enter your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
