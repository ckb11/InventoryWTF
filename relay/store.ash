import <shopwtf.ash>;

void main() {
	//print("This is a STORE!","green");
	buffer page;
	page.append(visit_url());
	ShopWTF(page).write();
}

