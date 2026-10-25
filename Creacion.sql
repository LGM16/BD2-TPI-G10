/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Sistema: gestión de una veterinaria
   Motor: SQL Server
   Script de creación de la base, las tablas y las restricciones
   ============================================================ */

IF DB_ID('VeterinariaPatitas') IS NULL
    CREATE DATABASE VeterinariaPatitas;
GO

USE VeterinariaPatitas;
GO

-- Especies: perro, gato, etc.
CREATE TABLE Especies (
    IDEspecie  INT IDENTITY(1,1) NOT NULL,
    Nombre     NVARCHAR(50)      NOT NULL,
    CONSTRAINT PK_Especies PRIMARY KEY (IDEspecie),
    CONSTRAINT UQ_Especies_Nombre UNIQUE (Nombre)
);
GO

-- Duenios: las personas responsables de las mascotas
CREATE TABLE Duenios (
    IDDuenio   INT IDENTITY(1,1) NOT NULL,
    Apellidos  NVARCHAR(100)     NOT NULL,
    Nombres    NVARCHAR(100)     NOT NULL,
    DNI        VARCHAR(10)       NOT NULL,
    Email      NVARCHAR(100)     NOT NULL,
    Telefono   VARCHAR(20)       NULL,
    Direccion  NVARCHAR(150)     NULL,
    FechaAlta  DATE              NOT NULL
        CONSTRAINT DF_Duenios_FechaAlta DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_Duenios PRIMARY KEY (IDDuenio),
    CONSTRAINT UQ_Duenios_DNI UNIQUE (DNI),
    CONSTRAINT CK_Duenios_Email CHECK (Email LIKE '%_@_%._%')
);
GO

-- Mascotas: los pacientes (no se borran, se dan de baja con Activa = 0)
CREATE TABLE Mascotas (
    IDMascota        INT IDENTITY(1,1) NOT NULL,
    IDDuenio         INT               NOT NULL,
    IDEspecie        INT               NOT NULL,
    Nombre           NVARCHAR(60)      NOT NULL,
    Raza             NVARCHAR(60)      NULL,
    Sexo             CHAR(1)           NOT NULL,
    FechaNacimiento  DATE              NOT NULL,
    Peso             DECIMAL(5,2)      NULL,
    Activa           BIT               NOT NULL
        CONSTRAINT DF_Mascotas_Activa DEFAULT (1),
    CONSTRAINT PK_Mascotas PRIMARY KEY (IDMascota),
    CONSTRAINT FK_Mascotas_Duenios
        FOREIGN KEY (IDDuenio) REFERENCES Duenios (IDDuenio),
    CONSTRAINT FK_Mascotas_Especies
        FOREIGN KEY (IDEspecie) REFERENCES Especies (IDEspecie),
    CONSTRAINT CK_Mascotas_Sexo CHECK (Sexo IN ('M', 'H')),
    CONSTRAINT CK_Mascotas_Peso CHECK (Peso IS NULL OR Peso > 0),
    CONSTRAINT CK_Mascotas_FechaNacimiento
        CHECK (FechaNacimiento <= CAST(GETDATE() AS DATE))
);
GO

-- Veterinarios: los profesionales que atienden
CREATE TABLE Veterinarios (
    IDVeterinario  INT IDENTITY(1,1) NOT NULL,
    Apellidos      NVARCHAR(100)     NOT NULL,
    Nombres        NVARCHAR(100)     NOT NULL,
    Matricula      VARCHAR(20)       NOT NULL,
    Email          NVARCHAR(100)     NOT NULL,
    Especialidad   NVARCHAR(80)      NULL,
    Activo         BIT               NOT NULL
        CONSTRAINT DF_Veterinarios_Activo DEFAULT (1),
    CONSTRAINT PK_Veterinarios PRIMARY KEY (IDVeterinario),
    CONSTRAINT UQ_Veterinarios_Matricula UNIQUE (Matricula),
    CONSTRAINT UQ_Veterinarios_Email UNIQUE (Email),
    CONSTRAINT CK_Veterinarios_Email CHECK (Email LIKE '%_@_%._%')
);
GO

