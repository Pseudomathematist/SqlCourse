1.Совпало
2.Совпало
3.Написал 
  SELECT dwarf_id FROM Dwarves WHERE dwarf_id in (SELECT owner_id FROM Items WHERE type = 'weapon');
  Вместо
  SELECT DISTINCT D.*
  FROM Dwarves D
  JOIN Items I ON D.dwarf_id = I.owner_id
  WHERE I.type = 'weapon';
  Идейно два вариантва вроде совпадают, буду иметь второй вариант в виду.
4.Написал
  SELECT d.dwarf_id, COUNT(t.task_id) FROM Dwarves AS d JOIN Task AS t ON d.dwarf_id = t.owner_id;
  GROUP BY d.dwarf_id, t.status;
  Вместо
  SELECT assigned_to, status, COUNT(*) AS task_count
  FROM Tasks
  GROUP BY assigned_to, status;
  Использовал лишний JOIN, буду следить за этим в дальнейшем.
5.Написал
  SELECT * FROM Tasks WHERE assigned_to in (SELECT dwarf_id FROM Dwarves WHERE squad_id in (SELECT squad_id WHERE name = 'Guardians'));
  Вместо
  SELECT T.*
  FROM Tasks T
  JOIN Dwarves D ON T.assigned_to = D.dwarf_id
  JOIN Squads S ON D.squad_id = S.squad_id
  WHERE S.name = 'Guardians';
  Идейно два вариантва вроде совпадают, буду иметь второй вариант в виду.
6.Задача звучала как "Выведите всех гномов и их ближайших родственников, указав тип родственных отношений."
  Я написал
  SELECT * FROM Relationships;
  Вместо
  SELECT D1.name AS dwarf_name, D2.name AS relative_name, R.relationship
  FROM Relationships R
  JOIN Dwarves D1 ON R.dwarf_id = D1.dwarf_id
  JOIN Dwarves D2 ON R.related_to = D2.dwarf_id;
  Хотя формально мое решение может подходить под задачу, но можно было конечно догадаться, что в задаче требуется нечто большее, чем SELECT * FROM Relationships;
  
