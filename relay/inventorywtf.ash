// ckb WTF Inventory Spoilers 
import <wtf.ash>;

//.php uses:
//closet
//craft
//fillcloset
//inventory
//sellstuff_ugly
//sellstuff
//storage



//This is a helper function to find the words KoL uses for various items in its [use] links that are not actually the word [use]
//This is run occasionally to update the text in the make stuff/SPEND/whatever links
void FindInvSpecs() {
	buffer page;
	page = append(page,visit_url("inventory.php?which=1"));
	page = append(page,visit_url("inventory.php?which=2"));
	page = append(page,visit_url("inventory.php?which=3"));
	
	matcher mis = create_matcher(">\\[(.+?)\\]</(a|s)>",page);
	while (find(mis)) {
		//print(group(mis),"olive");
		string spc = group(mis,1);
		if (!($strings[use,use some,use multiple,eat,eat some,drink,drink some,discard,put in terrarium,equip,drink,1,2,3,offhand] contains spc)) {
			print(spc,"olive");
		}
	}
	
}


//the magical place where inventory pages are parsed and updated
buffer InventoryWTF(buffer page) {
	//print("InventoryWTF","olive");
	//return page;
	//int tzero = gametime_to_int();
	
	//expensive items get highlighted
	static {
		int EXPCOST = 999999;
	}
	
	//insert stylesheet link
	page.replace_string("</head>","\n<link rel=\"stylesheet\" href=\"wtf.css\">\n</head>");
	
	//decorate current page
	matcher mtitle = create_matcher("(\\[[^<]+\\]) ?&nbsp;",page);
	if (find(mtitle)) {
		page.replace_string(group(mtitle),"<b class=modextra>"+group(mtitle,1)+"</b>&nbsp;");
	}
	
	//hack to fix boris's helm [twist horns] (and other future items which work in a similar way)...
	page.replace_string("</td><td colspan=2><a href=inventory.php?action="," <a href=inventory.php?action=");
	
	page.replace_string("<table><tr><td><div","<table width=100%><tr><td><div");
	page.replace_string("<td class=\"i\" valign=\"middle\">","<td class=\"i\" valign=\"middle\" width=33%>");
	page.replace_string("<td><a class=nounder","<td width=50%><a class=nounder");
	
	//get rid of slimling feeding to avoid losing equipment
	page.replace_string("[give to slimeling]","");
	//add [eat] link for glitch season reward name
	page.replace_string("whichitem=10207\">[implement]</a>","whichitem=10207\">[implement]</a> <a href=inv_eat.php?pwd="+my_hash()+"&which=3&whichitem=10207>[eat]</a>");
	//highlight the make stuff/SPEND/whatever links
	foreach ss in $strings[
	adjust,
	adjust collar,
	assemble,
	blOw,
	carve,
	cheat,
	chug,
	chug some,
	comb,
	conduct,
	configure,
	consider,
	crush,
	decipher,
	decorate,
	decrypt,
	disable,
	distill,
	examine,
	exchange,
	eXpend,
	fiddle,
	fix,
	flip,
	fold,
	follow,
	gaze,
	get clothes,
	grind,
	implement,
	kiwi kwiki mart,
	lathe something,
	lick,
	make stuff,
	manage,
	manipulate,
	melt,
	open,
	order,
	orderstuff,
	plate,
	play,
	ponder,
	pump,
	read,
	redeem,
	reminisce,
	rub,
	rummage,
	sculpt,
	sell,
	send,
	set mode,
	setup,
	shake,
	shake pan,
	shape it,
	smash,
	spend,
	SPEND,
	spin,
	squeeze,
	squish,
	stoke,
	subscribe,
	switch,
	tap,
	trade,
	tune moon,
	twist horns,
	twist horns back,
	upgrade,
	flatten,
	roll up,
	tie up,
	inflate,
	wish,
	zap,
	] {
		page.replace_string("["+ss+"]","[<span class=\"modextra\">"+ss+"</span>]");
	}
	
	//kill annoying TCRS image manipulation
	if (my_path()==$path[Two Crazy Random Summer]) {
		foreach it in $items[] {
			//change names back to normal
			if (it.tcrs_name!="") {
				page.replace_string(">"+it.tcrs_name+"</b>",">"+it+"</b>");
			}
		}
		//remove tcrs image changes
		matcher mtcrs = create_matcher("data-tcrs=\".+?\" ",page);
		while (find(mtcrs)) {
			page.replace_string(group(mtcrs),"");
		}
	}
	
	//main functional stuff
	string descpre = "<small class=desc>";
	string descpost = "</small>";
	string desctext = "";
	string replacementtext = "";
	string preamble = "";
	string descid = "";
	string itemname = "";
	string itemqty = "";
	string powerpre = "";
	string powerpost = "";
	string itclass = "";
	string qcol = "";
	item it;
	
	
	//find items on page
	matcher mit = create_matcher("(><b .*?rel=\"(\\d+)\".*?>)([^<>]+)(?:</a>)?</b>(&nbsp;<span>[0-9()]*</span>|</a> [0-9()]*)?(?! moved from storage)((?:.(?<!</td>))*?Power: \\d+)?(.*?)</td>", page);
	//regex:                      1:preable     2:descid      3:item      4:quantity-optional-varies                  ?:non-capture          5:powerpre-optional            6:powerpost
	
	while (find(mit)) {
		desctext = "";
		preamble = group(mit,1);
		descid = group(mit, 2);
		itemname = group(mit,3);
		itemqty = group(mit,4);
		powerpre = group(mit,5);
		powerpost = group(mit,6);
		
		//print(id+" = "+preamble, "olive");
		//print(itemname, "olive");
		
		//it = to_item(itemname);
		it = desc_to_item(descid);
		
		//highlight items
		if (it==$item[none]) {
			//do nothing
		} else if (it.quest) {
			itemname = "<b class=itquest>"+itemname+"</b>";
		} else if (false && historical_price(it)>EXPCOST) {
			itemname = "<b class=itexp>"+itemname+"</b>";
		} else if (false) {
			itemname = "<b class=itcool>"+itemname+"</b>";
		} else if (!(it.tradeable)) {
			itemname = "<b class=itnotrade>"+itemname+"</b>";
		}
		//add quality color
		qcol=QualColor(it.quality);
		if (qcol!="") {
			itemname = "<b class="+qcol+">"+itemname+"</b>";
		}
		//Check for class restrictions
		itclass = string_modifier(itemname,"Class");
		if (itclass!="" && my_class()!=to_class(itclass)) {
			itemname = "<b class=strike>"+itemname+"</b>";
		}
		
		//here is where the magic happens
		if (it==$item[none]) {
			//print("Inventory WTF: item \"" + itemname + "\" not found.", "red");
		} else if (have_equipped($item[FantasyRealm G. E. M.]) && it==$item[Rubee&trade;]) {
			desctext = "<a href=shop.php?whichshop=fantasyrealm>[<span class=\"modextra\">Spend</span>]</a>";
		} else {
			desctext = DescItem(it);
		}
		
		replacementtext = "";
		replacementtext += preamble;
		replacementtext += itemname;
		replacementtext += "</b>";
		replacementtext += itemqty;
		if (desctext!="") {
			replacementtext += "<br>";
			replacementtext += descpre;
			replacementtext += desctext;
			replacementtext += descpost;
		}
		replacementtext += powerpre;
		replacementtext += powerpost;
		replacementtext += "</td>";
		
		page.replace_string(group(mit), replacementtext);
		
	}
	
	//Add descriptions to special invetory.php pages
	if (contains_text(page,">Opening up the Folder Holder</b>")) {
		page = FolderWTF(page);
	}
	
	page = ImageWTF(page);
	//print("InventoryWTF load time = "+to_string(gametime_to_int()-tzero),"blue");
	return page;
	
}


void main() {
	//InventoryWTF();
}


