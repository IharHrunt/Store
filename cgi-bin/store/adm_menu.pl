#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_menu.pl
#
############################################################################

use CGI;
$q = new CGI;

require 'db.pl';

my $pathUrl =$path_cgi.'adm_menu.pl';
my $pathUrlAdm =$path_cgi.'adm.pl';
my $pathUrlAdm2 =$path_cgi.'adm_2.pl';
my $pathUrlSec =$path_cgi_https.'adm.pl';
my $pathUrlProduct =$path_cgi.'adm_product.pl';
my $pathUrlSendEmail =$path_cgi.'adm_sendemail.pl';
my $pathUrlAccount =$path_cgi_https.'adm_account.pl';
my $pathUrlTransactions = $path_cgi_https.'adm_trans.pl';
my $pathUrlJmenu = $path_cgi.'adm_jscript.pl';
$pathUpload =$path_cgi.'manager.pl';


if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

# Get params using CGI module
my $code = $q->param('code');  # code to identify admin

# Check access to enter the program
# $code is not defined
if ( $code eq '' )  { accessdenied(); return;}

# Check $code to give access to form for admin according to $com
$sql="SELECT Code, Super FROM Passw WHERE Code=$code";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check )  { accessdenied(); return; }

# Check admin status: supervisor or user and
# create string to show on the screen
if ( $super == 1 ) { $str_super= "Supervisor"; }
else { $str_super= "User"; }

my $com = $q->param('com');    # com to select form
if ( $com eq ''            ) { main(); }      # create form with frame
elsif ( $com eq 'menu'     ) { menu(); }      # create menu with closed category list
elsif ( $com eq 'menu_add' ) { menu('add'); } # create menu with opened category list
elsif ( $com eq 'help'        ) { help(); }

elsif ( $com eq 'news'    ) { news(); }
elsif ( $com eq 'Save changes' ) { news(); }


############################################################################
sub main  #17.02.2000 15:39
# Create html file with two frames: menu and main
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store Admin</TITLE>
</HEAD>
<FRAMESET COLS="20%,80%">
<FRAME SRC='$pathUrl?com=menu&code=$code'  SCROLLING='YES' NAME='_menu_adm' >
<FRAME SRC='$pathUrlAdm?code=$code' NAME='adm' >
</FRAMESET>
</HTML>
Browser

}   ##main


