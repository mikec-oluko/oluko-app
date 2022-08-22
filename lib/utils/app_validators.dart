enum PasswordStrength { weak, medium, strong }
enum ValidatorNames { containsUppercase, containsLowercase, containsDigit, containsSpecialChar, containsRecommendedChars, containsMinChars }
enum StringValidation {
  isValidUserName,
  isValidFirstAndLastName,
  containsBlankSpaces,
  startorEndWithBlankSpace,
  containsMinChars,
  containsSpecialChars,
  isAlphabetic,
  isAlphanumeric,
  isValidEmail
}

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

  Map<StringValidation, bool> getStringValidationState(String value, {int minStringLength}) {
    Map<StringValidation, bool> stringValidator = {};

    stringValidator[StringValidation.containsBlankSpaces] = validatePattern(value, r'\s+');
    stringValidator[StringValidation.startorEndWithBlankSpace] = validatePattern(value, r'^\s[a-z]+$') || validatePattern(value, r'^[a-z]+\s+$');
    stringValidator[StringValidation.containsMinChars] = validatePattern(value, r'^.{3,}');
    stringValidator[StringValidation.containsSpecialChars] = validatePattern(value, r'^[a-zA-Z0-9]+$');
    stringValidator[StringValidation.isValidEmail] = validatePattern(value,
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    stringValidator[StringValidation.isAlphabetic] = validatePattern(value, r'^[a-zA-Z]+$');
    stringValidator[StringValidation.isAlphanumeric] = validatePattern(value, r'^[a-zA-Z0-9]+$');
    stringValidator[StringValidation.isValidUserName] = validatePattern(value, r'^\S[a-zA-Z0-9_.-]{3,}$');
    stringValidator[StringValidation.isValidFirstAndLastName] = validatePattern(value, r'^[^0-9 ]+([a-zA-Z]+\s?)+[a-zA-Z]+$');

    List<StringValidation> validatorsWithError = [];
    stringValidator.forEach((key, value) {
      if (value == false) {
        validatorsWithError.add(key);
      }
    });

    return stringValidator;
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
