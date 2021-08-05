class_name NameGenerator
extends Reference


#return collection[race][randi() % collection[race].size()]
const collection = {
	GlobalConstants.RACE.GOBLIN: [
		"As",
		"Bliq",
		"Pusb",
		"Zregs",
		"Tronk",
		"Glorgierm",
		"Bliozturt",
		"Ruineerd",
		"Crizdokt",
		"Cryghat",
		"Criert",
		"Chics",
		"Sligz",
		"Chelx",
		"Kerd",
		"Sleagnygz",
		"Gnotzor",
		"Edorm",
		"Darseezz",
		"Pednaq",
		"Kees",
		"Paal",
		"Eesz",
		"Rarx",
		"Rert",
		"Plorterk",
		"Ekzux",
		"Trormiar",
		"Criodreebs",
		"Leklosb",
		"Gasz",
		"Vrarx",
		"Chielb",
		"Zrosb",
		"Plor",
		"Croiggokx",
		"Falil",
		"Croirnact",
		"Stroizokt",
		"Goitrect",
		"Jearx",
		"Kir",
		"Grikz",
		"Vrict",
		"Ilx",
		"Guisdas",
		"Elrebs",
		"Glustasb",
		"Blalysb",
		"Aarviz",
		"Xuiq",
		"Teagz",
		"Krold",
		"Klealk",
		"Glak",
		"Glarmild",
		"Leetrar",
		"Ediet",
		"Fromuts",
		"Vidvilb",
		"Viobs",
		"Slulk",
		"Tiecs",
		"Akx",
		"Bliot",
		"Golgisz",
		"Dribnozz",
		"Dreakurx",
		"Frasield",
		"Zriobobs",
		"Frirt",
		"Pogz",
		"Ing",
		"Akx",
		"Krukt",
		"Dialbokt",
		"Ivax",
		"Xiebzus",
		"Klabacs",
		"Wodnurt",
		"Irm",
		"Gnykt",
		"Klard",
		"Ags",
		"Frak",
		"Braasulx",
		"Crorisz",
		"Intics",
		"Chagbirt",
		"Kizlal",
		"Bolx",
		"Burx",
		"Zas",
		"Vrog",
		"Vial",
		"Riziots",
		"Onolb",
		"Bosic",
		"Dramvugz",
		"Onzaalx",
		"Arx",
		"Dat",
		"Glegs",
		"Laz",
		"Keect",
		"Wroskylb",
		"Uglocs",
		"Xuigsucs",
		"Veelsar",
		"Ditiagz"
	]
}


func get_name(_race, is_male=true, is_short=true) -> String:
	var name : String
	
	match _race:
		GlobalConstants.RACE.GOBLIN:
			name = _get_rnd_goblin_name(is_male, is_short)
		_:
			name = "None"
	
	return name


func _get_rnd_goblin_name(_is_male, _is_short) -> String:
	return _goblin_name_generator_v1(_is_male, _is_short)


