/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Funciones de usuario de VeterinariaPatitas
   Ejecutar después de Creacion.sql y Datos.sql
   ============================================================ */

USE VeterinariaPatitas;
GO

-- FN_EdadMascota: devuelve la edad en años de una mascota a una fecha de referencia.
-- Si todavía no cumplió años en el año de referencia, se resta uno.
CREATE OR ALTER FUNCTION dbo.FN_EdadMascota (
    @FechaNacimiento DATE,
    @FechaReferencia DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;

    SET @edad = DATEDIFF(YEAR, @FechaNacimiento, @FechaReferencia);

    IF (MONTH(@FechaReferencia) < MONTH(@FechaNacimiento))
       OR (MONTH(@FechaReferencia) = MONTH(@FechaNacimiento)
           AND DAY(@FechaReferencia) < DAY(@FechaNacimiento))
    BEGIN
        SET @edad = @edad - 1;
    END;

    RETURN @edad;
END;
GO

-- FN_ImporteMedicamentos: devuelve cuánto se cobró en medicamentos en una consulta
-- (cantidad por el precio que tenía cada medicamento ese día). Si no usó ninguno, devuelve 0.
CREATE OR ALTER FUNCTION dbo.FN_ImporteMedicamentos (
    @IDConsulta INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = SUM(Cantidad * PrecioUnitario)
    FROM ConsultaMedicamentos
    WHERE IDConsulta = @IDConsulta;

    RETURN ISNULL(@total, 0);
END;
GO