############################################################################
sub menu      #17.02.2000 15:39
# Create menu html file with category collapsable list
############################################################################
{


$counter='';
$str_counter="Error";

open(FILE, $path_menu_js."counter.dat");
read(FILE, $counter, 100000, 0);
close (FILE);

if ((defined $counter)&&($counter ne '')) {

  if ($counter < 10)                                 { $str_counter="00000".$counter; }
  elsif (($counter >= 10)&&($counter < 100))         { $str_counter="0000".$counter; }
  elsif (($counter >= 100)&&($counter < 1000))       { $str_counter="000".$counter; }
  elsif (($counter >= 1000)&&($counter < 10000))     { $str_counter="00".$counter; }
  elsif (($counter >= 10000)&&($counter < 100000))   { $str_counter="0".$counter; }
  elsif (($counter >= 100000)&&($counter < 1000000)) { $str_counter=$counter; }

}


#<BR><a href='$pathUrlSendEmail?comSender=Sender&code=$code' target='WinSender' onClick='windowOpenerSender()' ><FONT size='3'>Send Email</FONT></a>

print <<Browser;
Content-type: text/html\n\n
<HTML><HEAD>

<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>

<SCRIPT>


// open 'send message' in new window
function windowOpenerSender() {
  msgWindow=window.open('$pathUrl?comSender=Sender&code=$code','WinSender','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=700,height=420')
}
// open 'upload files' in new window
function windowOpenerUpload() {
  msgWindow=window.open('$pathUpload','WinUpload','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=800,height=420')
}
function set_alert() {
  if (confirm(" Log Out ? ")) { return true; }
  else {return false; }

}

</SCRIPT></HEAD>
<BODY BGCOLOR='#CCCCCC'>
<FORM NAME='form1' METHOD='POST' ACTION=$pathUrl >

<b><font size=3>Admin Menu:</font></b><br>
<b><font size=2><hr></font></b>
<a href='$pathUrlProduct?com=Listcategory&code=$code' TARGET='adm'> <FONT size='3'>Products</FONT></a>
<BR><a href='$pathUrlAccount?comEdit=Search&code=$code' TARGET='adm'><FONT size='3'>Accounts</a> (https)</FONT>
<BR><a href='$pathUrlTransactions?comEdit=Search&code=$code' TARGET='adm'><FONT size='3'>Orders</a> (https)</FONT>
<b><font size=2><hr></font></b>

<a href='$pathUrlSendEmail?comSender=Sender&code=$code' TARGET='adm' ><FONT size='3'>Send Email</FONT></a>
<BR><a href='$pathUpload' TARGET='WinUpload' onClick='windowOpenerUpload()' ><FONT size='3'>File manager</FONT></a>
<BR><a href='$pathUrl?com=news&sel=home&code=$code' TARGET='adm'><FONT size='3'>News Editor</FONT></a>
<BR><a href='$pathUrl?com=news&sel=product&code=$code' TARGET='adm'><FONT size='3'>Product News Editor</FONT></a>
<BR>
<b><font size=2><hr></font></b>
<a href='$pathUrlAdm?comCategory=Category&code=$code' TARGET='adm'><FONT size='3'>Categories</FONT></a>
<BR><a href='$pathUrlAdm?comManufacturer=Manufacturer&code=$code' TARGET='adm'><FONT size='3'>Manufacturers</FONT></a>
<BR><a href='$pathUrlAdm2?comTypeOfAvailable=TypeOfAvailable&code=$code' TARGET='adm'><FONT size='3'>Product availability</FONT></a>
<BR><a href='$pathUrlAdm?comTypeOfBusiness=TypeOfBusiness&code=$code' TARGET='adm'><FONT size='3'>Types of Business</FONT></a>
<BR><a href='$pathUrlAdm?comCreditCard=CreditCard&code=$code' TARGET='adm'><FONT size='3'>Types of Payment</FONT></a>
<BR><a href='$pathUrlAdm2?comAccount=Account&code=$code' TARGET='adm'><FONT size='3'>Account Types</FONT></a>
<BR><a href='$pathUrlJmenu?code=$code' TARGET='adm'><FONT size='3'>JS Menu Update</FONT></a>
<BR>
<b><font size=2><hr></font></b>
<a href='$pathUrlAdm?comSetup=Setup&code=$code' TARGET='adm'><FONT size='3'>Setup</FONT></a>
<BR><a href='$pathUrlSec?comPassw=Passw&code=$code' TARGET='adm'><FONT size='3'>Password</a> (https) </FONT>
<BR><a href='$pathUrlAdm?comPassw=Logout&code=$code' TARGET='_top' onClick='return set_alert()'><FONT size='3'>Log Out</FONT></a>
<BR>
<b><font size=2><hr></font></b>
<input type=hidden name=code value='$code' >
Status:<font size=2><b> $str_super</b></font><br>
Counter:<font size=2><b> $str_counter</b></font><br>

</FORM>
</BODY></HTML>
Browser

}   ##menu


############################################################################
sub news  #17.02.2000 15:39
############################################################################

