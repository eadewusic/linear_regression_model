import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding

class DailyHabitsScreen extends StatefulWidget {
  const DailyHabitsScreen({super.key});

  @override
  State<DailyHabitsScreen> createState() => _DailyHabitsScreenState();
}

class _DailyHabitsScreenState extends State<DailyHabitsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _monthlyGroceryController = TextEditingController();
  final _vehicleDistanceController = TextEditingController();
  final _wasteBagCountController = TextEditingController();
  final _tvPcHoursController = TextEditingController();
  final _clothesMonthlyController = TextEditingController();
  final _internetHoursController = TextEditingController();

  static const String apiUrl =
      'https://linear-regression-model-pjjl.onrender.com/predict/';

  @override
  void dispose() {
    for (var controller in [
      _monthlyGroceryController,
      _vehicleDistanceController,
      _wasteBagCountController,
      _tvPcHoursController,
      _clothesMonthlyController,
      _internetHoursController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Analyse Your Carbon Footprint',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Input fields based on Swagger UI
                    _buildInputField(
                      'Monthly grocery bill',
                      _monthlyGroceryController,
                      'Amount in USD',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'Vehicle monthly distance (km)',
                      _vehicleDistanceController,
                      'Distance in kilometers',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'Waste bag weekly count',
                      _wasteBagCountController,
                      'Number of bags',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'Daily hours using TV/PC',
                      _tvPcHoursController,
                      'Hours',
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildInputField(
                      'New clothes bought monthly',
                      _clothesMonthlyController,
                      'Number',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'Daily hours using the internet',
                      _internetHoursController,
                      'Hours',
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D37F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Calculate Carbon Footprint',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8F5F1),
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final Map<String, dynamic> inputData = {
        "monthly_grocery_bill": double.parse(_monthlyGroceryController.text),
        "vehicle_monthly_distance_km":
            double.parse(_vehicleDistanceController.text),
        "waste_bag_weekly_count": int.parse(_wasteBagCountController.text),
        "how_long_tv_pc_daily_hour": double.parse(_tvPcHoursController.text),
        "how_many_new_clothes_monthly":
            int.parse(_clothesMonthlyController.text),
        "how_long_internet_daily_hour":
            double.parse(_internetHoursController.text),
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(inputData),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final predictedEmission = responseData['predicted_carbon_emission'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CarbonFootprintScreen(prediction: predictedEmission),
            ),
          );
        } else {
          _showErrorDialog('Failed to get prediction. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class CarbonFootprintScreen extends StatelessWidget {
  final double prediction;

  const CarbonFootprintScreen({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carbon Footprint Result')),
      body: Center(
        child: Text(
          'Your estimated carbon footprint is $prediction',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
