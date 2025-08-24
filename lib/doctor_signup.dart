//docsignup
import 'package:care_track/doctor_login.dart';
import 'package:care_track/home_dr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/api_models.dart';

void main() {
  runApp(const DoctorSignup());
}

class DoctorSignup extends StatefulWidget {
  const DoctorSignup({Key? key}) : super(key: key);

  @override
  State<DoctorSignup> createState() => _DoctorSignupState();
}

class _DoctorSignupState extends State<DoctorSignup> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _infoController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _patientNumberController = TextEditingController();

  // Form data
  String? _selectedSpecialty;
  String? _selectedCity;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  List<String> _selectedDays = [];
  bool _loading = false;

  final Map<String, String> _specialtyMap = {
    'Cardiology': 'CARDIOLOGY',
    'Dermatology': 'DERMATOLOGY',
    'Neurology': 'NEUROLOGY',
    'Orthopedics': 'ORTHOPEDICS',
    'Ophthalmology': 'OPHTHALMOLOGY',
    'Otolaryngology': 'OTOLARYNGOLOGY',
  };

  final Map<String, String> _cityMap = {
    'Cairo': 'CAIRO',
    'Giza': 'GIZA',
    'Alexandria': 'ALEXANDRIA',
    'Luxor': 'LUXOR',
    'Aswan': 'ASWAN',
  };

  final List<String> _daysList = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final Map<String, String> _dayMap = {
    'Monday': 'MONDAY',
    'Tuesday': 'TUESDAY',
    'Wednesday': 'WEDNESDAY',
    'Thursday': 'THURSDAY',
    'Friday': 'FRIDAY',
    'Saturday': 'SATURDAY',
    'Sunday': 'SUNDAY',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _infoController.dispose();
    _consultationFeeController.dispose();
    _patientNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSpecialty == null) {
      _showError('Missing Information', 'Please select a specialty');
      return;
    }
    
    if (_selectedCity == null) {
      _showError('Missing Information', 'Please select a city');
      return;
    }
    
    if (_selectedDays.isEmpty) {
      _showError('Missing Information', 'Please select at least one available day');
      return;
    }

    setState(() => _loading = true);

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      final success = await appProvider.registerDoctor(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        city: _selectedCity!,
        street: _streetController.text.trim(),
        doctorSpeciality: _selectedSpecialty!,
        info: _infoController.text.trim(),
        patientNumber: int.parse(_patientNumberController.text),
        startTime: LocalTime(hour: _startTime.hour, minute: _startTime.minute),
        endTime: LocalTime(hour: _endTime.hour, minute: _endTime.minute),
        consultationFee: double.parse(_consultationFeeController.text),
        availableDays: _selectedDays.map((day) => _dayMap[day]!).toList(),
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeDr()),
        );
      } else if (mounted) {
        _showError('Registration failed', 'Unable to create doctor account. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Network error', e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Create Doctor Account',
                        style: TextStyle(
                          color: Color(0xFF0080FF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Progress indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? const Color(0xFF0080FF)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                
                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildBasicInfoPage(),
                      _buildProfessionalInfoPage(),
                      _buildSchedulePage(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _loading ? null : () {
                            if (_currentPage == 2) {
                              _registerDoctor();
                            } else {
                              _nextPage();
                            }
                          },
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_currentPage == 2 ? 'Register' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Full name is required';
              if (value.length < 7) return 'Full name must be at least 7 characters';
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@(gmail|yahoo|hotmail|outlook)\.(com|net|org)$')
                  .hasMatch(value)) {
                return 'Enter a valid email (gmail, yahoo, hotmail, outlook)';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Phone number is required';
              if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
                return 'Enter valid Egyptian phone number (010/011/012/015)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Professional Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedSpecialty,
            decoration: InputDecoration(
              labelText: 'Specialty',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.medical_services),
            ),
            items: _specialtyMap.keys.map((specialty) {
              return DropdownMenuItem(
                value: _specialtyMap[specialty],
                child: Text(specialty),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSpecialty = value;
              });
            },
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_city),
            ),
            items: _cityMap.keys.map((city) {
              return DropdownMenuItem(
                value: _cityMap[city],
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _streetController,
            decoration: InputDecoration(
              labelText: 'Street Address',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Street address is required';
              if (value.length < 5) return 'Street address must be at least 5 characters';
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _infoController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Professional Information',
              hintText: 'Brief description about your practice...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.info_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Professional info is required';
              if (value.length < 25) return 'Info must be at least 25 characters';
              if (value.length > 500) return 'Info must be less than 500 characters';
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _consultationFeeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Consultation Fee (EGP)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Consultation fee is required';
              final fee = double.tryParse(value);
              if (fee == null || fee <= 0) return 'Enter a valid fee amount';
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _patientNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Maximum Patients per Day',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.people),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Patient number is required';
              final num = int.tryParse(value);
              if (num == null || num <= 0) return 'Enter a valid number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Schedule Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Working hours
          const Text('Working Hours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, true),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time', style: TextStyle(fontSize: 12)),
                            Text(_startTime.format(context)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time', style: TextStyle(fontSize: 12)),
                            Text(_endTime.format(context)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Text('Available Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          
          // Days selection
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysList.map((day) {
              final isSelected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
                selectedColor: const Color(0xFF0080FF).withOpacity(0.2),
                checkmarkColor: const Color(0xFF0080FF),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Already have an account?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DoctorLogin()),
              );
            },
            child: const Text(
              'Login here',
              style: TextStyle(color: Color(0xFF0080FF), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
