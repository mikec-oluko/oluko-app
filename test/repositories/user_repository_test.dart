// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:oluko_app/models/user_response.dart';
// import 'package:oluko_app/repositories/user_repository.dart';

// class MockFirestore extends Mock implements FirebaseFirestore {}

// class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

// class MockDocumentReference extends Mock implements DocumentReference {}

// class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

// class MockQuerySnapshot extends Mock implements Future<QuerySnapshot<Map<String, dynamic>>> {}

// class MockDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// void main() {
//   group('User Repository', () {
//     test('user should be retrieved correctly', () async {
//       FirebaseFirestore firestoreInstance = MockFirestore();
//       CollectionReference<Map<String, dynamic>> collectionReference = MockCollectionReference();
//       DocumentReference documentReference = MockDocumentReference();
//       Query<Map<String, dynamic>> query = MockQuery();
//       Future<QuerySnapshot<Map<String, dynamic>>> querySnapshot = MockQuerySnapshot();
//       QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot = MockDocumentSnapshot();

//       when(firestoreInstance.collection(any)).thenReturn(collectionReference);
//       when(collectionReference.where(any, isEqualTo: 'testEmail')).thenReturn(query);
//       when(query.get()).thenAnswer((realInvocation) => Future.value(querySnapshot));
//       when((await querySnapshot).docs).thenReturn([documentSnapshot]);
//       when(documentSnapshot.data() as Map<String, dynamic>)
//           .thenReturn(UserResponse(email: 'testEmail', id: 'testId', firebaseId: 'testFirebaseId').toJson());

//       final UserResponse response = await UserRepository.test(firestoreInstance: firestoreInstance).get('testEmail');

//       expect(response, isNotNull);
//       expect(response.email, 'testEmail');
//     });
//   });
// }
