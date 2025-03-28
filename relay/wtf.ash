/******************************************************************************
WTF relay script general functions
******************************************************************************/
since r28464;



//Trim beginning string ss from string txt
string TrimFirst(string txt, string ss) {
	matcher mx = create_matcher("^"+ss+"(.+)",txt);
	if (find(mx)) { txt = group(mx,1); }
	//if (substring(txt,0,length(ss))==ss) { txt = substring(txt,length(ss)); }
	return txt;
}

//Trim ending string ss from string txt
string TrimLast(string txt, string ss) {
	matcher mx = create_matcher("(.+)"+ss+"$",txt);
	if (find(mx)) { txt = group(mx,1); }
	//if (substring(txt,length(txt)-1)==ss) { txt = substring(txt,0,length(txt)-length(ss)); }
	return txt;
}


//parse a string of modifiers and return a WTF html decorated string
string ParseMods(string modtxt) {
	string evm = modtxt;
	matcher mparse;
	
	string pmat = "";
	string newmod = "";
	
	static {
		//replace string text for various Modifier texts
		//we do replace in stages (a,b,c) to avoid conflicts
		string[string] arsx;
		//shorten for Class only restrictions
		arsx["\"Seal Clubber\""] = "SC";
		arsx["\"Turtle Tamer\""] = "TT";
		arsx["\"Sauceror\""] = "SA";
		arsx["\"Pastamancer\""] = "PM";
		arsx["\"Disco Bandit\""] = "DB";
		arsx["\"Accordion Thief\""] = "AT";
		//shorten various text
		arsx["Adventure Underwater"] = "Underwater";
		arsx["Adventures"] = "Advs";
		arsx["Attacks Can't Miss"] = "Can't Miss";
		arsx["Base Resting"] = "Resting";
		arsx["Bonus Resting"] = "Resting";
		arsx["Critical"] = "Crit";
		arsx["Damage Absorption"] = "DA";
		arsx["Damage Reduction"] = "DR";
		arsx["Experience"] = "Exp";
		arsx["Familiar Action Bonus"] = "Familiar Action";
		arsx["Familiar"] = "Fam";
		arsx["familiar"] = "Fam";
		arsx["Fishing Skill"] = "Fishing";
		arsx["Hobo Power"] = "Hobo";
		arsx["Initiative"] = "Init";
		arsx["Lasts Until Rollover"] = "Rollover";
		arsx["Maximum"] = "Max";
		arsx["Minstrel Level"] = "Minstrel";
		arsx["Monster Level"] = "ML";
		arsx["Moxie"] = "Mox";
		arsx["Muscle"] = "Mus";
		arsx["Mysticality"] = "Mys";
		arsx["Nonstackable Watch"] = "Watch";
		arsx["Pickpocket Chance"] = "Pickpocket";
		arsx["Random Monster Modifiers"] = "Random Mods";
		arsx["Reduce Enemy Defense"] = "Reduce Def";
		arsx["Resistance"] = "Res";
		arsx["Single Equip"] = "Single";
		arsx["Smithsness"] = "Smith";
		arsx["Softcore Only"] = "Softcore";
		arsx["Weapon"] = "Wpn";
		
		string[string] brsx;
		brsx["Damage"] = "Dmg";
		brsx["Resist"] = "Res";
		brsx[":"] = "";
		brsx["\""] = "";
		
		//decorate elemental tags with pretty colors
		string[string] crsx;
		crsx["Hot Dmg"] = "<span class=modhot>Hot Dmg</span>";
		crsx["Cold Dmg"] = "<span class=modcold>Cold Dmg</span>";
		crsx["Spooky Dmg"] = "<span class=modspooky>Spooky Dmg</span>";
		crsx["Stench Dmg"] = "<span class=modstench>Stench Dmg</span>";
		crsx["Sleaze Dmg"] = "<span class=modsleaze>Sleaze Dmg</span>";
		crsx["Hot Spell Dmg"] = "<span class=modhot>Hot Spell Dmg</span>";
		crsx["Cold Spell Dmg"] = "<span class=modcold>Cold Spell Dmg</span>";
		crsx["Spooky Spell Dmg"] = "<span class=modspooky>Spooky Spell Dmg</span>";
		crsx["Stench Spell Dmg"] = "<span class=modstench>Stench Spell Dmg</span>";
		crsx["Sleaze Spell Dmg"] = "<span class=modsleaze>Sleaze Spell Dmg</span>";
		crsx["Hot Res"] = "<span class=modhot>Hot Res</span>";
		crsx["Cold Res"] = "<span class=modcold>Cold Res</span>";
		crsx["Spooky Res"] = "<span class=modspooky>Spooky Res</span>";
		crsx["Stench Res"] = "<span class=modstench>Stench Res</span>";
		crsx["Sleaze Res"] = "<span class=modsleaze>Sleaze Res</span>";
		//crsx["Prismatic"] = "<span class=modspooky>P</span><span class=modhot>ri</span><span class=modsleaze>sm</span><span class=modstench>at</span><span class=modcold>ic</span>";
		//highlight items and meat
		crsx["Item"] = "<span class=moditem>Item</span>";
		crsx["Meat"] = "<span class=moditem>Meat</span>";
		//highlight ML
		crsx["ML"] = "<span class=modml>ML</span>";
		
	}
	
	
	//Get rid of some informational modifier stuff
	pmat = "";
	pmat +=  "(Familiar Effect: \".+?\")";
	pmat += "|(Equips On: \".+?\")";
	pmat += "|(Wiki Name: \".+?\")";
	pmat += "|(Last Available: \".+?\")";
	pmat += "|(Conditional Skill.+?: \".+?\")";
	pmat += "|(Conditional Skill.+?: \\+\\d+)";
	mparse = create_matcher(pmat,evm);
	while (find(mparse)) { evm = replace_string(evm,group(mparse),""); }
	
	//remove other static modifiers we don't care about
	evm = replace_string(evm,"Generic","");
	
	
	//Move parenthesis to the beginning of the modifier
	//Experience (Familiar) => Familiar Experience
	mparse = create_matcher("(, ?|^)([^,]*?)\\((.+?)\\)",evm);
	// regex = (, or begining)(any char not ,)((inside parens))
	//          1              2                3
	while (find(mparse)) {
		newmod = group(mparse,1)+group(mparse,3)+" "+group(mparse,2);
		TrimLast(newmod," ");
		evm = replace_string(evm,group(mparse),newmod);
	}
	
	
	//Combine modifiers for (min and max) regen
	mparse = create_matcher("([HM]P Regen )Min: \\+?(\\d+), \\1Max: \\+?(\\d+)",evm);
	// regex = (HMP type ) Min: (#) (#)
	while (find(mparse)) {
		if (group(mparse,1)!="") {
			newmod = group(mparse,1)+group(mparse,2);
			if (group(mparse,2)!=group(mparse,3)) {
				newmod += "-"+group(mparse,3);
			} 
		}
		evm = replace_string(evm,group(mparse),newmod);
	}
	//Combine modifiers for double regen - if HP and MP regen are the same, combine them
	mparse = create_matcher("HP Regen ([0-9-]+), MP Regen \\1",evm);
	while (find(mparse)) {
		newmod = "";
		if (group(mparse) != "") {	// group is the HP&MP combined Regen
			newmod += "HP/MP Regen "+group(mparse,1);
		}
		evm = replace_string(evm,group(mparse),newmod);
	}
	
	
	//Combine modifiers for maximum (HP and MP)
	mparse = create_matcher("Maximum HP( Percent|):([^,]+), Maximum MP\\1:([^,]+)",evm);
	//regex =              (1: Percent or nothing) (2    )         group1 (3    )
	while (find(mparse)) {
		newmod = "";
		if (group(mparse,2)!="") {
			newmod += "Max HP/MP:";
			newmod += group(mparse,2);
			if (group(mparse,2) != group(mparse,3)) {
				newmod += "/";
				newmod += group(mparse,3);
			}
			if (group(mparse,1)==" Percent") {
				newmod += "%";
			}
		}
		evm = replace_string(evm,group(mparse),newmod);
	}
	
	
	//BALE: Add missing + in front of modifier, for consistency. Then remove colon because it is in the way of legibility
	//Change " Percent: +XX" and " Drop: +XX" to "+XX%"
	buffer enew;  // This is used for rebuilding evm with append_replacement()
	enew.set_length(0);
	mparse = create_matcher("^\\s*(,)\\s*"+"|(\\s*Drop|\\s*Percent([^:]*))?(?<!Limit):\\s*(([+-])?\\d+)",evm);
	while (mparse.find()) {
		mparse.append_replacement(enew, "");
		if (mparse.group(1) == ",") {
			//group would contain extra comma at beginning
			//delete this: append nothing
		} else if (mparse.group(4) != "") {
			//group is the numeric modifier
			enew.append(mparse.group(3));	// group is possible words after "Percent"
			if (mparse.group(5) == "") {
				//group would contain + or -
				enew.append(" +");
			} else {
				enew.append(" ");
			}
			enew.append(mparse.group(4)); //This does not contain Drop, Percent or the colon.
			if (mparse.group(2) != "") {
				//group is Drop or Percent
				enew.append("%");
			}
		}
	}
	mparse.append_tail(enew);
	evm = enew;
	
	
	//Process Effects stuff to make it pretty
	mparse = create_matcher("(?:Rollover )?Effect: \"(.*)\", (?:Rollover )?Effect Duration (\\+\\d+)",evm);
	while (find(mparse)) {
		newmod = "<em class=modeffect>"+group(mparse,1)+"</em> ("+group(mparse,2)+")";
		evm = replace_string(evm,group(mparse),newmod);
	}
	
	//Check for extraneous commas and remove
	mparse = create_matcher(", , ",evm);
	while (find(mparse)) { evm = replace_string(evm,group(mparse),", "); }
	//Check for extraneous commas at beginning and end and remove
	mparse = create_matcher("^(,\\s*)(.+)",evm);
	if (find(mparse)) { evm = group(mparse,2); }
	mparse = create_matcher("(.+)(,\\s*)$",evm);
	if (find(mparse)) { evm = group(mparse,1); }
	
	//replace certain modifier strings with shorted / pretty strings
	foreach ss,rr in arsx { evm = replace_string(evm,ss,rr); }
	foreach ss,rr in brsx { evm = replace_string(evm,ss,rr); }
	foreach ss,rr in crsx { evm = replace_string(evm,ss,rr); }
	
	return evm;
}


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//return item given a description id
item ItDid(string id) {
	foreach it in $items[] {
		if (it.descid==id) { return it; }
	}
	return $item[none];
}


