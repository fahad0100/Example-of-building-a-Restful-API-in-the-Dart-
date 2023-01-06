import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class User {
  Handler get router {
    Router router = Router();
    Handler handler =
        Pipeline().addMiddleware(logRequests()).addHandler(router);

    router.post("/newUser", handler);

    return handler;
  }
}
