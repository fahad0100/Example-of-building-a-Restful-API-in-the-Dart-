import 'package:mongo_dart/mongo_dart.dart';

import '../Firebase/firebaseMethod.dart';
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
}