//return parsed modifiers for a thing
string DescMods(string dtxt) {
	string mod = string_modifier(dtxt,"Evaluated Modifiers");
	return ParseMods(mod);
}

string DescMods(item it) {
	string mod = string_modifier(it,"Evaluated Modifiers");
	return ParseMods(mod);
}

string DescMods(effect ef) {
	string mod = string_modifier(ef,"Evaluated Modifiers");
	return ParseMods(mod);
}

string DescMods(skill sk) {
	string mod = string_modifier(sk,"Evaluated Modifiers");
	return ParseMods(mod);
}


//WTF modifiers for effects
string DescEffect(effect ef) {
	string mod = string_modifier(ef,"Evaluated Modifiers");
	return ParseMods(mod);
}


//WTF modifiers for skills
string DescSkill(skill sk) {
	string mod = string_modifier(sk,"Evaluated Modifiers");
	return ParseMods(mod);
}


string DescCombine(string aa, string bb) {
	if (bb=="") { return aa; }
	if (aa=="") { return bb; }
	return aa+", "+bb;
}


//extra information for consumables
string DescCons(item it) {
	string desctext = "";
	
	//classification variables
	boolean isbooze = (it.inebriety>0);
	boolean isfood = (it.fullness>0);
	boolean isspleen = (it.spleen>0);
	boolean gainadv = (it.adventures!="" && it.adventures!=0);
	boolean gainstat = (it.muscle!="" && it.muscle!=0) || (it.mysticality!="" && it.mysticality!=0) || (it.moxie!="" && it.moxie!=0);
	
	if (!(isbooze || isfood || isspleen || gainadv || gainstat)) {	return ""; }
	
	//display level requirement
	if (it.levelreq>1) { desctext = DescCombine(desctext,"Lvl: "+it.levelreq); }
	if (isbooze) { desctext = DescCombine(desctext,"D: "+it.inebriety); }
	if (isfood) { desctext = DescCombine(desctext,"F: "+it.fullness); }
	if (isspleen) { desctext = DescCombine(desctext,"S: "+it.spleen); }
	if (gainadv) { desctext = DescCombine(desctext,"Adv: "+it.adventures); }
	//if (it.notes != "") { desctext = DescCombine(desctext,"Notes: "+it.notes); }
	//remove trailing commas ", "
	desctext = TrimLast(desctext,", ");
	
	return desctext;
}


