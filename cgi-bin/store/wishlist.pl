#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / wishlist.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

$pathUrl =$path_cgi_https."wishlist.pl";
$pathUrlAccount =$path_cgi_https."account.pl";
$pathUrlProduct=$path_cgi."product.pl";

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

my $comWish=$q->param('comWish');
if ( $comWish eq ''                       ) { list(); }
elsif ( $comWish eq 'AddToWishList'       ) { list(); }
elsif ( $comWish eq 'AddToWishListOption' ) { list(); }
elsif ( $comWish eq 'Recalculate'         ) { list(); }
elsif ( $comWish eq 'Remove'              ) { list(); }
elsif ( $comWish eq 'AddToCart'           ) { add_to_cart(); }
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


$str_menu_top="<SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
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
   accessdenied("Please enter your Login and Password");
   return;
 }


 $SelCat=$q->param('SelCat');
 $SelSubCat=$q->param('SelSubCat');
 $SelManuf=$q->param('SelManuf');
 $Id=$q->param('Id');
 $com=$q->param('com');
 $Bundle=$q->param('Bundle');
 $row=$q->param('row');
 $page=$q->param('page');


 if ( $com eq 'Product' ) { $pathUrlProduct=$path_cgi."product.pl?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page"; }
 elsif ( $com eq 'Description' ) {
    $pathUrlProduct=$path_cgi."product.pl?com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page"; 
 }


 if ( $comWish eq 'Recalculate' ) {
    recalculate();
 }
 if ( $comWish eq 'Remove' ) {
    remove();
 }

 if (( $comWish eq 'AddToWishList' )||( $comWish eq 'AddToWishListOption' )) {

   $sql="SELECT  Product.StoreProductNumber, Product.StoreProductName,Product.Price, Product.PriceType
       FROM Product WHERE Product.Id=$Id";
   dbexecute($sql);

   ( $StoreProductNumber, $StoreProductName, $Price, $PriceType)=dbfetch();

   if ($PriceType < 3) {
     #Products
     if (($comWish eq 'AddToWishList')||($Bundle eq 'true')) {

         $sql="SELECT DISTINCT  Id, ProductId, Quantity
               FROM WishList
               WHERE ProductId=$Id and OptionId = 0 and Status=0";
         dbexecute($sql);
         ( $IdOrderList, $ProductId, $Quantity )=dbfetch();
         if ( defined $IdOrderList)  {
             $Quantity++;
             $sql="UPDATE WishList SET Quantity = $Quantity WHERE Profile=$IdAccount and ProductId=$Id and OptionId = 0 and Status=0";
             dbdo($sql);
         }
         else {
             $sql="INSERT INTO WishList(ProductId, ProductNumber, ProductName, OptionId, Quantity, Price, Code, Profile, TimeExpiration, Status)
                   VALUES ($Id, '$StoreProductNumber', '$StoreProductName', 0, 1, $Price, '', $IdAccount, NOW(), 0)";
             dbdo($sql);
         }
      }
   }

   #Options
   if ( $comWish eq 'AddToWishListOption' ) {

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
 $hTA.='';

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Profile, Status
       FROM WishList
       WHERE Profile=$IdAccount and Status=0
       ORDER BY Id";
 dbexecute($sql);
 while (( $IdOrderList, $ProductId, $ProductNumber, $ProductName, $OptionId,
          $OptionNumber, $OptionName, $Quantity, $Price, $Code, $Trans, $Status )=dbfetch()) {


   $hTA.="
       if (document.wishlist.Add".$IdOrderList.".checked) { mycount++; }";

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
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center ><input type=checkbox name=Add".$IdOrderList." size=10 value=1></TD>
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=center>$str_Number</TD>
        <TD height=22 bgcolor=\"#f0f6f9\" class=Account align=left>$str_Name $str_option</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Price&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" align=center> <INPUT name=\"Quantity".$IdOrderList."\" value=\"$Quantity\"  maxLength=5  style=\"BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
               FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 30px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif\" ></TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=right>$Amount&nbsp;</TD>
        <TD bgcolor=\"#f0f6f9\" class=Account align=center>
        <a href='$pathUrl?comWish=Remove&IdItem=$IdOrderList&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&com=$com&row=$row&page=$page' title='Remove this item from wish list'    ><img src='/store/img/del.gif' width=13 height=13 border=0></a></TD>
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
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlAccount'>My Account</A>
   &gt; <A class=PathSite  href='".$pathUrl."'><u>\Wish List</u></A></SPAN>";

 $template_file=$path_html."html/wishlist.html";

 if ( $i==0 ) {
   if (($com eq 'Product')||($com eq 'Description')) {
     $str_table="<b><font color=#ff0000>Your Wish List is empty</font></b>
     <TABLE cellSpacing=0 cellPadding=0 width='600' align=center border=0 valign='bottom'>
     <TR><TD height=10 colspan=5 align=right></TD></TR>
     <TR><TD height=18 colspan=5 valign=bottom align=right><A href='$pathUrlProduct' title='continue ordering'><IMG  src='/store/btn/btn_continue.gif' width=130 height=20  border=0></A></TD></TR>
     </TABLE>
     ";
   }
   else {
     $str_table="<b><font color=#ff0000>Your Wish List is empty</font></b>";
   }
   $template_file=$path_html."html/wishlist_empty.html";
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

$VAR{'hTA'}=$hTA;
$VAR{'str_table'}=$str_table;

$VAR{'SubTotal'}=$SubTotal;
$VAR{'EstabDiscountLevel'}=$EstabDiscountLevel;
$VAR{'Total'}=$Total;
$VAR{'pathUrlProduct'}=$pathUrlProduct;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##list


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
        FROM WishList
        WHERE  Profile=$IdAccount and ProductId=$Id and OptionId = $OptionId and Status=0";
 dbexecute($sql);
 ($IdOrderList, $OptionQuantity)=dbfetch();

 if ( defined $IdOrderList)  {
     $OptionQuantity++;
     $sql="UPDATE WishList SET Quantity = $OptionQuantity  WHERE Id = $IdOrderList and Profile=$IdAccount";
     dbdo($sql);

 }
 else {
     $sql="INSERT INTO WishList(ProductId, ProductNumber, ProductName, OptionId, OptionNumber, OptionName, Quantity, Price, Code, Profile, TimeExpiration, Status)
           VALUES ($Id, '$StoreProductNumber', '$StoreProductName', $OptionId, '$OptionNumber', '$OptionName', 1, $OptionPrice, '', $IdAccount, NOW(), 0)";
     dbdo($sql);
 }


} #add_option


############################################################################
sub remove      #05.07.00 8:03
############################################################################

{

  $IdItem=$q->param('IdItem');
  $sql="UPDATE WishList SET Quantity = 0, Status=1 WHERE Id = $IdItem and Profile=$IdAccount and Status=0";
  dbdo($sql);


}   ##remove



############################################################################
sub recalculate      #05.07.00 8:03
############################################################################

{

  ###### !!!!!!!!!!!!!!!!check if quantity is not number !!!!!!!!!!!!!!!!!!!!
  $sql="SELECT Id FROM WishList WHERE Profile=$IdAccount";
  dbexecute($sql);
  while (( $IdWishList )=dbfetch()) {
    $Quantity='Quantity'.$IdWishList;
    $Quantity=$q->param($Quantity);
    if (($Quantity eq '')||($Quantity ==0 )) {
       $sql="UPDATE WishList SET Quantity = 0, Status=1 WHERE Id = $IdWishList and Profile=$IdAccount and Status=0";
       dbdo($sql);
    }
    else {
       $sql="UPDATE WishList SET Quantity = $Quantity WHERE Id = $IdWishList and Profile=$IdAccount and Status=0";
       dbdo($sql);
    }
  }
}   ##recalculate



############################################################################
sub add_to_cart      #05.07.00 8:03
############################################################################

{

  if ( $access_key ne 'true') {
    accessdenied("Please enter your Login and Password");
    return;
  }

  $Quantity=0;
  $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName,
                         OptionId, OptionNumber, OptionName, Quantity, Price,
                         code, TimeExpiration, Profile, Status
       FROM WishList
       WHERE Profile=$IdAccount and Status=0";
  dbexecute($sql);
  while (( $IdWishList, $ProductIdWishList, $ProductNumberWishList, $ProductNameWishList,
           $OptionIdWishList, $OptionNumberWishList, $OptionNameWishList,
           $QuantityWishList, $PriceWishList, $codeWishList, $TimeExpirationWishList,
           $ProfileWishList, $StatusWishList)=dbfetch()) {

       $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName,
                  OptionId, OptionNumber, OptionName, Quantity, Price,
                  code, TimeExpiration, Trans, Status
           FROM OrderList
           WHERE code='$code' and Trans=0 and ProductId=$ProductIdWishList and
           OptionId=$OptionIdWishList and Status=0";
       $cursor1=$dbh->prepare($sql);
       $cursor1->execute;
       ($IdOrderList, $ProductIdOrderList, $ProductNumberOrderList, $ProductNameOrderList,
       $OptionIdOrderList, $OptionNumberOrderList, $OptionNameOrderList,
       $QuantityOrderList, $PriceOrderList, $codeOrderList, $TimeExpirationOrderList,
       $TransOrderList, $StatusOrderList)= $cursor1->fetchrow_array;

       $Add='Add'.$IdWishList;
       $Add=$q->param($Add);

       if ( $Add == 1 ) {
          if ( defined $IdOrderList ) {
             $Quantity = $QuantityWishList + $QuantityOrderList;
             $sql="UPDATE OrderList SET Quantity=$Quantity WHERE Id = $IdOrderList and Code = '$code'";
             dbdo($sql);
             $sql="UPDATE WishList SET Quantity=0, Status=1 WHERE Id = $IdWishList and Profile=$IdAccount";
             dbdo($sql);
          }
          else {
             $sql="INSERT INTO OrderList(ProductId, ProductNumber, ProductName, OptionId, OptionNumber, OptionName,
                                        Quantity, Price, Code, Trans, TimeExpiration, Status)
                   VALUES ($ProductIdWishList, '$ProductNumberWishList', '$ProductNameWishList', $OptionIdWishList,
                          '$OptionNumberWishList', '$OptionNameWishList', $QuantityWishList, $PriceWishList,
                          '$code', 0, NOW(), $StatusWishList)";
             dbdo($sql);
             $sql="UPDATE WishList SET Quantity=0, Status=1 WHERE Id = $IdWishList and Profile=$IdAccount";
             dbdo($sql);
         }
      }
  }
  exit_to_cart();

}   ##add_to_cart


############################################################################
sub exit_to_cart      #05.07.00 8:03
############################################################################

{

 #  $SelCat=$q->param('SelCat');
 #  $SelSubCat=$q->param('SelSubCat');
 #  $SelManuf=$q->param('SelManuf');
 #  $Id=$q->param('Id');
 #  $row=$q->param('row');
 #  $page=$q->param('page');

 #  com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&Id=$Id&row=$row&page=$page
 #  &SelManuf=$SelManuf

  $pathCart = $path_cgi."cart.pl";
  print("Location: $pathCart \n\n")

  # require 'cart.pl';
  # step1();

}   ##exit_to_cart