class ApiResponse {
  ApiResponse({this.message, this.error, this.statusCode, this.data});

  num statusCode;
  List<dynamic> message;
  String error;
  dynamic data;

  ApiResponse.fromJson(Map json)
      : statusCode = json['statusCode'],
        message = json['message'],
        error = json['error'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
        'error': error,
        'data': data
      };
}
