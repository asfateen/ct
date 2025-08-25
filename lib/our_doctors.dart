import 'package:care_track/dr_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/api_models.dart';
import 'providers/app_provider.dart';

// This main() function is only for standalone testing
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider()..initializeAuth(),
      child: MaterialApp(
        title: 'Care Track',
        home: OurDoctors(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

// This is the widget that should be used for navigation
class OurDoctors extends StatefulWidget {
  OurDoctors({super.key});

  @override
  State<OurDoctors> createState() => _OurDoctorsState();
}

class _OurDoctorsState extends State<OurDoctors> {
  List<DoctorMainView> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Try multiple searches to get a variety of doctors
      List<DoctorMainView> allDoctors = [];
      
      final cities = ['CAIRO', 'GIZA', 'ALEXANDRIA'];
      final specialties = ['CARDIOLOGY', 'DERMATOLOGY', 'NEUROLOGY', 'ORTHOPEDICS'];
      
      for (final city in cities) {
        for (final specialty in specialties) {
          try {
            final doctors = await provider.searchDoctors(
              city: city,
              speciality: specialty,
              size: 10,
            );
            allDoctors.addAll(doctors);
          } catch (e) {
            // Continue to next search if one fails
            print('Search failed for $city - $specialty: $e');
          }
        }
      }
      
      // Remove duplicates based on doctor ID
      final uniqueDoctors = <int, DoctorMainView>{};
      for (final doctor in allDoctors) {
        uniqueDoctors[doctor.id] = doctor;
      }
      
      setState(() {
        doctors = uniqueDoctors.values.toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OurDoctorsScreen(doctors: doctors, isLoading: isLoading),
    );
  }
}

class OurDoctorsScreen extends StatelessWidget {
  final List<DoctorMainView> doctors;
  final bool isLoading;

  const OurDoctorsScreen({super.key, required this.doctors, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Use Navigator.pop() to go back
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Our Doctors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFDFF1FF),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? const Center(
                  child: Text(
                    'No doctors found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onDoctorTapped(context, doctor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doctor.doctorSpeciality,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 15, color: Colors.blue),
                            SizedBox(width: 3),
                            Text(
                              doctor.rating.toString(),
                              style: TextStyle(color: Colors.blue),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 3),
                            Text(
                              '${doctor.city} - ${doctor.distanceInKm.toStringAsFixed(1)}km',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text(
                    '${doctor.consultationFee.toInt()} LE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onDoctorTapped(BuildContext context, DoctorMainView doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrDetails(doctor: doctor),
      ),
    );
  }
}