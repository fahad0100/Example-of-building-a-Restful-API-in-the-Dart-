import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'Const/const_Msg.dart';
import 'Const/const_Variable.dart';
import 'Firebase/firebaseMethod.dart';
import 'MongoDB/MongoDbMethod.dart';
import 'Routers/BaseApi.dart';

/*
https://api-auth-first-test.herokuapp.com/ 
https://git.heroku.com/api-auth-first-test.git
mongodb+srv://admin123:<password>@cluster0.fca00cj.mongodb.net/?retryWrites=true&w=majority
*/
main() async {
  //for get port
  func();
  var env = Platform.environment;
  ConstVariable.port = env.entries.firstWhere(
      (element) => element.key == "PORT",
      orElse: (() => MapEntry("PORT", "8080")));

  final Router router = Router();
  router.mount("/api_v1", ApiBase().router);
  Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  router.all("/", (Request req) {
    return Response.ok("api is running");
  });

  var server = await io.serve(handler, ConstVariable.localAddress,
      int.parse(ConstVariable.port!.value.toString()));

  print("http://${server.address.host}:${server.port}");
}

func() async {
  StreamController strem = StreamController();
  strem.stream.listen((event) async {
    DateTime time = DateTime.now();
    String day = DateFormat('EEEE').format(time).trim();

    if (day == "Friday") {
    await MongoDBClss.deletedAllUsers();
    print("delete .....");
    }
  });

  Timer.periodic(Duration(hours: 5), (Timer timer) {
    strem.sink.add("delete");
  });
}
