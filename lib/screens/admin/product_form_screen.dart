import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _marcaController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  List<dynamic> _categorias = [];
  int? _selectedCategoria;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    try {
      final response = await _supabase.from('categorias_productos').select();
      setState(() => _categorias = response);
    } catch (e) {
      if (mounted) setState(() => _categorias = []);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _supabase.from('productos').insert({
        'nombre': _nombreController.text,
        'marca': _marcaController.text,
        'id_categoria': _selectedCategoria,
        'descripcion': _descripcionController.text,
        'estado': true,
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto registrado con éxito.')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: const Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldTitle('Nombre del Producto *'),
              _buildTextField(_nombreController, 'Ej: Aceite 10W40', LucideIcons.package),
              
              const SizedBox(height: 24),
              _buildFieldTitle('Marca *'),
              _buildTextField(_marcaController, 'Ej: Motul, Yamaha...', LucideIcons.tag),
              
              const SizedBox(height: 24),
              _buildFieldTitle('Categoría'),
              _buildDropdown(),
              
              const SizedBox(height: 24),
              _buildFieldTitle('Cantidad en Stock *'),
              _buildTextField(_cantidadController, '0', LucideIcons.hash, keyboardType: TextInputType.number),
              
              const SizedBox(height: 24),
              _buildFieldTitle('Descripción'),
              _buildTextField(_descripcionController, 'Opcional...', LucideIcons.alignLeft, maxLines: 3),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF6B00), size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white10),
        filled: true,
        fillColor: const Color(0xFF1E2124),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E2124), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoria,
          dropdownColor: const Color(0xFF1E2124),
          hint: Text(_categorias.isEmpty ? 'Cargando o sin categorías...' : 'Seleccionar...', style: const TextStyle(color: Colors.white10)),
          isExpanded: true,
          items: _categorias.map((c) {
            // Manejar posibles nombres de columnas ID
            final id = c['id_categoria'] ?? c['id'];
            return DropdownMenuItem<int>(value: id as int?, child: Text(c['nombre'] ?? 'Sin nombre'));
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategoria = val),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
