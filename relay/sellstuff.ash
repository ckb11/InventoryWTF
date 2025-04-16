// ckb WTF Inventory Spoilers 
import <wtf.ash>;



buffer SellStuffWTF(buffer page) {
	//print("SellStuffWTF","olive");
	//return page;
	
	//insert stylesheet link
	page.replace_string("</head>","\n<link rel=\"stylesheet\" href=\"wtf.css\">\n</head>");
	
	//main functional stuff
	string descpre = "<small class=desc>";
	string descpost = "</small>";
	string desctext = "";
	string replacementtext = "";
	string preamble = "";
	string descid = "";
	string itemname = "";
	string itemqty = "";
	string itclass = "";
	string qcol = "";
	item it;
	
	//<td><a class=nounder href='javascript:descitem(757328138);'><b>magilaser blastercannon</b></a> (3)<br><font size=1>170 Meat</font></td>
	//find items on page
	matcher mit = create_matcher("(<td><a class=nounder href='javascript:descitem\\((\\d+)\\);'><b>)([^<>]+)</b></a>([0-9() ]*)<br>", page);
	//regex:                       1:pre                                             2:descid         3:item         4:qty
	
	while (find(mit)) {
		desctext = "";
		preamble = group(mit,1);
		descid = group(mit,2);
		itemname = group(mit,3);
		itemqty = group(mit,4);
		
		//it = to_item(itemname);
		it = desc_to_item(descid);
		
		//print(group(mit),"olive");
		//print(descid+" = "+itemname+" = "+it,"olive");
		
		//add quality color
		qcol=QualColor(it.quality);
		if (qcol!="") {
			itemname = "<span class="+qcol+">"+itemname+"</span>";
		}
		//Check for class restrictions
		itclass = string_modifier(itemname,"Class");
		if ( itclass!="" && my_class()!=to_class(itclass) ) {
			itemname = "<span class=strike>"+itemname+"</span>";
		}
		
		//here is where the magic happens
		if (it==$item[none]) {
			//print("Inventory WTF: item \"" + itemname + "\" not found.", "red");
		} else {
			desctext = DescItem(it);
		}
		
		replacementtext = "";
		replacementtext += preamble;
		replacementtext += itemname;
		replacementtext += "</b></a>";
		replacementtext += itemqty;
		if (desctext!="") {
			replacementtext += "<br>";
			replacementtext += descpre;
			replacementtext += desctext;
			replacementtext += descpost;
		}
		replacementtext += "<br>";
		
		page.replace_string(group(mit), replacementtext);
		
	}
	
	//Add descriptions to special invetory.php pages
	if (contains_text(page,"bgcolor=blue><b>Opening up the Folder Holder</b>")) {
		page = FolderWTF(page);
	}
	
	page = ImageWTF(page);
	
	//print("InventoryWTF load time = "+to_string(gametime_to_int()-tzero),"blue");
	//print("DONE","purple");
	
	return page;
	
}


void main() {
	buffer page;
	page.append(visit_url());
	SellStuffWTF(page).write();
}


