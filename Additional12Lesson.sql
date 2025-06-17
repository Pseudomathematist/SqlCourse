WITH squad_battle_stats AS (
    SELECT
        squad_id,
        COUNT(report_id) AS total_battles,
        SUM(CASE WHEN outcome = 'Victory' THEN 1 ELSE 0 END) AS victories,
        SUM(casualties) AS total_squad_casualties,
        SUM(enemy_casualties) AS total_enemy_casualties
    FROM SQUAD_BATTLES
    GROUP BY squad_id
),

squad_member_stats AS (
    SELECT
        squad_id,
        COUNT(DISTINCT dwarf_id) AS total_members_ever,
        COUNT(DISTINCT CASE WHEN exit_date IS NULL THEN dwarf_id END) AS current_members
    FROM SQUAD_MEMBERS
    GROUP BY squad_id
),

squad_equipment_quality AS (
    SELECT
        se.squad_id,
        AVG(e.quality::DECIMAL) AS avg_equipment_quality
    FROM SQUAD_EQUIPMENT se
    JOIN EQUIPMENT e ON se.equipment_id = e.equipment_id
    GROUP BY se.squad_id
),

squad_training_stats AS (
    SELECT
        squad_id,
        COUNT(schedule_id) AS total_training_sessions,
        AVG(effectiveness) AS avg_training_effectiveness
    FROM SQUAD_TRAINING
    GROUP BY squad_id
),

member_skill_progress AS (
    SELECT
        sm.squad_id,
        AVG(ds.level - LAG(ds.level, 1, ds.level) OVER (PARTITION BY ds.dwarf_id, ds.skill_id ORDER BY ds.date)) AS avg_skill_improvement
    FROM DWARF_SKILLS ds
    JOIN SKILLS s ON ds.skill_id = s.skill_id
    JOIN SQUAD_MEMBERS sm ON ds.dwarf_id = sm.dwarf_id
    WHERE s.category = 'Combat'
    GROUP BY sm.squad_id
)

SELECT
    ms.squad_id,
    ms.name AS squad_name,
    ms.formation_type,
    d.name AS leader_name,
    COALESCE(sbs.total_battles, 0) AS total_battles,
    COALESCE(sbs.victories, 0) AS victories,
    ROUND(COALESCE(sbs.victories::DECIMAL / NULLIF(sbs.total_battles, 0) * 100, 0), 2) AS victory_percentage,
    ROUND(COALESCE(sbs.total_squad_casualties::DECIMAL / NULLIF(sms.total_members_ever, 0) * 100, 0), 2) AS casualty_rate,
    ROUND(COALESCE(sbs.total_enemy_casualties::DECIMAL / NULLIF(sbs.total_squad_casualties, 0), 0), 2) AS casualty_exchange_ratio,
    sms.current_members,
    sms.total_members_ever,
    ROUND(COALESCE(sms.current_members::DECIMAL / NULLIF(sms.total_members_ever, 0) * 100, 0), 2) AS retention_rate,
    ROUND(COALESCE(seq.avg_equipment_quality, 0), 2) AS avg_equipment_quality,
    COALESCE(sts.total_training_sessions, 0) AS total_training_sessions,
    ROUND(COALESCE(sts.avg_training_effectiveness, 0), 2) AS avg_training_effectiveness,
    ROUND(COALESCE(msp.avg_skill_improvement, 0), 2) AS avg_combat_skill_improvement,
    ROUND(
        COALESCE(
            (sbs.victories::DECIMAL / NULLIF(sbs.total_battles, 1)) * 0.4 +
            (LEAST(sbs.total_enemy_casualties::DECIMAL / NULLIF(sbs.total_squad_casualties, 1), 5) / 5.0) * 0.3 +
            (sms.current_members::DECIMAL / NULLIF(sms.total_members_ever, 1)) * 0.15 +
            (sts.avg_training_effectiveness) * 0.15
        , 0)
    , 3) AS overall_effectiveness_score,
    JSON_OBJECT(
        'member_ids', (SELECT JSON_ARRAYAGG(sm.dwarf_id) FROM SQUAD_MEMBERS sm WHERE sm.squad_id = ms.squad_id AND sm.exit_date IS NULL),
        'equipment_ids', (SELECT JSON_ARRAYAGG(se.equipment_id) FROM SQUAD_EQUIPMENT se WHERE se.squad_id = ms.squad_id),
        'battle_report_ids', (SELECT JSON_ARRAYAGG(sb.report_id) FROM SQUAD_BATTLES sb WHERE sb.squad_id = ms.squad_id),
        'training_ids', (SELECT JSON_ARRAYAGG(st.schedule_id) FROM SQUAD_TRAINING st WHERE st.squad_id = ms.squad_id)
    ) AS related_entities
FROM
    MILITARY_SQUADS ms
LEFT JOIN DWARVES d ON ms.leader_id = d.dwarf_id
LEFT JOIN squad_battle_stats sbs ON ms.squad_id = sbs.squad_id
LEFT JOIN squad_member_stats sms ON ms.squad_id = sms.squad_id
LEFT JOIN squad_equipment_quality seq ON ms.squad_id = seq.squad_id
LEFT JOIN squad_training_stats sts ON ms.squad_id = sts.squad_id
LEFT JOIN member_skill_progress msp ON ms.squad_id = msp.squad_id
ORDER BY
    overall_effectiveness_score DESC;
