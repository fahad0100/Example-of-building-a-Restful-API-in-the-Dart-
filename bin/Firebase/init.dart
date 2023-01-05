import 'dart:convert';

import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:firebase_auth_rest/src/models/signin_response.dart';
import 'package:firebase_auth_token/firebase_auth_token.dart' as fd;
import 'package:firebase_auth_token/firebase_auth_token.dart';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import '../Const/const_Msg.dart';

/*
  apiKey: "AIzaSyCd9iUrN2ADdnOy48OTVgzblEzozeqazB4",
  authDomain: "apistudents-3f587.firebaseapp.com",
  projectId: "apistudents-3f587",
  storageBucket: "apistudents-3f587.appspot.com",
  messagingSenderId: "403693989493",
  appId: "1:403693989493:web:2425070882d0eb0cbc523c"

  */
class FirebaseMethod {
  static const _apiKey = "AIzaSyCd9iUrN2ADdnOy48OTVgzblEzozeqazB4";

  static final _fbAuth = FirebaseAuth(http.Client(), _apiKey);
  static final _testApiToken =
      fd.FirebaseAuthToken(projectId: "apistudents-3f587");

  static createAccount({required String email, required String pass}) async {
    try {
      FirebaseAccount user =
          await _fbAuth.signUpWithPassword(email, pass, autoRefresh: true);

      Map<String, dynamic> dataUser = {
        "token": user.refreshToken.toString(),
        "id": user.localId.toString(),
        "expiresAt": user.expiresAt.toString()
      };

      return dataUser;
    } on AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }

  static login({required String email, required String pass}) async {
    try {
      FirebaseAccount user = await _fbAuth.signInWithPassword(email, pass);

      Map<String, dynamic> dataUser = {
        "token": user.idToken.toString(),
        "id": user.localId.toString(),
        "expiresAt": user.expiresAt.toString()
      };
      return dataUser;
    } on AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }

  static checkAuth({required String token}) async {
    try {
      AuthUser user = await _testApiToken
          .getUserFromToken(token.substring(7, token.length));

      Map<String, dynamic> dataUser = {
        "id": user.id.toString(),
      };
      return dataUser;
    } on AuthException catch (error) {
      Map<String, dynamic> mapRe = {
        "msg": error.error.message,
      };
      return mapRe;
    }
  }
}
