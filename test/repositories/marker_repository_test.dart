import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/models/marker.dart';
import 'package:oluko_app/repositories/firestore_repository.dart';
import 'package:oluko_app/repositories/marker_repository.dart';

class MockDocumentReference extends Mock implements DocumentReference {}

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockQuery extends Mock implements Query {}

void main() {
  group('Marker Repository ', () {
    /*test('should create marker ', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();

      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.collection(any)).thenReturn(collectionReference);
      when(documentReference.setData(any))
          .thenAnswer((realInvocation) => Future.value(null));
      when(documentReference.documentID).thenReturn('testId');

      MarkerRepository markerRepository =
          MarkerRepository.test(firestoreInstance: firestoreInstance);

      final testMarker = Marker(id: 'testId', position: 2.32);
      final parentVideoId = 'parentTest';

      final response =
          await markerRepository.createMarker(parentVideoId, testMarker);

      expect(response, isA<Marker>());
      expect(response.id, testMarker.id);
    });

    test('should get markers ', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();
      QuerySnapshot querySnapshot = MockQuerySnapshot();
      DocumentSnapshot documentSnapshot = MockDocumentSnapshot();
      final testMarker = Marker(id: 'testId', position: 2.32);

      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.collection(any)).thenReturn(collectionReference);
      when(documentSnapshot.documentID).thenReturn(testMarker.id);
      when(documentSnapshot.data).thenReturn(testMarker.toJson());
      when(querySnapshot.documents).thenReturn([documentSnapshot]);

      when(collectionReference.getDocuments())
          .thenAnswer((realInvocation) => Future.value(querySnapshot));
      when(documentReference.documentID).thenReturn('testId');

      MarkerRepository markerRepository =
          MarkerRepository.test(firestoreInstance: firestoreInstance);

      final parentVideoId = 'parentTest';

      final response = await markerRepository.getVideoMarkers(parentVideoId);

      expect(response, isA<List<Marker>>());
      expect(response.length, 1);
    });*/
  });
}
