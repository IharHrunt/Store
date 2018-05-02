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

$pathUrl =$path_cgi.'cart.pl';

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();



my $comCart=$q->param('comCart');
if ( $comCart eq ''                   ) { step1(); }
elsif ( $comCart eq 'AddToCart'       ) { step1(); }
elsif ( $comCart eq 'AddToCartOption' ) { step1(); }
elsif ( $comCart eq 'Recalculate'     ) { step1(); }
elsif ( $comCart eq 'Remove'          ) { step1(); }
elsif ( $comCart eq 'Step1'           ) { step1(); }
elsif ( $comCart eq 'Step2'           ) { step2(); }
elsif ( $comCart eq 'Enter'           ) { enter(); }
elsif ( $comCart eq 'Step3'           ) { step3(); }
elsif ( $comCart eq 'Step4'           ) { step4(); }
elsif ( $comCart eq 'Printer'           ) { step4(); }
elsif ( $comCart eq 'Step5'           ) { step5(); }
else { step1(); }


############################################################################
sub step1      #05.07.00 8:03
############################################################################

{

 $comCart=$q->param('comCart');
 $Bundle=$q->param('Bundle');
 $pathUrlProduct=$path_cgi."product.pl";

 $SelCat=$q->param('SelCat');
 $SelSubCat=$q->param('SelSubCat');
 $SelManuf=$q->param('SelManuf');
 $Id=$q->param('Id');
 $row=$q->param('row');
 $page=$q->param('page');

 
 $com=$q->param('com');
 if ( $com eq 'Product' ) { $pathUrlProduct=$path_cgi."product.pl?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page"; }
 elsif ( $com eq 'Description' ) {
       $pathUrlProduct=$path_cgi."product.pl?com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page"; 
 }


 if ( $comCart eq 'Recalculate' ) {
    recalculate();
 }
 if ( $comCart eq 'Remove' ) {
    remove();
 }


 if (( $comCart eq 'AddToCart' )||( $comCart eq 'AddToCartOption' )) {

   $sql="SELECT  Product.StoreProductNumber, Product.StoreProductName, Product.Price, Product.PriceType
       FROM Product WHERE Product.Id=$Id";
   dbexecute($sql);
   ($StoreProductNumber, $StoreProductName, $Price, $PriceType)=dbfetch();

   if ($PriceType < 3) {
      #Products
      if (( $comCart eq 'AddToCart' )||($Bundle eq 'true')) {

          $sql="SELECT DISTINCT  Id, ProductId, Quantity
                FROM OrderList
                WHERE Code = '$code' and Trans=0 and ProductId=$Id and OptionId = 0 and Status=0";
          dbexecute($sql);
          ( $IdOrderList, $ProductId, $Quantity )=dbfetch();
          if ( defined $IdOrderList)  {
             $Quantity++;
             $sql="UPDATE OrderList SET Quantity = $Quantity, Status=0 WHERE Id = $IdOrderList and Code = '$code' and Trans=0";
             dbdo($sql);
          }
          else {
             $sql="INSERT INTO OrderList(ProductId, ProductNumber, ProductName, OptionId, Quantity, Price, Code, Trans, TimeExpiration, Status)
                   VALUES ($Id, '$StoreProductNumber', '$StoreProductName', 0, 1, $Price, '$code', 0, NOW(), 0)";
             dbdo($sql);
          }
       }
   }

   #Options
   if ( $comCart eq 'AddToCartOption' ) {

       $ProductOption1=$q->param('ProductOption1');
       $ProductOption2=$q->param('ProductOption2');
       $ProductOption3=$q->param('ProductOption3');
       $ProductOption4=$q->param('ProductOption4');
       $ProductOption5=$q->param('ProductOption5');
       $ProductOption6=$q->param('ProductOption6');
       $ProductOption7=$q->param('ProductOption7');

       $ProductOption8=$q->param('ProductOption8');
       $ProductOption9=$q->param('ProductOption9');
       $ProductOption10=$q->param('ProductOption10');
       $ProductOption11=$q->param('ProductOption11');
       $ProductOption12=$q->param('ProductOption12');
       $ProductOption13=$q->param('ProductOption13');
       $ProductOption14=$q->param('ProductOption14');

       $ProductOption15=$q->param('ProductOption15');
       $ProductOption16=$q->param('ProductOption16');
       $ProductOption17=$q->param('ProductOption17');
       $ProductOption18=$q->param('ProductOption18');
       $ProductOption19=$q->param('ProductOption19');
       $ProductOption20=$q->param('ProductOption20');
       $ProductOption21=$q->param('ProductOption21');


        if ( $ProductOption1 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption1) }
        if ( $ProductOption2 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption2) }
        if ( $ProductOption3 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption3) }
        if ( $ProductOption4 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption4) }
        if ( $ProductOption5 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption5) }
        if ( $ProductOption6 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption6) }
        if ( $ProductOption7 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption7) }

        if ( $ProductOption8 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption8) }
        if ( $ProductOption9 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption9) }
        if ( $ProductOption10 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption10) }
        if ( $ProductOption11 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption11) }
        if ( $ProductOption12 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption12) }
        if ( $ProductOption13 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption13) }
        if ( $ProductOption14 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption14) }

        if ( $ProductOption15 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption15) }
        if ( $ProductOption16 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption16) }
        if ( $ProductOption17 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption17) }
        if ( $ProductOption18 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption18) }
        if ( $ProductOption19 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption19) }
        if ( $ProductOption20 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption20) }
        if ( $ProductOption21 ne '' ) { add_option( $Id, $StoreProductNumber, $StoreProductName, $ProductOption21) }

   }
 }

 $str_table='';
 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Code = '$code' and Trans=0 and Status=0
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
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center>$str_Number</TD>
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=left>$str_Name  $str_option</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Price&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" align=center> <INPUT name=\"Quantity".$IdOrderList."\" value=\"$Quantity\"  maxLength=5  style=\"BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
               FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 30px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif\" ></TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Amount&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=center>
        <a href='$pathUrl?comCart=Remove&IdItem=$IdOrderList&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&com=$com&row=$row&page=$page' title='Remove this item from shopping cart'><img src='/store/img/del.gif' width=13 height=13 border=0></a></TD>
        </TR>";

     $i++;
 }

 # for recalculate and direction to continue
 $str_table.="
       <input type=hidden name=SelCat value='$SelCat' >
       <input type=hidden name=SelSubCat value='$SelSubCat' >
       <input type=hidden name=SelManuf value='$SelManuf' >
       <input type=hidden name=Id value='$Id' >
       <input type=hidden name=com value='$com' >
       <input type=hidden name=row value='$row' >
       <input type=hidden name=page value='$page' >
       ";

 $SubTotal=sprintf("%.2f", $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);

 $str_menu_top="
     <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
     <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Shopping Cart</u></A></SPAN>";


 $template_file=$path_html."html/cart1.html";

 if ( $i==0 ) {
   if (($com eq 'Product')||($com eq 'Description')) {
     $str_table="<b><font color=#ff0000>Your shopping cart is empty</font></b>
     <TABLE cellSpacing=0 cellPadding=0 width='600' align=center border=0 valign='bottom'>
     <TR><TD height=10 colspan=5 align=right></TD></TR>
     <TR><TD height=18 colspan=5 valign=bottom align=right><A href='$pathUrlProduct' title='continue ordering'><IMG  src='/store/btn/btn_continue.gif' width=130 height=20  border=0></A></TD></TR>
     </TABLE>
     ";
   }
   else {
     $str_table="<b><font color=#ff0000>Your shopping cart is empty</font></b>";
   }
   $template_file=$path_html."html/cart_empty.html";
 }


