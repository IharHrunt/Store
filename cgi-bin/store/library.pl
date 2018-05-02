#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / library.pl
#
############################################################################

require 'db.pl';

############################################################################
sub get_cookie      #17.02.2000 15:39
############################################################################

{

$access_key="false";
$str_login="class=expanded";
$str_logout="class=collapsed";

# Use cookie to identify the customer ($code)
# Recovering cookies (get names and values)
my %cookies = fetch CGI::Cookie;
foreach (keys %cookies) {
   $cookname= $cookies{$_}->name;
   if ( $cookname eq 'StoreCookGomel' ) { $value= $cookies{$_}->value; }
}
if (( !defined $value )||( $value eq '' )) {

####################

  $EstabDiscountLevel='0.00';

  $code=setcode();
  $code="C".$code;

  # Start cookie(set name and value for cookie)
  my $c = new CGI::Cookie(-name   =>  'StoreCookGomel',
                          -value   =>  $code);
  print "Set-Cookie: $c\n";


  return;
}
else { $code=$value; }


# Check and set Established Discount Level
$sql="SELECT Id, DateCreate, Perspect, EstabDiscountLevel, CustShifr FROM Profile  WHERE CustShifr ='$code' and Status=0";
dbexecute($sql);
($IdAccount, $DateCreate, $Perspect, $EstabDiscountLevel, $CustShifr)=dbfetch();


if ( !defined $CustShifr ) {
  $EstabDiscountLevel='0.00';
 }
else {

    $Id=$IdAccount;
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

    $access_key="true";
    $str_login="class=collapsed";
    $str_logout="class=expanded";
}


} ##get_cookie


############################################################################
sub parse_body   # useful sub to enter data into email body template file
############################################################################

