#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_product.pl
#
############################################################################

use CGI;
$q = new CGI;

require 'db.pl';
require 'library.pl';

# set path for the forms of the current script
$pathUrl =$path_cgi.'adm_product.pl';

if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

$code = $q->param('code');
# if $code is not defined then accessdenied
if ( $code eq '' ) { accessdenied(); return ;}
# if $code is not equal data from Password table then accessdenied
my $sql="SELECT Code, Super FROM Passw WHERE Code='$code'";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check ) { accessdenied(); return ; }


# Select form from 'Products/Search Product' mode
$com = $q->param('com');
if    ( $com eq 'Listcategory' )  {list_category(); }
elsif ( $com eq 'CategoryProduct'){ product(); }
elsif ( $com eq 'Product'     )   { product(); }
elsif ( $com eq ' Cancel '    )   { product(); }
elsif ( $com eq 'Page'        )   { product();  }
elsif ( $com eq 'Add Product' )   { edit_product(); }
elsif ( $com eq 'Edit_Product')   { edit_product(); }
elsif ( $com eq '  Insert  ')     { dbedit_product(); }
elsif ( $com eq '  Update  ')     { dbedit_product(); }
elsif ( $com eq '  Delete  ')     { dbedit_product(); }
elsif ( $com eq ' Upload Files '){ dbedit_product(); }
elsif ( $com eq ' Remove Files '){ dbedit_product(); }

elsif ( $com eq 'Option'    )   { option();  }
elsif ( $com eq 'Add Option' )  { edit_option(); }
elsif ( $com eq 'Edit_Option') { edit_option(); }
elsif ( $com eq ' Insert ')     { dbedit_option(); }
elsif ( $com eq ' Update ')     { dbedit_option(); }
elsif ( $com eq ' Delete ')     { dbedit_option(); }
elsif ( $com eq 'Cancel'  )     { option(); }
elsif ( $com eq ' Upload File ') { dbedit_option(); }
elsif ( $com eq ' Remove File ') { dbedit_option(); }

elsif ( $com eq 'Special' ) { edit_new_top();  }
elsif ( $com eq 'New'     ) { edit_new_top();  }
elsif ( $com eq 'Top'     ) { edit_new_top();  }
elsif ( $com eq '  Save  ') { dbedit_new_top(); }
elsif ( $com eq '  Exit  ') { exit_product(); }

elsif ( $com eq 'Save changes') { bullet_product(); }


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store Admin</TITLE>
<HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><STRONG>Access Denied.</STRONG></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied


############################################################################
sub list_category     #17.02.2000 15:39 Create form with list of Categories
############################################################################
{

# Get rows' quantity on the page
$rowNumber=$q->param('rowNumber');
if (!defined $rowNumber)  { $rowNumber=30; }


# Select 'alive' Categories
my $sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);
# Create header Category table
my $str_table.="<table border='0' width='100%' cellspacing='1' cellpadding='1'>
                <TR><TH width='35%' ></TH></TH><TH width='65%' ></TH></TR>";

# fetch all records from recordset to format Category table
while (( $Id, $Name ) =dbfetch()) {
  #  Set up link to products of the selected category
  $str_table.="<TR><TD align='right'><TD align='left'>
      <a href='$pathUrl?com=CategoryProduct&SelectCategory=$Id&rowNumber=$rowNumber&code=$code&page=1'>
      <FONT size='3'>$Name</FONT></a></TD></TR>";
   }
$str_table.="
<TR><TD align='right'><TD align='left'><FONT size='3'><b>
<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1'>
All categories</b></FONT></a><br><br></TD></TR>

<TR><TD align='right'><TD align='left'>
<FONT size='3'>
<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectNew=yes'>New Products</a><BR>
</FONT></TD></TR>
<TR><TD align='right'><TD align='left'>
<FONT size='3'>
<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectSpecial=yes'>Special Offers</a><BR>
</FONT></TD></TR>
<TR><TD align='right'><TD align='left'>
<FONT size='3'>
<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectTop=yes'>Top Sellers</a>
</FONT></TD></TR>

</TABLE>

";


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store Admin</TITLE>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<HEAD>
<BODY BGCOLOR='#CCCCCC'>
<CENTER>
<P><H3>Products / Categories</H3>
$str_table
</CENTER>
</BODY></HTML>
Browser

}   ##list_category


############################################################################
sub product       #19.02.2000 8:47
############################################################################

{

# Get rows' quantity on the page
$rowNumber=$q->param('rowNumber');
$page=$q->param('page');
$SelectCategory=$q->param('SelectCategory');
my $str_CategoryFont='';

if ( $SelectCategory eq 'All') {
    $str_SelectCategory='';
     $str_CategoryFont="color='red'";
}
else {
    $str_SelectCategory=" and Category.Id=$SelectCategory ";
    $str_CategoryFont="";
}

$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');

$str_table2='';
$str_CategoryFontAdd="color=''";
if ( $SelectNew eq 'yes') {
    $str_SelectCategory=' and Product.NewBox = 0 ';
    $str_CategoryFont="";
    $str_CategoryFontAdd="color='red'";
}
$str_table2.="<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectNew=yes'><FONT ".$str_CategoryFontAdd." size='2'>New Products</FONT></a>&nbsp; ";
$str_CategoryFontAdd="color=''";
if ( $SelectSpecial eq 'yes') {
    $str_SelectCategory=' and Product.SpecialBox = 0 ';
    $str_CategoryFont="";
    $str_CategoryFontAdd="color='red'";
}
$str_table2.="<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectSpecial=yes'><FONT ".$str_CategoryFontAdd." size='2'>Special Offers</FONT></a>&nbsp; ";
$str_CategoryFontAdd="color=''";
if ( $SelectTop eq 'yes') {
    $str_SelectCategory=' and Product.TopBox = 0 ';
    $str_CategoryFont="";
    $str_CategoryFontAdd="color='red'";
}
$str_table2.="<a href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1&SelectTop=yes'><FONT ".$str_CategoryFontAdd." size='2'>Top Sellers</FONT></a>&nbsp; ";


# Select 'alive' Categories
my $sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);
# Create header Category table
my $str_table1.="<table border='0' width='100%' cellspacing='1' cellpadding='1'><TR><TD align='left'>
<a
href='$pathUrl?com=CategoryProduct&SelectCategory=All&rowNumber=$rowNumber&code=$code&page=1'><FONT ".$str_CategoryFont." size='2'><b>All categories</b></FONT></a>&nbsp; ";

# fetch all records from recordset to format Category table
while (( $Id, $Name ) =dbfetch()) {
  #  Set up link to products of the selected category
  if ( $Id == $SelectCategory ) { $str_CategoryFont="color='red'"; }
  else {  $str_CategoryFont="";  }

  $str_table1.="<a href='$pathUrl?com=CategoryProduct&SelectCategory=$Id&rowNumber=$rowNumber&code=$code&page=1'><FONT ".$str_CategoryFont." size='2'>$Name</FONT></a>&nbsp;&nbsp;&nbsp;";
   }
$str_table1.="$str_table2</TD></TR></TABLE>";

if (!defined $rowNumber) { $rowNumber=30; }
# Get 'successful' message
my $str_message=$_[2];
# Get number of the current page
# Count last and first rows for the current page
my $rowLast=$page*$rowNumber;
my $rowFirst=($page-1)*$rowNumber;
my $n=$rowFirst;
my $limit=100;
my $str_navig='';
my $navig = 0;
my $pathUrlPage="$pathUrl?com=Page&SelectCategory=$SelectCategory&code=$code&rowNumber=$rowNumber&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";


$sql="SELECT Product.Id,Product.Bullet,Product.StoreProductNumber,Category.Id, Category.Name,Product.Subcategory,
                Product.StoreProductName,Product.ManufacturerProductNumber,
                Manufacturer.Name,Product.ManufacturerProductName,
                Product.Quantity, Product.Status,
                Product.ProductSpecialPicture, Product.ProductTopPicture, Product.ProductNewPicture,
                Product.SpecialBox, Product.TopBox, Product.NewBox,
                ProductSpecialPicture, ProductNewPicture, ProductTopPicture
         FROM   Manufacturer, Product LEFT JOIN Category ON Product.Category = Category.Id
         WHERE  Product.ManufacturerName=Manufacturer.Id  $str_SelectCategory
                AND Product.Status<>1
         ORDER BY Category.Name, Product.Subcategory, Product.Bullet";
dbexecute($sql);

# Create header for table
my $str_table="<table border='1' width='100%' cellspacing='1' cellpadding='0'>
               <TR><TH width='6%'><TH width='15%'></TH>
               <TH width='20%'></TH><TH width='34%'><TH width='8%'></TH>
               <TH width='10%'></TH><TH width='6%'></TH>";

my $i=0;
my $CategoryTmp='';
my $BulletArray='';

