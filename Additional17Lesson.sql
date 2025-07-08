1. Связь данных с крепостью: Обходной путь vs. Прямая связь

    Проблема: Исходная схема не имела очевидной связи между атакой (в локации) и крепостью.

    Мое решение:
    Пришлось конструировать сложный "мост" для установления связи, объединяя несколько неполных путей.

        -- Пример из моего решения:
        WITH FortressLocations_CTE AS (
            -- Путь через тренировки
            SELECT ms.fortress_id, st.location_id FROM MILITARY_SQUADS ms JOIN SQUAD_TRAINING st ON ms.squad_id = st.squad_id
            UNION
            -- Путь через проекты
            SELECT w.fortress_id, l.location_id FROM WORKSHOPS w JOIN PROJECTS p ON w.workshop_id = p.workshop_id ...
            UNION
            -- Путь через военные посты
            SELECT ms.fortress_id, mst.location_id FROM MILITARY_SQUADS ms JOIN MILITARY_STATIONS mst ON ms.squad_id = mst.squad_id
        )

    Эталонное решение:
    Предполагает, что в таблице locations уже есть прямая или легко выводимая связь с крепостью, поэтому JOIN выглядит тривиально.

        -- Пример из эталонного решения:
        FROM locations l
        LEFT JOIN creature_attacks ca ON l.zone_id = ca.location_id -- Предполагает, что эта связь уже достаточна.
        -- Эталон не тратит усилия на обходные пути, так как исходит из идеальной схемы.

2. Глубина анализа: Расчет эвристик

    Проблема: Как оценить боеготовность отряда?

    Мое решение (Простая эвристика):
    Формула основана на 2-3 легкодоступных параметрах: средний навык, качество снаряжения и исторический % побед.

        -- Пример из моего решения:
        readiness_score = ( (AVG(ds.level) / 20.0) * 0.5 + (AVG(de.quality) / 10.0) * 0.3 + (AVG(...) * 0.2) )

    Эталонное решение (Комплексная эвристика):
    Формула включает 4 взвешенных компонента, включая фактор "свежести" тренировок.

        -- Пример из эталонного решения:
        combat_effectiveness = ROUND(
            (mr.successful_defenses / NULLIF(mr.battles_participated, 0) * 0.4) + -- Историческая эффективность
            (mr.avg_combat_skill / 10 * 0.3) +                                -- Навык
            (mr.avg_equipment_quality / 5 * 0.2) +                            -- Снаряжение
            (CASE WHEN mr.days_since_training < 7 THEN 1.0 ... END * 0.1)     -- Свежесть тренировок
        , 2)

3. Широта анализа: Вторичные факторы

    Проблема: Какие еще факторы влияют на безопасность?

    Мое решение:
    Анализ ограничен данными из предоставленной схемы. Внешние факторы, такие как погода, отсутствуют.

    Эталонное решение:
    Включает в анализ данные из таблиц, которых не было в исходной схеме, и ищет неочевидные связи.

        -- Пример из эталонного решения:
        -- Присоединение данных о погоде и фазах луны
        FROM creature_attacks ca
        ...
        JOIN weather_records w ON DATE_TRUNC('day', ca.date) = w.date
        JOIN moon_phases mp ON DATE_TRUNC('day', ca.date) = mp.date
        ...
        -- Расчет корреляции
        SELECT CORR(sap.attack_count, sap.temperature) AS correlation_value ...

        Мое решение не содержит подобных JOIN-ов и расчетов, так как соответствующих таблиц не было указано полей.

4. Структура итогового вывода: Агрегация по крепостям vs. Глобальный отчет

    Проблема: Как представить итоговый результат?

    Мое решение (Список по крепостям):

        -- Пример из моего решения:
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT( 'fortress_id', f.fortress_id, ...
                'vulnerability_analysis', (SELECT ... FROM Vulnerability_CTE v WHERE v.fortress_id = f.fortress_id)
            ...
            )
        )
        FROM FORTRESSES f ...

    Эталонное решение (Единый глобальный отчет):

        -- Пример из эталонного решения:
        SELECT
            ...
            JSON_OBJECT(
                'threat_assessment', (SELECT ... FROM ...),
                'vulnerability_analysis', (SELECT ... FROM zone_vulnerability ... LIMIT 10)
                ...
            )
        FROM (SELECT 1) AS dummy; -- Запрос не итерирует по крепостям
