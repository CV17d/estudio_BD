-- =============================================================================
-- LABORATORIO FINAL BASES DE DATOS - SISTEMA BANCARIO (BANCODB)
-- Script Oficial DDL y Carga de Datos (DML)
-- Universidad Cooperativa de Colombia - PhD Cristian Ordoñez
-- =============================================================================

-- PASO 1: CREACIÓN Y CONEXIÓN
-- Ejecutar en consola psql o pgAdmin:
-- CREATE DATABASE bancodb;
-- \c bancodb

-- Limpieza preventiva de tablas (en orden inverso de dependencias)
DROP TABLE IF EXISTS transacciones CASCADE;
DROP TABLE IF EXISTS prestamos CASCADE;
DROP TABLE IF EXISTS cuentas CASCADE;
DROP TABLE IF EXISTS empleados CASCADE;
DROP TABLE IF EXISTS tipos_cuenta CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS sucursales CASCADE;

-- =============================================================================
-- PARTE 2: CREACIÓN DE TABLAS (DDL)
-- Orden estricto: Tablas Fuertes primero, luego Tablas Dependientes
-- =============================================================================

-- 1. Tabla Fuerte: sucursales
CREATE TABLE sucursales (
    id_sucursal SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);

-- 2. Tabla Dependiente: empleados (FK -> sucursales)
CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(12,2) NOT NULL,
    id_sucursal INT NOT NULL,
    CONSTRAINT fk_empleados_sucursal FOREIGN KEY (id_sucursal) 
        REFERENCES sucursales(id_sucursal) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. Tabla Fuerte: clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50) NOT NULL
);

-- 4. Tabla Fuerte: tipos_cuenta
CREATE TABLE tipos_cuenta (
    id_tipo SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

-- 5. Tabla Dependiente: cuentas (FK -> clientes, tipos_cuenta)
CREATE TABLE cuentas (
    id_cuenta SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    saldo NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    fecha_apertura DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
    id_cliente INT NOT NULL,
    id_tipo INT NOT NULL,
    CONSTRAINT fk_cuentas_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cuentas_tipo FOREIGN KEY (id_tipo) 
        REFERENCES tipos_cuenta(id_tipo) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 6. Tabla Dependiente: transacciones (FK -> cuentas)
CREATE TABLE transacciones (
    id_transaccion SERIAL PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_cuenta INT NOT NULL,
    CONSTRAINT fk_transacciones_cuenta FOREIGN KEY (id_cuenta) 
        REFERENCES cuentas(id_cuenta) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. Tabla Dependiente: prestamos (FK -> clientes)
CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    monto NUMERIC(12,2) NOT NULL,
    tasa_interes NUMERIC(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    cuotas INT NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT fk_prestamos_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================================================
-- PARTE 3: INSERCIÓN DE DATOS (DML)
-- Respetando el orden estricto de integridad referencial
-- =============================================================================

-- 1. Insertar registros en sucursales
INSERT INTO sucursales(nombre, ciudad, direccion) VALUES
('Sucursal Centro', 'Bogotá', 'Cra 10 #20-30'),
('Sucursal Norte', 'Medellín', 'Calle 50 #40-20'),
('Sucursal Sur', 'Cali', 'Av 5 Norte #12-10');

-- 2. Insertar registros en clientes
INSERT INTO clientes(nombre, apellido, telefono, correo, ciudad) VALUES
('Juan', 'Rodríguez', '3001112233', 'juan@gmail.com', 'Bogotá'),
('María', 'López', '3004445566', 'maria@gmail.com', 'Cali'),
('Pedro', 'Martínez', '3019998877', 'pedro@gmail.com', 'Medellín'),
('Laura', 'García', '3025556677', 'laura@gmail.com', 'Pasto'),
('Camila', 'Fernández', '3048887766', 'camila@gmail.com', 'Bogotá');

-- 3. Insertar tipos de cuenta
INSERT INTO tipos_cuenta(descripcion) VALUES
('Ahorros'),
('Corriente');

-- 4. Insertar registros en empleados
INSERT INTO empleados(nombre, cargo, salario, id_sucursal) VALUES
('Carlos Pérez', 'Gerente', 8500000, 1),
('Ana Torres', 'Asesor', 3500000, 1),
('Luis Gómez', 'Cajero', 2800000, 2),
('Martha Díaz', 'Asesor', 4200000, 3);

-- 5. Insertar cuentas bancarias
INSERT INTO cuentas(numero_cuenta, saldo, fecha_apertura, estado, id_cliente, id_tipo) VALUES
('20001', 5000000, '2024-01-10', 'Activa', 1, 1),
('20002', 1200000, '2024-02-11', 'Activa', 2, 2),
('20003', 9500000, '2024-03-15', 'Activa', 3, 1),
('20004', 850000, '2024-03-20', 'Bloqueada', 4, 2),
('20005', 15000000, '2024-04-05', 'Activa', 5, 1);

-- 6. Insertar transacciones financieras
INSERT INTO transacciones(tipo, monto, id_cuenta) VALUES
('Deposito', 500000, 1),
('Retiro', 200000, 1),
('Transferencia', 1000000, 2),
('Deposito', 800000, 3),
('Retiro', 350000, 4),
('Deposito', 1500000, 5);

-- 7. Insertar préstamos bancarios
INSERT INTO prestamos(monto, tasa_interes, fecha_inicio, cuotas, id_cliente) VALUES
(10000000, 12.5, '2024-01-15', 24, 1),
(5000000, 10.2, '2024-02-20', 12, 2),
(15000000, 15.0, '2024-03-10', 36, 3);

-- =============================================================================
-- VERIFICACIÓN INICIAL DE CARGA
-- =============================================================================
SELECT 'sucursales' AS tabla, COUNT(*) AS registros FROM sucursales
UNION ALL SELECT 'empleados', COUNT(*) FROM empleados
UNION ALL SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL SELECT 'tipos_cuenta', COUNT(*) FROM tipos_cuenta
UNION ALL SELECT 'cuentas', COUNT(*) FROM cuentas
UNION ALL SELECT 'transacciones', COUNT(*) FROM transacciones
UNION ALL SELECT 'prestamos', COUNT(*) FROM prestamos;
