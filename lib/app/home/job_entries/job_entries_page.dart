import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:time_tracker/app/home/job_entries/entry_list_item.dart';
import 'package:time_tracker/app/home/job_entries/entry_page.dart';
import 'package:time_tracker/app/home/jobs/edit-job-form-page.dart';
import 'package:time_tracker/app/home/jobs/list-items-builder.dart';
import 'package:time_tracker/app/home/model/entry.dart';
import 'package:time_tracker/app/home/model/job.dart';
import 'package:time_tracker/services/database.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';

class JobEntriesPage extends StatelessWidget {
  const JobEntriesPage({@required this.database, @required this.job});
  final Database database;
  final Job job;

  static Future<void> show(BuildContext context,
      {Database database, Job job}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        //it gives parallax effect
        //instead of MaterialPageRoute
        fullscreenDialog: false,
        builder: (context) => JobEntriesPage(database: database, job: job),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on FirebaseException catch (e) {
      PlatformExceptionAwareDialog(
        title: 'Operation failed',
        firebaseException: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Job>(
        stream: database.jobStream(jobId: job.id),
        builder: (context, snapshot) {
          final job = snapshot.data;
          final jobName = job?.name ?? '';
          return Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              title: Text(jobName),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () => EditJobFormPage.show(context,
                      database: database, job: job),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () => EntryPage.show(
                    context: context,
                    database: database,
                    job: job,
                  ),
                ),
              ],
            ),
            body: _buildContent(context),
          );
        });
  }

  Widget _buildContent(BuildContext context) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(job: job),
      builder: (context, snapshot) {
        return ListItemsBuilder<Entry>(
          snapshot: snapshot,
          itemBuilder: (context, entry) {
            return DismissibleEntryListItem(
              key: Key('entry-${entry.id}'),
              entry: entry,
              job: job,
              onDismissed: () => _deleteEntry(context, entry),
              onTap: () => EntryPage.show(
                context: context,
                database: database,
                job: job,
                entry: entry,
              ),
            );
          },
        );
      },
    );
  }
}