func _goblin_name_generator_v1(_is_male: bool, _is_short: bool) -> String:
	var vowels = [
		"a", "e", "i", "o", "u", "a", "e", "i", "o", "u", "a", "e", "i",
		"o", "u", "y", "ia", "io", "ee", "aa", "ui", "ie", "ea", "oi"
	]
	
	var male_consonants_syllable_1 = [
		"", "", "", "", "", "", "", "b", "c", "d", "f", "g", "h", "j",
		"k", "l", "p", "r", "t", "v", "w", "x", "z", "br", "bl", "cr",
		"cl", "ch", "dr", "fr", "gr", "gl", "gn", "kr", "kl", "pr", "pl",
		"str", "st", "sr", "sl", "tr", "vr", "wr", "zr"
	]
	var male_consonants_syllable_2 = [
		"b", "d", "g", "h", "k", "l", "m", "n", "r", "s", "t", "v", "z",
		"b", "d", "g", "h", "k", "l", "m", "n", "r", "s", "t", "v", "z",
		"b", "d", "g", "h", "k", "l", "m", "n", "r", "s", "t", "v", "z",
		"b", "d", "g", "h", "k", "l", "m", "n", "r", "s", "t", "v", "z",
		"bb", "bd", "bh", "bl", "bk", "bn", "br", "bs", "bt", "bz", "db",
		"dd", "df", "dh", "dl", "dn", "dr", "ds", "dv", "dz", "", "gg",
		"gb", "gd", "gh", "gk", "gl", "gm", "gn", "gr", "gs", "gt", "gz",
		"hd", "hb", "hk", "hn", "hz", "kl", "kn", "kz", "kv", "kk", "lb",
		"ld", "lg", "lk", "ll", "lr", "ls", "lt", "lv", "lz", "mr", "mv",
		"mz", "mt", "nr", "nv", "nz", "nt", "rb", "rd", "rg", "rk", "rl",
		"rm", "rn", "rr", "rs", "rt", "rv", "rz", "sb", "sd", "sh", "sk",
		"sm", "sn", "sr", "str", "st", "sv", "sz", "ss", "tb", "tl", "tm",
		"tn", "tr", "tv", "tz", "tt", "vl", "vn", "vr", "vz", "zb", "zd",
		"zg", "zl", "zm", "zn", "zt"
	]
	var male_ending = [
		"c", "g", "k", "l", "q", "r", "t", "x", "z", "nk", "ld", "rd",
		"s", "sz", "zz", "ng", "kz", "lb", "rm", "sb", "bs", "ts", "cs",
		"ct", "gs", "gz", "kt", "kx", "lk", "lx", "rk", "rt", "rd", "rx"
	]
	
	var female_consonants_syllable_1 = [
		"", "", "", "", "", "", "", "b", "c", "d", "f", "g", "h", "j",
		"k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "bh", "br",
		"bl", "cr", "cl", "ch", "fr", "fl", "gr", "gl", "gn", "kh", "kl",
		"ph", "pr", "sh", "st", "sr", "sl", "sw", "th", "thr", "tr", "vr",
		"wr"
	]
	var female_consonants_syllable_2 = [
		"b", "f", "g", "h", "k", "l", "m", "n", "p", "r", "s", "t", "v",
		"b", "f", "g", "h", "k", "l", "m", "n", "p", "r", "s", "t", "v",
		"b", "f", "g", "h", "k", "l", "m", "n", "p", "r", "s", "t", "v",
		"b", "f", "g", "h", "k", "l", "m", "n", "p", "r", "s", "t", "v",
		"bb", "bd", "bh", "bl", "bk", "bn", "br", "bs", "bt", "bz", "fb",
		"fl", "fm", "fn", "fs", "ft", "gg", "gb", "gd", "gh", "gk", "gl",
		"gm", "gn", "gr", "gs", "gt", "gz", "hd", "hb", "hk", "hn", "hz",
		"kl", "kn", "kz", "kv", "kk", "lb", "ld", "lg", "lk", "ll", "lr",
		"ls", "lt", "lv", "lz", "mr", "mv", "mz", "mt", "nr", "nv", "nz",
		"nt", "ph", "pf", "pl", "pn", "pm", "pr", "ps", "pt", "pv", "rb",
		"rd", "rg", "rk", "rl", "rm", "rn", "rr", "rs", "rt", "rv", "rz",
		"sb", "sd", "sh", "sk", "sm", "sn", "sr", "str", "st", "sv", "sz",
		"ss", "tb", "tl", "tm", "tn", "tr", "tv", "tz", "tt", "vl", "vn",
		"vr", "vz"
	]
	var female_consonants_ending = [
		"h", "f", "g", "l", "n", "q", "s", "x", "z", "ls", "nk", "zz",
		"ld", "sh", "sz", "ss", "gs", "sx", "lx", "hx", "th", "rx", "rt",
		"ft", "fs", "fz", "lm", "lk", "lt", "ng", "nx", "ns", "nq"
	]
	var female_vowels_ending = [
		"e", "i", "ee", "ia", "ea", "a", "ai", "", "", "", "", "", "",
		"", "", "", "", "", "", ""
	]
	
	var index_vowels_syllable_1 = randi() % len(vowels)
	var index_vowels_syllable_2 = randi() % len(vowels)
	
	var index_m_cons_syllable_1 = randi() % len(male_consonants_syllable_1)
	var index_m_cons_syllable_2 = randi() % len(male_consonants_syllable_2)
	var index_m_ending = randi() % len(male_ending)
	
	var index_f_cons_syllable_1 = randi() % len(female_consonants_syllable_1)
	var index_f_cons_syllable_2 = randi() % len(female_consonants_syllable_2)
	var index_f_cons_ending = randi() % len(female_consonants_ending)
	var index_f_vowels_ending = randi() % len(female_vowels_ending)
	
	var name: String = ""
	
	if _is_male:
		name += male_consonants_syllable_1[index_m_cons_syllable_1]
		name += vowels[index_vowels_syllable_1]
		
		if not _is_short:
			name += male_consonants_syllable_2[index_m_cons_syllable_2]
			name += vowels[index_vowels_syllable_2]
		
		name += male_ending[index_m_ending]
	else:
		name += female_consonants_syllable_1[index_f_cons_syllable_1]
		name += vowels[index_vowels_syllable_1]
		
		if not _is_short:
			name += female_consonants_syllable_2[index_f_cons_syllable_2]
			name += vowels[index_vowels_syllable_2]
		
		name += female_consonants_ending[index_f_cons_ending]
		name += female_vowels_ending[index_f_vowels_ending]

	
	return name.capitalize()
