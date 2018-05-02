#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / account.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

$pathUrl =$path_cgi_https.'account.pl';
dbconnect();

get_cookie();

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();


#######################################################################

# set path for the forms of the current script
$pathUrlAccountLogIn =$path_cgi_http."account.pl?com=Login";
$pathUrlNewAccount =$path_cgi_https."account.pl?com=New";
$pathUrlAccountPersonal =$path_cgi_https."account.pl?com=Browse";
$pathUrlOrderHistory =$path_cgi_https."order.pl";
$pathUrlWishList =$path_cgi."wishlist.pl";
$pathUrlAccountRemove =$path_cgi_http."account.pl?com=RemoveAccount";
$pathUrlAccountLogOut =$path_cgi_http."account.pl?com=LogOut";

########################################################################

$str_menu_account_on="
    <TABLE cellSpacing=0 cellPadding=0 width=430 border=0>
    <TR><TD class=tabt width=430 background='/store/img/bgline.gif'
         height=17>&nbsp;My Account Menu</TD></TR>
    <TR><TD vAlign=top align=left width=430>

    <table border=0 width=100% cellspacing=0 cellpadding=0>
    <tr><td height=10 colspan=2 width='100%'></td></tr>
    <tr><td width='9%'></td><td><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Login</font></a> &nbsp; | &nbsp;<a href='#1'><font color=#aaaaaa>Register (New Account)</font></a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountPersonal'>&nbsp;Update My Account</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlOrderHistory'>&nbsp;Orders History</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlWishList'>&nbsp;Wish List</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountRemove' onClick = 'return checkRemove();'>&nbsp;Remove Account</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account_end.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountLogOut'>&nbsp;Logout</a></td></tr>
    </table><br>
    </TD></TR></table>";


$str_menu_account_off="
    <TABLE cellSpacing=0 cellPadding=0 width=430 border=0>
    <TR><TD class=tabt width=430 background='/store/img/bgline.gif'
         height=17>&nbsp;My Account Menu</TD></TR>
    <TR><TD vAlign=top align=left width=430>

    <table border=0 width=100% cellspacing=0 cellpadding=0>
    <tr><td height=10 colspan=2 width='100%'></td></tr>
    <tr><td width='8%'></td><td><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountLogIn'>&nbsp;Login</a> &nbsp;|&nbsp; <a href='$pathUrlNewAccount'>Register (New Account)</a></td></tr>
    <tr><td height=18 width='8%'></td><td valign=top><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Update My Account</font></a></td></tr>
    <tr><td width='8%'></td><td valign=top><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Orders History</font></a></td></tr>
    <tr><td width='8%'></td><td valign=top><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Wish List</font></a></td></tr>
    <tr><td width='8%'></td><td valign=top><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Remove Account</font></a></td></tr>
    <tr><td width='8%'></td><td valign=top><img src='/store/icon/icon_account_no_end.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Logout</font></a></td></tr>
    </table><br>
    </TD></TR></table>";


$com = $q->param('com');
if ( $com eq ''              ) { main(); }
elsif ( $com eq 'Login'      ) { accessdenied();   }
elsif ( $com eq 'Enter'    ) { main();   }
elsif ( $com eq 'Browse'     ) { newaccount();   }
elsif ( $com eq 'New'              ) { newaccount();   }
elsif ( $com eq 'Establish Account') { db_newaccount(); }
elsif ( $com eq 'Save Changes'     ) { db_newaccount(); }
elsif ( $com eq 'RemoveAccount'    ) { db_newaccount(); }
elsif ( $com eq 'RemoveAccountTop'    ) { main(); }
elsif ( $com eq 'Cancel'       ) { main(); }
elsif ( $com eq 'LogOut'       ) { main(); }
else { accessdenied(); }

############################################################################
sub accessdenied      #17.02.2000 15:39
############################################################################
{

$str_report=$_[0];
if ( $str_report ne '' ){ $str_report=$str_report;  }
$user=$_[1];
$pass=$_[2];

if ( $_[3] eq 'pass' ){ $str_scriptvar="document.form1.pass.focus();  document.form1.pass.select();"; }
else {  $str_scriptvar="document.form1.user.focus();  document.form1.user.select();"; }


$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'>My Account</A>
   &gt; <A class=PathSite  href='".$pathUrl."?com=Login'><u>Login</u></A></SPAN>";

print "Content-type: text/html\n\n";
$template_file=$path_html."html/account_login.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'str_scriptvar'}=$str_scriptvar;

$VAR{'str_report'}=$str_report;
$VAR{'user'}=$user;
$VAR{'pass'}=$pass;
$VAR{'EmailStore'}=$EmailStore;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

exit;

} ##accessdenied



############################################################################
sub main      #17.02.2000 15:39
############################################################################

