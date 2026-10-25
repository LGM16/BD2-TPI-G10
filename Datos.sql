/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Datos de ejemplo de la veterinaria (VeterinariaPatitas)

   Cómo usarlo:
   1) Ejecutar Creacion.sql (base recién creada, tablas vacías).
   2) Ejecutar este script.
   3) Recién después crear las vistas, procedimientos y triggers.
      (Los triggers rechazan turnos con fecha pasada y descuentan
      stock, así que los datos históricos tienen que cargarse antes.)

   Las fechas son relativas al día en que se ejecuta el script:
   el historial queda en los últimos dos meses y los turnos
   pendientes en las próximas dos semanas.
   El stock de los medicamentos ya refleja lo usado en las consultas.
   ============================================================ */

USE VeterinariaPatitas;
GO

SET NOCOUNT ON;
DECLARE @hoy DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

-- Especies
INSERT INTO Especies (Nombre) VALUES
    (N'Perro'),
    (N'Gato'),
    (N'Ave'),
    (N'Conejo'),
    (N'Hámster');

-- Dueños
INSERT INTO Duenios (Apellidos, Nombres, DNI, Email, Telefono, Direccion, FechaAlta) VALUES
    (N'Gómez', N'Mariana', '28451102', N'mariana.gomez@mail.com', '11-4455-1001', N'Av. San Martín 1234, General Pacheco', DATEADD(DAY, -400, CAST(@hoy AS DATE))),
    (N'Fernández', N'Julián', '30218774', N'julian.fernandez@mail.com', '11-4455-1002', N'Mitre 567, Tigre', DATEADD(DAY, -380, CAST(@hoy AS DATE))),
    (N'Rodríguez', N'Carolina', '33902561', N'carolina.rodriguez@mail.com', '11-4455-1003', N'Belgrano 890, General Pacheco', DATEADD(DAY, -350, CAST(@hoy AS DATE))),
    (N'López', N'Martín', '27664390', N'martin.lopez@mail.com', '11-4455-1004', N'Sarmiento 2100, Don Torcuato', DATEADD(DAY, -330, CAST(@hoy AS DATE))),
    (N'Martínez', N'Sofía', '35127845', N'sofia.martinez@mail.com', '11-4455-1005', N'Rivadavia 456, Tigre', DATEADD(DAY, -300, CAST(@hoy AS DATE))),
    (N'Pérez', N'Diego', '31770923', N'diego.perez@mail.com', '11-4455-1006', N'Av. Márquez 3300, Villa Ballester', DATEADD(DAY, -280, CAST(@hoy AS DATE))),
    (N'Sánchez', N'Lucía', '36485217', N'lucia.sanchez@mail.com', '11-4455-1007', N'Italia 150, General Pacheco', DATEADD(DAY, -250, CAST(@hoy AS DATE))),
    (N'Romero', N'Facundo', '29338406', N'facundo.romero@mail.com', '11-4455-1008', N'Moreno 745, Benavídez', DATEADD(DAY, -220, CAST(@hoy AS DATE))),
    (N'Díaz', N'Valeria', '34056129', N'valeria.diaz@mail.com', '11-4455-1009', N'Alsina 1020, Tigre', DATEADD(DAY, -200, CAST(@hoy AS DATE))),
    (N'Torres', N'Nicolás', '32649871', N'familiatorres@mail.com', '11-4455-1010', N'Los Aromos 88, Don Torcuato', DATEADD(DAY, -150, CAST(@hoy AS DATE))),
    (N'Torres', N'Camila', '38112764', N'familiatorres@mail.com', '11-4455-1011', N'Los Aromos 88, Don Torcuato', DATEADD(DAY, -140, CAST(@hoy AS DATE))),
    (N'Ruiz', N'Esteban', '26873350', N'esteban.ruiz@mail.com', '11-4455-1012', N'Colón 312, General Pacheco', DATEADD(DAY, -90, CAST(@hoy AS DATE)));

