import 'dart:convert';
import 'dart:io';

import '../../debug/app_logger.dart';
import '../../providers/user/user_model.dart';

class UpdateUserRequest {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final int? age;
  final File? image;
  final int? wilayaId;
  final int? communeId;
  final int? countryId;
  final int? regionId;
  final int? devisionId;
  UpdateUserRequest({
    this.name,
    this.email,
    this.phoneNumber,
    this.image,
    this.age,
    this.wilayaId,
    this.communeId,
    this.countryId,
    this.regionId,
    this.devisionId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (countryId != null) 'country_id': countryId,
      if (regionId != null) 'region_id': regionId,
      if (wilayaId != null || communeId != null) 'wilaya_id': wilayaId,
      if (age != null) 'age': age,
      if (communeId != null) 'commune_id': communeId,
      if (devisionId != null) 'division_id': devisionId,
      '_method': 'PUT',
    };
  }

  // convert the image to strign base64
  String? imageToBase64() {
    // if (image == null) return null;
    final bytes = image!.readAsBytesSync();
    return base64Encode(bytes);
  }

  //if division id is changed
  bool get shouldUpadateData => devisionId != null;

  // method field that check that each field is different from the current user fields and return new object
  UpdateUserRequest checkFields(UserModel user) {
    final fieldsToChange = <String, dynamic>{};
    if (name != null && name != user.name) fieldsToChange['name'] = name;
    if (phoneNumber != null && phoneNumber != user.phoneNumber) {
      fieldsToChange['phone_number'] = phoneNumber;
    }
    
    // Safely check wilaya and commune to avoid null pointer exceptions
    bool wilayaChanged = false;
    if (wilayaId != null) {
      if (user.wilaya == null || user.wilaya!.number != wilayaId) {
        wilayaChanged = true;
      }
    }
    
    bool communeChanged = false;
    if (communeId != null) {
      if (user.commune == null || user.commune!.number != communeId) {
        communeChanged = true;
      }
    }

    if (wilayaChanged || communeChanged) {
      fieldsToChange['wilaya_id'] = wilayaId;
    }
    if (communeChanged) {
      fieldsToChange['commune_id'] = communeId;
    }

    // Check country and region
    bool countryChanged = false;
    if (countryId != null) {
      if (user.country == null || user.country!.id != countryId) {
        countryChanged = true;
      }
    }

    bool regionChanged = false;
    if (regionId != null) {
      if (user.region == null || user.region!.id != regionId) {
        regionChanged = true;
      }
    }

    if (countryChanged) fieldsToChange['country_id'] = countryId;
    if (regionChanged) fieldsToChange['region_id'] = regionId;
    
    if (age != null && age != user.age) fieldsToChange['age'] = age;
    
    // Safely check division
    if (devisionId != null) {
      if (user.division == null || devisionId != user.division!.id) {
        fieldsToChange['division_id'] = devisionId;
      }
    }

    AppLogger.logInfo(
        'Update conditions: name(${name != null && name != user.name}), '
        'phoneNumber(${phoneNumber != null && phoneNumber != user.phoneNumber}), '
        'wilaya/commune($wilayaChanged || $communeChanged), '
        'age(${age != null && age != user.age}), '
        'division(${devisionId != null && (user.division == null || devisionId != user.division!.id)})');

    // Log current and new values
    AppLogger.logInfo(
        'Current values: name=${user.name}, phone=${user.phoneNumber}, '
        'wilaya=${user.wilaya?.number}, commune=${user.commune?.number}, '
        'age=${user.age}, division=${user.division?.id}');

    AppLogger.logInfo('New values: name=$name, phone=$phoneNumber, '
        'wilaya=$wilayaId, commune=$communeId, '
        'age=$age, division=$devisionId');

    AppLogger.logInfo('Fields to change: ${fieldsToChange.toString()}');

    // if (fieldsToChange.isEmpty) return this;
    return UpdateUserRequest(
      name: fieldsToChange['name'],
      phoneNumber: fieldsToChange['phone_number'],
      image: image,
      age: fieldsToChange['age'],
      wilayaId: fieldsToChange['wilaya_id'],
      communeId: fieldsToChange['commune_id'],
      countryId: fieldsToChange['country_id'],
      regionId: fieldsToChange['region_id'],
      devisionId: fieldsToChange['division_id'],
    );
  }

  bool get needSave =>
      name != null ||
      phoneNumber != null ||
      wilayaId != null ||
      image != null ||
      communeId != null ||
      countryId != null ||
      regionId != null ||
      age != null ||
      devisionId != null;

  // UpdateUserRequest copyWith({
  //   String? name,
  //   String? email,
  //   String? phoneNumber,
  //   int? wilayaId,
  //   int? communeId,
  //   int? devisionId,
  // }) {
  //   return UpdateUserRequest(
  //     name: name ?? this.name,
  //     email: email ?? this.email,
  //     phoneNumber: phoneNumber ?? this.phoneNumber,
  //     wilayaId: wilayaId ?? this.wilayaId,
  //     communeId: communeId ?? this.communeId,
  //     devisionId: devisionId ?? this.devisionId,
  //   );
  // }
}
