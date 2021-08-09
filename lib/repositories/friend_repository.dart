import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/friend.dart';

class FriendRepository {
  FirebaseFirestore firestoreInstance;

  FriendRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  FriendRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<Friend> getUserFriendsByUserId(String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .where('id', isEqualTo: userId)
          .get();

      if (docRef.docs.length == 0) {
        return null;
      }
      Friend friendData = Friend.fromJson(docRef.docs[0].data());
      return friendData;
    } catch (e) {
      throw e;
    }
  }

  static Future<List<User>> getUserFriendsRequestByUserId(String userId) async {
    //TODO: Get List of friendRequest for the userId
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend-request')
          .where('id', isEqualTo: userId)
          .get();
      List<User> listOfFriendRequests = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> element = doc.data();
        // listOfFriendRequests.add(userFriendRequestClass.fromJson(element));
      });
      // return listOfFriendRequests;
    } catch (e) {
      throw e;
    }
  }

  static Future<List<User>> getUserFriendsSuggestionsByUserId(
      String userId) async {
    //TODO: Get user suggestions for UserId
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend-suggestion')
          .where('id', isEqualTo: userId)
          .get();
      List<User> listOfFriendSuggestions = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> element = doc.data();
        // listOfFriendSuggestions.add(userFriendClass.fromJson(element));
      });
      // return listOfFriendSuggestions;

      // return;
    } catch (e) {
      throw e;
    }
  }

  static Future<User> confirmFriendRequest(
      String userId, User UserRequestedConfirmed) async {
    //TODO: Add user to friend list, remove from friend request.

    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e) {
      throw e;
    }
  }

  static Future<User> ignoreFriendRequest(
      String userId, User userRequestedignored) async {
    // TODO: Remove user from UserFriendRequest
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend-request')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e) {
      throw e;
    }
  }

  static Future<User> connectFriendSuggestion(
      String userId, User friendToConnect) async {
    //TODO: Connect with friendToConnect
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-suggestion')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e) {
      throw e;
    }
  }

  static Future<User> sendHiFiveToFriend(
      String userId, User friendToGreet) async {
    //TODO: Send a HiFive action to friendToGreet
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend-hifive')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e) {
      throw e;
    }
  }
}
