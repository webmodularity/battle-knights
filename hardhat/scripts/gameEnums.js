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
    },
    isMaleOnly: (index) => {
        return index == 3 || index == 6 ? true : false;
    }
};

exports.attributes = {
    "enum": ["Strength", "Vitality", "Size", "Stamina", "Dexterity", "Intelligence", "Luck"],
    findIndex: (attributeString) => {
        return this.attributes.enum.findIndex((val) => val === attributeString);
    }
};