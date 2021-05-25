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
  Firestore firestoreInstance;

  FirestoreProvider({collection}) {
    this.collection = collection;
    this.firestoreInstance = Firestore.instance;
  }
  FirestoreProvider.test({String collection, Firestore firestoreInstance}) {
    this.collection = collection;
    this.firestoreInstance = firestoreInstance;
  }

  Future<QuerySnapshot> getAll() {
    return firestoreInstance.collection(collection).getDocuments();
  }

  Future<DocumentSnapshot> get(String id) {
    return firestoreInstance.collection(collection).document(id).get();
  }

  Future<QuerySnapshot> getChild(String id, String childCollection) {
    return firestoreInstance
        .collection(collection)
        .document(id)
        .collection(childCollection)
        .getDocuments();
  }

  ///Get documents list from nested collections.
  ///
  ///[id] final document id after path.
  ///[childCollection] child collection present on every document in the path.
  ///[idPath] document id path to the [id] document. Ex. `{document_id}/{document_id}/{document_id}`.
  Future<QuerySnapshot> getChildWithPath(
      String id, String childCollection, String idPath) {
    List<String> idPathList = idPath.split('/');
    if (idPathList[0] == '') {
      idPathList = [];
    }
    CollectionReference finalCollection =
        firestoreInstance.collection(collection);
    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.document(idPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.document(id).collection(childCollection);
    return finalCollection.getDocuments();
  }

  addVideoResponse(parentVideoId, videoResponse, String idPath) {
    List<String> idPathList = idPath.split('/');
    idPathList = idPathList.length > 0 && idPathList[0] == '' ? [] : idPathList;
    CollectionReference finalCollection =
        firestoreInstance.collection(collection);

    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.document(idPathElement).collection('videoResponses');
    });
    finalCollection =
        finalCollection.document(parentVideoId).collection('videoResponses');

    final DocumentReference docRef = finalCollection.document();

    docRef.setData({
      'videoUrl': videoResponse.videoUrl,
      'thumbUrl': videoResponse.thumbUrl,
      'coverUrl': videoResponse.coverUrl,
      'aspectRatio': videoResponse.aspectRatio,
      'uploadedAt': videoResponse.uploadedAt,
      'videoName': videoResponse.videoName,
      'createdBy': videoResponse.createdBy,
      'id': docRef.documentID
    });
    return docRef.documentID;
  }

  Future<DocumentReference> add(dynamic entity) {
    return firestoreInstance.collection(collection).add(entity);
  }

  Future<void> set({String id, dynamic entity}) {
    return firestoreInstance
        .collection(collection)
        .document(id)
        .setData(entity);
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
