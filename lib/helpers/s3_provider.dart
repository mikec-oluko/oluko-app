import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:oluko_app/helpers/s3_policy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/config/s3_settings.dart';

import '../services/connectivity_service.dart';

class S3Provider {
  String accessKeyId = GlobalConfiguration().getString('accessKeyID');
  String secretKeyId = GlobalConfiguration().getString('secretAccessKey');
  String endpoint = GlobalConfiguration().getString('bucket');
  String region = GlobalConfiguration().getString('region');
  bool isConfigLoaded = false;
  final GlobalService _globalService = GlobalService();

  StreamSubscription<ConnectivityResult> connectivityListener;

  S3Provider();

  void postFile(String accessKeyId, String secretKeyId) async {
    final file = File(path.join('/path/to/file', 'square-cinnamon.jpg'));
    final stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    final length = await file.length();

    final uri = Uri.parse(endpoint);
    final req = http.MultipartRequest('POST', uri);
    final multipartFile = http.MultipartFile('file', stream, length, filename: path.basename(file.path));

    final policy = Policy.fromS3PresignedPost('uploaded/square-cinnamon.jpg', 'bucketname', accessKeyId, 15, length, region: region);
    final key = SigV4.calculateSigningKey(secretKeyId, policy.datetime, region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    try {
      final res = await req.send();
      await for (var value in res.stream.transform(utf8.decoder)) {
        if (kDebugMode) {
          print(value);
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  void getFile(String fileName, String path) {
    final uri = Uri.parse('$endpoint/$path/$fileName');
    try {
      http.get(uri).then((http.Response res) => putFile(res.bodyBytes, 'Thumbnails', 'panda-test.jpg'));
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      ).then((e) => print(e.toString()));
      rethrow;
    }
  }

  Future<String> putFile(Uint8List bodyBytes, String path, String fileName) async {
    Response res;
    bool _networkChangedConnection = false;
    bool _hasInternetConnection = _globalService.hasInternetConnection;
    ConnectivityResult _connectivityType = _globalService.getConnectivityType;

    if (!_globalService.hasListeners) {
      _globalService.addListener(() {
        _hasInternetConnection = _globalService.hasInternetConnection;
        if ((_connectivityType == ConnectivityResult.wifi && _globalService.getConnectivityType == ConnectivityResult.mobile) ||
            (_connectivityType == ConnectivityResult.mobile && _globalService.getConnectivityType == ConnectivityResult.mobile)) {
          _networkChangedConnection = true;
          _connectivityType = _globalService.getConnectivityType;
        }
      });
    }

    isConfigLoaded == false ? loadConfig() : null;
    final uri = Uri.parse('$endpoint/$path/$fileName');
    try {
      if (_hasInternetConnection && !_networkChangedConnection) {
        res = await http.put(uri, body: bodyBytes, headers: {'x-amz-acl': 'bucket-owner-full-control'});
      } else {
        print('VIDEO_UPLOAD: No Internet Connection');
        res.request.finalize();
      }
      return res.request.url.toString();
    } on TimeoutException catch (_) {
      print('TimeoutException');
      res.request.finalize();
      rethrow;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      rethrow;
    }
  }

  void loadConfig() {
    if (this.endpoint != null) {
      this.isConfigLoaded = true;
    } else {
      GlobalConfiguration().loadFromMap(s3Settings);
      if (this.endpoint == null) {
        this.endpoint = GlobalConfiguration().getString('bucket');
      }
      if (this.region == null) {
        this.region = GlobalConfiguration().getString('region');
      }
      if (this.accessKeyId == null) {
        this.accessKeyId = GlobalConfiguration().getString('accessKeyID');
      }
      if (this.secretKeyId == null) {
        this.secretKeyId = GlobalConfiguration().getString('secretAccessKey');
      }
      this.isConfigLoaded = true;
    }
  }
}
