-- INSTALL httpfs;
LOAD httpfs;
-- INSTALL json;
LOAD json;

CREATE OR REPLACE TABLE steam_games AS
SELECT * FROM read_json_auto(
    'steam_2025.json',
    maximum_object_size = 268435456
);


SELECT * FROM steam_games;

DESCRIBE steam_games;


--
-- -- 1. Вказуємо папку для тимчасових файлів (DuckDB створить її сам)
-- -- Це дозволить обробляти дані, більші за вашу RAM
-- PRAGMA temp_directory='./duckdb_temp_storage';
--
-- -- 2. (Опціонально) Обмежуємо RAM, щоб DuckDB раніше почав використовувати диск
-- -- Наприклад, якщо у вас 16GB RAM, поставте ліміт 8GB або 10GB
-- SET memory_limit='8GB';
--
-- -- 3. Вимикаємо збереження порядку вставки (це пришвидшує паралельну обробку)
-- SET preserve_insertion_order=false;




CREATE OR REPLACE TABLE games_parsed AS
SELECT
    -- Витягуємо поля з розгорнутого JSON об'єкта (змінна 'game_item')
    -- Використовуйте json_extract або ->> для доступу до полів
    game_item->>'appid' as appid,
    game_item->>'name' as name,
    game_item->>'price' as price,
    game_item->>'developer' as developer,
    game_item->>'publisher' as publisher,
    game_item->>'score' as score
FROM (
    SELECT unnest(games) as game_item
    FROM steam_games
);

-- ---------    PARSING   ---------------
CREATE OR REPLACE TABLE steam_analytics_ready AS
SELECT
    g.appid,
    g.app_details.data.name AS game_name,
    COALESCE(g.app_details.data.price_overview.final / 100.0, 0) AS price_usd,
    COALESCE(g.app_details.data.price_overview.discount_percent, 0) AS discount_pct,
    g.app_details.data.is_free AS is_free,

    COALESCE(
        try_strptime(g.app_details.data.release_date.date, '%b %d, %Y'),
        try_strptime(g.app_details.data.release_date.date, '%d %b, %Y'),
        try_strptime(g.app_details.data.release_date.date, '%Y')
    ) AS release_date,

    g.app_details.data.developers AS developers_list,
    CAST(COALESCE(g.app_details.data.required_age::INT, 0) AS INT) AS required_age,
    list_transform(g.app_details.data.genres, x -> x.description) AS genres_list

FROM (SELECT unnest(games) AS g
         FROM steam_games);

-- ----------------------------------------


select * from steam_analytics_ready
limit 100;




-- ----- 1st INSIGHT: Average Price & Count by Genre-----
SELECT
    CASE
        WHEN t.genre IN ('Симуляторы', 'Simulação', 'Simülasyon', 'Simulation') THEN 'Simulation'
        WHEN t.genre IN ('Экшены', 'Acción', 'Ação', 'Aksiyon', 'Action') THEN 'Action'
        WHEN t.genre IN ('Инди', 'Indépendant', 'Indie') THEN 'Indie'
        WHEN t.genre IN ('Aventura', 'Adventure') THEN 'Adventure'
        WHEN t.genre IN ('Strateji', 'Strategy') THEN 'Strategy'
        WHEN t.genre IN ('Deportes', 'Sports') THEN 'Sports'
        WHEN t.genre IN ('Carreras', 'Racing') THEN 'Racing'
        WHEN t.genre IN ('Multijogador Massivo', 'Massively Multiplayer') THEN 'Massively Multiplayer'
        ELSE t.genre
    END AS clean_genre,
    ROUND(AVG(games.price_usd), 2) AS average_price,
    COUNT(*) AS games_count
FROM steam_analytics_ready AS games
CROSS JOIN UNNEST(games.genres_list) AS t(genre)
GROUP BY clean_genre
ORDER BY average_price DESC;

-- Interpretation:
--Niche categories like 'Animation & Modeling' command the highest average prices ($36.84)
-- despite low release volumes. Conversely, mass-market genres like 'Action' and 'Indie' are
-- the most saturated and affordable, averaging around $6.00 per title.


-- ----- 2nd INSIGHT: Game Releases Over Time -----
SELECT
    EXTRACT(year FROM release_date) AS release_year,
    COUNT(*) AS games_count,
    ROUND(AVG(price_usd), 2) AS average_price,
FROM steam_analytics_ready
WHERE EXTRACT(year FROM release_date) <2026
GROUP BY release_year
ORDER BY release_year;

-- Interpretation:
-- The dataset reveals exponential growth in Steam releases, rising from single digits
-- to over 1,000 titles annually in 2024–2025, with a notable average price spike in 2018.

-- ----- 3rd INSIGHT:  -----
SELECT
    required_age,
    COUNT(*) AS games_count
FROM steam_analytics_ready
GROUP BY required_age
ORDER BY required_age ASC;

-- Interpretation:
-- Over 98% of titles have no specific age rating (0), indicating that games explicitly
-- restricted to mature audiences (17+ or 18+) make up a very small fraction of the library.


-- ----- 4th INSIGHT: top 20 developers (num of games) -----

SELECT
    t.developer as developer,
    COUNT(*) AS games_count
FROM steam_analytics_ready AS games
CROSS JOIN UNNEST(games.developers_list) AS t(developer)
GROUP BY t.developer
ORDER BY games_count DESC
LIMIT 20;

-- Interpretation:
-- The list is led by studios releasing frequent content or utilities (like SmiteWorks USA),
-- rather than traditional AAA publishers, showing that quantity of releases
-- does not always equal mainstream fame.

-- ----- 5th INSIGHT: top 20 most expensive games-----

SELECT
    game_name,
    ROUND(price_usd),
    release_date,
    genres_list
FROM steam_analytics_ready
WHERE is_free = false
ORDER BY price_usd DESC
LIMIT 20;

-- Interpretation:
-- The highest-priced item is a 'Europa Universalis IV' pack at $11,000 (likely a bundle or error),
-- confirming that the most expensive titles are usually professional software or
-- anomalies rather than standard games.

-- ----- 6th INSIGHT: Free vs Paid  -----
SELECT
    CASE
        WHEN is_free = true THEN 'Free'
        ELSE 'Paid'
    END AS business_model,
    COUNT(*) AS games_count,
FROM steam_analytics_ready
GROUP BY business_model
ORDER BY games_count DESC;

-- Interpretation:
-- Paid games dominate the marketplace, accounting for over 80% of the dataset (7,068 titles),
-- while Free-to-Play remains a significant but smaller segment (1,643 titles).