{

$str_StoreLogin="";

$str_report=$_[0];

if (($com eq '')||($com eq 'Save Changes')||($com eq 'Cancel')) {

  if ( $access_key eq 'true') {
      if ( $str_report eq '') {
         if( $FirstName eq '' ) { $FirstName=$FirstNameTmp; }
         if( $FirstNameTmp eq '' ) { $FirstNameTmp='Sir or Madam'; }
      }
      if ($com eq 'Save Changes') {
         $str_report=$str_report."<br><br><u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b>";
      }
      else {
         $str_report=$str_report."<u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b>";
      }
       $str_menu_account=$str_menu_account_on;
       $str_StoreLogin="true";
  }
  else {

$str_report="
    <table border=0 width=100% cellspacing=0 cellpadding=0>
    <tr><td height=20 colspan=3 class=Account><b>By choosing to register at the Store you can:</b></td></tr>
    <tr><td valign=middle width=5><img src='/store/img/point-r.gif'></td><td valing=top width=5></td><td class=Account>Receive a better price for some of our products.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Check status and content of multiple orders, both current and past with full security.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Add items to your shopping cart to purchase them altogether and often save on shipping charges. </td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Update your account information including shipping and billing addresses, forms and types of payment tools.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Add items to you wish list for purchase at a later time or to email the list to your partner.</td></tr>
    </table>";

    $str_menu_account=$str_menu_account_off;
    $str_StoreLogin="false";
  }
}


##########################################
elsif ( $com eq 'Establish Account') {

    $str_menu_account=$str_menu_account_on;
    $str_report=$str_report."<br><br><u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b>";
    $str_login="class=collapsed";
    $str_logout="class=expanded";
    $str_StoreLogin="true";

}

elsif ($com eq 'RemoveAccount') {
    $str_menu_account=$str_menu_account_off;
    $str_login="class=expanded";
    $str_logout="class=collapsed";
    $str_StoreLogin="false";

}

elsif ($com eq 'RemoveAccountTop') {

   ##### Check Access to Account##################################
   if ( $code ne '') {

      $sql = "SELECT Id, FirstName, LastName, DateCreate, CustShifr, UNIX_TIMESTAMP(TimeExpirShifr), UNIX_TIMESTAMP()-1800
          FROM Profile WHERE CustShifr='$code' and Status=0";
      dbexecute($sql);
      ($Id, $FirstName, $LastName, $DateCreate, $CustShifrCheck, $DateShifr, $DateShifrCheck ) = dbfetch();
      if ( $code ne $CustShifrCheck )  { accessdenied("Access Denied. Please enter your Login and Password.", $user, $pass); return;  }
   }
   else  { accessdenied("Access Denied. Please enter your Login and Password.", $user, $pass); return;  }
   $str_report=" <u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b>";

   $str_menu_account_on="
    <TABLE cellSpacing=0 cellPadding=0 width=430 border=0>
    <TR><TD class=tabt width=430 background='/store/img/bgline.gif'
         height=17>&nbsp;My Account Menu</TD></TR>
    <TR><TD vAlign=top align=left width=430>

    <table border=0 width=100% cellspacing=0 cellpadding=0>
    <tr><td height=10 colspan=2 width='100%'></td></tr>
    <tr><td width='9%'></td><td><img src='/store/icon/icon_account_no.gif' width='30' height='18' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Login</font></a> &nbsp; | &nbsp;<a href='#1'><font color=#aaaaaa>Register (New Account)</font></a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountPersonal'>&nbsp;Update My Account</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlOrderHistory'>&nbsp;Orders History</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlWishList'>&nbsp;Wish List</a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountRemove' onClick = 'return checkRemove();'><font color=#ff0000>&nbsp;Remove Your Account ?</font></a></td></tr>
    <tr><td width='9%'></td><td valign=top><img src='/store/icon/icon_account_end.gif' width='30' height='18' align='absmiddle'><a href='$pathUrlAccountLogOut'>&nbsp;Logout</a></td></tr>
    </table><br>
    </TD></TR></table>";


   $str_menu_account=$str_menu_account_on;
   $str_StoreLogin="true";

}


elsif ($com eq 'LogOut') {

   if ( $code ne '') {

      $sql = "SELECT Id, FirstName, LastName, DateCreate, CustShifr, UNIX_TIMESTAMP(TimeExpirShifr), UNIX_TIMESTAMP()-1800
          FROM Profile WHERE CustShifr='$code' and Status=0";
      dbexecute($sql);
      ($Id, $FirstName, $LastName, $DateCreate, $CustShifrCheck, $DateShifr, $DateShifrCheck ) = dbfetch();
      if ( $code ne $CustShifrCheck )  { accessdenied("Access Denied. Please enter your Login and Password.", $user, $pass); return;  }
   }
   else  { accessdenied("Access Denied. Please enter your Login and Password.", $user, $pass); return;  }

   $sql = "UPDATE Profile SET CustShifr=''  WHERE  CustShifr='$code' AND Status=0";
   dbdo($sql);

   if( $FirstName eq '' ) { $FirstName='Sir or Madam'; }
    $str_report="<b>Dear $FirstName</b>,<br><br>Your Account ( <b># $AccountNumber</b> ) has been locked.";
    $str_menu_account=$str_menu_account_off;

    $str_login="class=expanded";
    $str_logout="class=collapsed";
    $str_StoreLogin="false";

}


elsif ($com eq 'Enter') {

    $user=$q->param('user');
    $pass=$q->param('pass');
    $_=$user; (s/^\s+//); (s/\s+$//); $user=$_;
    $_=$user; s/\'/\\\'/g; $user1=$_;
    $_=$pass; (s/^\s+//); (s/\s+$//); $pass=$_;
    $_=$pass; s/\'/\\\'/g; $pass1=$_;


     if ( length($user1) < 4 )  { accessdenied("Access Denied. Invalid Login", $user, $pass); return; }

       #### User ####
       $sql = "SELECT Id, CustomerID, Password FROM Profile WHERE CustomerID='$user1' and Status=0";
       dbexecute($sql);
       ($Id, $userdb, $passdb) = dbfetch();
       if ( !defined $userdb ) {
         accessdenied("Access Denied. Invalid Login.", $user, $pass); return;
       }

      if (length($pass) < 6)  { accessdenied("Access Denied. Invalid Password", $user, $pass, 'pass'); return; }
      $sql = "SELECT Id, FirstName, CustomerID, Password, DateCreate, EstabDiscountLevel FROM Profile WHERE CustomerID='$user1' and Password='$pass1' and Status=0";
      dbexecute($sql);
      ($Id, $FirstName, $userdb, $passdb, $DateCreate, $EstabDiscountLevel) = dbfetch();
       if ( defined $passdb ) {
          if (($pass ne $passdb))  { accessdenied("Access Denied. Invalid Password.", $user, $pass, 'pass' ); return; }
       }
       else { accessdenied("Access Denied. Invalid Password.", $user, $pass, 'pass' ); return; }

      $sql = "UPDATE Profile SET CustShifr=''  WHERE  CustShifr='$code' AND Status=0";
      dbdo($sql);

      #DATE_FORMAT('1997-10-04 22:23:00', 'W M Y h:i:s');
      #select FROM_UNIXTIME(UNIX_TIMESTAMP(), 'Y D M h:m:s x');
      #  -> '1997 23rd December 03:12:30 x'

      $sql = "SELECT YEAR(TimeExpirShifr), MONTH(TimeExpirShifr), DAYOFMONTH(TimeExpirShifr) 
              FROM Profile
              WHERE CustomerID='$user1' and Password='$pass1' and Status=0";
      dbexecute($sql);

      ($y, $m, $d) = dbfetch();
      if ($m <10) { $m="0".$m; }
      if ($d <10) { $d="0".$d; }

      $sql = "UPDATE Profile SET CustShifr='$code', TimeExpirShifr=NOW()
              WHERE CustomerID='$user1' and Password='$pass1' and Status=0";
      dbdo($sql);

      $CustomerID=$userdb;


      ###########################################################
      if ( $Id < 10) { $AccountNumber='000'.$Id; }
      elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
      elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
      else { $AccountNumber=$Id; }
      $curDate=$DateCreate;
      $curDate3=substr($curDate, 2 , 2);
      $curDate2=substr($curDate, 5 , 2);
      $curDate1=substr($curDate, 8 , 2);
      $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
      ##########################################################

      $str_menu_account=$str_menu_account_on;

    if( $FirstName eq '' ) { $FirstName='Sir or Madam'; }

    $str_report="<b>Dear $FirstName</b>,<br><br>
    Welcome to your account! Your last visit was  $y-$m-$d.<br><br>
    <u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b>";

    $str_login="class=collapsed";
    $str_logout="class=expanded";
    $str_StoreLogin="true";

}

$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>My Account</u></A></SPAN>";

print "Content-type: text/html\n\n";
$template_file=$path_html."html/account_main.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;
$VAR{'str_StoreLogin'}=$str_StoreLogin;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_scriptvar'}=$str_scriptvar;
$VAR{'str_report'}=$str_report;
$VAR{'str_menu_account'}=$str_menu_account;

$VAR{'strscript_new_menu'}=$strscript_new_menu;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

} ##main


############################################################################
sub newaccount      #17.02.2000 15:39
############################################################################

{

$str_menu_top="
    <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
    <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'>My Account</A> &gt; ";

$str_title="";

if (( $com eq 'Establish Account'  )||( $com eq 'New'  )){

    if ($com eq 'New'  ){  $CustomerID=''; }

    $Perspect =0; # change value from $Perspect in library.pl

    $str_menu_top.="<A class=PathSite  href='".$pathUrl."?com=New'><u>Register</u></A></SPAN>";
    $str_title="
    <table border=0 width=100% cellspacing=0 cellpadding=0>
    <tr><td height=20 colspan=3 class=Account><b>By choosing to register at the Store you can:</b></td></tr>
    <tr><td valign=middle width=5><img src='/store/img/point-r.gif'></td><td valing=top width=5></td><td class=Account>Receive a better price for some of our products.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Check status and content of multiple orders, both current and past with full security.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Add items to your shopping cart to purchase them altogether and often save on shipping charges. </td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Update your account information including shipping and billing addresses, forms and types of payment tools.</td></tr>
    <tr><td valign=middle><img src='/store/img/point-r.gif'></td><td valing=top></td><td class=Account>Add items to you wish list for purchase at a later time or to email the list to your partner.</td></tr>
    </table>";

    $str_button="<input type='hidden' name=com value='Establish Account'>
                <a href=\"javascript:checkData()\"  title=\"establish account\"><img  src=\"/store/btn/btn_establish_red.gif\" width=\"130\" height=\"20\" border=0 alt=\"establish account\"></a>";
}
else {

    $str_menu_top.="<A class=PathSite  href='".$pathUrl."?com=Browse'><u>Update My Account</u></A></SPAN>";
    $str_button="<input type='hidden' name=com value='Save Changes'>
                 <a href=\"javascript:checkData()\"  title=\"save changes\"><img  src=\"/store/btn/btn_save.gif\" width=\"97\" height=\"20\" border=0 alt=\"save changes\"></a>&nbsp;
                 <a href='".$pathUrl."?com=Cancel'  title=\"cancel\"><img  src=\"/store/btn/btn_cancel.gif\" width=\"64\" height=\"20\" border=0 alt=\"cancel\"></a>";


    ##### Check Access to Account##################################
     if ( $access_key ne 'true') {
       accessdenied("Access Denied. Please enter your Login and Password");
       return;
     }
   ###############################################################

    if ( $com eq 'Browse'  ) {
       # Select account information
       $sql="SELECT Id, CustomerID, Password, FirstName, LastName, Email,Title,
                CompanyName, Subscriber, StreetAddress, City, State, Country,
                TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                TradeReferences, Notes, EstabDiscountLevel, PaymentTerms,Phone,
                ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                ShippingPhone, Fax, Zip, ShippingFax, ShippingZip, DateCreate,Category
             FROM Profile
             WHERE  Id=$Id and Status=0";
        dbexecute($sql);
        ($Id, $CustomerID, $Password, $FirstName, $LastName, $Email, $Title, $CompanyName, $Subscriber,
         $StreetAddress, $City, $State, $Country, $TypeOfBusiness,$TypeOfBusinessSpecify,
         $CurProjShortDescription, $BankReferences, $TradeReferences, $Notes, $EstabDiscountLevel,
         $PaymentTerms, $Phone, $ShippingStreetAddress, $ShippingCity, $ShippingState,
         $ShippingCountry, $ShippingPhone, $Fax, $Zip, $ShippingFax, $ShippingZip, $DateCreate,
         $str_Category) =dbfetch();

         $Password2=$Password;

         # Checked if the Billing Address equal Shipping Address
         if (($StreetAddress eq $ShippingStreetAddress)&&($StreetAddress ne '')&&
            ($City eq $ShippingCity)&&($City ne '')&&($State ne '')&& ( $State eq $ShippingState )&&
            ($Country eq $ShippingCountry)&&($Country ne '')&&($Phone eq $ShippingPhone)&&($Phone ne ''))
         { $checked='CHECKED'; }

         $str_title="<u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b> &nbsp; <u>Discount Level</u>: <b>$EstabDiscountLevel %</b><BR>
             Required fields are marked with (<FONT COLOR='red'size=2 >*</FONT>) asterisks.";

    }


  ###########################################################
  if ( $Id < 10) { $AccountNumber='000'.$Id; }
  elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
  elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
  else { $AccountNumber=$Id; }
  $curDate=$DateCreate;
  $curDate3=substr($curDate, 2 , 2);
  $curDate2=substr($curDate, 5 , 2);
  $curDate1=substr($curDate, 8 , 2);
  $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
  ##########################################################

  $str_title="<u>Account Number</u>: <b>$AccountNumber</b> &nbsp; <u>Established</u>: <b>$DateCreate</b> &nbsp; <u>Discount Level</u>: <b>$EstabDiscountLevel %</b><BR>
             Required fields are marked with (<FONT COLOR='red'size=2 >*</FONT>) asterisks.";
}

if ($Subscriber == 1) {
    $Subscriber=" checked ";
}

my $str_message=$_[0];
my $scriptvar=$_[1];
if (  $scriptvar==1 ) { $str_scriptvar=$str_message; }
else { $str_scriptvar="document.form1.FirstName.focus();  document.form1.FirstName.select();"; }


# Create pull-boxes for the form
if ( $str_Category ne '' ) { @Category=split(/,/, $str_Category); }


#############################################
$_=$FirstName;     s/\\//g; s/\"/&quot;/g; $FirstName=$_;
$_=$LastName;      s/\\//g; s/\"/&quot;/g; $LastName=$_;
$_=$Email;         s/\\//g; s/\"/&quot;/g; $Email=$_;
$_=$Title;                   s/\\//g; s/\"/&quot;/g; $Title=$_;
$_=$CompanyName;             s/\\//g; s/\"/&quot;/g; $CompanyName=$_;

$_=$StreetAddress; s/\\//g; s/\"/&quot;/g; $StreetAddress=$_;
$_=$City;          s/\\//g; s/\"/&quot;/g; $City=$_;
$_=$State;         s/\\//g; s/\"/&quot;/g; $State=$_;
$_=$Zip;           s/\\//g; s/\"/&quot;/g; $Zip=$_;
$_=$Phone;         s/\\//g; s/\"/&quot;/g; $Phone=$_;
$_=$Fax;           s/\\//g; s/\"/&quot;/g; $Fax=$_;
$_=$ShippingStreetAddress; s/\\//g; s/\"/&quot;/g; $ShippingStreetAddress=$_;
$_=$ShippingCity;          s/\\//g; s/\"/&quot;/g; $ShippingCity=$_;
$_=$ShippingState;         s/\\//g; s/\"/&quot;/g; $ShippingState=$_;
$_=$ShippingZip;           s/\\//g; s/\"/&quot;/g; $ShippingZip=$_;
$_=$ShippingPhone;         s/\\//g; s/\"/&quot;/g; $ShippingPhone=$_;
$_=$ShippingFax;           s/\\//g; s/\"/&quot;/g; $ShippingFax=$_;

$_=$TypeOfBusiness;          s/\\//g; s/\"/&quot;/g; $TypeOfBusiness=$_;
$_=$TypeOfBusinessSpecify;   s/\\//g; s/\"/&quot;/g; $TypeOfBusinessSpecify=$_;
$_=$CurProjShortDescription; s/\\//g; s/\"/&quot;/g; $CurProjShortDescription=$_;
$_=$BankReferences;          s/\\//g; s/\"/&quot;/g; $BankReferences=$_;
$_=$TradeReferences;         s/\\//g; s/\"/&quot;/g; $TradeReferences=$_;
$_=$EstabDiscountLevel;      s/\\//g; s/\"/&quot;/g; $EstabDiscountLevel=$_;
$_=$Notes;                   s/\\//g; s/\"/&quot;/g; $Notes=$_;

if ($CurProjShortDescription ne '') { $CurProjShortDescription.=" "; }
if ($BankReferences ne '') { $BankReferences.=" "; }
if ($TradeReferences ne '') { $TradeReferences.=" "; }
if ($Notes ne '') { $Notes.=" "; }


$_=$CustomerID;       s/\\//g; s/\"/&quot;/g; $CustomerID=$_;
$_=$Password;         s/\\//g; s/\"/&quot;/g; $Password=$_;
$_=$Password2;        s/\\//g; s/\"/&quot;/g; $Password2=$_;

#############################################

print "Content-type: text/html\n\n";
$template_file=$path_html."html/account_personal.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_scriptvar'}=$str_scriptvar;

$VAR{'FirstName'}=$FirstName;
$VAR{'LastName'}=$LastName;
$VAR{'Title'}=$Title;
$VAR{'CompanyName'}=$CompanyName;
$VAR{'Email'}=$Email;
$VAR{'str_select4'}=paymentterms_box_new($PaymentTerms, 1, $Perspect);
$VAR{'Subscriber'}=$Subscriber;

$VAR{'StreetAddress'}=$StreetAddress;
$VAR{'City'}=$City;
$VAR{'str_select2'}=state_box($State, 0, 1);
$VAR{'str_select3'}=country_box($Country, 0, $Perspect);
$VAR{'Phone'}=$Phone;
$VAR{'Fax'}=$Fax;
$VAR{'Zip'}=$Zip;
$VAR{'Checked'}=$checked;

$VAR{'ShippingStreetAddress'}=$ShippingStreetAddress;
$VAR{'ShippingCity'}=$ShippingCity;
$VAR{'str_select21'}=state_box($ShippingState, 1, 1);
$VAR{'str_select31'}=country_box($ShippingCountry, 1, 1);
$VAR{'ShippingPhone'}=$ShippingPhone;
$VAR{'ShippingFax'}=$ShippingFax;
$VAR{'ShippingZip'}=$ShippingZip;

$VAR{'str_select5'}=cust_category_box_new(@Category);

$VAR{'str_select1'}=type_of_business_box($TypeOfBusiness, 1);
$VAR{'TypeOfBusinessSpecify'}=$TypeOfBusinessSpecify;
$VAR{'CurProjShortDescription'}=$CurProjShortDescription;
$VAR{'BankReferences'}=$BankReferences;
$VAR{'TradeReferences'}=$TradeReferences;
$VAR{'Notes'}=$Notes;

$VAR{'CustomerID'}=$CustomerID;
$VAR{'Password'}=$Password;
$VAR{'Password2'}=$Password2;

$VAR{'str_button'}=$str_button;

$VAR{'str_title'}=$str_title;
$VAR{'str_report'}=$str_report;
$VAR{'AccountNumber'}=$AccountNumber;
$VAR{'DateCreate'}=$DateCreate;
$VAR{'CustShifr'}=$CustShifr;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

} ##newaccount


############################################################################
sub db_newaccount      #17.02.2000 15:39
############################################################################

{

# Get data of the selected Customer
$CustomerID=$q->param('CustomerID');
$Password=$q->param('Password');
$Password2=$q->param('Password2');
$FirstName=$q->param('FirstName');
$LastName=$q->param('LastName');
$Email=$q->param('Email');
$Title=$q->param('Title');
$CompanyName=$q->param('CompanyName');
$Subscriber=$q->param('Subscriber');
if ($Subscriber eq '') { $Subscriber=0; }

# Billing Address
$City=$q->param('City');
$State=$q->param('State');
$Country=$q->param('Country');
$StreetAddress=$q->param('StreetAddress');
$Zip=$q->param('Zip');
$Phone=$q->param('Phone');
$Fax=$q->param('Fax');

# Shipping Address
$ShippingStreetAddress=$q->param('ShippingStreetAddress');
$ShippingCity=$q->param('ShippingCity');
$ShippingState=$q->param('ShippingState');
$ShippingCountry=$q->param('ShippingCountry');
$ShippingZip=$q->param('ShippingZip');
$ShippingPhone=$q->param('ShippingPhone');
$ShippingFax=$q->param('ShippingFax');

$TypeOfBusiness=$q->param('TypeOfBusiness');
$TypeOfBusinessSpecify=$q->param('TypeOfBusinessSpecify');
$CurProjShortDescription=$q->param('CurProjShortDescription');
$BankReferences=$q->param('BankReferences');
$TradeReferences=$q->param('TradeReferences');
$Notes=$q->param('Notes');
$PaymentTerms=$q->param('PaymentTerms');

# Get Category interested in
@Category=$q->param('Category');
$i=0;
foreach (@Category) {
   $i++;
   if ( $i==1 ) { $str_Category.=$_; }
   else { $str_Category.=",".$_; }
}

$Perspect = 0;
$Status = 0;

$CustShifr=$q->param('CustShifr');

# check fields before enter database
#############################################
$_=$FirstName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $FirstName=$_;
$_=$LastName;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $LastName=$_;
$_=$Email;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Email=$_;
$_=$Title;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Title=$_;
$_=$CompanyName;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CompanyName=$_;

$_=$StreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StreetAddress=$_;
$_=$City;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
$_=$State;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $State=$_;
$_=$Zip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
$_=$Phone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
$_=$Fax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
$_=$ShippingStreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingStreetAddress=$_;
$_=$ShippingCity;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingCity=$_;
$_=$ShippingState;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingState=$_;
$_=$ShippingZip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingZip=$_;
$_=$ShippingPhone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingPhone=$_;
$_=$ShippingFax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingFax=$_;

$_=$TypeOfBusiness;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TypeOfBusiness=$_;
$_=$TypeOfBusinessSpecify;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TypeOfBusinessSpecify=$_;
$_=$CurProjShortDescription;(s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CurProjShortDescription=$_;
$_=$BankReferences;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $BankReferences=$_;
$_=$TradeReferences;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TradeReferences=$_;
$_=$EstabDiscountLevel;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $EstabDiscountLevel=$_;
$_=$Notes;                  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Notes=$_;

$_=$CustomerID;      (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CustomerID=$_;
$_=$Password;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password=$_;
$_=$Password2;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password2=$_;
#############################################


if (( $com eq 'Establish Account'  )||( $com eq 'Save Changes'  )) {

   if (&email_check($Email)==0) {
     newaccount("document.form1.Email.focus();  document.form1.Email.select();
     alert('Incorrect Email Address!')", 1 );
     return;
   }

}## end checking

if ( $com eq 'Establish Account'  ){

   ##### Check User Name
   $sql="SELECT CustomerID FROM Profile WHERE CustomerID='$CustomerID'";
   dbexecute($sql);
   ($CustomerID_check) =dbfetch();
   if (defined $CustomerID_check) {
     newaccount("document.form1.CustomerID.focus();  document.form1.CustomerID.select();
     alert('This Login is used by other user. Please choose another Login.')", 1 );
     return;
   }

  $DateCreate=get_date();

  $sql = "UPDATE Profile SET CustShifr=''  WHERE  CustShifr='$code' AND Status=0";
  dbdo($sql);

  $sql="INSERT INTO Profile (
            CustomerID , Password , FirstName, LastName, Email, Title,
            CompanyName, Subscriber, StreetAddress, City, State, Country,
            TypeOfBusiness, TypeOfBusinessSpecify,
            CurProjShortDescription, BankReferences,TradeReferences, Notes,
            EstabDiscountLevel, PaymentTerms, Status, Phone,
            ShippingStreetAddress, ShippingCity,
            ShippingState, ShippingCountry, ShippingPhone,
            Fax, Zip, ShippingFax, ShippingZip, DateCreate,
            Category, Perspect, CustShifr, TimeExpirShifr
 )

     VALUES ('$CustomerID','$Password', '$FirstName', '$LastName', '$Email','$Title',
            '$CompanyName', $Subscriber, '$StreetAddress', '$City','$State','$Country',
            '$TypeOfBusiness', '$TypeOfBusinessSpecify',
            '$CurProjShortDescription','$BankReferences', '$TradeReferences','$Notes',
            0,'$PaymentTerms', 0 ,'$Phone',
            '$ShippingStreetAddress', '$ShippingCity',
            '$ShippingState','$ShippingCountry', '$ShippingPhone',
            '$Fax', '$Zip', '$ShippingFax', '$ShippingZip', '$DateCreate',
            '$str_Category', 0, '$code', NOW()  )";

  if (dbdo($sql)) {

  $sql = "SELECT Id
          FROM Profile WHERE CustomerID='$CustomerID' and Password='$Password' and Status=0";
  dbexecute($sql);
  ($Id ) = dbfetch();

  ###########################################################
  if ( $Id < 10) { $AccountNumber='000'.$Id; }
  elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
  elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
  else { $AccountNumber=$Id; }
  $curDate=$DateCreate;
  $curDate3=substr($curDate, 2 , 2);
  $curDate2=substr($curDate, 5 , 2);
  $curDate1=substr($curDate, 8 , 2);
  $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
  ##########################################################

  if ($FirstName eq '') { $FirstName='Sir or Madam'; }

           my $mail_to = $EmailStore;
           my $from = $EmailStore;
           my $subj = "New Account # $AccountNumber has been established";
           my $body = "
Dear Admin,\n
New Account # $AccountNumber has been established.\n";

send_mail($mail_to,$from,$subj,$body,"text");

      $mail_to = $Email;
      $from = $EmailStore;
      $subj = "$NameStore messenger";
      $body = "
Dear $FirstName,

Your account at $NameStore has been established. Your account Number is $AccountNumber.
Below is your Login Information:
  Login = $CustomerID 
  Password  = $Password 
We recommend that you save this information. If you have any questions
please contact our Customer Service at $EmailStore.

Thank you for the interest in our services.

$NameDirector,
Customer Service Representative
$NameStore
$EmailStore
";

  send_mail($mail_to,$from,$subj,$body,"text");
  main("<b>Dear $FirstName</b>,<br><br> Your account has been established successfully. E-mail with confirmation has been sent to the address you specified in your account.
                Hope our business will be useful you!</b>"); return ;
}
else  {
  newaccount ("document.form1.FirstName.focus();  document.form1.FirstName.select();
  alert('Database error. The record has not been inserted !')", 1 );
  return ;
  }
}

elsif ( $com eq 'Save Changes'  ){


  ###### Check Access
  if ( $access_key ne 'true') {
      accessdenied("Access Denied. Please enter your Login and Password");  return;
  }
  ##### Check User Name
  if ($CustomerID ne '') {
    $sql="SELECT Id FROM Profile WHERE CustomerID='$CustomerID'";
    dbexecute($sql);

    while(($Id_check) =dbfetch()) {
      if ($Id_check ne $Id) {
        newaccount("document.form1.CustomerID.focus();  document.form1.CustomerID.select();
        alert('This Login is used by other user. Please choose another Login.')", 1 );
        return;
      }
    }
  }

   $DateCreateOld=get_date();

   $sql="INSERT INTO Profile_Old ( Id_Parent, CustomerID, Password, FirstName, LastName, Email, Title,
                    CompanyName, Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip, Status, DateCreate,
                    Category, Perspect, Notes  )
             SELECT Id, CustomerID, Password, FirstName, LastName, Email, Title,
                    CompanyName, Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip, Status, '$DateCreateOld',
                    Category, Perspect, Notes
             FROM Profile
             WHERE Id=$Id ";
   dbdo($sql);


   $sql="UPDATE Profile SET CustomerID='$CustomerID',Password='$Password',
                FirstName='$FirstName', LastName='$LastName', Email='$Email', Title='$Title',
                CompanyName='$CompanyName', Subscriber=$Subscriber, StreetAddress='$StreetAddress',City='$City',
                State='$State', Country='$Country',TypeOfBusiness='$TypeOfBusiness',
                CurProjShortDescription='$CurProjShortDescription',BankReferences='$BankReferences',
                TradeReferences='$TradeReferences', Notes='$Notes',
                PaymentTerms='$PaymentTerms',TypeOfBusinessSpecify='$TypeOfBusinessSpecify',
                Phone='$Phone', ShippingStreetAddress='$ShippingStreetAddress',
                ShippingCity='$ShippingCity', ShippingState='$ShippingState',
                ShippingCountry='$ShippingCountry', ShippingPhone='$ShippingPhone',
                ShippingZip='$ShippingZip',ShippingFax='$ShippingFax',
                Zip='$Zip', Fax='$Fax',Category ='$str_Category'

          WHERE Id=$Id";
  if (dbdo($sql)) {

  ###########################################################
  if ( $Id < 10) { $AccountNumber='000'.$Id; }
  elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
  elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
  else { $AccountNumber=$Id; }
  $curDate=$DateCreate;
  $curDate3=substr($curDate, 2 , 2);
  $curDate2=substr($curDate, 5 , 2);
  $curDate1=substr($curDate, 8 , 2);
  $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
  ##########################################################

  if ($FirstName eq '') { $FirstName='Sir or Madam'; }


      ##### to ADmin #####
      $mail_to = $EmailStore;
      $from = $EmailStore;
      $subj = "Account # $AccountNumber has been modified";
      $body = "
Dear Admin,\n
Account # $AccountNumber has been modified.\n";

send_mail($mail_to,$from,$subj,$body,"text");

    ##### to Account #######
      $mail_to = $Email;
      $from = $EmailStore;
      $subj = "$NameStore messenger";
      $body = "
Dear $FirstName,

Your account at $NameStore # $AccountNumber has been modified and saved.
If you have any questions please contact our Customer Service at $EmailStore.
Thank you for the interest in our services.

$NameDirector,
Customer Service Representative
$NameStore
$EmailStore
";

  send_mail($mail_to,$from,$subj,$body,"text");
  main("<b>Dear $FirstName</b>,<br><br> Your Account has been updated successfully. E-mail with confirmation has been sent to the address you specified in your account.  "); return ;
  }
  else {
     # Return to previous form ('Modify') with error  message
     newaccount("document.form1.FirstName.focus();  document.form1.FirstName.select();
     alert('Database error. The record has not been saved !')", 1 );
     return;
  }
}

elsif ( $com eq 'RemoveAccount'  ){

  ###### Check Access
  if ( $access_key ne 'true') {
      accessdenied("Access Denied. Please enter your Login and Password");  return;
  }

  $sql="SELECT FirstName, Email FROM Profile WHERE Id=$Id"; 
  dbexecute($sql);
  ($FirstName, $Email)=dbfetch();

  ### Remove Account
  $sql="UPDATE Profile SET CustShifr='', Status=1  WHERE Id=$Id";

  if (dbdo($sql)) {

  ###########################################################
  if ( $Id < 10) { $AccountNumber='000'.$Id; }
  elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
  elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
  else { $AccountNumber=$Id; }
  $curDate=$DateCreate;
  $curDate3=substr($curDate, 2 , 2);
  $curDate2=substr($curDate, 5 , 2);
  $curDate1=substr($curDate, 8 , 2);
  $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
  ##########################################################


  if ($FirstName eq '') { $FirstName='Sir or Madam'; }

    ##### to ADmin #####
    my $mail_to = $EmailStore;
    my $from = $EmailStore;
    my $subj = "Account # $AccountNumber has been removed";
    my $body = "
Dear Admin,\n
Account # $AccountNumber has been removed from database.\n";

send_mail($mail_to,$from,$subj,$body,"text");

      ##### to Account #######
      $mail_to = $Email;
      $from = $EmailStore;
      $subj = "$NameStore messenger";
      $body = "
Dear $FirstName,

Your account (# $AccountNumber) has been removed from $NameStore database.

$NameDirector,
Customer Service Representative
$NameStore
$EmailStore
";
    
     send_mail($mail_to,$from,$subj,$body,"text");
     main("<b>Dear $FirstName</b>,<br><br> Your account (# $AccountNumber) has been removed from database.
         E-mail with confirmation has been sent to the address you specified in your account."); return ;
  }
  else {
     # Return to previous form ('Modify') with error  message
     newaccount("document.form1.FirstName.focus();  document.form1.FirstName.select();
     alert('Database error. The record has not been removed !')", 1 );
     return;
  }
}
    
} ##db_newaccount