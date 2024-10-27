SELECT Dwarves.dwarf_id, Dwarves.name, Dwarves.age, Dwarves.profession, Dwarves.squad_id, Squads.name, Squads.mission FROM Dwarves, Squads WHERE (Dwarves.squad_id = Squads.squad_id);
SELECT dwarf_id, name, age, profession FROM Dwarves WHERE profession = 'miner' AND squad_id IS NULL;
SELECT task_id FROM Tasks WHERE priority in (SELECT MAX(priority) FROM Tasks));
SELECT Dwarves.dwarf_id, (SELECT COUNT(item_id) FROM Items WHERE Dwarves.dwarf_id = Items.owner_id) FROM Dwarves WHERE EXIST (SELECT owner_id FROM Items WHERE owner_id IS NOT NULL);
SELECT squad_id, (SELECT COUNT(dwarf_id) FROM Dwarves WHERE Dwarves.squad_id = Squads.squad_id) FROM Squads;
