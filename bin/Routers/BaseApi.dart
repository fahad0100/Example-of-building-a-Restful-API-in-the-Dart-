import 'dart:convert';
import 'dart:ffi';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'Auth/authRouter.dart';

class ApiBase {
  Handler get router {
    Router router = Router();

    router.mount("/auth/", AuthAPi().router);
    Handler _handler =
        Pipeline().addMiddleware(logRequests()).addHandler(router);

    router.all("/", (Request req) {
      return Response.ok("ApiBase");
    });
    //-------here for if user enter wrong path
    router.all("/<name|.*>", (Request req) {
      return Response.notFound(
          json.encode({
            "msg": "Wrong! path is not currect < ${req.url} >",
            "code": "404"
          }),
          headers: {"Content-Type": "application/json"});
    });

    return _handler;
  }
}
