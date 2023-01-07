import 'dart:convert';

import 'package:firebase_auth_token/firebase_auth_token.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../Const/const_Msg.dart';
import '../../Firebase/firebaseMethod.dart';
import '../../Models/PostModel.dart';
import '../../MongoDB/MongoDbMethod.dart';

class UserRouter {
  Handler get router {
    Router router = Router();

    Handler handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware((innerHandler) => (Request req) async {
              try {
                var parm = req.headers["authorization"];
                if (parm != null) {
                  var user = await FirebaseMethod.checkAuth(token: parm);
                  print(user);

                  return await innerHandler(req);
                } else {
                  return Msg.msgUnauthorized(msg: {"msg": "unauthorized"});
                }
              } catch (error) {
                return Msg.msgUnauthorized(msg: {
                  "msg": "Token is expired or you don't have unauthorized +"
                });
              }
            })
        .addHandler(router);

    router.post("/NewPost", (Request req) async {
      try {
        var headers = req.headers["authorization"].toString();
        print(1);
        var parms = json.decode(await req.readAsString());
        print(2);
        DateTime time = DateTime.now();
        print(3);
        Map<String, dynamic> user =
            await FirebaseMethod.checkAuth(token: headers);
        PostModel post = PostModel(
          id: ObjectId().$oid,
          idUser: user["id"],
          title: parms["title"],
          content: parms["content"],
          createAt: time.millisecondsSinceEpoch,
        );
        print(4);
        var isDone = await MongoDBClss.newPost(token: headers, post: post);
        print(isDone);
        if (isDone) {
          return Msg.msgResponseSuccess(msg: {"msg": "Post create"});
        }
      } catch (error) {
        return Msg.msgResponseError(
            msg: {"msg": "title and content is reqiurd"});
      }
    });

    router.get("/AllPost", (Request req) async {
      var posts = await MongoDBClss.allPost();

      return Msg.msgResponseSuccess(msg: {"data": posts});
    });

    router.get("/MyPost", (Request req) async {
      try {
        var headers = req.headers["authorization"].toString();
        Map<String, dynamic> user =
            await FirebaseMethod.checkAuth(token: headers);
        var posts = await MongoDBClss.userPosts(userID: user["id"]);
        return Msg.msgResponseSuccess(msg: {"data": posts});
      } catch (error) {
        return Msg.msgResponseError(
            msg: {"msg": "title and content is reqiurd"});
      }
    });

    router.get("/MyPost/<id>", (Request req, String id) async {
      try {
        var headers = req.headers["authorization"].toString();
        Map<String, dynamic> user =
            await FirebaseMethod.checkAuth(token: headers);
        var posts =
            await MongoDBClss.postOFuser(userID: user["id"], postID: id);
        if (posts != null) {
          return Msg.msgResponseSuccess(msg: posts);
        }
        return Msg.msgResponseError(msg: {"msg": "not found"});
      } catch (error) {
        return Msg.msgResponseError(
            msg: {"msg": "title and content is reqiurd"});
      }
    });

    router.get("/Post/<id>", (Request req, String id) async {
      try {
        var posts = await MongoDBClss.postID(postID: id);
        if (posts != null) {
          return Msg.msgResponseSuccess(msg: posts);
        }
        return Msg.msgResponseError(msg: {"msg": "not found"});
      } catch (error) {
        return Msg.msgResponseError(
            msg: {"msg": "title and content is reqiurd"});
      }
    });
    router.put("/updatePost/<id>", (Request req, String id) async {
      try {
        var headers = req.headers["authorization"].toString();
        Map<String, dynamic> parms = json.decode(await req.readAsString());
        Map<String, dynamic> user =
            await FirebaseMethod.checkAuth(token: headers);
        print("33333");

        if (parms.containsKey("title") && parms.containsKey("content")) {
          var posts = await MongoDBClss.updatePostUsers(
              userID: user["id"], postID: id, dataUpdate: parms);
          print("--------$posts---------");
          if (posts == true) {
            return Msg.msgResponseSuccess(msg: {"msg": "post updated"});
          } else {
            return Msg.msgResponseError(msg: {"msg": "Not found"});
          }
        } else {
          return Msg.msgResponseError(
              msg: {"msg": "title and conten is reqiurd "});
        }
      } catch (error) {
        return Msg.msgResponseError(msg: {"msg": error});
      }
    });

    router.delete("/deletePost/<id>", (Request req, String id) async {
      try {
        var headers = req.headers["authorization"].toString();
        Map<String, dynamic> user =
            await FirebaseMethod.checkAuth(token: headers);
        print("33333");

        var posts =
            await MongoDBClss.deletePostUsers(userID: user["id"], postID: id);
        print("--------$posts---------");
        if (posts == true) {
          return Msg.msgResponseSuccess(msg: {"msg": "post deleted"});
        } else {
          return Msg.msgResponseError(
              msg: {"msg": " not found or you don't have authorization"});
        }
      } catch (error) {
        return Msg.msgResponseError(msg: {"msg": error});
      }
    });

    return handler;
  }
}
