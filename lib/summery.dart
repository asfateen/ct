import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appo_datetime.dart';
import 'booking_details.dart';
import 'models/api_models.dart';
import 'providers/app_provider.dart';

class BookAppointmentSummaryPage extends StatefulWidget {
  final DoctorMainView doctor;
  final Map<String, dynamic> appointmentData;
  final DateTime selectedDate;
  final String selectedTime;
  final bool isInPerson;
  final bool isCashPayment;

  const BookAppointmentSummaryPage({
    Key? key,
    required this.doctor,
    required this.appointmentData,
    required this.selectedDate,
    required this.selectedTime,
    required this.isInPerson,
    required this.isCashPayment,
  }) : super(key: key);

  @override
  _BookAppointmentSummaryPageState createState() => _BookAppointmentSummaryPageState();
}

class _BookAppointmentSummaryPageState extends State<BookAppointmentSummaryPage> {
  bool isBooking = false;

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _bookAppointment() async {
    setState(() {
      isBooking = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Book the appointment via API
      final bookingResult = await provider.bookAppointmentWithData(widget.appointmentData);
      
      if (bookingResult != null) {
        // Navigate to booking confirmation with the booking result
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetails(
              booking: Booking(
                id: bookingResult['id'] ?? 0,
                date: _formatDate(widget.selectedDate),
                time: widget.selectedTime,
                appointmentType: widget.isInPerson ? "In Person" : "Virtual",
                doctorName: widget.doctor.name,
                specialization: widget.doctor.specialization,
                rating: widget.doctor.rating,
                distance: "${widget.doctor.distanceInKm}km away",
                price: widget.doctor.pricePerHour.toInt(),
                status: 'confirmed',
              ),
            ),
          ),
        );
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      setState(() {
        isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "Book Appointment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Progress Indicator
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Row(
                children: [
                  // Step 1 - Completed
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Color(0xFF4CAF50),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                  // Step 2 - Active
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "2",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step Labels
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date & Time",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Summary",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),

                      // Doctor Information Section
                      Text(
                        "Doctor Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: widget.doctor.image != null 
                                ? NetworkImage(widget.doctor.image!) 
                                : null,
                              child: widget.doctor.image == null 
                                ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                                : null,
                              backgroundColor: Colors.grey[200],
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.doctor.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.doctor.specialization,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "${widget.doctor.rating}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "${widget.doctor.distanceInKm}km away",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Booking Information Section
                      Text(
                        "Booking Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Date & Time Info
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date & Time",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDate(widget.selectedDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    widget.selectedTime,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.isInPerson ? Icons.person : Icons.video_call,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Appointment Type",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.isInPerson ? "In Person" : "Virtual",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Payment Method Section
                      Text(
                        "Payment Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE8E8E8)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2196F3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    widget.isCashPayment ? Icons.money : Icons.credit_card,
                                    color: Color(0xFF2196F3),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Payment Method",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        widget.isCashPayment ? "Cash" : "Credit Card",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${widget.doctor.pricePerHour} EGP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isBooking ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isBooking
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Booking...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Book Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Summery extends StatelessWidget {
  final DoctorMainView doctor;
  final Map<String, dynamic> appointmentData;
  final DateTime selectedDate;
  final String selectedTime;
  final bool isInPerson;
  final bool isCashPayment;

  const Summery({
    Key? key,
    required this.doctor,
    required this.appointmentData,
    required this.selectedDate,
    required this.selectedTime,
    required this.isInPerson,
    required this.isCashPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Summary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: BookAppointmentSummaryPage(
        doctor: doctor,
        appointmentData: appointmentData,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        isInPerson: isInPerson,
        isCashPayment: isCashPayment,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
