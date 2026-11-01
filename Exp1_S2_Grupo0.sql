SELECT
    NUMFACTURA AS "N° Factura",
    TO_CHAR(
        FECHA,
        'DD "de" FMMonth YYYY',
        'NLS_DATE_LANGUAGE=SPANISH'
    ) AS "Fecha Emisión",
    LPAD(RUTCLIENTE, 10, '0') AS "RUT Cliente",
    TO_CHAR(NETO, 'FM$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto Neto",
    TO_CHAR(IVA, 'FM$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto iva",
    TO_CHAR(TOTAL, 'FM$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.''') AS "Total Factura",
    CASE
        WHEN TOTAL <= 50000 THEN 'Bajo'
        WHEN TOTAL <= 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",
    CASE CODPAGO
        WHEN 1 THEN 'EFECTIVO'
        WHEN 2 THEN 'TARJETA DEBITO'
        WHEN 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de pago"
FROM FACTURA
WHERE FECHA >= ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12)
  AND FECHA < TRUNC(SYSDATE, 'YYYY')
ORDER BY FECHA DESC, NETO DESC;


SELECT
    LPAD(RUTCLIENTE, 11, '*') AS "RUT",
    INITCAP(NOMBRE) AS "Cliente",
    NVL(TO_CHAR(TELEFONO), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(CODCOMUNA), 'Sin comuna') AS "COMUNA",
    ESTADO AS "ESTADO",
    CASE
        WHEN SALDO / CREDITO < 0.5 THEN
            'Bueno (' ||
            TO_CHAR(
                CREDITO - SALDO,
                'FM$999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ')'
        WHEN SALDO / CREDITO <= 0.8 THEN
            'Regular (' ||
            TO_CHAR(
                SALDO,
                'FM$999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ')'
        ELSE 'Crítico'
    END AS "Estado Crédito",
    NVL(
        UPPER(SUBSTR(MAIL, INSTR(MAIL, '@') + 1)),
        'Correo no registrado'
    ) AS "Dominio Correo"
FROM CLIENTE
WHERE ESTADO = 'A'
  AND CREDITO > 0
ORDER BY NOMBRE ASC;


SELECT
    CODPRODUCTO AS "ID",
    INITCAP(DESCRIPCION) AS "Descripción de Producto",
    CASE
        WHEN VALORCOMPRADOLAR IS NULL THEN 'Sin registro'
        WHEN VALORCOMPRADOLAR = TRUNC(VALORCOMPRADOLAR) THEN
            TO_CHAR(VALORCOMPRADOLAR, 'FM999990') || ' USD'
        ELSE
            TO_CHAR(
                VALORCOMPRADOLAR,
                'FM999990D99',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ' USD'
    END AS "Compra en USD",
    CASE
        WHEN VALORCOMPRADOLAR IS NULL THEN 'Sin registro'
        ELSE
            '$' || TO_CHAR(
                ROUND(VALORCOMPRADOLAR * &TIPOCAMBIO_DOLAR),
                'FM999G999G990',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ' PESOS'
    END AS "USD convertido",
    TOTALSTOCK AS "Stock",
    CASE
        WHEN TOTALSTOCK IS NULL THEN 'Sin datos'
        WHEN TOTALSTOCK < &UMBRAL_BAJO
            THEN '¡ALERTA stock muy bajo!'
        WHEN TOTALSTOCK BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO
            THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE
        WHEN TOTALSTOCK > 80 THEN
            '$' || TO_CHAR(
                ROUND(VUNITARIO * 0.90),
                'FM999G999G990',
                'NLS_NUMERIC_CHARACTERS='',.'''
            )
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM PRODUCTO
WHERE UPPER(DESCRIPCION) LIKE '%ZAPATO%'
  AND UPPER(PROCEDENCIA) = 'I'
ORDER BY CODPRODUCTO DESC;