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
    /*test('should create marker (1)', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();

      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.setData(any))
          .thenAnswer((realInvocation) => Future.value(null));
      when(documentReference.documentID).thenReturn('testId');

      MarkerRepository markerRepository =
          MarkerRepository.test(firestoreInstance: firestoreInstance);

      final testMarker = Marker(id: 'testId', position: 2.32, videoId: '2521');

      final response = await markerRepository.createMarker1(testMarker);

      expect(response, isA<Marker>());
      expect(response.id, testMarker.id);
      expect(response.position, testMarker.position);
      expect(response.videoId, testMarker.videoId);
    });*/

    /*test('should create marker (2)', () async {
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

      final testMarker = Marker(id: 'testId', position: 2.32, videoId: '2521');
      final parentVideoId = 'parentTest';

      final response =
          await markerRepository.createMarker(parentVideoId, testMarker);

      expect(response, isA<String>());
      expect(response, testMarker.id);
    });*/
  });
}
