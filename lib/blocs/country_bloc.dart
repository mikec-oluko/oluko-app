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

class CountryFailure extends CountryState {
  final String exceptionMessage;
  CountryFailure({this.exceptionMessage});
}

class CountryBloc extends Cubit<CountryState> {
  CountryBloc() : super(Loading());
  List<Country> countries;

  Future<void> getCountriesWithStates(String country) async {
    try {
      if (countries != null && countries.isNotEmpty) {
        if (country != null && country != '') {
          final countryToUpdateIndex = countries.indexWhere((element) => element.name == country);
          if (countryToUpdateIndex != -1 &&
              (countries[countryToUpdateIndex].states == null || countries[countryToUpdateIndex].states.isEmpty)) {
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
}
