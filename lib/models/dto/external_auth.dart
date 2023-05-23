class ExternalAuthDto {
  ExternalAuthDto({this.tokenId, this.email, this.projectId, this.avatar, this.firstName, this.lastName});

  String tokenId;
  String projectId;
  String avatar;
  String firstName;
  String lastName;
  String email;

  Map<String, dynamic> toJson() => {'tokenId': tokenId, 'email': email, 'projectId': projectId, 'avatar': avatar, 'firstName': firstName, 'lastName': lastName};
}
