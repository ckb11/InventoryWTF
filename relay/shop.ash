import <shopwtf.ash>;

void main() {
	//print("This is a SHOP!","green");
	buffer page;
	page.append(visit_url());
	page = ShopWTF(page);
	write(page);
}

