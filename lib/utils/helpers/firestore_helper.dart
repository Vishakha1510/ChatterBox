import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> insertUser({required String email}) async {
    //Check if a user(email) already exists in the database

    bool isUserExist = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        await querySnapshot.docs;

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in allDocs) {
      if (doc.data()['email'] == email) {
        isUserExist = true;
        break;
      }
    }

    if (isUserExist == false) {
      //Step-1: Fetch the id & count from records collection

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firebaseFirestore.collection("records").doc("users").get();

      int id = documentSnapshot.data()!['id'];
      int count = documentSnapshot.data()!['count'];

      //Step-2: Increment the id by 1
      id++;
      count++;

      //Step-3: Insert the record by that

      await firebaseFirestore.collection('users').doc("${id}").set({
        "email": email,
        "timestamp": DateTime.now(),
      });

      //Step-4: Update the incremented id to the records collection

      await firebaseFirestore.collection('records').doc("users").update({
        "id": id,
        "count": count,
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot =
        firebaseFirestore.collection("users").snapshots();
    return querySnapshot;
  }

  Future<String> createOrGetChatroom({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    bool isChatroomExists = false;
    String chatroomId = "";

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    allChatrooms.forEach((chatroom) {
      List users = chatroom.data()['users'];
      if (users.contains(senderEmail) && users.contains(receiverEmail)) {
        isChatroomExists = true;
        chatroomId = chatroom.id;
        return;
      }
    });
    if (isChatroomExists == false) {
      chatroomId = senderEmail + "_" + receiverEmail;
      await firebaseFirestore.collection("chatrooms").doc(chatroomId).set({
        'users': [senderEmail, receiverEmail],
      });
    }
    return chatroomId;
  }

  Future<void> sendChatMessage({
    required String senderEmail,
    required String receiverEmail,
    required String message,
  }) async {
    String chatroomId = await createOrGetChatroom(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
    );

    await firebaseFirestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .add({
          "senderEmail": senderEmail,
          "receiverEmail": receiverEmail,
          "message": message,
          "timestamp": DateTime.now(),
        });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAllMessages({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    String chatroomId = await createOrGetChatroom(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
    );
    DocumentSnapshot<Map<String, dynamic>> chatroomSnapshot =
        await firebaseFirestore.collection("chatrooms").doc(chatroomId).get();

    if (!chatroomSnapshot.exists) {
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore
            .collection("chatrooms")
            .doc(chatroomId)
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages =
        querySnapshot.docs;

    return allMessages;
  }

  Future<void> deleteMessage({
    required String senderEmail,
    required String receiverEmail,
    required String messageDocId,
  }) async {
    String chatroomId = await createOrGetChatroom(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
    );
    await firebaseFirestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .delete();
  }

  Future<void> updateMessage({
    required String senderEmail,
    required String receiverEmail,
    required String messageDocId,
    required String updatedMessage,
  }) async {
    String chatroomId = await createOrGetChatroom(
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
    );

    await firebaseFirestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .update({'message': updatedMessage});
  }
}
// Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAllMessages({
  //   required String senderEmail,
  //   required String receiverEmail,
  // }) async {
  //   String chatroomId = await createOrGetChatroom(
  //     senderEmail: senderEmail,
  //     receiverEmail: receiverEmail,
  //   );

  //   QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //       await firebaseFirestore
  //           .collection("chatrooms")
  //           .doc(chatroomId)
  //           .collection("messages")
  //           .orderBy("timestamp", descending: true)
  //           .get();

  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages =
  //       querySnapshot.docs;

  //   return allMessages;
  // }
