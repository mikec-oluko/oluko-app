enum PasswordStrength { weak, medium, strong }
enum ValidatorNames { containsUppercase, containsLowercase, containsDigit, containsSpecialChar, containsRecommendedChars, containsMinChars }

class AppValidators {
  PasswordStrength validatePassword(String value) {
    Map<ValidatorNames, bool> validators = {};

    validators[ValidatorNames.containsUppercase] = validatePattern(value, r'[A-Z]');
    validators[ValidatorNames.containsLowercase] = validatePattern(value, r'[a-z]');
    validators[ValidatorNames.containsDigit] = validatePattern(value, r'[0-9]');
    validators[ValidatorNames.containsSpecialChar] = validatePattern(value, r'[!@#\$&*~]');
    validators[ValidatorNames.containsRecommendedChars] = validatePattern(value, r'^.{8,}');
    validators[ValidatorNames.containsMinChars] = validatePattern(value, r'^.{6,}');

    List<ValidatorNames> validatorsWithError = [];
    validators.forEach((key, value) {
      if (value == false) {
        validatorsWithError.add(key);
      }
    });

    if (validatorsWithError.length == 0) {
      return PasswordStrength.strong;
    } else if (validatorsWithError.length == 1 && validators[ValidatorNames.containsRecommendedChars] == false) {
      return PasswordStrength.medium;
    } else if (validatorsWithError.length == 1 && validators[ValidatorNames.containsDigit] == false) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  Map<ValidatorNames, bool> getPasswordValidationState(String value) {
    Map<ValidatorNames, bool> validators = {};

    validators[ValidatorNames.containsUppercase] = validatePattern(value, r'[A-Z]');
    validators[ValidatorNames.containsLowercase] = validatePattern(value, r'[a-z]');
    validators[ValidatorNames.containsDigit] = validatePattern(value, r'[0-9]');
    validators[ValidatorNames.containsMinChars] = validatePattern(value, r'^.{8,}');

    List<ValidatorNames> validatorsWithError = [];
    validators.forEach((key, value) {
      if (value == false) {
        validatorsWithError.add(key);
      }
    });

    return validators;
  }

  bool validatePattern(String value, Pattern pattern) {
    RegExp regex = new RegExp(pattern.toString());
    print(value);
    if (value.isEmpty) {
      return false;
    } else {
      if (!value.contains(regex))
        return false;
      else
        return true;
    }
  }

  static bool isNeitherNullNorEmpty(dynamic list) {
    if (list == null) {
      return false;
    }
    try {
      if (list.isNotEmpty as bool) {
        return true;
      }
    } catch (e) {}
    return false;
  }
}