{

    $mybody='';
    local($template_file, *OUT) = @_;
    local($line, $line_copy, $changes);
    # Open the template file and parse each line
    if (!open(TEMPLATE, $template_file)) {
        $Error_Message = "Could not open $template_file ($!).";
        return("");
    }
    while ($line = <TEMPLATE>) {
        # Initialize our variables
        $line_copy = '';
        $changes = 0;
        # Search for variables in the current line
        while ($line =~ /<<([^>]+)>>/) {
            # Build up the new line with the section of $line prior to the
            # variable and the value for $var_name (check %VAR, %CONFIG,
            # %FORM, then %ENV for match)
            ++$changes;
            if ($VAR{$1}) { $line_copy .= $` . $VAR{$1} }
            elsif ($CONFIG{$1}) { $line_copy .= $` . $CONFIG{$1} }
            elsif ($FORM{$1}) { $line_copy .= $` . $FORM{$1} }
            elsif ($ENV{$1}) { $line_copy .= $` . $ENV{$1} }
            else {
                --$changes;
                $line_copy .= $`;
            }
            # Change $line to the section of $line after the variable
            $line = $';
        }
        # Set $line according to whether or not any matches were found
        $line = $line_copy ? $line_copy . $line : $line;
        # Print line depending on presence of 0: and variables existing
        if (($line !~ s/^0://) || !$line_copy || $changes) {
           # print OUT $line;
           $mybody.=$line;
        }
    }
    close(TEMPLATE);

    return $mybody;

}  ##parse_body


############################################################################
sub converter       #19.06.2005 8:47   
############################################################################

{

  $PriceConv=$_[0]; 
  $PriceConv=sprintf("%.2f", $PriceConv); 
  $LenConv=length($PriceConv);

  if (($LenConv > 6)&&($LenConv < 10)) {
    $PriceHead=substr ($PriceConv,0,$LenConv-6);
    $PriceTail=substr ($PriceConv,$LenConv-6,6);
    $PriceConv="$PriceHead,$PriceTail";
  }

  if ($LenConv > 9) {
    $PriceHead=substr ($PriceConv,0,$LenConv-9);
    $PriceMiddle=substr ($PriceConv,$LenConv-6,3);
    $PriceTail=substr ($PriceConv,$LenConv-6,6);
    $PriceConv="$PriceHead,$PriceMiddle,$PriceTail";

  }

  return $PriceConv;

}  ##converter


############################################################################
sub special_products       #19.06.2005 8:47   show special products list
############################################################################

{

$home_page=$_[0];

my $str_special_products="<table border=0 cellspacing=0 cellpadding=0 width=100%>";
my $pathUrlProduct =$path_cgi."product.pl";

$i=0;
my $sql="SELECT Id, StoreProductNumber, StoreProductName, Category, Subcategory, ProductSmallPicture, ProductSpecialPicture, Price, PriceType
      FROM Product
      WHERE SpecialBox = 0 and ProductSpecialPicture = 'true' and Status=0
      ORDER BY Bullet";
dbexecute($sql);
$str_new_products="";
while (( $Id, $StoreProductNumber,$StoreProductName, $Category, $Subcategory, $ProductSmallPicture, $ProductSpecialPicture, $Price, $PriceType) =dbfetch()) {

  $Price=converter($Price);
  $Price="\$ ".$Price;
  if (($PriceType ==2)&&($access_key ne "true")) {
    $Price="Price: Login";       
  }
  if ($PriceType == 3) {
    $Price="Price: Contact Us";       
  }

  ########  bug - requires to check if subcategory=1 #######
  if ($Subcategory == 1) {
      $Subcategory ='';
  }
  ##########################################################

  if ( $ProductSpecialPicture eq 'true' ) {
      $str_special_products.="
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=8 border=0></td></tr>
      <tr><td colspan=3 valign=top align=center><a class=Special href='$pathUrlProduct?com=Description&SelCat=Special&Id=$Id'> <B>$StoreProductNumber - $StoreProductName</B></a></td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=5 border=0></td></tr>
      <tr><td colspan=3 align=center valign=top>
           <a href='$pathUrlProduct?com=Description&SelCat=Special&Id=$Id' title='product details'><img src=/store/product_image/$ProductSmallPicture width=150  border=0></a>
      </td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=3 border=0></td></tr>
      <tr><td colspan=3 align=center valign=top><div align=right class=SpecialPrice>$Price&nbsp;</div>
      </td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=5 border=0></td></tr>
      <tr><td colspan=3 valign=top bgcolor='#468499'><img src=/store/img/pix.gif width=1 height=1 border=0></td></tr>
";
  }
  $i++;
}

$str_special_products.="<tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=17 border=0></td></tr></table>";

if ( $i==0 ) {  $str_special_products=''; }
else {
$str_special_products.="
<div align=center><a class=Special href=$pathUrlProduct?com=Product&SelCat=Special><u>SHOW ALL SPECIAL OFFERS<u></a></div> 
<br>
";
}

return $str_special_products;

}   ##special_products



############################################################################
sub new_products       #19.06.2005 8:47   show new products list
############################################################################

{

my $pathUrlProduct =$path_cgi."product.pl";

$i=0;
my $sql="SELECT Id, StoreProductNumber, StoreProductName, Category, Subcategory, ProductSmallPicture, ProductNewPicture, Price, PriceType
      FROM Product
      WHERE NewBox = 0 and ProductNewPicture = 'true' and Status=0
      ORDER BY Bullet";
dbexecute($sql);
$str_new_products="<table border=0 cellspacing=0 cellpadding=0 width=100%>";
while (( $Id, $StoreProductNumber,$StoreProductName, $Category, $Subcategory, $ProductSmallPicture, $ProductNewPicture, $Price, $PriceType) =dbfetch()) {


  $Price=converter($Price);
  $Price="\$ ".$Price;
  if (($PriceType ==2)&&($access_key ne "true")) {
    $Price="Price: Login";       
  }
  if ($PriceType == 3) {
    $Price="Price: Contact Us";       
  }


  ########  bug - requires to check if subcategory=1 #######
  if ($Subcategory == 1) {
      $Subcategory ='';
  }
  ##########################################################

  if ( $ProductNewPicture eq 'true' ) {
      $str_new_products.="
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=8 border=0></td></tr>
      <tr><td colspan=3 valign=top align=center><a class=NewP href='$pathUrlProduct?com=Description&SelCat=New&Id=$Id'> <B>$StoreProductNumber - $StoreProductName</B></a></td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=5 border=0></td></tr>
      <tr><td colspan=3 align=center valign=top>
           <a href='$pathUrlProduct?com=Description&SelCat=New&Id=$Id' title='product details'><img src=/store/product_image/$ProductSmallPicture width=150  border=0></a>
      </td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=3 border=0></td></tr>
      <tr><td colspan=3 align=center valign=top><div align=left class=NewPrice>&nbsp;&nbsp;$Price&nbsp;</div>
      </td></tr>
      <tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=5 border=0></td></tr>
      <tr><td colspan=3 valign=top bgcolor='#468499'><img src=/store/img/pix.gif width=1 height=1 border=0></td></tr>
    ";
  }
  $i++;
}

$str_new_products.="<tr><td colspan=3 valign=top><img src=/store/img/pix.gif width=1 height=17 border=0></td></tr></table>";

if ( $i==0 ) {  $str_new_products=''; }
else {
$str_new_products.="
<div align=center><a class=NewP href=$pathUrlProduct?com=Product&SelCat=New><u>SHOW ALL NEW PRODUCTS<u></a></div> 
<br>
";
}

return $str_new_products;

}   ##new_products


############################################################################
sub top_sellers       #19.06.2005 8:47   show new products list
############################################################################

{

my $pathUrlProduct =$path_cgi."product.pl";
$str_top_sellers="<table border=0 cellspacing=0 cellpadding=0 width=100%>
      <TR><TD colspan=7  height=7></TD><tr>";

$i=0;
$count=0;
my $sql="SELECT Id, StoreProductNumber, StoreProductName, Category, Subcategory,
                ProductShortDescription, ProductSmallPicture, ProductTopPicture, Price, PriceType
      FROM Product
      WHERE TopBox = 0 and ProductTopPicture = 'true' and Status=0
      ORDER BY Bullet";
dbexecute($sql);
while (( $Id, $StoreProductNumber,$StoreProductName, $Category, $Subcategory,
$ProductShortDescription, $ProductSmallPicture, $ProductTopPicture, $Price, $PriceType) =dbfetch()) {


  $Price=converter($Price);
  $Price="\$ ".$Price;
  if (($PriceType ==2)&&($access_key ne "true")) {
    $Price="Price: Login";       
  }
  if ($PriceType == 3) {
    $Price="Price: Contact Us";       
  }

########  bug - requires to check if subcategory=1 #######
  if ($Subcategory == 1) {  $Subcategory ='';  }
##########################################################

  if ( $ProductTopPicture eq 'true' ) {

    if ( $count==0 )    {
      $count=1;
      $str_top_sellers.="
      <tr>
         <td valign=middle align=left width=5%></td>
         <td valign=top align=left width=40%>
             <table border=0 cellspacing=0 cellpadding=0 width=100%>
             <tr><td valign=top align=left><a class=TopP href=$pathUrlProduct?com=Description&SelCat=$Category&SelSubCat=$Subcategory&Id=$Id title='product details'><img src=/store/product_image/$ProductSmallPicture width=150 border=0></a></td></tr>
             <tr><td valign=middle align=left height=8></td></tr>
             <tr><td valign=top align=left>
                <a class=TopP href=$pathUrlProduct?com=Description&SelCat=Top&&Id=$Id>
                <font color=#ff0000>$StoreProductNumber</font> - $StoreProductName<br><u>$Price</u></a>
            </td></tr>
            </table>
            <br>
         </td>
         <td valign=middle align=left width=3%></td>
         <td bgcolor='#468499' width=1><IMG height=1 src='/store/img/pix.gif'></td>";
    }
    else     {
       $count=0;
       $str_top_sellers.="
        <td valign=middle align=left width=3%></td>
        <td valign=middle align=left width=3%></td>
        <td valign=top align=left width=46%>

             <table border=0 cellspacing=0 cellpadding=0 width=100%>
             <tr><td valign=top align=left><a class=TopP href=$pathUrlProduct?com=Description&SelCat=Top&Id=$Id title='product details'><img src=/store/product_image/$ProductSmallPicture width=150 border=0></a></td></tr>
             <tr><td valign=middle align=left height=8></td></tr>
             <tr><td valign=top align=left>
                <a class=TopP href=$pathUrlProduct?com=Description&SelCat=Top&Id=$Id>
                <font color=#ff0000>$StoreProductNumber</font> - $StoreProductName<br><u>$Price</u></a>
            </td></tr>
            </table>
             <br>

       </td>
       </tr>
       <tr><TD colspan=7   height=12></TD><tr>
       <tr>
       <td width=44% colspan=2  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td>
       <TD  height=1 width=3%></TD>
       <TD  height=1 width=1></TD>
       <TD  height=1 width=3%></TD>
       <td width=49% colspan=2  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td>
      </TR>
      <TR><TD colspan=7   height=12></TD><tr>";
   }
  $i++;
 }
}

############# <IMG height=15  src='/store/icon/icon_lupa_small2.gif' width=15 align=absMiddle border=0>

if ( $count == 1 ) {
       $str_top_sellers.="
        <td valign=middle align=left width=3%></td>
        <td valign=middle align=left width=3%></td>
        <td valign=middle align=left width=46%>
       </td>
       </tr>
       <tr><TD colspan=7   height=12></TD><tr>
       <tr>
       <td width=44% colspan=2  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td>
       <TD  height=1 width=3%></TD>
       <TD  height=1 width=1></TD>
       <TD  height=1 width=3%></TD>
       <td width=49% colspan=2  bgcolor='#468499' height=1><IMG height=1 src='/store/img/pix.gif'></td>
      </TR>
      <TR><TD colspan=6   height=12></TD><tr>";
}

$str_top_sellers.="</table>";


if ( $i==0 ) {  $str_top_sellers=''; }
else {
$str_top_sellers.="
<div align=right><a class=TopP href=$pathUrlProduct?com=Product&SelCat=Top><u>SHOW ALL TOP SELLERS</u></a></div>
";
}

return $str_top_sellers;

}   ##top_sellers


############################################################################
sub create_home_js
############################################################################

{

  $str_special_products = special_products();
  $str_special_products="var special_products=\"".$str_special_products."\"";
  $_=$str_special_products; s/\n//g;  $str_special_products=$_;

  $str_new_products = new_products();
  $str_new_products="var new_products=\"".$str_new_products."\"";
  $_=$str_new_products; s/\n//g;  $str_new_products=$_;

  $str_top_sellers = top_sellers();
  $str_top_sellers="var top_sellers=\"".$str_top_sellers."\"";
  $_=$str_top_sellers; s/\n//g;   $str_top_sellers=$_;


  $new=$path_menu_js."home_page.js";
  unlink ($new);
  $_=$str_special_products;
  open(NEW, ">> $new") or $i=0;
  print NEW $str_special_products;
  print NEW "\n\n";
  print NEW $str_new_products;
  print NEW "\n\n";
  print NEW $str_top_sellers;

  close(NEW);


} ##create_home_js


############################################################################
sub create_js_menu
############################################################################

{

$pathUrlProduct =$path_cgi."product.pl";
$str_table_js ="var myMenu2 = new Array();\n";
$i=0;

my $sql="SELECT distinct Category.Id, Category.Name
         FROM Category, Product
         WHERE Category.Status=0 and Product.Category=Category.Id and Product.Status=0
         ORDER BY Category.Name";
dbexecute($sql);
while (($Id, $Name) =dbfetch()) {

       $_=$Name;    (s/^\s+//); (s/\s+$//);  s/\'/\\\'/g; s/\"/\\\"/g;   $Name=$_;

       if ( $i==0 ) {
           $str_table_js ="var myMenu2 = new Array();\n";
       }
       $j = 0;

       ###### new code ########
       $sql="SELECT distinct Subcategory.Id, Subcategory.Name FROM Subcategory, Product, Category
             WHERE Subcategory.Category=$Id and Subcategory.Status=0 and Product.Category=$Id
                   and Product.Subcategory=Subcategory.Id and Product.Status=0
             ORDER BY Subcategory.Name";
       $cursor1=$dbh->prepare($sql);
       $cursor1->execute;
       $count_inner = $cursor1->rows;

       #$sql="SELECT distinct Id, Name FROM Subcategory WHERE Category =$Id and Status=0 ORDER BY Name ";
       #$cursor1=$dbh->prepare($sql);
       #$cursor1->execute;

       while (($IdSub, $NameSub) =$cursor1->fetchrow_array) {

       $_=$NameSub;    (s/^\s+//); (s/\s+$//);  s/\'/\\\'/g; s/\"/\\\"/g;   $NameSub=$_;     

             if ( $j==0 ) {
                $str_sub_cat_menu.="var menu2$i = new Array();\n"
             }
             $str_sub_cat_menu.="menu2".$i."[$j] = new Array(\"L\",\" $NameSub\",\"\",\"$pathUrlProduct?com=Product&SelCat=$Id&SelSubCat=$IdSub\");\n";
             $j++;
      }
      if ( $j == 0 ) {
         $str_table_js.="myMenu2[$i] = new Array(\"L\",\" $Name\",\"\",\"$pathUrlProduct?com=Product&SelCat=$Id\");\n";
      }
      else {
         $str_table_js.="myMenu2[$i] = new Array(\"M\",\" $Name\",\"$pathUrlProduct?com=Product&SelCat=$Id\",\"menu2$i\");\n"; #menu24
      }
      $i++;
}


$str_table_js.="myMenu2[$i] = new Array(\"S\",\"\",\"\");\n";
$i++;
$str_table_js.="myMenu2[$i] = new Array(\"L\",\" New Products\",\"\",\"$pathUrlProduct?com=Product&SelCat=New\");\n"; 
$i++;
$str_table_js.="myMenu2[$i] = new Array(\"L\",\" Special Offer\",\"\",\"$pathUrlProduct?com=Product&SelCat=Special\");\n"; 
$i++;
$str_table_js.="myMenu2[$i] = new Array(\"L\",\" Top Sellers\",\"\",\"$pathUrlProduct?com=Product&SelCat=Top\");\n"; 

$str_sc2 = "sc2=1;";
$str_table_js=$str_table_js.$str_sub_cat_menu.$str_sc2;



$old=$path_menu_js."menu_data.js";
$new=$path_menu_js."tmp.js";

open(OLD, "< $old")  or $i=0;
open(NEW, ">> $new") or $i=0;
#select(NEW);

while ( <OLD> ) {
  if (($_ =~ m/menu2/ig) || ($_ =~ m/sc2/)) {
      if (($_ =~ m/theMenu/)) {   ## save line: theMenu[1] = new Array("myMenu2","menu2");

      }
      else
      {
         next
      }
  }
  print NEW $_;
}

$_=$str_table_js;
print NEW $_;

close(OLD);
close(NEW);

rename ($new, $old) or $i=0;
unlink ($new);

if ($i < 1)  {
    $str_error_js="Debugger: <font color='ff0000'>Error. Javascript Menu has not been changed.</font>";
}
else{
    $str_error_js="Debugger: <u>Success</u>. Categories and Subcategories have been changed in JavaScript menu.</font>";
}

return ($i, $str_error_js, $str_table_js);

}   ##create_js_menu

