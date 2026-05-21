import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class RepairPdfScreen extends StatelessWidget {
  final Map<String, dynamic> repair;
  
  const RepairPdfScreen({super.key, required this.repair});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    
    final cliente = repair['motocicletas']?['clientes'];
    final moto = repair['motocicletas'];
    final fecha = 'Reciente';

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('RAFA MOTOS', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.SizedBox(height: 4),
                    pw.Text('Taller de Motocicletas Especializado', style: pw.TextStyle(fontSize: 14, color: PdfColors.blue400)),
                    pw.SizedBox(height: 4),
                    pw.Text('Carrera 54 #96a-17, Barrio Aranjuez, Medellín, Antioquia', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.Text('Tel: +57 300 123 4567 | Email: info@rafamotos.com', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.Text('NIT: 900.123.456-7', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 16),
                    pw.Divider(color: PdfColors.grey400),
                  ]
                )
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('REPARACIÓN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Número: R-${repair['id_reparacion'].toString().padLeft(3, '0')}'),
                      pw.Text('Fecha de Recepción: $fecha'),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DATOS DEL CLIENTE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(cliente != null ? '${cliente['nombre']} ${cliente['apellido']}' : 'Desconocido'),
                      pw.Text('Teléfono: ${cliente?['telefono'] ?? 'N/A'}'),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Text('DATOS DE LA MOTOCICLETA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Marca: ${moto?['marca'] ?? 'N/A'}'),
                      pw.Text('Modelo: ${moto?['modelo'] ?? 'N/A'}'),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Placa: ${moto?['placa'] ?? 'N/A'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Año: ${moto?['anio'] ?? 'N/A'}'),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Text('DESCRIPCIÓN DEL SERVICIO', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Text('N/A', style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 16),
              pw.Text('OBSERVACIONES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Text(repair['observaciones'] ?? 'Sin observaciones.', style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        title: const Text('Comprobante PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F1113),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: 'RafaMotos_R${repair['id_reparacion']}.pdf',
        previewPageMargin: const EdgeInsets.all(24),
        loadingWidget: const CircularProgressIndicator(color: Color(0xFF2E65F3)),
      ),
    );
  }
}
