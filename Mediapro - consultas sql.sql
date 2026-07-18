-- DOMINANDO CONSULTAS SQL

-- 1. Utiliza INNER JOIN con WHERE para encontrar todas las escenas de producciones de cierto género grabadas en determinadas localizaciones.
SELECT
    p.Titulo,
    p.Genero,
    e.ID_escena,
    e.Descripcion,
    l.Nombre AS Localizacion
FROM Produccion p
INNER JOIN Escena e
    ON p.ID_produccion = e.ID_produccion
INNER JOIN Plan_Rodaje_Escena pre
    ON e.ID_escena = pre.ID_escena
INNER JOIN Plan_Rodaje pr
    ON pre.ID_plan = pr.ID_plan
INNER JOIN Localizacion l
    ON pr.ID_localizacion = l.ID_localizacion
WHERE p.Genero = 'Drama'
AND l.Tipo = 'Interior';


-- 2. Aplica LEFT JOIN con ORDER BY para listar todo el personal creativo y sus asignaciones a producciones (si las tienen) ordenadas por fecha.
SELECT
    pe.Nombres,
    pe.Apellidos,
    pe.Especialidad,
    p.Titulo,
    pr.Fecha_inicio
FROM Personal pe
LEFT JOIN Produccion_Personal pp
    ON pe.ID_personal = pp.ID_personal
LEFT JOIN Produccion p
    ON pp.ID_produccion = p.ID_produccion
ORDER BY p.Fecha_inicio;


-- 3. Usa RIGHT JOIN con GROUP BY y HAVING para encontrar instalaciones utilizadas por más de 5 disciplinas diferentes y calcular la tasa de ocupación.
SELECT
    et.ID_equipo,
    et.Categoria,
    et.Marca,
    COUNT(pe.ID_produccion) AS TotalProducciones
FROM Produccion_Equipo pe
RIGHT JOIN Equipo_Tecnico et
    ON pe.ID_equipo = et.ID_equipo
GROUP BY
    et.ID_equipo,
    et.Categoria,
    et.Marca
HAVING COUNT(pe.ID_produccion) > 5;


-- 4. Implementa INNER JOIN múltiple con BETWEEN para listar material grabado en un período específico junto con los datos de la producción, escena y localización.

SELECT
    mg.ID_material,
    p.Titulo,
    e.Descripcion AS Escena,
    l.Nombre AS Localizacion,
    pr.Fecha
FROM Material_Grabado mg
INNER JOIN Produccion p
    ON mg.ID_produccion = p.ID_produccion
INNER JOIN Escena e
    ON mg.ID_escena = e.ID_escena
INNER JOIN Plan_Rodaje_Escena pre
    ON e.ID_escena = pre.ID_escena
INNER JOIN Plan_Rodaje pr
    ON pre.ID_plan = pr.ID_plan
INNER JOIN Localizacion l
    ON pr.ID_localizacion = l.ID_localizacion
WHERE pr.Fecha
BETWEEN '2025-01-01' AND '2025-06-30';


-- 5. Combina LEFT JOIN con IS NULL para identificar actores sin asignación a ninguna producción actual.
SELECT
    a.ID_actor,
    a.Nombres,
    a.Apellidos
FROM Actor a
LEFT JOIN Escena_Actor ea
    ON a.ID_actor = ea.ID_actor
LEFT JOIN Escena e
    ON ea.ID_escena = e.ID_escena
LEFT JOIN Produccion p
    ON e.ID_produccion = p.ID_produccion
WHERE p.ID_produccion IS NULL;


-- 6. Utiliza INNER JOIN con IN para encontrar procesos de postproducción relacionados con ciertas producciones específicas.
SELECT
    p.ID_produccion,
    p.Titulo,
    po.ID_post,
    po.Tipo,
    po.Responsable,
    po.Estado
FROM Produccion p
INNER JOIN Postproduccion po
    ON p.ID_produccion = po.ID_produccion
WHERE p.ID_produccion IN (1, 3, 5);


-- 7. Aplica JOIN con función de agregación SUM y GROUP BY para calcular los minutos totales grabados por producción y día.
SELECT
    p.Titulo,
    pr.Fecha,
    SUM(mg.Duracion) AS Total_Minutos
FROM Material_Grabado mg
INNER JOIN Produccion p
    ON mg.ID_produccion = p.ID_produccion
INNER JOIN Escena e
    ON mg.ID_escena = e.ID_escena
INNER JOIN Plan_Rodaje_Escena pre
    ON e.ID_escena = pre.ID_escena
INNER JOIN Plan_Rodaje pr
    ON pre.ID_plan = pr.ID_plan
GROUP BY
    p.Titulo,
    pr.Fecha;


-- 8. Usa INNER JOIN con LIKE para encontrar localizaciones con ciertas características en su descripción, junto con las producciones que las han utilizado.
SELECT
    l.Nombre,
    l.Caracteristicas,
    p.Titulo
FROM Localizacion l
INNER JOIN Produccion_Localizacion pl
    ON l.ID_localizacion = pl.ID_localizacion
INNER JOIN Produccion p
    ON pl.ID_produccion = p.ID_produccion
WHERE l.Caracteristicas LIKE '%Moderna%';


-- 9. Implementa JOIN múltiple con subconsulta para identificar las producciones con ratio de material útil superior al promedio para su tipo.
SELECT
    p.Titulo,
    SUM(mg.Duracion) AS Total_Minutos
FROM Produccion p
INNER JOIN Material_Grabado mg
    ON p.ID_produccion = mg.ID_produccion
GROUP BY
    p.ID_produccion,
    p.Titulo
HAVING SUM(mg.Duracion) >
(
    SELECT AVG(TotalMinutos)
    FROM
    (
        SELECT
            SUM(Duracion) AS TotalMinutos
        FROM Material_Grabado
        GROUP BY ID_produccion
    ) AS Promedio
);


-- 10. Combina LEFT JOIN con función de fecha para listar planes de rodaje programados para los próximos 15 días junto con los datos de la producción y localización, incluso si no hay rodajes próximos.
SELECT
    p.Titulo,
    pr.Fecha,
    l.Nombre AS Localizacion
FROM Produccion p
LEFT JOIN Plan_Rodaje pr
    ON p.ID_produccion = pr.ID_produccion
    AND pr.Fecha BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 15 DAY)
LEFT JOIN Localizacion l
    ON pr.ID_localizacion = l.ID_localizacion;