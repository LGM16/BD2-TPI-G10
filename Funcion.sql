USE VeterinariaPatitas;
GO

IF OBJECT_ID('dbo.FN_EdadMascota', 'FN') IS NOT NULL
    DROP FUNCTION dbo.FN_EdadMascota;

GO

-- Funcion para 
CREATE FUNCTION dbo.FN_EdadMascota (
    @fechaNacimiento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Edad INT;
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE);

    SET @Edad = DATEDIFF(YEAR,@fechaNacimiento,@FechaActual);

    IF (MONTH(@FechaActual) = MONTH(@fechaNacimiento) AND DAY(@FechaActual) < DAY(@fechaNacimiento))
    BEGIN
        SET @Edad = @Edad - 1;
    END;

    RETURN @Edad;
END;
GO

-- Verificacion de funcionamiento correcto, borrar dsp
-- SELECT
--     M.IDMascota,
--     M.Nombre AS NombreMascota,
--     E.Nombre AS Especie,
--     M.FechaNacimiento,
--     dbo.FN_EdadMascota(M.FechaNacimiento) AS EdadActual 
-- FROM Mascotas M 
-- INNER JOIN Especies E ON M.IDEspecie = E.IDEspecie;