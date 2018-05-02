#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / product.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;
require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

my $pathUrlEmailFriend =$path_cgi."emailfriend.pl";
my $pathUrlProduct =$path_cgi."product.pl";

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

my $com = $q->param('com');     # Use this param to select form
if ( $com eq ''               ) {list_category(); }
elsif ( $com eq 'Product'     ) { product(); }
elsif ( $com eq 'Page'        ) { product(); }
elsif ( $com eq 'Description' ) { product_description(); }
elsif ( $com eq 'Option1'     ) { option_description(); }

############################################################################
sub list_category        #17.02.2000 15:39   Show Category list
############################################################################

{

$count_outer=0;
$i=0;
str_table_right;

my $sql="SELECT distinct Category.Id, Category.Name
         FROM Category, Product
         WHERE Category.Status=0 and Product.Category=Category.Id and Product.Status = 0
         ORDER BY Category.Name";
dbexecute($sql);
$count_outer = $cursor->rows;
while (($Id, $Name) =dbfetch()) {

       $j = 0;
       $count_inner=0;
       $str_sub_cat_menu='';

       $sql="SELECT distinct Subcategory.Id, Subcategory.Name
             FROM Subcategory, Product, Category
             WHERE Subcategory.Category=$Id and Subcategory.Status=0 and Product.Category=$Id
                   and Product.Subcategory=Subcategory.Id and Product.Status=0
             ORDER BY Subcategory.Name";
       $cursor1=$dbh->prepare($sql);
       $cursor1->execute;
       $count_inner = $cursor1->rows;

       $i++;
       while (($IdSub, $NameSub) =$cursor1->fetchrow_array) {
               $j++;
               if ( $count_inner == $j) {
                   $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty_end.jpg' width=13 align=absMiddle border=0>";
               }
               else  {
                   $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty.jpg' width=13 align=absMiddle border=0>";
               }

               if ( $count_outer != $i) {
                   $str_empty_line="<IMG height=18  src='/store/icon/icon_empty_line.jpg' width=13 align=absMiddle border=0>";
               }
               else {
                  $str_empty_line="<IMG height=18 src='/store/img/pix.gif' width=13 align=absMiddle border=0>";
               }
               $str_sub_cat_menu.="<TR><TD vAlign=top align=left width=13 >$str_empty_line</td>
               <TD vAlign=top align=left ><IMG height=1 src='/store/img/pix.gif'
               width=18>$str_cat_empty<IMG height=1 src='/store/img/pix.gif'
               width=3><A  href='".$pathUrlProduct."?com=Product&SelCat=$Id&SelSubCat=$IdSub'
               >&nbsp;$NameSub</A></TD></TR>";
      }

      if ( $count_outer == $i) {
          $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty_end.jpg' width=13 align=absMiddle border=0>";
          $str_cat_plus = "<IMG id=plus".$Id."   onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=expanded   height=18  src='/store/icon/icon_plus_end.jpg' width=13 align=absMiddle border=0>";
          $str_cat_minus="<IMG  id=minus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=collapsed height=18  src='/store/icon/icon_minus_end.jpg' width=13 align=absMiddle border=0>";
      }
      else  {
          $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty.jpg' width=13 align=absMiddle border=0>";
          $str_cat_plus = "<IMG id=plus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=expanded height=18  src='/store/icon/icon_plus.jpg' width=13   align=absMiddle border=0>";
          $str_cat_minus="<IMG id=minus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=collapsed height=18  src='/store/icon/icon_minus.jpg' width=13 align=absMiddle border=0>";
      }

      if ( $j == 0 )    {

         $str_sub_cat_menu='';
         $str_table_right.="
         <TR>
             <TD vAlign=top align=left width=17><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=263>$str_cat_empty<A  href='".$pathUrlProduct."?com=Product&SelCat=$Id'>&nbsp;<b>$Name</b></A></TD>
         </TR>";
      }
      else {
         $str_table_right.="
         <TR>
             <TD vAlign=top align=left width=17><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=263>$str_cat_plus"."$str_cat_minus<a id=cat".$Id." href=\"javascript:onClick=outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\">&nbsp;<b>$Name</b></div><DIV id=subcat".$Id." CLASS=collapsed2><TABLE border=0 cellPadding=0 cellSpacing=0>".$str_sub_cat_menu."</table></div></TD>
         </TR>";
      }
}

if ($i < 1)  {
   $str_table_right="<TR><TD vAlign=top align=left><font color='FF0000'>Sorry. Products search did not return any results.
   Please try again. If the problem persists, please send description to Store Customer Support.</font><br><br>";
}


########## Start Manufacturers #############
$count_outer=0;
$i=0;
str_table_left;

$sql="SELECT distinct Manufacturer.Id, Manufacturer.Name
         FROM  Manufacturer, Product
         WHERE Manufacturer.Status=0 and Product.ManufacturerName=Manufacturer.Id and Product.Status=0
         ORDER BY Manufacturer.Name";
dbexecute($sql);

$count_outer = $cursor->rows;
while (($Id, $Name) =dbfetch()) {

       $j = 0;
       $count_inner=0;
       $str_sub_cat_menu='';

       $sql="SELECT distinct Category.Id, Category.Name
       FROM Category, Product
       WHERE Category.Status=0 and Product.Category=Category.Id and Product.Status = 0 and
             Product.ManufacturerName=$Id
       ORDER BY Category.Name";
       $cursor1=$dbh->prepare($sql);
       $cursor1->execute;
       $count_inner = $cursor1->rows;

       $i++;
       while (($IdSub, $NameSub) =$cursor1->fetchrow_array) {

               $j++;
               if ( $count_inner == $j) {
                   $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty_end.jpg' width=13 align=absMiddle border=0>";
               }
               else  {
                   $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty.jpg' width=13 align=absMiddle border=0>";
               }

               if ( $count_outer != $i) {
                   $str_empty_line="<IMG height=18  src='/store/icon/icon_empty_line.jpg' width=13 align=absMiddle border=0>";
               }
               else {
                  $str_empty_line="<IMG height=18 src='/store/img/pix.gif' width=13 align=absMiddle border=0>";
               }
               $str_sub_cat_menu.="<TR><TD vAlign=top align=left width=13 >$str_empty_line</td><TD vAlign=top align=left
               ><IMG height=1 src='/store/img/pix.gif' width=18>$str_cat_empty<IMG height=1 src='/store/img/pix.gif' width=3
               ><A  href='".$pathUrlProduct."?com=Product&SelManuf=$Id&SelCat=$IdSub'>&nbsp;<b>$NameSub</b></A></TD></TR>";
      }

      if ( $count_outer == $i) {
          $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty_end.jpg' width=13 align=absMiddle border=0>";
          $str_cat_plus = "<IMG id=plus".$Id."   onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=expanded   height=18  src='/store/icon/icon_plus_end.jpg' width=13 align=absMiddle border=0>";
          $str_cat_minus="<IMG  id=minus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=collapsed height=18  src='/store/icon/icon_minus_end.jpg' width=13 align=absMiddle border=0>";
      }
      else  {
          $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty.jpg' width=13 align=absMiddle border=0>";
          $str_cat_plus = "<IMG id=plus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=expanded height=18  src='/store/icon/icon_plus.jpg' width=13   align=absMiddle border=0>";
          $str_cat_minus="<IMG id=minus".$Id."  onClick=\"outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\"  CLASS=collapsed height=18  src='/store/icon/icon_minus.jpg' width=13 align=absMiddle border=0>";
      }

      if ( $j == 0 )    {

         $str_sub_cat_menu='';
         $str_table_left.="
         <TR>
             <TD vAlign=top align=left width=17><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=263>$str_cat_empty<A  href='".$pathUrlProduct."?com=Product&SelManuf=$Id'>&nbsp;<b>$Name</b></A></TD>
         </TR>";
      }
      else {
         $str_table_left.="
         <TR>
             <TD vAlign=top align=left width=17><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=263>$str_cat_plus"."$str_cat_minus<a id=cat".$Id." href=\"javascript:onClick=outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\">&nbsp;<b>$Name</b></div><DIV id=subcat".$Id." CLASS=collapsed2><TABLE border=0 cellPadding=0 cellSpacing=0>".$str_sub_cat_menu."</table></div></TD>
         </TR>";
      }
}

if ($i < 1)  {
   $str_table_left="<TR><TD vAlign=top align=left><font color='FF0000'>Sorry. Products search did not return any results.
   Please try again. If the problem persists, please send description to Store Customer Support.</font><br><br>";
}


$str_menu_top="
  <div style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlProduct'><u>Products</u></A></div>";


#HTML template: category.html
print "Content-type: text/html\n\n";
$template_file=$path_html."html/product_main.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_table_left'}=$str_table_left;
$VAR{'str_table_right'}=$str_table_right;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template1.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##list_category



############################################################################
sub product       #19.02.2000 8:47   Show Products list
############################################################################

{

my $SelCat=$q->param('SelCat');
my $SelSubCat=$q->param('SelSubCat');
my $SelManuf=$q->param('SelManuf');
my $Print=$q->param('Print');

$row=$q->param('row');
$page=$q->param('page');

if ((!defined $row)||($row == '')) { $row=5; }
if ((!defined $page)||($page == '')) { $page=1; }
my $rowLast=$page*$row;
my $rowFirst=($page-1)*$row;
my $n=$rowFirst;
my $limit=100;
my $str_navig='';
my $navig = 0;
$str_sql='';

my $pathUrlPage="$pathUrlProduct?com=Page&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&row=$row";

my $pathDescription=$pathUrlProduct."?com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&row=$row&page=$page";
my $str_menu_top;
my $str_table;
my $str_sub_cat;
my $str_sub_cat_menu;
my $str_NameSub;

## Start Category and SubCategory Menu ###
if ( $SelSubCat != '') {

    $count_inner=0;
    $j=0;
    $sql="SELECT distinct Subcategory.Id, Subcategory.Name  FROM Subcategory, Product, Category
          WHERE Subcategory.Category=$SelCat and Subcategory.Status=0 and Product.Category=$SelCat
                   and Product.Subcategory=Subcategory.Id and Product.Status=0
          ORDER BY Subcategory.Name";
    dbexecute($sql);
    $count_inner = $cursor->rows;

    while (( $IdSub, $NameSub, $CatMenuName) =dbfetch()) {

         $j++;
         if ( $count_inner == $j) {
            $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty_end.jpg' width=13 align=absMiddle border=0>";
         }
         else  {
             $str_cat_empty = "<IMG height=18  src='/store/icon/icon_empty.jpg' width=13 align=absMiddle border=0>";
         }

         if ($SelSubCat == $IdSub) {
             $str_sub_cat_menu.="
                <TR><TD vAlign=top align=left ><IMG height=1 src='/store/img/pix.gif'
                width=30>$str_cat_empty<IMG height=1
                src='/store/img/pix.gif'
                width=3><IMG height=7  src='/store/icon/icon_select.gif' width=7><A  href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$IdSub&row=$row&page=$page'
                ><font color='#ff0000'>&nbsp;$NameSub</font></A></TD></TR>";

                $str_NameSub="<u>".$NameSub."</u>";
         }
         else
         {
             ###&page=$page BUG

             $str_sub_cat_menu.="
                <TR><TD vAlign=top align=left ><IMG height=1 src='/store/img/pix.gif'
                width=30>$str_cat_empty<IMG height=1
                src='/store/img/pix.gif' width=3><A href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$IdSub&row=$row'
                >&nbsp;&nbsp;&nbsp;$NameSub</A></TD></TR>";
         }

    }
    $str_sub_cat_menu="<TABLE border=0 cellPadding=0 cellSpacing=0 width='100%'>
     <TR><TD vAlign=top align=left ><IMG height=5 src='/store/img/pix.gif' width=25></TD></TR>".$str_sub_cat_menu."</table>";
}
## End Category and SubCategory Menu ###

if ( $SelCat ne '') {
  $str_sql=" and Category.Id=$SelCat";
}


if ( $SelCat eq 'New') {
  $str_sql = " and Product.NewBox=0 ";
  $SelAll='New Products';
}
elsif ( $SelCat eq 'Special') {
  $str_sql = " and Product.SpecialBox=0 ";
  $SelAll='Special Offers';
}
elsif ( $SelCat eq 'Top') {
  $str_sql = " and Product.TopBox=0 ";
  $SelAll='Top Sellers';
}

if ( $SelManuf ne '') {
  $str_sql = " and Product.ManufacturerName=$SelManuf ".$str_sql;
  $sql="SELECT Manufacturer.Name FROM  Manufacturer  WHERE Manufacturer.Id = $SelManuf";
  dbexecute($sql);
  $SelAll = dbfetch();
}

$i=0;
$sql="SELECT Product.Id,Product.StoreProductNumber,Category.Id, Category.Name,Product.Subcategory,
             Product.StoreProductName,Product.ManufacturerProductNumber,
             Manufacturer.Id,Manufacturer.Name,Product.ManufacturerProductName,
             Product.ProductShortDescription,Product.ProductSmallPicture,
             Product.ProductDetailedDescription, Product.Price,Product.PriceType,
             Product.Status, Product.NewBox, Product.SpecialBox, Product.TopBox,
             TypeOfAvailable.Name
      FROM Product,Category,Manufacturer, TypeOfAvailable
      WHERE Product.Category=Category.Id and Product.ManufacturerName=Manufacturer.Id
             and Product.TypeOfAvailable=TypeOfAvailable.Id
             and  Product.Status=0 $str_sql
            ORDER BY Category.Name,Product.Subcategory,Product.Bullet";
dbexecute($sql);

my $pathImg =$path."product_image/";  # path to product's picture

while (( $Id,$StoreProductNumber,$CategoryId,$Category,$Subcategory,$StoreProductName,
         $ManufacturerProductNumber,$ManufacturerId, $ManufacturerName,$ManufacturerProductName,
         $ProductShortDescription,$ProductSmallPicture, 
         $ProductDetailedDescription,$Price,$PriceType, $Status,
         $NewBox, $SpecialBox, $TopBox,
         $TypeOfAvailable) =dbfetch()) {


   $CategoryLink ="<a href='".$pathUrlProduct."?com=Product&SelCat=$CategoryId&row=$row&page=1' class=CategoryDescription title='Show all products in this category'>$Category</a>";
   $ManufacturerLink ="Manufacturer: <a href='".$pathUrlProduct."?com=Product&SelManuf=$ManufacturerId&row=$row&page=1' class=CategoryDescription title='Show all products of this manufacturer'>$ManufacturerName</a>";

   if ( $Subcategory > 0 ) {
       $sql="SELECT Name FROM Subcategory  WHERE Id=$Subcategory";
       $cursor1=$dbh->prepare($sql);
       $cursor1->execute;
      ($SubcategoryName) = $cursor1->fetchrow_array;
       $CategoryLink.=" &nbsp;/&nbsp; <a href='".$pathUrlProduct."?com=Product&SelCat=$CategoryId&SelSubCat=$Subcategory&row=$row&page=1' class=CategoryDescription title='Show all products in this subcategory'>$SubcategoryName</a>";
    }



    ############## top menu #######################

    if ($SelSubCat != '') {
        $str_menu_top="
        <div align=left style='FONT-WEIGHT: normal; FONT-SIZE: 11px; COLOR: #1b5665; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none'><A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlProduct'
        >Products</A> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&row=$row&page=1'
        class='PathSite'> $Category</a> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&row=$row&page=$page'
        class='PathSite'><u>$str_NameSub</u></a></div>";
    }
    else {
        if (($SelCat eq 'New')||($SelCat eq 'Special')||($SelCat eq 'Top')) { 
          $SelAllTmp=$SelAll;
        }
        elsif ( $SelManuf ne '') {
          if ( $SelCat ne '') { $SelAllTmp=$SelAll." ($Category)";  }
          else  { $SelAllTmp=$SelAll; }
        }
        else {  
          $SelAllTmp=$Category; 
        }
        $str_menu_top="
        <div align=left style='FONT-WEIGHT: normal; FONT-SIZE: 11px; COLOR: #1b5665; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none'><A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlProduct'
        >Products</A> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelManuf=$SelManuf&row=$row&page=$page' class='PathSite'><u>$SelAllTmp</u></a></div>";
       
    }

    ########################33##########
    # Mark New, Top, Specials Products

    if ( $TopBox==0 ) { $str_status_top="<img  src='/store/icon/icon_top.gif' border=0 height=10 width=60>"; }
    else { $str_status_top=''; }

    if ( $SpecialBox==0 ) { $str_status_special="<img  src='/store/icon/icon_offer3.gif' border=0>"; }
    else { $str_status_special=''; }

    if ( $NewBox==0 ) { $str_status_new="<img src='/store/icon/icon_new.gif' border='0' width=30 height=10>"; }
    else { $str_status_new=''; }
    ########################33##########


    if (($SelSubCat == '')||($SelSubCat == $Subcategory )) {
       if (($rowFirst<=$i)&&($i<$rowLast))  { # Select only rows for this page
       $n++;

       $Price=converter($Price);
       $Price="\$ ".$Price;
       if ($access_key eq "true") {
          $str_shop_wish="
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' title ='add product to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
          <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to shopping cart</a>&nbsp;&nbsp;</td>
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href='".$path_cgi."wishlist.pl?comWish=AddToWishList&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page'  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow.gif' height=15 width=36 border='0'></a></td>
          <td align=right>&nbsp;<a href='".$path_cgi."wishlist.pl?comWish=AddToWishList&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to wish list</a>&nbsp;&nbsp;</td>
          ";
       }
       else {
          $str_shop_wish="
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' title ='add product to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
          <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to shopping cart</a>&nbsp;&nbsp;</td>
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\"  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\" class=mr_grey>Add to wish list</a>&nbsp;&nbsp;</td>
          ";
       }

       if (($PriceType ==2)&&($access_key ne "true")) {
          $Price="<a href='".$path_cgi."account.pl?com=Login' class=PriceType>Login</u></b></a>";
          $str_shop_wish="
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your shopping cart. You have to login first.')\" title ='add product to shopping cart'><img src='/store/icon/icon_cart_arrow_grey.gif' height=15 width=37 border='0'></a></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your shopping cart. You have to login first.')\" class=mr_grey>Add to shopping cart</a>&nbsp;&nbsp;</td>
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\"  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td>
          <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\" class=mr_grey>Add to wish list</a>&nbsp;&nbsp;</td>
          ";
       }
       if ($PriceType ==3) {
          $Price="<a href='".$path_cgi."contact.pl' class=PriceType>Contact Us</a>";
          $str_shop_wish="";
       }

       $str_table.="
       <TABLE border=0 cellPadding=0 cellSpacing=0 width=100% >
        <tr><td  width=150 bgcolor='#468499' align=center class=ProductNumber><b><font color='#ffffff'>$StoreProductNumber</font></b></td><td colspan=2 bgcolor='#468499' height=18 align=right>$str_status_special</td></tr>
        <tr>
          <td width=169 align=center>
                <table cellSpacing=0 cellPadding=0 width=100% border=0 align=center valign=middle>
                <tr><td height=7 align=center></td></tr>
                <tr><td align=center><a href='$pathDescription&Id=$Id'  title='product details'><img src='/store/product_image/$ProductSmallPicture' width=150 border='0' ></a><br></td></tr>
                <tr><td height=7 align=center></td></tr>
                </table>
          </td>
          <td bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td>
          <td width=821 align=center height='100%'>

             <table cellSpacing=0 cellPadding=0 width=100% border=0 height=100%>
             <tr><td align=left valign=top>
                 <table cellSpacing=0 cellPadding=0 width=100% border=0>
                 <tr><TD colspan=2 height ='13'></TD></tr>
                 <tr><td align=left width=4%>&nbsp;</td><td width=96% align=left valign=top><a href='$pathDescription&Id=$Id' title ='product details' class=ProductNumber><b><font color='#ff0000'>$StoreProductNumber</font> - $StoreProductName</b></a>&nbsp;&nbsp;$str_status_new&nbsp;$str_status_top</td></tr>
                 <tr><TD colspan=2 height ='10'></TD></tr>
                 <tr><td align=left>&nbsp;</td><td align=left valign=top>$ProductShortDescription</TD></tr>
                 <tr><td align=left></td><TD height ='10'></TD></tr>
                 <tr><td align=left></td><TD>$CategoryLink&nbsp;&nbsp;&nbsp;$ManufacturerLink</tr>
                 <tr><td align=left></td><TD height ='30' valign=middle><b>Availability:&nbsp; <i>$TypeOfAvailable</i></b></TD></tr>
                  </table>
            </td>
            </tr>
            <tr><td align=left valign=bottom>
                <table cellSpacing=0 cellPadding=0 width=100% border=0  valign=bottom>
                <tr><TD height=1 width='4%'></TD><td colspan=2 width='96%' bgcolor='#468499' height=1 align=right></td></tr>
                <tr><TD colspan=3 height ='5'></TD></tr>
                <tr><TD height=1>&nbsp;</TD>
                    <td align=left valign=middle width=19%>
                      <table cellSpacing=0 cellPadding=0 width=100% border=0  align=center >
                      <tr><td align=left valign=middle class=ProductNumber><b>Price: &nbsp;<font color='#000000'>$Price</font></b></td></tr>
                      </table>
                    </td>
                    <td align=right valign=middle width=81%>
                      <TABLE border=0 cellPadding=0 cellSpacing=0 bordercolor='#5fa0b2' align=right>
                      <tr>
                      <td align=right>&nbsp;<a href='$pathDescription&Id=$Id' title ='product details'><img src='/store/icon/icon_lupa_green.gif' height=15 width=13 border='0'></a></td>
                      <td align=right>&nbsp;<a href='$pathDescription&Id=$Id' class=mr>Product details</a>&nbsp;&nbsp;</td>
                      <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
                      <td align =left >&nbsp;<a href='/store/product_pdf/$ProductDetailedDescription' target='Win' onClick='openWinPDF()' class='mr'>Download full description in format</a></td>
                      <td align =left >&nbsp;<a href='/store/product_pdf/$ProductDetailedDescription' target='Win' onClick='openWinPDF()' class='mr' title ='download full description in PDF format'><img src='/store/icon/icon_pdf.gif' border='0' width=16 height=16></a>&nbsp;&nbsp;</td>
                      $str_shop_wish
                      </tr>
                     </table>
                 </td>
                 </tr>
                 <tr><TD colspan=3 height ='5'></TD></tr>
                 </table>
               </td></tr>
               </table>      
           </td>
        </tr>
        <tr><td colspan=3 bgcolor='#468499' height=1 align=right></td></tr>
         <tr><td colspan=3 align=right height=20></td></tr>
         </table>";

       }
       $i++;
       if ((sprintf("%d",($i%$row)) == 0 )&&( $limit-1 >= $navig )) {
         $navig++;
         if ( $page == $navig ){ $str_navig.="<span class=Pages>$navig</span>&nbsp;"; }
         else { $str_navig.="<a href='$pathUrlPage&page=$navig'  class=Pages>$navig</a>&nbsp;";}
       }
    }
}

$str_table.="<TABLE border=0 cellPadding=0 cellSpacing=0 width=100%></table>";


if (( $i > $navig*$row )&&( $limit-1 >= $navig )) {
  $navig++;
  if ( $page == $navig ){ $str_navig.="<span class=Pages>$navig</span>&nbsp;";}
  else { $str_navig.="<a href='$pathUrlPage&page=$navig' class=Pages>$navig</a>&nbsp;";}
}
$str_navig="&nbsp;<font size='2'>View List:&nbsp;&nbsp;".$str_navig."</font>";


# Count and check last page
$pageLast=sprintf("%d",($i%$row));
if ($pageLast==0) {$pageLast=($i/$row);}
else  {  $pageLast=sprintf("%d",($i/$row));  $pageLast++;  }
if ( $pageLast == 1) { $str_navig=''; }
                                                          
if (($SelCat eq 'New')||($SelCat eq 'Special')||($SelCat eq 'Top')) { 
   $SelAllTmp=$SelAll;
}
elsif ( $SelManuf ne '') {

   if ( $SelCat ne '') { 
      $sql="SELECT Name  FROM Category  WHERE Category.Id=$SelCat";
      dbexecute($sql);
      $Category = dbfetch();
      $SelAllTmp=$SelAll." ($Category)";  
   }
   else  { 
      $SelAllTmp=$SelAll; 
   }
}
else {  
   $sql="SELECT Name  FROM Category  WHERE Category.Id=$SelCat";
   dbexecute($sql);
   $Category = dbfetch();
   $SelAllTmp=$Category;  
}

$str_sub_cat="
        <TABLE cellSpacing=0 cellPadding=0 width=100% border=0>
        <TBODY>
        <TR><td vAlign=top align=middle width=163 background='/store/img/bgline.gif'></td><TD class=tabt width=626 background='/store/img/bgline.gif'
        height=18>&nbsp;&nbsp;$SelAllTmp </td><td vAlign=top align=right width=200 background='/store/img/bgline.gif'>&nbsp;&nbsp;$str_navig&nbsp;&nbsp;&nbsp;</TD></TR>
        <TR><td vAlign=top align=middle></td><TD>$str_sub_cat_menu </TD></tr>
        </table><br>";

$comURL="?comURL=\"".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&row=$row&page=$page\"";
$_=$comURL;   s/&/gomel/g; $comURL=$_;

$str_printer_bottom="
<SCRIPT>
function openWinPDF() {
  msgWindow=window.open('/store/product_pdf/$ProductDetailedDescription', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
}

function openWinEmail() {
  msgWindow=window.open('".$pathUrlEmailFriend.$comURL."','WinEmail', 'menubar=no, toolbars=no, status=no, scrollbars=no,resizable=no,width=400,height=480')
}
function openWinPrint() {
  msgWindow=window.open('".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
}

</SCRIPT>
              <TABLE border=0 cellPadding=0 cellSpacing=0 width='100%'>
             <tr>
             <td valing=top width='30' align ='right'><a href='".$pathUrlEmailFriend.$comURL."' target='WinEmail' onClick='openWinEmail()'  class='mr' title='Email this page to a colleague' ><img src='/store/icon/icon_mail.gif' border='0' width=20 height=20></a></td>
             <td valing=top width='160'>&nbsp;<a href='".$pathUrlEmailFriend.$comURL."' target='WinEmail' onClick='openWinEmail()'  class='mr' >Email this page to a colleague</a></td>
             <td valing=top width='30' align ='right'><a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1&row=$row&page=$page' target='Win' onClick='openWinPrint()' class='mr' title='Print page'><img src='/store/icon/icon_printer.gif' border='0' width=16 height=16></a></td>
             <td valing=top width='80'>&nbsp;&nbsp;<a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1&row=$row&page=$page' target='Win' onClick='openWinPrint()' class='mr'>Print page</a></td>
             <td width='500'></td>
             <td valing=top width='200' align=right>&nbsp;&nbsp;$str_navig&nbsp;&nbsp;&nbsp;</td>
             </tr>
             </table><br>";


$str_help_product="<TABLE border=0 cellPadding=0 cellSpacing=0 width=145 >
                  <tr><TD height=8></td></tr>
                 <tr><TD class='ware2'><li>To see the product details click on the product image or on the icon &nbsp;<img src='/store/icon/icon_lupa_green.gif' height=15 width=13 border='0'>
                   <br><li>To add the product to your shopping cart click on the icon &nbsp;<img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'>
                   <br><li>If you are not ready to buy the product right now but going to do it in the future you can add the product to your wish list &nbsp;<img src='/store/icon/icon_wish_arrow.gif' height=15 width=36 border='0'></TD>
                  <TD width=5></td></tr>
                  <tr><TD height=8></td></tr>
                  </table>";

if ($i < 1)  {

$str_table="<TABLE border=0 cellPadding=0 cellSpacing=0 width='100%' align=center><tr>
   <TD vAlign=top align=left><br><font color='FF0000'>&nbsp;&nbsp;&nbsp;Sorry. Products search did not return any results.
   Please try again. If the problem persists, please send description to Store Customer Support.</font><br><br>
   </TD></TR></table>";
}


######################################
if ( $Print==1 ) {
     print "Content-type: text/html\n\n";
     $template_file=$path_html."html/printer.html";
     $VAR{'path_cgi'}=$path_cgi;
     $VAR{'path_cgi_https'}=$path_cgi_https;
     $VAR{'str_menu_top'}=$str_menu_top;
     $VAR{'str_sub_cat'}=$str_sub_cat;
     $VAR{'str_table'}=$str_table;

     $template_file=parse_body($template_file, *STDOUT);
     $VAR{'template_file'}=$template_file;

     if ( !parse_template($path_html."html/printer.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
     }

     return;
}
######################################


#HTML template: product_list.html
print "Content-type: text/html\n\n";
$template_file=$path_html."html/product_list.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_sub_cat'}=$str_sub_cat;
$VAR{'str_table'}=$str_table;
$VAR{'str_printer_bottom'}=$str_printer_bottom;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;
$VAR{'str_help_product'}=$str_help_product;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template2.html", *STDOUT)) {
   print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##product


############################################################################
sub product_description     #18.02.2000  Show Product detailed description
############################################################################

{

# bug with SelSubCat

my $SelCat=$q->param('SelCat');
my $SelSubCat=$q->param('SelSubCat');
my $SelManuf=$q->param('SelManuf');
my $Id=$q->param('Id');
my $Print=$q->param('Print');
$row=$q->param('row');
$page=$q->param('page');

if ( $SelCat eq 'New'       ) {  $SelAll='New Products';  }
elsif ( $SelCat eq 'Special') {  $SelAll='Special Offers'; }
elsif ( $SelCat eq 'Top'    ) {  $SelAll='Top Sellers';   }

if ( $SelManuf ne '' ) {
  $sql="SELECT Manufacturer.Name FROM  Manufacturer  WHERE Manufacturer.Id = $SelManuf";
  dbexecute($sql);
  $SelAll = dbfetch();
}

# Select full information about the Product using its Id
$sql="SELECT Product.StoreProductNumber,Category.Id,Category.Name,Product.Subcategory,
             Product.StoreProductName,Product.ManufacturerProductNumber,
             Manufacturer.Id,Manufacturer.Name,Product.ManufacturerProductName,Product.Price,
             Product.PriceType, Product.ProductShortDescription, Product.ProductPicture,
             Product.ProductDetailedDescription,
             Product.Status, Product.NewBox, Product.SpecialBox, Product.TopBox,
             Product.ProductDescription, Product.ProductSpecification, Product.ProductTechNotes,
             Product.TypeOfAvailable

       FROM Product,Category,Manufacturer
       WHERE Product.Category=Category.Id and Product.ManufacturerName=Manufacturer.Id and
             Product.Id=$Id";
dbexecute($sql);

my ($StoreProductNumber,$CategoryId,$Category,$Subcategory,$StoreProductName,$ManufacturerProductNumber,
    $ManufacturerId,$ManufacturerName,$ManufacturerProductName,$Price,$PriceType,
    $ProductShortDescription,$ProductPicture, $ProductDetailedDescription,
    $Status, $NewBox, $SpecialBox, $TopBox,
    $ProductDescription, $ProductSpecification, $ProductTechNotes,
    $TypeOfAvailable) =dbfetch();

    $sql="SELECT Name FROM  TypeOfAvailable  WHERE Id = $TypeOfAvailable and Status=0";
    dbexecute($sql);
    $TypeOfAvailable = dbfetch();

$CategoryLink ="<a href='".$pathUrlProduct."?com=Product&SelCat=$CategoryId&row=$row&page=1' class=CategoryDescription>$Category</a>";
$ManufacturerLink ="Manufacturer: <a href='".$pathUrlProduct."?com=Product&SelManuf=$ManufacturerId&row=$row&page=1' class=CategoryDescription title='Show all products of this manufacturer'>$ManufacturerName</a>";

if ( $Subcategory > 0 ) {
  $sql="SELECT Name FROM Subcategory  WHERE Id=$Subcategory";
  dbexecute($sql);
  ($SubcategoryName) = dbfetch();
  $CategoryLink.=" &nbsp;/&nbsp; <a href='".$pathUrlProduct."?com=Product&SelCat=$CategoryId&SelSubCat=$Subcategory&row=$row&page=1' class=CategoryDescription>$SubcategoryName</a>";
}

     $Price=converter($Price);
     $Price="\$ ".$Price;
     $str_shop_wish_option_contact="<INPUT type=radio CHECKED name=Bundle value='true' id='AddBundle'> Add product+options&nbsp;&nbsp;<INPUT type=radio name=Bundle value='false' id='AddOptions'> Add options only";

     if ($access_key eq "true") {
        $str_shop_wish="
        <td align=right><a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' title ='add product to shopping cart' class=mr><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
        <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to shopping cart</a>&nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
        <td align=right>&nbsp;&nbsp;&nbsp;<a href='".$path_cgi."wishlist.pl?comWish=AddToWishList&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page'  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow.gif' height=15 width=36 border='0'></a></td>
        <td align=right>&nbsp;<a href='".$path_cgi."wishlist.pl?comWish=AddToWishList&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to wish list</a> &nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
        ";

       $str_shop_wish_option="
       <TABLE width=130 border=0 cellPadding=0 cellSpacing=0 >
       <tr><td align=center ><a href=\"javascript:add_cart_option()\" title ='add option(s) to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
       <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
       <td align=center ><a href=\"javascript:add_wishlist_option()\"  title ='add option(s) to my wish list'><img src='/store/icon/icon_wish_arrow.gif' height=15 width=36 border='0'></a></td></td>
       </tr></table>
       ";
      }
      else {
        $str_shop_wish="
        <td align=right><a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' title ='add product to shopping cart' class=mr><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
        <td align=right>&nbsp;<a href='".$path_cgi."cart.pl?comCart=AddToCart&com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page' class=mr>Add to shopping cart</a>&nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
        <td align=right>&nbsp;&nbsp;&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\"  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td>
        <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\" class=mr_grey>Add to wish list</a>&nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
        ";

       $str_shop_wish_option="
       <TABLE width=130 border=0 cellPadding=0 cellSpacing=0 >
       <tr><td align=center ><a href=\"javascript:add_cart_option()\" title ='add option(s) to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
       <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
       <td align=center ><a href=\"javascript:alert('You cannot add option(s) of this product to your wish list. You have to login first.')\"  title ='add option(s) to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td></td>
       </tr></table>
       ";
      }

     if (($PriceType ==2)&&($access_key ne "true")) {
        $Price="<a href='".$path_cgi."account.pl?com=Login' class=PriceType>Login</u></b></a>";
        $str_shop_wish="
        <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your shopping cart. You have to login first.')\" title ='add product to shopping cart'><img src='/store/icon/icon_cart_arrow_grey.gif' height=15 width=37 border='0'></a></td>
        <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your shopping cart. You have to login first.')\" class=mr_grey>Add to shopping cart</a>&nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
        <td align=right>&nbsp;&nbsp;&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\"  title ='add product to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td>
        <td align=right>&nbsp;<a href=\"javascript:alert('You cannot add this product to your wish list. You have to login first.')\" class=mr_grey>Add to wish list</a>&nbsp;&nbsp;&nbsp;</td>
        <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
       ";

       $str_shop_wish_option="
       <TABLE width=130 border=0 cellPadding=0 cellSpacing=0 >
       <tr><td align=center ><a href=\"javascript:alert('You cannot add option(s) of this product to your shopping cart. You have to login first.')\" title ='add option(s) to shopping cart'><img src='/store/icon/icon_cart_arrow_grey.gif' height=15 width=37 border='0'></a></td>
       <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
       <td align=center ><a href=\"javascript:alert('You cannot add option(s) of this product to your wish list. You have to login first.')\"  title ='add option(s) to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td></td>
       </tr></table>
       ";

     }
     if ($PriceType == 3) {
        $Price="<a href='".$path_cgi."contact.pl' class=PriceType>Contact Us</a>";
        $str_shop_wish_option_contact="<INPUT DISABLED type=radio name=Bundle value='true' id='AddBundle'><font color=#AAAAAA> Add product+options</font>&nbsp;&nbsp;<INPUT type=radio CHECKED name=Bundle value='false' id='AddOptions'> Add options only";
        $str_shop_wish="";

        if ($access_key eq "true") {
          $str_shop_wish_option="
          <TABLE width=130 border=0 cellPadding=0 cellSpacing=0 >
          <tr><td align=center ><a href=\"javascript:add_cart_option()\" title ='add option(s) to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=center ><a href=\"javascript:add_wishlist_option()\"  title ='add option(s) to my wish list'><img src='/store/icon/icon_wish_arrow.gif' height=15 width=36 border='0'></a></td></td>
          </tr></table>
          ";
        }
        else {
          $str_shop_wish_option="
          <TABLE width=130 border=0 cellPadding=0 cellSpacing=0 >
          <tr><td align=center ><a href=\"javascript:add_cart_option()\" title ='add option(s) to shopping cart'><img src='/store/icon/icon_cart_arrow.gif' height=15 width=37 border='0'></a></td>
          <td bgcolor='#ffffff' width=2><img src='/store/img/delimetr.gif' border='0'></td>
          <td align=center ><a href=\"javascript:alert('You cannot add option(s) of this product to your wish list. You have to login first.')\"  title ='add option(s) to my wish list'><img src='/store/icon/icon_wish_arrow_grey.gif' height=15 width=36 border='0'></a></td></td>
          </tr></table>
          ";
        }
     }

####################################################
$str_exit='';

if (($SelCat eq 'New')||($SelCat eq 'Special')||($SelCat eq 'Top')) { 
   $SelAllTmp=$SelAll;
}
elsif ( $SelManuf ne '') {

   if ( $SelCat ne '') { 
      $sql="SELECT Name  FROM Category  WHERE Category.Id=$SelCat";
      dbexecute($sql);
      $Category = dbfetch();
      $SelAllTmp=$SelAll." ($Category)";  
   }
   else  { 
      $SelAllTmp=$SelAll; 
   }
}
else {  
   $sql="SELECT Name  FROM Category  WHERE Category.Id=$SelCat";
   dbexecute($sql);
   $Category = dbfetch();
   $SelAllTmp=$Category;  
}


$str_menu_top="
   <div align=left  style='FONT-WEIGHT: normal; FONT-SIZE: 11px; COLOR: #1b5665; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlProduct'
   >Products</A> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelManuf=$SelManuf&row=$row&page=$page'
   class='PathSite'>$SelAllTmp</a> &gt; ";

   $str_exit="<a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelManuf=$SelManuf&row=$row&page=$page'";


$str_NameSub='';
if ( $SelSubCat ne '') {
   $sql="SELECT distinct Id, Name FROM Subcategory WHERE Status=0 and id = $SelSubCat";
   dbexecute($sql);
   while(($IdSub, $NameSub) =dbfetch()) {
      $str_NameSub=$NameSub;

      $str_menu_top="
      <div align=left  style='FONT-WEIGHT: normal; FONT-SIZE: 11px; COLOR: #1b5665; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
      <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrlProduct'
      >Products</A> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelManuf=$SelManuf&row=$row&page=1'
      class='PathSite'>$SelAllTmp</a> &gt; <a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&row=$row&page=$page'
      class='PathSite'>$str_NameSub</a> &gt; ";

      $str_exit="<a href='".$pathUrlProduct."?com=Product&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&row=$row&page=$page' ";
   }
}
####################################################

$str_menu_top.="<a href='$pathUrlProduct.?com=Description&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Id=$Id&row=$row&page=$page'
                class='PathSite'><u>$StoreProductNumber</u></a></div>";

    $str_sub_cat_text='';
    $str_sub_cat="
    <TABLE cellSpacing=0 cellPadding=0 width=100% border=0>
    <TR><td vAlign=top align=middle width=170 background='/store/img/bgline.gif'></td><TD class=tabt width=826 background='/store/img/bgline.gif'
    height=18></TD></TR>
    </table><br>";

    $AvOpTab2="
       <form name='wishlist' method=post action='$path_cgi"."wishlist.pl' style='margin:0'>
       <input type=hidden name=comWish value='AddToWishListOption' >
       <input type=hidden name=SelCat value='$SelCat' >
       <input type=hidden name=SelSubCat value='$SelSubCat' >
       <input type=hidden name=SelManuf value='$SelManuf' >
       <input type=hidden name=row value='$row' >
       <input type=hidden name=page value='$page' >
       <input type=hidden name=Id value='$Id' >
       <input type=hidden name=com value='Description' >
       <input type=hidden name=Bundle value='false' >
      ";
   $AvOpTab2_script='';

   $AvOpTab1="
       <form name='cart' method=post action='$path_cgi"."cart.pl' style='margin:0'>
       <input type=hidden name=comCart value='AddToCartOption' >
       <input type=hidden name=SelCat value='$SelCat' >
       <input type=hidden name=SelSubCat value='$SelSubCat' >
       <input type=hidden name=SelManuf value='$SelManuf' >
       <input type=hidden name=Id value='$Id' >
       <input type=hidden name=row value='$row' >
       <input type=hidden name=page value='$page' >
       <input type=hidden name=com value='Description' >

      <div id=child1 class=expanded2><table width='100%' border=0 cellPadding=0 cellSpacing=1>
      <tr><TD bgcolor='#468499' height='1' colspan='6'></TD></tr>
      <tr bgcolor='#468499'><td width='7%' height=20 align='center' valign='middle' class=opt><font face='tahoma, Arial, Helvetica, sans-serif'  color='#ffffff'><b>Add</b></font></td>
                            <td width='14%' align='center' valign='middle' class=opt><font face='tahoma, Arial, Helvetica, sans-serif' color='#ffffff'><b>Name</b></font></td>
                            <td width='42%' align='center' class=opt><font face='tahoma, Arial, Helvetica, sans-serif' color='#ffffff'><b>Description</b></font></td>
                            <td width='13%' align='center' class=opt><font face='tahoma, Arial, Helvetica, sans-serif' color='#ffffff'><b>Price</b></font></td>
                            <td width='12%' align='center' class=opt><font face='tahoma, Arial, Helvetica, sans-serif' color='#ffffff'><b>Availability</b></font></td>
                            <td width='12%' align='center' class=opt><font face='tahoma, Arial, Helvetica, sans-serif' color='#ffffff'><b>Details</b></font></td>
                            </tr>
     <tr><TD bgcolor='#468499' height='1' colspan='6'></TD></tr>";

     $j=0;
     $sql="SELECT Id, ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, TypeOfAvailable, Status
           FROM OptionList  WHERE ProductId=$Id and Status=0";
     dbexecute($sql);
     while (($OptionId, $ProductId, $OptionNumber, $OptionName, $OptionDescription, $OptionPicture, $OptionPrice, $OptionTypeOfAvailable, $OptionStatus)=dbfetch()) {

        $str_OptionTypeOfAvailable='';
        $sql="SELECT Name FROM  TypeOfAvailable  WHERE Id = $OptionTypeOfAvailable and Status=0";
        $cursor5=$dbh->prepare($sql);
        $cursor5->execute;
        $str_OptionTypeOfAvailable =$cursor5->fetchrow_array;

     
        $_=$OptionDescription;      (s/^\s+//); (s/\s+$//);  $OptionDescription=$_;
        $_=$OptionPicture;         (s/^\s+//); (s/\s+$//);   $OptionPicture=$_;

        $str_OptionDescription="&nbsp;";
        if (($OptionDescription eq '')&&($OptionPicture eq '')) {
             $str_OptionDescription="&nbsp;";
        }
        else  {
             $str_OptionDescription="
             <SCRIPT>
             function openWinOption() {
                 msgWindow=window.open('".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&SelSubCat=$SelSubCat&Print=1', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
             }
             </SCRIPT>
             <a href='$pathUrlProduct?com=Option1&Id=$OptionId'  class='mr' target='Win' onClick='openWinOption()' >More details</a>";
############################ <IMG height=9  src='/store/icon/icon_lupa_small.gif' width=9 align=absMiddle border=0>
        }

        $j++;
        $OptionPrice=converter($OptionPrice);

        $AvOpTab1.="<tr bgcolor='#ffffff'><td height=18 align='center' valing='middle'><input type=checkbox name=ProductOption".$j." size=10 value=$OptionId></td>
                                     <td align='left' valing='middle' class=opt><font face='Verdana, Arial, Helvetica, sans-serif' color='#1a1a1a'>&nbsp;$OptionNumber</font></td>
                                     <td align='left' class=opt><font face='Verdana, Arial, Helvetica, sans-serif' color='#000000'>&nbsp;$OptionName</font></td>
                                     <td align='right' class=opt><font face='Verdana, Arial, Helvetica, sans-serif' color='#000000'>\$ $OptionPrice&nbsp;&nbsp;</font></td>
                                     <td align='center' class=opt><font face='Verdana, Arial, Helvetica, sans-serif' color='#000000'>$str_OptionTypeOfAvailable</font></td>
                                     <td align='center' class=opt><font face='Verdana, Arial, Helvetica, sans-serif' color='#000000'>$str_OptionDescription</font></td>
                                     </tr>
                                     <tr><TD bgcolor='#468499' height='1' colspan='6'></TD></tr>";
        $AvOpTab2.="<input type=hidden name=ProductOption".$j." value='' >";
        $AvOpTab2_script.="
            document.wishlist.ProductOption".$j.".value='';
            if (document.cart.ProductOption".$j.".checked) {
               document.wishlist.ProductOption".$j.".value=document.cart.ProductOption".$j.".value;
               mycount++;
            }
           ";
     }

    $AvOpTab1.="</table>
          <table width='100%' border=0 cellPadding=0 cellSpacing=1>
          <tr bgcolor='#ffffff'>
          <td align='left' width=30% class=opt>
            <TABLE width=100% border=0 cellPadding=0 cellSpacing=0 >
            <tr><td colspan=3 height=10 align=right valign=middle></td>
            <tr><td align=left class=opt><font face='Verdana, Arial, Helvetica, sans-serif'  color='#000000'>

     $str_shop_wish_option_contact

                   </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            </tr></table>
         </td>
         <td align='left' width=70% valing='middle'>

     $str_shop_wish_option

         </td> </tr>
         </table></div>
         </form>";

    $AvOpTab1.="
      <SCRIPT>
      function add_cart_option() {
         mycount=0;
         $AvOpTab2_script
         if ( mycount == 0 ) { alert ('No selected item(s) to add to shopping cart!');  }
         else { document.cart.submit(); }
      }
      </SCRIPT>
      ";

     $AvOpTab2.="</form>";
     $AvOpTab2.="
      <SCRIPT>
      function add_wishlist_option() {
        mycount=0;
        $AvOpTab2_script

        if (document.getElementById('AddBundle').checked) {
           document.wishlist.Bundle.value='true';
        }
        else {
           document.wishlist.Bundle.value='false';
        }

        if ( mycount == 0 ) { alert ('No selected item(s) to add to your wish list!');  }
        else { document.wishlist.submit(); }
      }
      </SCRIPT>
      ";

# Mark Specials Products
if ( $TopBox==0 ) { $str_status_top="<img  src='/store/icon/icon_top.gif' border=0 height=10 width=60>"; }
else { $str_status_top=''; }

if ( $SpecialBox==0 ) { $str_status_special="<img  src='/store/icon/icon_offer3.gif' border=0 height=18 width=87>"; }
else { $str_status_special=''; }

if ( $NewBox==0 ) { $str_status_new="<img src='/store/icon/icon_new.gif' border='0' width=30 height=10>"; }
else { $str_status_new=''; }



$comURL="?comURL=\"".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&row=$row&page=$page&SelSubCat=$SelSubCat&SelManuf=$SelManuf\"";
$_=$comURL;   s/&/gomel/g; $comURL=$_;
$str_printer_bottom="
<SCRIPT>
function openWinEmail() {
  msgWindow=window.open('".$pathUrlEmailFriend.$comURL."','WinEmail', 'menubar=no, toolbars=no, status=no, scrollbars=no,resizable=no,width=400,height=480')
}

function openWinZoom() {
  msgWindow=window.open('/store/product_image/$ProductPicture', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
}

function openWinPDF() {
  msgWindow=window.open('/store/product_pdf/$ProductDetailedDescription', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
}

function openWinPrint() {
  msgWindow=window.open('".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1', 'Win', 'menubar=yes, toolbars=no, status=no, scrollbars=yes, resizable=yes, width=650, height=400')
}
</SCRIPT>

              <TABLE border=0 cellPadding=0 cellSpacing=0 width='100%'>
             <tr>
              <td width='5' align ='left'></td>
              <td width='18' align ='left'><a href='/store/product_image/$ProductPicture'  target='Win' onClick='openWinZoom()' class='mr' title='Zoom In image'><img src='/store/icon/icon_lupa_green.gif' height=15 width=13 border='0'></a> </td>
              <td align=left><a href='/store/product_image/$ProductPicture' target='Win' onClick='openWinZoom()' class='mr'>Zoom In image</a> </td>
              <td width='12' align ='left'><img src='/store/img/delimetr.gif' border='0'></td>
              <td width='20' align ='left'><a href='/store/product_pdf/$ProductDetailedDescription' target='Win' onClick='openWinPDF()' class='mr' title='Download full description in PDF format'> <img src='/store/icon/icon_pdf.gif' border='0' width=16 height=16></a> </td>
              <td align =left><a href='/store/product_pdf/$ProductDetailedDescription' target='Win' onClick='openWinPDF()' class='mr'>Download full description in PDF format</a> </td>
              <td width='16' align ='left'><img src='/store/img/delimetr.gif' border='0'></td>
              <td width='20' align ='left'><a href='".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1' target='Win' onClick='openWinPrint()' class='mr' title='Print page'><img src='/store/icon/icon_printer.gif' border='0'></a></td>
              <td align=left >&nbsp;<a href='".$pathUrlProduct."?com=Description&Id=$Id&SelCat=$SelCat&SelSubCat=$SelSubCat&SelManuf=$SelManuf&Print=1' target='Win' onClick='openWinPrint()' class='mr'>Print page</a>&nbsp;&nbsp;</td>
              <td width='10' align ='left'><img src='/store/img/delimetr.gif' border='0'></td>
              <td width='20' align ='left'><a href='' class='mr' title='Email this page to a friend(s)'><img src='/store/icon/icon_mail.gif' border='0' ></a></td>
              <td  align=left>&nbsp;<a href='".$pathUrlEmailFriend.$comURL."' target='WinEmail' onClick='openWinEmail()'  class='mr' >Email this page to a friend(s)</a></td>
             </tr></table>";

###########################################################################

$countTabs=0;

if ($j==0) { $AvOpTab='';  $AvOpTab1=''; $AvOpTab2=''; }
else {

   $AvOpTab="<TD width='1' align=center></TD>
   <TD id=child1_1 class=collapsed2 align=center width=140 height='26' background='/store/img/tab_off.gif'>
   <a href=\"javascript:onClick=
        outliner2('child1', 'child2', 'child3', 'child4');
        outliner2('child1_2', 'child1_1');
        outliner2('child2_1', 'child2_2');
        outliner2('child3_1', 'child3_2');
        outliner2('child4_1', 'child4_2');\"
            class='Tabs'>Available Options</a>
   </TD>
   <TD id=child1_2 class=expanded2 align=center width=140 height='26' background='/store/img/tab_on.gif'><div class=Tabs>Available Options</div></TD>
   ";
   $countTabs++;
}

if (( $ProductDescription eq '') ||( !defined $ProductDescription)){
   $DescriptionTab=""; $DescriptionTab1="";
}
else {

    if ($countTabs == 0) { $expanded2="collapsed2"; $collapsed2="expanded2"; }
    else  {                $expanded2="expanded2"; $collapsed2="collapsed2"; }

    $DescriptionTab="<TD width='1' align=center></TD>
    <TD id=child2_1 class=$expanded2 align=center width=140 height='26' background='/store/img/tab_off.gif'>
    <a href=\"javascript:onClick=
        outliner2('child2', 'child1','child3', 'child4');
        outliner2('child1_1', 'child1_2');
        outliner2('child2_2', 'child2_1');
        outliner2('child3_1', 'child3_2');
        outliner2('child4_1', 'child4_2');\"
                   class='Tabs'>Description</a></TD>
        <TD id=child2_2 class=$collapsed2 align=center width=140 height='26' background='/store/img/tab_on.gif'><div class=Tabs>Description</div></TD>
       ";
    $DescriptionTab1=$collapsed2;
    $countTabs++;
}

if (( $ProductSpecification eq '') ||( !defined $ProductSpecification)){
   $SpecificationTab=""; $SpecificationTab1="";
}
else {

    if ($countTabs == 0) { $expanded2="collapsed2"; $collapsed2="expanded2"; }
    else  {                $expanded2="expanded2"; $collapsed2="collapsed2"; }

   $SpecificationTab="<TD width='1' align=center></TD>
   <TD id=child3_1 class=$expanded2 align=center width=140 height='26' background='/store/img/tab_off.gif'>
   <a href=\"javascript:onClick=
        outliner2('child3', 'child1', 'child2', 'child4');
        outliner2('child1_1', 'child1_2');
        outliner2('child2_1', 'child2_2');
        outliner2('child3_2', 'child3_1');
        outliner2('child4_1', 'child4_2');\"
                   class='Tabs'>Specification</a></TD>
   <TD id=child3_2 class=$collapsed2 align=center width=140 height='26' background='/store/img/tab_on.gif'><div class=Tabs>Specification</div></TD>
   ";
    $SpecificationTab1=$collapsed2;
    $countTabs++;
}

if (( $ProductTechNotes eq '') ||( !defined $ProductTechNotes)){
   $TechNotesTab=""; $TechNotesTab1="";
}
else {

    if ($countTabs == 0) { $expanded2="collapsed2"; $collapsed2="expanded2"; }
    else  {                $expanded2="expanded2"; $collapsed2="collapsed2"; }

    $TechNotesTab="<TD width='1' align=center></TD>
    <TD id=child4_1 class=$expanded2 align=center width=140 height='26' background='/store/img/tab_off.gif'><a href=\"javascript:onClick=
          outliner2('child4', 'child1','child2', 'child3', 'child5');
          outliner2('child1_1', 'child1_2');
          outliner2('child2_1', 'child2_2');
          outliner2('child3_1', 'child3_2');
          outliner2('child4_2', 'child4_1');\"
                    class='Tabs'>Tech Notes</a></TD>
    <TD id=child4_2 class=$collapsed2 align=center width=140 height='26' background='/store/img/tab_on.gif'><div class=Tabs>Tech Notes</div></TD>
    ";
    $TechNotesTab1=$collapsed2;
    $countTabs++;
}

if ($countTabs > 0) {
  $str_line_tabs="
  <table width='100%' border=0 cellPadding=0 cellSpacing=1>
  <tr><TD bgcolor='#468499' height='1'></TD></tr>
  <tr><TD height='8'></TD></tr>
  </table>";


  $countTabs=$countTabs*140 + $countTabs;
}
else {
  $str_line_tabs="";
  $countTabs=0;
}

###########################################################################

     $str_table.="
       <table cellSpacing=0 cellPadding=0 border=0 align=center width='100%'>
       <tr><td width=300 align=center bgcolor='#468499' height=18 valign=middle class=ProductNumber><font color='#FFffff'><b>$StoreProductNumber</b></font></td>
            <td colspan=2 bgcolor='#468499' height=18 align=right> $str_status_special</td>
       </tr>
       <tr><td colspan='3' bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td></tr>
       <tr>
       <td  valign='top' align='center' width=150>
       <br>
        <a href='/store/product_image/$ProductPicture' target='Win' onClick='openWinZoom()' title='Zoom In image'><img src='/store/product_image/$ProductPicture' width=300 border='0'></a>
       <br>
       </td>
       <td width=80% align=center valign=top>
       <!-- $StoreProductNumber - $StoreProductName -->
            <table cellSpacing=0 cellPadding=0 width=93% border=0 align center>
            <tr><td colspan=3 align=left valign=top class=ProductNumber><br><b><font color='#ff0000'>$StoreProductNumber</font> - <font color='#182520'>$StoreProductName</b></font>&nbsp;&nbsp;$str_status_new&nbsp;$str_status_top</span>
            </td></tr>
            <tr><TD colspan=3 height ='10'></TD></tr>
           <tr><TD colspan=3 >$ProductShortDescription</TD></tr>
           <tr><TD colspan=3 height ='10'></TD></tr>
           <tr><TD colspan=3 >$CategoryLink&nbsp;&nbsp;&nbsp;$ManufacturerLink</TD></tr>
           <tr><TD colspan=3 height ='25'></TD></tr>
           <TR><TD colspan=3  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif' width=1></TD><tr>
           <tr><TD colspan=3 height ='5'></TD></tr>
           <tr><td align=left valign=middle colspan=3> $str_printer_bottom     </td></tr>
           <tr><TD colspan=3 height ='5'></TD></tr>
           <TR><TD colspan=3  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif' width=1></TD><tr>
                  <tr><TD colspan=2 height ='1'></TD></tr>
            <tr><TD colspan=3 height ='4'></TD></tr>
            <tr>
            <td align=left valign=middle width=35%>
             <table cellSpacing=0 cellPadding=0 width=100% border=0  align=center >
             <tr><td align=left valign=middle class=ProductNumber>&nbsp;&nbsp;<b>Price: &nbsp;<font color='#000000'>$Price</font></b></td></tr>
             </table>
            </td>
            <td align=right valign=middle width=58%>


             <TABLE border=0 cellPadding=0 cellSpacing=0 bordercolor='#5fa0b2' >
             <tr>
             $str_shop_wish
             <td align=left valign=middle>&nbsp;&nbsp;&nbsp;$str_exit class=mr><img src='/store/icon/icon_exit_arrow.gif' height=15 width=20 border='0' title='Back to product list'></a></td>
             <td align=left valign=middle>&nbsp;$str_exit class=mr title='Back to product list'><u>EXIT</u></a>&nbsp;&nbsp;</td>
             </tr>
             </table>
             </td>
            </tr>
            <tr><TD colspan=3 height ='5'></TD></tr>
            <tr><td colspan=3>
            <TABLE border=0 cellPadding=0 cellSpacing=0 width='100%'>
            <TR><TD colspan=3  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif' width=1></TD><tr>
            <tr><TD colspan=3 height ='35' valign=middle>&nbsp;&nbsp;<b>Availability:&nbsp; <i>$TypeOfAvailable</i></b></TD></tr>
            </table>
            </td></tr>
           </table>
       </td></tr>
       </table>
       <br><br>
     <table width='100%' border=0 cellPadding=0 cellSpacing=0 align=center>
     <tr><td width='100%'>
             <table width=$countTabs border=0 cellPadding=0 cellSpacing=0 align=left>
             <tr>
                $AvOpTab
                $DescriptionTab
                $SpecificationTab
                $TechNotesTab
             </tr>
          </table>
     </td>
     </tr></table>
      $str_line_tabs

      $AvOpTab1
      $AvOpTab2
      <div id=child2 class=$DescriptionTab1><TABLE cellSpacing=0 cellPadding=0 width=100% border=0 align=center>
               <TR><TD vAlign=top align=left width=100%>$ProductDescription</td></tr></table></div>
      <div id=child3 class=$SpecificationTab1><TABLE cellSpacing=0 cellPadding=0 width=100% border=0 align=center>
               <TR><TD vAlign=top align=left width=100%>$ProductSpecification</td></tr></table></div>
      <div id=child4 class=$TechNotesTab1><TABLE cellSpacing=0 cellPadding=0 width=100% border=0 align=center>
               <TR><TD vAlign=top align=left width=100%>$ProductTechNotes</td></tr></table></div>
      <BR><BR>
";


######################################
if ( $Print==1 ) {

    $str_printer_bottom="<TABLE border=0 cellPadding=0 cellSpacing=0 width='100%'>
             <tr><td colspan=7 bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td></tr>
             <tr><td colspan=7 height=15></td></tr></table>";

     print "Content-type: text/html\n\n";
     $template_file=$path_html."html/printer.html";
     $VAR{'path_cgi'}=$path_cgi;
     $VAR{'path_cgi_https'}=$path_cgi_https;
     $VAR{'str_menu_top'}=$str_menu_top;
     $VAR{'str_sub_cat'}=$str_sub_cat;
     $VAR{'str_table'}=$str_table;

     if ( !parse_template($path_html."html/printer.html", *STDOUT)) {
        print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
     }

     return;
}

######################################

#HTML template: ??????????.html from table Product
print "Content-type: text/html\n\n";
$template_file=$path_html."html/product_details.html";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;


$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_sub_cat'}=$str_sub_cat;
$VAR{'str_table'}=$str_table;
$VAR{'str_detail'}=$str_detail;
$VAR{'str_printer_bottom'}=$str_printer_bottom;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;
$VAR{'str_help_product'}=$str_help_product;
$VAR{'str_detail'}=$str_detail;

$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template2.html", *STDOUT)) {
   print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}


}   ##product_description


############################################################################
sub option_description   # useful sub to enter data into email body template file
############################################################################

{

my $Id=$q->param('Id');

$sql="SELECT Id, ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, Status
      FROM OptionList  WHERE Id=$Id and Status=0";
dbexecute($sql);
($OptionId, $ProductId, $OptionNumber, $OptionName, $OptionDescription, $OptionPicture, $OptionPrice, $OptionStatus)=dbfetch();

$_=$OptionDescription;      (s/^\s+//); (s/\s+$//);  $OptionDescription=$_;
$_=$OptionPicture;         (s/^\s+//); (s/\s+$//);   $OptionPicture=$_;

if ($OptionPicture eq '') {
    $OptionPicture="";
}
else  {
    $OptionPicture="<img src='/store/option_image/$OptionPicture' border='0'>";
}


print "Content-type: text/html\n\n";
$template_file=$path_html."html/option.html";

$VAR{'OptionPicture'}=$OptionPicture;
$VAR{'OptionNumber'}=$OptionNumber;
$VAR{'OptionName'}=$OptionName;
$VAR{'OptionDescription'}=$OptionDescription;
$VAR{'Price'}=$Price;

if ( !parse_template($template_file, *STDOUT)) {
   print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
  }


}   ##option_description