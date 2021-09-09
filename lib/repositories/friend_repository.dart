import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
      var document = docRef.docs[0].data() as Map<String, dynamic>;
      Friend friendData = Friend.fromJson(document);
      return friendData;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<Friend> getUserFriendsRequestByUserId(String userId) async {
    //TODO: Get List of friendRequest for the userId
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .where('id', isEqualTo: userId)
          .get();
      if (docRef.docs.isNotEmpty) {
        List<Friend> listOfFriendRequests =
            docRef.docs.map((doc) => Friend.fromJson(doc.data() as Map<String, dynamic>)).toList();
        return listOfFriendRequests[0];
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<List<User>> getUserFriendsSuggestionsByUserId(String userId) async {
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
        final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
        // listOfFriendSuggestions.add(userFriendClass.fromJson(element));
      });
      // return listOfFriendSuggestions;

      // return;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<FriendModel> confirmFriendRequest(Friend friend, FriendRequestModel friendRequest) async {
    try {
      //Generate user reference from friend request
      var friendUserDocument = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('users')
          .doc(friendRequest.id)
          .get();

      //Friend model to add as a friend
      FriendModel friendModel =
          FriendModel(id: friendRequest.id, isFavorite: false, reference: friendUserDocument.reference);

      //Remove friend request
      friend.friendRequestReceived.removeWhere((element) => element.id == friendModel.id);
      friend.friends.add(friendModel);

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());
      return friendModel;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<FriendRequestModel> ignoreFriendRequest(Friend friend, FriendRequestModel friendRequest) async {
    try {
      //Remove friend request
      friend.friendRequestReceived.removeWhere((element) => element.id == friendRequest.id);

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());
      return friendRequest;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<FriendModel> markFriendAsFavorite(Friend friend, FriendModel friendModel) async {
    friendModel.isFavorite = friendModel.isFavorite == null ? false : friendModel.isFavorite;
    friend.friends = friend.friends.map((friend) {
      if (friend.id == friendModel.id) {
        friend.isFavorite = friendModel.isFavorite;
      }
      return friend;
    }).toList();

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());
      return friendModel;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<User> connectFriendSuggestion(String userId, User friendToConnect) async {
    //TODO: Connect with friendToConnect
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-suggestion')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  static Future<User> sendHiFiveToFriend(String userId, User friendToGreet) async {
    //TODO: Send a HiFive action to friendToGreet
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users-friend-hifive')
          .where('id', isEqualTo: userId)
          .get();

      // return;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<FriendRequestModel> cancelFriendRequestSend(Friend friend, FriendRequestModel friendRequest) async {
    try {
      //Remove friend request sent
      friend.friendRequestSent.removeWhere((element) => element.id == friendRequest.id);

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());
      return friendRequest;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  //Remove request sent from currentUser.sent and UserToConnect.received
  static removeRequestSent(Friend currentUserFriend, String userRequestedId) async {
    try {
      //CREO EL FRIENDREQUESTMODEL PARA USERREQUESTED
      FriendRequestModel userRequestedAsRequestModel = FriendRequestModel(id: userRequestedId);

      //CREO EL FRIENDREQUESTMODEL PARA CURRENTUSER
      FriendRequestModel currentUserAsRequestModel = FriendRequestModel(id: currentUserFriend.id);

      //ELIMINO USERREQUESTED DE MIS FRIEND REQUEST SENT
      await cancelFriendRequestSend(currentUserFriend, userRequestedAsRequestModel);
      //PIDO EL MODELO FRIEND DE USERREQUESTED
      Friend userRequestedAsFriend = await getUserFriendsByUserId(userRequestedId);

      await ignoreFriendRequest(userRequestedAsFriend, currentUserAsRequestModel);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  //add on currentUser request sent to UserToConnect
  static Future<FriendRequestModel> addUserRequestToSent(Friend friend, FriendRequestModel friendRequest) async {
    try {
      friend.friendRequestSent.add(friendRequest);

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());

      return friendRequest;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  //add on UserToConnect the request on received
  static Future<FriendRequestModel> addUserRequestToReceived(String userRequestedId, String currentUserId) async {
    try {
      FriendRequestModel userToConnect = FriendRequestModel(id: currentUserId);

      Friend friend = await getUserFriendsByUserId(userRequestedId);

      friend.friendRequestReceived.add(userToConnect);

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('friends')
          .doc(friend.id)
          .set(friend.toJson());

      return userToConnect;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static sendRequestOfConnectOnBothUsers(Friend currentUserFriend, String userRequestedId) async {
    try {
      FriendRequestModel userRequestedAsRequestModel = FriendRequestModel(id: userRequestedId);

      addUserRequestToSent(currentUserFriend, userRequestedAsRequestModel);
      addUserRequestToReceived(userRequestedId, currentUserFriend.id);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
