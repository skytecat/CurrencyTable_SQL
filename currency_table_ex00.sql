WITH users AS (SELECT user_id, SUM(money) AS volume, type, currency_id
    FROM balance
    GROUP BY type, currency_id, user_id),

    cur_rate AS (SELECT DISTINCT currency.id, rate_to_usd AS last_rate_to_usd
                  FROM (SELECT id, MAX(updated) AS updated
                        FROM currency
                        GROUP BY id) last_rate
                           JOIN currency ON currency.updated = last_rate.updated),
    un AS ( SELECT *
            FROM users
            FULL JOIN cur_rate ON cur_rate.id = users.currency_id
    )

SELECT DISTINCT COALESCE("user".name, 'not defined') AS name, COALESCE(lastname, 'not defined') AS lastname, type,
                volume, COALESCE(currency.name, 'not defined') AS currency_name,
                COALESCE(last_rate_to_usd, 1) AS last_rate_to_usd,
                COALESCE(volume * last_rate_to_usd, volume) AS total_volume_in_usd
FROM un
FULL JOIN "user" ON un.user_id = "user".id
LEFT JOIN currency ON un.currency_id = currency.id
ORDER BY name DESC, lastname, type;
