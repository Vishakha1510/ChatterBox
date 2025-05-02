import 'package:chatterbox/utils/helpers/firebase_auth_helper.dart';
import 'package:chatterbox/utils/helpers/firestore_helper.dart';
import 'package:chatterbox/views/components/drawer_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    User? user = ModalRoute.of(context)!.settings.arguments as User?;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("HOME"),
        actions: [
          IconButton(
            onPressed: () {
              Get.changeTheme(
                Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
              );
            },
            icon:
                (Get.isDarkMode)
                    ? Icon(Icons.light_mode)
                    : Icon(Icons.dark_mode),
          ),
        ],
      ),
      drawer: DrawerComponent(user: user),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
          stream: FirestoreHelper.firestoreHelper.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("ERROR: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  (data == null) ? [] : data.docs;

              return (allDocs.isEmpty)
                  ? Center(child: Text("No any data available"))
                  : ListView.builder(
                    itemCount: allDocs.length,
                    itemBuilder: (context, i) {
                      Timestamp timestamp =
                          allDocs[i].data()['timestamp'] as Timestamp;
                      final currentUserEmail =
                          FirebaseAuthHelper.firebaseAuth.currentUser?.email;

                      return Card(
                        elevation: 3,
                        child: ListTile(
                          leading: Text("${i + 1}"),
                          title:
                              (currentUserEmail != null &&
                                      currentUserEmail ==
                                          allDocs[i].data()['email'])
                                  ? Text("${allDocs[i].data()['email']} (You)")
                                  : Text("${allDocs[i].data()['email']}"),
                          subtitle: Text(
                            "${timestamp.toDate().day} / ${timestamp.toDate().month} / ${timestamp.toDate().year}",
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              'chat_page',
                              arguments: allDocs[i].data()['email'],
                            );
                          },
                        ),
                      );
                    },
                  );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
