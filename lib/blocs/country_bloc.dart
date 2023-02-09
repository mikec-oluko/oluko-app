import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/country.dart';
import 'package:oluko_app/repositories/country_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CountryState {}

class Loading extends CountryState {}

class CountrySuccess extends CountryState {
  List<Country> countries;
  CountrySuccess({this.countries});
}

class CountryWithStateSuccess extends CountryState {
  Country country;
  CountryWithStateSuccess({this.country});
}

class CountryFailure extends CountryState {
  final String exceptionMessage;
  CountryFailure({this.exceptionMessage});
}

class CountryBloc extends Cubit<CountryState> {
  CountryBloc() : super(Loading());
  List<Country> countries;
  final String _mainCountryName = 'United States';

  Future<void> getCountriesWithStates(String country) async {
    try {
      if (countries != null && countries.isNotEmpty) {
        if (country != null && country != '') {
          final countryToUpdateIndex = countries.indexWhere((element) => element.name == country);
          if (countryToUpdateIndex != -1 && (countries[countryToUpdateIndex].states == null || countries[countryToUpdateIndex].states.isEmpty)) {
            countries[countryToUpdateIndex].states = await CountryRepository.getCountryStates(countries[countryToUpdateIndex].id);
            emit(CountrySuccess(countries: countries));
          }
        }
      } else {
        countries = await CountryRepository.getCountries(country);
        emit(CountrySuccess(countries: countries));
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(CountryFailure(exceptionMessage: e.toString()));
    }
  }

  Future<List<Country>> getStatesForCountry(String countryId) async {
    try {
      var countryIndex = countries.indexWhere((item) => item.id == countryId);
      if (countryIndex != -1) {
        countries[countryIndex].states = await CountryRepository.getCountryStates(countryId);
        return countries;
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void clear() {
    countries = [];
  }

  Future<void> getAllCountries() async {
    try {
      countries = await CountryRepository.getAllCountries();
      if (countries.isNotEmpty) {
        _orderCountryList();
        await getStatesForCountry(countries[0].id);
        emit(CountrySuccess(countries: countries));
         emit(CountryWithStateSuccess(country: countries[0]));
      } else {
        emit(CountryFailure());
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _orderCountryList() {
    final _mainCountryResult = countries.where((country) => country.name == _mainCountryName).toList();
    if (_mainCountryResult.isNotEmpty) {
      final int _indexOfMainCountry = countries.indexOf(_mainCountryResult.first);
      Country _mainCountry = countries.elementAt(_indexOfMainCountry);
      countries.removeAt(_indexOfMainCountry);
      countries.insert(0, _mainCountry);
    }
  }

  void emitSelectedCountryState(Country selectedCountry) {
    emit(CountryWithStateSuccess(country: selectedCountry));
  }
}
