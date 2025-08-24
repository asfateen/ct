import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'summery.dart';
import 'models/api_models.dart';
import 'providers/app_provider.dart';

class BookAppointmentPage extends StatefulWidget {
  final DoctorMainView doctor;
  
  const BookAppointmentPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int selectedDateIndex = -1;
  String? selectedTime;
  String selectedTimeSlot = "";
  bool isInPerson = true;
  bool isCashPayment = true;
  bool isLoading = true;

  List<AvailableDate> availableDates = [];
  List<String> availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorAvailability();
  }

  Future<void> _loadDoctorAvailability() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.getDoctorAvailability(widget.doctor.id);
      
      setState(() {
        availableDates = provider.availableDates;
        isLoading = false;
        
        // Select first available date by default
        if (availableDates.isNotEmpty) {
          selectedDateIndex = 0;
          _loadTimeSlotsForDate(0);
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load availability: $e')),
      );
    }
  }

  void _loadTimeSlotsForDate(int dateIndex) {
    if (dateIndex >= 0 && dateIndex < availableDates.length) {
      setState(() {
        availableTimeSlots = availableDates[dateIndex].timeSlots;
        selectedTime = null;
        selectedTimeSlot = "";
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  void _bookAppointment() async {
    if (selectedDateIndex < 0 || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final selectedDate = availableDates[selectedDateIndex];
      
      final appointmentData = {
        'doctor_id': widget.doctor.id,
        'appointment_date': selectedDate.date.toIso8601String().split('T')[0],
        'appointment_time': selectedTime,
        'appointment_type': isInPerson ? 'in_person' : 'virtual',
        'payment_method': isCashPayment ? 'cash' : 'card',
        'amount': widget.doctor.pricePerHour,
      };

      // Navigate to summary with booking data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Summery(
            doctor: widget.doctor,
            appointmentData: appointmentData,
            selectedDate: selectedDate.date,
            selectedTime: selectedTime!,
            isInPerson: isInPerson,
            isCashPayment: isCashPayment,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing booking: $e')),
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
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Progress Indicator
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Row(
                children: [
                  // Step 1 - Active
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "1",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Color(0xFFE0E0E0),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                  // Step 2 - Inactive
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
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
                  Text(
                    "Date & Time",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Summary",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Info Card
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
                                radius: 25,
                                backgroundImage: widget.doctor.image != null 
                                  ? NetworkImage(widget.doctor.image!) 
                                  : null,
                                child: widget.doctor.image == null 
                                  ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                                  : null,
                                backgroundColor: Colors.grey[200],
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.doctor.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      widget.doctor.specialization,
                                      style: TextStyle(
                                        fontSize: 14,
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
                        ),

                        SizedBox(height: 24),

                        // Select Date Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select Date",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Date Selection
                        if (availableDates.isEmpty)
                          Container(
                            height: 80,
                            child: Center(
                              child: Text(
                                "No available dates",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: availableDates.length,
                              itemBuilder: (context, index) {
                                AvailableDate availableDate = availableDates[index];
                                bool isSelected = index == selectedDateIndex;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDateIndex = index;
                                    });
                                    _loadTimeSlotsForDate(index);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFF2196F3) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Color(0xFF2196F3) : Color(0xFFE0E0E0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatDay(availableDate.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected ? Colors.white : Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _formatDate(availableDate.date),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 32),

                        // Available Time Section
                        Text(
                          "Available time",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Time Slots Grid
                        if (availableTimeSlots.isEmpty && selectedDateIndex >= 0)
                          Container(
                            height: 60,
                            child: Center(
                              child: Text(
                                "No available time slots for selected date",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else if (selectedDateIndex >= 0)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: availableTimeSlots.length,
                            itemBuilder: (context, index) {
                              String time = availableTimeSlots[index];
                              bool isSelected = time == selectedTime;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTime = time;
                                    selectedTimeSlot = time;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? Color(0xFF2196F3) : Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Color(0xFF2196F3) : Color(0xFFE8E8E8),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        SizedBox(height: 32),

                        // Appointment Type Section
                        Text(
                          "Appointment Type",
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
                            border: Border.all(color: Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF2196F3),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "In Person",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCashPayment = !isCashPayment;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isCashPayment ? Color(0xFF2196F3) : Colors.transparent,
                                  border: Border.all(
                                    color: isCashPayment ? Color(0xFF2196F3) : Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isCashPayment
                                    ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                                    : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Cash",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
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
                  onPressed: (selectedDateIndex >= 0 && selectedTime != null) 
                    ? _bookAppointment 
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue",
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

class AppoDatetime extends StatelessWidget {
  final DoctorMainView doctor;

  const AppoDatetime({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: BookAppointmentPage(doctor: doctor),
      debugShowCheckedModeBanner: false,
    );
  }
}
