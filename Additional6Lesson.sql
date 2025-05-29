 Задача 2: Получение данных о гноме с навыками и назначениями

Создайте запрос, который возвращает информацию о гноме, включая идентификаторы всех его навыков, текущих назначений, принадлежности к отрядам и используемого снаряжения.




SELECT 
	D.dwarf_id, D.name, D.age, D.profession,
	JSON_OBJECT(
      'skill_ids', (
        SELECT JSON_ARRAYAGG(DS.skill_id)
        FROM DWARF_SKILLS DS
        WHERE DS.dwarf_id = D.dwarf_id
        ),
      'assignment_ids', (
        SELECT JSON_ARRAYAGG(DA.assignment_id)
        FROM DWARF_ASSIGNMENT DA
        WHERE DA.dwarf_id = D.dwarf_id
        ),
      'squad_ids', (
        SELECT 	JSON_ARRAYAGG(SA.squad_id)
        FROM SQUAD_MEMBERS SA
        WHERE SA.dwarf_id = D.dwarf_id
        ),
      'equipment_ids', (
        SELECT JSON_ARRAYAGG(DE.equipment_id)
        FROM DWARF_EQUIPMENT DE 
        WHERE DE.dwarf_id = D.dwarf_id
        )
      ) AS related_entities
FROM 
	DWARVES D;
    
 Задача 3: Данные о мастерской с назначенными рабочими и проектами

Напишите запрос для получения информации о мастерской, включая идентификаторы назначенных ремесленников, текущих проектов, используемых и производимых ресурсов. 


SELECT
	W.workshop_id,
    W.name,
    W.type,
    W.quality,
    JSON_OBJECT(
      'craftsdwarf_ids', (
        SELECT JSON_ARRAYAGG(WC.craftsdwarf_id)
        FROM WORKSHOP_CRAFTSDWARVES WC
        WHERE WC.workshop_id = W.workshop_id
        ),
      'project_ids', (
        SELECT JSON_ARRAYAGG(P.project_id)
        FROM PROJECTS P
        WHERE P.workshop_id = W.workshop_id
        ),
      'input_material_ids', (
        SELECT JSON_ARRAYAGG(WM.material_id)
        FROM WORKSHOP_MATERIALS WM
        WHERE WM.workshop_id = W.workshop_id
        ),
      'output_product_ids', (
        SELECT JSON_ARRAYAGG(WP.product_id)
        FROM WORKSHOP_PRODUCTS WP
        WHERE WP.workshop_id = W.workshop_id
        )
      ) AS related_entities
FROM 
	WORKSHOPS W;
    
 Задача 4: Данные о военном отряде с составом и операциями

Разработайте запрос, который возвращает информацию о военном отряде, включая идентификаторы всех членов отряда, используемого снаряжения, прошлых и текущих операций, тренировок. 


SELECT
 	S.squad_id,
   	S.name,
    S.formation_type,
    S.leader_id,
    JSON_OBJECT(
      'member_ids', (
        SELECT JSON_ARRAYAGG(SM.dwarf_id)
        FROM SQUAD_MEMBERS SM
        WHERE SM.squad_id = S.squad_id
        ),
      'equipment_ids', (
        SELECT JSON_ARRAYAGG(SE.equipment_id)
        FROM SQUAD_EQUIPMENT SE
        WHERE SE.squad_id = S.squad_id
        ),
      'operation_ids', (
        SELECT JSON_ARRAYAGG(SO.operation_id)
        FROM SQUAD_OPERATION SO
        WHERE SO.squad_id = S.squad_id AND SO.end_date IS NULL
        ),
      'training_schedule_ids', (
        SELECT JSON_ARRAYAGG(ST.schedule_id)
        FROM SQUAD_TRAINING ST
        WHERE ST.squad_id = S.squad_id
        ),
      'battle_report_ids', (
        SELECT JSON_ARRAYAGG(SO.operation_id)
        FROM SQUAD_OPERATION SO
        WHERE SO.squad_id = S.squad_id AND SO.end_date IS NOT NULL
        )
      ) AS related_entities
FROM 
	MILITARY_SQUADS S;
      
        