import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreServices {
  FirestoreServices._(); //creating private constructor
  static final instance = FirestoreServices._(); //singleton design pattern
  Future<void> setData({String path, Map<String, dynamic> data}) async {
    final documentReference = FirebaseFirestore.instance.doc(path);
    print("$path :==> $data");
    await documentReference.set(data);
  }

  Future<void> deleteData({@required String path}) async {
    final documentReference = FirebaseFirestore.instance.doc(path);
    print("Path: $path");
    await documentReference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots(); //list of collections
    return snapshots.map(
      (snapshot) => snapshot.docs
          .map(
            (snapshot) => builder(snapshot.data(), snapshot.id),
          )
          .toList(),
    );
  }
}
