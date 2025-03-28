/******************************************************************************
SHOPS WTF relay script  And STORES too!
******************************************************************************/
import <wtf.ash>;


boolean NotNeeded(item it) {
	//stuff we ever need 1 of in run
	static {
		boolean[item] shoplist;
		shoplist = $items[
		The Big Book of Pirate Insults,
		Massive Manual of Marauder Mockery,
		Boris's key,
		Jarlsberg's key,
		Sneaky Pete's key,
		Richard's star key,
		UV-resistant compass,
		];
	}
	
	if ((shoplist contains it) && available_amount(it)>0 && !can_interact()) { return true; }
	return false;
}


buffer ShopWTF(buffer page) {
	//insert stylesheet link
	page.replace_string("</head>", "\n<link rel=\"stylesheet\" href=\"wtf.css\">\n</head>");
	
	string oldtext = "";
	string descpre = "<small class=desc>";
	string descpost = "</small>";
	string desctext = "";
	string replacementtext = "";
	string preamble = "";
	string itemname = "";
	string itemqty = "";
	string postamble = "";
	string itclass = "";
	string qcol = "";
	string buybutton = "";
	item it;
	skill sk;
	
	//This is a hack/fix for the mayo page
	string mwhip = "<b>miracle whip<font color=red size=-2><b>Only 1 left in stock!</b></font></b>&nbsp;&nbsp;&nbsp;&nbsp;</a>";
	page.replace_string("<b>miracle whip<font color=red size=-2><b>Only 1 left in stock!</b></font></b>&nbsp;&nbsp;&nbsp;&nbsp;</a>", "<b>miracle whip</b>&nbsp;</a><br><font color=red size=-2><b>Only 1 left in stock!</b></font>");
	
	//matcher mit = create_matcher("<a on.+?<b>(.+?)</b>",page);
	matcher mit = create_matcher("(<a on.+?)<b>([^<>]*)</b>(.*?</a>)",page);
	//regex                       1:pre        2:item      3:post
	
	while (find(mit)) {
		//print(group(mit),"olive");
		replacementtext = "";
		desctext = "";
		preamble = group(mit,1);
		itemname = group(mit,2);
		postamble = group(mit,3);
		oldtext = preamble+"<b>"+itemname+"</b>"+postamble;
		it = to_item(itemname);
		sk = to_skill(itemname);
		
		//here is where the magic happens
		if (false && sk != $skill[none]) {
			//print("Shop WTF: skill \"" + itemname + "\" decoded.","olive");
			desctext = DescSkill(sk) + DescEffect(to_effect(sk));
		} else if (it == $item[none]) {
			//print("Shop WTF: item \"" + itemname + "\" not found.","red");
		} else {
			//print(it,"olive");
			desctext = DescItem(it);
		}
		
		itemname = "<b>"+itemname+"</b>";
		//remove once per run buy buttons
		if (NotNeeded(it)) {
			int nn = to_int(it);
			matcher mbt = create_matcher("tr rel=\""+nn+"\".+?"+itemname+".+?(<input class=\"button.+?>)",page);
			if (find(mbt)) { page.replace_string(group(mbt, 1), ""); }
			//print("removing "+it,"olive");
		}
		
		itemqty = " ("+to_string(available_amount(it))+")";
		//highlight quest items
		if (it.quest) {
			itemname = "<b class=questitem>"+itemname+"</b>";
		}
		//add quality color
		qcol = QualColor(it.quality);
		if (qcol != "") {
			itemname = "<b class="+qcol+">"+itemname+"</b>";
		}
		//Check for skills from skill items/books
		if (contains_text(desctext,"Skill:")) {
			if (have_skill(skill_modifier(it,"Skill"))) {
				itemname = "<b class=itcool>"+itemname+"</b>";
			}
		}
		//add item inventory qty
		itemname = itemname+itemqty;
		if (desctext != "") {
			desctext = "<br>"+descpre+desctext+descpost;
		}
		
		page.replace_string(oldtext, preamble+itemname+postamble+desctext);
	}
	
	page = ImageWTF(page);
	
	return page;
}


void main() {
	buffer page;
	page.append(visit_url());
	page = ShopWTF(page);
	write(page);
}


/*
STORES:
Uncle P's Antiques
The Smacketeria
Gouda's Grimoire and Grocery
The Shadowy Store
Black Market
White Citadel
The Bugbear Bakery
Gno-Mart
Nervewrecker's Store
The Degrassi Knoll Bakery and Hardware Store
Little Canadia Jewelers
The Armory and Leggery
The Market
The Meatsmith
Barrrtleby's Barrrgain Bookstore
The Hippy Produce Stand
The Organic Produce Stand
The Tweedleporium

SHOPS:
Wintergarden
Star Chart
sugar sheet

Freshwater Fishbonery
Worse Homes and Gardens

*/




