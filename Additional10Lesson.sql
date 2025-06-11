WITH WORKSHOPS_INFO AS (
  SELECT 
      w.workshop_id,
      w.name as workshop_name,
      w.type As workshop_type,
      COALESCE(COUNt(*), 0) as num_craftsdwarves,
  FROM
      WORKSHOPS w 
  LEFT JOIN
      WORKSHOP_CRAFTSDWARVES wc ON w.workshop_id = wc.workshop_id
  GROUP BY
      w.workshop_id, workshop_name, workshop_type
),
WORKSHOPS_ADDITIONAL_INFO AS (
  SELECT
      w.workshop_id,
      COALESCE(SUM(wp.quantity), 0) AS total_quantity_produced,
      COALESCE(SUM(w.value), 0) AS total_production_value
      COUNT(DISTINCT wp.production_date) AS count_production_days
      COALESCE(total_quantity_produced / NULLIF(count_production_days, 0)) AS daily_production_rate
      EXTRACT(DAY FROM (MAX(production_date) - MIN(production_date)) AS total_working_duration
      COALESCE(count_production_days / NULLIF(total_working_duration, 0)) * 100 AS workshop_utilization_percent
      COALESCE(total_production_value / NULLIF(total_quantity_produced, 0)) As value_per_material_unit
  FROM
      WORKSHOPS w
  LEFT JOIN
      WORKSHOP_PRODUCTS wp ON w.workshop_id = wp.workshop_id
  LEFT JOIN
      PRODUCTS p ON wp.product_id = p.product_id
  GROUP BY
      w.workshop_id
),
QUALITIES AS (
  SELECT 
      created_by,
      AVARAGE(quality) AS avarage_quality
  FROM
      PRODUCTS
),
SKILLS_VALUE AS (
  SELECT 
      d.dwarf_id,
      COALESCE(SUM(ds.level), 0) AS skill_value
  FROM
      DWARFS d 
  LEFT JOIN
      DWARF_SKILLS ds ON d.dwarf_id = ds.dwarf_id;
  GROUP BY
      d.dwarf_id
  ),
SKILL_QUALITY_CORRELATION AS(
  SELECT 
      w.workshop_id,
      CORR(skill_value, quality) AS skill_quality_correlation
  FROM
      WORKSHOPS w 
  LEFT JOIN
      SKILLS_VALUE sv ON w.dwarf_id = sv.dwarf_id
  LEFT JOIN
      QUALITIES q ON sv.dwarf_id = q.created_by
  GROUP BY
      w.workshop_id;
)

SELECT
  wi.workshop_id,
  wi.workshop_name,
  wi.workshop_type,
  wi.num_craftsdwarves,
  wai.total_quantity_produced,
  wai.total_production_value,
  wai.daily_production_rate,
  wai.workshop_utilization_percent,
  wai.value_per_material_unit,
  sqs.skill_quality_correlation,
  JSON_OBJECT(
        'craftsdwarf_ids', (
            SELECT JSON_ARRAYAGG(wc.dwarf_id)
            FROM WORKSHOP_CRAFTSDWARVES wc
            WHERE ws.workshop_id = wi.workshop_id
        ),
        'product_ids', (
            SELECT JSON_ARRAYAGG(wp.product_id)
            FROM WORKSHOP_PRODUCTS wp
            WHERE wp.workshop_id = wi.workshop_id
        ),
        'material_ids', (
            SELECT JSON_ARRAYAGG(wm.material_id)
            FROM WORKSHOP_MATERIALS wm
            WHERE wm.workshop_id = wi.workshop_id
        )
    	'project_ids', (
            SELECT JSON_ARRAYAGG(p.project_id)
            FROM PROJECTS  p
            WHERE p.workshop_id = wi.workshop_id
        ),
    ) AS related_entities
FROM
  WORKSHOPS_INFO wi 
JOIN
  WORKSHOPS_ADDITIONAL_INFO wai ON wi.workshop_id = wai.workshop_id
JOIN
  SKILL_QUALITY_CORRELATION sqc ON wi.workshop_id = sqc.workshop_id;
  
            
            
            
