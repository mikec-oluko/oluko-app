import 'package:cloud_firestore/cloud_firestore.dart';

double getDoubleFromJson(jsonValue) {
  return jsonValue == null ? 0 : double.tryParse((jsonValue as num)?.toString());
}

Timestamp getTimestamp(jsonValue) {
  return jsonValue is FieldValue
      ? null
      : jsonValue is Timestamp
          ? jsonValue
          : jsonValue is Map
              ? Timestamp(jsonValue['_seconds'] as int, jsonValue['_nanoseconds'] as int)
              : jsonValue is int
                  ? Timestamp.fromMillisecondsSinceEpoch(jsonValue)
                  : null;
}
