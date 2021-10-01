double getDoubleFromJson(jsonValue) {
  return jsonValue == null ? 0 : double.tryParse((jsonValue as num)?.toString());
}
