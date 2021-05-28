import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('User Repository', () {
    test('user should be retrieved correctly', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();
      Query query = MockQuery();
      QuerySnapshot querySnapshot = MockQuerySnapshot();
      DocumentSnapshot documentSnapshot = MockDocumentSnapshot();

      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.where(any, isEqualTo: 'testEmail'))
          .thenReturn(query);
      when(query.getDocuments())
          .thenAnswer((realInvocation) => Future.value(querySnapshot));
      when(querySnapshot.documents).thenReturn([documentSnapshot]);
      when(documentSnapshot.data).thenReturn(UserResponse(
              email: 'testEmail', id: 'testId', firebaseId: 'testFirebaseId')
          .toJson());

      final UserResponse response =
          await UserRepository.test(firestoreInstance: firestoreInstance)
              .get('testEmail');

      expect(response, isNotNull);
      expect(response.email, 'testEmail');
    });
  });
}
