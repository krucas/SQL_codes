SELECT
    account_id,
    count(trans_id) as amount
FROM trans
GROUP BY account_id
ORDER BY 2 DESC;

/*  poskytnutých úvěrů
Napište dotaz, který připraví souhrn poskytnutých půjček v následujících dimenzích:

rok, čtvrtletí, měsíc,
rok, čtvrtletí,
rok,
celkový.
Jako výsledek souhrnu zobrazit následující informace:

celková výše půjček,
průměrná výše půjčky,
celkový počet poskytnutých úvěrů.


 */
SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(QUARTER FROM date) AS quarter,
EXTRACT(MONTH FROM date) AS monht
FROM loan
GROUP BY 1, 2, 3;


SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(QUARTER FROM date) AS quarter,
EXTRACT(MONTH FROM date) AS monht
FROM loan
GROUP BY 1, 2, 3 WITH ROLLUP;





-- rok, čtvrtletí, měsíc,
SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(QUARTER FROM date) AS quarter,
EXTRACT(MONTH FROM date) AS monht
FROM loan
GROUP BY date, date, date WITH ROLLUP ;

SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(QUARTER FROM date) AS quarter
FROM loan
GROUP BY date, date WITH ROLLUP
ORDER BY date;



-- celkový.

SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(QUARTER FROM date) AS quarter,
EXTRACT(MONTH FROM date) AS month,
COUNT(payments),
SUM(payments),
AVG(payments)
FROM loan
GROUP BY year, quarter, month WITH ROLLUP
ORDER BY 1,2,3;

SELECT COUNT(loan.loan_id) FROM loan;

-- celková výše půjček,
SELECT SUM(loan.amount) FROM loan;
-- 103261740

-- průměrná výše půjčky,
SELECT AVG(loan.amount) FROM loan;
-- 151410.1760

-- celkový počet poskytnutých úvěrů.
SELECT COUNT(loan.amount) FROM loan;
-- 682



-- Stav půjčky
--  které stavy představují splacené půjčky a které představují nesplacené půjčky.
SELECT status,
       COUNT(status)  FROM loan
GROUP BY status
ORDER BY 1;

A,203
B,31
C,403
D,45


-- spatne reseni a postup, dlouho mi trvalo najit cestu, domnival jsem se, ze tam jsou jenom uvery, po delsim
-- zkoumani, tam bylo vice druhu transakce, tato metoda sla tedy stranou.
SELECT l.account_id, MAX(t.balance), l.amount FROM trans AS t
JOIN loan AS l USING (account_id)
GROUP BY  l.amount, l.account_id ;


-- Analýza účtů
-- Napište dotaz, který seřadí účty podle následujících kritérií:

počet daných úvěrů (klesající),
výše poskytnutých úvěrů (klesající),
průměrná výše půjčky,
-- V úvahu se berou pouze plně splacené půjčky.

WITH cte AS (
SELECT account_id,
       ROUND(AVG(amount),0) as AVG_amount,
       SUM(amount) AS SUM_amount,
       COUNT(amount) AS COUNT_amount
FROM loan
WHERE status IN ('A', 'C')
GROUP BY account_id
)
SELECT *,
       ROW_number() OVER ( ORDER BY cte.SUM_amount DESC) AS rank_sum_amount,
       ROW_number() OVER ( ORDER BY cte.COUNT_amount DESC) AS rank_count_amount
FROM cte;



SELECT loan.account_id, count(loan_id),
ROW_number() OVER (PARTITION BY loan_id ORDER BY loan_id DESC) AS row_num
FROM loan
GROUP BY loan.account_id;

SELECT COUNT(loan_id), loan_id
FROM loan
WHERE status IN ('A', 'C')
GROUP BY loan_id
ORDER BY COUNT(loan_id) DESC;

SELECT amount FROM loan
              WHERE status IN ('A', 'C')
ORDER By amount DESC;


SELECT AVG(amount) FROM loan
ORDER By amount DESC;

/*
Plně splacené půjčky
Zjistěte zůstatek splacených úvěrů rozdělený podle pohlaví klienta.

Kromě toho použijte metodu podle svého výběru ke kontrole správnosti dotazu.
*/

SELECT c.gender,
t.account_id

FROM client AS c
                             JOIN disp AS d ON c.client_id = d.client_id
                             JOIN trans AS t ON d.account_id = t.account_id
GROUP BY c.gender, t.account_id;

DROP TABLE IF EXISTS tmp_results;
CREATE TEMPORARY TABLE tmp_results AS

