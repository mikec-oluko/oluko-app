import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/firestore_data.dart';

class MockDocumentReference extends Mock implements DocumentReference {}

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockQuery extends Mock implements Query {}

void main() {
  group('Firestore Repository ', () {
    test('should get firebase collection', () async {
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

    test('should get firebase document', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();
      DocumentSnapshot documentSnapshot = MockDocumentSnapshot();
      String key = 'testKey';
      when(documentReference.get())
          .thenAnswer((realInvocation) => Future.value(documentSnapshot));
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      final response = await firestoreProvider.get(key);
      expect(response, isA<DocumentSnapshot>());
    });

    test('should get firebase child document', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();
      QuerySnapshot querySnapshot = MockQuerySnapshot();

      String key = 'testKey';

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.collection(any)).thenReturn(collectionReference);
      when(collectionReference.getDocuments())
          .thenAnswer((realInvocation) => Future.value(querySnapshot));

      final response = await firestoreProvider.getChild(key, 'childCollection');
      expect(response, isA<QuerySnapshot>());
    });

    test('should get firebase child with path', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();
      QuerySnapshot querySnapshot = MockQuerySnapshot();

      String key = 'testKey';
      String childCollection = 'childCollection';
      String pathCollection = 'pathCollection';

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.collection(any)).thenReturn(collectionReference);
      when(collectionReference.getDocuments())
          .thenAnswer((realInvocation) => Future.value(querySnapshot));

      final response = await firestoreProvider.getChildWithPath(
          key, childCollection, pathCollection);
      expect(response, isA<QuerySnapshot>());
    });

    /*test('should add video response', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();

      String documentId = 'testDocumentId';
      String parentVideoKey = 'testKey';
      Video videoResponse = Video(videoUrl: 'testVideourl');
      String keyPath = 'pathCollection';

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);
      when(documentReference.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document()).thenReturn(documentReference);
      when(documentReference.documentID).thenReturn(documentId);

      final response = await firestoreProvider.addVideoResponse(
          parentVideoKey, videoResponse, keyPath);
      expect(response, isA<String>());
      expect(response, documentId);
    });*/

    test('should add entity', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();

      Video videoResponse = Video(videoUrl: 'testVideourl');

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.add(any))
          .thenAnswer((realInvocation) => Future.value(documentReference));

      final response = await firestoreProvider.add(videoResponse.toJson());
      expect(response, isA<DocumentReference>());
    });

    test('should set entity', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      DocumentReference documentReference = MockDocumentReference();

      Video videoResponse = Video(videoUrl: 'testVideourl');
      String key = 'testKey';
      Map<String, dynamic> entity = videoResponse.toJson();

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.document(any)).thenReturn(documentReference);

      await firestoreProvider.set(id: key, entity: entity);
    });

    test('should listen snapshots', () async {
      Firestore firestoreInstance = MockFirestore();
      CollectionReference collectionReference = MockCollectionReference();
      QuerySnapshot querySnapshot = MockQuerySnapshot();

      Video videoResponse = Video(videoUrl: 'testVideourl');
      Map<String, dynamic> entity = videoResponse.toJson();

      FirestoreProvider firestoreProvider = FirestoreProvider.test(
          collection: 'videos', firestoreInstance: firestoreInstance);
      when(firestoreInstance.collection(any)).thenReturn(collectionReference);
      when(collectionReference.snapshots())
          .thenAnswer((_) => Stream.value(querySnapshot));

      Stream<QuerySnapshot> response = firestoreProvider.listenAll();
      expect(response, isA<Stream<QuerySnapshot>>());
    });
  });
}
