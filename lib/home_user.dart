import 'package:care_track/dr_details.dart';
import 'package:care_track/our_doctors.dart';
import 'package:care_track/profile.dart';
import 'package:care_track/search.dart' show SearchPage;
import 'package:care_track/user_appo.dart';
import 'package:flutter/material.dart';
import 'models/api_models.dart';

void main() {
  runApp(const HomeUser());
}

class HomeUser extends StatelessWidget {
  const HomeUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Doctor {
  final String name;
  final String specialization;
  final double rating;
  final String distance;
  final int fee;

  const Doctor({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.distance,
    required this.fee,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Doctor> doctors = const [
    Doctor(
      name: 'Dr. Rishi',
      specialization: 'Cardiologist',
      rating: 4.7,
      distance: '800m away',
      fee: 500,
    ),
    Doctor(
      name: 'Dr. Vaamana',
      specialization: 'Dentist',
      rating: 4.7,
      distance: '800m away',
      fee: 600,
    ),
    Doctor(
      name: 'Dr. Nallarasi',
      specialization: 'Cardiologist',
      rating: 4.7,
      distance: '800m away',
      fee: 700,
    ),
    Doctor(
      name: 'Dr. LEE',
      specialization: 'General Physician',
      rating: 4.7,
      distance: '800m away',
      fee: 750,
    ),
  ];

  // Convert local Doctor to DoctorMainView for navigation
  static DoctorMainView _convertToApiDoctor(Doctor doctor) {
    return DoctorMainView(
      id: 0, // Placeholder
      email: 'doctor@example.com', // Placeholder
      fullName: doctor.name,
      phoneNumber: '000-000-0000', // Placeholder
      city: 'Cairo', // Placeholder
      street: '123 Main St', // Placeholder
      doctorSpeciality: doctor.specialization,
      info: 'Experienced doctor', // Placeholder
      patientNumber: 50, // Placeholder
      startTime: LocalTime(hour: 9, minute: 0),
      endTime: LocalTime(hour: 17, minute: 0),
      consultationFee: doctor.fee.toDouble(),
      availableDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      role: 'DOCTOR',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Define the function inside build method to access context
    void _onDoctorTapped(Doctor doctor) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrDetails(doctor: HomePage._convertToApiDoctor(doctor)), // Pass the converted doctor object
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.4,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Search', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Omar Ahmed',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'How is going today?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 140,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/doctor.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Our Doctors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OurDoctors()),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF247CFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onTap: () => _onDoctorTapped(doctor),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFBBDEFB),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserAppo()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.grey, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialization,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(doctor.rating.toString()),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(doctor.distance),
                  const Spacer(),
                  Text(
                    '${doctor.fee} LE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