{

$sel = $q->param('sel');
if ( $sel eq 'product' ) {
   $new=$path_menu_js."news_product.js";
   $str_title="Products";
}
else {
   $new=$path_menu_js."news_home.js";
   $str_title="";
}

$Line1 = $q->param('Line1');
$_=$Line1; (s/^\s+//); (s/\s+$//);  (s/\n//g);  (s/\r/ /g); (s/\t//g);  (s/\\//g);  (s/'/\\\'/g);  (s/"/\\\"/g);  $Line1=$_;
if ($Line1 ne '') { $Line1.=" "; }

if ( $com eq 'Save changes' ) {

  $Line1="var news=\"<span class=news>".$Line1."<\/span>\"\n";
  $err=0;
  unlink ($new);
  open(NEW, ">> $new") or $err=1;
  $_=$Line1;
  print NEW $_;
  close(NEW);

  if ($err==1) {
    $str_scriptvar=" alert('Error! Cannot open file for news loading!');";
  }
  else {
    $str_scriptvar=" alert('Information has been saved successfully!');";
  }
}


$Line1 = '';
open(FILE, "<$new");
while ( <FILE> ) {

    (s/^\s+//);
    (s/\s+$//);
    (s/var news="<span class=news>//g);
    (s/<\/span>"//g);
    (s/\\//g);
    $Line1.=$_;
}
close (FILE);


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>

<SCRIPT>
// set focus on Load or error
function setFocus() {
         $str_scriptvar
}
</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM NAME='form1' METHOD='POST' ACTION=$pathUrl >
<center>
<FONT SIZE=5><B>$str_title News Editor</B></font>
<br><br>
To format news report you can use HTML tags.
<input type='hidden' name=sel value='$sel'>
<br><br>
<textarea rows=15 name=Line1 cols=60>$Line1</textarea>
<br><br>

<input type='hidden' name=code value='$code'>
<input type='submit' name=com value='Save changes'>
<input type='reset' name=com value='   Reset   '>
</center>
<FORM>
</BODY>
</HTML>
Browser

}   ##news


############################################################################
sub accessdenied      #17.02.2000 15:39
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD><TITLE>Admin</TITLE></HEAD>
<BODY BGCOLOR='#CCCCCC' >
<CENTER><B>Access Denied</B></CENTER>
</BODY></HTML>

Browser

}   ##accessdenied


############################################################################
sub help  #17.02.2000 15:39
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" >
<FORM NAME=\"form1\" METHOD=\"POST\" ACTION=$pathUrl >
<center>
<FONT SIZE=4><B>Admin Help</B></font>
<br><br>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"10%\"></TH><TH width=\"80%\"></TH><TH width=\"10%\"></TH></TR>
<TR>
  <TD align=\"left\"></TD>
  <TD align=\"left\">
<b>Directories:</b>
<li>../store/banner/ - special offer images, top sellers images;
<li>../store/btn/ - buttons images;
<li>../store/html/ - html templates for the store front pages;
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TD width=\"10%\"valign=top></TD><TD width=\"75%\" valign=top>
The idea of using templates is to allow admin to update static information without programmer.
Each template file have prefix and suffix. Prefix shows what menu item the file is used for
and suffix shows for what action. For example, cart1.html - Step 1 in shopping cart,
cart2_login.html - Step 2 (if user is not logged in), cart2.html - Step 2 (user logged in).<br>
One more thing about templates. For example, you can prepare several top banners and place them
on different pages  or you can add additional information, for example, download links for specific pages
at the left or right sides(before/after special offer or new products).<br><br>
<u>How to changes static content of templates</u>.<br>
1. Using File Manager or FTP client please download template file to your local hard drive.<br>
2. Open file with any text or html editor.<br>
3. Modify file, save and upload it back to web-server.<br><br>
<u>Recommendation</u><br>
1. DO NOT CHANGE the tags &lt;&lt;something&gt;&gt;. They are used by perl for dynamic page building.<br>
2. Be careful with tags &lt;SCRIPT&gt;. They are used for executing of javascript code. <br>
3. To change content in the center of the page please find lines &lt;!-- start center page --&gt;
and &lt;!-- end center page --&gt;. They are html comments. Please add your information in
HTML format between these lines. Similar tags are used for comments of: Special Offer, New Products, Search, Login and other. <br>
4. CSS styles are in the file store.css (see below).

<br><br>
</TD></TR>
</TABLE>

<li>../store/icon/ - icons images;
<li>../store/img/ - other images (logo, background, credit cards and other);
<li>../store/js/ - javascript and css files:

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TD width=\"10%\"valign=top></TD><TD width=\"15%\"valign=top>store.css</TD><TD width=\"75%\">HTML styles. You can add your styles to this file or use existing ones. Also styles can be specified directly in html file as Microsoft Word does.</TD></TR>
<TR><TD width=\"10%\"valign=top></TD><TD width=\"15%\" valign=top>home_page.js</TD><TD width=\"75%\">
   This file is builded automatically, when admin add, update or delete
   a product. File keeps information about special offer, new products and top
   sellers for home page javascript loader. As home page is a static page we have to use such loader. All other pages are dynamic. They are compiled at web-server
and then are sent to browser;</TD></TR>
<TR><TD width=\"10%\"valign=top></TD><TD width=\"15%\"valign=top>index.url</TD><TD width=\"75%\">This file keeps index of links to pages and is used by search engine;</TD></TR>
<TR><TD width=\"10%\"valign=top></TD><TD width=\"15%\"valign=top>menu_data.js</TD><TD width=\"75%\">Cross-browser javascript menu builder (data);</TD></TR>
<TR><TD width=\"10%\"valign=top></TD><TD width=\"15%\"valign=top>menu_dom.js</TD><TD width=\"75%\">Cross-browser javascript menu builder (code);</TD></TR>
</TABLE>
<li>../store/product_html/ - HTML files with  product description/specification.
<li>../store/product_image/ - Small and big products pictures;
<li>../store/product_pdf/ - Pdf-files with full products description;
<li>../cgi-bin/store/ - perl scripts and libraries (access denied through File Manager, accessible through FTP client only);

<br><br>
<b>Setup Form:</b>
<br>
All or some of the fields of this form are used at front side of Store
for My Account, Contact Us and Shopping Cart forms. Also this information
is used when e-mail message is sending to a customer.


<br><br>
<b>Password Form:</b>
<br>
Program prevents the work of two or more admins with the same UserName at the same time. If
you wish to be sure that access to store admin is blocked after your work please <u>Log Out!</u>


<br><br>
<b>JS Menu Update Form:</b>
<br>
Javascript menu Debugger. Using of it is not reqiured. Now program re-builds javascript top menu (menu_data.js)
automatically when you add, update or delete a  product.



<br><br>
<b>Account Types, Types of Payment  Forms:</b>
<br>
Connection between customer account and types of payment is set <u>through the level of account type</u> so
be careful changing the level value for account type. Types of payment are used by account type to promt to the customer available for
him payment terms.The lowest level is 0 and is set as default for a new account. In Types of payment form for fields Description and
Conditions of Sale can be used any html tags to format text except the folowing tags: html, head, body.
If you remove a type of payment from database the program does not check
if there is an account with this type of payment as default. In this case customer has not
default type of payment. Account types is not recommended to delete.


<br><br>
<b>Types of Business Form:</b>
<br>
For Accounts. Types of Business is used to specify type of business of the customer.
When you delete any type of business the program checks and gives alert if the there is an account with this
type of business.


<br><br>
<b>Manufacturers Form:</b>
<br>
For Products. When you delete any manufacturer the program checks and gives alert if the there is a product of this
manufacturer.


<br><br>
<b>Categories Form:</b>
<br>
For Products.
When you delete any category or subcategory the program checks and gives alert if the there is a product
that belongs to this category or subcategory.


<br><br>
<b>Send Email Form:</b><br>
The form has two modes to send email messages (with attached file(s)): <br>
1. By entereing email address(es) manually; <br>
2. By selecting list of subscribers for store notifications from Account database;

<br><br>
<b>File manager Form:</b><br>
It is used instead of FTP connection. File Manager allows to work with file system of web-server.
To download file to a local hard drive please target your mouse pointer on the file you need
and click on the right button. From the menu choose \"Save Link Target As...\".
<br>
<u>Note</u>. When you are downloading file with html extention then Mozilla, Netscape and (FireFox???) can add to the file name
additional extention \".htm\". Example: \"autuc.html.htm\". You have to remove it. IE and Opera have not this bag.

<br><br>
<b>Products Form:</b><br>
Before to add product to store database you have to do the folowing steps:<br>
1. Add category/subcategory to Category form;<br>
2. Prepare product images:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.1. The product small picture;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.2. The product big picture;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.3. Top sellers product picture (if needed);<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.4. Special offer banner (if needed);<br>
3. Prepare HTML file with the product description/specification. To format text in the file you
can use any html tags except the folowing: HTML, HEAD, BODY;<br>
4. Prepare pdf file with full description/specification of the product;<br>
5. Now you can add the product to store database. Fill in all required fields and
upload image, html and pdf files.<br>
6. Available Options.<br>
7. Specify the product status:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.1. Hidden - the product is not showed at the front
side of store and jscript top menu does not show the category the product belongs to if this product
or other products in this category are hidden;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.2. Active - the product is available for the customers;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.3. New - the product is available for the customers; The difference is that all products with
this status are selected for the list NEW PRODUCTS at the right side of the store front side with the links to detailed
products description;<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.4. Special Offer - the product is available for the customers.
For the products with this status can be specified banners that are showed
at the left side of the store front side. It's not required that each product
with this status must have the banner.  Quantity of banners can be any. To add banner you have to
click on the link at the right side of the table with list of products
(plus means the product has banner, nothing - no). Special Offer Banner Uploader
is used to upload banner to web server (..store/banner/ directory) or remove it.
<u>Note</u>. Close the form with button "Exit" for reloading of home page (remember, it is static page);<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.5. Top Sellers - the product is available for the customers. It works in the same way as Special Offer does;<br>
8. Click on the button Insert to add the product to database.<br>
9. If you wish to update or delete the product you need to open the product and click on
the button at the end of the form. If you do not want to applay changes click on the
button Cancel. When you delete the product then its small and big images, html and pdf files,
special offer banner or top sellers picture are removed from the web server too.

<br><br>
<b>Accounts Form:</b><br>
The form allows:<br>
1. Select list of accounts by date of establishment. To narrow list of accounts can be
used keyword(s) search by any creteria.<br>
2. Browse personal information of the account holder.<br>
3. Browse Account History, Orders History and Wish List information of the account holder.<br>
4. Add, update or delete accounts. When you update account at the front
or back side of store the program (before to applay new changes) writes old
information into History List of the account.<br>
5. When a new account is established at the front side of store its account
type level is set 0 (default).<br>
6. If you wish to change Account type, discount level or any other account information
please open account, do changes and then click on the button Save changes.
If you decided not to apply changes simply click on the button Cancel.<br>
7. To send email to the account holder click on his(her) email address link.<br>
<u>Note</u>. If the account holder didn't specify his/her first name
then Dear Sir or Madam phrase is used for all email messages store sends to him/her.


<br><br>
<b>Orders Form:</b><br>
1. Select list of orders by date period. To narrow list of orders can be
used keyword(s) search by any creteria.<br>
2. Update or delete order.<br>
3. <u>Recommendation</u>:<br>
3.1. For Date fields please follow /yyyy-mm-dd/ format;<br>
3.2. Information about Tracking number can be added either as a plain text enter or
as A HREF link if you have got URL. <br><br> <u>Example</u>: &lt;a href='http://ups.com?id=1234567890'&gt;1234567890&lt;/a&gt;


<br><br>
---------------------------------------<br>
<font size=2>Updated: 2005-08-03</font>

</TD>
  <TD align=\"left\"></TD>
</TR>
</Table>

</center>
<FORM>
</BODY>
</HTML>
Browser

}   ##help