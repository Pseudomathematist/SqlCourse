WITH
fortress_locations AS (
    SELECT ms.fortress_id, st.location_id
    FROM MILITARY_SQUADS ms
    JOIN SQUAD_TRAINING st ON ms.squad_id = st.squad_id
    WHERE st.location_id IS NOT NULL
    UNION
    SELECT w.fortress_id, l.location_id
    FROM WORKSHOPS w
    JOIN PROJECTS p ON w.workshop_id = p.workshop_id
    JOIN PROJECT_ZONES pz ON p.project_id = pz.project_id
    JOIN LOCATIONS l ON pz.zone_id = l.zone_id
    WHERE l.location_id IS NOT NULL
    UNION
    SELECT ms.fortress_id, mst.location_id
    FROM MILITARY_SQUADS ms
    JOIN MILITARY_STATIONS mst ON ms.squad_id = mst.squad_id
    WHERE mst.location_id IS NOT NULL
),
security_by_year AS (
    SELECT
        fl.fortress_id,
        EXTRACT(YEAR FROM ca.date) AS year,
        COUNT(ca.attack_id) AS total_attacks,
        SUM(ca.casualties) AS total_dwarf_casualties,
        SUM(ca.enemy_casualties) AS total_enemy_casualties,
        AVG(CASE WHEN ca.outcome = 'Victory' THEN 1 ELSE 0 END) * 100 AS defense_success_rate
    FROM CREATURE_ATTACKS ca
    JOIN fortress_locations fl ON ca.location_id = fl.location_id
    GROUP BY fl.fortress_id, year
),
security_year_comparison AS (
    SELECT
        fortress_id, year, total_attacks, total_dwarf_casualties, total_enemy_casualties, defense_success_rate,
        (defense_success_rate - LAG(defense_success_rate, 1, defense_success_rate) OVER (PARTITION BY fortress_id ORDER BY year)) AS year_over_year_improvement,
        (total_dwarf_casualties - LAG(total_dwarf_casualties, 1, total_dwarf_casualties) OVER (PARTITION BY fortress_id ORDER BY year)) AS casualties_change
    FROM security_by_year
),
military_readiness AS (
    SELECT
        ms.fortress_id, ms.squad_id, ms.name AS squad_name, ms.leader_id,
        COUNT(sm.dwarf_id) AS active_members,
        AVG(ds.level) AS avg_combat_skill,
        AVG(de.quality) AS avg_equipment_quality,
        (
            (COALESCE(AVG(ds.level), 1) / 20.0) * 0.5 +
            (COALESCE(AVG(de.quality), 1) / 10.0) * 0.3 +
            (AVG(CASE WHEN sb.outcome = 'Victory' THEN 1 ELSE 0.5 END)) * 0.2
        ) AS readiness_score,
        AVG(CASE WHEN sb.outcome = 'Victory' THEN 1 ELSE 0 END) * 100 AS combat_effectiveness,
        (
            SELECT JSON_ARRAYAGG(d.name)
            FROM SQUAD_MEMBERS sm_inner
            JOIN DWARVES d ON sm_inner.dwarf_id = d.dwarf_id
            WHERE sm_inner.squad_id = ms.squad_id AND sm_inner.exit_date IS NULL
        ) AS member_names
    FROM MILITARY_SQUADS ms
    LEFT JOIN SQUAD_MEMBERS sm ON ms.squad_id = sm.squad_id AND sm.exit_date IS NULL
    LEFT JOIN DWARVES d ON sm.dwarf_id = d.dwarf_id
    LEFT JOIN DWARF_SKILLS ds ON d.dwarf_id = ds.dwarf_id AND ds.category = 'Combat'
    LEFT JOIN DWARF_EQUIPMENT de ON d.dwarf_id = de.dwarf_id
    LEFT JOIN SQUAD_BATTLES sb ON ms.squad_id = sb.squad_id
    GROUP BY ms.fortress_id, ms.squad_id, ms.name, ms.leader_id
),
zone_vulnerability AS (
    SELECT
        fl.fortress_id, l.zone_id, l.name AS zone_name,
        (
            (COUNT(ca.attack_id) + COUNT(CASE WHEN ca.outcome = 'Defeat' THEN 5 END)) /
            (1.0 + l.fortification_level + l.trap_density + l.wall_integrity)
        ) * COALESCE(AVG(ca.military_response_time_minutes), 500) AS vulnerability_score,
        COUNT(CASE WHEN ca.outcome = 'Defeat' THEN 1 END) AS historical_breaches,
        l.fortification_level, l.choke_points,
        (
            SELECT JSON_ARRAYAGG(mst.squad_id)
            FROM MILITARY_STATIONS mst
            WHERE mst.location_id = l.location_id
        ) AS covering_squad_ids,
        (
            SELECT JSON_ARRAYAGG(dst.structure_id)
            FROM DEFENSE_STRUCTURES dst
            WHERE dst.location_id = l.location_id
        ) AS defense_structure_ids
    FROM fortress_locations fl
    JOIN LOCATIONS l ON fl.location_id = l.location_id
    LEFT JOIN CREATURE_ATTACKS ca ON l.location_id = ca.location_id
    GROUP BY fl.fortress_id, l.zone_id, l.name, l.fortification_level, l.choke_points, l.wall_integrity, l.location_id
),
effectiveness_against_creatures AS (
    SELECT
        fl.fortress_id,
        c.type AS enemy_type,
        COUNT(ca.attack_id) AS total_encounters,
        AVG(CASE WHEN ca.outcome = 'Victory' THEN 1 ELSE 0 END) * 100 AS success_rate,
        AVG(ca.casualties) AS avg_dwarf_casualties,
        AVG(ca.enemy_casualties) AS avg_enemy_casualties
    FROM CREATURE_ATTACKS ca
    JOIN CREATURES c ON ca.creature_id = c.creature_id
    JOIN fortress_locations fl ON ca.location_id = fl.location_id
    GROUP BY fl.fortress_id, c.type
),
seasonal_attack_statistics AS (
    SELECT
        fl.fortress_id,
        CASE
            WHEN EXTRACT(MONTH FROM ca.date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM ca.date) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM ca.date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END AS season,
        COUNT(ca.attack_id) AS number_of_attacks
    FROM CREATURE_ATTACKS ca
    JOIN fortress_locations fl ON ca.location_id = fl.location_id
    GROUP BY fl.fortress_id, season
),
fortress_statistics AS (
    SELECT
        fl.fortress_id,
        COUNT(DISTINCT ca.attack_id) AS total_recorded_attacks,
        COUNT(DISTINCT ca.creature_id) AS unique_attackers,
        AVG(CASE WHEN ca.outcome = 'Victory' THEN 1 ELSE 0 END) * 100 AS overall_defense_success_rate
    FROM fortress_locations fl
    LEFT JOIN CREATURE_ATTACKS ca ON fl.location_id = ca.location_id
    GROUP BY fl.fortress_id
)

SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'fortress_id', f.fortress_id,
        'fortress_name', f.name,
        'population', f.population,
        'founded_year', f.founded_year,
        'report_generated_at', NOW(),
        
        'overall_summary', JSON_OBJECT(
            'total_recorded_attacks', COALESCE(fs.total_recorded_attacks, 0),
            'unique_attacker_types', COALESCE(fs.unique_attackers, 0),
            'overall_defense_success_rate', COALESCE(fs.overall_defense_success_rate, 100.0)
        ),

        'security_analysis', JSON_OBJECT(
            'threat_assessment', (
                SELECT JSON_OBJECT(
                    'current_threat_level', CASE
                        WHEN MAX(c.threat_level) >= 5 THEN 'CRITICAL'
                        WHEN MAX(c.threat_level) >= 3 THEN 'High'
                        WHEN MAX(c.threat_level) > 0 THEN 'Moderate'
                        ELSE 'Low'
                    END,
                    'active_threats', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'creature_type', c.type,
                                'threat_level', c.threat_level,
                                'last_sighting_date', MAX(cs.date),
                                'territory_proximity', MIN(ct.distance_to_fortress)
                            )
                        )
                        FROM CREATURES c
                        LEFT JOIN CREATURE_SIGHTINGS cs ON c.creature_id = cs.creature_id
                        LEFT JOIN CREATURE_TERRITORIES ct ON c.creature_id = ct.creature_id
                        WHERE c.active = TRUE
                        GROUP BY c.type, c.threat_level
                    )
                )
                FROM CREATURES
                WHERE active = TRUE
            ),
            'vulnerability_analysis', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'zone_id', zv.zone_id,
                        'zone_name', zv.zone_name,
                        'vulnerability_score', zv.vulnerability_score,
                        'historical_breaches', zv.historical_breaches,
                        'fortification_level', zv.fortification_level,
                        'choke_points', zv.choke_points,
                        'covering_squad_ids', zv.covering_squad_ids,
                        'defense_structure_ids', zv.defense_structure_ids
                    )
                )
                FROM zone_vulnerability zv
                WHERE zv.fortress_id = f.fortress_id
                ORDER BY zv.vulnerability_score DESC
                LIMIT 5
            ),
            'effectiveness_vs_enemies', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'enemy_type', ec.enemy_type,
                        'total_encounters', ec.total_encounters,
                        'success_rate', ec.success_rate,
                        'avg_dwarf_casualties', ec.avg_dwarf_casualties,
                        'avg_enemy_casualties', ec.avg_enemy_casualties
                    )
                )
                FROM effectiveness_against_creatures ec
                WHERE ec.fortress_id = f.fortress_id
            ),
            'seasonal_attack_patterns', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT('season', s.season, 'number_of_attacks', s.number_of_attacks)
                )
                FROM seasonal_attack_statistics s
                WHERE s.fortress_id = f.fortress_id
            )
        ),
        'military_readiness_assessment', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'squad_id', mr.squad_id,
                    'squad_name', mr.squad_name,
                    'readiness_score', mr.readiness_score,
                    'leader_id', mr.leader_id,
                    'active_members', mr.active_members,
                    'avg_combat_skill', mr.avg_combat_skill,
                    'avg_equipment_quality', mr.avg_equipment_quality,
                    'combat_effectiveness', mr.combat_effectiveness,
                    'member_names', mr.member_names
                )
            )
            FROM military_readiness mr
            WHERE mr.fortress_id = f.fortress_id
        ),
        'security_evolution_timeline', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'year', s.year,
                    'defense_success_rate', s.defense_success_rate,
                    'total_attacks', s.total_attacks,
                    'dwarf_casualties', s.total_dwarf_casualties,
                    'enemy_casualties', s.total_enemy_casualties,
                    'year_over_year_improvement', s.year_over_year_improvement,
                    'casualties_change', s.casualties_change
                )
            )
            FROM security_year_comparison s
            WHERE s.fortress_id = f.fortress_id
        )
    )
)
FROM FORTRESSES f
LEFT JOIN fortress_statistics fs ON f.fortress_id = fs.fortress_id;
