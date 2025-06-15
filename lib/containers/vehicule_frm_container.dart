import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';

class Vehicule {
  final int id;
  final String nom;
  final String plaque;
  final String statut;

  Vehicule({
    required this.id,
    required this.nom,
    required this.plaque,
    this.statut = 'en_route',
  });

  factory Vehicule.fromMap(Map<String, dynamic> map) {
    return Vehicule(
      id: map['id'] as int,
      nom: map['nom'] as String,
      plaque: map['plaque'] as String,
      statut: map['statut'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'plaque': plaque,
      'statut': statut,
    };
  }

  @override
  String toString() {
    return '$nom - $plaque';
  }
}

class VehiculeFrmContainer extends StatefulWidget {
  final Function(Vehicule)? onVehiculeAdded;

  const VehiculeFrmContainer({super.key, this.onVehiculeAdded});

  @override
  State<VehiculeFrmContainer> createState() => _VehiculeFrmContainerState();
}

class _VehiculeFrmContainerState extends State<VehiculeFrmContainer> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _plaqueController = TextEditingController();
  String _selectedStatut = 'en_route';

  final List<String> _statutOptions = ['en_route', 'arreté', 'hors_zone'];

  @override
  void dispose() {
    _nomController.dispose();
    _plaqueController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vehicule = Vehicule(
        id: 0, // L'ID sera généré automatiquement par la base de données
        nom: _nomController.text,
        plaque: _plaqueController.text,
        statut: _selectedStatut,
      );

      widget.onVehiculeAdded?.call(vehicule);
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Nouveau Véhicule',
      showBackButton: true,
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
                        'Enregistrer un véhicule',
                        style: GoogleFonts.inter(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF023661),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom du véhicule',
                        icon: Icons.directions_car,
                        validator: (value) => value?.isEmpty ?? true ? 'Entrez le nom du véhicule' : null,
                      ),
                      const SizedBox(height: 25),
                      
                      _buildTextField(
                        controller: _plaqueController,
                        label: 'Plaque d\'immatriculation',
                        icon: Icons.confirmation_number,
                        validator: (value) => value?.isEmpty ?? true ? 'Entrez la plaque' : null,
                      ),
                      const SizedBox(height: 25),
                      
                      _buildStatutDropdown(),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
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
      validator: validator,
    );
  }

  Widget _buildStatutDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Statut',
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
        prefixIcon: const Icon(Icons.settings, color: Color(0xFF023661)),
      ),
      value: _selectedStatut,
      items: _statutOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            _formatStatut(value),
            style: GoogleFonts.inter(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatut = value!;
        });
      },
      validator: (value) => value == null ? 'Sélectionnez un statut' : null,
    );
  }

  String _formatStatut(String statut) {
    switch (statut) {
      case 'en_route':
        return 'En route';
      case 'arreté':
        return 'Arrêté';
      case 'hors_zone':
        return 'Hors zone';
      default:
        return statut;
    }
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
          'ENREGISTRER LE VÉHICULE',
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