SELECT c.gender, SUM(l.amount) AS amount FROM loan as l
         JOIN account as a USING (account_id)
         JOIN disp as d USING (account_id)
         JOIN client as c USING (client_id)
WHERE l.status IN ('A', 'C') AND d.type = 'OWNER'
GROUP BY c.gender ;

WITH cte as (
    SELECT sum(amount) as amount
    FROM loan AS l
    WHERE l.status IN ('A', 'C')
)
SELECT (SELECT SUM(amount) FROM tmp_results) - (SELECT amount FROM cte)



SELECT account_id, SUM(balance) FROM trans
WHERE type = 'PRIJEM'
GROUP BY account_id;

SELECT loan.account_id, SUM(loan.amount)
FROM loan
GROUP BY loan.account_id;

-- Analyza klienta - cast 1
-- kdo ma vice splacenych pujcek - zeny nebo muzi?


SELECT c.gender, SUM(l.amount) AS amount, AVG(c.birth_date) FROM loan as l
         JOIN account as a USING (account_id)
         JOIN disp as d USING (account_id)
         JOIN client as c USING (client_id)
WHERE l.status IN ('A', 'C') AND d.type = 'OWNER'
GROUP BY c.gender ;

M,43256388
F,44425200

-- jaky je prumerny vek dluznika rozdeleny podle pohlavi.
DROP TABLE IF EXISTS tmp_part_one;
CREATE TEMPORARY TABLE tmp_part_one AS
SELECT c.gender, SUM(l.amount) AS sum_amount,
       COUNT(l.amount) as count_amount,
       ROUND(AVG(2025 - EXTRACT(YEAR FROM c.birth_date)), 1) AS avg_age
FROM loan as l
         JOIN account as a USING (account_id)
         JOIN disp as d USING (account_id)
         JOIN client as c USING (client_id)
WHERE TRUE  AND l.status IN ('A', 'C') AND d.type = 'OWNER'
GROUP BY c.gender ;


SELECT SUM(count_amount) FROM tmp_part_one;

SELECT
    gender,
    SUM(count_amount) as count_amount
FROM tmp_part_one
GROUP BY gender;

SELECT
    gender,
    ROUND(avg(avg_age),1) as count_amount
FROM tmp_part_one
GROUP BY gender;

SELECT client.birth_date, client.birth_date - (SELECT NOW()) FROM client;
SELECT 2025 - EXTRACT(YEAR FROM client.birth_date)  FROM client;

SELECT @jirkuv_test;

/*
Analýza klienta - část 2
Proveďte analýzy, které odpovídají na otázky:

která oblast má nejvíce klientů,
ve které oblasti bylo vyplaceno nejvíce úvěrů,
ve které oblasti byla vyplacena nejvyšší částka úvěrů.
Jako klienty vyberte pouze vlastníky účtů.
*/

SELECT  COUNT(A3) AS oblast, A3 FROM district
GROUP BY A3
ORDER BY oblast DESC;

SELECT   A3, COUNT(c.district_id) AS client  FROM district d
                                JOIN client c USING (district_id)
GROUP BY A3
ORDER BY client DESC;
-- nejvic klientu ma  south Moravia,937


-- ve které oblasti bylo vyplaceno nejvíce úvěrů,

DROP TABLE IF EXISTS tmp_district_analytics;

CREATE TEMPORARY TABLE tmp_district_analytics AS
SELECT A2,
    d.district_id,
         COUNT(DISTINCT c.client_id) pocet_klientu,
         SUM(amount) AS celkova_vyse,
         COUNT(amount) AS pocet_pujcek
                                FROM district d
                                JOIN client c USING (district_id)
                                JOIN account a USING (district_id)
                                JOIN loan l USING (account_id)
                                JOIN disp de USING (client_id)
WHERE de.type = 'OWNER' AND l.status IN ('A', 'B')
GROUP BY d.district_id
ORDER BY pocet_pujcek DESC;

-- která oblast má nejvíce klientů,
SELECT * FROM tmp_district_analytics
ORDER BY pocet_klientu DESC;
-- Hl.m. Praha,1,547,1991386320,20239

-- ve které oblasti bylo vyplaceno nejvíce úvěrů,
SELECT * FROM tmp_district_analytics
ORDER BY celkova_vyse DESC;

-- ve které oblasti byla vyplacena nejvyšší částka úvěrů
SELECT * FROM tmp_district_analytics
ORDER BY pocet_pujcek DESC;

