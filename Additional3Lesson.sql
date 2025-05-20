SELECT S.squad_id, S.name FROM Squads S JOIN Dwarves D ON S.leader_id = D.dwarf_id WHERE D.squad_id IS NULL OR D.squad_id <> S.squad_id;
SELECT dwarf_id, name FROM Dwarves WHERE age > 150 AND profession = 'Warrior';
SELECT DISTINCT D.dwarf_id, D.name FROM Dwarves D JOIN Items I ON D.dwarf_id = I.owner_id WHERE I.type = 'weapon';
SELECT D.dwarf_id, D.name, T.status, COUNT(*) FROM Dwarves D JOIN Tasks T ON D.dwarf_id = T.assigned_to GROUP BY D.dwarf_id, D.name, T.status;
SELECT T.task_id FROM Tasks T JOIN Dwarves D ON T.assigned_to = D.dwarf_id JOIN Squads S ON D.squad_id = S.squad_id WHERE S.name = 'Guardians';
SELECT D.dwarf_id, D.name, R.relationship, R.related_to, R2.name  FROM Dwarves D JOIN Relationships R ON D.dwarf_id = R.dwarf_id JOIN Dwarves R2 ON R.related_to = R2.dwarf_id;
