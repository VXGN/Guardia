import 'dart:convert';
import 'package:guardia_app/features/companion/data/models/trusted_contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TrustedContactLocalDataSource {
  Future<List<TrustedContactModel>> getContacts();
  Future<void> saveContacts(List<TrustedContactModel> contacts);
}

class TrustedContactLocalDataSourceImpl implements TrustedContactLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_CONTACTS = 'CACHED_TRUSTED_CONTACTS';

  TrustedContactLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TrustedContactModel>> getContacts() async {
    final jsonString = sharedPreferences.getString(CACHED_CONTACTS);
    if (jsonString != null) {
      final List decodeData = json.decode(jsonString);
      return decodeData
          .map((item) => TrustedContactModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveContacts(List<TrustedContactModel> contacts) async {
    final String jsonString = json.encode(
      contacts.map((contact) => contact.toJson()).toList(),
    );
    await sharedPreferences.setString(CACHED_CONTACTS, jsonString);
  }
}
