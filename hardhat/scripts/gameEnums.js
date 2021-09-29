exports.genders = {
    "enum": ["M", "F"],
    findIndex: (genderString) => {
        return this.genders.enum.findIndex((val) => val === genderString);
    }
};

exports.races = {
    "enum": ["Human", "Dwarf", "Orc", "Ogre", "Elf", "Halfling", "Undead", "Gnome"],
    findIndex: (raceString) => {
        return this.races.enum.findIndex((val) => val === raceString);
    }
};
