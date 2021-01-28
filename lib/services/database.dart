import 'package:flutter/foundation.dart';
import 'package:time_tracker/app/home/model/entry.dart';
import 'package:time_tracker/app/home/model/job.dart';
import 'package:time_tracker/services/api-path.dart';
import 'package:time_tracker/services/firestore-services.dart';

abstract class Database {
  Future<void> setJob(Job job);
  Future<void> deleteJob(Job job);
  Stream<List<Job>> jobsStream();

  Future<void> setEntry(Entry entry);
  Future<void> deleteEntry(Entry entry);
  Stream<List<Entry>> entriesStream({Job job});

  Stream<Job> jobStream({@required String jobId});
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirebaseDatabase implements Database {
  FirebaseDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  final _service = FirestoreServices.instance;

  @override
  Future<void> setJob(Job job) async => await _service.setData(
        path: APIpath.job(uid, job.id),
        data: job.toMap(),
      );
//when deleting the particular job this function also delete all the entries associated with that job
// in other word
//All entries matching the job id are deleted manually,Why? Because entries are not a sub-collection of a job document
  @override
  Future<void> deleteJob(Job job) async {
    final allEntries = await entriesStream(job: job).first;
    for (Entry entry in allEntries) {
      if (entry.jobId == job.id) {
        await deleteEntry(entry);
      }
    }
    await _service.deleteData(path: APIpath.job(uid, job.id));
  }

  @override
  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: APIpath.jobs(uid),
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );

//Entry section
  @override
  Future<void> setEntry(Entry entry) async => await _service.setData(
        path: APIpath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  @override
  Future<void> deleteEntry(Entry entry) async =>
      await _service.deleteData(path: APIpath.entry(uid, entry.id));

  @override
  Stream<List<Entry>> entriesStream({Job job}) =>
      _service.collectionStream<Entry>(
        path: APIpath.entries(uid),
        queryBuilder: job != null
            ? (query) => query.where('jobId', isEqualTo: job.id)
            : null,
        builder: (data, documentID) => Entry.fromMap(data, documentID),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );

  Stream<Job> jobStream({@required String jobId}) => _service.documentStream(
        path: APIpath.job(uid, jobId),
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );
}