print "Content-type: text/html\n\n";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_table'}=$str_table;

$VAR{'DatePurchased'}=get_date();
$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;
$VAR{'pathUrlProduct'}=$pathUrlProduct;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##step1


############################################################################
sub add_option      #05.07.00 8:03
############################################################################

{
$Id = $_[0];
$StoreProductNumber = $_[1];
$StoreProductName = $_[2];
$OptionId = $_[3];

 $sql="SELECT Id, ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, Status
       FROM OptionList  WHERE Id=$OptionId and Status=0";
 dbexecute($sql);
 ($OptionId, $ProductId, $OptionNumber, $OptionName, $OptionDescription, $OptionPicture, $OptionPrice, $OptionStatus)=dbfetch();

 $sql="SELECT DISTINCT Id, Quantity
        FROM OrderList
        WHERE Code = '$code' and Trans=0 and ProductId=$Id and OptionId = $OptionId and Status=0";
 dbexecute($sql);
 ($IdOrderList, $OptionQuantity)=dbfetch();

 if ( defined $IdOrderList)  {
     $OptionQuantity++;
     $sql="UPDATE OrderList SET Quantity = $OptionQuantity  WHERE Id = $IdOrderList and Code = '$code' and Trans=0";
     dbdo($sql);
 }
 else {
     $sql="INSERT INTO OrderList(ProductId, ProductNumber, ProductName, OptionId, OptionNumber, OptionName, Quantity, Price, Code, Trans, TimeExpiration, Status)
           VALUES ($Id, '$StoreProductNumber', '$StoreProductName', $OptionId, '$OptionNumber', '$OptionName', 1, $OptionPrice, '$code', 0, NOW(), 0)";
     dbdo($sql);
 }

} #add_option


############################################################################
sub remove      #05.07.00 8:03
############################################################################

{

  $IdItem=$q->param('IdItem');
  $sql="UPDATE OrderList SET Quantity = 0, Status=1 WHERE Id = $IdItem and Code = '$code' and Trans=0 and Status=0";
  dbdo($sql);


}   ##remove



############################################################################
sub recalculate      #05.07.00 8:03
############################################################################

{

  ###### !!!!!!!!!!!!!!!!check if quantity is not number !!!!!!!!!!!!!!!!!!!!
  $sql="SELECT Id FROM OrderList WHERE Code = '$code' and Trans=0";
  dbexecute($sql);
  while (( $IdOrderList )=dbfetch()) {
    $Quantity='Quantity'.$IdOrderList;
    $Quantity=$q->param($Quantity);
    if (($Quantity eq '')||($Quantity ==0 )) {
       $sql="UPDATE OrderList SET Quantity = 0, Status=1 WHERE Id = $IdOrderList and Code = '$code' and Trans=0 and Status=0";
       dbdo($sql);
    }
    else {
       $sql="UPDATE OrderList SET Quantity = $Quantity WHERE Id = $IdOrderList and Code = '$code' and Trans=0 and Status=0";
       dbdo($sql);
    }
  }
}   ##recalculate


############################################################################
sub enter      #17.02.2000 15:39
############################################################################

