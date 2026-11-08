# TPI Base de Datos II - Equipo 10

Sistema de gestión de una veterinaria (base **VeterinariaPatitas**), hecho en SQL Server.
Tecnicatura Universitaria en Programación - UTN FRGP.

## Integrantes
- Sackmann, Francisco
- Cristiani, Francisco
- Migliore, Lucas
- Aznal, Luciano

## Qué hay en el repositorio

| Archivo | Qué contiene |
|---|---|
| `DER_VeterinariaPatitas.png` | Diagrama de entidad relación |
| `Creacion.sql` | Crea la base y las 8 tablas con sus restricciones |
| `Datos.sql` | Datos de ejemplo de todas las tablas |
| `Funcion.sql` | 2 funciones de usuario: `FN_EdadMascota` y `FN_ImporteMedicamentos` |
| `Vistas.sql` | 4 vistas: `VW_TurnosPendientes`, `VW_HistorialClinico`, `VW_FacturacionPorVeterinario` y `VW_StockMedicamentos` |
| `Procedimientos.sql` | 3 procedimientos: `SP_ReporteConsultasPorVeterinario` (reporte), `SP_RegistrarConsulta` y `SP_AgregarMedicamentoAConsulta` (acción) |
| `Triggers.sql` | 3 triggers: `TR_ValidarTurno` (INSERT), `TR_DescontarStockMedicamento` (INSERT) y `TR_AnularConsulta` (DELETE) |

## Cómo ejecutarlo (en este orden)
1. `Creacion.sql`
2. `Datos.sql`
3. `Funcion.sql`
4. `Vistas.sql`
5. `Procedimientos.sql`
6. `Triggers.sql`

Los datos se cargan **antes** de los triggers a propósito: `TR_ValidarTurno` rechaza turnos con
fecha pasada y el historial de ejemplo tiene turnos viejos, y `TR_DescontarStockMedicamento`
descontaría stock que en los datos de ejemplo ya está descontado.

Las fechas de `Datos.sql` son relativas al día en que se ejecuta: el historial queda en los
últimos dos meses y los turnos pendientes en las próximas dos semanas.

Para volver al estado inicial después de las pruebas hay que borrar la base
(`DROP DATABASE VeterinariaPatitas`) y ejecutar de nuevo `Creacion.sql` y `Datos.sql`.

## Notas
- Los scripts están guardados en UTF-8 con BOM para que los acentos se vean bien en SQL Server
  Management Studio.
- Los scripts de funciones, vistas, procedimientos y triggers usan `CREATE OR ALTER`, así que se
  pueden ejecutar más de una vez.

## Video de la demo
El video (hasta 25 minutos) muestra el sistema funcionando en SQL Server Management Studio, con casos de éxito
y de validación. Cada integrante graba y explica una parte:

| Integrante | Qué muestra | Tiempo |
|---|---|---|
| Sackmann, Francisco | Presentación del equipo y del sistema, el DER y las tablas con los datos de ejemplo | 4:30 |
| Migliore, Lucas | Funciones, vistas y procedimientos (detalle abajo) | 10:30 |
| Cristiani, Francisco | Los 3 triggers (detalle abajo) | 6:00 |
| Todos | Cierre: resumen y repositorio | 1:00 |

**Migliore, Lucas**
- Funciones: `FN_EdadMascota` (con la fecha de referencia y el caso del cumpleaños) y `FN_ImporteMedicamentos`.
- Vistas: `VW_TurnosPendientes`, `VW_HistorialClinico` (usa `FN_EdadMascota`), `VW_FacturacionPorVeterinario`
  (usa `FN_ImporteMedicamentos`) y `VW_StockMedicamentos`.
- Procedimientos: `SP_ReporteConsultasPorVeterinario` con los parámetros visibles (caso correcto y casos con error),
  `SP_RegistrarConsulta` (el turno pasa a Atendido y aparece la consulta) y `SP_AgregarMedicamentoAConsulta`
  (stock antes y después, y el caso sin stock suficiente).

**Cristiani, Francisco**
- `TR_DescontarStockMedicamento`: un INSERT con más cantidad que el stock se rechaza y el stock no cambia.
- `TR_ValidarTurno`: un turno válido y los casos que rechaza (mascota o veterinario inactivo, fecha pasada,
  veterinario ocupado y mascota con otro turno el mismo día).
- `TR_AnularConsulta`: un DELETE sobre una consulta, mostrando antes y después la consulta, el detalle, el stock y
  el estado del turno.
