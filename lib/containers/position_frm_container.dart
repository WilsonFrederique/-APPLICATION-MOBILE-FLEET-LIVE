import 'package:fleetlive/containers/position_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';

import '../screens/home_screens.dart'; // Importez votre HomeScreen

class PositionFormContainer extends StatefulWidget {
  final Function(Position)? onPositionAdded;

  const PositionFormContainer({super.key, this.onPositionAdded});

  @override
  State<PositionFormContainer> createState() => _PositionFormContainerState();
}

class _PositionFormContainerState extends State<PositionFormContainer> {
  final _formKey = GlobalKey<FormState>();
  final _vehiculeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final List<String> _vehicles = [
    'Camion 1 - ABC-123',
    'Voiture 2 - XYZ-789',
    'Fourgon 3 - DEF-456'
  ];

  @override
  void dispose() {
    _vehiculeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final position = Position(
        vehiculeId: _vehicles.indexOf(_vehiculeController.text) + 1,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        timestamp: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        vehiculeNom: _vehiculeController.text.split(' - ')[0],
        vehiculePlaque: _vehiculeController.text.split(' - ')[1],
      );

      widget.onPositionAdded?.call(position);
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Nouvelle Position',
      showBackButton: true,
      onBackPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enregistrer une position',
                        style: GoogleFonts.inter(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF023661),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      _buildDropdownField(),
                      const SizedBox(height: 25),
                      
                      Column(
                        children: [
                          _buildCoordinateField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            icon: Icons.north,
                          ),
                          const SizedBox(height: 16),
                          _buildCoordinateField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            icon: Icons.east,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      const SizedBox(height: 40),
                      
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Véhicule',
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF023661)),
      ),
      value: _vehiculeController.text.isEmpty ? null : _vehiculeController.text,
      items: _vehicles.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _vehiculeController.text = value!;
        });
      },
      validator: (value) => value == null ? 'Sélectionnez un véhicule' : null,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF023661)),
    );
  }

  Widget _buildCoordinateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: const Color(0xFF023661)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Entrez une $label';
        }
        if (double.tryParse(value) == null) {
          return 'Valeur numérique requise';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF023661),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'ENREGISTRER LA POSITION',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}