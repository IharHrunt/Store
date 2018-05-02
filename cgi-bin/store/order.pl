#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / about.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

$pathUrl =$path_cgi_https."order.pl";
$pathUrlAccount =$path_cgi_https."account.pl";

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

my $com=$q->param('com');
if ( $com eq 'Order'       ) { order(); }
elsif ( $com eq 'Printer'     ) { order(); }
else { list(); }

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
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlAccount'>My Account</A>
   &gt; <A class=PathSite  href='".$pathUrl."'><u>Orders History</u></A></SPAN>";

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
sub list      #17.02.2000 15:39
############################################################################

{

 if ( $access_key ne 'true') {
   accessdenied("Access Denied. Please enter your Login and Password");
   return;
 }


$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlAccount'>My Account</A>
   &gt; <A class=PathSite  href='".$pathUrl."'><u>Orders History</u></A></SPAN>";



$str_table="
   <table border=\"0\" width=\"594\" cellspacing=\"0\" cellpadding=\"2\" align=center>
   <TR><td align=left bgcolor='#468499' height=17>&nbsp;&nbsp;&nbsp;&nbsp;<font color=\"#ffffff\"><b>Orders History</b></font></td></TR>
   <TR><td align=left  height=17>$str_menu_top</td></TR></table>

 <TABLE cellSpacing=1 cellPadding=0 width=594 align=center  border=0 valign=MIDDLE>
 <TR>
 <TD height=18 width=42 bgcolor='#468499' class=Account align=middle ><font color='#ffffff'><b>N</b></font></TD>
 <TD height=18 width=112 bgcolor='#468499' class=Account align=middle ><font color='#ffffff'><b>Order #</b></font></TD>
 <TD width=106 bgcolor='#468499' class=Account align=middle ><font color='#ffffff'><b>Date</b></font></TD>
 <TD width=200 bgcolor='#468499' class=Account align=middle ><font color='#ffffff'><b>Type of payment</b></font></TD>
 <TD width=112 bgcolor='#468499' class=Account align=middle ><font color='#ffffff'><b>Total&nbsp;</b></font></TD>
 </TR>";


$sql="SELECT Id, StoreOrderNumber, PurchasingOrderNumber,
             FirstName, LastName, Email, Title, CompanyName,
             StreetAddress, City, State, Country, Phone, Zip, Fax,
             ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
             ShippingPhone, ShippingZip, ShippingFax,
             EstabDiscountLevel,
             CreditCard, DatePurchased,
             DateShipped, DatePaymentDue, DatePaymentReceived,
             ShippedVia, TrackingNumber
FROM Transactions
WHERE Profile=$IdAccount and Status=0
ORDER BY Id DESC";
dbexecute($sql);

$j=0;

while (($IdTrans, $StoreOrderNumber,$PurchasingOrderNumber,
  $FirstName,$LastName,$Email, $Title, $CompanyName,
  $StreetAddress, $City,$State,$Country,
  $Phone,$Zip, $Fax,
  $ShippingStreetAddress, $ShippingCity,$ShippingState,$ShippingCountry,
  $ShippingPhone,$ShippingZip, $ShippingFax,
  $EstabDiscountLevelOrder,
  $CreditCard, $DatePurchased,
  $DateShipped, $DatePaymentDue, $DatePaymentReceived,
  $ShippedVia, $TrackingNumber) =dbfetch()) {
  $j++;

  if ($DateShipped =='0000-00-00') { $DateShipped=''; }
  if ($DatePaymentDue =='0000-00-00') { $DatePaymentDue=''; }
  if ($DatePaymentReceived =='0000-00-00') { $DatePaymentReceived=''; }

  $str_table.="";

 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,  Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Trans = $IdTrans
       ORDER BY Id";

 $cursor1=$dbh->prepare($sql);
 $cursor1->execute;

 while (( $IdOrderList, $ProductId, $ProductNumber, $ProductName, $OptionId, $Quantity, $Price, $Code, $Trans, $Status )=$cursor1->fetchrow_array) {

    if ( $Status == 0 ) {
      $Amount=sprintf("%.2f", ($Price*$Quantity));  # Amount result
      $SubTotal = $SubTotal + $Amount;
    }

    $sql="SELECT Id, ProductNumber, OptionId, OptionName, OptionDescription, Quantity, Price
          FROM OrderList
          WHERE Trans=$IdTrans and OptionId >0 and ProductId=$ProductId and Status=0
          ORDER BY Id";
         $cursor2=$dbh->prepare($sql);
         $cursor2->execute;

     while (( $IdOrderList, $ProductNumber, $OptionId, $OptionName, $OptionDescription, $Quantity, $Price) = $cursor2->fetchrow_array) {

         $Amount=sprintf("%.2f", ($Price*$Quantity));  # Amount result
         $SubTotal = $SubTotal + $Amount;
     }
     $i++;
 }

 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevelOrder =sprintf("%.2f", $EstabDiscountLevelOrder);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevelOrder/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);

 $str_table.="
    <TR>
    <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center>$j</TD>
    <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center><a href='".$pathUrl."?com=Order&IdTrans=$IdTrans' title='order details' class=mr4><img src=/store/icon/icon_lupa_small.gif width=9 heigh=9 border=0>&nbsp;<u>$StoreOrderNumber</u></a></TD>
    <TD bgcolor=\"#f0f6f9\" class=Account align=center>$DatePurchased</TD>
    <TD bgcolor=\"#f0f6f9\" class=Account align=center>$CreditCard</TD>
    <TD bgcolor=\"#f0f6f9\" class=Account align=right>\$ $Total&nbsp;</TD>
    </TR>
    ";
}

