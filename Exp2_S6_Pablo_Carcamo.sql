
-- Primera consulta
SELECT 
    -- Datos Profesional
    profesional.id_profesional AS "ID",       
    appaterno ||' '|| apmaterno ||' '|| nombre AS "PROFESIONAL",
    
      -- Asesorias Banca
    (SELECT COUNT(*)
     FROM asesoria
     JOIN empresa ON asesoria.cod_empresa = empresa.cod_empresa
     WHERE id_profesional = profesional.id_profesional
     AND cod_sector = 3
     ) AS "NRO ASESORIA BANCA",
        
    -- Monto Banca    
    (SELECT TO_CHAR(SUM(honorario), '$99G999G999') 
     FROM asesoria
     JOIN empresa ON asesoria.cod_empresa = empresa.cod_empresa
     WHERE id_profesional = profesional.id_profesional
     AND cod_sector = 3
     ) AS "MONTO_TOTAL_BANCA", 
    
    -- Asesorias Retail
    COUNT(*) AS "NRO ASESORIA RETAIL",     
    
    -- Monto Retail    
    TO_CHAR(SUM(honorario), '$99G999G999') AS "MONTO_TOTAL_RETAIL",     
    
      -- Total Asesorias
    (SELECT COUNT(*)
     FROM asesoria
     JOIN empresa ON asesoria.cod_empresa = empresa.cod_empresa
     WHERE id_profesional = profesional.id_profesional
     AND cod_sector IN(3,4)
     ) AS "TOTAL_ASESORIAS",

    -- Total Retail
    (SELECT TO_CHAR(SUM(honorario), '$99G999G999') 
     FROM asesoria
     JOIN empresa ON asesoria.cod_empresa = empresa.cod_empresa
     WHERE id_profesional = profesional.id_profesional
     AND cod_sector IN(3,4) 
     ) AS "TOTAL_HONORARIOS"

FROM profesional
JOIN asesoria ON profesional.id_profesional = asesoria.id_profesional
JOIN empresa ON asesoria.cod_empresa = empresa.cod_empresa

WHERE cod_sector = 4
GROUP BY profesional.id_profesional, appaterno, apmaterno, nombre

ORDER BY "ID" ASC;



-- Segunda consulta
CREATE TABLE REPORTE_MES
AS
SELECT 
    --Datos profesional
    profesional.id_profesional AS "ID_PROF",
    
    appaterno ||' '|| apmaterno ||' '|| nombre AS "NOMBRE_COMPLETO",
    
    nombre_profesion AS "NOMBRE_PROFESION",    
    
    nom_comuna AS "NOM_COMUNA",
    
    -- Numero de asesorias 
    COUNT(*) AS "NRO_ASESORIAS",
    
    -- Calculo de honorarios
    ROUND(SUM(honorario)) AS "MONTO_TOTAL_HONORARIOS",

    ROUND(AVG(honorario)) AS "PROMEDIO_HONORARIO",
    
    ROUND(MIN(honorario)) AS "HONORARIO_MINIMO",

    ROUND(MAX(honorario)) AS "HONORARIO_MAXIMO"
       
FROM profesional
JOIN profesion ON profesional.cod_profesion = profesion.cod_profesion 
JOIN comuna ON profesional.cod_comuna = comuna.cod_comuna
JOIN asesoria ON profesional.id_profesional = asesoria.id_profesional

-- Abril 2024
WHERE EXTRACT(YEAR FROM fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) -1  
AND EXTRACT(MONTH FROM fin_asesoria) = EXTRACT(MONTH FROM SYSDATE) -8

GROUP BY profesional.id_profesional, appaterno, apmaterno, nombre,
nombre_profesion, nom_comuna

ORDER BY profesional.id_profesional ASC; 

--Ver tabla creada
SELECT * FROM REPORTE_MES;



--Tercera consulta
SELECT 
    --Honorarios y sueldo profesional
    SUM(honorario) AS "HONORARIO",
 
    profesional.id_profesional AS "ID_PROFESIONAL",
    
    numrun_prof AS "NUMRUN_PROF",
    
    sueldo AS "SUELDO"

FROM profesional 
JOIN asesoria ON profesional.id_profesional = asesoria.id_profesional

--Marzo 2024
WHERE EXTRACT(YEAR FROM fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) -1  
AND EXTRACT(MONTH FROM fin_asesoria) = EXTRACT(MONTH FROM SYSDATE) -9

GROUP BY profesional.id_profesional, numrun_prof, sueldo;

-- Update
UPDATE profesional    
SET sueldo = (SELECT  
              CASE   
                  WHEN SUM(honorario) < 1000000 THEN sueldo * 1.10
                  ELSE sueldo * 1.15
              END
              FROM asesoria)
              
WHERE sueldo = profesional.sueldo;
              
