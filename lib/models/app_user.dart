import 'package:agora_video/services/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  String? uid;
  String? email;
  String? photoUrl;
  String? displayName;
  bool? success;
  Data? data;
  String? id;
  AppLogin? type;

  // factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
  //       success: json["success"],
  //       data: Data.fromJson(json["data"]),
  //     );

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String? fbId = json['fbId'];
    String? appleId = json['appleId'];
    String? googleId = json['gId'];
    String? id = fbId ?? googleId ?? appleId;

    return AppUser(
      displayName: json['name'],
      email: json['emailId'],
      id: id,
      photoUrl: json['profileImg'],
    );
  }

  AppUser(
      {this.data,
      this.success,
      this.uid,
      this.email,
      this.photoUrl,
      this.displayName,
      this.id,
      this.type});

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        //todo: there is fb id gid and name is also returning inside data
      };

//  response{success: true, message: Register Successfully, data: {userId: hdQJdKwc55kXaRvLq, authToken: lqghaN0om3dVSvoq7nwyucNhBVbaJiin6_ZmlL-h-cs, name: Riddhi Daftary, fbId: 105629627240340198785, gId: null}}

  factory AppUser.fromFirebase(
    User? user, {
    String? id,
    AppLogin? logintype,
    String? name,
    String? email,
    String? imageUrl,
    bool useUpdatedName = false,
  }) {
    if (kDebugMode) {
      print('uid in app user ' + user!.uid);
      print('id  in app user  $id');
      print('email  in app user  ${user.email ?? email}');
      print('name  in app user  $name');
      print('useUpdatedName  in app user  $useUpdatedName');
    }

    return AppUser(
      uid: user?.uid,
      email: user?.email ?? email,
      id: id,
      type: logintype,
      displayName: useUpdatedName ? name : user!.displayName ?? name,
      photoUrl: user!.photoURL ?? imageUrl,
    );
  }
}

class Data {
  Data({
    this.userId,
    this.authToken,
  });

  String? userId;
  String? authToken;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        authToken: json["authToken"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "authToken": authToken,
      };
}
