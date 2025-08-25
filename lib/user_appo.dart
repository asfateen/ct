import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/api_models.dart';

// This main() function is only for standalone testing
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider()..initializeAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Care Track',
        home: UserAppo(),
      ),
    ),
  );
}

// This is the widget that should be used for navigation
class UserAppo extends StatefulWidget {
  UserAppo({super.key});

  @override
  State<UserAppo> createState() => _UserAppoState();
}

class _UserAppoState extends State<UserAppo> {
  List<AppointmentResponse> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final loadedAppointments = await provider.getAppointments();
      setState(() {
        appointments = loadedAppointments;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'My Appointment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : appointments.isEmpty
                ? Center(
                    child: Text(
                      'No appointments found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appointment.doctorName ?? "Doctor",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              appointment.doctorSpecialization ?? "Specialist",
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Scheduled", // AppointmentResponse doesn't have status field, so using default
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date: ${_formatDate(appointment.date)}",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${appointment.doctorConsultationFee.toInt()} LE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _cancelAppointment(appointment.id),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDFEFFF),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _rescheduleAppointment(appointment),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Text(
                                    "Reschedule", 
                                    style: TextStyle(fontSize: 13, color: Colors.white)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      return "${dayNames[date.weekday - 1]}, ${date.day} ${months[date.month]} ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final success = await provider.cancelAppointment(appointmentId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment cancelled successfully')),
        );
        _loadAppointments(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment')),
        );
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling appointment')),
      );
    }
  }

  void _rescheduleAppointment(AppointmentResponse appointment) {
    // For now, show a simple dialog - in a real app you'd navigate to a rescheduling screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule Appointment'),
        content: Text('Rescheduling functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