-- Mascotas (dos están dadas de baja: Activa = 0)
INSERT INTO Mascotas (IDDuenio, IDEspecie, Nombre, Raza, Sexo, FechaNacimiento, Peso, Activa) VALUES
    (1, 1, N'Rocky', N'Labrador', 'M', '2019-03-14', 31.5, 1),
    (1, 2, N'Luna', N'Siamés', 'H', '2021-07-02', 4.2, 1),
    (2, 1, N'Max', N'Mestizo', 'M', '2017-11-20', 18.0, 1),
    (3, 2, N'Mía', N'Persa', 'H', '2020-01-09', 3.8, 1),
    (3, 1, N'Toby', N'Beagle', 'M', '2022-05-30', 11.4, 1),
    (4, 1, N'Simba', N'Golden Retriever', 'M', '2018-09-12', 33.0, 1),
    (5, 2, N'Nala', N'Mestizo', 'H', '2023-02-18', 3.1, 1),
    (5, 3, N'Coco', N'Canario', 'M', '2022-08-25', 0.03, 0),
    (6, 1, N'Bruno', N'Bulldog Francés', 'M', '2021-04-05', 12.8, 1),
    (6, 1, N'Kira', N'Border Collie', 'H', '2020-10-17', 19.6, 1),
    (7, 2, N'Pelusa', N'Angora', 'H', '2016-06-21', 4.5, 1),
    (7, 4, N'Thor', N'Enano', 'M', '2023-09-03', 1.6, 1),
    (8, 1, N'Lola', N'Caniche', 'H', '2019-12-01', 6.7, 1),
    (8, 2, N'Milo', N'Mestizo', 'M', '2024-03-27', 3.9, 1),
    (9, 1, N'Zeus', N'Ovejero Alemán', 'M', '2015-08-08', 36.2, 1),
    (10, 5, N'Mora', N'Sirio', 'H', '2025-01-15', 0.12, 1),
    (10, 2, N'Canela', N'Mestizo', 'H', '2022-11-11', 4.0, 1),
    (11, 3, N'Pipo', N'Cotorra', 'M', '2021-06-06', 0.09, 1),
    (11, 1, N'Nube', N'Samoyedo', 'H', '2023-12-24', 17.3, 0),
    (12, 1, N'Tango', N'Mestizo', 'M', '2020-07-19', 22.1, 1);

-- Veterinarios (Molina ya no atiende: Activo = 0)
INSERT INTO Veterinarios (Apellidos, Nombres, Matricula, Email, Especialidad, Activo) VALUES
    (N'Herrera', N'Paula', 'MP-1001', N'paula.herrera@patitas.com', N'Clínica general', 1),
    (N'Navarro', N'Ignacio', 'MP-1002', N'ignacio.navarro@patitas.com', N'Cirugía', 1),
    (N'Castro', N'Julieta', 'MP-1003', N'julieta.castro@patitas.com', N'Dermatología', 1),
    (N'Benítez', N'Raúl', 'MP-1004', N'raul.benitez@patitas.com', N'Animales exóticos', 1),
    (N'Molina', N'Gabriela', 'MP-1005', N'gabriela.molina@patitas.com', N'Clínica general', 0);

-- Medicamentos (Omeprazol y Colirio quedaron con poco stock)
INSERT INTO Medicamentos (Nombre, Stock, PrecioUnitario) VALUES
    (N'Amoxicilina 250 mg', 45, 2800),
    (N'Meloxicam 1 mg', 30, 2100),
    (N'Ivermectina', 60, 1500),
    (N'Antiparasitario externo (pipeta)', 25, 4300),
    (N'Vacuna antirrábica', 40, 3500),
    (N'Vacuna quíntuple', 35, 5200),
    (N'Suero fisiológico', 80, 900),
    (N'Omeprazol 20 mg', 3, 1700),
    (N'Colirio antibiótico', 5, 2600),
    (N'Complejo vitamínico B', 50, 1900);

