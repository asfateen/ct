class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class LoginResponse {
  final String token;
  final UserMainView? user;
  final DoctorMainView? doctor;

  LoginResponse({required this.token, this.user, this.doctor});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: json['user'] != null ? UserMainView.fromJson(json['user']) : null,
      doctor: json['user'] != null ? DoctorMainView.fromJson(json['user']) : null,
    );
  }
}

class UserRegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;

  UserRegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      };
}

class DoctorRegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String city;
  final String street;
  final String doctorSpeciality;
  final String info;
  final int patientNumber;
  final LocalTime startTime;
  final LocalTime endTime;
  final double consultationFee;
  final List<String> availableDays;

  DoctorRegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.city,
    required this.street,
    required this.doctorSpeciality,
    required this.info,
    required this.patientNumber,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    required this.availableDays,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
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
      };
}

class UserMainView {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;

  UserMainView({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  factory UserMainView.fromJson(Map<String, dynamic> json) {
    return UserMainView(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }
}

class DoctorMainView {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String city;
  final String street;
  final String doctorSpeciality;
  final String info;
  final int patientNumber;
  final LocalTime startTime;
  final LocalTime endTime;
  final double consultationFee;
  final List<String> availableDays;
  final String role;

  DoctorMainView({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.city,
    required this.street,
    required this.doctorSpeciality,
    required this.info,
    required this.patientNumber,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    required this.availableDays,
    required this.role,
  });

  factory DoctorMainView.fromJson(Map<String, dynamic> json) {
    return DoctorMainView(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      city: json['city'],
      street: json['street'],
      doctorSpeciality: json['doctorSpeciality'],
      info: json['info'],
      patientNumber: json['patientNumber'],
      startTime: LocalTime.fromJson(json['startTime']),
      endTime: LocalTime.fromJson(json['endTime']),
      consultationFee: json['consultationFee'].toDouble(),
      availableDays: List<String>.from(json['availableDays']),
      role: json['role'],
    );
  }
}

class LocalTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  LocalTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  factory LocalTime.fromJson(Map<String, dynamic> json) {
    return LocalTime(
      hour: json['hour'],
      minute: json['minute'],
      second: json['second'] ?? 0,
      nano: json['nano'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
        'second': second,
        'nano': nano,
      };

  @override
  String toString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class DoctorSearchRequest {
  final String city;
  final String doctorSpeciality;

  DoctorSearchRequest({
    required this.city,
    required this.doctorSpeciality,
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'doctorSpeciality': doctorSpeciality,
      };
}

class BookAppointmentRequest {
  final String date;
  final int doctorId;

  BookAppointmentRequest({
    required this.date,
    required this.doctorId,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'doctorId': doctorId,
      };
}

class ModifyAppointmentRequest {
  final String date;
  final int id;

  ModifyAppointmentRequest({
    required this.date,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'id': id,
      };
}

class AppointmentResponse {
  final int id;
  final String date;
  final int patientId;
  final String patientName;
  final int doctorId;
  final String doctorName;
  final String doctorCity;
  final String doctorStreet;
  final String doctorSpecialization;
  final LocalTime doctorStartTime;
  final LocalTime doctorEndTime;
  final double doctorConsultationFee;

  AppointmentResponse({
    required this.id,
    required this.date,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorCity,
    required this.doctorStreet,
    required this.doctorSpecialization,
    required this.doctorStartTime,
    required this.doctorEndTime,
    required this.doctorConsultationFee,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      id: json['id'],
      date: json['date'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      doctorCity: json['doctorCity'],
      doctorStreet: json['doctorStreet'],
      doctorSpecialization: json['doctorSpecialization'],
      doctorStartTime: LocalTime.fromJson(json['doctorStartTime']),
      doctorEndTime: LocalTime.fromJson(json['doctorEndTime']),
      doctorConsultationFee: json['doctorConsultationFee'].toDouble(),
    );
  }
}

class MedicalRecord {
  final int? id;
  final String content;
  final String date;

  MedicalRecord({
    this.id,
    required this.content,
    required this.date,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      content: json['content'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'content': content,
        'date': date,
      };
}

class MedicalRecordResponse {
  final int id;
  final String content;
  final String date;
  final int? doctorId;
  final String? doctorName;
  final int? patientId;
  final String? patientName;

  MedicalRecordResponse({
    required this.id,
    required this.content,
    required this.date,
    this.doctorId,
    this.doctorName,
    this.patientId,
    this.patientName,
  });

  factory MedicalRecordResponse.fromJson(Map<String, dynamic> json) {
    return MedicalRecordResponse(
      id: json['id'],
      content: json['content'],
      date: json['date'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      patientId: json['patientId'],
      patientName: json['patientName'],
    );
  }
}

class ErrorResponse {
  final String message;
  final int status;

  ErrorResponse({required this.message, required this.status});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'],
      status: json['status'],
    );
  }
}

// Enums
class City {
  static const String cairo = 'CAIRO';
  static const String giza = 'GIZA';
  static const String alexandria = 'ALEXANDRIA';
  static const String luxor = 'LUXOR';
  static const String aswan = 'ASWAN';
  static const String portSaid = 'PORT_SAID';
  static const String suez = 'SUEZ';
  static const String ismailia = 'ISMAILIA';
  static const String faiyum = 'FAIYUM';
  static const String damietta = 'DAMIETTA';
  static const String asyut = 'ASYUT';
  static const String minya = 'MINYA';
  static const String beniSuef = 'BENI_SUEF';
  static const String sharqia = 'SHARQIA';
  static const String dakahliya = 'DAKAHLIYA';
  static const String gharbia = 'GHARBIA';
  static const String monufia = 'MONUFIA';
  static const String kafrElSheikh = 'KAFR_EL_SHEIKH';
  static const String beheira = 'BEHEIRA';
  static const String qena = 'QENA';
  static const String sohag = 'SOHAG';
  static const String redSea = 'RED_SEA';
  static const String matrouh = 'MATROUH';
  static const String newValley = 'NEW_VALLEY';
  static const String northSinai = 'NORTH_SINAI';
  static const String southSinai = 'SOUTH_SINAI';

  static List<String> get all => [
        cairo, giza, alexandria, luxor, aswan, portSaid, suez, ismailia,
        faiyum, damietta, asyut, minya, beniSuef, sharqia, dakahliya,
        gharbia, monufia, kafrElSheikh, beheira, qena, sohag, redSea,
        matrouh, newValley, northSinai, southSinai
      ];
}

class DoctorSpeciality {
  static const String cardiology = 'CARDIOLOGY';
  static const String dermatology = 'DERMATOLOGY';
  static const String neurology = 'NEUROLOGY';
  static const String orthopedics = 'ORTHOPEDICS';
  static const String ophthalmology = 'OPHTHALMOLOGY';
  static const String otolaryngology = 'OTOLARYNGOLOGY';

  static List<String> get all => [
        cardiology, dermatology, neurology, orthopedics, ophthalmology, otolaryngology
      ];
}

class DayOfWeek {
  static const String monday = 'MONDAY';
  static const String tuesday = 'TUESDAY';
  static const String wednesday = 'WEDNESDAY';
  static const String thursday = 'THURSDAY';
  static const String friday = 'FRIDAY';
  static const String saturday = 'SATURDAY';
  static const String sunday = 'SUNDAY';

  static List<String> get all => [
        monday, tuesday, wednesday, thursday, friday, saturday, sunday
      ];
}

// Available date for doctor appointments
class AvailableDate {
  final DateTime date;
  final List<String> timeSlots;

  AvailableDate({
    required this.date,
    required this.timeSlots,
  });

  factory AvailableDate.fromJson(Map<String, dynamic> json) {
    return AvailableDate(
      date: DateTime.parse(json['date']),
      timeSlots: List<String>.from(json['time_slots'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'time_slots': timeSlots,
    };
  }
}

// SearchDoctorsRequest for the search functionality
class SearchDoctorsRequest {
  final String? name;
  final String? specialization;
  final String? governorate;
  final double? minRating;
  final double? maxPricePerHour;
  final int page;

  SearchDoctorsRequest({
    this.name,
    this.specialization,
    this.governorate,
    this.minRating,
    this.maxPricePerHour,
    this.page = 1,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null && name!.isNotEmpty) data['name'] = name;
    if (specialization != null && specialization!.isNotEmpty) data['specialization'] = specialization;
    if (governorate != null && governorate!.isNotEmpty) data['governorate'] = governorate;
    if (minRating != null) data['min_rating'] = minRating;
    if (maxPricePerHour != null) data['max_price_per_hour'] = maxPricePerHour;
    data['page'] = page;
    
    return data;
  }
}
