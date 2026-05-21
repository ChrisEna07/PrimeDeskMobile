# 🏍️ PrimeDesk Mobile - App Cliente & Administración

**PrimeDesk Mobile** es la versión móvil oficial del ecosistema **PrimeDesk**, diseñada como el complemento directo para la plataforma web principal: [PrimeDesk Web](https://primedesk-frontend.vercel.app/inicio). 

Esta aplicación móvil está desarrollada en **Flutter** y optimizada para ofrecer una experiencia fluida, rápida y con un diseño de interfaz premium oscuro coherente con el sistema web. Permite a los clientes agendar citas para sus motocicletas y realizar seguimiento de sus reparaciones en tiempo real, mientras que los administradores y mecánicos pueden gestionar la agenda del taller.

---

## ✨ Características Principales

* **👥 Control de Accesos por Roles**: Integración estricta de roles mediante Supabase Auth:
  * **Clientes**: Vista simplificada y segura. Únicamente pueden ver su perfil personal, sus propias motocicletas y agendar o cancelar sus citas (con reglas de negocio de mínimo 1 hora de anticipación).
  * **Administradores y Empleados**: Acceso completo para editar citas, gestionar clientes, registrar motocicletas y controlar reparaciones.
* **📅 Agendamiento Inteligente**: Creación dinámica de citas con selección de fecha, hora, mecánico asignado, motocicleta y servicios sugeridos. La confirmación genera automáticamente una orden de reparación en el sistema.
* **🏍️ Mis Motos (Dinámico)**: Listado dinámico filtrado de forma segura que muestra solo los vehículos registrados a nombre del cliente autenticado.
* **💎 Interfaz Premium & Diálogos Animados**: Diálogos personalizados animados con estilo *glassmorphism* (efecto de vidrio esmerilado) en tonos oscuros y acentos naranja (`#FF6B00`), ofreciendo feedback instantáneo en inicios de sesión, cierres de sesión y confirmación de retroceso/salida.
* **📧 Notificaciones por Correo**: Integración indirecta con la API de **Resend** a través del backend para confirmaciones instantáneas de registro y citas.

---

## 🛠️ Stack Tecnológico

* **Core Framework**: [Flutter SDK](https://flutter.dev/) (Dart con null-safety estricto)
* **Backend como Servicio (BaaS)**: [Supabase](https://supabase.com/) (Autenticación, base de datos Postgres y almacenamiento)
* **Gestión de Estado**: Provider & ChangeNotifier
* **Estilos e Iconografía**: Lucide Icons para Flutter
* **Utilidades de Fecha**: Intl (soporte multi-idioma para fechas en español)

---

## 🚀 Instalación y Desarrollo

### Requisitos Previos
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (Versión estable recomendada)
* Android Studio / Xcode para emuladores y construcción de paquetes.

### Paso 1: Clonar y descargar dependencias
```bash
git clone <url-del-repositorio>
cd PrimeDeskMobile
flutter pub get
```

### Paso 2: Configuración del Entorno
Crea un archivo `.env` en la raíz del proyecto con la siguiente estructura:
```env
# URL de la API del Backend (Render/NodeJS)
API_URL=https://tu-backend-render.com

# Credenciales de Supabase
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-de-supabase
```

### Paso 3: Ejecutar en Desarrollo
```bash
flutter run
```

---

## 📦 Construcción de APKs Ligeras (Producción)

Para generar APKs optimizadas y de tamaño reducido (dividiendo el binario según la arquitectura del dispositivo en lugar de compilar un archivo gordo unificado), utiliza el siguiente comando de compilación:

```bash
flutter build apk --split-per-abi
```

Esto generará tres instaladores optimizados independientes en la ruta `build/app/outputs/flutter-apk/`:
1. **`app-arm64-v8a-release.apk`** (~21 MB) — Diseñado para la mayoría de teléfonos modernos (ej: Motorola Razr 60, Samsung Galaxy S series, etc.).
2. **`app-armeabi-v7a-release.apk`** (~19 MB) — Compatible con dispositivos Android de generaciones anteriores de 32 bits.
3. **`app-x86_64-release.apk`** (~22 MB) — Ideal para emuladores e interfaces basadas en procesadores de computadoras.

---

## 🌐 Ecosistema PrimeDesk
* **Plataforma Web Oficial**: [https://primedesk-frontend.vercel.app/inicio](https://primedesk-frontend.vercel.app/inicio)
* **Repositorio Móvil**: Companion App para Android e iOS.