{

    $user=$q->param('user');
    $pass=$q->param('pass');
    $_=$user; (s/^\s+//); (s/\s+$//); $user=$_;
    $_=$user; s/\'/\\\'/g; $user1=$_;
    $_=$pass; (s/^\s+//); (s/\s+$//); $pass=$_;
    $_=$pass; s/\'/\\\'/g; $pass1=$_;


     if ( length($user1) < 4 )  { step2("Access Denied. Invalid Login", $user, $pass); return; }

       #### User ####
       $sql = "SELECT Id, CustomerID, Password FROM Profile WHERE CustomerID='$user1' and Status=0";
       dbexecute($sql);
       ($Id, $userdb, $passdb) = dbfetch();
       if ( !defined $userdb ) {
         step2("Access Denied. Invalid Login.", $user, $pass); return;
       }

      #### Password ####
      if (length($pass) < 6)  { step2("Access Denied. Invalid Password", $user, $pass, 'pass'); return; }
      $sql = "SELECT Id, FirstName, CustomerID, Password, DateCreate, EstabDiscountLevel FROM Profile WHERE CustomerID='$user1' and Password='$pass1' and Status=0";
      dbexecute($sql);
      ($IdAccount, $FirstName, $userdb, $passdb, $DateCreate, $EstabDiscountLevel) = dbfetch();
       if ( defined $passdb ) {
          if (($pass ne $passdb))  { step2("Access Denied. Invalid Password.", $user, $pass, 'pass' ); return; }
       }
       else { step2("Access Denied. Invalid Password.", $user, $pass, 'pass' ); return; }

      $sql = "UPDATE Profile SET CustShifr=''  WHERE  CustShifr='$code' AND Status=0";
      dbdo($sql);

      $sql = "UPDATE Profile SET CustShifr='$code', TimeExpirShifr=NOW()
              WHERE CustomerID='$user1' and Password='$pass1' and Status=0";
      dbdo($sql);

     get_cookie();
     step2();

} ##enter


############################################################################
sub step2      #05.07.00 8:03
############################################################################
{


 if ( $access_key eq 'true') {
    $template_file=$path_html."html/cart2.html";


    if ( $comCart eq 'Step3' ) {
        $FirstName=$q->param('FirstName');
        $LastName=$q->param('LastName');
        $Email=$q->param('Email');
        $Title=$q->param('Title');
        $CompanyName=$q->param('CompanyName');

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
    }
    else  {

       # Select account information
       $sql="SELECT Id, CustomerID, Password, FirstName, LastName, Email,Title,
                CompanyName, Subscriber, StreetAddress, City, State, Country,
                TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                TradeReferences, Notes, EstabDiscountLevel, PaymentTerms,Phone,
                ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                ShippingPhone, Fax, Zip, ShippingFax, ShippingZip, DateCreate,Category
             FROM Profile
             WHERE  Id=$IdAccount and Status=0"; # $IdAccount from get_cookie
        dbexecute($sql);
        ($Id, $CustomerID, $Password, $FirstName, $LastName, $Email, $Title, $CompanyName, $Subscriber,
         $StreetAddress, $City, $State, $Country, $TypeOfBusiness,$TypeOfBusinessSpecify,
         $CurProjShortDescription, $BankReferences, $TradeReferences, $Notes, $EstabDiscountLevel,
         $PaymentTerms, $Phone, $ShippingStreetAddress, $ShippingCity, $ShippingState,
         $ShippingCountry, $ShippingPhone, $Fax, $Zip, $ShippingFax, $ShippingZip, $DateCreate,
         $str_Category) =dbfetch();

         # Checked if the Billing Address equal Shipping Address
         if (($StreetAddress eq $ShippingStreetAddress)&&($StreetAddress ne '')&&
            ($City eq $ShippingCity)&&($City ne '')&&($State ne '')&& ( $State eq $ShippingState )&&
            ($Country eq $ShippingCountry)&&($Country ne '')&&($Phone eq $ShippingPhone)&&($Phone ne ''))
         { $checked='CHECKED'; }

    }

     my $str_message=$_[0];
     my $scriptvar=$_[1];
     if (  $scriptvar==1 ) { $str_scriptvar=$str_message; }
     else { $str_scriptvar="document.form1.FirstName.focus();  document.form1.FirstName.select();"; }

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
     #############################################

 }
 else {

   $template_file=$path_html."html/cart2_log.html";
   $str_report=$_[0];
  ####  if ( $str_report ne '' ){ $str_report=$str_report;  }
   $user=$_[1];
   $pass=$_[2];
   if ( $_[3] eq 'pass' ){ $str_scriptvar="document.form1.pass.focus();  document.form1.pass.select();"; }
   else {  $str_scriptvar="document.form1.user.focus();  document.form1.user.select();"; }

 }


 $str_table='';
 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Code = '$code' and Trans=0 and Status=0
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
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center>$str_Number</TD>
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=left>$str_Name $str_option</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Price&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" align=center> $Quantity</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }

 # for recalculate and direction to continue
 $str_table.="
       <input type=hidden name=SelCat value='$SelCat' >
       <input type=hidden name=SelSubCat value='$SelSubCat' >
       <input type=hidden name=SelManuf value='$SelManuf' >
       <input type=hidden name=Id value='$Id' >
       <input type=hidden name=com value='$com' >
       ";

 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);

 $str_menu_top="
     <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
     <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Shopping Cart</u></A></SPAN>";


 $i=0;
 $sql="SELECT Id FROM OrderList WHERE Code = '$code' and Trans=0 and Status=0";
 dbexecute($sql);
 while (( $IdOrderList )=dbfetch()) {
     $i++;
 }
 if ( $i==0 ) { step1(); return;}



print "Content-type: text/html\n\n";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_table'}=$str_table;
$VAR{'DatePurchased'}=get_date();
$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;

$VAR{'str_scriptvar'}=$str_scriptvar;
$VAR{'str_report'}=$str_report;
$VAR{'user'}=$user;
$VAR{'pass'}=$pass;

$VAR{'FirstName'}=$FirstName;
$VAR{'LastName'}=$LastName;
$VAR{'Title'}=$Title;
$VAR{'CompanyName'}=$CompanyName;
$VAR{'Email'}=$Email;

$VAR{'StreetAddress'}=$StreetAddress;
$VAR{'City'}=$City;
$VAR{'State'}=state_box($State, 0, 1);
$VAR{'Country'}=country_box($Country, 0, 1);
$VAR{'Phone'}=$Phone;
$VAR{'Fax'}=$Fax;
$VAR{'Zip'}=$Zip;
$VAR{'Checked'}=$checked;

$VAR{'ShippingStreetAddress'}=$ShippingStreetAddress;
$VAR{'ShippingCity'}=$ShippingCity;
$VAR{'ShippingState'}=state_box($ShippingState, 1, 1);
$VAR{'ShippingCountry'}=country_box($ShippingCountry, 1, 1);
$VAR{'ShippingPhone'}=$ShippingPhone;
$VAR{'ShippingFax'}=$ShippingFax;
$VAR{'ShippingZip'}=$ShippingZip;
$VAR{'PaymentTerms'}=$PaymentTerms;


$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}


}   ##step2



