import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepairFormScreen extends StatefulWidget {
  final Map<String, dynamic>? repairData;
  const RepairFormScreen({super.key, this.repairData});

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  bool _isSaving = false;
  
  List<dynamic> _clientes = [];
  List<dynamic> _motos = [];
  
  int? _selectedClienteId;
  int? _selectedMotoId;
  
  late TextEditingController _observacionesController;

  final Map<String, bool> _servicios = {
    'Cambio de Aceite': false,
    'Lavado Especial': false,
    'Mantenimiento General': false,
    'Sincronizacion': false,
  };

  @override
  void initState() {
    super.initState();
    _observacionesController = TextEditingController(text: widget.repairData?['observaciones']?.toString() ?? '');
    
    // Parse existing servicios if editing (deprecated - no longer stored in DB)
    
    // Si estamos editando, tratamos de auto-seleccionar la moto y su cliente
    if (widget.repairData != null && widget.repairData!['motocicletas'] != null) {
      _selectedMotoId = widget.repairData!['id_motocicleta'];
      _selectedClienteId = widget.repairData!['motocicletas']['id_cliente'];
    }

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final clientesRes = await _supabase.from('clientes').select('id_cliente, nombre, apellido');
      final motosRes = await _supabase.from('motocicletas').select('id_motocicleta, id_cliente, marca, modelo, placa').eq('estado', true);
      
      if (mounted) {
        setState(() {
          _clientes = clientesRes;
          _motos = motosRes;

          // Si entramos a editar, y no sabíamos el cliente, lo sacamos de la moto cargada
          if (_selectedMotoId != null && _selectedClienteId == null) {
             final motoMatch = _motos.where((m) => m['id_motocicleta'] == _selectedMotoId).toList();
             if (motoMatch.isNotEmpty) {
                _selectedClienteId = motoMatch.first['id_cliente'];
             }
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading dropdown data: $e");
    }
  }

  List<dynamic> get _motosFiltradas {
    if (_selectedClienteId == null) return [];
    return _motos.where((m) => m['id_cliente'] == _selectedClienteId).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedMotoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona una motocicleta.'), backgroundColor: Colors.redAccent));
      return;
    }

    final activeServices = _servicios.entries.where((e) => e.value).map((e) => e.key).join(', ');
    if (activeServices.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un servicio solicitado.'), backgroundColor: Colors.redAccent));
       return;
    }

    setState(() => _isSaving = true);
    
    try {
      final data = {
        'id_motocicleta': _selectedMotoId,
        'observaciones': _observacionesController.text,
      };

      if (widget.repairData == null) {
        data['estado'] = 'Pendiente';
        await _supabase.from('reparaciones').insert(data);
      } else {
        await _supabase.from('reparaciones').update(data).eq('id_reparacion', widget.repairData!['id_reparacion']);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1113),
        title: Text(widget.repairData == null ? 'Nueva Reparación' : 'Editar Reparación', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2124),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cliente *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedClienteId,
                            hint: 'Seleccionar cliente',
                            items: _clientes.map((c) => DropdownMenuItem<int>(value: c['id_cliente'], child: Text('${c['nombre']} ${c['apellido']}', style: const TextStyle(color: Colors.white)))).toList(),
                            onChanged: (val) {
                               setState(() {
                                 _selectedClienteId = val;
                                 _selectedMotoId = null; // reset moto when client changes
                               });
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Motocicleta *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedMotoId,
                            hint: 'Seleccionar motocicleta',
                            items: _motosFiltradas.map((m) => DropdownMenuItem<int>(value: m['id_motocicleta'], child: Text('${m['marca']} ${m['modelo']} - ${m['placa']}', style: const TextStyle(color: Colors.white)))).toList(),
                            onChanged: (val) => setState(() => _selectedMotoId = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                const Text('Servicios Solicitados *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _servicios.keys.map((key) {
                    return SizedBox(
                      width: 250,
                      child: CheckboxListTile(
                        value: _servicios[key],
                        onChanged: (val) => setState(() => _servicios[key] = val!),
                        title: Text(key, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        activeColor: const Color(0xFF2E65F3),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                const Text('Observaciones', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Observaciones del cliente sobre el servicio...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF0F1113),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xFF2E65F3))),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                if (widget.repairData != null) ...[
                   // TODO: Implementar "Avances de Reparación" live list if required. 
                   // Current schema integration supports creation, advances might go to Detailed view logically to avoid dirty form state.
                ],

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E65F3), 
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(widget.repairData == null ? 'Crear Reparación' : 'Actualizar Reparación', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required int? value, required String hint, required List<DropdownMenuItem<int>> items, required Function(int?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF0F1113), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white30, fontSize: 14)),
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2124),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