//additional descriptions for configurable items or items with charges
string DescVars(item it) {
	string vartext = "";
	switch (it) {
		case $item[scratch 'n' sniff sword]: //#3508
		case $item[scratch 'n' sniff crossbow]: //#3526
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[sticker1])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[sticker2])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[sticker3])));
		break;
		case $item[Spooky Putty sheet]: //#3665
			vartext = "("+get_property("spookyPuttyCopiesMade")+"/5)";
		break;
		case $item[Spooky Putty monster]: //#3667
			if (get_property("spookyPuttyMonster")!="") { vartext += "("+get_property("spookyPuttyMonster")+")"; }
		break;
		case $item[Crown of Thrones]: //#4614
			vartext = DescMods("Throne:"+my_enthroned_familiar());
		break;
		case $item[shaking 4-d camera]: //#4170
			if (get_property("cameraMonster")!="") { vartext += "("+get_property("cameraMonster")+")"; }
		break;
		case $item[photocopied monster]: //#4873
			if (get_property("photocopyMonster")!="") { vartext += "("+get_property("photocopyMonster")+")"; }
		break;
		case $item[over-the-shoulder Folder Holder]: //#4930
		case $item[replica over-the-shoulder Folder Holder]: //#11220
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[folder1])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[folder2])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[folder3])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[folder4])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[folder5])));
		break;
		case $item[card sleeve]: //#5009
			vartext = DescMods(equipped_item($slot[card-sleeve]));
		break;
		case $item[Rain-Doh black box]: //#5563
			vartext = "("+get_property("_raindohCopiesMade")+"/5)";
		break;
		case $item[Rain-Doh box full of monster]: //#5564
			if (get_property("rainDohMonster")!="") { vartext += "("+get_property("rainDohMonster")+")"; }
		break;
		case $item[wax bugbear]: //#5704
			if (get_property("waxMonster")!="") { vartext += "("+get_property("waxMonster")+")"; }
		break;
		case $item[envyfish egg]: //#6388
			if (get_property("envyfishMonster")!="") { vartext += "("+get_property("envyfishMonster")+")"; }
		break;
		case $item[crude monster sculpture]: //#6677
			if (get_property("crudeMonster")!="") { vartext += "("+get_property("crudeMonster")+")"; }
		break;
		case $item[ice sculpture]: //#7080
			if (get_property("iceSculptureMonster")!="") { vartext += "("+get_property("iceSculptureMonster")+")"; }
		break;
		case $item[shaking crappy camera]: //#7176
			if (get_property("crappyCameraMonster")!="") { vartext += "("+get_property("crappyCameraMonster")+")"; }
		break;
		case $item[Buddy Bjorn]: //#7200
			vartext = DescMods("Throne:"+my_bjorned_familiar());
		break;
		case $item[The Crown of Ed the Undying]: //#8185
			vartext = DescMods("Edpiece:"+get_property("edPiece"));
		break;
		case $item[your cowboy boots]: //#8850
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[bootskin])));
			vartext = DescCombine(vartext,DescMods(equipped_item($slot[bootspur])));
		break;
		case $item[Deck of Every Card]: //#8382
			vartext = "("+get_property("_deckCardsDrawn")+"/15)";
		break;
		case $item[screencapped monster]: //#9023
			if (get_property("screencappedMonster")!="") { vartext += "("+get_property("screencappedMonster")+")"; }
		break;
		case $item[Time-Spinner]: //#9104
			vartext = "("+get_property("_timeSpinnerMinutesUsed")+"/10)";
		break;
		case $item[Kremlin's Greatest Briefcase]:
			vartext = "("+get_property("_kgbClicksUsed")+"/22)";
		break;
		case $item[genie bottle]:
			vartext = "("+get_property("_genieWishesUsed")+"/3)";
		break;
		case $item[latte lovers member's mug]:
			vartext = "("+get_property("_latteRefillsUsed")+"/3)";
		break;
		case $item[Fourth of May Cosplay Saber]:
			vartext = "("+get_property("_saberForceUses")+"/5)";
		case $item[Beach Comb]:
			vartext = "("+get_property("_freeBeachWalksUsed")+"/11)";
		break;
		case $item[Powerful Glove]:
			vartext = "("+get_property("_powerfulGloveBatteryPowerUsed")+"/100)";
		break;
		case $item[backup camera]:
			vartext = "("+get_property("_backUpUses")+"/11)";
		break;
		case $item[industrial fire extinguisher]:
			vartext = "("+get_property("_fireExtinguisherCharge")+"/100)";
		break;
		case $item[designer sweatpants]:
			vartext = "("+get_property("sweat")+"/100)";
		break;
		case $item[tiny stillsuit]: //#10932
			vartext = "("+get_property("familiarSweat")+")";
		break;
		case $item[Jurassic Parka]:
		case $item[replica Jurassic Parka]:
			vartext = "("+get_property("_spikolodonSpikeUses")+"/5)";
		break;
		case $item[cursed monkey's paw]:
			vartext = "("+get_property("_monkeyPawWishesUsed")+"/5)";
		break;
		case $item[Cincho de Mayo]:
		case $item[replica Cincho de Mayo]:
			vartext = "("+get_property("_cinchUsed")+"/100)";
		break;
		case $item[2002 Mr. Store Catalog]: //#11257
		case $item[Replica 2002 Mr. Store Catalog]:
			vartext = "("+get_property("availableMrStore2002Credits")+"/3)";
		break;
		case $item[Flash Liquidizer Ultra Dousing Accessory]:
			vartext = "("+get_property("_douseFoeUses")+"/3)";
		break;
		case $item[august scepter]:
			vartext = "("+get_property("_augSkillsCast")+"/5)";
		break;
		case $item[Apriling band saxophone]:
			vartext = "("+get_property("_aprilBandSaxophoneUses")+"/3)";
		break;
		case $item[Apriling band quad tom]:
			vartext = "("+get_property("_aprilBandTomUses")+"/3)";
		break;
		case $item[Apriling band tuba]:
			vartext = "("+get_property("_aprilBandTubaUses")+"/3)";
		break;
		case $item[Apriling band staff]:
			vartext = "("+get_property("_aprilBandStaffUses")+"/3)";
		break;
		case $item[Apriling band piccolo]:
			vartext = "("+get_property("_aprilBandPiccoloUses")+"/3)";
		break;
		case $item[Sept-Ember Censer]:
			vartext = "("+get_property("availableSeptEmbers")+")";
		break;
		case $item[bat wings]: //#11658
			vartext = "("+get_property("_batWingsSwoopUsed")+"/11)";
		break;
	}
	
	return vartext;
	
}



//WTF modifiers for items, with special handling for unique items
string DescItem(item it) {
	string constext = DescCons(it);
	string modstext = DescMods(it);
	string efftext = DescEffect(effect_modifier(it,"Effect")) + DescEffect(effect_modifier(it,"Rollover Effect"));
	string vartext = DescVars(it);
	
	string desctext = "";
	desctext = DescCombine(desctext,constext);
	desctext = DescCombine(desctext,modstext);
	if (efftext != "") { desctext += ", ["+efftext+"]"; }
	desctext = DescCombine(desctext,vartext);
	
	boolean IsAbsorby(item it) {
		if ($items[interesting clod of dirt, dirty bottlecap, discarded button] contains it) return true;
		return (it.gift || it.tradeable) && it.discardable;
	}
	
	string noobtext = "";
	if (my_path()==$path[Gelatinous Noob] && IsAbsorby(it)) {
		skill sk = it.noob_skill;
		if (sk!=$skill[none] && !have_skill(sk)) {
			noobtext += "<br><em class=modnoob>"+to_string(sk)+"</em>";
			noobtext += " ["+DescSkill(sk)+"]";
		}
	}
	desctext = DescCombine(desctext,noobtext);
	
	return desctext;
}


string QualColor(string qt) {
	//add quality color css class
	if (contains_text(qt,"EPIC")) {
		return "modepic";
	} else if (qt=="awesome") {
		return "modawesome"; 
	} else if (qt=="good") {
		return "modgood";
	} else if (qt=="crappy") {
		return "modcrappy";
	}
	return "";
}


buffer FolderWTF(buffer page) {
	page.replace_string("</head>","\n<link rel=\"stylesheet\" href=\"wtf.css\">\n</head>");
	matcher mf = create_matcher("<b>(.+?)</b></td>", page);
	while (find(mf)) {
		item it = to_item("folder ("+group(mf,1)+")");
		string dd = "<small class=desc>"+DescItem(it)+"</small>";
		page.replace_string(group(mf),"<b>"+group(mf,1)+"</b><br>"+dd+"</td>");
	}
	return page;
}

buffer FolderWTF(string ss) {
 return FolderWTF(to_buffer(ss));
}


//color item image icons using tcrs.js script, based on wtfitemcolors.txt data
buffer ImageWTF(buffer page) {
	if (!contains_text(page,"tcrs.js")) {
		page.replace_string("</head>","\n<script language=\"javascript\" src=\"tcrs.js\"></script>\n</head>");
	}
	
	static {
		string[string] cmap;
		cmap["red"] = "#CC0000";
		cmap["green"] = "#006600";
		cmap["blue"] = "#0000CC";
		cmap["brown"] = "#8B4513";
		cmap["yellow"] = "#999900";
		cmap["gray"] = "#696969";
		cmap["purple"] = "#8A2BE2";
		cmap["orange"] = "#FF8C00";
		cmap["maroon"] = "#800000";
		cmap["pink"] = "#FF69B4";
		cmap["indigo"] = "#4B0082";
		cmap["violet"] = "#9400D3";
		cmap["vermilion"] = "#E34234";
		cmap["amber"] = "#FFBF00";
		cmap["chartreuse"] = "#7FFF00";
		cmap["teal"] = "#008080";
		cmap["magenta"] = "#FF00FF";
		cmap["fuchsia"] = "#FF00FF";
		cmap["cyan"] = "#00FFFF";
		cmap["navy"] = "#000080";
		cmap["olive"] = "#808000";
		cmap["darkgreen"] = "#006400";
		cmap["gold"] = "#999900"; //"#FFD700";
		cmap["silver"] = "#696969"; //"#C0C0C0";
		cmap["bronze"] = "#CD7F32";
		cmap["rust"] = "#B7410E";
		
		string[int] itcol;
		string[item] itdat;
		file_to_map("wtfitemcolors.txt",itdat);
		foreach it,ss in itdat { itcol[to_int(it.descid)] = cmap[ss]; }
		
	}
	
	//<img src="/images/itemimages/folder2.gif" class="hand pop" rel="desc_item.php?whichitem=803733525" onClick='javascript:descitem(803733525)'>
	matcher mcol = create_matcher("(<img)([^>]+src=[^>]+?descitem\\((\\d+)[^>]+?>)", page);
	while (find(mcol)) {
		int did = to_int(group(mcol,3));
		if (itcol[did]!="") {
			//print(did,"olive");
			page.replace_string(group(mcol),group(mcol,1)+" data-tcrs=\""+itcol[did]+"\""+group(mcol,2));
		}
	}
	
	return page;
	
}