-- Turnos: atendidos (historial), cancelados y pendientes
-- Nota: el turno cancelado del veterinario 1 de dentro de 3 días a las 11 comparte horario
-- con otro turno pendiente: un turno cancelado no bloquea el horario.
INSERT INTO Turnos (IDMascota, IDVeterinario, FechaHora, Motivo, Estado) VALUES
    (1, 5, DATEADD(HOUR, 12, DATEADD(DAY, -58, @hoy)), N'Cojera', 'Atendido'),
    (8, 2, DATEADD(HOUR, 17, DATEADD(DAY, -56, @hoy)), N'Cojera', 'Atendido'),
    (15, 5, DATEADD(HOUR, 12, DATEADD(DAY, -54, @hoy)), N'Vómitos y decaimiento', 'Atendido'),
    (2, 4, DATEADD(HOUR, 16, DATEADD(DAY, -50, @hoy)), N'Cojera', 'Atendido'),
    (9, 1, DATEADD(HOUR, 16, DATEADD(DAY, -48, @hoy)), N'Control post operatorio', 'Atendido'),
    (16, 5, DATEADD(HOUR, 10, DATEADD(DAY, -45, @hoy)), N'Pérdida de apetito', 'Atendido'),
    (3, 3, DATEADD(HOUR, 17, DATEADD(DAY, -43, @hoy)), N'Problemas en la piel', 'Atendido'),
    (10, 4, DATEADD(HOUR, 12, DATEADD(DAY, -41, @hoy)), N'Control anual', 'Atendido'),
    (17, 1, DATEADD(HOUR, 12, DATEADD(DAY, -38, @hoy)), N'Control general', 'Atendido'),
    (4, 2, DATEADD(HOUR, 15, DATEADD(DAY, -36, @hoy)), N'Control general', 'Atendido'),
    (11, 3, DATEADD(HOUR, 10, DATEADD(DAY, -35, @hoy)), N'Vómitos y decaimiento', 'Atendido'),
    (18, 4, DATEADD(HOUR, 10, DATEADD(DAY, -34, @hoy)), N'Cojera', 'Atendido'),
    (5, 1, DATEADD(HOUR, 15, DATEADD(DAY, -32, @hoy)), N'Control post operatorio', 'Atendido'),
    (12, 2, DATEADD(HOUR, 17, DATEADD(DAY, -31, @hoy)), N'Problemas en la piel', 'Atendido'),
    (19, 3, DATEADD(HOUR, 11, DATEADD(DAY, -29, @hoy)), N'Revisión de oído', 'Atendido'),
    (6, 4, DATEADD(HOUR, 12, DATEADD(DAY, -28, @hoy)), N'Desparasitación', 'Atendido'),
    (13, 1, DATEADD(HOUR, 12, DATEADD(DAY, -27, @hoy)), N'Vacunación', 'Atendido'),
    (20, 2, DATEADD(HOUR, 16, DATEADD(DAY, -25, @hoy)), N'Control anual', 'Atendido'),
    (7, 3, DATEADD(HOUR, 11, DATEADD(DAY, -22, @hoy)), N'Revisión de oído', 'Atendido'),
    (14, 4, DATEADD(HOUR, 10, DATEADD(DAY, -17, @hoy)), N'Problemas en la piel', 'Atendido'),
    (1, 1, DATEADD(HOUR, 12, DATEADD(DAY, -15, @hoy)), N'Problemas en la piel', 'Atendido'),
    (3, 1, DATEADD(HOUR, 10, DATEADD(DAY, -12, @hoy)), N'Vacunación', 'Cancelado'),
    (8, 2, DATEADD(HOUR, 9, DATEADD(DAY, -11, @hoy)), N'Control general', 'Atendido'),
    (9, 3, DATEADD(HOUR, 16, DATEADD(DAY, -6, @hoy)), N'Revisión de oído', 'Cancelado'),
    (15, 3, DATEADD(HOUR, 12, DATEADD(DAY, -4, @hoy)), N'Cojera', 'Atendido'),
    (2, 4, DATEADD(HOUR, 17, DATEADD(DAY, -3, @hoy)), N'Control anual', 'Atendido'),
    (1, 1, DATEADD(HOUR, 9, DATEADD(DAY, 1, @hoy)), N'Desparasitación', 'Pendiente'),
    (2, 3, DATEADD(HOUR, 10, DATEADD(DAY, 1, @hoy)), N'Control anual', 'Pendiente'),
    (5, 2, DATEADD(HOUR, 15, DATEADD(DAY, 2, @hoy)), N'Control post operatorio', 'Pendiente'),
    (7, 4, DATEADD(HOUR, 16, DATEADD(DAY, 2, @hoy)), N'Control anual', 'Pendiente'),
    (6, 1, DATEADD(HOUR, 11, DATEADD(DAY, 3, @hoy)), N'Vómitos y decaimiento', 'Cancelado'),
    (13, 1, DATEADD(HOUR, 11, DATEADD(DAY, 3, @hoy)), N'Vómitos y decaimiento', 'Pendiente'),
    (10, 3, DATEADD(HOUR, 10, DATEADD(DAY, 5, @hoy)), N'Vacunación', 'Pendiente'),
    (4, 2, DATEADD(HOUR, 12, DATEADD(DAY, 6, @hoy)), N'Vacunación', 'Pendiente'),
    (17, 4, DATEADD(HOUR, 9, DATEADD(DAY, 8, @hoy)), N'Pérdida de apetito', 'Pendiente'),
    (15, 2, DATEADD(HOUR, 11, DATEADD(DAY, 9, @hoy)), N'Vacunación', 'Cancelado'),
    (20, 1, DATEADD(HOUR, 17, DATEADD(DAY, 10, @hoy)), N'Vómitos y decaimiento', 'Pendiente'),
    (16, 4, DATEADD(HOUR, 11, DATEADD(DAY, 12, @hoy)), N'Problemas en la piel', 'Pendiente');

