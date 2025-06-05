SELECT 
	E.expedition_id,
    E.destination,
    E.status,
    (
      SELECT 1.0 * COUNT(CASE WHEN EM.survived IS TRUE THEN 1 END) / COUNT(*)
      FROM EXPEDITION_MEMEBERS EM
      WHERE EM.expedition_id = E.expedition_id
    ) AS survival_rate,
    (
      SELECT SUM(EA.value)
      FROM EXPEDITION_ARTIFACTS EA 
      WHERE EA.expedition_id = E.expedition_id
    ) AS artifacts_value,
    (
      SELECT COUNT(CASE WHEN ES.discovery_date BETWEEN E.departure_date AND return_date THEN 1 END)
      FROM EXPEDITION_SITES ES 
      WHERE ES.expedition_id = E.expedition_id
    ) AS discovered_sites,
    (
      SELECT 1.0 * COUNT(CASE WHEN EC.outcome = 'GOOD' THEN 1 END) / COUNT(*)
      FROM EXPEDITION_CREATURES EC
      WHERE EC.expedition_id = E.expedition_id
    ) AS encounter_success_rate,
    (
      SELECT COUNT(CASE WHEN DS.date <= E.return_date THEN 1 END) -
       		  COUNT(CASE WHEN DS.date <= E.departure_date THEN 1 END)
      FROM EXPEDITION_MEMBERS EM
      JOIN DWARF_SKILLS DS
      ON EM.dwarf_id = DS.dwarf_id
      WHERE EM.expedition_id = E.expedition_id
    ) AS skill_improvement,
    return_date - departure_date AS expedition_duration,
    JSON_OBJECT(
      'member_ids', (
        SELECT JSON_ARRAYAGG(EM.dwarf_id)
        FROM EXPEDITION_MEMBERS EM
        WHERE EM.expedition_id = E.expedition_id
        ),
      'artifact_ids', (
        SELECT JSON_ARRAYAGG(EA.artifact_id)
        FROM EXPEDITION_ARTIFACTS EA
        WHERE EA.expedition_id = E.expedition_id
        ),
      'site_ids', (
        SELECT JSON_ARRAYAGG(ES.site_id)
        FROM EXPEDITION_SITES ES
        WHERE ES.expedition_id = E.expedition_id
        )
      ) AS related_entities
FROM
	EXPEDITIONS E;