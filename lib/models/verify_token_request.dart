class VerifyTokenRequest {
  VerifyTokenRequest({this.tokenId});

  String tokenId;

  VerifyTokenRequest.fromJson(Map json) : tokenId = json['token_id'];

  Map<String, dynamic> toJson() => {
        'token_id': tokenId,
      };
}
