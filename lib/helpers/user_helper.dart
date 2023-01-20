class UserHelper {
  static String printUsername(String username, String userId) {
    return username == userId ? '' : username;
  }

  static String getFullName(String firstName, String lastName, {bool isCurrentUser = true}) {
    return isCurrentUser
        ? "${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()} ${lastName[0].toUpperCase()}${lastName.substring(1).toLowerCase()}"
        : '${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()} ${lastName[0].toUpperCase()}.';
  }
}
