import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/country_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/country.dart';
import 'package:oluko_app/models/enums/register_fields_enum.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/app_validators.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class OlukoRegisterTextfield extends StatefulWidget {
  final String title;
  final RegisterFieldEnum fieldType;
  final Function(Map<ValidatorNames, bool> passwordValidationState) onPasswordValidate;
  final Function(String value) onInputUpdated;
  const OlukoRegisterTextfield({Key key, this.title, this.fieldType, this.onPasswordValidate, this.onInputUpdated}) : super();

  @override
  State<OlukoRegisterTextfield> createState() => _OlukoRegisterTextfieldState();
}

class _OlukoRegisterTextfieldState extends State<OlukoRegisterTextfield> {
  TextEditingController controller = TextEditingController();
  String errorMessage;
  bool existError = false;
  List<Country> countries = [];
  Country _selectedCountry;
  Country newCountryWithStates;
  Country _countryWithStates;
  List<String> defaultStates = ['-'];
  String _selectedState;
  bool _peekPassword = false;
  Map<StringValidation, bool> stringValidator = {};

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: (widget.fieldType == RegisterFieldEnum.COUNTRY || widget.fieldType == RegisterFieldEnum.STATE)
            ? _getDropDown(widget.fieldType)
            : _getTextFormField(context));
  }

  Widget _getDropDown(RegisterFieldEnum fieldType) {
    Widget _dropDownSelected;
    if (widget.fieldType == RegisterFieldEnum.COUNTRY) {
      _dropDownSelected = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: countriesDropdown(),
      );
    }
    if (widget.fieldType == RegisterFieldEnum.STATE) {
      _dropDownSelected = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: statesDropdown(),
      );
    }
    return _dropDownSelected;
  }

  TextFormField _getTextFormField(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.black),
      decoration: InputDecoration(
        errorText: existError ? errorMessage : '',
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: existError ? OlukoColors.error : OlukoColors.grayColor),
        ),
        errorBorder: existError
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: OlukoColors.error),
              )
            : OutlineInputBorder(
                borderSide: const BorderSide(color: OlukoColors.grayColor),
                borderRadius: BorderRadius.circular(5),
              ),
        labelText: widget.title,
        labelStyle: TextStyle(height: 1, color: existError ? OlukoColors.error : OlukoColors.grayColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: OlukoColors.grayColor),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: OlukoColors.grayColor),
          borderRadius: BorderRadius.circular(5),
        ),
        filled: true,
        hintStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.primary),
        hintText: widget.title,
        fillColor: OlukoColors.white,
        suffixIcon: !_isPasswordField(widget.fieldType)
            ? controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: OlukoColors.black,
                    ),
                  )
                : null
            : PeekPassword(
                onPressed: (bool peekPassword) => {
                  setState(() {
                    _peekPassword = peekPassword;
                  })
                },
              ),
      ),
      obscureText: _isPasswordField(widget.fieldType) && !_peekPassword,
      cursorColor: OlukoColors.primary,
      cursorWidth: 1.5,
      onChanged: (value) {
        if (value == null || value.isEmpty) {
          if (_isPasswordField(widget.fieldType)) widget.onPasswordValidate(AppValidators().getPasswordValidationState(value));
        } else {
          stringValidator = AppValidators().getStringValidationState(value);
          switch (widget.fieldType) {
            case RegisterFieldEnum.USERNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(minCharsError: true));
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(blankSpacesError: true));
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(startOrEndBlankError: true));
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(specialCharsError: true));
                } else if (!stringValidator[StringValidation.isAlphanumeric]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(alphaNumericError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.FIRSTNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(minCharsError: true));
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(blankSpacesError: true));
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(startOrEndBlankError: true));
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(specialCharsError: true));
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(alphabeticError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.CITY:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(minCharsError: true));
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(blankSpacesError: true));
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(startOrEndBlankError: true));
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(specialCharsError: true));
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(alphabeticError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.LASTNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(minCharsError: true));
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(blankSpacesError: true));
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(startOrEndBlankError: true));
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(specialCharsError: true));
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(alphabeticError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.EMAIL:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.isValidEmail]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(emailError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.PASSWORD:
              widget.onPasswordValidate(AppValidators().getPasswordValidationState(value));
              break;
            default:
          }
          widget.onInputUpdated(value);
        }
      },
      onSaved: (value) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return OlukoLocalizations.get(context, 'required');
        } else {
          stringValidator = AppValidators().getStringValidationState(value);
          switch (widget.fieldType) {
            case RegisterFieldEnum.USERNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  return _getErrorMessage(minCharsError: true);
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  return _getErrorMessage(blankSpacesError: true);
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  return _getErrorMessage(startOrEndBlankError: true);
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  return _getErrorMessage(specialCharsError: true);
                } else if (!stringValidator[StringValidation.isAlphanumeric]) {
                  return _getErrorMessage(alphaNumericError: true);
                } else {
                  return null;
                }
              }
              break;
            case RegisterFieldEnum.FIRSTNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  return _getErrorMessage(minCharsError: true);
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  return _getErrorMessage(blankSpacesError: true);
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  return _getErrorMessage(startOrEndBlankError: true);
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  return _getErrorMessage(specialCharsError: true);
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  return _getErrorMessage(alphabeticError: true);
                } else {
                  return null;
                }
              }
              break;
            case RegisterFieldEnum.CITY:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(minCharsError: true));
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(blankSpacesError: true));
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(startOrEndBlankError: true));
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(specialCharsError: true));
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  setErrorMessage(errorMessageToShow: _getErrorMessage(alphabeticError: true));
                } else {
                  _clearFieldErrors();
                }
              }
              break;
            case RegisterFieldEnum.LASTNAME:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.containsMinChars]) {
                  return _getErrorMessage(minCharsError: true);
                } else if (stringValidator[StringValidation.containsBlankSpaces]) {
                  return _getErrorMessage(blankSpacesError: true);
                } else if (stringValidator[StringValidation.startorEndWithBlankSpace]) {
                  return _getErrorMessage(startOrEndBlankError: true);
                } else if (!stringValidator[StringValidation.containsSpecialChars]) {
                  return _getErrorMessage(specialCharsError: true);
                } else if (!stringValidator[StringValidation.isAlphabetic]) {
                  return _getErrorMessage(alphabeticError: true);
                } else {
                  return null;
                }
              }
              break;
            case RegisterFieldEnum.EMAIL:
              if (stringValidator != null) {
                if (!stringValidator[StringValidation.isValidEmail]) {
                  return _getErrorMessage(emailError: true);
                } else {
                  return null;
                }
              }
              break;
            case RegisterFieldEnum.PASSWORD:
              widget.onPasswordValidate(AppValidators().getPasswordValidationState(value));
              return null;
              break;
            default:
          }
        }
        return null;
      },
    );
  }

  void _clearFieldErrors() {
    setState(() {
      existError = false;
      errorMessage = '';
    });
  }

  String _getErrorMessage(
      {bool specialCharsError = false,
      bool startOrEndBlankError = false,
      bool blankSpacesError = false,
      bool alphaNumericError = false,
      bool alphabeticError = false,
      bool emailError = false,
      bool minCharsError = false}) {
    final String _specialChar = OlukoLocalizations.get(context, 'errorMessageSpecialCharacters');
    final String _onlyAlphabetic = OlukoLocalizations.get(context, 'errorMessageOnlyAlphabetic');
    final String _onlyAlphaNumeric = OlukoLocalizations.get(context, 'errorMessageOnlyAlphanumeric');
    final String _hasBlankSpaces = OlukoLocalizations.get(context, 'errorMessageContainBlankSpace');
    final String _startOrEndWithBlankSpace = OlukoLocalizations.get(context, 'errorMessageBlankSpace');
    final String _invalidLength = OlukoLocalizations.get(context, 'errorMessageMustContainAtLeast') + OlukoLocalizations.get(context, 'characters');
    final String _isNotEmail = OlukoLocalizations.get(context, 'errorMessageInvalidEmail');
    final String _errorMessageBase = '${OlukoLocalizations.get(context, 'errorMessageTheField')} ${widget.title}';
    String _endMessage = 'Is invalid';

    if (specialCharsError) _endMessage = _specialChar;
    if (startOrEndBlankError) _endMessage = _startOrEndWithBlankSpace;
    if (blankSpacesError) _endMessage = _hasBlankSpaces;
    if (alphaNumericError) _endMessage = _onlyAlphaNumeric;
    if (alphabeticError) _endMessage = _onlyAlphabetic;
    if (emailError) _endMessage = _isNotEmail;
    if (minCharsError) _endMessage = _invalidLength;

    return _errorMessageBase + _endMessage;
  }

  void setErrorMessage({@required String errorMessageToShow}) {
    setState(() {
      existError = true;
      errorMessage = errorMessageToShow;
    });
  }

  bool _isPasswordField(RegisterFieldEnum textfieldType) => textfieldType == RegisterFieldEnum.PASSWORD;

  Widget countriesDropdown() {
    return BlocListener<CountryBloc, CountryState>(
      listener: (context, state) {
        if (state is CountrySuccess) {
          if (countries == null || countries.isEmpty) {
            setState(() {
              countries = state.countries;
            });
          }
        }
      },
      child: countries != null && countries.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: OlukoColors.grayColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                  dropdownColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : Colors.transparent,
                  isExpanded: true,
                  value: _selectedCountry?.name ?? countries[0].name,
                  items: countries.map<DropdownMenuItem<String>>((Country country) {
                    return DropdownMenuItem<String>(
                      value: country.name,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          country.name,
                          overflow: TextOverflow.ellipsis,
                          style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String item) async {
                    _selectedCountry = countries.firstWhere((country) => country.name == item);
                    final List<String> statesOfSelectedCountry = _selectedCountry?.states;
                    var newFieldsState = '';
                    var newCountries = countries;
                    if (statesOfSelectedCountry != null && statesOfSelectedCountry.isNotEmpty) {
                      newFieldsState = statesOfSelectedCountry[0];
                    } else {
                      newCountries = await BlocProvider.of<CountryBloc>(context).getStatesForCountry(_selectedCountry.id);
                      newCountryWithStates = newCountries.firstWhere((element) => element.id == _selectedCountry.id);
                      BlocProvider.of<CountryBloc>(context).emitSelectedCountryState(newCountryWithStates);
                      newFieldsState = newCountryWithStates != null && AppValidators.isNeitherNullNorEmpty(newCountryWithStates.states)
                          ? newCountryWithStates.states[0]
                          : '-';
                    }
                    setState(() {
                      countries = newCountries;
                    });
                    widget.onInputUpdated(item);
                  },
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
              child: Text(
                '-',
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
              ),
            ),
    );
  }

  Widget statesDropdown() {
    return BlocListener<CountryBloc, CountryState>(
      listener: (context, state) {
        if (state is CountryWithStateSuccess) {
          setState(() {
            _countryWithStates = state.country;
          });
        }
      },
      child: _countryWithStates != null
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: OlukoColors.grayColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                  dropdownColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent,
                  isExpanded: true,
                  value: _selectedState ?? _countryWithStates.states[0],
                  items: _countryWithStates.states.isNotEmpty
                      ? _countryWithStates.states.map<DropdownMenuItem<String>>((String countryState) {
                          return DropdownMenuItem<String>(
                            value: countryState,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                countryState,
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                              ),
                            ),
                          );
                        }).toList()
                      : defaultStates.map<DropdownMenuItem<String>>((String countryState) {
                          return DropdownMenuItem<String>(
                            value: countryState,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                countryState,
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                              ),
                            ),
                          );
                        }).toList(),
                  onChanged: (String item) async {
                    setState(() {
                      _selectedState = item;
                    });
                    widget.onInputUpdated(item);
                  },
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: OlukoColors.grayColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                  borderRadius: BorderRadius.circular(5),
                  dropdownColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent,
                  isExpanded: true,
                  value: '-',
                  items: defaultStates.map<DropdownMenuItem<String>>((String countryState) {
                    return DropdownMenuItem<String>(
                      value: countryState,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          countryState,
                          overflow: TextOverflow.ellipsis,
                          style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.primary),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String item) async {
                    setState(() {
                      _selectedState = item;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
