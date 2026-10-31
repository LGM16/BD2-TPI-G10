/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Triggers de la veterinaria (VeterinariaPatitas)

   Cómo usarlo:
   Ejecutar una sola vez, después de Creacion.sql y Datos.sql. 
   ============================================================ */

USE VeterinariaPatitas;
GO

CREATE TRIGGER TR_ValidarTurno ON Turnos
AFTER INSERT
AS
BEGIN

-- Rechazo de turno por Mascota o Veterinario Inactivo.
    IF (
        SELECT COUNT(*) FROM Mascotas
        WHERE Activa = 0 AND IDMascota IN (SELECT IDMascota FROM inserted)) > 0
    BEGIN
        RAISERROR('ERROR: La mascota se encuentra inactiva.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF (
        SELECT COUNT(*) FROM Veterinarios
        WHERE Activo = 0 AND IDVeterinario IN (SELECT IDVeterinario FROM inserted)) > 0
    BEGIN
        RAISERROR('ERROR: El Veterinario se encuentra inactivo.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

-- Rechazo de turno por fecha ya pasada.
    IF (SELECT COUNT(*) FROM inserted WHERE FechaHora < GETDATE()) > 0
    BEGIN
        RAISERROR('Error: No se puede registrar un turno con fecha pasada.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

-- Rechazo de turno si Veterinario tiene turno en ese horario (No se cuentan los cancelados).
    IF (
        SELECT COUNT(*)
        FROM inserted I
        INNER JOIN Turnos T ON T.IDVeterinario = I.IDVeterinario AND T.FechaHora = I.FechaHora
        
        WHERE T.IDTurno <> I.IDTurno
          AND I.Estado <> 'Cancelado'
          AND T.Estado <> 'Cancelado') > 0
    BEGIN
        RAISERROR('ERROR: El veterinario ya tiene un turno en ese horario.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

-- Rechazo de turno si la Mascota posee turno en la misma fecha.
    IF (
        SELECT COUNT(*)
        FROM inserted I
        INNER JOIN Turnos T ON T.IDMascota = I.IDMascota
        
        WHERE T.IDTurno <> I.IDTurno
          AND CAST(T.FechaHora AS DATE) = CAST(I.FechaHora AS DATE)
          AND I.Estado = 'Pendiente'
          AND T.Estado = 'Pendiente') > 0
    BEGIN
        RAISERROR('ERROR: La mascota ya tiene turno en esa fecha.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Descuenta del stock los medicamentos usados en una consulta.
-- Si no alcanza, cancela la operación y avisa el error.
CREATE TRIGGER TR_DescontarStockMedicamento ON ConsultaMedicamentos
AFTER INSERT
AS
BEGIN
    IF (
        SELECT COUNT(*) FROM Medicamentos
        WHERE Stock < (SELECT SUM(I.Cantidad) FROM inserted I
                       WHERE I.IDMedicamento = Medicamentos.IDMedicamento)) > 0
    BEGIN
        RAISERROR('ERROR: No hay stock suficiente para el medicamento.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE Medicamentos
    SET Stock = Stock - (SELECT SUM(I.Cantidad) FROM inserted I
                         WHERE I.IDMedicamento = Medicamentos.IDMedicamento)
    WHERE IDMedicamento IN (SELECT IDMedicamento FROM inserted);
END
GO

-- Al anular una consulta se devuelve el stock usado, se borra el detalle y se deja como pendiente el turno.
CREATE TRIGGER TR_AnularConsulta ON Consultas
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Medicamentos
    SET Stock = Stock + (SELECT SUM(CM.Cantidad) FROM ConsultaMedicamentos CM
                         WHERE CM.IDMedicamento = Medicamentos.IDMedicamento
                         AND CM.IDConsulta IN (SELECT IDConsulta FROM deleted))
    WHERE IDMedicamento IN (SELECT IDMedicamento FROM ConsultaMedicamentos
                            WHERE IDConsulta IN (SELECT IDConsulta FROM deleted));

    DELETE FROM ConsultaMedicamentos WHERE IDConsulta IN (SELECT IDConsulta FROM deleted);

    DELETE FROM Consultas WHERE IDConsulta IN (SELECT IDConsulta FROM deleted);

    UPDATE Turnos SET Estado = 'Pendiente' WHERE IDTurno IN (SELECT IDTurno FROM deleted);
END
GO