############################################################################
sub step3      #05.07.00 8:03
############################################################################
{

 if ( $access_key ne 'true') {
   step2("Access Denied. Please enter your Login and Password");
   return;
 }


 $FirstName=$q->param('FirstName');
 $LastName=$q->param('LastName');
 $Email=$q->param('Email');
 $Title=$q->param('Title');
 $CompanyName=$q->param('CompanyName');

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
 $PaymentTerms=$q->param('PaymentTerms');

 #############################################
 $_=$FirstName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $FirstName=$_;
 $_=$LastName;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $LastName=$_;
 $_=$Email;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Email=$_;
 $_=$Title;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Title=$_;
 $_=$CompanyName;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CompanyName=$_;

 $_=$StreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StreetAddress=$_;
 $_=$City;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
 $_=$Zip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
 $_=$Phone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
 $_=$Fax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
 $_=$ShippingStreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingStreetAddress=$_;
 $_=$ShippingCity;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingCity=$_;
 $_=$ShippingZip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingZip=$_;
 $_=$ShippingPhone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingPhone=$_;
 $_=$ShippingFax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingFax=$_;


 #############################################
 if (&email_check($Email)==0) {
    
    step2("document.form1.Email.focus();  document.form1.Email.select(); alert('Incorrect Email Address!')", 1 );
    return;

  }


 $sql="SELECT Name FROM Country WHERE Id=$Country";
 dbexecute($sql);
 $Country=dbfetch();
 $sql="SELECT Name FROM Country WHERE Id=$ShippingCountry";
 dbexecute($sql);
 $ShippingCountry=dbfetch();

 $sql="SELECT Name FROM State WHERE Id=$State";
 dbexecute($sql);
 $State=dbfetch();
 $sql="SELECT Name FROM State WHERE Id=$ShippingState";
 dbexecute($sql);
 $ShippingState=dbfetch();


 $statusSelect="false";
 $str_select="
 <table border=0 width=100% cellspacing=0 cellpadding=0 align=center>";
 $str_select.="<TR><td  colspan=3 valign=top height='1' bgcolor=#5fa0b2><img src='/store/img/pix.gif' height='1' ></td></tr>";



 $sql="SELECT Id FROM AccountType WHERE  Status=0 and Level=$Perspect";
 dbexecute($sql);
 ( $Id_AccountType ) =dbfetch();

 $sql="SELECT DISTINCT CreditCard.Id, CreditCard.Name, CreditCard.Description
     FROM CreditCard, SubAccountType
     WHERE CreditCard.Status=0 and SubAccountType.Status=0 and
            CreditCard.Id=SubAccountType.CreditCard and SubAccountType.AccountType = $Id_AccountType
     ORDER BY CreditCard.Name";
 dbexecute($sql);

 $sel=0;
  $str_focus="";
 $str_javascript='';
 $str_javascript2='';
 $str_disabled="";
 # $PaymentTerms=3; TEST

 while (($Id, $Name, $Description) =dbfetch()) {

   if ( $Id == $PaymentTerms ){  $checked="CHECKED"; }
   else { $checked=""; }
   $str_creditcard='';

   if ( $Name eq 'Credit Card' ) {
     $str_change="
     if (document.getElementById(\'Credit Card\').checked) {
        document.getElementById(\'Visa\').disabled=false;
        document.getElementById(\'MasterCard\').disabled=false;
        document.getElementById(\'Discover\').disabled=false;
        document.getElementById(\'American Express\').disabled=false;
        document.form1.CreditCardNumber.disabled = false;
        document.form1.ExpirationMonth.disabled = false;
        document.form1.ExpirationYear.disabled = false;
        document.form1.SecurityCode.disabled = false;
        document.form1.NameOnCard.disabled = false;
    }
     else  {
        document.getElementById(\'Visa\').disabled=true;
        document.getElementById(\'MasterCard\').disabled=true;
        document.getElementById(\'Discover\').disabled=true;
        document.getElementById(\'American Express\').disabled=true;
        document.form1.CreditCardNumber.disabled = true;
        document.form1.ExpirationMonth.disabled = true;
        document.form1.ExpirationYear.disabled = true;
        document.form1.SecurityCode.disabled = true;
        document.form1.NameOnCard.disabled = true;

        document.getElementById(\'Visa\').checked=false;
        document.getElementById(\'MasterCard\').checked=false;
        document.getElementById(\'Discover\').checked=false;
        document.getElementById(\'American Express\').checked=false;
        document.form1.CreditCardNumber.value = '';
        document.form1.ExpirationMonth.value = '';
        document.form1.ExpirationYear.value = '';
        document.form1.SecurityCode.value = '';
        document.form1.NameOnCard.value = '';
     }
     ";

     $str_javascript2="
     if (document.getElementById(\'$Name\').checked) {
        if ((document.getElementById(\'Visa\').checked==false)&&(document.getElementById(\'MasterCard\').checked==false)&&
            (document.getElementById(\'Discover\').checked==false)&&(document.getElementById(\'American Express\').checked==false)) {
           alert(\"The field \'Type of Credit Card\' is required\");   return;
        }
        if (document.form1.CreditCardNumber.value.length == 0) {
          alert(\"The field \'Credit Card Number\' is required\"); document.form1.CreditCardNumber.focus();  document.form1.CreditCardNumber.select(); return;
        }
        if (document.form1.ExpirationMonth.value.length == 0){
          alert(\"The field \'Expiration Month\' is required\"); document.form1.ExpirationMonth.focus();  document.form1.ExpirationMonth.select(); return;
        }
        if (document.form1.ExpirationYear.value.length == 0){
          alert(\"The field \'Expiration Year\' is required\"); document.form1.ExpirationYear.focus();  document.form1.ExpirationYear.select(); return;
        }
        if (document.form1.SecurityCode.value.length == 0) {
          alert(\"The field \'Security Code\' is required\"); document.form1.SecurityCode.focus();  document.form1.SecurityCode.select(); return;
        }
        if (document.form1.NameOnCard.value.length == 0) {
          alert(\"The field \'Name on card\' is required\"); document.form1.NameOnCard.focus();  document.form1.NameOnCard.select(); return;
        }
     }
     ";

     $str_focus=$str_change;

     $str_creditcard="
      <table border=0 width=100% cellspacing=3 cellpadding=0 align=center>
      <TR><td  colspan=2 valign=top height='7'><img src='/store/img/pix.gif' height='1' ></td></tr>
      <TR>
         <TD width=100 class=Account valign=middle>Type of Credit Card</TD>
         <TD class=Account>
        <table border=0 width=100% cellspacing=0 cellpadding=0 align=center>
         <TR><td valign=middle><INPUT type='radio' $str_disabled id='Visa'  name=CreditCardType value='Visa'></td><td valign=middle><img src='/store/img/visa.gif'  width=45 height=28  border=0>&nbsp;&nbsp;&nbsp;</td>
             <td valign=middle><INPUT type='radio' $str_disabled id='MasterCard'  name=CreditCardType value='MasterCard'></td><td valign=middle><img src='/store/img/mastercard.gif'  width=45 height=28  border=0>&nbsp;&nbsp;&nbsp;</td>
             <td valign=middle><INPUT type='radio' $str_disabled id='Discover'  name=CreditCardType value='Discover'></td><td valign=middle><img src='/store/img/discover.gif'  width=45 height=28  border=0>&nbsp;&nbsp;&nbsp;</td>
             <td valign=middle><INPUT type='radio' $str_disabled id='American Express'  name=CreditCardType value='American Express'></td><td valign=middle><img src='/store/img/amex.gif'  width=45 height=28  border=0></td>
          </TR>
          </table>
          </TD>
      </TR>
      <TR>
         <TD width=150 class=Account>Credit Card Number</TD>
         <TD class=Account><INPUT name=CreditCardNumber value='' $str_disabled maxLength=30  style='BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 12px; BORDER-LEFT: #468499 1px solid; WIDTH: 200px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Arial, Helvetica, sans-serif' ></TD>
      </TR>
      <TR>
         <TD class=Account>Expiration month</TD>
         <TD class=Account><INPUT name=ExpirationMonth value='' $str_disabled maxLength=2  style='BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 12px; BORDER-LEFT: #468499 1px solid; WIDTH: 20px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Arial, Helvetica, sans-serif' >&nbsp;&nbsp;(01-12)</TD>
      </TR>
         <TD class=Account>Expiration year</TD>
         <TD class=Account><INPUT name=ExpirationYear value='' $str_disabled maxLength=2  style='BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 12px; BORDER-LEFT: #468499 1px solid; WIDTH: 20px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Arial, Helvetica, sans-serif' >&nbsp;&nbsp;(00-99)</TD>
      </TR>
      <TR>
         <TD class=Account>Security code</TD>
         <TD class=Account><INPUT name=SecurityCode value='' $str_disabled maxLength=30  style='BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 12px; BORDER-LEFT: #468499 1px solid; WIDTH: 150px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Arial, Helvetica, sans-serif' ></TD>
      </TR>
      <TR>
         <TD class=Account>Name on card *</TD>
         <TD class=Account><INPUT name=NameOnCard value='' $str_disabled maxLength=150  style='BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 12px; BORDER-LEFT: #468499 1px solid; WIDTH: 310px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY:  Arial, Helvetica, sans-serif' ></TD>
      </TR>
      <TR>
         <TD class=Account></TD>
         <TD class=Account>* Full name as it appears on the Credit Card. If Corporate Card - name of the corporation the card belongs to and the name of the authorized officer.</TD>
      </TR>
      </table>";
    }


    if ( $sel ==0 )    {
      $str_javascript.="(!(document.getElementById(\'$Name\').checked))";
    }
    else  {
       $str_javascript.="&&(!(document.getElementById(\'$Name\').checked))"
    }
    $str_select.="<TR><td colspan=3 valign=top height='3'><img src='/store/img/pix.gif' height='1' ></td></tr>
                  <TR><td valign=top width=35></td><td valign=top class=Account><INPUT id='$Name' type='radio' name=PaymentTerms value=$Id $checked  onClick=\"changeTerms();\">&nbsp;<b>$Name</b><br><br>$Description</td>
                      <td width=25 valign=top></td></TR>
                  <TR><td valign=top width=35></td><td valign=top class=Account>
                  $str_creditcard
                  </td>
                      <td width=25 valign=top></td></TR>
                 <TR><td colspan=3 valign=top height='10'><img src='/store/img/pix.gif' height='1' ></td></tr>
                 <TR><td colspan=3 valign=top height='1' bgcolor='#468499'><img src='/store/img/pix.gif' height='1' ></td></tr>";
    $sel++;

 }

 $str_select.="</table><br>
 <SCRIPT>
 function changeTerms() {
   $str_change
 }
 function enter() {
   if ($str_javascript) {
     alert(\"Please select your type of payment!\");  return;
   }
    $str_javascript2

   document.form1.submit();
 }
 </SCRIPT>
 ";

 $PaymentTerms=$str_select;



 $str_table='';
 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Code = '$code' and Trans=0 and Status=0
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
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center>$str_Number</TD>
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=left>$str_Name $str_option</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Price&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" align=center> $Quantity</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }


 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));
 $SubTotal=converter($SubTotal);
 $Total=converter($Total);


 $str_menu_top="
     <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
     <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Shopping Cart</u></A></SPAN>";


 $i=0;
 $sql="SELECT Id FROM OrderList WHERE Code = '$code' and Trans=0 and Status=0";
 dbexecute($sql);
 while (( $IdOrderList )=dbfetch()) {
     $i++;
 }
 if ( $i==0 ) { step1(); return;}


print "Content-type: text/html\n\n";
$template_file=$path_html."html/cart3.html";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_scriptvar'}="changeTerms();";
$VAR{'str_table'}=$str_table;
$VAR{'DatePurchased'}=get_date();
$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;

$VAR{'str_report'}=$str_report;

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


$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##step3


############################################################################
sub step4      #05.07.00 8:03
############################################################################
{

 if ( $access_key ne 'true') {
   step2("Access Denied. Please enter your Login and Password");
   return;
 }


 $FirstName=$q->param('FirstName');
 $LastName=$q->param('LastName');
 $Email=$q->param('Email');
 $Title=$q->param('Title');
 $CompanyName=$q->param('CompanyName');

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
 $PaymentTerms=$q->param('PaymentTerms');

 $CreditCardType=$q->param('CreditCardType');
 $CreditCardNumber=$q->param('CreditCardNumber');
 $ExpirationMonth=$q->param('ExpirationMonth');
 $ExpirationYear=$q->param('ExpirationYear');
 $SecurityCode=$q->param('SecurityCode');
 $NameOnCard=$q->param('NameOnCard');


 #############################################
 $_=$FirstName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $FirstName=$_;
 $_=$LastName;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $LastName=$_;
 $_=$Email;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Email=$_;
 $_=$Title;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Title=$_;
 $_=$CompanyName;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CompanyName=$_;

 $_=$StreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StreetAddress=$_;
 $_=$City;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
 $_=$Zip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
 $_=$Phone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
 $_=$Fax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
 $_=$ShippingStreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingStreetAddress=$_;
 $_=$ShippingCity;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingCity=$_;
 $_=$ShippingZip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingZip=$_;
 $_=$ShippingPhone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingPhone=$_;
 $_=$ShippingFax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingFax=$_;

 $_=$NameOnCard;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $NameOnCard=$_;


  if ( $comCart eq 'Printer' )  {
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


 $sql="SELECT CreditCard.Id, CreditCard.Name, CreditCard.Description, CreditCard.ConditionsOfSale
     FROM CreditCard
     WHERE CreditCard.Status=0 and CreditCard.Id=$PaymentTerms";
 dbexecute($sql);
 ($Id, $Name, $Description, $ConditionsOfSale) =dbfetch();

  $str_creditcard='';
  if ( $Name eq 'Credit Card' ) {

     if ($CreditCardType eq "Visa") { $str_card="<img src='/store/img/visa.gif'  width=45 height=28 border=0>"; }
     elsif ($CreditCardType eq "MasterCard") { $str_card="<img src='/store/img/mastercard.gif'  width=45 height=28  border=0>"; }
     elsif ($CreditCardType eq "Discover") { $str_card="<img src='/store/img/Discover.gif'  width=45 height=28  border=0>"; }
     elsif ($CreditCardType eq "American Express") { $str_card="<img src='/store/img/amex.gif'  width=45 height=28  border=0>"; }

      $str_creditcard="
        <table border=0 width=600 cellspacing=0 cellpadding=2 align=center>
        <TR>
        <TD width=285 $str_class valign=top>
            <table border=$str_border width=285 cellspacing=1 cellpadding=2>
            <TR>
               <TD width=120 $str_bg_class>Type of credit card</TD>
               <TD width=165 $str_bg_class><b>Visa</b></TD>
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
             <TD  $str_class>$NameOnCard</TD>
           </TR>

           </table>
        </TD>
        <TD width=28 $str_class></TD>
        <TD width=185 $str_class valign=top>
       </TD>
       </TR>
      </table>";

    $str_select="
    <table border=0 width=600 cellspacing=0 cellpadding=0 align=center>
    <TR><td valign=top $str_class align=left width=50>&nbsp;$str_card</td><td width=444 valign=middle align=left $str_class>Type of payment: <b>$Name</b></td></TR>
    <TR><td colspan=2 valign=top $str_class> $str_creditcard  </td></TR>
    </table>";
  }
  else   {
    $str_select="
    <table border=0 width=600 cellspacing=0 cellpadding=0 align=center>
    <TR><td valign=middle align=left $str_class>&nbsp;&nbsp;Type of payment: <b>$Name</b></td></TR>
    </table>";

  }

  $str_PaymentTerms=$str_select;


 $str_table='';
 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Code = '$code' and Trans=0 and Status=0
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

 $str_menu_top="
     <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
     <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Shopping Cart</u></A></SPAN>";


 $i=0;
 $sql="SELECT Id FROM OrderList WHERE Code = '$code' and Trans=0 and Status=0";
 dbexecute($sql);
 while (( $IdOrderList )=dbfetch()) {
     $i++;
 }
 if ( $i==0 ) { step1(); return;}



print "Content-type: text/html\n\n";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_table'}=$str_table;
$VAR{'DatePurchased'}=get_date();
$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;


$VAR{'str_scriptvar'}=$str_scriptvar;
$VAR{'str_report'}=$str_report;

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


if ( $comCart eq 'Printer' )  {

    if ( !parse_template($path_html."html/cart4_printer.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
    }
}
else {

    $template_file=$path_html."html/cart4.html";
    $template_file=parse_body($template_file, *STDOUT);
    $VAR{'template_file'}=$template_file;

    if ( !parse_template($path_html."html/template.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
    }
}

}   ##step4



############################################################################
sub step5      #05.07.00 8:03
############################################################################
{


 if ( $access_key ne 'true') {
   step2("Access Denied. Please enter your Login and Password");
   return;
 }

$FirstName=$q->param('FirstName');
$LastName=$q->param('LastName');
$Email=$q->param('Email');
$Title=$q->param('Title');
$CompanyName=$q->param('CompanyName');

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
$PaymentTerms=$q->param('PaymentTerms');


$CreditCardType=$q->param('CreditCardType');
$CreditCardNumber=$q->param('CreditCardNumber');
$ExpirationMonth=$q->param('ExpirationMonth');
$ExpirationYear=$q->param('ExpirationYear');
$SecurityCode=$q->param('SecurityCode');
$NameOnCard=$q->param('NameOnCard');


#############################################
$_=$FirstName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $FirstName=$_;
$_=$LastName;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $LastName=$_;
$_=$Email;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Email=$_;
$_=$Title;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Title=$_;
$_=$CompanyName;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CompanyName=$_;

$_=$StreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StreetAddress=$_;
$_=$City;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
$_=$Zip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
$_=$Phone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
$_=$Fax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
$_=$ShippingStreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingStreetAddress=$_;
$_=$ShippingCity;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingCity=$_;
$_=$ShippingZip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingZip=$_;
$_=$ShippingPhone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingPhone=$_;
$_=$ShippingFax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingFax=$_;

$_=$NameOnCard;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $NameOnCard=$_;


 ####################################################################################
 $str_table="<table border='1' width='100%' cellspacing='1' cellpadding='0'>
          <TR ><TH height=18 width='15%'><font size=2>Unit</font></TH>
     <TH width='45%'><font size=2>Name</font></TH>
     <TH width='15%'><font size=2>Unit Price</font></TH>
     <TH width='10%'><font size=2>Quantity</font></TH>
     <TH width='15%'><font size=2>Total Cost</font></TH></TR>";

 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Code = '$code' and Trans=0 and Status=0
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
        <TD height=18 align=center>$str_Number</TD>
        <TD align=left>$str_Name $str_option</TD>
        <TD align=right>$Price&nbsp;</TD>
        <TD align=center> $Quantity</TD>
        <TD align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }

 $str_table.="</table>";
 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);

 ####################################################################################

 # Exit if thre is not products in the order list
 $i=0;
 $sql="SELECT Id FROM OrderList WHERE Code = '$code' and Trans=0 and Status=0";
 dbexecute($sql);
 while (( $IdOrderList )=dbfetch()) {
     $i++;
 }
 if ( $i==0 ) { step1(); return; }


 $send='no';
 $DatePurchased=get_date();

 ###########################################################
 $sql="SELECT COUNT(Id) FROM Transactions WHERE DatePurchased='$DatePurchased'";
 dbexecute($sql);
 $countID=dbfetch();
 ############### Order Number Start ########################
 $countID=$countID+355;
 $curDate=$DatePurchased;
 $curDate3=substr($curDate, 2 , 2);
 $curDate2=substr($curDate, 5 , 2);
 $curDate1=substr($curDate, 8 , 2);
 $StoreOrderNumber=$curDate3.$curDate2.$curDate1.$countID;
 ############### Order Number End ########################

 $sql="SELECT Name FROM CreditCard WHERE Id = $PaymentTerms";
 dbexecute($sql);
 ($PaymentTerms) =dbfetch();


 $sql="INSERT INTO Transactions
           ( Profile, StoreOrderNumber, PurchasingOrderNumber,
            FirstName, LastName, Email, Title, CompanyName,
            StreetAddress, City, State, Country, Phone, Zip, Fax,
            ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
            ShippingPhone, ShippingZip, ShippingFax,
            EstabDiscountLevel,
            CreditCard, DatePurchased, code, Status,
            DateShipped, DatePaymentDue, DatePaymentReceived,
            ShippedVia, TrackingNumber,
            CreditCardType, CreditCardNumber, ExpirationMonth, ExpirationYear,
            SecurityCode, NameOnCard
            )
      VALUES
           ($IdAccount,'$StoreOrderNumber','$PurchasingOrderNumber',
           '$FirstName','$LastName','$Email', '$Title', '$CompanyName',
           '$StreetAddress', '$City','$State','$Country',
           '$Phone','$Zip', '$Fax',
           '$ShippingStreetAddress', '$ShippingCity','$ShippingState','$ShippingCountry',
           '$ShippingPhone','$ShippingZip', '$ShippingFax',
            $EstabDiscountLevel,
            '$PaymentTerms', '$DatePurchased', '$code', 0,
            '0000-00-00', '0000-00-00', '0000-00-00','', '',
            '$CreditCardType', '$CreditCardNumber', '$ExpirationMonth', '$ExpirationYear',
            '$SecurityCode', '$NameOnCard'
             )";
 if (dbdo($sql)) { $send ='yes'; }
 else { $str_report = "<div align=center><font color=#ff0000>
 Sorry.  The order has not been accepted. Possible problem - incorrect data you entered.<br>
 Click BACK button of your browser, check your data and try again. If the problem persists<br>
  please contact Store Customer Service Representative (Database Error: #126). </font></b></div>" } # Get error message

 $send ='yes';

 if ( $send eq 'yes' ) {

       # Get Id of the 'master' record in Transactions to create children in TransOrder
       $sql="SELECT Id FROM Transactions WHERE code='$code' and DatePurchased='$DatePurchased'";
       dbexecute($sql);
       $IdTrans=dbfetch();
       $sql="UPDATE Transactions SET code='true' WHERE code='$code'";
       dbdo($sql);
       $sql="Update OrderList set Trans=$IdTrans WHERE Code = '$code' and Trans=0 and Status=0";
       dbdo($sql);

       #####################################################################################

       $FirstNameTmp = $FirstName;
       $LastNameTmp = $LastName;

       if ( $FirstName eq '')  { $FirstName="Sir or Madam";  }
       if (( $FirstNameTmp eq '')&& ( $LastNameTmp eq '')) { $FirstNameTmp="--";  }
       if ( $Title eq '')  { $Title="--";  }
       if ( $Fax eq '')  { $Fax="--";  }
       if ( $ShippingFax eq '')  { $ShippingFax="--";  }
       #######################################################################################

       $email_body="Dear $FirstName,<BR><BR>
       This is a confirmation of your order. If you have any questions, please contact us.<BR><BR>
       $NameDirector<BR>
       Customer Service Representative<BR>
       $NameStore<BR>
       Address: $AddressStore<BR>
       $CityStore $StateStore $CountryStore $ZipStore<BR>
       Phone:$PhoneStore<BR>
       Fax: $FaxStore<BR>
       E-mail: <a href='mailto:$EmailStore' ><FONT color='blue'>$EmailStore</FONT></a><BR><BR>
       <hr width='80%' align=left><BR>
       <h3>On-Line Order #$StoreOrderNumber Specification</h3>
       <b>Date:</b> $DatePurchased <b>Type of Payment:</b> $PaymentTerms<BR>
       <b>Customer:</b> $FirstNameTmp $LastNameTmp<BR>
       <b>Title:</b> $Title<BR>
       <b>Company Name:</b> $CompanyName<BR><BR>

       <b><u>Billing Address:</u></b> $StreetAddress
       $City $State $Country $Zip<BR>
       <b>Contact Phone:</b> $Phone  <b>Fax:</b> $Fax  <br>
       <b>Email:</b> <a href='mailto:$Email' ><FONT color='blue'>$Email</FONT></a><BR><BR>

       <b><u>Shipping Address</u>:</b> $ShippingStreetAddress
       $ShippingCity $ShippingState $ShippingCountry $ShippingZip<BR>
       <b>Contact Phone:</b> $ShippingPhone  <b>Fax:</b> $ShippingFax<BR>
       <BR>

        $str_table
       <table border='0' width='100%' cellspacing='1' cellpadding='0'>
       <TR><TH width='83%'></TH><TH width='17%'></TH></TR>
       <TD align='right'><font size=2><B>Sub - Total:</B></font></TD>
       <TD align='right'><font size=2>\$ $SubTotal</font></TD></TR>
       <TD align='right'><font size=2><B>Established Discount Lelel:</B></font></TD>
       <TD align='right'><font size=2>\% $EstabDiscountLevel</font></TD></TR>
       <TR><TD align='right'>-------------------------</TD><TD align='right'>------------</TD></TR>
       <TD align='right'><font size=2><B>Total:</B></font></TD>
       <TD align='right'><font size=2>\$ $Total</font></TD></TR>
       </table><BR>
        <hr width='100%' align=left><BR>";

######################################## If FileName1 or is not exist + URL
    if ( $FileName1 ne '') { $FileName1=" * <a href='/store/forms/$FileName1' target='pdf' class=mr><u>$FileName1</u></a> &nbsp; ";  }
    if ( $FileName2 ne '') { $FileName2=" &nbsp; * <a href='/store/forms/$FileName2' target='rtf' class=mr><u>$FileName2</u></a>&nbsp;&nbsp;";  }
    if (( $FileName1 ne '') || ( $FileName2 ne '')) {
        $str_payment.=$FileName1;
        if (( $FileName1 ne '') && ( $FileName2 ne '')) {  $str_payment.="|";  }
        $str_payment.=$FileName2;
    }
    $str_payment="<div align =right>$str_payment</div>";

     $pathOrderHistory=$path_cgi_https."order.pl?com=Order&IdTrans=$IdTrans";
       $str_report="<table border=0 width=560 cellspacing=0 cellpadding=2 align=center>
                </tr><td valign=top class=Account>
       <b>Dear $FirstName</b>, <br><br>Your order <a href='$pathOrderHistory'  class=Email>#<u>$StoreOrderNumber</u></a> has been accepted successfuly.
       Thank you for ordering at store.com.  The confirmation is being sent to your e-mail address.<br><br>
       Forgot to print out the Fax/E-mail form? You can find it in your </b><a href='$pathOrderHistory' class=Email><u>orders history</u></a>.
       <br><br>$str_payment
              </td></TR></table>";
           ## TEST $str_report=$email_body;
  }

  # Send E-mail to the Customer and Admin
  if ( $send eq 'yes' ) {

     $mail_to = $EmailStore;
     $from = $EmailStore;
     $subj = "On-line Order Confirmation";
     $body = $email_body;
     send_mail($mail_to,$from,$subj,$body,"html");
     $mail_to = $Email;
     $subj = "On-line Order Confirmation";
     send_mail($mail_to,$from,$subj,$body,"html");
  }

 $str_menu_top="
     <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
     <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Shopping Cart</u></A></SPAN>";


print "Content-type: text/html\n\n";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$template_file=$path_html."html/cart5.html";
$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$VAR{'str_report'}=$str_report;
$VAR{'DatePurchased'}=get_date();


$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##step5