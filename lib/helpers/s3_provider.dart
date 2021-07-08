import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:global_configuration/global_configuration.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:mvt_fitness/helpers/s3_policy.dart';

class S3Provider {
  String accessKeyId = GlobalConfiguration().getValue("accessKeyID");
  String secretKeyId = GlobalConfiguration().getValue("secretAccessKey");
  String endpoint = GlobalConfiguration().getValue("bucket");
  String region = GlobalConfiguration().getValue("region");

  S3Provider();
  //{this.accessKeyId, this.secretKeyId, this.endpoint, this.region}
  void postFile(accessKeyId, secretKeyId) async {
    final file = File(path.join('/path/to/file', 'square-cinnamon.jpg'));
    final stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    final length = await file.length();

    final uri = Uri.parse(endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile('file', stream, length,
        filename: path.basename(file.path));

    final policy = Policy.fromS3PresignedPost(
        'uploaded/square-cinnamon.jpg', 'bucketname', accessKeyId, 15, length,
        region: region);
    final key =
        SigV4.calculateSigningKey(secretKeyId, policy.datetime, region, 's3');
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
        print(value);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getFile(String fileName, String path) async {
    final uri = Uri.parse('$endpoint/$path/$fileName');
    try {
      http.Response res = await http.get(uri);
      await putFile(res.bodyBytes, 'Thumbnails', 'panda-test.jpg');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> putFile(
      Uint8List bodyBytes, String path, String fileName) async {
    final uri = Uri.parse('$endpoint/$path/$fileName');
    http.Response res;

    try {
      res = await http.put(uri,
          body: bodyBytes, headers: {'x-amz-acl': 'bucket-owner-full-control'});
      return res.request.url.toString();
    } catch (e) {
      print(e.toString());
    }
  }
}
