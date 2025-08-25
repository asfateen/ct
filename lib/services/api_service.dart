import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  String? get authToken => _authToken;
  
  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Authentication endpoints
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Handle both token-only response and full LoginResponse object
      if (data is String) {
        // API returned just a token string
        return LoginResponse(token: data, user: null, doctor: null);
      } else if (data is Map<String, dynamic>) {
        // API returned a full response object
        return LoginResponse.fromJson(data);
      } else {
        throw ApiException('Invalid response format', response.statusCode);
      }
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<LoginResponse> registerPatient(UserRegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/patient'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<LoginResponse> registerDoctor(DoctorRegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/doctor'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<String> logout() async {
    final response = await http.get(
      Uri.parse('$baseUrl/logout'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      clearAuthToken();
      return response.body;
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<String> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-account'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      clearAuthToken();
      return response.body;
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Patient endpoints
  Future<UserMainView> getPatient() async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserMainView.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<UserMainView> updatePatient(Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/patient'),
      headers: _headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserMainView.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<List<DoctorMainView>> searchDoctors(
    DoctorSearchRequest request, {
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/patient/doctors-search').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DoctorMainView.fromJson(json)).toList();
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Doctor endpoints
  Future<DoctorMainView> getDoctor() async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorMainView.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<DoctorMainView> updateDoctor(Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/doctor'),
      headers: _headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorMainView.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Appointment endpoints
  Future<List<AppointmentResponse>> getAppointments({
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/appointments').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppointmentResponse.fromJson(json)).toList();
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<AppointmentResponse> bookAppointment(BookAppointmentRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppointmentResponse.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<AppointmentResponse> modifyAppointment(ModifyAppointmentRequest request) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppointmentResponse.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<String> cancelAppointment(int appointmentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/appointments/$appointmentId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Medical Records endpoints
  Future<MedicalRecord> getMedicalRecord(int recordId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/$recordId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MedicalRecord.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<MedicalRecord> updateMedicalRecord(int recordId, MedicalRecord record) async {
    final response = await http.put(
      Uri.parse('$baseUrl/medical-records/$recordId'),
      headers: _headers,
      body: jsonEncode(record.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MedicalRecord.fromJson(data);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<List<MedicalRecordResponse>> getPatientMedicalRecords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/patient/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicalRecordResponse.fromJson(json)).toList();
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<List<MedicalRecord>> getSharedRecordsForPatient() async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/shared/patient/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<List<MedicalRecordResponse>> getSharedRecordsForDoctor() async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/shared/doctor/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicalRecordResponse.fromJson(json)).toList();
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  Future<void> shareRecordWithDoctor(int recordId, int doctorId) async {
    final uri = Uri.parse('$baseUrl/medical-records/share').replace(
      queryParameters: {
        'recordId': recordId.toString(),
        'doctorId': doctorId.toString(),
      },
    );

    final response = await http.post(uri, headers: _headers);

    if (response.statusCode != 200) {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Doctor availability 
  Future<List<AvailableDate>> getDoctorAvailability(int doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctors/$doctorId/availability'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['available_dates'] != null) {
        final List<dynamic> datesJson = data['available_dates'];
        return datesJson.map((json) => AvailableDate.fromJson(json)).toList();
      }
      return [];
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }

  // Book appointment with flexible data
  Future<Map<String, dynamic>> bookAppointmentWithData(Map<String, dynamic> appointmentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers,
      body: jsonEncode(appointmentData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = ErrorResponse.fromJson(jsonDecode(response.body));
      throw ApiException(error.message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
