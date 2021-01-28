import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/app/home/model/job.dart';
import 'package:time_tracker/services/database.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';

class EditJobFormPage extends StatefulWidget {
  EditJobFormPage({@required this.database, this.job});
  final Database database;
  final Job job;
  static Future<void> show(BuildContext context,
      {Database database, Job job}) async {
    // final database = Provider.of<Database>(context, listen: false); //uses the context of JobPage
    await Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EditJobFormPage(
        database: database,
        job: job,
      ),
    ));
  }

  @override
  _EditJobFormPageState createState() => _EditJobFormPageState();
}

class _EditJobFormPageState extends State<EditJobFormPage> {
  @override
  void initState() {
    if (widget.job != null) {
      _jobName = widget.job.name;
      _ratePerHour = widget.job.ratePerHour;
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  String _jobName;
  int _ratePerHour;
  bool validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (validateAndSaveForm()) {
      try {
        final jobs = await widget.database.jobsStream().first;
        final allName = jobs.map((job) => job.name).toList();
        if (widget.job != null) {
          allName.remove(widget.job.name);
        }
        if (allName.contains(_jobName)) {
          PlatformAwareDialog(
            title: 'Name already used',
            content: 'please choose different job name',
            defaultActionText: 'Ok',
          ).show(context);
        } else {
          final job = Job(
            id: widget.job?.id ?? documentIdFromCurrentDate(),
            name: _jobName,
            ratePerHour: _ratePerHour,
          );
          await widget.database.setJob(job);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        PlatformExceptionAwareDialog(
          title: "Operation failed",
          firebaseException: e,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'New Job' : 'Edit Job'),
        actions: [
          FlatButton(
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            onPressed: _submit,
          )
        ],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: _buildForm(),
        ),
      ),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        autocorrect: false,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Job name',
        ),
        initialValue: _jobName,
        onSaved: (value) => _jobName = value,
        validator: (value) => value.isEmpty ? 'Job Name can\'t be empty' : null,
      ),
      SizedBox(
        height: 10,
      ),
      TextFormField(
        autocorrect: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Rate per hour',
        ),
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => _ratePerHour = int.tryParse(value) ?? 0,
      ),
    ];
  }
}
