/* 
Proyecto: BancoGT - Análisis de Fraude Transaccional
Archivo: 02_Analisis_KPIs.sql
Descripción: Consultas de diagnóstico, segmentación y validación de controles de riesgo.
*/

USE BancoGT;
GO

-- ====================================================================
-- 1. KPI GLOBAL: MÉTRICAS GENERALES DE LA CARTERA
-- Solución: Centralización de indicadores de salud financiera.
-- Fin: Obtener el monto exacto de pérdida monetaria para justificar inversiones en ciberseguridad.
-- ====================================================================
SELECT 
    COUNT(*) AS Total_Transacciones,
    SUM(CAST(is_fraud AS INT)) AS Total_Fraudes,
    CAST(SUM(CAST(is_fraud AS INT)) AS FLOAT) / COUNT(*) * 100 AS Tasa_Fraude_Porcentaje,
    SUM(amount) AS Monto_Total_Transaccionado,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END) AS Monto_Total_Perdida_Fraude
FROM BancoGT;


-- ====================================================================
-- 2. ANÁLISIS GEOGRÁFICO: CONCENTRACIÓN DE RIESGO
-- Solución: Segmentación por país para detectar mercados de alto riesgo.
-- Fin: Identificar países donde la tasa de fraude excede los estándares permitidos para restringir o fortalecer controles.
-- ====================================================================
SELECT 
    country AS Pais,
    COUNT(*) AS Volumetria,
    SUM(CAST(is_fraud AS INT)) AS Cantidad_Fraudes,
    CAST(SUM(CAST(is_fraud AS INT)) AS FLOAT) / COUNT(*) * 100 AS Tasa_Fraude_Pais,
    AVG(amount) AS Ticket_Promedio
FROM BancoGT
GROUP BY country
ORDER BY Tasa_Fraude_Pais DESC;


-- ====================================================================
-- 3. PERFILAMIENTO COMERCIAL: CANAL Y CATEGORÍA
-- Solución: Desglose de transacciones por tipo y categoría de comercio.
-- Fin: Detectar vulnerabilidades en comercios específicos para aplicar reglas de validación más estrictas.
-- ====================================================================
SELECT 
    transaction_type AS Canal_Transaccional,
    merchant_category AS Categoria_Comercio,
    COUNT(*) AS Volumetria,
    SUM(CAST(is_fraud AS INT)) AS Casos_Fraude,
    CAST(SUM(CAST(is_fraud AS INT)) AS FLOAT) / COUNT(*) * 100 AS Tasa_Fraude
FROM BancoGT
GROUP BY transaction_type, merchant_category
ORDER BY Casos_Fraude DESC;


-- ====================================================================
-- 4. ANÁLISIS TEMPORAL: BLOQUES HORARIOS
-- Solución: Agrupación horaria mediante lógica condicional (CASE).
-- Fin: Optimizar los turnos del equipo de monitoreo, asignando más personal en las horas de mayor actividad fraudulenta.
-- ====================================================================
SELECT 
    CASE 
        WHEN hour >= 0 AND hour < 6 THEN '1. Madrugada (00-05h)'
        WHEN hour >= 6 AND hour < 12 THEN '2. Mañana (06-11h)'
        WHEN hour >= 12 AND hour < 18 THEN '3. Tarde (12-17h)'
        ELSE '4. Noche (18-23h)'
    END AS Bloque_Horario,
    COUNT(*) AS Volumetria,
    SUM(CAST(is_fraud AS INT)) AS Fraudes,
    CAST(SUM(CAST(is_fraud AS INT)) AS FLOAT) / COUNT(*) * 100 AS Tasa_Fraude
FROM BancoGT
GROUP BY 
    CASE 
        WHEN hour >= 0 AND hour < 6 THEN '1. Madrugada (00-05h)'
        WHEN hour >= 6 AND hour < 12 THEN '2. Mañana (06-11h)'
        WHEN hour >= 12 AND hour < 18 THEN '3. Tarde (12-17h)'
        ELSE '4. Noche (18-23h)'
    END
ORDER BY Bloque_Horario;


-- ====================================================================
-- 5. VALIDACIÓN DE CONTROLES: CORRELACIÓN RIESGO VS FRAUDE
-- Solución: Comparativa de scores promedio entre transacciones legítimas y fraudulentas.
-- Fin: Demostrar científicamente la efectividad de nuestros modelos de predicción de riesgo.
-- ====================================================================
SELECT 
    is_fraud AS Fraude_Confirmado,
    AVG(device_risk_score) AS Promedio_Riesgo_Dispositivo,
    AVG(ip_risk_score) AS Promedio_Riesgo_IP,
    MAX(amount) AS Maximo_Monto_Transaccion
FROM BancoGT
GROUP BY is_fraud;