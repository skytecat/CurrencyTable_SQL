WITH past_cur AS (SELECT DISTINCT balance.user_id, balance.money, balance.currency_id, name, balance.updated, MAX(currency.updated) AS min
                  FROM balance
                           JOIN currency ON currency.id = balance.currency_id
                  WHERE currency.updated < balance.updated
                  GROUP BY 1, 2, 3, 4, 5),
fut_cur AS (SELECT DISTINCT balance.user_id, balance.money, balance.currency_id, name, balance.updated, MIN(currency.updated) AS max
            FROM balance
                     JOIN currency ON currency.id = balance.currency_id
            WHERE currency.updated > balance.updated
            GROUP BY 1, 2, 3, 4, 5),
join_cur AS(SELECT COALESCE(p.user_id, f.user_id) AS user_id, COALESCE(p.money, f.money) AS money, COALESCE(p.currency_id, f.currency_id) AS currency_id, COALESCE(p.min, f.max) AS upd
            FROM past_cur p
                FULL JOIN fut_cur f ON p.user_id = f.user_id AND p.money = f.money AND p.currency_id = f.currency_id AND p.updated = f.updated)
SELECT DISTINCT COALESCE(u.name, 'not defined') AS name, COALESCE(u.lastname, 'not defined') AS lastname, c.name AS currency_name, money * rate_to_usd AS currency_in_usd
FROM join_cur j
    LEFT JOIN "user" u ON user_id = u.id
    JOIN currency c ON c.updated = j.upd AND j.currency_id = c.id
ORDER BY name DESC, lastname, currency_name;
