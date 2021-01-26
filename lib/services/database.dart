import 'package:flutter/foundation.dart';
import 'package:time_tracker/app/home/model/job.dart';
import 'package:time_tracker/services/api-path.dart';
import 'package:time_tracker/services/firestore-services.dart';

abstract class Database {
  Future<void> setJob(Job job);

  Future<void> deleteJob(Job job);

  Stream<List<Job>> jobsStream();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirebaseDatabase implements Database {
  FirebaseDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  final _services = FirestoreServices.instance;

  @override
  Future<void> setJob(Job job) async => await _services.setData(
        path: APIpath.job(uid, job.id),
        data: job.toMap(),
      );

  @override
  Future<void> deleteJob(Job job) async => await _services.deleteData(
        path: APIpath.job(uid, job.id),
      );

  @override
  Stream<List<Job>> jobsStream() => _services.collectionStream(
        path: APIpath.jobs(uid),
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );
}
