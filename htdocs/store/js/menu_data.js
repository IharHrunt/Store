var theMenu = new Array();
theMenu[0] = new Array("myMenu1","menu1");
theMenu[1] = new Array("myMenu2","menu2");
theMenu[2] = new Array("myMenu3","menu3");
theMenu[3] = new Array("myMenu4","menu4");
theMenu[4] = new Array("myMenu5","menu5");
theMenu[5] = new Array("myMenu6","menu6");
theMenu[6] = new Array("myMenu7","menu7");
theMenu[7] = new Array("myMenu8","menu8");

var myMenu1 = new Array();
var myMenu5 = new Array();
var myMenu8 = new Array();

var myMenu3 = new Array();
myMenu3[0] = new Array("L"," Glossary of satellite communication","","http://store.com/cgi-bin/cgiwrap/store/store/resources.pl?com=1");
//myMenu3[1] = new Array("L"," Introduction to theory and practice of earth satellite stations","","http://store.com/cgi-bin/cgiwrap/store/store/resources.pl?com=2");
//myMenu3[2] = new Array("L"," Satellite operators","","http://store.com/cgi-bin/cgiwrap/store/store/resources.pl?com=3");
//myMenu3[3] = new Array("L"," Literature","","http://store.com/cgi-bin/cgiwrap/store/store/resources.pl?com=4");

var myMenu4 = new Array();
if (log =="true") {
myMenu4[0] = new Array("C"," Register","","");
myMenu4[1] = new Array("C"," Login","","");
myMenu4[2] = new Array("S"," ","","");
myMenu4[3] = new Array("L"," Update my account","","https://store.com/cgi-bin/cgiwrap/store/store/account.pl?com=Browse");
myMenu4[4] = new Array("L"," Orders history","","https://store.com/cgi-bin/cgiwrap/store/store/order.pl");
myMenu4[5] = new Array("L"," My wish list ","","http://store.com/cgi-bin/cgiwrap/store/store/wishlist.pl");
myMenu4[6] = new Array("L"," Remove my account","","http://store.com/cgi-bin/cgiwrap/store/store/account.pl?com=RemoveAccountTop");
myMenu4[7] = new Array("S"," ","","");
myMenu4[8] = new Array("L"," Logout","","http://store.com/cgi-bin/cgiwrap/store/store/account.pl?com=LogOut");

}
else {
myMenu4[0] = new Array("L"," Register","","https://store.com/cgi-bin/cgiwrap/store/store/account.pl?com=New");
myMenu4[1] = new Array("L"," Login","","http://store.com/cgi-bin/cgiwrap/store/store/account.pl?com=Login");
myMenu4[2] = new Array("S"," ","","");
myMenu4[3] = new Array("C"," Update my account","","");
myMenu4[4] = new Array("C"," Orders history","","");
myMenu4[5] = new Array("C"," My wish list ","","");
myMenu4[6] = new Array("C"," Remove my account","","");
myMenu4[7] = new Array("S"," ","","");
myMenu4[8] = new Array("C"," Logout","","");
}
  
var myMenu6 = new Array();
myMenu6[0] = new Array("L"," Why register at Store?","","http://store.com/cgi-bin/cgiwrap/store/store/help.pl?com=1");
myMenu6[1] = new Array("L"," Customer service","","http://store.com/cgi-bin/cgiwrap/store/store/help.pl?com=2");
myMenu6[2] = new Array("L"," Return/Exchange policy","","http://store.com/cgi-bin/cgiwrap/store/store/help.pl?com=3");

var myMenu7 = new Array();
myMenu7[0] = new Array("L"," Partners","","http://store.com/cgi-bin/cgiwrap/store/store/partner.pl?com=1");
myMenu7[1] = new Array("L"," Links and Resources","","http://store.com/cgi-bin/cgiwrap/store/store/partner.pl?com=2");
myMenu7[2] = new Array("L"," Competitors","","http://store.com/cgi-bin/cgiwrap/store/store/partner.pl?com=3");
var myMenu2 = new Array();
myMenu2[0] = new Array("M"," Block Downconverters (LNBs)","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=22","menu20");
myMenu2[1] = new Array("M"," Block Upconverters (BUCs)","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=21","menu21");
myMenu2[2] = new Array("S","","");
myMenu2[3] = new Array("L"," New Products","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=New");
myMenu2[4] = new Array("L"," Special Offer","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=Special");
myMenu2[5] = new Array("L"," Top Sellers","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=Top");
var menu20 = new Array();
menu20[0] = new Array("L"," C-Band","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=22&SelSubCat=23");
menu20[1] = new Array("L"," Ku-Band","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=22&SelSubCat=22");
var menu21 = new Array();
menu21[0] = new Array("L"," C-Band","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=21&SelSubCat=20");
menu21[1] = new Array("L"," Ku-Band","","http://localhost/cgi-bin/store/product.pl?com=Product&SelCat=21&SelSubCat=19");
sc2=1;