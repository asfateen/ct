import 'package:care_track/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'models/api_models.dart';
import 'providers/app_provider.dart';

class MedicalRecord {
  final DateTime date;
  final String title;
  final String? doctorName;
  final BloodAnalysis? bloodAnalysis;

  MedicalRecord({
    required this.date,
    required this.title,
    this.doctorName,
    this.bloodAnalysis,
  });
}

class BloodAnalysis {
  final double redBloodCells;
  final int hemoglobin;
  final double hematocrit;
  final double whiteBloodCells;

  BloodAnalysis({
    required this.redBloodCells,
    required this.hemoglobin,
    required this.hematocrit,
    required this.whiteBloodCells,
  });
}

class MedicalRecordCubit extends Cubit<List<MedicalRecord>> {
  final AppProvider appProvider;
  MedicalRecordCubit(this.appProvider) : super(const []);

  Future<void> loadRecords() async {
    try {
      final apiRecords = await appProvider.getPatientMedicalRecords();
      
      // Convert API MedicalRecordResponse to UI MedicalRecord objects
      final uiRecords = apiRecords.map((apiRecord) => _convertToUIMedicalRecord(apiRecord)).toList();
      
      emit(uiRecords);
    } catch (e) {
      print('Error loading medical records: $e');
      emit([]);
    }
  }

  // Convert API MedicalRecordResponse to UI MedicalRecord
  MedicalRecord _convertToUIMedicalRecord(MedicalRecordResponse apiRecord) {
    try {
      final date = DateTime.parse(apiRecord.date);
      
      // Extract content and determine if it contains blood analysis data
      final content = apiRecord.content.toLowerCase();
      BloodAnalysis? bloodAnalysis;
      
      // Simple parsing for blood analysis data from content
      if (content.contains('blood') && content.contains('analysis')) {
        // For now, use some sample values - in a real app you'd parse the content properly
        bloodAnalysis = BloodAnalysis(
          redBloodCells: 4.1,
          hemoglobin: 142,
          hematocrit: 33.6,
          whiteBloodCells: 3.850,
        );
      }
      
      return MedicalRecord(
        date: date,
        title: apiRecord.content.length > 50 
          ? apiRecord.content.substring(0, 50) + '...'
          : apiRecord.content,
        doctorName: apiRecord.doctorName,
        bloodAnalysis: bloodAnalysis,
      );
    } catch (e) {
      // Fallback if date parsing fails
      return MedicalRecord(
        date: DateTime.now(),
        title: apiRecord.content,
        doctorName: apiRecord.doctorName,
      );
    }
  }
}

class MedicalRecordPage extends StatelessWidget {
  final Widget? previousPage;

  const MedicalRecordPage({super.key, this.previousPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Medical Record", textAlign: TextAlign.center),
      ),
      body: BlocBuilder<MedicalRecordCubit, List<MedicalRecord>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final grouped = <String, List<MedicalRecord>>{};
          for (var record in records) {
            final key =
                "${record.date.year}-${record.date.month.toString().padLeft(2, '0')}";
            grouped.putIfAbsent(key, () => []).add(record);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children:
            grouped.entries.map((entry) {
              final monthName = _monthName(entry.value.first.date.month);
              final year = entry.value.first.date.year;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$monthName $year",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map(
                        (record) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (record.doctorName != null)
                              Text("Doctor: ${record.doctorName}"),
                            if (record.bloodAnalysis != null) ...[
                              Text(
                                "Red blood cells: ${record.bloodAnalysis!.redBloodCells} million/mcL",
                              ),
                              Text(
                                "Hemoglobin: ${record.bloodAnalysis!.hemoglobin} g/L",
                              ),
                              Text(
                                "Hematocrit: ${record.bloodAnalysis!.hematocrit}%",
                              ),
                              Text(
                                "White blood cells: ${record.bloodAnalysis!.whiteBloodCells} cells/mcL",
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month];
  }
}

void main() {
  runApp(const MedicalRecordApp());
}

class MedicalRecordApp extends StatelessWidget {
  const MedicalRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return BlocProvider(
            create: (_) => MedicalRecordCubit(appProvider)..loadRecords(),
            child: const MedicalRecordPage(),
          );
        },
      ),
    );
  }
}