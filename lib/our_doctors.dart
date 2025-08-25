import 'package:care_track/dr_details.dart';
import 'package:care_track/home_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/api_models.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(OurDoctors());
}

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
      final loadedDoctors = await provider.searchDoctors(
        city: 'CAIRO', 
        speciality: 'CARDIOLOGY',
        size: 20,
      );
      setState(() {
        doctors = loadedDoctors;
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
            // Use Navigator.pop() instead of push to go back properly
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeUser()),
              );
            }
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