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
    @required
        T builder(Map<String, dynamic> data,
            String documentID), //object(builder) of type T
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
  }) {
    Query query = FirebaseFirestore.instance
        .collection(path); //Query is the base class of collection
    if (queryBuilder != null) {
      query = queryBuilder(
          query); //calling function of type Query and returns a particular query value
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentID),
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data(), snapshot.id));
  }
}