$str_table.="</table>";

if($j == 0) {
   $str_table="
   <table border=\"0\" width=\"600\" cellspacing=\"0\" cellpadding=\"0\" align=center>
   <TR><td align=left bgcolor='#468499' height=18 >&nbsp;&nbsp;&nbsp;&nbsp;<font color=\"#ffffff\"><b>Orders History</b></font></td></TR>
   <TR><td align=left  height=20></td></TR>
   <TR><td align=center  class=Account><b><font color=#ff0000>Your Orders History is empty</font></b></td></TR>
   <TR><td align=left  height=20></td></TR>
   <TR><td bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td></TR>
   </table>";
}
else {
   $str_table.="
   <table border=\"0\" width=\"600\" cellspacing=\"0\" cellpadding=\"0\" align=center>
   <TR><td align=left width=600  class=Account></td></TR>
   <TR><td align=left  height=25></td></TR>
   <TR><td bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td></TR>
   </table>";
}


print "Content-type: text/html\n\n";
$template_file=$path_html."html/order.html";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;
$VAR{'str_table'}=$str_table;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##list


############################################################################
sub order      #17.02.2000 15:39
############################################################################

{

 if ( $access_key ne 'true') {
   accessdenied("Access Denied. Please enter your Login and Password");
   return;
 }


  if ( $com eq 'Printer' )  {
     $str_bg_class="class=Printer";
     $str_bg_class2="class=Printer";
     $str_class="class=Printer";
     $str_border=1;
  }
  else   {
     $str_class="class=Account";
     $str_bg_class="bgcolor=\"#d8e9f0\" class=Account";
     $str_bg_class2="bgcolor=\"#f0f6f9\" class=Account";
     $str_border=0;
  }

my $IdTrans=$q->param('IdTrans');
my $Print=$q->param('Print');
my $StoreOrderNumberMenu;

$str_table='';
$sql="SELECT StoreOrderNumber, PurchasingOrderNumber,
             FirstName, LastName, Email, Title, CompanyName,
             StreetAddress, City, State, Country, Phone, Zip, Fax,
             ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
             ShippingPhone, ShippingZip, ShippingFax,
             EstabDiscountLevel,
             CreditCard, DatePurchased,
             DateShipped, DatePaymentDue, DatePaymentReceived,
             ShippedVia, TrackingNumber,
             CreditCardType, CreditCardNumber, ExpirationMonth, ExpirationYear,
             SecurityCode, NameOnCard

FROM Transactions
WHERE Profile=$IdAccount and Id=$IdTrans
ORDER BY Id DESC";
dbexecute($sql);

($StoreOrderNumber, $PurchasingOrderNumber,
  $FirstName,$LastName,$Email, $Title, $CompanyName,
  $StreetAddress, $City,$State,$Country,
  $Phone,$Zip, $Fax,
  $ShippingStreetAddress, $ShippingCity,$ShippingState,$ShippingCountry,
  $ShippingPhone,$ShippingZip, $ShippingFax,
  $EstabDiscountLevelOrder,
  $CreditCard, $DatePurchased,
  $DateShipped, $DatePaymentDue, $DatePaymentReceived,
  $ShippedVia, $TrackingNumber,
  $CreditCardType, $CreditCardNumber, $ExpirationMonth, $ExpirationYear,
  $SecurityCode, $NameOnCard
  ) =dbfetch();


  if ($DateShipped =='0000-00-00') { $DateShipped=''; }
  if ($DatePaymentDue =='0000-00-00') { $DatePaymentDue=''; }
  if ($DatePaymentReceived =='0000-00-00') { $DatePaymentReceived=''; }


  $sql="SELECT CreditCard.ConditionsOfSale FROM CreditCard WHERE  CreditCard.Name='$CreditCard'";
  dbexecute($sql);
  ($ConditionsOfSale) =dbfetch();

  $str_creditcard='';
  if ( $CreditCard eq 'Credit Card' ) {

     if ($CreditCardType eq "Visa") { $str_card="<img src='/store/img/visa.gif'  width=45 height=28 border=0>"; }
     elsif ($CreditCardType eq "MasterCard") { $str_card="<img src='/store/img/mastercard.gif'  width=45 height=28  border=0>"; }
     elsif ($CreditCardType eq "Discover") { $str_card="<img src='/store/img/Discover.gif'  width=45 height=28  border=0>"; }
     elsif ($CreditCardType eq "American Express") { $str_card="<img src='/store/img/amex.gif'  width=45 height=28  border=0>"; }

      $str_creditcard="
           <table border=$str_border width=285 cellspacing=1 cellpadding=2>
            <TR>
               <TD width=125 $str_bg_class>Type of credit card</TD>
               <TD width=160 $str_bg_class><b>Visa</b></TD>
           </TR>
           <TR>
              <TD $str_class>Credit Card Number</TD>
              <TD $str_class>$CreditCardNumber</TD>
           </TR>
           <TR>
              <TD $str_bg_class>Expiration month</TD>
              <TD $str_bg_class>$ExpirationMonth</TD>
           </TR>

           <TR>
              <TD $str_class>Expiration year</TD>
              <TD $str_class>$ExpirationYear</TD>
           </TR>
           <TR>
             <TD $str_bg_class>Security code</TD>
             <TD $str_bg_class>$SecurityCode</TD>
           </TR>
           <TR>
             <TD valign=top $str_class>Name on Card</TD>
             <TD $str_class>$NameOnCard</TD>
           </TR>
           </table>";
    $str_select="
    <table border=0 width=100% cellspacing=0 cellpadding=0 align=center>
    <TR><td valign=top $str_class align=left width=50>$str_card</td><td width=90% valign=middle align=left $str_class>&nbsp;&nbsp;Type of payment: <b>$CreditCard</b></td></TR>
    <TR><td colspan=2 valign=top $str_class> $str_creditcard  </td></TR>
    </table>";
    }
    else   {
      $str_select="
     <table border=0 width=100% cellspacing=0 cellpadding=0 align=center>
     <TR><td  height=20 valign=middle align=left $str_bg_class>&nbsp;&nbsp;Type of payment: <b>$CreditCard</b></td></TR>
    </table>";
   }
   $str_PaymentTerms=$str_select;

if ( $com ne 'Printer' )  {

  $str_PaymentTerms="
  <table border=\"0\" width=\"600\" cellspacing=\"0\" cellpadding=\"1\" align=center>
  <TR>
    <TD width=285 valign=top bgcolor='#468499' height=18  class=Account>&nbsp;<font color=\"#ffffff\"><b>Payment</b></font></td>
    <TD width=30 valign=top  ></TD>
    <TD width=285 valign=top bgcolor='#468499' height=18  class=Account >&nbsp;<font color=\"#ffffff\"><b>Shipping</b></font></td>
  </TR>

  <TR><td colspan=3 align=left width=600  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>
  <TR>
  <TD width=285 $str_class valign=top>
   $str_select
  </TD>
  <TD width=30 $str_class></TD>
  <TD width=285 $str_class valign=top>
      <table border=$str_border width=\"285\" cellspacing=\"1\" cellpadding=\"2\">
      <TR><TD $str_bg_class>Date Payment Due</TD><TD $str_bg_class>$DatePaymentDue&nbsp;</TD></TR>
      <TR><TD $str_class>Date Payment Received</TD><TD $str_class>$DatePaymentReceived&nbsp;</TD></TR>
      <TR><TD width=140 $str_bg_class>Date Shipped</TD><TD  $str_bg_class>$DateShipped&nbsp;</TD></TR>
      <TR><TD  $str_class>Shipped via</TD><TD $str_class >$ShippedVia&nbsp;</TD></TR>
      <TR><TD  $str_bg_class>Tracking #</TD><TD $str_bg_class>$TrackingNumber&nbsp;</TD></TR>
      </table>
  </TD>
  </TR>
  </table>";
}

 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Trans = $IdTrans and Status = 0
       ORDER BY Id";
 dbexecute($sql);
 while (( $IdOrderList, $ProductId, $ProductNumber, $ProductName, $OptionId,
          $OptionNumber, $OptionName, $Quantity, $Price, $Code, $Trans, $Status )=dbfetch()) {

    if ( $OptionId ==0 ) {
        $str_option="";
        $str_Number=$ProductNumber;
        $str_Name=$ProductName;
    }
    else  {
        $str_option="(for $ProductNumber)";
        $str_Number=$OptionNumber;
        $str_Name=$OptionName;
    }

    $Amount=sprintf("%.2f", ($Price*$Quantity));  # Amount result
    $SubTotal = $SubTotal + $Amount;

    $Price=converter($Price);
    $Amount=converter($Amount);

    $str_table.="<TR>
        <TD height=22 $str_bg_class2 align=center>$str_Number</TD>
        <TD height=22 $str_bg_class2 align=left>$str_Name $str_option</TD>
        <TD $str_bg_class2 align=right>$Price&nbsp;</TD>
        <TD $str_bg_class2 align=center> $Quantity</TD>
        <TD $str_bg_class2 class=Account align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }


 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);


