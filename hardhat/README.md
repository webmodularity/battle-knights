## BattleKnights

## Knight Generator
### Names
Names are generated randomly on chain using a pool of names and titles that are specific to the selected race and gender.
The contract will attempt to generate a unique name but will fallback to adding a roman numeral suffix in the case of too many attempts.

### Races & Gender
The race and gender is determined randomly on chain and is influenced by the spawn %s listed in the table below.
Humans are the most common (70%) and have randomly assigned attributes. The non-human races have a bonus and penalty attribute that modifies the order of their attributes. The bonus attribute will be the highest and the penalty attribute will be the lowest rolls.

| Race         | Bonus Attribute  | Penalty Attribute | Spawn %   | Gender  |
| ------------ | :--------------: | :---------------: | :-------: | :--------------: |
| *Human*      | N/A              | N/A               | 70%       | M (80%), F (20%) |
| *Dwarf*      | Vitality         | Size              | 10%       | M (80%), F (20%) |
| *Orc*        | Strength         | Intelligence      | 8%        | M (80%), F (20%) |
| *Ogre*       | Size             | Dexterity         | 4%        | M (100%)         |
| *Elf*        | Dexterity        | Strength          | 3%        | M (80%), F (20%) |
| *Halfling*   | Luck             | Size              | 2%        | M (80%), F (20%) |
| *Gnome*      | Intelligence     | Size              | 2%        | M (80%), F (20%) |
| *Undead*     | Stamina          | Luck              | 1%        | M (100%)         |

### Attributes
Attribute scores are generated randomly on chain (3d6) but capped at a sum of 84. No knights with super lucky rolls dominating. Each knight has a total of 84 attribute point that are just distributed differently.


| Attribute        | Range    | Combat Bonus                 |
| ---------------- | :------: | ---------------------------- |
| *Strength*       | 3-18     | Damage                       |
| *Vitality*       | 3-18     | Health Pool                  |
| *Size*           | 3-18     | Damage                       |
| *Stamina*        | 3-18     | Endurance                    |
| *Dexterity*      | 3-18     | Initiative, Dodge            |
| *Intelligence*   | 3-18     | Critical Hit, Counterattack  |
| *Luck*           | 3-18     | Critical Hit, Initiative     |