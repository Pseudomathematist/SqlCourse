SELECT 
    f.fortress_id,
    f.name,
    f.location,
    f.founded_year,
    JSON_OBJECT(
        'dwarf_ids', (
            SELECT JSON_ARRAYAGG(d.dwarf_id)
            FROM dwarves d
            WHERE d.fortress_id = f.fortress_id
        ),
        'resource_ids', (
            SELECT JSON_ARRAYAGG(fr.resource_id)
            FROM fortress_resources fr
            WHERE fr.fortress_id = f.fortress_id
        ),
        'workshop_ids', (
            SELECT JSON_ARRAYAGG(w.workshop_id)
            FROM workshops w
            WHERE w.fortress_id = f.fortress_id
        ),
        'squad_ids', (
            SELECT JSON_ARRAYAGG(s.squad_id)
            FROM military_squads s
            WHERE s.fortress_id = f.fortress_id
        )
    ) AS related_entities
FROM 
    fortresses f;

Этот запрос проходит по всем крепостям в таблице
и для каждой вытаскивает её основные данные: ID, название, расположение и год основания.
Дополнительно он создаёт отдельное поле, в которое помещает JSON-объект.
Внутри этого объекта собираются четыре JSON-массива: список ID гномов, которые живут в крепости,
список ID ресурсов, связанных с крепостью, список ID мастерских, находящихся в ней,
и список ID военных отрядов, приписанных к этой крепости. Всё это делается с помощью вложенных подзапросов.

JSON_ARRAYAGG просто собирает значения из нескольких строк в один JSON-массив. 
Например, если у крепости есть гномы с ID 1, 2 и 3,
то JSON_ARRAYAGG вернёт [1, 2, 3]. 
Это удобно, когда нужно получить список в одной строке, 
а не много строк по отдельности. Если данных нет — вернёт NULL.