$str_printer_bottom.="
<table border=\"0\" width=\"600\" cellspacing=\"0\" cellpadding=\"0\" align=center>
<TR><td align=left  height=15></td></TR>
<TR><td bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td></TR>
</table>
<TABLE border=0 cellPadding=0 cellSpacing=0 width='600' align=center>
<TR><TD   height=1><IMG height=10 src='/store/img/pix.gif'  width=1></TD><tr>
</table>
<TABLE border=0 cellPadding=0 cellSpacing=0 width='600' align=center>
             <tr><td width='400' height='20' align ='right'></td><td  valign=middle width='330'></td><td width='35' align ='right'
               ><a href='".$pathUrl."?com=Printer&IdTrans=$IdTrans' class='mr' target='printer'><img src='/store/icon/icon_printer.gif' border='0'></a></td>
               <td width=165 align=right><a href='".$pathUrl."?com=Printer&IdTrans=$IdTrans' target='printer' class='mr'>Print Fax/E-mail Form</a></td>
             </tr></table>";

$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlAccount'>My Account</A>
   &gt; <A class=PathSite  href='".$pathUrl."'>Orders History</A> &gt; <A class=PathSite  href='".$pathUrl."?com=Order&IdTrans=$IdTrans'><u>\#$StoreOrderNumber</u></A></SPAN>";