SELECT account_id
FROM loan;

/*
Analýza klienta - část 3
Použijte dotaz vytvořený v předchozí úloze a upravte jej,
abyste určili procento každého okresu na celkové výši poskytnutých půjček.

Ukázkový výsledek:

*/
WITH cte AS (SELECT A2,
                    d.district_id,
                    COUNT(DISTINCT c.client_id) pocet_klientu,
                    SUM(amount)   AS            celkova_vyse,
                    COUNT(amount) AS            pocet_pujcek
             FROM district d
                      JOIN client c USING (district_id)
                      JOIN account a USING (district_id)
                      JOIN loan l USING (account_id)
                      JOIN disp de USING (client_id)
             WHERE de.type = 'OWNER'
               AND l.status IN ('A', 'B')
             GROUP BY d.district_id
             ORDER BY pocet_pujcek DESC)

SELECT *,
       celkova_vyse / SUM(celkova_vyse) OVER() AS diff
    FROM cte
    ORDER BY diff DESC;



SELECT A2, celkova_vyse, pocet_pujcek , (pocet_pujcek / celkova_vyse ) * 100  AS diff
FROM tmp_district_analytics
ORDER BY diff DESC;


/*
 Výběr klienta
Zkontrolujte databázi klientů, kteří splňují následující výsledky:

jejich zůstatek na účtu je vyšší než 1000,
mají více než 5 půjček,
se narodili po roce 1990.
A předpokládáme, že zůstatek na účtu je loan amount- payments
 */



SELECT COUNT(DISTINCT(account_id)) FROM loan;
SELECT * FROM client
WHERE birth_date > '1985-01-01';

SELECT account_id, SUM(amount), SUM(payments), SUM(amount - payments) FROM loan
GROUP BY account_id;



SELECT t.account_id, MAX(balance) AS balance FROM trans t
                                JOIN loan l USING (account_id)
GROUP BY l.account_id
WHERE t.balance > 1000 AND (SELECT account_id FROM loan
WHERE loan_id > 5);


SELECT client_id,
       SUM(amount - payments) AS client_balance,
    COUNT(l.loan_id) AS vyse_pujcky
FROM loan as l
JOIN account as a USING (account_id)
JOIN disp as d USING (account_id)
JOIN client as c USING (client_id)
WHERE TRUE
AND l.status IN ('A', 'c')
AND d.type = 'OWNER'
AND birth_date > '1975-01-01'
GROUP BY client_id
HAVING SUM(amount - payments) > 1000
AND count(loan_id) > 5



/*
 Končící karty
Napište proceduru pro obnovení vámi vytvořené tabulky (můžete ji nazvat např. cards_at_expiration) obsahující následující sloupce:

ID klienta,
ID karty,
datum expirace – předpokládáme, že karta může být aktivní 3 roky od data vydání,
adresa klienta ( A3stačí sloupec).
Poznámka: Tabulka cardobsahuje karty, které byly vydány do konce roku 1998.
 */

DROP PROCEDURE IF EXISTS cards_at_expiration_report;
DELIMITER $$
CREATE PROCEDURE cards_at_expiration_report(p_date DATE)
BEGIN
    TRUNCATE TABLE fcards_at_expiration;
    INSERT INTO fcards_at_expiration
        WITH cte AS (SELECT
                    c.client_id,
                    card_id,
                    ADDDATE(issued, INTERVAL 3 YEAR) AS date_expiration,
                    di.A3                               AS client_address,
                    issued AS datum_vydani
             FROM card as ca
                      JOIN disp as d USING (disp_id)
                      JOIN client as c USING (client_id)
                      JOIN district as di USING (district_id))
    SELECT * FROM cte
    WHERE p_date BETWEEN DATE_ADD(date_expiration, INTERVAL -7 DAY) AND date_expiration;

end; $$

DELIMITER ;

CALL cards_at_expiration_report('2001-01-01');



DROP TABLE fcards_at_expiration;
CREATE TABLE fcards_at_expiration
(
    client_id       int                      not null,
    card_id         int default 0            not null,
    date_expiration date                     null,
    A3              varchar(25)              not null,
    datum_vydani    date                     null
);


-- chci videt rozdily.
SELECT issued,
       ADDDATE(issued, INTERVAL 3 YEAR) AS prvni,
       DATE_ADD(issued, INTERVAL 3 YEAR) AS druhy
FROM card;


ADDDATE(issued, INTERVAL 3 YEAR)