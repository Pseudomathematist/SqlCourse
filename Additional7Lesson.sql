 Задача 2: Получение данных о гноме с навыками и назначениями

Создайте запрос, который возвращает информацию о гноме, включая идентификаторы всех его навыков, текущих назначений, принадлежности к отрядам и используемого снаряжения.

Май запрос аналогичен.
    
 Задача 3: Данные о мастерской с назначенными рабочими и проектами

Напишите запрос для получения информации о мастерской, включая идентификаторы назначенных ремесленников, текущих проектов, используемых и производимых ресурсов. 

Эталонное решение.

SELECT 
    w.workshop_id,
    w.name,
    w.type,
    w.quality,
    JSON_OBJECT(
        'craftsdwarf_ids', (
            SELECT JSON_ARRAYAGG(wc.dwarf_id)
            FROM workshop_craftsdwarves wc
            WHERE wc.workshop_id = w.workshop_id
        ),
        'project_ids', (
            SELECT JSON_ARRAYAGG(p.project_id)
            FROM projects p
            WHERE p.workshop_id = w.workshop_id
        ),
        'input_material_ids', (
            SELECT JSON_ARRAYAGG(wm.material_id)
            FROM workshop_materials wm
            WHERE wm.workshop_id = w.workshop_id AND wm.is_input = TRUE
        ),
        'output_product_ids', (
            SELECT JSON_ARRAYAGG(wp.product_id)
            FROM workshop_products wp
            WHERE wp.workshop_id = w.workshop_id
        )
    ) AS related_entities
FROM 
    workshops w;

Материалы мастерских (Workshop_Materials): Связывает мастерские с используемыми материалами (n:m) 
Судя по эталонному решению если строка таблицы Workshop_Materials отвечает за используемый материал, то поле is_input будет TRUE. Но учитывая,
что "(Workshop_Materials): Связывает мастерские с используемыми материалами (n:m)", то не понятно, что означает, когда поле is_input будет FALSE.
Возможно это означает, что материал не используется, а производится, но тогда возможно "(Workshop_Materials): Связывает мастерские с содержащихся в них материалами (n:m)"
Также "(Workshop_Materials): Связывает мастерские с используемыми материалами (n:m)", но таблицы для материалов нет, поэтому их сущность не полностью понятна.

Мое решение.

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

Эталонное решение

SELECT 
    s.squad_id,
    s.name,
    s.formation_type,
    s.leader_id,
    JSON_OBJECT(
        'member_ids', (
            SELECT JSON_ARRAYAGG(sm.dwarf_id)
            FROM squad_members sm
            WHERE sm.squad_id = s.squad_id
        ),
        'equipment_ids', (
            SELECT JSON_ARRAYAGG(se.equipment_id)
            FROM squad_equipment se
            WHERE se.squad_id = s.squad_id
        ),
        'operation_ids', (
            SELECT JSON_ARRAYAGG(so.operation_id)
            FROM squad_operations so
            WHERE so.squad_id = s.squad_id
        ),
        'training_schedule_ids', (
            SELECT JSON_ARRAYAGG(st.schedule_id)
            FROM squad_training st
            WHERE st.squad_id = s.squad_id
        ),
        'battle_report_ids', (
            SELECT JSON_ARRAYAGG(sb.report_id)
            FROM squad_battles sb
            WHERE sb.squad_id = s.squad_id
        )
    ) AS related_entities
FROM 
    military_squads s;

Тут я просто не заметил таблицу SQUAD_BATTLES. Поэтому я операции я поделил на те которые еще не кочились - текущие и те которые кончились - прошлые.
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
      
        