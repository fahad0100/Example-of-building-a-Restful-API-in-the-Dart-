import 'package:mongo_dart/mongo_dart.dart';

import '../Firebase/firebaseMethod.dart';
import '../Models/PostModel.dart';
import '../Models/Users.dart';

class MongoDBClss {
  static late Db db;
  static connect({required String nameDatabase}) async {
    db = await Db.create(
        "mongodb+srv://adminDataBase:adminDataBase123@database.w2w7sac.mongodb.net/$nameDatabase?retryWrites=true&w=majority");
    await db.open().then((value) => print("** database connected **"));
    print(db.runtimeType);
  }

//?-----------new user add------------
  static addNewUsers({required UserModel user}) async {
    await MongoDBClss.connect(nameDatabase: "DataBase");
    var coll = db.collection("Users");
    await coll
        .insertOne(user.toJson())
        .then((value) => print("secc ${value.isSuccess}"));
    var x = await coll.find().toList();
    print(x);
    await db.close();
  }

  //?-----------get all Users for firebase and mongodb deleted------------
  static deletedAllUsers() async {
    try {
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Users");
      await coll.find();
      var users = await coll.find().toList();
      for (var user in users) {
        print(user["_id"]);
        await FirebaseMethod.deleteUser(idUser: user["_id"]);
      }
      await coll.drop();
      await db.close();
    } catch (error) {
      print(error);
    }
  }

  //? create new post

  static newPost({required String token, required PostModel post}) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      await coll.insert(post.toJson());

      await db.close();
      return true;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }
  //? get all post

  static allPost() async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      List allPost = await coll.find().toList();
      print(allPost);

      await db.close();
      return allPost;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }

  static userPosts({required String userID}) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      List allPost = await coll.find(where.eq("idUser", userID)).toList();
      print(allPost);

      await db.close();
      return allPost;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }

  static postOFuser({required String userID, required String postID}) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      Map<String, dynamic>? allPost =
          await coll.findOne(where.eq("idUser", userID).eq("_id", postID));
      print(allPost);

      await db.close();
      return allPost;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }

  static postID({required String postID}) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      Map<String, dynamic>? allPost =
          await coll.findOne(where.eq("_id", postID));
      print(allPost);

      await db.close();
      return allPost;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }

  static updatePostUsers(
      {required String userID,
      required String postID,
      required Map<String, dynamic> dataUpdate}) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      Map<String, dynamic>? post =
          await coll.findOne(where.eq("idUser", userID).eq("_id", postID));
      if (post != null) {
        await coll.updateMany(where.eq("idUser", userID).eq("_id", postID),
            modify.set("title", dataUpdate["title"]));
        await coll.updateMany(where.eq("idUser", userID).eq("_id", postID),
            modify.set("content", dataUpdate["content"]));
        await db.close();
        return true;
      }
      await db.close();
      return false;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }

  static deletePostUsers({
    required String userID,
    required String postID,
  }) async {
    try {
      print("i am here 4");
      await MongoDBClss.connect(nameDatabase: "DataBase");
      var coll = db.collection("Posts");
      Map<String, dynamic>? post =
          await coll.findOne(where.eq("idUser", userID).eq("_id", postID));
      if (post != null) {
        await coll.deleteOne(where.eq("idUser", userID).eq("_id", postID));
        await db.close();
        return true;
      }
      await db.close();
      return false;
    } catch (error) {
      print(error);
      return {"msg": error};
    }
  }
}
