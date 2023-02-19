import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../Const/const_Msg.dart';
import '../../Firebase/firebaseMethod.dart';

class AuthAPi {
  Handler get router {
    Router router = Router();

    router.post("/signup", (Request req) async {
      try {
        final Map<String, dynamic> param =
            json.decode(await req.readAsString());
        if (param.containsKey("email") &&
            param.containsKey("password") &&
            param.containsKey("name")) {
          var dataUser = await FirebaseMethod.createAccount(
              email: param["email"],
              pass: param["password"],
              name: param["name"]);
          if (dataUser["msg"] != null) {
            return Msg.msgResponseError(msg: dataUser);
          }
          return Msg.msgResponseSuccess(msg: dataUser);
        }
        return Msg.notFound(
            msg: {"msg": "name, email and password is reqiurd"});
      } catch (error) {
        return Msg.badRequest(msg: {"msg": "bad Request"});
      }
    });

    router.post("/signin", (Request req) async {
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

    router.post("/restpassword", (Request req) async {
      try {
        final Map<String, dynamic> param =
            json.decode(await req.readAsString());
        if (param.containsKey("email")) {
          var dataUser =
              await FirebaseMethod.restPassword(email: param["email"]);
          if (dataUser["msg"] != null) {
            return Msg.msgResponseError(msg: dataUser);
          }
          return Msg.msgResponseSuccess(msg: dataUser);
        }
        return Msg.notFound(msg: {"msg": "email reqiurd"});
      } catch (error) {
        return Msg.badRequest(msg: {"msg": "bad Request"});
      }
    });
    router.get("/checkauth", (Request req) async {
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

//http://8.213.24.202:8080/api_v1/auth/signin
/*
{
{
    "_id": "YBhBBSSWN7h8xlHR7MqFSjGVPaI2",
    "email": "fahadalazmi@gmail.com",
    "createAt": 20230219125531,
    "name": "Fahad Alazmi",
    "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1YzJiNDBhYTJmMzIyNzk4NjY2YTZiMzMyYWFhMDNhNjc3MzAxOWIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYXBpc3R1ZGVudHMtM2Y1ODciLCJhdWQiOiJhcGlzdHVkZW50cy0zZjU4NyIsImF1dGhfdGltZSI6MTY3NjgxMTMzMiwidXNlcl9pZCI6IllCaEJCU1NXTjdoOHhsSFI3TXFGU2pHVlBhSTIiLCJzdWIiOiJZQmhCQlNTV043aDh4bEhSN01xRlNqR1ZQYUkyIiwiaWF0IjoxNjc2ODExMzMyLCJleHAiOjE2NzY4MTQ5MzIsImVtYWlsIjoiZmFoYWRhbGF6bWlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbImZhaGFkYWxhem1pQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.hUeMZ_OtYNBhb9uPZe6K3XwVEHncKqWtBXMQCgSDbAI-Dx0YKt_J1uricWVdXP-p1Go-29I4FMQBb-VJBHowLGApeX34MCr0KBq3bRHiHjLO-fAoU3U3OBPIPvSoKqdYElxvhUwoGsp14IDiH1H6hGoRkHKH2GR5-tXghIYqNoeivuICfo3bbtXiCpbDyUWSx2kjjpx7D392vK8rRFWIZ_tZzZrj7ND5iiWI_8dxw-G77cOozlX8w4Ugu8tKoBY6LjnWZBngYXWcmBgy_nqNYkhsCOi6Z2tBHylCIYnPR-_qf7q4mSVEu5e3RPtoefpztZydG6PVApH5CEJNSEcREA",
    "refreshToken": "APJWN8eFusrZfcPQpMxhrb-jJIF0ZJWIcOlKc5M2icSArghNNfaD2PomYm1nzdBPIPzmbE3tSgy-PufHaVekXKqKa5ZWang7ZKuW9fDkfSxnB7JD3C584V0WyXSb6-OxyJfXLhIzOOyK3VwBUJFeltJgsKlemCTx9TA93CR0tQ5arzWewSxSHa9YwX4GgzpsSg1h2x5wxj0shgB7bnggEYtwcaSX2prBtg",
    "expiresAt": "2023-02-19 13:55:33.008277Z",
    "code": 200
}
{
    "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1YzJiNDBhYTJmMzIyNzk4NjY2YTZiMzMyYWFhMDNhNjc3MzAxOWIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYXBpc3R1ZGVudHMtM2Y1ODciLCJhdWQiOiJhcGlzdHVkZW50cy0zZjU4NyIsImF1dGhfdGltZSI6MTY3NjgxMjIzNCwidXNlcl9pZCI6IllCaEJCU1NXTjdoOHhsSFI3TXFGU2pHVlBhSTIiLCJzdWIiOiJZQmhCQlNTV043aDh4bEhSN01xRlNqR1ZQYUkyIiwiaWF0IjoxNjc2ODEyMjM0LCJleHAiOjE2NzY4MTU4MzQsImVtYWlsIjoiZmFoYWRhbGF6bWlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbImZhaGFkYWxhem1pQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.ynbkJtvipMsXigDxCqewAxGzWSacN3IEBLckhOa1cBuK0q6aBNs8gBPzt-W0u9M9OCkz4m0M5-AKW7z9wwC15B-iOfodQmsFp618BbVdZ5UVw0CS5wXU4LJmW2of5nOjx46WZC2q7w6EL7CWU-wsohHBVZd5ZmN1yLzTn0qar_xOxx7vMTUNb-NAxwVYIq80JpoDMChOEMW60U85jbjoH8VOTSmNg4O0G_0wZxZse_H_FrQm-3U6JNXrXAR_KvseBBOXYOfEkvkryyrisx5sdo6JJkVwjKoZdEEkf8nVQ664NDedGxqUmJ17So5Af9Oinm2sYqQYzbukwo9Inhlj9Q",
    "id": "YBhBBSSWN7h8xlHR7MqFSjGVPaI2",
    "refreshToken": "APJWN8fHfRhmGLCn_UaSPvBCcsDOzv4eQEUR2TPoYq2J7PXsZqzBU2p1Zao3ameFZHTMEPLmEbe8Bf_64g15q-Vvl739SrqgNh9dljJwiiw2e4w6e1Q_t6YL2KtU5Bpt958RmaPENUp15LeDlNwPv-H950eP-FwDnz7HtfEE2W0ZW0RJUjucHJA1AQcWdulbOpo1HxECRmnOOSq-gbYtpHkUpeK_LN63Gg",
    "expiresAt": "2023-02-19 14:10:34.175086Z",
    "code": 200
}
}

*/