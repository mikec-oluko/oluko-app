class ChangeUserInformation {
  ChangeUserInformation({
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.city,
    this.state,
    this.country,
  });

  String firstName, lastName, email, username, city, state, country;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> changeUserInformationJson = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'city': city,
      'state': state,
      'country': country,
    };
    return changeUserInformationJson;
  }
}