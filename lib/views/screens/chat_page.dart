import 'package:chatterbox/utils/helpers/firebase_auth_helper.dart';
import 'package:chatterbox/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  String? updatedMessage;
  @override
  Widget build(BuildContext context) {
    String receiverEmail = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(receiverEmail, textAlign: TextAlign.center),
      ),
      body: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: FutureBuilder(
                future: FirestoreHelper.firestoreHelper.fetchAllMessages(
                  senderEmail:
                      FirebaseAuthHelper.firebaseAuth.currentUser!.email
                          as String,
                  receiverEmail: receiverEmail,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                        snapshot.data;

                    return (data == null || data.isEmpty)
                        ? Center(child: Text("No any messages yet.."))
                        : ListView.builder(
                          reverse: true,
                          itemCount: data.length,
                          itemBuilder: (context, i) {
                            return Row(
                              mainAxisAlignment:
                                  (data[i].data()['receiverEmail'] ==
                                          receiverEmail)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  child: Chip(
                                    label: Text("${data[i].data()['message']}"),
                                  ),
                                  onLongPress: () {
                                    _showOptionsDialog(
                                      context,
                                      data[i],
                                      receiverEmail,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      await FirestoreHelper.firestoreHelper.sendChatMessage(
                        senderEmail:
                            FirebaseAuthHelper.firebaseAuth.currentUser!.email
                                as String,
                        receiverEmail: receiverEmail,
                        message: messageController.text,
                      );
                      messageController.clear();
                      setState(() {});
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 24,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String receiverEmail,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (receiverEmail != document.data()['receiverEmail'])
                      ? Container()
                      : ListTile(
                        leading: Icon(Icons.edit),
                        title: Text("Edit"),
                        onTap: () {
                          Navigator.of(context).pop();

                          _handleEdit(context, document, receiverEmail);
                        },
                      ),
                  (receiverEmail != document.data()['receiverEmail'])
                      ? Container()
                      : Divider(height: 1, thickness: 1),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("Delete"),
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleDelete(context, document, receiverEmail);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleEdit(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String receiverEmail,
  ) {
    String currentMessage = document.data()['message'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Edit Message"),
            content: TextFormField(
              initialValue: currentMessage,
              onChanged: (val) {
                updatedMessage = val;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirestoreHelper.firestoreHelper.updateMessage(
                    senderEmail:
                        FirebaseAuthHelper.firebaseAuth.currentUser!.email
                            as String,
                    receiverEmail: receiverEmail,
                    messageDocId: document.id,
                    updatedMessage: updatedMessage as String,
                  );
                  setState(() {});
                },
                child: Text("Update"),
              ),
            ],
          ),
    );
  }

  void _handleDelete(
    BuildContext context,
    DocumentSnapshot document,
    String receiverEmail,
  ) async {
    await FirestoreHelper.firestoreHelper.deleteMessage(
      senderEmail: FirebaseAuthHelper.firebaseAuth.currentUser!.email as String,
      receiverEmail: receiverEmail,
      messageDocId: document.id,
    );
    setState(() {});
  }
}
