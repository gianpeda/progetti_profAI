USE banca;

CREATE TEMPORARY TABLE temp_tabella AS
SELECT 
    c.id_cliente,
    FLOOR(DATEDIFF(CURDATE(), c.data_nascita) / 365.25) AS età,
    COALESCE(tot_usc.nr_trans_uscita, 0) AS nr_trans_uscita,
    COALESCE(tot_entr.nr_trans_entrate, 0) AS nr_trans_entrate,
    COALESCE(tot_usc_amt.importo_totale_uscite, 0) AS importo_totale_uscite,
    COALESCE(tot_entr_amt.importo_totale_entrate, 0) AS importo_totale_entrate,
    COALESCE(nr_conti.nr_conti, 0) AS nr_conti,
    COALESCE(nr_conti_tipo.nr_conti_tipo_base, 0) AS nr_conti_tipo_base,
    COALESCE(nr_conti_tipo.nr_conti_tipo_business, 0) AS nr_conti_tipo_business,
    COALESCE(nr_conti_tipo.nr_conti_tipo_privati, 0) AS nr_conti_tipo_privati,
    COALESCE(nr_conti_tipo.nr_conti_tipo_famiglie, 0) AS nr_conti_tipo_famiglie,
    COALESCE(tot_usc_tipo.acquisto_amazon, 0) AS acquisto_amazon,
    COALESCE(tot_usc_tipo.rata_mutuo, 0) AS rata_mutuo,
    COALESCE(tot_usc_tipo.hotel, 0) AS hotel,
    COALESCE(tot_usc_tipo.biglietto_aereo, 0) AS biglietto_aereo,
    COALESCE(tot_usc_tipo.supermercato, 0) AS supermercato,
    COALESCE(tot_entr_tipo.stipendio, 0) AS stipendio,
    COALESCE(tot_entr_tipo.pensione, 0) AS pensione,
    COALESCE(tot_entr_tipo.dividendi, 0) AS dividendi,
    COALESCE(usc_tip_conto.conto_base, 0) AS usc_conto_base,
    COALESCE(usc_tip_conto.conto_business, 0) AS usc_conto_business,
    COALESCE(usc_tip_conto.conto_privati, 0) AS usc_conto_privati,
    COALESCE(usc_tip_conto.conto_famiglie, 0) AS usc_conto_famiglie,
    COALESCE(entr_tip_conto.conto_base, 0) AS entr_conto_base,
    COALESCE(entr_tip_conto.conto_business, 0) AS entr_conto_business,
    COALESCE(entr_tip_conto.conto_privati, 0) AS entr_conto_privati,
    COALESCE(entr_tip_conto.conto_famiglie, 0) AS entr_conto_famiglie
FROM 
    cliente c
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN id_tipo_trans IN ('3', '4', '5', '6', '7') THEN 1 ELSE 0 END) AS nr_trans_uscita
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_usc ON c.id_cliente = tot_usc.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN id_tipo_trans IN ('0', '1', '2') THEN 1 ELSE 0 END) AS nr_trans_entrate
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_entr ON c.id_cliente = tot_entr.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN importo < 0 THEN trans.importo ELSE 0 END) AS importo_totale_uscite
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_usc_amt ON c.id_cliente = tot_usc_amt.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN importo > 0 THEN trans.importo ELSE 0 END) AS importo_totale_entrate
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_entr_amt ON c.id_cliente = tot_entr_amt.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        COUNT(cont.id_conto) AS nr_conti
    FROM conto cont
    GROUP BY cont.id_cliente
) AS nr_conti ON c.id_cliente = nr_conti.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        COUNT(cont.id_conto) AS nr_conti,
        SUM(CASE WHEN cont.id_tipo_conto = '0' THEN 1 ELSE 0 END) AS nr_conti_tipo_base,
        SUM(CASE WHEN cont.id_tipo_conto = '1' THEN 1 ELSE 0 END) AS nr_conti_tipo_business,
        SUM(CASE WHEN cont.id_tipo_conto = '2' THEN 1 ELSE 0 END) AS nr_conti_tipo_privati,
        SUM(CASE WHEN cont.id_tipo_conto = '3' THEN 1 ELSE 0 END) AS nr_conti_tipo_famiglie
    FROM conto cont
    GROUP BY cont.id_cliente
) AS nr_conti_tipo ON c.id_cliente = nr_conti_tipo.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN trans.id_tipo_trans = '3' THEN 1 ELSE 0 END) AS acquisto_amazon,
        SUM(CASE WHEN trans.id_tipo_trans = '4' THEN 1 ELSE 0 END) AS rata_mutuo,
        SUM(CASE WHEN trans.id_tipo_trans = '5' THEN 1 ELSE 0 END) AS hotel,
        SUM(CASE WHEN trans.id_tipo_trans = '6' THEN 1 ELSE 0 END) AS biglietto_aereo,
        SUM(CASE WHEN trans.id_tipo_trans = '7' THEN 1 ELSE 0 END) AS supermercato
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_usc_tipo ON c.id_cliente = tot_usc_tipo.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN trans.id_tipo_trans = '0' THEN 1 ELSE 0 END) AS stipendio,
        SUM(CASE WHEN trans.id_tipo_trans = '1' THEN 1 ELSE 0 END) AS pensione,
        SUM(CASE WHEN trans.id_tipo_trans = '2' THEN 1 ELSE 0 END) AS dividendi
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS tot_entr_tipo ON c.id_cliente = tot_entr_tipo.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN trans.importo < 0 AND id_tipo_conto = 0 THEN trans.importo ELSE 0 END) AS conto_base,
        SUM(CASE WHEN trans.importo < 0 AND id_tipo_conto = 1 THEN trans.importo ELSE 0 END) AS conto_business,
        SUM(CASE WHEN trans.importo < 0 AND id_tipo_conto = 2 THEN trans.importo ELSE 0 END) AS conto_privati,
        SUM(CASE WHEN trans.importo < 0 AND id_tipo_conto = 3 THEN trans.importo ELSE 0 END) AS conto_famiglie
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS usc_tip_conto ON c.id_cliente = usc_tip_conto.id_cliente
LEFT JOIN (
    SELECT 
        cont.id_cliente,
        SUM(CASE WHEN trans.importo > 0 AND id_tipo_conto = 0 THEN trans.importo ELSE 0 END) AS conto_base,
        SUM(CASE WHEN trans.importo > 0 AND id_tipo_conto = 1 THEN trans.importo ELSE 0 END) AS conto_business,
        SUM(CASE WHEN trans.importo > 0 AND id_tipo_conto = 2 THEN trans.importo ELSE 0 END) AS conto_privati,
        SUM(CASE WHEN trans.importo > 0 AND id_tipo_conto = 3 THEN trans.importo ELSE 0 END) AS conto_famiglie
    FROM conto cont
    INNER JOIN transazioni trans ON cont.id_conto = trans.id_conto
    GROUP BY cont.id_cliente
) AS entr_tip_conto ON c.id_cliente = entr_tip_conto.id_cliente;

SELECT * FROM temp_tabella;