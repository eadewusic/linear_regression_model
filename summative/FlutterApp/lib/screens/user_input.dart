import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'analysis.dart';

// Main widget for the Daily Habits screen
class DailyHabitsScreen extends StatefulWidget {
  const DailyHabitsScreen({super.key});

  @override
  State<DailyHabitsScreen> createState() => _DailyHabitsScreenState();
}

class _DailyHabitsScreenState extends State<DailyHabitsScreen> {
  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for input fields
  final _devicesController = TextEditingController();
  final _hoursController = TextEditingController();
  final _groceryController = TextEditingController();
  final _transportController = TextEditingController();
  final _clothesController = TextEditingController();
  final _mealsController = TextEditingController();

  // API URL
  static const String apiUrl = 'https://linear-regression-model-pjjl.onrender.com/predict/';

  @override
  void dispose() {
    // Dispose of controllers to free up resources
    for (var controller in [
      _devicesController,
      _hoursController,
      _groceryController,
      _transportController,
      _clothesController,
      _mealsController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside of the text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Assign form key for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Analyse Your Daily Habits',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Input fields for various habits
                    _buildInputField(
                      'How many electronic devices do you own?',
                      _devicesController,
                      'Number',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'How many hours a day do you spend in front of your device?',
                      _hoursController,
                      'Hours',
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildInputField(
                      'Monthly grocery spending',
                      _groceryController,
                      'Amount in USD',
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildInputField(
                      'Monthly transportation expenditure',
                      _transportController,
                      'Amount in USD',
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildInputField(
                      'How many clothes do you buy monthly?',
                      _clothesController,
                      'Number',
                      TextInputType.number,
                    ),
                    _buildInputField(
                      'Weekly number of meals consumed',
                      _mealsController,
                      'Number',
                      TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    // Submit button for calculating carbon footprint
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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

  // Helper function to build input fields
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8F5F1),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            // Validation for input fields
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value'; // Check for empty input
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number'; // Check for valid number
              }
              return null; // Validation passed
            },
          ),
        ],
      ),
    );
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard

      // Gather input data
      final Map<String, dynamic> inputData = {
        "monthly_grocery_bill": double.parse(_groceryController.text),
        "vehicle_monthly_distance_km": double.parse(_transportController.text),
        "waste_bag_weekly_count": int.parse(_mealsController.text),
        "how_long_tv_pc_daily_hour": double.parse(_hoursController.text),
        "how_many_new_clothes_monthly": int.parse(_clothesController.text),
        "how_long_internet_daily_hour": double.parse(_devicesController.text),
      };

      try {
        // Send POST request to the API
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(inputData),
        );

        // Handle API response
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final predictedEmission = responseData['predicted_carbon_emission'];

          // Navigate to the Carbon Footprint Screen with the prediction
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

  // Helper function to display error dialog
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

// Updated Carbon Footprint Screen
class CarbonFootprintScreen extends StatelessWidget {
  final double prediction;

  const CarbonFootprintScreen({Key? key, required this.prediction})
      : super(key: key);

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
