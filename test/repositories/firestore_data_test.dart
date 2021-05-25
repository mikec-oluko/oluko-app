import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/firestore_data.dart';

class MockDocumentReference extends Mock implements DocumentReference {}

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockQuery extends Mock implements Query {}

void main() {
  group('Sign Up', () {
    test('should get firebase collection', () async {
      final request = SignUpRequest(
          email: 'testemail-${DateTime.now().millisecondsSinceEpoch}@gmail.com',
          password: 'testpassword',
          firstName: 'testFirstName',
          lastName: 'testLastName');

      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      QuerySnapshot querySnapshot = MockQuerySnapshot();

      when(collectionReference.getDocuments())
          .thenAnswer((_) => Future.value(querySnapshot));
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);

      final response = await firestoreProvider.getAll();

      expect(response, isA<QuerySnapshot>());
    });
  });
}