# Fetch all records from recordset to format products' table
while (( $Id, $Bullet, $StoreProductNumber, $SelCat, $Category,$Subcategory,$StoreProductName,
         $ManufacturerProductNumber,$ManufacturerName,$ManufacturerProductName, $Quantity, $Status,
         $ProductSpecialPicture, $ProductTopPicture, $ProductNewPicture, $SpecialBox, $TopBox, $NewBox,
         $ProductSpecialPicture, $ProductNewPicture,  $ProductTopPicture) =dbfetch()) {

if (($rowFirst<=$i)&&($i<$rowLast))  { # Select only rows for this page

  $n++;

  $count_option=0;
  $sql="SELECT * FROM OptionList WHERE ProductId=$Id and Status = 0";
  $cursor2=$dbh->prepare($sql);
  $cursor2->execute;
  $count_option = $cursor2->rows;


  # Set link to update or delete the product
  my $pathEdit_Product=$pathUrl."?com=Edit_Product&Id=$Id&SelectCategory=$SelectCategory&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
  $pathEdit_Product.="&page=$page&rowNumber=$rowNumber&code=$code";

  my $pathEdit_Option=$pathUrl."?com=Option&Id=$Id&SelectCategory=$SelectCategory&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
  $pathEdit_Option.="&page=$page&rowNumber=$rowNumber&code=$code&Status=$Status";


  if ( $Status==2 )  {$color="bgcolor='#AAAAAA'"; $specials="<Font color='black'><i>Hidden</i></font>"; }
  else { $color="bgcolor='#DDDDDD'";

    my $pathEdit_New=$pathUrl."?com=New&Id=$Id&SelectCategory=$SelectCategory&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
    $pathEdit_New.="&page=$page&rowNumber=$rowNumber&code=$code&Status=$Status";
    my $pathEdit_Special=$pathUrl."?com=Special&Id=$Id&SelectCategory=$SelectCategory&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
    $pathEdit_Special.="&page=$page&rowNumber=$rowNumber&code=$code&Status=$Status";

    my $pathEdit_Top=$pathUrl."?com=Top&Id=$Id&SelectCategory=$SelectCategory&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
    $pathEdit_Top.="&page=$page&rowNumber=$rowNumber&code=$code&Status=$Status";

    if ($ProductSpecialPicture eq 'true') {  $LinkSpecial='(+)';  }
    else { $LinkSpecial="";  }
    if ($ProductTopPicture eq 'true') {  $LinkTop='(+)';  }
    else { $LinkTop="";  }
    if ($ProductNewPicture eq 'true') {  $LinkNew='(+)';  }
    else { $LinkNew="";  }

    $specials='';
    if  ( $NewBox == 0    )  { $specials.="<Font color='blue'><i><a href='$pathEdit_New'>New $LinkNew</i></a></font><br>"; }
    if ( $SpecialBox == 0 )  { $specials.="<Font color='blue'><i><a href='$pathEdit_Special'>Special $LinkSpecial</i></a></font><br>";  }
    if ( $TopBox == 0     )  { $specials.="<Font color='blue'><i><a href='$pathEdit_Top'>Top $LinkTop</i></a></font>";  }
    if ( $specials eq '') {   $specials='&nbsp;'  }
  }


  # setcategory header for the group of products
  if ( $CategoryTmp ne $Category ) {
    $str_table.="<TR><TD colspan=7 align='Left'><B>Category :<Font color='red'> $Category </Font></TD></TR>";
    $CategoryTmp=$Category;

    $str_table.="
      <TR><TD align='center' ><B><Font size=2>Bullet*</Font></B></TD>
      <TD align='center'><B><Font size=2>Subcategory</Font></B></TD>
      <TD align='center'><B><Font size=2>Prod. Number</Font></B></TD>
      <TD align='center'><B><Font size=2>Product Name</Font></B></TD>
      <TD align='center'><B><Font size=2>Options</Font></B></TD>
      <TD align='center'><B><Font size=2>Status</Font></B></TD>
      <TD align='center'><B><Font size=2>Q-ty</Font></B></TD>
      </TR>";
  }

     $SubcategoryTmp='';
     # Select list of Subcategories for the current Category
     my $sql="SELECT Id, Name FROM Subcategory  WHERE Status=0 ORDER BY Name ";
      # Create new cursor to keep recordset of Subcategories
     $cursor1=$dbh->prepare($sql);
     $cursor1->execute;
     $str_subcategory='';
     # fetch all records from recordset to format subcategory cell
     while (($key,$value) =$cursor1->fetchrow_array) {
        if ( $Subcategory == $key ) {
           $SubcategoryTmp = $value; 
        }
     }
     if ( $Subcategory == 0 ) { $SubcategoryTmp = "&nbsp;"; }

  $BulletArray.="Bullet".$Id.",";
  $str_checkData.="
    if (!((document.form1.Bullet$Id.value > 0 )&&(document.form1.Bullet$Id.value < 100000 ))) {
       alert(\"Value in the field \'Bullet\' ($StoreProductNumber) is incorrect or equal 0.\");document.form1.Bullet$Id.focus(); document.form1.Bullet$Id.select(); return false
    }
    if ((document.form1.Quantity$Id.value == '' ) || 
        (document.form1.Quantity$Id.value == ' ' ) ||
        (document.form1.Quantity$Id.value == '  ' ) ||
        (document.form1.Quantity$Id.value == '   ' ) ||
        (document.form1.Quantity$Id.value == '    ' ) ||
        (document.form1.Quantity$Id.value == '     ' ) ||
        (!((document.form1.Quantity$Id.value >= 0 )&&(document.form1.Quantity$Id.value < 100000 )))) {
       alert(\"Value in the field \'Quantity\' ($StoreProductNumber) is incorrect.\");document.form1.Quantity$Id.focus(); document.form1.Quantity$Id.select(); return false
    }
  ";


  $str_table.="
  <TR $color><TD align='center'><input type=text name=\"Bullet$Id\" value=\"$Bullet\" maxlength=5 size=3 align=right></TD>
  <TD align='center'><Font size=2>$SubcategoryTmp</Font></TD>
  <TD align='center'><a href='$pathEdit_Product'><FONT size=2>$StoreProductNumber</FONT></a></TD>
  <TD align='left'><Font size=2>&nbsp;$StoreProductName</Font></TD>
  <TD align='center'><Font size=2><a href='$pathEdit_Option'>Options</a> / $count_option</Font></TD>
  <TD align='center'><Font size=2>$specials</Font></TD>
  <TD align='center'><input type=text name=\"Quantity$Id\" value=\"$Quantity\" maxlength=5 size=3 align=right></TD>
  </TR>";
 }
 $i++;
 if ((sprintf("%d",($i%$rowNumber)) == 0 )&&( $limit-1 >= $navig )) {
    $navig++;
    if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT>  "; }
    else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a>  ";}
 }

}


$str_table.="</Table>";

if (( $i > $navig*$rowNumber )&&( $limit-1 >= $navig )) {
  $navig++;
  if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT>  "; }
  else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a>  ";}
}
$str_navig="&nbsp;<font size='2'><u>Pages</u>: ".$str_navig."</font>";

# Count and check last page
$pageLast=sprintf("%d",($i%$rowNumber));
if ($pageLast==0) {$pageLast=($i/$rowNumber);}
else  {  $pageLast=sprintf("%d",($i/$rowNumber));  $pageLast++;  }
if ( $pageLast == 1) { $str_navig=''; }

$str_order="* <font size=2>Products are ordered by Category, Subcategory, Bullet</font><BR>";
$str_bullet="<input type=submit name=com value='Save changes' onClick='return checkData()'> <input type=reset name=comSender value=\" Reset \">";

if ($i == 0) {
  # Set warning message if the table is empty
  $str_table="The selected category is empty. To add a new product please click on the button below.";
  $str_navig='';
  $str_order='';
  $str_bullet='';
 }


#HTML
print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<SCRIPT>

function checkData () {

   $str_checkData
   else {
      if (confirm('Save changes ?')) { return true; }
      else  { return false; }
   }
}
</SCRIPT>

</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<FORM METHOD='POST' Name=\"form1\" ACTION=$pathUrl>
<CENTER>
<H3>Products / Categories / Products List</H3>
$str_table1<br>
<table border='0' width='100%' cellspacing='1' cellpadding='0'>
<TR><TD align='left'><font color='black'>$str_message</font>
</TD></TR>
</TABLE>
$str_table
</CENTER>
<table border='0' width='100%' cellspacing='1' cellpadding='0'>
<TR><TD align='left'>$str_navig</TD><TD align='right'>$str_order</TD></TR>
</TABLE>
<CENTER>
<BR>
<input type=hidden name=SelectCategory value='$SelectCategory'>
<input type=hidden name=page value='$page'>
<input type=hidden name=rowNumber value='$rowNumber'>
<input type=hidden name=code value='$code'>
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">
<input type=hidden name=BulletArray value=\"$BulletArray\">

<input type=submit name=com value='Add Product' >
$str_bullet
</CENTER>

</FORM></BODY></HTML>
Browser
}   ##product



############################################################################
sub bullet_product        #18.02.2000  20:53
############################################################################

{

$BulletArray=$q->param('BulletArray');
@BulletArray=split(/,/, $BulletArray);


$x=0;
$y=0;

$str_finish='';
foreach (@BulletArray) {

   $x++;
   $len=length($_);
   $len=$len-6;
   $aa=substr($_,6,$len); 

   $bb=$q->param($_);                    
   $dd="Quantity".$aa;
   $cc=$q->param($dd);      
   if ($aa == '') { $aa=0; }              
   if ($cc == '') { $cc=0; }

#   $str_finish.="+".$aa."=".$bb."=".$cc;

   $sql="UPDATE Product SET Bullet=$bb, Quantity=$cc  WHERE Id=$aa";
   if (dbdo($sql)) {  $y++;  }
}

create_home_js();

if ($x==$y) {
   change_page($com,1,"All records have been updated successfully");
}
else {
   change_page($com,1,"<B><font color=ff0000>Error!!! Only $y of $x record(s) have been updated successfully</font><b>");
}

}   ##bullet_product


############################################################################
sub edit_product      #18.02.2000  18:16
############################################################################
{


# Get Id of the selected Product
$Id=$q->param('Id');

# Get params which have been set on 'Query' page
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
my $Category_default =$SelectCategory;
# Get number of the current page on 'List of Products' form
$page=$q->param('page');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');


$sql="SELECT MAX(Bullet) FROM Product WHERE Status <> 1";
dbexecute($sql);
($Bullet_MAX) =dbfetch();


# Get error message for JScript alert
my $str_message=$_[0];
# Set buttons and title for the form
my $str_button='';
my $str='';


if (( $com eq 'Add Product')||( $com eq '  Insert  ')||( $comTest eq 'Insert')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=com value='  Insert  ' onClick='return checkData()'>
               <input type=hidden name=comTest value='Insert'>";
  $str_Category='';
  $str_Category_Out='';
  # Set up Category pull-box disabled if you came with selected category
  if ( $Category_default ne "All") {
     #  $str_Category="Disabled";
       $str_Category="";
      # $str_Category_Out="<input type=hidden name=Category value='$Category_default'>";
       $str_Category_Out="";
  }
 }
else  {
  # Update or delete the record
  $str="Modify";
  $str_button="<input type=submit name=com value='  Update  ' onClick='return checkData()'> ";
  $str_button.="<input type=submit name=com value='  Delete  ' onClick='return checkRemoveProduct()'> ";

  ############
  # $str_button.="<input type=submit name=com value='  Insert  ' onClick='return checkData()'>
  #             <input type=hidden name=comTest value='Insert'>";
  ############

  if ( $_[2] ne 'new' )  {
  # Get data of the product (only update or delete mode)
    if ( $Id ne '' ) {
      $sql="SELECT Bullet, StoreProductNumber,Category,Subcategory,StoreProductName,
                ManufacturerProductNumber,ManufacturerName,ManufacturerProductName,
                ProductShortDescription,ProductSmallPicture,ProductPicture,ProductDetailedDescription,
                Price,Price2,Price3,PriceType,Quantity,Status,
                ProductSpecialPicture, ProductTopPicture, ProductNewPicture,
                SpecialBox, TopBox, NewBox,
                ProductDescription, ProductSpecification, ProductTechNotes,
                TypeOfAvailable

         FROM Product
         WHERE Id=$Id and Status <> 1";
      dbexecute($sql);
      ($Bullet, $StoreProductNumber,$Category,$Subcategory,$StoreProductName,$ManufacturerProductNumber,
      $ManufacturerName,$ManufacturerProductName, $ProductShortDescription,$ProductSmallPicture,
      $ProductPicture,$ProductDetailedDescription,$Price,$Price2,$Price3,$PriceType,
      $Quantity, $Status,
      $ProductSpecialPicture, $ProductTopPicture, $ProductNewPicture, $SpecialBox, $TopBox, $NewBox,
      $ProductDescription, $ProductSpecification, $ProductTechNotes,$TypeOfAvailable) =dbfetch();
    }
  }
}

$str_button.="<input type=submit name=com value=' Cancel '>";


my $FileTmp1 = 'None .....';
my $FileTmp2 = 'None .....';
my $FileTmp3 = 'None .....';


my $str_check1='&nbsp';
my $str_check2='&nbsp';
my $str_check3='&nbsp';

my $Img1='&nbsp';
my $Img2='&nbsp';
my $Img3='&nbsp';


$str_check_javascript = "
function checkRemove () {
    alert('Nothing to remove.');
    return false;
}";

$SizeTmp1=0;  $SizeTmp2=0;  $SizeTmp3=0;

if (( $ProductSmallPicture ne '' )||( $ProductPicture ne '' )||( $ProductDetailedDescription ne '' )) {

  if ( $ProductSmallPicture ne '' ) {

    $file1=$path_product_image.$ProductSmallPicture;
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
     $mtime,$ctime,$blksize,$blocks) = stat($file1);
     $SizeTmp1 = (int($size/100))/10 ;

    $str_check_javascript_tmp.= "(!document.form1.Checkfile1.checked)&&";
    $str_check1 = "<INPUT type='checkbox' name='Checkfile1' value='1' >";
    $FileTmp1 = "<font color='blue' size=2>$ProductSmallPicture </font> <font color='black' size=2> ( $SizeTmp1 K )</font>";
    $pathImg1=$path."product_image/".$ProductSmallPicture;
    $Img1 = "<a href='$pathImg1' target='new4'>View</a>";
  }
  if ( $ProductPicture ne '' ) {

    $SizeTmp2='';
    $file2=$path_product_image.$ProductPicture;
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
     $mtime,$ctime,$blksize,$blocks) = stat($file2);
    $SizeTmp2 = (int($size/100))/10 ;

    $str_check2 = "<INPUT type='checkbox' name='Checkfile2' value='1' >";
    $str_check_javascript_tmp.= "(!document.form1.Checkfile2.checked)&&";
    $FileTmp2 = "<font color='blue' size=2>$ProductPicture </font> <font color='black' size=2> ( $SizeTmp2 K )</font>";
    $pathImg2=$path."product_image/".$ProductPicture;
    $Img2 = "<a href='$pathImg2' target='new4'>View</a>";

  }
  if ( $ProductDetailedDescription ne '' ) {


    $file4=$path_product_pdf.$ProductDetailedDescription;
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
    $mtime,$ctime,$blksize,$blocks) = stat($file4);
    $SizeTmp3 = (int($size/100))/10 ;


    $str_check3 = "<INPUT type='checkbox' name='Checkfile3' value='1' >";
    $str_check_javascript_tmp.= "(!document.form1.Checkfile3.checked)&&";
    $FileTmp3 = "<font color='blue' size=2>$ProductDetailedDescription </font> <font color='black' size=2> ( $SizeTmp3 K )</font>";
    $pathImg3=$path."product_pdf/".$ProductDetailedDescription;
    $Img3 = "<a href='$pathImg3' target='new3'>View</a>";
  }

  $len = length($str_check_javascript_tmp)-2;
  $str_check_javascript_tmp=substr($str_check_javascript_tmp,0, len-2);
  $str_check_javascript = "
  function checkRemove () {
    if ($str_check_javascript_tmp ) {
       alert('Check box(es) to remove the selected file(s) from web-server.');
       return false;
     }
    else { return true; }
  } ";

}


