SELECT Dwarves.dwarf_id, Dwarves.name AS dwarf_name, Dwarves.age, Dwarves.profession, Dwarves.squad_id, Squads.name AS squad_name, Squads.mission FROM Dwarves JOIN Squads ON Dwarves.squad_id = Squads.squad_id;

SELECT dwarf_id, name FROM Dwarves WHERE Profession = 'miner' AND squad_id IS NULL;

SELECT task_id, description FROM Tasks WHERE priority = (SELECT MAX(priority) FROM Tasks) AND status = 'pending';

SELECT Dwarves.dwarf_id, Dwarves.name, Count(*) FROM Dwarves JOIN Items ON Dwarves.dwarf_id = Items.owner_id GROUP BY Dwarves.dwarf_id;

SELECT Squad.squad_id, Squad.name, COUNT(*) FROM Squad LEFT JOIN Dwarves ON Squad.squad_id = Dwarves.squad_id GROUP BY Squad.squad_id, Squad.name;

SELECT Dwarves.profession FROM Dwarves JOIN (SELECT owner_id FROM Tasks WHERE status in ('pending', 'in_progress')) AS Unsolved_tasks ON Dwarves.dwarf_id = Unsolved_tasks.owner_id GROUP BY Dwarves.profession HAVING COUNT(*) = (SELECT MAX(count) FROM (SELECT COUNT(*) AS count FROM Dwarves JOIN (SELECT  owner_id FROM Tasks WHERE status in ('pending', 'in_progress')) AS Unsolved_tasks ON Dwarves.dwarf_id = Unsolved_tasks.owner_id GROUP BY Dwarves.profession) AS Task_counts);

SELECT Items.type, AVG(Dwarves.age) FROM Items JOIN Dwarves ON (Items.owner_id = Dwarves.dwarf_id OR Items.owner_id IS NULL) GROUP BY Items.type;

SELECT dwarf_id FROM Dwarves WHERE (age > (SELECT AVG(age) FROM Dwarves) AND NOT EXISTS (SELECT owner_id FROM Items WHERE owner_id = Dwarves.dwarf_id));
