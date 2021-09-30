class ApiResponse {
  ApiResponse({this.message, this.error, this.statusCode, this.data});

  num statusCode;
  String message;
  String error;
  dynamic data;

  ApiResponse.fromJson(Map json)
      : statusCode = num.tryParse(json['statusCode']?.toString()),
        message = json['message']?.toString(),
        error = json['error']?.toString(),
        data = json['data'];

  Map<String, dynamic> toJson() => {'statusCode': statusCode, 'message': message, 'error': error, 'data': data};
}
