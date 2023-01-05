import 'dart:convert';

import 'package:shelf/shelf.dart';

class Msg {
  static notFound({required Map<String, dynamic> msg}) {
    Map<String, dynamic> mapMsg = msg;
    mapMsg["code"] = 404;
    return Response.notFound(json.encode(mapMsg),
        headers: {"Content-Type": "application/json"});
  }

  static badRequest({required Map<String, dynamic> msg}) {
    Map<String, dynamic> mapMsg = msg;
    mapMsg["code"] = 400;
    return Response.badRequest(
        body: json.encode(mapMsg),
        headers: {"Content-Type": "application/json"});
  }

  static msgResponseSuccess({required Map<String, dynamic> msg}) {
    Map<String, dynamic> mapMsg = msg;
    mapMsg["code"] = 200;
    return Response.ok(json.encode(mapMsg),
        headers: {"Content-Type": "application/json"});
  }

  static msgResponseError({required Map<String, dynamic> msg}) {
    // msg.addAll({"Code": 403});
    Map<String, dynamic> mapMsg = msg;
    mapMsg["code"] = 403;

    return Response.forbidden(json.encode(mapMsg),
        headers: {"Content-Type": "application/json"});
  }

  static msgUnauthorized({required Map<String, dynamic> msg}) {
    // msg.addAll({"Code": 403});
    Map<String, dynamic> mapMsg = msg;
    mapMsg["code"] = 401;

    return Response.unauthorized(json.encode(mapMsg),
        headers: {"Content-Type": "application/json"});
  }
}
