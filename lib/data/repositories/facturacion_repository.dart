import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/transaccion_model.dart';

class FacturacionRepository {
  final _supabase = Supabase.instance.client;

  // Registrar una compra de repuestos
  Future<void> registrarCompra(Compra compra) async {
    await _supabase.from('compras').insert(compra.toMap());
  }

  // Generar la venta final y cerrar la reparación
  Future<void> finalizarVenta(Venta venta) async {
    try {
      // 1. Insertar la venta
      await _supabase.from('ventas').insert(venta.toMap());

      // 2. Actualizar el estado de la reparación a 'Finalizado'
      await _supabase
          .from('reparaciones')
          .update({'estado': 'Finalizado'})
          .eq('id_reparacion', venta.idReparacion);
    } catch (e) {
      throw Exception("Error en la transacción de venta: $e");
    }
  }
}
