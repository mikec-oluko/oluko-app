class ForgotPasswordDto {
  ForgotPasswordDto({this.email, this.projectId});

  String email;
  String projectId;

  ForgotPasswordDto.fromJson(Map json)
      :
        email = json['email']?.toString(),
        projectId = json['projectId']?.toString();

  Map<String, dynamic> toJson() => {'email': email, 'projectId': projectId};
}
