import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'Const/const_Msg.dart';
import 'Const/const_Variable.dart';
import 'routersApi/BaseApi.dart';

/*
https://api-auth-first-test.herokuapp.com/ 
https://git.heroku.com/api-auth-first-test.git

*/
main() async {
  //for get port

  var env = Platform.environment;
  constVsvariable.port = env.entries.firstWhere(
      (element) => element.key == "PORT",
      orElse: (() => MapEntry("PORT", "8080")));

  final Router router = Router();
  router.mount("/api_v1", ApiBase().router);
  Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(router);
  router.all("/", (Request req) {
    return Response.ok("api is running");
  });
  router.all("/<name|.*>", (Request req) {
    return Msg.msgResponseError(msg: {"msg": "Page not found"});
  });

  var server = await io.serve(handler, constVsvariable.localAddress,
      int.parse(constVsvariable.port!.value.toString()));

  print("http://${server.address.host}:${server.port}");
}