-- Consultas (una por cada turno atendido; los importes incluyen los medicamentos usados)
INSERT INTO Consultas (IDTurno, FechaConsulta, Diagnostico, Tratamiento, Importe) VALUES
    (1, DATEADD(HOUR, 12, DATEADD(DAY, -58, @hoy)), N'Parásitos intestinales', N'Desparasitación y repetir en 15 días', 19700),
    (2, DATEADD(HOUR, 17, DATEADD(DAY, -56, @hoy)), N'Evolución favorable post operatoria', N'Retiro de puntos y control en 10 días', 19200),
    (3, DATEADD(HOUR, 12, DATEADD(DAY, -54, @hoy)), N'Vacunación al día', N'Se aplica refuerzo anual', 12500),
    (4, DATEADD(HOUR, 16, DATEADD(DAY, -50, @hoy)), N'Vacunación al día', N'Se aplica refuerzo anual', 11900),
    (5, DATEADD(HOUR, 16, DATEADD(DAY, -48, @hoy)), N'Control sin novedades', N'Se indican controles anuales', 15000),
    (6, DATEADD(HOUR, 10, DATEADD(DAY, -45, @hoy)), N'Parásitos intestinales', N'Desparasitación y repetir en 15 días', 15200),
    (7, DATEADD(HOUR, 17, DATEADD(DAY, -43, @hoy)), N'Vacunación al día', N'Se aplica refuerzo anual', 15200),
    (8, DATEADD(HOUR, 12, DATEADD(DAY, -41, @hoy)), N'Otitis externa', N'Limpieza y gotas óticas por 7 días', 21600),
    (9, DATEADD(HOUR, 12, DATEADD(DAY, -38, @hoy)), N'Evolución favorable post operatoria', N'Retiro de puntos y control en 10 días', 12500),
    (10, DATEADD(HOUR, 15, DATEADD(DAY, -36, @hoy)), N'Dermatitis alérgica', N'Baños medicados y antihistamínico', 18200),
    (11, DATEADD(HOUR, 10, DATEADD(DAY, -35, @hoy)), N'Infección urinaria', N'Antibiótico por 10 días', 19200),
    (12, DATEADD(HOUR, 10, DATEADD(DAY, -34, @hoy)), N'Conjuntivitis', N'Colirio cada 8 horas por 5 días', 8000),
    (13, DATEADD(HOUR, 15, DATEADD(DAY, -32, @hoy)), N'Vacunación al día', N'Se aplica refuerzo anual', 15000),
    (14, DATEADD(HOUR, 17, DATEADD(DAY, -31, @hoy)), N'Control sin novedades', N'Se indican controles anuales', 11000),
    (15, DATEADD(HOUR, 11, DATEADD(DAY, -29, @hoy)), N'Dermatitis alérgica', N'Baños medicados y antihistamínico', 17600),
    (16, DATEADD(HOUR, 12, DATEADD(DAY, -28, @hoy)), N'Infección urinaria', N'Antibiótico por 10 días', 23000),
    (17, DATEADD(HOUR, 12, DATEADD(DAY, -27, @hoy)), N'Conjuntivitis', N'Colirio cada 8 horas por 5 días', 18600),
    (18, DATEADD(HOUR, 16, DATEADD(DAY, -25, @hoy)), N'Evolución favorable post operatoria', N'Retiro de puntos y control en 10 días', 13700),
    (19, DATEADD(HOUR, 11, DATEADD(DAY, -22, @hoy)), N'Control sin novedades', N'Se indican controles anuales', 8900),
    (20, DATEADD(HOUR, 10, DATEADD(DAY, -17, @hoy)), N'Esguince leve', N'Reposo y antiinflamatorio', 8000),
    (21, DATEADD(HOUR, 12, DATEADD(DAY, -15, @hoy)), N'Evolución favorable post operatoria', N'Retiro de puntos y control en 10 días', 15000),
    (23, DATEADD(HOUR, 9, DATEADD(DAY, -11, @hoy)), N'Esguince leve', N'Reposo y antiinflamatorio', 19200),
    (25, DATEADD(HOUR, 12, DATEADD(DAY, -4, @hoy)), N'Parásitos intestinales', N'Desparasitación y repetir en 15 días', 9500),
    (26, DATEADD(HOUR, 17, DATEADD(DAY, -3, @hoy)), N'Evolución favorable post operatoria', N'Retiro de puntos y control en 10 días', 24400);

-- Medicamentos usados en cada consulta, con el precio que tenían ese día
-- (varias consultas viejas quedaron con precios anteriores al aumento)
INSERT INTO ConsultaMedicamentos (IDConsulta, IDMedicamento, Cantidad, PrecioUnitario) VALUES
    (1, 8, 2, 1700),
    (1, 4, 1, 3800),
    (2, 2, 2, 2100),
    (3, 3, 1, 1500),
    (4, 7, 1, 900),
    (6, 2, 2, 2100),
    (7, 7, 3, 900),
    (8, 9, 3, 2200),
    (10, 7, 3, 900),
    (10, 3, 2, 1500),
    (11, 3, 3, 1500),
    (11, 9, 1, 2200),
    (15, 8, 3, 1700),
    (15, 3, 3, 1500),
    (16, 5, 3, 3500),
    (17, 4, 2, 3800),
    (18, 10, 3, 1900),
    (19, 7, 1, 900),
    (22, 3, 3, 1500),
    (22, 6, 1, 5200),
    (24, 4, 2, 4300),
    (24, 2, 3, 2100);

GO
