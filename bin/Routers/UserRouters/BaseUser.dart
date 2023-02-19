import 'dart:convert';

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

    router.post("/newpost", (Request req) async {
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

    router.get("/allposts", (Request req) async {
      var posts = await MongoDBClss.allPost();

      return Msg.msgResponseSuccess(msg: {"data": posts});
    });

    router.get("/myposts", (Request req) async {
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

    router.get("/mypost/<id>", (Request req, String id) async {
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

    router.get("/post/<id>", (Request req, String id) async {
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
    router.put("/updatepost/<id>", (Request req, String id) async {
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

    router.delete("/deletepost/<id>", (Request req, String id) async {
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


/*
write me a professional README.md file for github to implmention dart backend :
includes it : get,post,put and delete 
Prerequisites:
Dart SDK 
Firebase
MongoDB Atlas 

Endpoints:
Get / : Check id server is running.
Auth:
POST /api_v1/auth/SignUp: Creates a new user.
POST /api_v1/auth/SignIn: Login a user.
GET /api_v1/auth/checkAuth: Check token a user is not expire.
POST /api_v1/auth/restPassword: rest Password a user.
User:
POST /api_v1/user/NewPost : Creates a new Post.
GET /api_v1/user/AllPost : Retrieves all posts.
GET /api_v1/user/MyPost : Retrieves all posts of user.
GET /api_v1/user/Post/<id> : Retrieve any post by id .
GET /api_v1/user/MyPost/<id> : Retrieve a post of user by id .
Put /api_v1/user/updatePost/<id> : update a post of user by id .
Delete /api_v1/user/deletePost/<id> : Delete a post of user by id .


The project has been connected to:
Firebase: to use the Authentication service
MongoDB: to store data

Set up your Firebase credentials:
Create a file called firebase.json in the root of the project, and add your Firebase API key and other relevant information.

Running the API:
dart bin/server.dart


Contributing
We welcome contributions to this project. If you have an idea for an improvement or a bug to report, please open an issue. If you would like to make a change yourself, please follow these steps:

Fork the repository.
Create a new branch for your changes.
Make your changes.
Commit and push your changes to your branch.
Open a pull request.
or contact me on email fahad.alazmi1994@gmail.com

Clone the repository: https://github.com/fahad0100/Example-of-building-a-Restful-API-in-the-Dart-.git
deployment on heroku:https://api-auth-first-test.herokuapp.com/

*/