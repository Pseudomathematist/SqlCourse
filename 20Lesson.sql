SELECT squad_id FROM Squads WHERE leader_id is NULL;
SELECT dwarf_id FROM Dwarves WHERE age > 150 AND profession = 'warrior';
SELECT dwarf_id FROM Dwarves WHERE dwarf_id in (SELECT owner_id FROM Items WHERE type = 'weapon');
SELECT d.dwarf_id, COUNT(t.task_id) FROM Dwarves AS d JOIN Task AS t ON d.dwarf_id = t.owner_id;
GROUP BY d.dwarf_id, t.status;
SELECT * FROM Tasks WHERE assigned_to in (SELECT dwarf_id FROM Dwarves WHERE squad_id in (SELECT squad_id WHERE name = 'Guardians'));
SELECT * FROM Relationships;
