/* ============================================================
   TPI - Base de Datos II (TUP) - Equipo 10
   Procedimientos almacenados de VeterinariaPatitas
   Ejecutar después de Funcion.sql
   ============================================================ */

USE VeterinariaPatitas;
GO

/* ------------------------------------------------------------
   SP_ReporteConsultasPorVeterinario (procedimiento de REPORTE)
   Recibe un veterinario y un rango de fechas, y devuelve las
   consultas que hizo en ese período. No modifica datos.
   Devuelve dos resultados: el detalle y un resumen.
   Ejemplo: EXEC SP_ReporteConsultasPorVeterinario 1, '2026-09-01', '2026-10-31';
   ------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE SP_ReporteConsultasPorVeterinario
    @IDVeterinario INT,
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    DECLARE @cantidad INT;

    -- Validaciones de los parámetros
    SELECT @cantidad = COUNT(*)
    FROM Veterinarios
    WHERE IDVeterinario = @IDVeterinario;

    IF @cantidad = 0
    BEGIN
        RAISERROR('El veterinario indicado no existe.', 16, 1);
        RETURN;
    END;

    IF @FechaDesde > @FechaHasta
    BEGIN
        RAISERROR('La fecha desde no puede ser posterior a la fecha hasta.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Detalle de las consultas del período
        SELECT
            c.FechaConsulta,
            m.Nombre AS Mascota,
            d.Apellidos + ', ' + d.Nombres AS Duenio,
            c.Diagnostico,
            dbo.FN_ImporteMedicamentos(c.IDConsulta) AS EnMedicamentos,
            c.Importe AS ImporteTotal
        FROM Consultas c
            INNER JOIN Turnos t ON c.IDTurno = t.IDTurno
            INNER JOIN Mascotas m ON t.IDMascota = m.IDMascota
            INNER JOIN Duenios d ON m.IDDuenio = d.IDDuenio
        WHERE t.IDVeterinario = @IDVeterinario
          AND CAST(c.FechaConsulta AS DATE) BETWEEN @FechaDesde AND @FechaHasta
        ORDER BY c.FechaConsulta;

        -- Resumen del período
        SELECT
            COUNT(*) AS CantidadConsultas,
            ISNULL(SUM(c.Importe), 0) AS TotalFacturado,
            ISNULL(AVG(c.Importe), 0) AS PromedioPorConsulta
        FROM Consultas c
            INNER JOIN Turnos t ON c.IDTurno = t.IDTurno
        WHERE t.IDVeterinario = @IDVeterinario
          AND CAST(c.FechaConsulta AS DATE) BETWEEN @FechaDesde AND @FechaHasta;
    END TRY
    BEGIN CATCH
        DECLARE @mensaje VARCHAR(5000);
        SET @mensaje = 'Error al generar el reporte: ' + ERROR_MESSAGE();
        RAISERROR(@mensaje, 16, 1);
    END CATCH
END;
GO

/* ------------------------------------------------------------
   SP_RegistrarConsulta (procedimiento de ACCIÓN)
   Registra la consulta de un turno pendiente y pasa el turno a
   Atendido. Las dos acciones se hacen juntas en una transacción:
   o se hacen las dos o no se hace ninguna.
   Ejemplo: EXEC SP_RegistrarConsulta 31, 'Control sin novedades', NULL, 9500;
   ------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE SP_RegistrarConsulta
    @IDTurno INT,
    @Diagnostico NVARCHAR(300),
    @Tratamiento NVARCHAR(300) = NULL,
    @Importe DECIMAL(10,2)
AS
BEGIN
    DECLARE @estado VARCHAR(10);
    DECLARE @mensaje VARCHAR(5000);

    -- Validaciones
    SELECT @estado = Estado
    FROM Turnos
    WHERE IDTurno = @IDTurno;

    IF @estado IS NULL
    BEGIN
        RAISERROR('El turno indicado no existe.', 16, 1);
        RETURN;
    END;

    IF @estado <> 'Pendiente'
    BEGIN
        SET @mensaje = 'Solo se puede registrar la consulta de un turno pendiente. '
                     + 'Estado actual: ' + @estado;
        RAISERROR(@mensaje, 16, 1);
        RETURN;
    END;

    IF LEN(LTRIM(RTRIM(ISNULL(@Diagnostico, '')))) = 0
    BEGIN
        RAISERROR('El diagnóstico es obligatorio.', 16, 1);
        RETURN;
    END;

    IF @Importe IS NULL OR @Importe < 0
    BEGIN
        RAISERROR('El importe no puede ser negativo.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Consultas (IDTurno, Diagnostico, Tratamiento, Importe)
        VALUES (@IDTurno, @Diagnostico, @Tratamiento, @Importe);

        UPDATE Turnos
        SET Estado = 'Atendido'
        WHERE IDTurno = @IDTurno;

        COMMIT TRANSACTION;

        -- Muestra la consulta que quedó registrada
        SELECT IDConsulta, IDTurno, FechaConsulta, Diagnostico, Tratamiento, Importe
        FROM Consultas
        WHERE IDTurno = @IDTurno;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @mensaje = 'Error al registrar la consulta: ' + ERROR_MESSAGE();
        RAISERROR(@mensaje, 16, 1);
    END CATCH
END;
GO

/* ------------------------------------------------------------
   SP_AgregarMedicamentoAConsulta (procedimiento de ACCIÓN)
   Agrega un medicamento a una consulta. Guarda el precio que
   tiene el medicamento ese día (así un cambio de precio no
   modifica el historial) y suma lo cobrado al importe de la
   consulta. El stock lo descuenta el trigger
   TR_DescontarStockMedicamento.
   Ejemplo: EXEC SP_AgregarMedicamentoAConsulta 5, 1, 2;
   ------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE SP_AgregarMedicamentoAConsulta
    @IDConsulta INT,
    @IDMedicamento INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @cantidadFilas INT;
    DECLARE @stock INT;
    DECLARE @precio DECIMAL(10,2);
    DECLARE @mensaje VARCHAR(5000);

    -- Validaciones
    SELECT @cantidadFilas = COUNT(*)
    FROM Consultas
    WHERE IDConsulta = @IDConsulta;

    IF @cantidadFilas = 0
    BEGIN
        RAISERROR('La consulta indicada no existe.', 16, 1);
        RETURN;
    END;

    SELECT @stock = Stock, @precio = PrecioUnitario
    FROM Medicamentos
    WHERE IDMedicamento = @IDMedicamento;

    IF @stock IS NULL
    BEGIN
        RAISERROR('El medicamento indicado no existe.', 16, 1);
        RETURN;
    END;

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        RAISERROR('La cantidad tiene que ser mayor a cero.', 16, 1);
        RETURN;
    END;

    SELECT @cantidadFilas = COUNT(*)
    FROM ConsultaMedicamentos
    WHERE IDConsulta = @IDConsulta AND IDMedicamento = @IDMedicamento;

    IF @cantidadFilas > 0
    BEGIN
        RAISERROR('Ese medicamento ya está cargado en la consulta.', 16, 1);
        RETURN;
    END;

    IF @stock < @Cantidad
    BEGIN
        SET @mensaje = 'No hay stock suficiente. Stock disponible: ' + CAST(@stock AS VARCHAR(10));
        RAISERROR(@mensaje, 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- El trigger TR_DescontarStockMedicamento descuenta el stock al insertar
        INSERT INTO ConsultaMedicamentos (IDConsulta, IDMedicamento, Cantidad, PrecioUnitario)
        VALUES (@IDConsulta, @IDMedicamento, @Cantidad, @precio);

        UPDATE Consultas
        SET Importe = Importe + (@Cantidad * @precio)
        WHERE IDConsulta = @IDConsulta;

        COMMIT TRANSACTION;

        -- Muestra cómo quedó la consulta y el stock del medicamento
        SELECT
            c.IDConsulta,
            c.Importe AS ImporteDeLaConsulta,
            m.Nombre AS Medicamento,
            @Cantidad AS CantidadAgregada,
            @precio AS PrecioAplicado,
            m.Stock AS StockActual
        FROM Consultas c
            INNER JOIN Medicamentos m ON m.IDMedicamento = @IDMedicamento
        WHERE c.IDConsulta = @IDConsulta;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @mensaje = 'Error al agregar el medicamento: ' + ERROR_MESSAGE();
        RAISERROR(@mensaje, 16, 1);
    END CATCH
END;
GO
