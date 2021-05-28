// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  String collection;
  FirebaseFirestore firestoreInstance;

  FirestoreProvider({collection}) {
    this.collection = collection;
    this.firestoreInstance = FirebaseFirestore.instance;
  }
  FirestoreProvider.test(
      {String collection, FirebaseFirestore firestoreInstance}) {
    this.collection = collection;
    this.firestoreInstance = firestoreInstance;
  }

  Future<QuerySnapshot> getAll() {
    return firestoreInstance.collection(collection).get();
  }

  Future<DocumentSnapshot> get(String key) {
    return firestoreInstance.collection(collection).doc(key).get();
  }

  Future<QuerySnapshot> getChild(String key, String childCollection) {
    return firestoreInstance
        .collection(collection)
        .doc(key)
        .collection(childCollection)
        .get();
  }

  ///Get documents list from nested collections.
  ///
  ///[key] final document key after path.
  ///[childCollection] child collection present on every document in the path.
  ///[keyPath] document key path to the [key] document. Ex. `{document_key}/{document_key}/{document_key}`.
  Future<QuerySnapshot> getChildWithPath(
      String key, String childCollection, String keyPath) {
    List<String> keyPathList = keyPath.split('/');
    if (keyPathList[0] == '') {
      keyPathList = [];
    }
    CollectionReference finalCollection =
        firestoreInstance.collection(collection);
    keyPathList.forEach((keyPathElement) {
      finalCollection =
          finalCollection.doc(keyPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.doc(key).collection(childCollection);
    return finalCollection.get();
  }

  addVideoResponse(parentVideoKey, videoResponse, String keyPath) {
    List<String> keyPathList = keyPath.split('/');
    keyPathList =
        keyPathList.length > 0 && keyPathList[0] == '' ? [] : keyPathList;
    CollectionReference finalCollection =
        firestoreInstance.collection(collection);

    keyPathList.forEach((keyPathElement) {
      finalCollection =
          finalCollection.doc(keyPathElement).collection('videoResponses');
    });
    finalCollection =
        finalCollection.doc(parentVideoKey).collection('videoResponses');

    final DocumentReference docRef = finalCollection.doc();

    docRef.set({
      'videoUrl': videoResponse.videoUrl,
      'thumbUrl': videoResponse.thumbUrl,
      'coverUrl': videoResponse.coverUrl,
      'aspectRatio': videoResponse.aspectRatio,
      'uploadedAt': videoResponse.uploadedAt,
      'videoName': videoResponse.videoName,
      'createdBy': videoResponse.createdBy,
      'key': docRef.id
    });
    return docRef.id;
  }

  Future<DocumentReference> add(dynamic entity) {
    return firestoreInstance.collection(collection).add(entity);
  }

  Future<void> set({String key, dynamic entity}) {
    return firestoreInstance.collection(collection).doc(key).set(entity);
  }

  Stream<QuerySnapshot> listenAll() {
    return firestoreInstance.collection(collection).snapshots();
  }

  void addBatch(List<dynamic> entities) {
    entities.forEach((dynamic entity) {
      add(entity);
    });
  }
}
