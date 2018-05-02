#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / map.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

$pathUrl =$path_cgi.'map.pl';
$pathUrlProduct =$path_cgi."product.pl";

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

main();  

############################################################################
sub main      #05.07.00 8:03
############################################################################

{

$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Site Map</u></A></SPAN>";


$count_outer=0;
$i=0;
str_table_right;

my $sql="SELECT distinct Category.Id, Category.Name
         FROM Category, Product
         WHERE Category.Status=0 and Product.Category=Category.Id and Product.Status=0
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
             <TD vAlign=top align=left width=34><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=550>$str_cat_empty<A  href='".$pathUrlProduct."?com=Product&SelCat=$Id'>&nbsp;$Name</A></TD>
         </TR>";
      }
      else {
         $str_table_right.="
         <TR>
             <TD vAlign=top align=left width=34><IMG src='/store/img/pix.gif' width=17 align=absMiddle border=0></td>
             <TD vAlign=top align=left width=550>$str_cat_plus"."$str_cat_minus<a id=cat".$Id." href=\"javascript:onClick=outliner('subcat".$Id."', 'plus".$Id."', 'minus".$Id."');\">&nbsp;$Name</div><DIV id=subcat".$Id." CLASS=collapsed2><TABLE border=0 cellPadding=0 cellSpacing=0>".$str_sub_cat_menu."</table></div></TD>
         </TR>";
      }
}



if ($i < 1)  {
   $str_table_right="<TR><TD vAlign=top align=left><font color='000000'>Sorry. Products search did not return any results.
   Please try again. If the problem persists, please send description to customer support.</font><br> $numRows<br> $count_outer;";
}

$str_table=$str_table_right;


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
    <TABLE cellSpacing=0 cellPadding=0 width=584 border=0 align=center>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Login</font></a> &nbsp; | &nbsp;<a href='#1'><font color=#aaaaaa>Register (New Account)</font></a></td></tr>
    <tr><td width=34 height=18></td><td width=550 valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='$pathUrlAccountPersonal'>&nbsp;Update My Account</a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='$pathUrlOrderHistory'>&nbsp;Orders History</a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='$pathUrlWishList'>&nbsp;Wish List</a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='$pathUrlAccountRemove' onClick = 'return checkRemove();'>&nbsp;Remove Account</a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty_end.jpg' width='13' align='absmiddle'><a href='$pathUrlAccountLogOut'>&nbsp;Logout</a></td></tr>
    </table>";

$str_menu_account_off="
    <TABLE cellSpacing=0 cellPadding=0 width=584 border=0 align=center>
    <tr><td></td><td><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'>&nbsp;<a href='$pathUrlAccountLogIn'>Login</a> &nbsp;|&nbsp; <a href='$pathUrlNewAccount'>Register (New Account)</a></td></tr>
    <tr><td width=34 height=18></td><td width=550 valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Update My Account</font></a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Orders History</font></a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Wish List</font></a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Remove Account</font></a></td></tr>
    <tr><td></td><td valign=top><img src='/store/icon/icon_empty_end.jpg' width='13' align='absmiddle'><a href='#1'><font color=#aaaaaa>&nbsp;Logout</font></a></td></tr>
    </table>";

if ( $access_key eq 'true') {
    $str_menu_account=$str_menu_account_on;
}
else {
    $str_menu_account=$str_menu_account_off;
}

print "Content-type: text/html\n\n";
$template_file=$path_html."html/map.html";

$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;
$VAR{'str_menu_account'}=$str_menu_account;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();
$VAR{'EmailStore'}=$EmailStore;
$VAR{'str_table'}=$str_table;

### SEARCH ENGINE ###
$comSearch=$q->param('comSearch');
if ($comSearch eq "true") {
  if ( !parse_template($template_file, *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
  }
}
else {
  $template_file=parse_body($template_file, *STDOUT);
  $VAR{'template_file'}=$template_file;

  if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
  }
}

}   ##main


