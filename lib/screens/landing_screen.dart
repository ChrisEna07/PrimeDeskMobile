import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: Stack(
        children: [
          // Background Image with Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1742294740060-1b169f3c0807?q=80&w=1172&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.4)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Icon(LucideIcons.bike, color: Color(0xFFFF6B00), size: 30),
                      SizedBox(width: 10),
                      Text('RafaMotos', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
                    ],
                  ),
                  const Spacer(),
                  const Text('Taller Especializado en', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const Text('Motocicletas', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 20),
                  const Text(
                    'Servicio profesional, diagnóstico preciso y repuestos originales para tu pasión sobre dos ruedas.',
                    style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navegar a registro (placeholder)
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CREAR CUENTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