# Create html table for the form
# Create Category pull-box
my $CategoryTMP='';
my $str_select1="<SELECT NAME='Category' ".$str_Category." onChange='setbox()' >";
$str_select1.="<OPTION  VALUE=999>-- Select Category --";
$sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);
# Fetch all records from recordset and set the selected category
while (( $IdTmp,$Name ) =dbfetch()) {
  if (( $IdTmp==$Category )||( $IdTmp==$Category_default )) {
     $str_select1.="<OPTION SELECTED VALUE=$IdTmp>$Name"; $CategoryTMP=$Name;
   }
  else { $str_select1.="<OPTION VALUE=$IdTmp>$Name"; }
}
$str_select1.="</SELECT>";


if (  $Category_default eq 'All' ) {  $Category_default = $Category; }



# Create Subcategory pull-box
$str_select11="<SELECT NAME=Subcategory >";
$str_select11.="<OPTION  VALUE=999>-- Select Subcategory --";
$sql="SELECT Id, Name FROM Subcategory
      WHERE Status=0 and Category=$Category_default ORDER BY Name";
dbexecute($sql);
while (( $IdTmp,$Name ) =dbfetch()) {
  if ( $IdTmp==$Subcategory ){
      $str_select111.="<OPTION SELECTED VALUE=$IdTmp>$Name";
  }
  else { $str_select111.="<OPTION VALUE=$IdTmp>$Name"; }
}


if ( $str_select111 ne '' ) { $str_select11.=$str_select111."</SELECT>"; }
else {
   if ( $CategoryTMP ne '') { $str_select11="<SELECT NAME=Subcategory ><OPTION SELECTED VALUE=0>$CategoryTMP</SELECT>";}
   else { $str_select11="<SELECT NAME=Subcategory ><OPTION SELECTED VALUE=999>-- Select Subcategory --</SELECT>"; }
}



# Create Manufacturer pull-box
my $str_select2="<SELECT NAME=ManufacturerName >";
$str_select2.="<OPTION VALUE=999>-- Select Manufacturer --";
$sql="SELECT Id, Name FROM Manufacturer WHERE Status=0 ORDER BY Name";
dbexecute($sql);
while (( $IdTmp,$Name ) =dbfetch()) {

  if ( $IdTmp==$ManufacturerName )  { $str_select2.="<OPTION SELECTED VALUE=$IdTmp>$Name"; }
  else { $str_select2.="<OPTION VALUE=$IdTmp>$Name"; }
}
$str_select2.="</SELECT>";


# Create Availability pull-box
my $str_select5="<SELECT NAME=TypeOfAvailable >";
$str_select5.="<OPTION VALUE=999>-- Select Item --";
$sql="SELECT Id, Name FROM TypeOfAvailable WHERE Status=0 ORDER BY Id";
dbexecute($sql);
while (( $IdTmp,$Name ) =dbfetch()) {

  if ( $IdTmp==$TypeOfAvailable )  { $str_select5.="<OPTION SELECTED VALUE=$IdTmp>$Name"; }
  else { $str_select5.="<OPTION VALUE=$IdTmp>$Name"; }
}
$str_select5.="</SELECT>";




# Create Product's Status
my $str_select3="<SELECT NAME=Status>";
  if ( $Status==2 ) {$str_select3.="<OPTION VALUE=0> Active <OPTION SELECTED VALUE=2> Hidden "; }
  else {$str_select3.="<OPTION SELECTED VALUE=0> Active <OPTION VALUE=2> Hidden "; }
$str_select3.="</SELECT>";


if ( $PriceType == 2) {
  $str_select4.="<INPUT type='radio' name=PriceType value=1>Dollars&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=2 CHECKED>Login&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=3>Contact Us";
} 
elsif ( $PriceType == 3) {
  $str_select4.="<INPUT type='radio' name=PriceType value=1>Dollars&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=2>Login&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=3 CHECKED>Contact Us";
} 
else {
  $str_select4.="<INPUT type='radio' name=PriceType value=1 CHECKED>Dollars&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=2>Login&nbsp;&nbsp;<INPUT type='radio' name=PriceType value=3>Contact Us";
} 

if (( $NewBox==0 )&&( defined $NewBox)) {$str_NewBox=" <INPUT type=checkbox value=0 checked name=NewBox> New Products"; }
else { $str_NewBox=" <INPUT type=checkbox value=0 name=NewBox> New Products";}

if (( $SpecialBox==0 )&&( defined $SpecialBox))  {$str_SpecialBox=" <INPUT type=checkbox value=0 checked name=SpecialBox> Special Offers"; }
else { $str_SpecialBox=" <INPUT type=checkbox value=0 name=SpecialBox> Special Offers";}

if (( $TopBox==0 )&&( defined $TopBox)) {$str_TopBox=" <INPUT type=checkbox value=0 checked name=TopBox> Top Sellers"; }
else { $str_TopBox=" <INPUT type=checkbox value=0 name=TopBox> Top Sellers";}

#$SpecialBox, $TopBox, $NewBox
$str_array="";
if ( $str_message ne '' ) {  $str_scriptvar="alert('$str_message');" ; }

$sql="SELECT Subcategory.Id, Subcategory.Name, Subcategory.Category FROM Subcategory, Category
      WHERE Subcategory.Status=0 and Subcategory.Category=Category.Id ORDER BY Name";
