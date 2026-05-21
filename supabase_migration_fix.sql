-- =============================================
--  PrimeDesk — SQL Migration Fix
--  Ejecutar en SQL Editor de Supabase
-- =============================================

-- 1. Agregar columnas faltantes a productos
ALTER TABLE productos ADD COLUMN IF NOT EXISTS cantidad INT NOT NULL DEFAULT 0;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS precio NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS stock_minimo INT NOT NULL DEFAULT 5;

-- 2. Foreign Key: reparaciones -> motocicletas
ALTER TABLE reparaciones DROP CONSTRAINT IF EXISTS fk_reparaciones_motocicletas;
ALTER TABLE reparaciones ADD CONSTRAINT fk_reparaciones_motocicletas
  FOREIGN KEY (id_motocicleta) REFERENCES motocicletas(id_motocicleta);

-- 3. Foreign Key: agendamientos -> motocicletas (si no existe)
ALTER TABLE agendamientos DROP CONSTRAINT IF EXISTS fk_agendamientos_motocicletas;
ALTER TABLE agendamientos ADD CONSTRAINT fk_agendamientos_motocicletas
  FOREIGN KEY (id_motocicleta) REFERENCES motocicletas(id_motocicleta);

-- 4. Foreign Key: agendamientos -> empleados (si no existe)
ALTER TABLE agendamientos DROP CONSTRAINT IF EXISTS fk_agendamientos_empleados;
ALTER TABLE agendamientos ADD CONSTRAINT fk_agendamientos_empleados
  FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado);

-- 5. Foreign Keys: ventas -> clientes, ventas -> reparaciones
ALTER TABLE ventas DROP CONSTRAINT IF EXISTS fk_ventas_clientes;
ALTER TABLE ventas ADD CONSTRAINT fk_ventas_clientes
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente);

ALTER TABLE ventas DROP CONSTRAINT IF EXISTS fk_ventas_reparaciones;
ALTER TABLE ventas ADD CONSTRAINT fk_ventas_reparaciones
  FOREIGN KEY (id_reparacion) REFERENCES reparaciones(id_reparacion);

-- 6. Foreign Key: compras -> proveedores
ALTER TABLE compras DROP CONSTRAINT IF EXISTS fk_compras_proveedores;
ALTER TABLE compras ADD CONSTRAINT fk_compras_proveedores
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor);

-- 7. Asignar cantidad/precio a productos existentes
UPDATE productos SET cantidad = 10, precio = 25000 WHERE cantidad IS NULL OR precio IS NULL OR precio = 0;

-- 8. Foreign Key: horarios -> empleados
ALTER TABLE horarios DROP CONSTRAINT IF EXISTS fk_horarios_empleados;
ALTER TABLE horarios ADD CONSTRAINT fk_horarios_empleados
  FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado);