print "Content-type: text/html\n\n";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_printer_bottom'}=$str_printer_bottom;

$VAR{'StoreOrderNumber'}=$StoreOrderNumber;
$VAR{'DatePurchased'}=$DatePurchased;
$VAR{'str_table'}=$str_table;
$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;

$VAR{'FirstName'}=$FirstName;
$VAR{'LastName'}=$LastName;
$VAR{'Title'}=$Title;
$VAR{'CompanyName'}=$CompanyName;
$VAR{'Email'}=$Email;

$VAR{'StreetAddress'}=$StreetAddress;
$VAR{'City'}=$City;
$VAR{'State'}=$State;
$VAR{'Country'}=$Country;
$VAR{'Phone'}=$Phone;
$VAR{'Fax'}=$Fax;
$VAR{'Zip'}=$Zip;
$VAR{'Checked'}=$checked;

$VAR{'ShippingStreetAddress'}=$ShippingStreetAddress;
$VAR{'ShippingCity'}=$ShippingCity;
$VAR{'ShippingState'}=$ShippingState;
$VAR{'ShippingCountry'}=$ShippingCountry;
$VAR{'ShippingPhone'}=$ShippingPhone;
$VAR{'ShippingFax'}=$ShippingFax;
$VAR{'ShippingZip'}=$ShippingZip;
$VAR{'PaymentTerms'}=$PaymentTerms;
$VAR{'str_PaymentTerms'}=$str_PaymentTerms;

$VAR{'CreditCardType'}=$CreditCardType;
$VAR{'CreditCardNumber'}=$CreditCardNumber;
$VAR{'ExpirationMonth'}=$ExpirationMonth;
$VAR{'ExpirationYear'}=$ExpirationYear;
$VAR{'SecurityCode'}=$SecurityCode;
$VAR{'NameOnCard'}=$NameOnCard;

$VAR{'ConditionsOfSale'}=$ConditionsOfSale;

$VAR{'PhoneStore'}=$PhoneStore;
$VAR{'FaxStore'}=$FaxStore;
$VAR{'EmailStore'}=$EmailStore;

if ( $com eq 'Printer' )  {
    if ( !parse_template($path_html."html/cart4_printer.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
    }
}
else {
   $template_file=$path_html."html/order_details.html"; 
   $template_file=parse_body($template_file, *STDOUT);
   $VAR{'template_file'}=$template_file;

   if ( !parse_template($path_html."html/template.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
   }
}

}   ##order
