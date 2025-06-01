import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String location = '';
  String linkedIn = '';
  String portfolio = '';

  String school = '';
  String degree = '';
  String fieldOfStudy = '';
  String eduStart = '';
  String eduEnd = '';

  String company = '';
  String role = '';
  String expStart = '';
  String expEnd = '';
  String expDescription = '';

  String certName = '';
  String certInstitution = '';
  String certYear = '';

  void saveProfile(BuildContext context) {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    Flushbar(
      message: 'Profile saved successfully!',
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }
}