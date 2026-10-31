/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Vistas de VeterinariaPatitas
   Ejecutar después de Funcion.sql (dos vistas usan las funciones)
   ============================================================ */

USE VeterinariaPatitas;
GO

-- VW_TurnosPendientes: turnos que todavía no se atendieron, con los datos que necesita la
-- recepción (mascota, dueño y teléfono, veterinario). Para ordenarlos se usa ORDER BY al
-- consultar la vista: SELECT * FROM VW_TurnosPendientes ORDER BY FechaHora;
CREATE OR ALTER VIEW VW_TurnosPendientes AS
SELECT
    t.IDTurno,
    t.FechaHora,
    DATEDIFF(DAY, GETDATE(), t.FechaHora) AS DiasHastaElTurno,
    t.Motivo,
    m.Nombre AS Mascota,
    e.Nombre AS Especie,
    d.Apellidos + ', ' + d.Nombres AS Duenio,
    d.Telefono,
    v.Apellidos + ', ' + v.Nombres AS Veterinario,
    v.Especialidad
FROM Turnos t
    INNER JOIN Mascotas m ON t.IDMascota = m.IDMascota
    INNER JOIN Especies e ON m.IDEspecie = e.IDEspecie
    INNER JOIN Duenios d ON m.IDDuenio = d.IDDuenio
    INNER JOIN Veterinarios v ON t.IDVeterinario = v.IDVeterinario
WHERE t.Estado = 'Pendiente';
GO

-- VW_HistorialClinico: cada consulta con la mascota, su dueño, el veterinario y lo que se
-- hizo. La edad es la que tenía la mascota el día de la consulta (usa FN_EdadMascota).
CREATE OR ALTER VIEW VW_HistorialClinico AS
SELECT
    c.IDConsulta,
    c.FechaConsulta,
    m.IDMascota,
    m.Nombre AS Mascota,
    e.Nombre AS Especie,
    dbo.FN_EdadMascota(m.FechaNacimiento, c.FechaConsulta) AS EdadEnAnios,
    d.Apellidos + ', ' + d.Nombres AS Duenio,
    v.Apellidos + ', ' + v.Nombres AS Veterinario,
    c.Diagnostico,
    c.Tratamiento,
    (SELECT COUNT(*)
     FROM ConsultaMedicamentos cm
     WHERE cm.IDConsulta = c.IDConsulta) AS MedicamentosUsados,
    c.Importe
FROM Consultas c
    INNER JOIN Turnos t ON c.IDTurno = t.IDTurno
    INNER JOIN Mascotas m ON t.IDMascota = m.IDMascota
    INNER JOIN Especies e ON m.IDEspecie = e.IDEspecie
    INNER JOIN Duenios d ON m.IDDuenio = d.IDDuenio
    INNER JOIN Veterinarios v ON t.IDVeterinario = v.IDVeterinario;
GO

-- VW_FacturacionPorVeterinario: por veterinario y por mes, cuántas consultas hizo,
-- cuánto facturó, el promedio por consulta y cuánto de eso fue en medicamentos
-- (usa FN_ImporteMedicamentos).
CREATE OR ALTER VIEW VW_FacturacionPorVeterinario AS
SELECT
    v.IDVeterinario,
    v.Apellidos + ', ' + v.Nombres AS Veterinario,
    YEAR(c.FechaConsulta) AS Anio,
    MONTH(c.FechaConsulta) AS Mes,
    COUNT(*) AS CantidadConsultas,
    SUM(c.Importe) AS TotalFacturado,
    AVG(c.Importe) AS PromedioPorConsulta,
    SUM(dbo.FN_ImporteMedicamentos(c.IDConsulta)) AS TotalEnMedicamentos
FROM Consultas c
    INNER JOIN Turnos t ON c.IDTurno = t.IDTurno
    INNER JOIN Veterinarios v ON t.IDVeterinario = v.IDVeterinario
GROUP BY
    v.IDVeterinario,
    v.Apellidos,
    v.Nombres,
    YEAR(c.FechaConsulta),
    MONTH(c.FechaConsulta);
GO

-- VW_StockMedicamentos: stock de cada medicamento con un aviso cuando queda poco.
CREATE OR ALTER VIEW VW_StockMedicamentos AS
SELECT
    IDMedicamento,
    Nombre,
    Stock,
    PrecioUnitario,
    CASE
        WHEN Stock = 0 THEN 'Sin stock'
        WHEN Stock <= 5 THEN 'Stock bajo'
        ELSE 'Normal'
    END AS EstadoStock,
    Stock * PrecioUnitario AS ValorEnStock
FROM Medicamentos;
GO
