import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserMainView? _currentUser;
  DoctorMainView? _currentDoctor;
  String? _userType;
  bool _isLoading = false;
  
  UserMainView? get currentUser => _currentUser;
  DoctorMainView? get currentDoctor => _currentDoctor;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null || _currentDoctor != null;
  ApiService get apiService => _apiService;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final token = await AuthService.getAuthToken();
      final userType = await AuthService.getUserType();
      
      if (token != null) {
        _apiService.setAuthToken(token);
        _userType = userType;
        
        if (userType == 'patient') {
          _currentUser = await AuthService.getUser();
        } else if (userType == 'doctor') {
          _currentDoctor = await AuthService.getDoctor();
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      _apiService.setAuthToken(response.token);
      
      if (response.user != null) {
        _currentUser = response.user;
        _userType = 'patient';
        await AuthService.saveLoginData(response.token, user: response.user);
      } else if (response.doctor != null) {
        _currentDoctor = response.doctor;
        _userType = 'doctor';
        await AuthService.saveLoginData(response.token, doctor: response.doctor);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final request = UserRegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      
      final response = await _apiService.registerPatient(request);
      
      _apiService.setAuthToken(response.token);
      _currentUser = response.user;
      _userType = 'patient';
      
      await AuthService.saveLoginData(response.token, user: response.user);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Register patient error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String city,
    required String street,
    required String doctorSpeciality,
    required String info,
    required int patientNumber,
    required LocalTime startTime,
    required LocalTime endTime,
    required double consultationFee,
    required List<String> availableDays,
  }) async {
    _setLoading(true);
    try {
      final request = DoctorRegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        city: city,
        street: street,
        doctorSpeciality: doctorSpeciality,
        info: info,
        patientNumber: patientNumber,
        startTime: startTime,
        endTime: endTime,
        consultationFee: consultationFee,
        availableDays: availableDays,
      );
      
      final response = await _apiService.registerDoctor(request);
      
      _apiService.setAuthToken(response.token);
      _currentDoctor = response.doctor;
      _userType = 'doctor';
      
      await AuthService.saveLoginData(response.token, doctor: response.doctor);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Register doctor error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiService.logout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await AuthService.logout();
      _apiService.clearAuthToken();
      _currentUser = null;
      _currentDoctor = null;
      _userType = null;
      _setLoading(false);
    }
  }

  Future<List<DoctorMainView>> searchDoctors({
    required String city,
    required String speciality,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final request = DoctorSearchRequest(
        city: city,
        doctorSpeciality: speciality,
      );
      return await _apiService.searchDoctors(request, page: page, size: size);
    } catch (e) {
      print('Search doctors error: $e');
      return [];
    }
  }

  Future<List<AppointmentResponse>> getAppointments({
    int page = 0,
    int size = 10,
  }) async {
    try {
      return await _apiService.getAppointments(page: page, size: size);
    } catch (e) {
      print('Get appointments error: $e');
      return [];
    }
  }

  Future<bool> bookAppointment({
    required String date,
    required int doctorId,
  }) async {
    try {
      final request = BookAppointmentRequest(date: date, doctorId: doctorId);
      await _apiService.bookAppointment(request);
      return true;
    } catch (e) {
      print('Book appointment error: $e');
      return false;
    }
  }

  Future<bool> modifyAppointment({
    required int appointmentId,
    required String date,
  }) async {
    try {
      final request = ModifyAppointmentRequest(id: appointmentId, date: date);
      await _apiService.modifyAppointment(request);
      return true;
    } catch (e) {
      print('Modify appointment error: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      await _apiService.cancelAppointment(appointmentId);
      return true;
    } catch (e) {
      print('Cancel appointment error: $e');
      return false;
    }
  }

  Future<List<MedicalRecordResponse>> getPatientMedicalRecords() async {
    try {
      return await _apiService.getPatientMedicalRecords();
    } catch (e) {
      print('Get patient medical records error: $e');
      return [];
    }
  }

  Future<List<MedicalRecordResponse>> getSharedRecordsForDoctor() async {
    try {
      return await _apiService.getSharedRecordsForDoctor();
    } catch (e) {
      print('Get shared records for doctor error: $e');
      return [];
    }
  }

  Future<bool> shareRecordWithDoctor(int recordId, int doctorId) async {
    try {
      await _apiService.shareRecordWithDoctor(recordId, doctorId);
      return true;
    } catch (e) {
      print('Share record error: $e');
      return false;
    }
  }

  // Doctor availability
  List<AvailableDate> _availableDates = [];
  List<AvailableDate> get availableDates => _availableDates;

  Future<void> getDoctorAvailability(int doctorId) async {
    _setLoading(true);
    try {
      final response = await _apiService.getDoctorAvailability(doctorId);
      _availableDates = response;
      notifyListeners();
    } catch (e) {
      print('Get doctor availability error: $e');
      _availableDates = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Book appointment with flexible data
  Future<Map<String, dynamic>?> bookAppointmentWithData(Map<String, dynamic> appointmentData) async {
    _setLoading(true);
    try {
      final response = await _apiService.bookAppointmentWithData(appointmentData);
      notifyListeners();
      return response;
    } catch (e) {
      print('Book appointment error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
