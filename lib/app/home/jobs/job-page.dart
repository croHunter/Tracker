import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/jobs/edit-job-form-page.dart';
import 'package:time_tracker/app/home/jobs/job-list-tile.dart';
import 'package:time_tracker/app/home/jobs/list-item-builder.dart';
import 'package:time_tracker/app/home/model/job.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/services/database.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';

class JobPage extends StatelessWidget {
  Future<void> _onSignOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await auth.signOut();
  }

  Future<void> _conformSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAwareDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Logout',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestSignOut) {
      await _onSignOut(context);
    }
  }

  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      PlatformExceptionAwareDialog(
        title: 'Operation failed',
        firebaseException: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jobs"),
        centerTitle: true,
        actions: [
          FlatButton(
            onPressed: () => _conformSignOut(context),
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => EditJobFormPage.show(context),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        return ListItemBuilder<Job>(
          snapshot: snapshot,
          itemBuilder: (context, job) => Dismissible(
            key: Key('job-${job.id}'),
            background: Container(
              color: Colors.red,
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _delete(context, job),
            child: JobListTile(
              job: job,
              onTap: () => EditJobFormPage.show(context, job: job),
            ),
          ),
        );
        // if (snapshot.hasData) {
        //   final jobs = snapshot.data;
        //   if (jobs.isNotEmpty) {
        //     final children = jobs
        //             ?.map(
        //               (job) => JobListTile(
        //                 job: job,
        //                 onTap: () => EditJobFormPage.show(context, job: job),
        //               ),
        //             )
        //             ?.toList() ??
        //         [];
        //
        //     return ListView(
        //       children: children,
        //     );
        //   }
        //   return EmptyContent();
        // }
        // if (snapshot.hasError) {
        //   return Center(
        //     child: Text('Some error occurred'),
        //   );
        // }
        // return Center(
        //   child: CircularProgressIndicator(),
        // );
      },
    );
  }
}
