class UserHelper {
  static String printUsername(String username, String userId) {
    return username == userId ? '' : username;
  }

  static String getFullName(String firstName, String lastName, {bool isCurrentUser = true}) {
    var fullName = '';
    if (firstName != null && firstName.isNotEmpty) {
      fullName += isCurrentUser
          ? '${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()} '
          : '${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()} ';
    }
    if (lastName != null && lastName.isNotEmpty) {
      fullName += isCurrentUser
          ? '${lastName[0].toUpperCase()}${lastName.substring(1).toLowerCase()}'
          : '${lastName[0].toUpperCase()}.';
    }
    return fullName;
  }
}
