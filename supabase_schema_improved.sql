-- =====================================================
--  PrimeDeskDB — REFINED PostgreSQL / Supabase
-- =====================================================

/* 
   CAMBIOS REALIZADOS:
   1. Vinculación con "auth.users" de Supabase.
   2. Adición de tabla "Reparaciones_Productos" (Repuestos usados).
   3. Adición de tabla "Inventario_Historial" para trazabilidad.
   4. Enums para estados consistentes.
   5. RLS (Row Level Security) inicial sugerido.
*/

CREATE SCHEMA IF NOT EXISTS public;

-- 1. Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Roles
CREATE TABLE Roles (
    ID_Rol     SERIAL PRIMARY KEY,
    Nombre     VARCHAR(50)  NOT NULL UNIQUE,
    Descripcion TEXT        NULL,
    Estado     BOOLEAN      NOT NULL DEFAULT TRUE
);

INSERT INTO Roles (Nombre, Descripcion) VALUES 
('Admin', 'Acceso total al sistema'),
('Mecanico', 'Gestión de reparaciones y servicios'),
('Cliente', 'Consulta de sus propias motos y reparaciones');

-- 3. Perfiles vinculados a Supabase Auth
CREATE TABLE Perfiles (
    ID          UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    ID_Rol      INT NOT NULL REFERENCES Roles(ID_Rol),
    Nombre      VARCHAR(100) NOT NULL,
    Apellido    VARCHAR(100) NOT NULL,
    Documento   VARCHAR(20) UNIQUE,
    Telefono    VARCHAR(10),
    Direccion   TEXT,
    Foto_Url    TEXT,
    Estado      BOOLEAN DEFAULT TRUE,
    Creado_En   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Categorías y Productos
CREATE TABLE Categorias_Productos (
    ID_Categoria SERIAL PRIMARY KEY,
    Nombre       VARCHAR(30) NOT NULL UNIQUE,
    Descripcion  TEXT        NULL,
    Estado       BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE Productos (
    ID_Producto  SERIAL PRIMARY KEY,
    ID_Categoria INT         NOT NULL REFERENCES Categorias_Productos(ID_Categoria),
    Nombre       VARCHAR(60) NOT NULL,
    Marca        VARCHAR(40) NOT NULL,
    Precio_Venta NUMERIC(10,2) NOT NULL DEFAULT 0,
    Stock        INT         NOT NULL DEFAULT 0,
    Stock_Minimo INT         NOT NULL DEFAULT 5,
    Descripcion  TEXT        NULL,
    Estado       BOOLEAN     NOT NULL DEFAULT TRUE
);

-- 5. Motocicletas
CREATE TABLE Motocicletas (
    ID_Motocicleta SERIAL PRIMARY KEY,
    ID_Cliente     UUID        NOT NULL REFERENCES Perfiles(ID),
    Marca          VARCHAR(50) NOT NULL,
    Modelo         VARCHAR(50) NOT NULL,
    Anio           INT         NOT NULL,
    Placa          VARCHAR(10) NOT NULL UNIQUE,
    Color          VARCHAR(20) NOT NULL,
    Motor          VARCHAR(50) NOT NULL,
    Kilometraje    INT         NOT NULL DEFAULT 0,
    Estado         BOOLEAN     NOT NULL DEFAULT TRUE
);

-- 6. Servicios
CREATE TABLE Servicios (
    ID_Servicio  SERIAL PRIMARY KEY,
    Nombre       VARCHAR(100) NOT NULL UNIQUE,
    Precio       NUMERIC(10,2) NOT NULL DEFAULT 0,
    Descripcion  TEXT         NULL,
    Estado       BOOLEAN      NOT NULL DEFAULT TRUE
);

-- 7. Reparaciones
CREATE TYPE estado_reparacion AS ENUM ('Pendiente', 'En Progreso', 'Esperando Repuestos', 'Completada', 'Entregada', 'Cancelada');

CREATE TABLE Reparaciones (
    ID_Reparacion   SERIAL PRIMARY KEY,
    ID_Motocicleta  INT          NOT NULL REFERENCES Motocicletas(ID_Motocicleta),
    ID_Mecanico     UUID         NOT NULL REFERENCES Perfiles(ID),
    Fecha_Ingreso   TIMESTAMP    NOT NULL DEFAULT NOW(),
    Fecha_Entrega   TIMESTAMP    NULL,
    Observaciones   TEXT         NULL,
    Estado          estado_reparacion NOT NULL DEFAULT 'Pendiente',
    Total_Servicios NUMERIC(10,2) DEFAULT 0,
    Total_Repuestos NUMERIC(10,2) DEFAULT 0,
    Total_Final     NUMERIC(10,2) DEFAULT 0
);

-- 8. Detalles de Reparación
CREATE TABLE Reparaciones_Servicios (
    ID_Reparacion INT NOT NULL REFERENCES Reparaciones(ID_Reparacion) ON DELETE CASCADE,
    ID_Servicio   INT NOT NULL REFERENCES Servicios(ID_Servicio),
    Precio_Aplicado NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (ID_Reparacion, ID_Servicio)
);

CREATE TABLE Reparaciones_Productos (
    ID_Reparacion INT NOT NULL REFERENCES Reparaciones(ID_Reparacion) ON DELETE CASCADE,
    ID_Producto   INT NOT NULL REFERENCES Productos(ID_Producto),
    Cantidad      INT NOT NULL,
    Precio_Unidad NUMERIC(10,2) NOT NULL,
    Subtotal      NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (ID_Reparacion, ID_Producto)
);

-- 9. Avances
CREATE TABLE Reparaciones_Avances (
    ID_Avance     SERIAL    PRIMARY KEY,
    ID_Reparacion INT       NOT NULL REFERENCES Reparaciones(ID_Reparacion) ON DELETE CASCADE,
    ID_Empleado   UUID      NOT NULL REFERENCES Perfiles(ID),
    Descripcion   TEXT      NOT NULL,
    Foto_Evidencia TEXT     NULL,
    Fecha         TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 10. Historial Inventario
CREATE TYPE tipo_movimiento AS ENUM ('Entrada', 'Salida', 'Ajuste');
CREATE TABLE Inventario_Historial (
    ID_Movimiento SERIAL PRIMARY KEY,
    ID_Producto   INT NOT NULL REFERENCES Productos(ID_Producto),
    Tipo          tipo_movimiento NOT NULL,
    Cantidad      INT NOT NULL,
    Motivo        TEXT,
    Fecha         TIMESTAMP DEFAULT NOW()
);

-- Trigger para descontar stock al insertar en Reparaciones_Productos
CREATE OR REPLACE FUNCTION descontar_stock_reparacion()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Productos 
    SET Stock = Stock - NEW.Cantidad 
    WHERE ID_Producto = NEW.ID_Producto;
    
    INSERT INTO Inventario_Historial (ID_Producto, Tipo, Cantidad, Motivo)
    VALUES (NEW.ID_Producto, 'Salida', NEW.Cantidad, 'Reparación ID: ' || NEW.ID_Reparacion);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock_reparacion
AFTER INSERT ON Reparaciones_Productos
FOR EACH ROW EXECUTE FUNCTION descontar_stock_reparacion();
