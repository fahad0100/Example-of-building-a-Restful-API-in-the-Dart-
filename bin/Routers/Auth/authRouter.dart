import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../Const/const_Msg.dart';
import '../../Firebase/firebaseMethod.dart';

class AuthAPi {
  Handler get router {
    Router router = Router();

    router.post("/SignUp", (Request req) async {
      try {
        final Map<String, dynamic> param =
            json.decode(await req.readAsString());
        if (param.containsKey("email") &&
            param.containsKey("password") &&
            param.containsKey("name")) {
          var dataUser = await FirebaseMethod.createAccount(
              email: param["email"], pass: param["password"],name: param["name"]);
          if (dataUser["msg"] != null) {
            return Msg.msgResponseError(msg: dataUser);
          }
          return Msg.msgResponseSuccess(msg: dataUser);
        }
        return Msg.notFound(msg: {"msg": "name, email and Password is reqiurd"});
      } catch (error) {
        return Msg.badRequest(msg: {"msg": "bad Request"});
      }
    });

    router.post("/SignIn", (Request req) async {
      try {
        final Map<String, dynamic> param =
            json.decode(await req.readAsString());
        if (param.containsKey("email") && param.containsKey("password")) {
          var dataUser = await FirebaseMethod.login(
              email: param["email"], pass: param["password"]);
          if (dataUser["msg"] != null) {
            return Msg.msgResponseError(msg: dataUser);
          }
          return Msg.msgResponseSuccess(msg: dataUser);
        }
        return Msg.notFound(msg: {"msg": "email and Password is reqiurd"});
      } catch (error) {
        return Msg.badRequest(msg: {"msg": "bad Request"});
      }
    });

    router.get("/checkAuth", (Request req) async {
      try {
        Map<String, dynamic> param = req.headers;
        print(param["authorization"]);
        print(param.containsKey("authorization"));

        if (param.containsKey("authorization")) {
          var dataUser =
              await FirebaseMethod.checkAuth(token: param["authorization"]);
          if (dataUser["msg"] == null) {
            return Msg.msgResponseSuccess(msg: dataUser);
          }
          return Msg.badRequest(msg: {"msg": "token authorization is requird"});
        }
        return Msg.badRequest(msg: {"msg": "token authorization is requird"});
      } catch (error) {
        return Msg.badRequest(msg: {"msg": "token authorization is requird"});
      }
    });
    router.all("/<name|.*>", (Request req) {
      return Response.notFound(
          json.encode({
            "msg": "Wrong! path is not currect < ${req.url} >",
            "code": "404"
          }),
          headers: {"Content-Type": "application/json"});
    });
    return router;
  }
}
