import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/dto/country.dart';

class CountryRepository {
  FirebaseFirestore firestoreInstance;

  CountryRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CountryRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Assessment>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('assessments').get();
    List<Assessment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Assessment.fromJson(element));
    });
    return response;
  }

  static Future<List<Country>> getCountries(String countryName) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance.collection('countries').orderBy('name').get();
    final List<Country> countries = [];
    for (final doc in docRef.docs) {
      final Map<String, dynamic> countryMap = doc.data() as Map<String, dynamic>;
      final country = Country.fromJson(countryMap);
      if (countryName != null && countryName == country.name) {
        country.states = await getCountryStates(country.id);
      }
      countries.add(country);
    }
    if (countryName == null) {
      countries[0].states = await getCountryStates(countries[0].id);
    }
    return countries;
  }

  static Future<List<String>> getCountryStates(String countryId) async {
    final snapshot = await FirebaseFirestore.instance.collection('countries').doc(countryId).collection('states').get();
    final docs = snapshot.docs;
    if (docs.isNotEmpty) {
      final states = docs[0].data()['states'] as List<dynamic>;
      return states.map((state) => state.toString()).toList();
    }
    return [];
  }

  static Future<List<Country>> getAllCountries() async {
    final List<Country> _allCountries = [];
    final QuerySnapshot docRef = await FirebaseFirestore.instance.collection('countries').orderBy('name').get();
    if (docRef.docs.isNotEmpty) {
      docRef.docs.forEach((countryDoc) {
        final Map<String, dynamic> countryMap = countryDoc.data() as Map<String, dynamic>;
        final country = Country.fromJson(countryMap);

        if (_allCountries.isNotEmpty) {
          if (_allCountries.where((savedCountry) => savedCountry.id == country.id).toList().isEmpty) {
            _allCountries.add(country);
          }
        } else {
          _allCountries.add(country);
        }
      });
      return _allCountries;
    } else {
      return [];
    }
  }
}
