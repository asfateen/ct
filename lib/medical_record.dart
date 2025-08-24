import 'package:care_track/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class FakeMedicalRecordRepository {
  Future<List<MedicalRecord>> getMedicalRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MedicalRecord(
        date: DateTime(2025, 2, 25),
        title: "Doctor name",
        doctorName: "Dr. John Doe",
      ),
      MedicalRecord(
        date: DateTime(2025, 2, 25),
        title: "Blood",
        bloodAnalysis: BloodAnalysis(
          redBloodCells: 4.10,
          hemoglobin: 142,
          hematocrit: 33.6,
          whiteBloodCells: 3.850,
        ),
      ),
      MedicalRecord(
        date: DateTime(2025, 2, 25),
        title: "Blood Analysis",
        bloodAnalysis: BloodAnalysis(
          redBloodCells: 3.90,
          hemoglobin: 122,
          hematocrit: 47.7,
          whiteBloodCells: 4.300,
        ),
      ),

      MedicalRecord(date: DateTime(2025, 1, 25), title: "End of observation"),
      MedicalRecord(
        date: DateTime(2025, 1, 25),
        title: "Blood Analysis",
        bloodAnalysis: BloodAnalysis(
          redBloodCells: 4.30,
          hemoglobin: 132,
          hematocrit: 37.7,
          whiteBloodCells: 4.700,
        ),
      ),
      MedicalRecord(
        date: DateTime(2025, 1, 25),
        title: "Blood Analysis",
        bloodAnalysis: BloodAnalysis(
          redBloodCells: 3.90,
          hemoglobin: 118,
          hematocrit: 38.7,
          whiteBloodCells: 4.500,
        ),
      ),
    ];
  }
}

class MedicalRecordCubit extends Cubit<List<MedicalRecord>> {
  final FakeMedicalRecordRepository repository;
  MedicalRecordCubit(this.repository) : super(const []);

  Future<void> loadRecords() async {
    final records = await repository.getMedicalRecords();
    emit(records);
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
      home: BlocProvider(
        create:
            (_) =>
        MedicalRecordCubit(FakeMedicalRecordRepository())
          ..loadRecords(),
        child: const MedicalRecordPage(),
      ),
    );
  }
}