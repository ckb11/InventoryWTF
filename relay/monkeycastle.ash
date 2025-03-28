import <wtf.ash>;


buffer SeamonWTF(buffer page) {
	//insert stylesheet link
	page.replace_string("</head>", "\n<link rel=\"stylesheet\" href=\"wtf.css\">\n</head>");
	
	string oldtext = "";
	string descpre = "<small class=desc>";
	string descpost = "</small>";
	string desctext = "";
	string replacementtext = "";
	
	if (contains_text(page,"<b>Big Brother</b>")) {
		string itemname = "";
		string itemqty = "";
		item it;
		
		matcher mit = create_matcher("<td><b>([^<>]*)</b>&nbsp;&nbsp;&nbsp;&nbsp;</td>",page);
		
		while (find(mit)) {
			replacementtext = "";
			desctext = "";
			oldtext = group(mit);
			itemname = group(mit,1);
			it = to_item(itemname);
			
			//here is where the magic happens
			if (it != $item[none]) { desctext = DescItem(it); }
			if (desctext != "") { desctext = "<br>"+descpre+desctext+descpost; }
			itemqty = " ("+to_string(available_amount(it))+")";
			replacementtext = "<td><b>"+itemname+"</b>"+itemqty+"&nbsp;&nbsp;&nbsp;&nbsp;"+desctext+"</td>";
			
			page.replace_string(oldtext,replacementtext);
		}
	}
	
	if (contains_text(page,"<b>Mom</b>")) {
		string effectname = "";
		effect ef;
		
		matcher mef = create_matcher("</td><td><b>(.+?)</b></td></tr></table>",page);
		
		while (find(mef)) {
			
			replacementtext = "";
			desctext = "";
			oldtext = group(mef);
			effectname = group(mef,1);
			ef = to_effect(effectname);
			
			//here is where the magic happens
			if (ef != $effect[none]) { desctext = DescEffect(ef); }
			if (desctext != "") { desctext = "<br>"+descpre+desctext+descpost; }
			replacementtext = "</td><td><b>"+effectname+"</b>"+desctext+"</td></tr></table>";
			
			page.replace_string(oldtext,replacementtext);
		}
	}
	
	page = ImageWTF(page);
	
	return page;
}


void main() {
	//print("This is a monkeycastle!","green");
	buffer page;
	page.append(visit_url());
	SeamonWTF(page).write();
}

