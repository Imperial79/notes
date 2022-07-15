import 'package:cloud_firestore/cloud_firestore.dart';

import 'globalVariable.dart';

class DatabaseMethods {
  //Adding user to database QUERY
  addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  //Uploading transactions to database QUERY
  uploadNotes(String username, noteMap, String labelName, String time) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .collection('notes')
        .doc(time)
        .set(noteMap);
  }

  //fetching transactions from database
  getNotesByLabel(String username, String labelName) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection('notes')
        .where('label', isEqualTo: labelName)
        .orderBy("time", descending: true)
        .snapshots();
  }

  getAllNotes() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(UserName.userName)
        .collection('notes')
        .orderBy("time", descending: true)
        .snapshots();
  }

  getlabel() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserName.userName)
        .collection('labelList')
        .get();
  }

  updatelabel(List labelList) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserName.userName)
        .collection('labelList')
        .doc('list')
        .set({'labelList': labelList});
  }

  fetchLabel() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserName.userName)
        .collection('labelList')
        .snapshots();
  }

  updateNote(String time, Map<String, dynamic> updatedNoteMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserName.userName)
        .collection('notes')
        .doc(time)
        .update(updatedNoteMap);
  }

  //Delete all transacts
  // deleteAllTransacts(String username) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(username)
  //       .collection('transacts')
  //       .get()
  //       .then((snapshot) {
  //     for (DocumentSnapshot ds in snapshot.docs) {
  //       ds.reference.delete();
  //     }
  //   });
  // }

  //Delete all transacts
  deleteNote(String username, String time, String labelName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .collection('notes')
        .where('time', isEqualTo: time)
        .limit(1)
        .get()
        .then(
      (snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      },
    );
  }
}
