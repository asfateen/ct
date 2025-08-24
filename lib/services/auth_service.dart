import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _doctorKey = 'doctor_data';
  static const String _userTypeKey = 'user_type';

  static Future<void> saveLoginData(String token, {UserMainView? user, DoctorMainView? doctor}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    if (user != null) {
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setString(_userTypeKey, 'patient');
    }
    
    if (doctor != null) {
      await prefs.setString(_doctorKey, jsonEncode(doctor.toJson()));
      await prefs.setString(_userTypeKey, 'doctor');
    }
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<UserMainView?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserMainView.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<DoctorMainView?> getDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    final doctorJson = prefs.getString(_doctorKey);
    if (doctorJson != null) {
      return DoctorMainView.fromJson(jsonDecode(doctorJson));
    }
    return null;
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_doctorKey);
    await prefs.remove(_userTypeKey);
  }
}

extension UserMainViewExtension on UserMainView {
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'role': role,
  };
}

extension DoctorMainViewExtension on DoctorMainView {
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'city': city,
    'street': street,
    'doctorSpeciality': doctorSpeciality,
    'info': info,
    'patientNumber': patientNumber,
    'startTime': startTime.toJson(),
    'endTime': endTime.toJson(),
    'consultationFee': consultationFee,
    'availableDays': availableDays,
    'role': role,
  };
}
