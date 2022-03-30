class UserHelper {
  static String printUsername(String username, String userId) {
    return username == userId ? '' : username;
  }
  
  static String getFullName(String firstName, String lastName) {
    return "${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()} ${lastName[0].toUpperCase()}${lastName.substring(1).toLowerCase()}";
  }
}