dbexecute($sql);
$j=0;
while (( $IdTmp,$NameTmp,$source) =dbfetch()) {

   $_=$NameTmp;    (s/^\s+//); (s/\s+$//);  s/\'/\\\'/g; s/\"/\\\"/g;   $NameTmp=$_;     
   $_=$source;    (s/^\s+//); (s/\s+$//);  s/\'/\\\'/g; s/\"/\\\"/g;   $source=$_;     

  $str_array.="myarray[$j] = new Array(3);  myarray[$j][0] = $IdTmp;  myarray[$j][1] = '".$NameTmp."';   myarray[$j][2] = $source; \n";
 $j++;
}
$str_array.="var count=".$j.";";

# Get $scriptvar to set focus and Jscript alert for the form
# Get 'successful' or error message for Jscript alert
my $str_message=$_[0];
my $scriptvar=$_[1];
if (  $scriptvar==1 ) { $str_scriptvar=$str_message; }
else { $str_scriptvar="document.form1.Bullet.focus();  document.form1.Bullet.select();"; }


#############################################
$_=$StoreProductNumber;          s/\\//g; s/\"/&quot;/g; $StoreProductNumber=$_;
$_=$StoreProductName;            s/\\//g; s/\"/&quot;/g; $StoreProductName=$_;
$_=$ManufacturerProductNumber;   s/\\//g; s/\"/&quot;/g; $ManufacturerProductNumber=$_;
$_=$ManufacturerProductName;     s/\\//g; s/\"/&quot;/g; $ManufacturerProductName=$_;

$_=$ProductShortDescription;     s/\\//g; s/\"/&quot;/g; $ProductShortDescription=$_;
$_=$ProductDescription;          s/\\//g; s/\"/&quot;/g; $ProductDescription=$_;
$_=$ProductSpecification;        s/\\//g; s/\"/&quot;/g; $ProductSpecification=$_;
$_=$ProductTechNotes;            s/\\//g; s/\"/&quot;/g; $ProductTechNotes=$_;


if ($ProductShortDescription ne '') { $ProductShortDescription.=" "; }
if ($ProductDescription ne '') { $ProductDescription.=" "; }
if ($ProductSpecification ne '') { $ProductSpecification.=" "; }
if ($ProductTechNotes ne '') { $ProductTechNotes.=" "; }

$_=$Price;                       s/\\//g; s/\"/&quot;/g; $Price=$_;
$_=$Price2;                      s/\\//g; s/\"/&quot;/g; $Price2=$_;
$_=$Price3;                      s/\\//g; s/\"/&quot;/g; $Price3=$_;

#############################################

print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<SCRIPT>
myarray = new Array(1);
$str_array
// identify user browser
function setbox () {

 var isNav4, isIE4;
// if (parseInt(navigator.appVersion.charAt(0)) >= 4) {
//   isNav4 = (navigator.appName == "Netscape") ? true : false;
//   isIE4 = (navigator.appName.indexOf("Microsoft") != -1) ? true : false;
// }

 for (n = document.form1.Subcategory.options.length; n >-1;  n--) { document.form1.Subcategory.options[n]=null; }


 var i=0;
 var x = document.form1.Category.selectedIndex;

// window.status="lenth" + myarray.length;

// for (n = 0; n < myarray.length; n++) {
 for (n = 0; n < count; n++) {
     if ( document.form1.Category.options[x].value == myarray[n][2] ) {
        i++;
     }
 }

//return;

 if ( i==0 ) {
   var str = document.form1.Category.options[x].text;
   document.form1.Subcategory.options[0]=new Option(str, "1");
 }
 else {
   if ( x != 0 ) {
      i=0;
      var option0 = new Option("-- Select Subcategory --", "999" )
      eval('document.form1.Subcategory.options[0]=option' + 0)

//      for (n = 0; n < myarray.length; n++) {
      for (n = 0; n < count; n++) {
         if ( document.form1.Category.options[x].value == myarray[n][2] ) {
            i++;
          document.form1.Subcategory.options[i] = new Option(myarray[n][1] , myarray[n][0] );
        }
      }
   }
 }
 document.form1.Subcategory.options[0].selected=true;
//   if(isNav4) { history.go(0); }

}


// Validate fields before submit
function checkData () {

   if (!((document.form1.Bullet.value > 0 )&&(document.form1.Bullet.value < 100000 ))) {
     alert("Value in the field \'Bullet\' is incorrect or equal 0.");document.form1.Bullet.focus(); document.form1.Bullet.select();return false
   }
   if (document.form1.StoreProductNumber.value == '') {
     alert("The field \'Product Number\' cannot be empty.");document.form1.StoreProductNumber.focus();document.form1.StoreProductNumber.select(); return false
   }
   if (document.form1.StoreProductName.value == '') {
     alert("The field \'Product Name\' cannot be empty.");document.form1.StoreProductName.focus();document.form1.StoreProductName.select(); return false
   }
   if (document.form1.Category.selectedIndex == 0) {
     alert("The field \'Category\' cannot be empty."); document.form1.Category.focus(); return false
   }

   if  (!((!document.form1.Subcategory.options[0].selected)||
       (document.form1.Subcategory.options[0].value != 999 ))) {
     alert("The field \'Subcategory\' cannot be empty.");document.form1.Subcategory.focus(); return false
   }

   if (document.form1.ManufacturerProductNumber.value == '') {
     alert("The field \'Manufacturer Product Number\' cannot be empty.");document.form1.ManufacturerProductNumber.focus();document.form1.ManufacturerProductNumber.select(); return false
   }
   if (document.form1.ManufacturerName.selectedIndex == 0) {
     alert("The field \'Manufacturer Name\' cannot be empty.");document.form1.ManufacturerName.focus(); return false
   }
   if (document.form1.ManufacturerProductName.value == '') {
     alert("The field \'Manufacturer Product Name\' cannot be empty.");document.form1.ManufacturerProductName.focus();document.form1.ManufacturerProductName.select(); return false
   }
   if (document.form1.TypeOfAvailable.selectedIndex == 0) {
     alert("The field \'Availability\' cannot be empty.");document.form1.TypeOfAvailable.focus(); return false
   }

    if ((document.form1.Quantity.value == '' ) || 
        (document.form1.Quantity.value == ' ' ) ||
        (document.form1.Quantity.value == '  ' ) ||
        (document.form1.Quantity.value == '   ' ) ||
        (document.form1.Quantity.value == '    ' ) ||
        (document.form1.Quantity.value == '     ' ) ||       
        (!((document.form1.Quantity.value >= 0 )&&(document.form1.Quantity.value < 100000000 )))) {
     alert("Value in the field \'Quantity\' is incorrect.");document.form1.Quantity.focus(); document.form1.Quantity.select();return false
   }


   if (!((document.form1.Price.value > 0 )&&(document.form1.Price.value < 100000000 ))) {
     alert("Value in the field \'Price (1)\' is incorrect or equal 0.");document.form1.Price.focus(); document.form1.Price.select();return false
   }
   if (!((document.form1.Price2.value > 0 )&&(document.form1.Price2.value < 100000000 ))) {
     alert("Value in the field \'Price (2)\' is incorrect or equal 0.");document.form1.Price2.focus(); document.form1.Price2.select();return false
   }
   if (!((document.form1.Price3.value > 0 )&&(document.form1.Price3.value < 100000000 ))) {
     alert("Value in the field \'Price (3)\' is incorrect or equal 0.");document.form1.Price3.focus(); document.form1.Price3.select();return false
   }

   if (document.form1.ProductSmallPicture.value == '') {
     alert("The field  \'Small Picture\' cannot be empty.");document.form1.Filename1.focus();document.form1.Filename1.select(); return false
   }
   if (document.form1.ProductPicture.value == '') {
     alert("The field \'Big Picture\' cannot be empty.");document.form1.Filename2.focus(); document.form1.Filename2.select(); return false
   }
   if (document.form1.ProductDetailedDescription.value == '') {
     alert("The field \'Detailed Description\' cannot be empty.");document.form1.Filename3.focus();document.form1.Filename3.select(); return false
   }
   if ($SizeTmp1 > $SizeTmp2) {
     alert("Warning! Size of \'Small Picture\' is bigger than size of \'Big Picture\'.");document.form1.Filename1.focus();document.form1.Filename1.select(); return false
   }


   if (document.form1.ProductShortDescription.value == '') {
     alert("The field \'Product Short Description\' cannot be empty.");document.form1.ProductShortDescription.focus();document.form1.ProductShortDescription.select(); return false
   }
   else {
      if (confirm('Submit this product ?')) { return true; }
      else  { return false; }
   }

}

function checkRemoveProduct() {

  if (confirm('Remove this product from database?')) { return true; }
  else {  return false;
  }
}

// Set focus on Load or error
function setFocus() {
  $str_scriptvar
}

$str_check_javascript

function checkUpload () {

  if ((document.form1.Filename1.value.length < 1)&&(document.form1.Filename2.value.length < 1)&&
      (document.form1.Filename3.value.length < 1)&&(document.form1.Filename4.value.length < 1))
    { alert("Please select at least one file to upload to web-server.");
    document.form1.Filename1.focus();  document.form1.Filename1.select(); return false; }
   $str_change_javascript
   else {  return true;  }
}


</SCRIPT>
</HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\">
<CENTER>
<H3>
$str Product.
</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"70%\"></TH><TH width=\"30%\"></TH></TR>
<TR><TD align=\"right\"></TD>
<TD align=\"left\"><font size=2 color=\"black\"><font color=#ff0000>*</font> Required field</font></TD></TR>
</Table>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\">Bullet <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=Bullet value=\"$Bullet\"
              maxlength=5 size=5 > (1-99999) </TD></TR>


<TR><TD align=\"right\">Product Number <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=StoreProductNumber value=\"$StoreProductNumber\"
              maxlength=30 size=35 ></TD></TR>
<TR><TD align=\"right\">Product Name <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=StoreProductName value=\"$StoreProductName\"
              maxlength=250 size=70 ></TD></TR>
<TR><TD align=\"right\">Category <font color=#ff0000>*</font> :</TD>
<TD align=\"left\">$str_select1</TD></TR>
<TR><TD align=\"right\">Subcategory <font color=#ff0000>*</font> :</TD>
<TD align=\"left\">$str_select11 </TD></TR>
<TR><TD align=\"right\"> Manufacturer Product Number <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=ManufacturerProductNumber value=\"$ManufacturerProductNumber\"
              maxlength=30 size=35></TD></TR>
<TR><TD align=\"right\"> Manufacturer Name <font color=#ff0000>*</font> :</TD>
<TD align=\"left\">$str_select2</TD></TR>
<TR><TD align=\"right\">Manufact.Product Name <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=ManufacturerProductName value=\"$ManufacturerProductName\"
               maxlength=250 size=70></TD></TR>
<TR><TD align=\"right\">Availability <font color=#ff0000>*</font> :</TD><TD align=\"left\">$str_select5</TD></TR>
<TR><TD align=\"right\">Quantity <font color=#ff0000>*</font> :</TD><TD><input type=text name=Quantity value=\"$Quantity\"
                maxlength=5 size=5> (0-99999) </TD></TR>
</table>


<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\">Price, \$ <font color=#ff0000>*</font> :</TD><TD> 1 <input type=text name=Price value=\"$Price\"
                maxlength=12 size=12>&nbsp;2 <input type=text name=Price2 value=\"$Price2\"
                maxlength=12 size=12>&nbsp;3 <input type=text name=Price3 value=\"$Price3\"
                maxlength=12 size=12></TD></TR>

<TR><TD align=\"right\">Price Type :</TD><TD>$str_select4</TD></TR>
</Table>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\">Belongs to:</TD>
<TD align=\"left\">$str_NewBox &nbsp;&nbsp; $str_SpecialBox &nbsp;&nbsp; $str_TopBox</TD></TR>
</Table>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\" BGCOLOR=\"#CCCCCC\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\"><BR></TD> <TD align=\"left\"></TD></TR>
<TR><TD align=\"right\" valign=top ><B>Upload Files:</B></TD> <TD align=\"left\">
<font SIZE=\"1\" face=\"Arial, Helvetica, Condensed\">
Click any \"Browse\" button to locate the file you need, and select it.<br>
The file path will appear in the \"Input\" field. Next, click \"Upload files\"<BR>
to upload the selected file(s) to web-server.</font></TD></TR></table>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<tr><td align = \"right\" valing=\"top\">Small Picture (width=150, height=any) <font color=#ff0000>*</font> :</td>
<td align=\"left\">
<input type=\"file\" name=\"Filename1\" size=40 >
</td></tr>
<tr><td align = \"right\">Big Picture (width=any, height=any) <font color=#ff0000>*</font> :</td>
<td align=\"left\">
<input type=\"file\" name=\"Filename2\" size=40 ></td></tr>
<tr><td align = \"right\">Detailed Description(Pdf-file) <font color=#ff0000>*</font> :</td>
<td align=\"left\">
<input type=\"file\" name=\"Filename3\" size=40></td></tr>
</TABLE>
<br>

<input type=submit name=com value=\" Upload Files \" onClick=\"return checkUpload()\">
<BR>

<table border=\"0\" width=\"100%\" cellspacing=\"5\" cellpadding=\"4\">
<TR><TH width=\"30%\"></TH><TH width=\"70%\"></TH></TR>
<TR><TD align=\"right\"><BR></TD> <TD align=\"left\"></TD></TR>
<TR><TD align=\"right\" valign=top ><B>Remove Files:</B></TD> <TD align=\"left\">
<font SIZE=\"1\" face=\"Arial, Helvetica, Condensed\">
Check box(es) upon the file(s) you wish to remove from this product.<br>
Next, click button \"Remove files\" to delete them. Also, you can<br>
upload new file to replace already existing one.
</font>
</TD></TR></TABLE>



<table border=\"0\" width=\"90%\" cellspacing=\"1\" cellpadding=\"0\">
<TR bgcolor=\"#DDDDDD\"><TH width=\"14%\">Type<TH width=\"38%\">File Name ( Size )</TH>
<TH width=\"3%\">Box</TH><TH width=\"35%\">View</TH></TR>
<TR bgcolor=\"#DDDDDD\"><TD align=\"left\" ><font size=2>&nbsp;<b>Small Picture</b></font></TD>
  <TD align=\"left\"> &nbsp $FileTmp1</TD>
  <TD align=\"center\">$str_check1</TD>
  <TD align=\"center\" valign=\"center\">$Img1</TD></TR>
<TR bgcolor=\"#DDDDDD\"><TD align=\"left\" ><font size=2>&nbsp;<b>Big Picture</b></font></TD>
  <TD align=\"left\"> &nbsp $FileTmp2</TD>
  <TD align=\"center\">$str_check2</TD>
  <TD align=\"center\"valign=\"center\" >$Img2</TD></TR>
<TR bgcolor=\"#DDDDDD\"><TD align=\"left\" ><font size=2>&nbsp;<b>Pdf-file</b></font></TD>
  <TD align=\"left\"> &nbsp $FileTmp3</TD>
  <TD align=\"center\">$str_check3</TD>
  <TD align=\"center\"valign=\"center\" >$Img3</TD></TR>
</Table>
<br>
<input type=submit name=com value=\" Remove Files \" onClick=\"return checkRemove()\">

<BR><BR>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"15%\"></TH><TH width=\"85%\"></TH></TR>
<TR><TD valign=\"top\" align=\"right\">Short <br>Description <font color=#ff0000>*</font> : </TD>
<TD align=\"left\">
   <TEXTAREA NAME=ProductShortDescription ROWS=10 COLS=80>$ProductShortDescription</TEXTAREA><br><br>
</TD></TR>

<TR><TD valign=\"top\" align=\"right\">Description:</TD>
<TD align=\"left\"><TEXTAREA NAME=ProductDescription ROWS=15 COLS=80>$ProductDescription</TEXTAREA></TD></TR>
<TR><TD valign=\"top\" align=\"right\">Specification:</TD>
<TD align=\"left\"><TEXTAREA NAME=ProductSpecification ROWS=20 COLS=80>$ProductSpecification</TEXTAREA></TD></TR>
<TR><TD valign=\"top\" align=\"right\">Tech Notes:</TD>
<TD align=\"left\"><TEXTAREA NAME=ProductTechNotes ROWS=20 COLS=80>$ProductTechNotes</TEXTAREA></TD></TR>
</Table>

<br>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\">Product Status <font color=#ff0000>*</font> :</TD><TD align=\"left\">$str_select3</TD></TR></Table>

<br>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=SelectCategory value=\"$SelectCategory\">
<input type=hidden name=page value=\"$page\">
<input type=hidden name=rowNumber value=\"$rowNumber\">
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">
<input type=hidden name=code value=\"$code\">

<input type=hidden name=ProductSmallPicture value=\"$ProductSmallPicture\">
<input type=hidden name=ProductPicture value=\"$ProductPicture\">
<input type=hidden name=ProductDetailedDescription value=\"$ProductDetailedDescription\">

<input type=hidden name=ProductSpecialPicture value=\"$ProductSpecialPicture\">
<input type=hidden name=ProductNewPicture value=\"$ProductNewPicture\">
<input type=hidden name=ProductTopPicture value=\"$ProductTopPicture\">
$str_Category_Out

$str_button

<br><br>
</CENTER></FORM>
</BODY></HTML>
Browser

}   ##edit_product


############################################################################
sub dbedit_product        #18.02.2000  20:53
############################################################################

{

# Get params from 'Edit Product' form
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');
$rowNumber=$q->param('rowNumber');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');


$Id=$q->param('Id');
$Bullet=$q->param('Bullet');
if ( $Bullet == '' ) { $Bullet=0; }

$StoreProductNumber=$q->param('StoreProductNumber');
$StoreProductNumber=uc($StoreProductNumber);
$Category=$q->param('Category');
$Subcategory=$q->param('Subcategory');
$StoreProductName=$q->param('StoreProductName');
$ManufacturerProductNumber=$q->param('ManufacturerProductNumber');
$ManufacturerName=$q->param('ManufacturerName');
$ManufacturerProductName=$q->param('ManufacturerProductName');
$ProductShortDescription=$q->param('ProductShortDescription');
$ProductSmallPicture=$q->param('ProductSmallPicture');
$ProductPicture=$q->param('ProductPicture');
$ProductDescription=$q->param('ProductDescription');
$ProductSpecification=$q->param('ProductSpecification');
$ProductTechNotes=$q->param('ProductTechNotes');
$ProductDetailedDescription=$q->param('ProductDetailedDescription');
$Price=$q->param('Price');
$Price2=$q->param('Price2');
$Price3=$q->param('Price3');
$PriceType=$q->param('PriceType');
$TypeOfAvailable=$q->param('TypeOfAvailable');

$Quantity=$q->param('Quantity');  
if ($Quantity == '') { $Quantity = 0; }

$Status=$q->param('Status');
$comTest=$q->param('comTest');

$SpecialBox=$q->param('SpecialBox');
$TopBox=$q->param('TopBox');
$NewBox=$q->param('NewBox');

$ProductSpecialPicture=$q->param('ProductSpecialPicture');
$ProductTopPicture=$q->param('ProductTopPicture');
$ProductNewPicture=$q->param('ProductNewPicture');

if ( $SpecialBox eq '' ) { $SpecialBox = 1;  $ProductSpecialPicture=''; }
if ( $TopBox eq '' ) { $TopBox = 1; $ProductTopPicture = ''; }
if ( $NewBox eq '' ) { $NewBox = 1; $ProductNewPicture = ''; }

#############################################
$_=$StoreProductNumber;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StoreProductNumber=$_;
$_=$StoreProductName;           (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StoreProductName=$_;
$_=$ManufacturerProductNumber;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ManufacturerProductNumber=$_;
$_=$ManufacturerProductName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ManufacturerProductName=$_;
$_=$ProductShortDescription;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ProductShortDescription=$_;
$_=$ProductDescription;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ProductDescription=$_;
$_=$ProductSpecification;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ProductSpecification=$_;
$_=$ProductTechNotes;           (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ProductTechNotes=$_;

$_=$Price;                      (s/^\s+//); (s/\s+$//); $Price=$_;
$_=$Price2;                     (s/^\s+//); (s/\s+$//); $Price2=$_;
$_=$Price3;                     (s/^\s+//); (s/\s+$//); $Price3=$_;

my $str_message='';

################# Upload Files ###################
if ( $com eq ' Upload Files ')  {

    $message_main=''; $message1=''; $message2=''; $message3=''; $message4='';
    $Filename1=$q->param('Filename1');
    $Filename2=$q->param('Filename2');
    $Filename3=$q->param('Filename3');


    if ( $Filename1 ne '') {
      ($ProductSmallPicture, $message1 ) = write_file_product($Filename1,1);
    }
    if ( $Filename2 ne '') {
      ($ProductPicture, $message2 ) = write_file_product($Filename2,1 );
    }
    if ( $Filename3 ne '') {
      ($ProductDetailedDescription, $message3 ) = write_file_product($Filename3,2);
    }

    $message_main=$message1.$message2.$message3;

    if ( $message_main eq '' ) {
      edit_product("document.form1.Filename1.focus();  document.form1.Filename1.select();
        alert('Uploading of file(s) has been completed successfully !')", 1 , 'new');
       return;
    }
    else {
      edit_product("document.form1.Filename1.focus();  document.form1.Filename1.select();
        alert('Uploading of file(s) has been completed with error ! \\n$message_main')", 1, 'new' );
      return;
    }
}

################# Remove Files ###################
elsif ( $com eq ' Remove Files ') {

    $Checkfile1=$q->param('Checkfile1');
    $Checkfile2=$q->param('Checkfile2');
    $Checkfile3=$q->param('Checkfile3');

    if ( $Checkfile1 == 1) { remove_file_product($ProductSmallPicture, 1); $ProductSmallPicture=''; }
    if ( $Checkfile2 == 1) { remove_file_product($ProductPicture, 1); $ProductPicture=''; }
    if ( $Checkfile3 == 1) { remove_file_product($ProductDetailedDescription, 2); $ProductDetailedDescription=''; }

    edit_product("document.form1.Filename1.focus();  document.form1.Filename1.select();
    alert('Removing of file(s) has been completed successfully!')", 1 , 'new');
    return;
}

################## Insert ########################
elsif ( $com eq '  Insert  ')
 {
       $sql="INSERT INTO Product (
            Bullet, StoreProductNumber,Category,Subcategory,StoreProductName,ManufacturerProductNumber,
            ManufacturerName,ManufacturerProductName,ProductShortDescription,ProductSmallPicture,
            ProductPicture,Price,Price2,Price3,PriceType,ProductDetailedDescription,
            Quantity, Status,
            ProductSpecialPicture, ProductTopPicture, ProductNewPicture, SpecialBox, TopBox, NewBox,
            ProductDescription, ProductSpecification, ProductTechNotes,
            TypeOfAvailable
            )
            VALUES (
            $Bullet, '$StoreProductNumber','$Category','$Subcategory','$StoreProductName',
            '$ManufacturerProductNumber','$ManufacturerName','$ManufacturerProductName',
            '$ProductShortDescription','$ProductSmallPicture',
            '$ProductPicture',$Price,$Price2,$Price3,$PriceType,'$ProductDetailedDescription',
             $Quantity, $Status,
            '', '', '', $SpecialBox, $TopBox, $NewBox,
            '$ProductDescription', '$ProductSpecification', '$ProductTechNotes',
            $TypeOfAvailable  
            )";
      if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<br>";  }
      else {
        edit_product("document.form1.Bullet.focus();  document.form1.Bullet.select();
        alert('Database error. The record has not been inserted !')", 1 , 'new');
        return;
      }
 }

############## Update the selected record #################3
elsif ( $com eq '  Update  ')
 {
        $sql="UPDATE Product SET Bullet=$Bullet, StoreProductNumber='$StoreProductNumber',Category='$Category',
                Subcategory='$Subcategory', StoreProductName='$StoreProductName',
                ManufacturerProductNumber='$ManufacturerProductNumber',
                ManufacturerName='$ManufacturerName',ManufacturerProductName='$ManufacturerProductName',
                ProductShortDescription='$ProductShortDescription',
                ProductSmallPicture='$ProductSmallPicture', ProductPicture='$ProductPicture',
                ProductDetailedDescription='$ProductDetailedDescription',
                Price=$Price,Price2=$Price2,Price3=$Price3,PriceType=$PriceType,
                Quantity=$Quantity, Status=$Status,
                SpecialBox=$SpecialBox, TopBox=$TopBox, NewBox=$NewBox,
                ProductSpecialPicture='$ProductSpecialPicture', ProductNewPicture='$ProductNewPicture',
                ProductTopPicture='$ProductTopPicture',
                ProductDescription='$ProductDescription', ProductSpecification='$ProductSpecification',
                ProductTechNotes='$ProductTechNotes', TypeOfAvailable=$TypeOfAvailable
             WHERE Id=$Id";
        if (dbdo($sql)) { $str_message= "The record has been updated successfully ! <br>"; }
        else {
          edit_product("document.form1.Bullet.focus();  document.form1.Bullet.select();
          alert('Database error. The record has not been updated !')", 1 , 'new');
          return;
        }
 }

################ Delete the selected record ################
elsif( $com eq '  Delete  ')
 {
  $sql="UPDATE Product SET status=1 WHERE Id=$Id";
  if (dbdo($sql)) {
        $str_message= "The record has been deleted successfully ! <br>";
     remove_file_product($ProductSmallPicture, 1);
     remove_file_product($ProductPicture, 1);
     remove_file_product($ProductDetailedDescription, 2);
  }
  else {
       edit_product("document.form1.Bullet.focus();  document.form1.Bullet.select();
       alert('Database error. The record has not been deleted !')", 1 , 'new');
       return;
    }
 }


### Re-build JScript Menu and JScripts for  Home page###
create_js_menu();
create_home_js();

########################################################

change_page($com,1,$str_message);


}   ##dbedit_product


############################################################################
sub remove_file_product      #12.09.00 14:09
############################################################################
{

###### How to remove files
#my $filename=$_[0];
#my $path_dir=$_[1];

#if ($path_dir==1) { unlink ($path_product_image.$filename); }
#if ($path_dir==2) { unlink ($path_product_html.$filename); }
#if ($path_dir==3) { unlink ($path_product_pdf.$filename); }
#if ($path_dir==4) { unlink ($path_banner.$filename); }


} ##remove_file_product


############################################################################
sub write_file_product      #12.09.00 14:09
############################################################################
{

my $filename=$_[0];
my $select_path=$_[1];
my $mess='';

if ($filename=~m/^.*(\\|\/)(.*)/) {
  $name_attach = $2;
}
else {
  $name_attach=$filename;
}

##############################33?????????????##########

if ( $select_path == 1)   { $pathUpload=$path_product_image; }
elsif ( $select_path == 2){ $pathUpload=$path_product_pdf; }


open (FILE, ">$pathUpload"."$name_attach") or $mess = "Cannot write file ".$name_attach."\\n";
binmode(FILE);
while(<$filename>){ print FILE; }
close(FILE);

return $name_attach, $mess ;

}   ##write_file_product



############################################################################
sub option      #19.02.2000
############################################################################

{


$Id=$q->param('Id');
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');


my $str_message=$_[0]; # Get 'successful' message

my $str_table="<table border='1' width='100%' cellspacing='2' cellpadding='0'>
            <TR BGCOLOR='silver'>
            <TH width='3%' ><FONT size=2>N</FONT></TH>
            <TH width='12%'><FONT size=2>Number</FONT></TH>
            <TH width='35%'><FONT size=2>Name</FONT></TH>
            <TH width='10%'><FONT size=2>Price</FONT></TH>
            <TH width='10%'><FONT size=2>Availability</FONT></TH>
            <TH width='20%'><FONT size=2>Picture</FONT></TH>
            <TH width='10%'><FONT size=2>Description</FONT></TH>
            </TR>";
         

my $n=1;
my $pathCategory='';


$sql="SELECT StoreProductNumber, StoreProductName FROM Product WHERE Id=$Id";
dbexecute($sql);
($StoreProductNumber, $StoreProductName)=dbfetch();


$sql="SELECT Id, ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, TypeOfAvailable, Status
      FROM OptionList  WHERE ProductId=$Id and Status=0";
dbexecute($sql);
while (($OptionId, $ProductId, $OptionNumber, $OptionName, $OptionDescription, $OptionPicture, $OptionPrice, $TypeOfAvailable, $OptionStatus)=dbfetch()) {

  $TypeOfAvailableName='';
  $sql="SELECT Name FROM  TypeOfAvailable  WHERE Id = $TypeOfAvailable and Status=0";
  $cursor1=$dbh->prepare($sql);
  $cursor1->execute;
  $TypeOfAvailableName = $cursor1->fetchrow_array;

  $_=$OptionDescription;      (s/^\s+//); (s/\s+$//);  $OptionDescription=$_;
  if ( $OptionDescription ne '')  {
    $OptionDescription="+";
  }
  else  {
    $OptionDescription="-";
  }

  $OptionPrice=converter($OptionPrice);

  $pathOption=$pathUrl."?com=Edit_Option&OptionId=$OptionId&Id=$Id&rowNumber=$rowNumber&SelectCategory=$SelectCategory&page=$page&code=$code&SelectNew=$SelectNew&SelectSpecial=$SelectSpecial&SelectTop=$SelectTop";
  $str_table.="<TR><TD align='center'><FONT size=2>$n</FONT></TD>
               <TD align='center'><a href='".$pathOption."'><FONT size=2>$OptionNumber</FONT></a></TD>
               <TD align='left'><FONT size=2>$OptionName</FONT></TD>
               <TD align='right'><FONT size=2>\$ $OptionPrice&nbsp;</FONT></TD>
               <TD align='center'><FONT size=2>&nbsp;$TypeOfAvailableName</FONT></TD>
               <TD align='center'><FONT size=2>&nbsp;$OptionPicture</FONT></TD>
               <TD align='center'><FONT size=2>&nbsp;$OptionDescription</FONT></TD>";

  $n++;
}
$str_table.="</Table>";

# Set Warning message if the table is empty
if ($n==1) { $str_table="The table of available options is empty."; }



#HTML
print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<FORM METHOD='POST' ACTION=$pathUrl>
<CENTER>
<H4>$StoreProductNumber - $StoreProductName: Available Options</H4>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=SelectCategory value=\"$SelectCategory\">
<input type=hidden name=page value=\"$page\">
<input type=hidden name=rowNumber value=\"$rowNumber\">
<input type=hidden name=code value='$code'>
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">

<input type=submit name=com value='Add Option' >
<input type=submit name=com value='  Exit  ' >

</CENTER></FORM></BODY></HTML>
Browser
}   ##options



############################################################################
sub edit_option      #18.02.2000  18:16
############################################################################
{


$Id=$q->param('Id');
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');

$OptionId=$q->param('OptionId');

$comTest=$q->param('comTest');

$sql="SELECT StoreProductNumber, StoreProductName FROM Product WHERE Id=$Id";
dbexecute($sql);
($StoreProductNumber, $StoreProductName)=dbfetch();


if (( $com eq 'Add Option')||( $com eq ' Insert ')||( $comTest eq ' Insert ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=com value=' Insert ' onClick='return checkData()'>
               <input type=hidden name=comTest value=' Insert '>";
 }
else  {
  # Update or delete the record
  $str="Modify";
  $str_button="<input type=submit name=com value=' Update ' onClick='return checkData()'> ";
  $str_button.="<input type=submit name=com value=' Delete ' onClick='return checkDelete()'> ";
    if ( $_[2] ne 'new' )  {
       if ( $OptionId ne '' ) {
         $sql="SELECT Id, ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, TypeOfAvailable, Status
               FROM OptionList WHERE Id=$OptionId";
         dbexecute($sql);
         ($OptionId, $ProductId, $OptionNumber, $OptionName, $OptionDescription, $OptionPicture, $Price, $TypeOfAvailable, $Status)=dbfetch();
       }
    }
}


# Create Availability pull-box
my $str_select5="<SELECT NAME=TypeOfAvailable >";
$str_select5.="<OPTION VALUE=999>-- Select Item --";
$sql="SELECT Id, Name FROM TypeOfAvailable WHERE Status=0 ORDER BY Id";
dbexecute($sql);
while (( $IdTmp,$Name ) =dbfetch()) {

  if ( $IdTmp==$TypeOfAvailable )  { $str_select5.="<OPTION SELECTED VALUE=$IdTmp>$Name"; }
  else { $str_select5.="<OPTION VALUE=$IdTmp>$Name"; }
}
$str_select5.="</SELECT>";


if  ( $OptionPicture eq '') {
   $upload_disabled ="";
   $remove_disabled ="disabled";
   $str_image="";

}
else {
   $upload_disabled ="disabled";
   $remove_disabled ="";
   $str_image="<img src='/store/option_image/$OptionPicture' border=0>";
}


$_=$OptionNumber;          s/\\//g; s/\"/&quot;/g; $OptionNumber=$_;
$_=$OptionName;            s/\\//g; s/\"/&quot;/g; $OptionName=$_;
$_=$OptionDescription;     s/\\//g; s/\"/&quot;/g; $OptionDescription=$_;


print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<SCRIPT>

// Validate fields before submit
function checkData () {

   if (document.form1.OptionNumber.value == '') {
     alert("The field \'Number\' cannot be empty.");document.form1.OptionNumber.focus();document.form1.OptionNumber.select(); return false
   }

   if (document.form1.OptionName.value == '') {
     alert("The field \'Name\' cannot be empty.");document.form1.OptionName.focus();document.form1.OptionName.select(); return false
   }
   if (!((document.form1.Price.value > 0 )&&(document.form1.Price.value < 100000000 ))) {
     alert("The field \'Price\' is incorrect or equal 0.");document.form1.Price.focus(); document.form1.Price.select();return false
   }
   if (document.form1.TypeOfAvailable.selectedIndex == 0) {
     alert("The field \'Availability\' cannot be empty.");document.form1.TypeOfAvailable.focus(); return false
   }

   if (confirm('Save information ?')) { return true; }
   else  { return false; }
}

function checkDelete() {
  if (confirm('Remove this option from database?')) { return true; }
  else {  return false;
  }
}


// Set focus on Load or error
function setFocus() {
   $_[0];
}
function checkUpload () {

  if (document.form1.Filename5.value.length < 1)
    { alert("Please select image file to upload to web-server.");
    document.form1.Filename5.focus();  document.form1.Filename5.select(); return false; }
    else {  return true;  }
}

function checkRemove () {

    if (confirm('Remove this image file?')) { return true; }
     else  { return false; }
}


</SCRIPT>
</HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\">
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=SelectCategory value=\"$SelectCategory\">
<input type=hidden name=page value=\"$page\">
<input type=hidden name=rowNumber value=\"$rowNumber\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">


<input type=hidden name=OptionId value=\"$OptionId\">
<input type=hidden name=OptionPicture value=\"$OptionPicture\">

<CENTER>
<h4>$str Option<br>$StoreProductNumber - $StoreProductName</h4>

<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"35%\"></TH><TH width=\"65%\"></TH></TR>
<TR><TD align=\"right\"> Number <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=OptionNumber value=\"$OptionNumber\" maxlength=30 size=20></TD></TR>
<TR><TD align=\"right\"> Name <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=OptionName value=\"$OptionName\" maxlength=250 size=67></TD></TR>
<TR><TD align=\"right\"> Price <font color=#ff0000>*</font> :</TD>
<TD align=\"left\"><input type=text name=Price value=\"$Price\" maxlength=10 size=10></TD></TR>
<TR><TD align=\"right\" valign=top> Description :</TD>
<TD align=\"left\"><textarea rows=7 name=OptionDescription cols=50>$OptionDescription</textarea>
</TD></TR>
<TR><TD align=\"right\"> Availability <font color=#ff0000>*</font> :</TD>
<TD align=\"left\">$str_select5
</TD></TR>

<TR><TD colspan=2 width=20% align=\"right\"><br></TD></TR>

<TR><TD align=\"right\">Image File Input :</TD>
<TD align=\"left\"><input type=\"file\" name=\"Filename5\" size=50  $upload_disabled>
</TD></TR>
<TR><TD align=\"right\"></TD>
<TD align=\"left\"><input type=submit $upload_disabled  name=com value=\" Upload File \" onClick=\"return checkUpload()\">
&nbsp; <input type=submit name=com value=\" Remove File \" $remove_disabled onClick=\"return checkRemove()\">
 </TD></TR>
</Table>


<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<tr><td align = \"right\" valing=\"top\"></td>
<td align=\"left\"> $str_image &nbsp; $OptionPicture</td></tr>
</TABLE>
<BR><BR>
$str_button <input type=submit name=com value='Cancel'>



</CENTER></FORM>

</BODY></HTML>
Browser

}   ##edit_option


############################################################################
sub dbedit_option        #18.02.2000  20:53
############################################################################

{

$Id=$q->param('Id');
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');

$OptionId=$q->param('OptionId');
$OptionNumber=$q->param('OptionNumber');
$OptionName=$q->param('OptionName');
$OptionDescription=$q->param('OptionDescription');
$OptionPicture=$q->param('OptionPicture');
$Price=$q->param('Price');
$TypeOfAvailable=$q->param('TypeOfAvailable');


$_=$OptionNumber;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $OptionNumber=$_;
$_=$OptionName;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $OptionName=$_;
$_=$OptionDescription;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $OptionDescription=$_;

my $str_message='';



################## Insert ########################
if ( $com eq ' Insert ')
 {

       $sql="INSERT INTO OptionList (ProductId, OptionNumber, OptionName, OptionDescription, OptionPicture, Price, TypeOfAvailable, Status)
             VALUES ($Id, '$OptionNumber', '$OptionName', '$OptionDescription', '$OptionPicture', $Price, $TypeOfAvailable, 0)";
      if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<br>";  }
      else {
        edit_option("document.form1.OptionNumber.focus();  document.form1.OptionNumber.select();
        alert('Database error. The record has not been inserted !')", 1 , 'new');
        return;
      }
 }

############## Update the selected record #################3
elsif ( $com eq ' Update ')
 {
        $sql="UPDATE OptionList SET OptionNumber='$OptionNumber', OptionName='$OptionName',
              OptionDescription='$OptionDescription', OptionPicture='$OptionPicture', Price=$Price,
              TypeOfAvailable=$TypeOfAvailable
              WHERE Id=$OptionId";
        if (dbdo($sql)) { $str_message= "The record has been updated successfully ! <br>";}
        else {
          edit_option("document.form1.OptionNumber.focus();  document.form1.OptionNumber.select();
          alert('Database error. The record has not been updated !')", 1 , 'new');
          return;
        }
 }

################ Delete the selected record ################
elsif( $com eq ' Delete ')
 {
  $sql="UPDATE OptionList SET Status=1 WHERE Id=$OptionId";
  if (dbdo($sql)) {
      $str_message= "The record has been deleted successfully ! <br>";
      if ( $OptionPicture ne '') {
          unlink ($path_option_image.$OptionPicture);  }
      }
  else {
       edit_option("document.form1.OptionNumber.focus();  document.form1.OptionNumber.select();
       alert('Database error. The record has not been deleted !')", 1 , 'new');
       return;
    }
 }



################# Upload Files ###################
elsif ( $com eq ' Upload File ')  {

    $Filename5=$q->param('Filename5');
    $filename=$Filename5;

    if ($filename=~m/^.*(\\|\/)(.*)/) {
       $name_attach = $2;
    }
    else {
       $name_attach=$filename;
    }
    $mess='';
    open (FILE, ">$path_option_image"."$name_attach") or $mess = "Cannot write file ".$name_attach."\\n";
    binmode(FILE);
    while(<$filename>){ print FILE; }
    close(FILE);

    $OptionPicture =$name_attach;
    if ( $mess ne '' ) {
        edit_option("alert('\"Upload File\" has been completed with error ! ')", 1 , 'new'); return;

    }
    else {
       edit_option("alert('\"Upload File\" has been completed successfully !')", 1 , 'new'); return;
    }
}

################# Remove Files ###################
elsif ( $com eq ' Remove File ') {

    unlink ($path_option_image.$OptionPicture);
    $OptionPicture ='';
    edit_option("alert('\"Remove File\" has been completed successfully !')", 1 , 'new'); return;
}

 option();

}   ##dbedit_option


############################################################################
sub edit_new_top      #18.02.2000  18:16
############################################################################
{


$Id=$q->param('Id');
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');
$Status=$q->param('Status');



if (( $com eq 'New')||( $comTest eq 'New')) {
      $sql="SELECT StoreProductNumber, StoreProductName, ProductNewPicture, ProductSmallPicture FROM Product WHERE Id=$Id";
      dbexecute($sql);
      ($StoreProductNumber, $StoreProductName, $ProductNewPicture, $ProductSmallPicture)=dbfetch();
      $str_top_line="New Products";
      if ( $ProductNewPicture ne '')  {
         $str_box="<INPUT type='checkbox' checked name='ProductNewPicture' value='true' >";
      }
      else {
         $str_box="<INPUT type='checkbox' name='ProductNewPicture' value='true' >";
      }
      $str_box.="<input type=hidden name=comTest value=New>";
}
if (( $com eq 'Top')||( $comTest eq 'Top')) {
      $sql="SELECT StoreProductNumber, StoreProductName, ProductTopPicture, ProductSmallPicture FROM Product WHERE Id=$Id";
      dbexecute($sql);
      ($StoreProductNumber, $StoreProductName, $ProductTopPicture, $ProductSmallPicture)=dbfetch();
      $str_top_line="Top Sellers ";
      if ( $ProductTopPicture ne '')  {
         $str_box="<INPUT type='checkbox' checked name='ProductTopPicture' value='true' >";
      }
      else {
         $str_box="<INPUT type='checkbox' name='ProductTopPicture' value='true' >";
      }
      $str_box.="<input type=hidden name=comTest value=Top>";

}

if (( $com eq 'Special')||( $comTest eq 'Special')) {
      $sql="SELECT StoreProductNumber, StoreProductName, ProductSpecialPicture, ProductSmallPicture FROM Product WHERE Id=$Id";
      dbexecute($sql);
      ($StoreProductNumber, $StoreProductName, $ProductSpecialPicture, $ProductSmallPicture)=dbfetch();
      $str_top_line="Special Offers";
      if ( $ProductSpecialPicture ne '')  {
         $str_box="<INPUT type='checkbox' checked name='ProductSpecialPicture' value='true' >";
      }
      else {
         $str_box="<INPUT type='checkbox' name='ProductSpecialPicture' value='true' >";
      }
      $str_box.="<input type=hidden name=comTest value=Special>";

}




print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<SCRIPT>

// Validate fields before submit
function checkData () {
   if (confirm('Save this information ?')) { return true; }
   else  { return false; }
}

</SCRIPT>
</HEAD>

<BODY BGCOLOR=\"#CCCCCC\">
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\">
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=StoreProductNumber value=\"$StoreProductNumber\">
<input type=hidden name=StoreProductName value=\"$StoreProductName\">

<input type=hidden name=code value=\"$code\">
<input type=hidden name=SelectCategory value=\"$SelectCategory\">
<input type=hidden name=page value=\"$page\">
<input type=hidden name=rowNumber value=\"$rowNumber\">
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">

<CENTER>
<h3>$str_top_line</h3>
<h4> $StoreProductNumber-$StoreProductName</h4>


<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"50%\"></TH><TH width=\"50%\"></TH></TR>
<tr><td align = \"right\" valing=\"top\">Show product in the limited list (yes/no):</td>
<td align=\"left\">$str_box &nbsp;&nbsp;
<input type=submit name=com value=\"  Save  \">
<input type=submit name=com value=\" Cancel \">
</td></tr>
</TABLE>

</CENTER></FORM>

</BODY></HTML>
Browser

}   ##edit_new_top


############################################################################
sub dbedit_new_top        #18.02.2000  20:53
############################################################################

{

$Id=$q->param('Id');
$StoreProductNumber=$q->param('StoreProductNumber');
$StoreProductNumber=uc($StoreProductNumber);
$StoreProductName=$q->param('StoreProductName');

$ProductNewPicture=$q->param('ProductNewPicture');
$ProductTopPicture=$q->param('ProductTopPicture');
$ProductSpecialPicture=$q->param('ProductSpecialPicture');
$comTest=$q->param('comTest');


my $str_message='';
if ( $comTest eq 'New') {
    $sql="UPDATE Product SET ProductNewPicture='$ProductNewPicture'  WHERE Id=$Id";
    if (dbdo($sql)) {  }
    else { edit_new_top("alert('Database error. The record has not been updated !')");  return;  }
}
if ( $comTest eq 'Top') {
    $sql="UPDATE Product SET ProductTopPicture='$ProductTopPicture'  WHERE Id=$Id";
    if (dbdo($sql)) {  }
    else { edit_new_top("alert('Database error. The record has not been updated !')");  return;  }
}
if ( $comTest eq 'Special') {
    $sql="UPDATE Product SET ProductSpecialPicture='$ProductSpecialPicture'  WHERE Id=$Id";
    if (dbdo($sql)) {  }
    else { edit_new_top("alert('Database error. The record has not been updated !')");  return;  }
}


create_home_js();
change_page($com,1,"The record has been updated successfully");

}   ##dbedit_new_top




###### THE END OLD STARTS ##################################################


############################################################################
sub edit_special      #18.02.2000  18:16
############################################################################
{

$Id=$q->param('Id');
$rowNumber=$q->param('rowNumber');
$SelectCategory=$q->param('SelectCategory');
$page=$q->param('page');
$SelectNew=$q->param('SelectNew');
$SelectSpecial=$q->param('SelectSpecial');
$SelectTop=$q->param('SelectTop');
$Status=$q->param('Status');

if ( $com eq 'Special') {
      $sql="SELECT StoreProductNumber, StoreProductName, ProductSpecialPicture FROM Product WHERE Id=$Id";
      dbexecute($sql);
      ($StoreProductNumber, $StoreProductName, $ProductSpecialPicture)=dbfetch();
}


if ( $ProductSpecialPicture eq '') {
   $upload_disabled ="";
   $remove_disabled ="disabled";
   $str_image="";

}
else {
   $upload_disabled ="disabled";
   $remove_disabled ="";
   $str_image="<img src='/store/banner/$ProductSpecialPicture' border=0>";
}

  $str_top_line="Special Offers Banner Uploader";
  $str_size="<u>Special Offers</u>: image size requirement (width = 145, height = 127)";


print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<SCRIPT>

// Validate fields before submit
function checkData () {
   if (confirm('Save this information ?')) { return true; }
   else  { return false; }
}

// Set focus on Load or error
function setFocus() {
   $_[0];
}
function checkUpload () {

  if (document.form1.Filename5.value.length < 1)
    { alert("Please select image file to upload to web-server.");
    document.form1.Filename5.focus();  document.form1.Filename5.select(); return false; }
    else {  return true;  }
}

function checkRemove () {

    if (confirm('Remove this image file?')) { return true; }
     else  { return false; }
}


</SCRIPT>
</HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\">
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=StoreProductNumber value=\"$StoreProductNumber\">
<input type=hidden name=StoreProductName value=\"$StoreProductName\">

<input type=hidden name=code value=\"$code\">
<input type=hidden name=SelectCategory value=\"$SelectCategory\">
<input type=hidden name=page value=\"$page\">
<input type=hidden name=rowNumber value=\"$rowNumber\">
<input type=hidden name=SelectNew value=\"$SelectNew\">
<input type=hidden name=SelectSpecial value=\"$SelectSpecial\">
<input type=hidden name=SelectTop value=\"$SelectTop\">

<input type=hidden name=ProductSpecialPicture value=\"$ProductSpecialPicture\">

<CENTER>
<h3>$str_top_line</h3>
<h4> $StoreProductNumber-$StoreProductName</h4>


<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"15%\"></TH><TH width=\"85%\"></TH></TR>
<tr><td align = \"right\" valing=\"top\">Input:</td>
<td align=\"left\">
<input type=\"file\" name=\"Filename5\" size=30  $upload_disabled> &nbsp; <input type=submit $upload_disabled  name=com value=\"Upload File\" onClick=\"return checkUpload()\">
&nbsp; <input type=submit name=com value=\"Remove File\" $remove_disabled onClick=\"return checkRemove()\"> &nbsp; <input type=submit name=com value=\"  Exit  \">
</td></tr>
<tr><td align = \"right\" valing=\"top\"></td>
<td align=\"left\">
$str_size
</td></tr>

</TABLE>
<br>


<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"2\">
<TR><TH width=\"15%\"></TH><TH width=\"85%\"></TH></TR>
<tr><td align = \"right\" valing=\"top\"></td>
<td align=\"left\"> $str_image &nbsp; $ProductSpecialPicture

</td></tr>
</TABLE>

</td></tr>
</TABLE>

</CENTER></FORM>

</BODY></HTML>
Browser

}   ##edit_special


############################################################################
sub dbedit_special        #18.02.2000  20:53
############################################################################

{

$Id=$q->param('Id');
$StoreProductNumber=$q->param('StoreProductNumber');
$StoreProductNumber=uc($StoreProductNumber);
$StoreProductName=$q->param('StoreProductName');
$ProductSpecialPicture=$q->param('ProductSpecialPicture');
$Status=$q->param('Status');

my $str_message='';


################# Upload Files ###################
if ( $com eq 'Upload File')  {


    $Filename5=$q->param('Filename5');
    $filename=$Filename5;

    if ($filename=~m/^.*(\\|\/)(.*)/) {
       $name_attach = $2;
    }
    else {
       $name_attach=$filename;
    }

    $mess='';

    open (FILE, ">$path_banner"."$name_attach") or $mess = "Cannot write file ".$name_attach."\\n";
    binmode(FILE);
    while(<$filename>){ print FILE; }
    close(FILE);

    $ProductSpecialPicture =$name_attach;

    if ( $mess ne '' ) {
        edit_special("alert('\"Upload File\" has been completed with error ! ')"); return;
    }

    $sql="UPDATE Product SET ProductSpecialPicture='$ProductSpecialPicture'   WHERE Id=$Id";
    if (dbdo($sql)) {
       edit_special("alert('\"Upload File\" and Database update have been completed successfully !')"); return;
    }
    else {
      edit_special("alert('Database error. The record has not been updated !')");  return;
    }

}

################# Remove Files ###################
elsif ( $com eq 'Remove File') {

    unlink ($path_banner.$ProductSpecialPicture);
    $ProductSpecialPicture='';
    $sql="UPDATE Product SET ProductSpecialPicture='$ProductSpecialPicture'   WHERE Id=$Id";
    if (dbdo($sql)) {
      edit_special("alert('\"Remove File\" and Database update have been completed successfully !')"); return;
    }
    else {
      edit_special("alert('Database error. The record has not been updated !')");  return;
    }

}

}   ##dbedit_special


############################################################################
sub exit_product      #12.09.00 14:09
############################################################################
{

 create_home_js();
 change_page($com,1,'');

}