-- Turnos: el estado puede ser Pendiente, Atendido o Cancelado
CREATE TABLE Turnos (
    IDTurno        INT IDENTITY(1,1) NOT NULL,
    IDMascota      INT               NOT NULL,
    IDVeterinario  INT               NOT NULL,
    FechaHora      DATETIME          NOT NULL,
    Motivo         NVARCHAR(200)     NOT NULL,
    Estado         VARCHAR(10)       NOT NULL
        CONSTRAINT DF_Turnos_Estado DEFAULT ('Pendiente'),
    CONSTRAINT PK_Turnos PRIMARY KEY (IDTurno),
    CONSTRAINT FK_Turnos_Mascotas
        FOREIGN KEY (IDMascota) REFERENCES Mascotas (IDMascota),
    CONSTRAINT FK_Turnos_Veterinarios
        FOREIGN KEY (IDVeterinario) REFERENCES Veterinarios (IDVeterinario),
    CONSTRAINT CK_Turnos_Estado
        CHECK (Estado IN ('Pendiente', 'Atendido', 'Cancelado'))
);
-- Ojo: que un veterinario no tenga dos turnos a la misma hora no va como UNIQUE,
-- porque un turno cancelado no tiene que bloquear el horario. Lo controla un trigger.
GO

-- Consultas: lo que se hace en un turno atendido (un turno tiene como mucho una)
-- Importe es el total cobrado: la consulta más los medicamentos usados
CREATE TABLE Consultas (
    IDConsulta     INT IDENTITY(1,1) NOT NULL,
    IDTurno        INT               NOT NULL,
    FechaConsulta  DATETIME          NOT NULL
        CONSTRAINT DF_Consultas_FechaConsulta DEFAULT (GETDATE()),
    Diagnostico    NVARCHAR(300)     NOT NULL,
    Tratamiento    NVARCHAR(300)     NULL,
    Importe        DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_Consultas PRIMARY KEY (IDConsulta),
    CONSTRAINT FK_Consultas_Turnos
        FOREIGN KEY (IDTurno) REFERENCES Turnos (IDTurno),
    CONSTRAINT UQ_Consultas_Turno UNIQUE (IDTurno),
    CONSTRAINT CK_Consultas_Importe CHECK (Importe >= 0)
);
GO

-- Medicamentos: stock y precio de cada uno
CREATE TABLE Medicamentos (
    IDMedicamento   INT IDENTITY(1,1) NOT NULL,
    Nombre          NVARCHAR(100)     NOT NULL,
    Stock           INT               NOT NULL
        CONSTRAINT DF_Medicamentos_Stock DEFAULT (0),
    PrecioUnitario  DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_Medicamentos PRIMARY KEY (IDMedicamento),
    CONSTRAINT UQ_Medicamentos_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Medicamentos_Stock CHECK (Stock >= 0),
    CONSTRAINT CK_Medicamentos_Precio CHECK (PrecioUnitario >= 0)
);
GO

-- ConsultaMedicamentos: medicamentos usados en cada consulta
-- (tabla intermedia, relación muchos a muchos)
-- PrecioUnitario guarda el precio que tenía el medicamento ese día, así un
-- cambio de precio en Medicamentos no modifica el historial de las consultas
CREATE TABLE ConsultaMedicamentos (
    IDConsulta      INT           NOT NULL,
    IDMedicamento   INT           NOT NULL,
    Cantidad        INT           NOT NULL,
    PrecioUnitario  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_ConsultaMedicamentos
        PRIMARY KEY (IDConsulta, IDMedicamento),
    CONSTRAINT FK_ConsultaMedicamentos_Consultas
        FOREIGN KEY (IDConsulta) REFERENCES Consultas (IDConsulta),
    CONSTRAINT FK_ConsultaMedicamentos_Medicamentos
        FOREIGN KEY (IDMedicamento) REFERENCES Medicamentos (IDMedicamento),
    CONSTRAINT CK_ConsultaMedicamentos_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_ConsultaMedicamentos_Precio CHECK (PrecioUnitario >= 0)
);
GO
