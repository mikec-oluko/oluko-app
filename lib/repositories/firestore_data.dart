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

  FirestoreProvider({this.collection});

  Future<QuerySnapshot> getAll() {
    return Firestore.instance.collection(collection).getDocuments();
  }

  Future<DocumentSnapshot> get(String key) {
    return Firestore.instance.collection(collection).document(key).get();
  }

  Future<QuerySnapshot> getChild(String key, String childCollection) {
    return Firestore.instance
        .collection(collection)
        .document(key)
        .collection(childCollection)
        .getDocuments();
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
        Firestore.instance.collection(collection);
    keyPathList.forEach((keyPathElement) {
      finalCollection =
          finalCollection.document(keyPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.document(key).collection(childCollection);
    return finalCollection.getDocuments();
  }

  addVideoResponse(parentVideoKey, videoResponse, String keyPath) {
    List<String> keyPathList = keyPath.split('/');
    keyPathList =
        keyPathList.length > 0 && keyPathList[0] == '' ? [] : keyPathList;
    CollectionReference finalCollection =
        Firestore.instance.collection(collection);

    keyPathList.forEach((keyPathElement) {
      finalCollection = finalCollection
          .document(keyPathElement)
          .collection('videoResponses');
    });
    finalCollection =
        finalCollection.document(parentVideoKey).collection('videoResponses');

    final DocumentReference docRef = finalCollection.document();

    docRef.setData({
      'videoUrl': videoResponse.videoUrl,
      'thumbUrl': videoResponse.thumbUrl,
      'coverUrl': videoResponse.coverUrl,
      'aspectRatio': videoResponse.aspectRatio,
      'uploadedAt': videoResponse.uploadedAt,
      'videoName': videoResponse.videoName,
      'createdBy': videoResponse.createdBy,
      'key': docRef.documentID
    });
    return docRef.documentID;
  }

  Future<DocumentReference> add(dynamic entity) {
    return Firestore.instance.collection(collection).add(entity);
  }

  Future<void> set({String key, dynamic entity}) {
    return Firestore.instance
        .collection(collection)
        .document(key)
        .setData(entity);
  }

  Stream<QuerySnapshot> listenAll() {
    return Firestore.instance.collection(collection).snapshots();
  }

  void addBatch(List<dynamic> entities) {
    entities.forEach((dynamic entity) {
      add(entity);
    });
  }
}
