#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / search.pl
#
############################################################################

use CGI;
use CGI::Cookie;
use LWP::Simple;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();
$pathUrl =$path_cgi.'search.pl';

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

$SearchWord = $q->param('SearchWord');
$_=$SearchWord;   (s/^\s+//); (s/\s+$//);  $SearchWord=$_;

search();

############################################################################
sub search      #05.07.00 8:03
############################################################################

{

$str_table="";
$i=0;
$limit=30;

if (($SearchWord ne '')&&( defined $SearchWord ))  {

   ###select categories###
   my $sql="SELECT distinct Category.Id, Category.Name
         FROM Category, Product
         WHERE Category.Status=0 and Product.Category=Category.Id and Product.Status=0
         ORDER BY Category.Name";
   dbexecute($sql);
   while (( $Id_Cat, $Name ) =dbfetch()) {

      ###select subcategories###
      $j = 0;
      $sql="SELECT distinct Subcategory.Id, Subcategory.Name
            FROM Subcategory, Product, Category
            WHERE Subcategory.Category=$Id_Cat and Subcategory.Status=0 and Product.Category=$Id_Cat
                   and Product.Subcategory=Subcategory.Id and Product.Status=0
            ORDER BY Subcategory.Name";
      $cursor1=$dbh->prepare($sql);
      $cursor1->execute;
      while (($Id_Sub, $NameSub) =$cursor1->fetchrow_array) {

         ###select products with subcategory###
         $j++;
         $sql="SELECT Product.Id, Product.StoreProductNumber, Product.StoreProductName
               FROM Product
               WHERE Product.Category=$Id_Cat and Product.Subcategory=$Id_Sub and Product.Status=0
               ORDER BY Product.StoreProductNumber ";
         $cursor2=$dbh->prepare($sql);
         $cursor2->execute;
         while (( $Id,$StoreProductNumber,$StoreProductName) =$cursor2->fetchrow_array) {

              $URL="product.pl?com=Description&SelCat=$Id_Cat&SelSubCat=$Id_Sub&Id=$Id";
              $URL_FULL=$path_cgi.$URL."&Print=1";
              $NAME="Products > $Name > $NameSub > $StoreProductNumber - $StoreProductName";
              $_= get($URL_FULL);
              if ( m/$SearchWord/i ) {
                 if ($i == $limit) {
                   last;
                 } 
                 $i++;
                 $str_table.="<a href='$URL' class=Search>$i. $NAME</u></a><br><br>";
              }
         }

      }

      ###select products with category###
      if ( $j==0 ) {
         $sql="SELECT Product.Id, Product.StoreProductNumber, Product.StoreProductName
               FROM Product
               WHERE Product.Category=$Id_Cat and Product.Status=0
               ORDER BY Product.StoreProductNumber ";
         $cursor2=$dbh->prepare($sql);
         $cursor2->execute;
         while (( $Id,$StoreProductNumber,$StoreProductName) =$cursor2->fetchrow_array) {
              $URL="product.pl?com=Description&SelCat=$Id_Cat&Id=$Id";
              $URL_FULL=$path_cgi.$URL."&Print=1";
              $NAME="Products > $Name > $StoreProductNumber - $StoreProductName";
              $_= get($URL_FULL);
              if ( m/$SearchWord/i ) {
                 if ($i == $limit) {
                   last;
                 } 
                 $i++;
                 $str_table.="<a href='$URL' class=Search>$i. $NAME</u></a><br><br>";
               }
         }
      }

   }

   $template_file=$path_menu_js."index.url";
   open(FILE, "<$template_file") or $str_table.="<font color = #ff0000>Error: File index.url not found. Search stopped.<br></font>";
   @lines=<FILE>;

   foreach $lines(@lines) {
     chop;
     ($URL, $NAME) = (split(/_/, $lines));
     $URL_FULL=$path_cgi.$URL."&comSearch=true";
     $_= get($URL_FULL);
     if ( m/$SearchWord/i ) {
       if ($i == $limit) {
        last;
       } 
       $i++;
       $str_table.="<a href='$URL' class=Search>$i. $NAME</u></a><br><br>";
     }
   }
   close(FILE);

   if ($i == $limit) {
     $str_table="<span style=\"FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #000000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
     <br><u>Search Result</u>: $i record(s)*, &nbsp;&nbsp;<u>Keyword(s)</u>: \"$SearchWord\" </span>
     <br><br>".$str_table."* Search returned too many records and the search result was limited by $limit records."
   }
   else {

     $str_table="<span style=\"FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #000000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
     <br><u>Search Result</u>: $i record(s), &nbsp;&nbsp;<u>Keyword(s)</u>: \"$SearchWord\" </span>
     <br><br>".$str_table;

   }

   if ($i == 0) {
      $str_table="<span style=\"FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #000000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
      <br><u>Search Result</u>: $i record(s), &nbsp;&nbsp;<u>Keyword(s)</u>: \"$SearchWord\" </span><br><br>
       <span style=\"FONT-WEIGHT: bold; FONT-SIZE: 11px; COLOR: #ff0000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
       Search didn't  return any result. Please broaden your criteria and try again.</span><br>"
   }
}
else {

      $str_table="<span style=\"FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #000000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
      <br><u>Search Result</u>: $i record(s), &nbsp;&nbsp;<u>Keyword(s)</u>: \"$SearchWord\" </span><br><br>
      <span style=\"FONT-WEIGHT: bold; FONT-SIZE: 11px; COLOR: #ff0000; FONT-FAMILY: Tahoma, Arial, Helvetica, sans-serif;\" >
      Search didn't  return any result. Please broaden your criteria and try again.</span><br>"

}

print "Content-type: text/html\n\n";
$template_file=$path_html."html/search.html";

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


}   ##search



