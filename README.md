# TPI Base de Datos II - Equipo 10

Sistema de gestión de una veterinaria (base VeterinariaPatitas), hecho en SQL Server.
Tecnicatura Universitaria en Programación - UTN FRGP.

## Integrantes
- Sackmann, Francisco
- Cristiani, Francisco
- Migliore, Lucas
- Aznal, Luciano

## Qué hay en el repositorio
- `DER_VeterinariaPatitas.png`: diagrama de entidad relación.
- `Creacion.sql`: crea la base y las 8 tablas con sus restricciones.
- `Datos.sql`: datos de ejemplo para probar todo.

## Cómo ejecutarlo (en este orden)
1. `Creacion.sql`
2. `Datos.sql`
3. Después, cuando estén, la función, las vistas, los procedimientos y los triggers.

Los datos se cargan antes de los triggers a propósito: los triggers rechazan turnos
con fecha pasada, y el historial de ejemplo tiene turnos viejos.

## En desarrollo
- `Funcion.sql`: FN_EdadMascota
- `Vistas.sql`: 3 vistas
- `Procedimientos.sql`: 2 procedimientos almacenados
- `Triggers.sql`: 3 triggers
