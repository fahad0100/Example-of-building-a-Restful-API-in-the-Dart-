import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth_rest/firebase_auth_rest.dart' as restFB;
import 'package:firebase_auth_token/firebase_auth_token.dart' as fd;
import 'package:http/http.dart' as http;
import '../Models/Users.dart';
import '../MongoDB/MongoDbMethod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_admin_sdk/firebase_admin.dart' as admin;

/*
  apiKey: "AIzaSyCd9iUrN2ADdnOy48OTVgzblEzozeqazB4",
  authDomain: "apistudents-3f587.firebaseapp.com",
  projectId: "apistudents-3f587",
  storageBucket: "apistudents-3f587.appspot.com",
  messagingSenderId: "403693989493",
  appId: "1:403693989493:web:2425070882d0eb0cbc523c"

  */
class FirebaseMethod {
// for package:firebase_admin_sdk/firebase_admin.dart
  static dynamic adminFirebase = null;

  // for package:firebase_admin_sdk/firebase_admin.dart

  static const _apiKey = "AIzaSyCd9iUrN2ADdnOy48OTVgzblEzozeqazB4";
  static final _fbAuth = restFB.FirebaseAuth(http.Client(), _apiKey);
  static final _testApiToken =
      fd.FirebaseAuthToken(projectId: "apistudents-3f587");

  static createAccount(
      {required String email, required String pass, required name}) async {
    try {
      var now = DateTime.now();
      int? timeString = int.tryParse(DateFormat('yyyyMMddHHmmss').format(now));
      restFB.FirebaseAccount user =
          await _fbAuth.signUpWithPassword(email, pass, autoRefresh: true);
      restFB.UserData? userInfo = await user.getDetails();

      Map<String, dynamic> dataUser = {
        "_id": userInfo!.localId,
        "email": userInfo.email,
        "createAt": timeString as int,
        "name": name
      };
      await MongoDBClss.addNewUsers(user: UserModel.fromJson(dataUser));

      dataUser["token"] = user.refreshToken.toString();
      dataUser["expiresAt"] = user.expiresAt.toString();

      return dataUser;
    } on restFB.AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }

  static login({required String email, required String pass}) async {
    try {
      restFB.FirebaseAccount user =
          await _fbAuth.signInWithPassword(email, pass);

      Map<String, dynamic> dataUser = {
        "token": user.idToken.toString(),
        "id": user.localId.toString(),
        "expiresAt": user.expiresAt.toString()
      };
      return dataUser;
    } on restFB.AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }

  static checkAuth({required String token}) async {
    try {
      fd.AuthUser user = await _testApiToken
          .getUserFromToken(token.substring(7, token.length));

      Map<String, dynamic> dataUser = {
        "id": user.id.toString(),
      };
      return dataUser;
    } on restFB.AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }

  static deleteUser({idUser}) async {
    try {
      var jsonString =
          File("apistudents-3f587-firebase-adminsdk-hzbpg-67e17f6145.json")
              .readAsStringSync();
      final Map<String, dynamic> jsonmap = await json.decode(jsonString);
      var certificate = admin.FirebaseAdmin.instance.certFromMap(jsonmap);

      adminFirebase ??=
          admin.FirebaseAdmin.instance.initializeApp(admin.AppOptions(
        credential: certificate,
      ));

      var user = await adminFirebase.auth().getUser(idUser.toString());

      await adminFirebase.auth().deleteUser(idUser.toString());
      print("the user have ${user.email} is deleted ...");
    } catch (error) {
      print(error);
    }
  }
}