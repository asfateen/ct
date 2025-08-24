import 'package:care_track/dr_details.dart';
import 'package:care_track/home_user.dart';
import 'package:flutter/material.dart';

// Doctor class to match the structure used in other screens
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String distance;
  final String price;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.price,
  });

  // Add getters to match home page Doctor class
  String get specialization => specialty;
  int get fee => int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 500;
}

void main() {
  runApp(OurDoctors());
}

class OurDoctors extends StatelessWidget {
  OurDoctors({super.key});

  final List<Doctor> doctors = [
    Doctor(
      id: '1',
      name: "Dr. Rishi",
      specialty: "Cardiologist",
      rating: 4.7,
      distance: "800m away",
      price: "500 LE",
    ),
    Doctor(
      id: '2',
      name: "Dr. Vaamana",
      specialty: "Dentist",
      rating: 4.7,
      distance: "800m away",
      price: "600 LE",
    ),
    Doctor(
      id: '3',
      name: "Dr. Nallarasi",
      specialty: "Cardiologist",
      rating: 4.7,
      distance: "800m away",
      price: "700 LE",
    ),
    Doctor(
      id: '4',
      name: "Dr. Nihal",
      specialty: "Cardiologist",
      rating: 4.7,
      distance: "800m away",
      price: "750 LE",
    ),
    Doctor(
      id: '5',
      name: "Dr. Rishita",
      specialty: "Cardiologist",
      rating: 4.7,
      distance: "800m away",
      price: "800 LE",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OurDoctorsScreen(doctors: doctors),
    );
  }
}

class OurDoctorsScreen extends StatelessWidget {
  final List<Doctor> doctors;

  const OurDoctorsScreen({super.key, required this.doctors});

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
      body: ListView.separated(
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
                          doctor.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doctor.specialty,
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
                              doctor.distance,
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
                    doctor.price,
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

  void _onDoctorTapped(BuildContext context, Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }
}