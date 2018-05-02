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

$pathUrl =$path_cgi.'resources.pl';

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();

resources();  

############################################################################
sub resources      #05.07.00 8:03
############################################################################

{

my $com=$q->param('com');

if ( $com ==1 ) { 
   $template_file=$path_html."html/resources1.html"; 
   $str_menu_top="
   <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'>Products Resources</A>
   &gt; <A class=PathSite  href='$pathUrl?com=1'><u>Glossary of satellite communication</u></A></SPAN>";
}
elsif ( $com ==2 ) { 
   $template_file=$path_html."html/resources2.html"; 
   $str_menu_top="
   <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'>Products Resources</A>
   &gt; <A class=PathSite  href='$pathUrl?com=2'><u>Introduction to theory and practice of earth satellite stations</u></A></SPAN>";
}
elsif ( $com ==3 ) { 
   $template_file=$path_html."html/resources3.html"; 
   $str_menu_top="
   <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'>Products Resources</A>
   &gt; <A class=PathSite  href='$pathUrl?com=3'><u>Satellite operators</u></A></SPAN>";
}
elsif ( $com ==4 ) { 
   $template_file=$path_html."html/resources4.html"; 
   $str_menu_top="
   <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Products Resources</u></A>
   &gt; <A class=PathSite  href='$pathUrl?com=4'><u>Literature</u></A></SPAN>";
}
else {
   $template_file=$path_html."html/resources_main.html";
   $str_menu_top="
   <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
   <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Products Resources</u></A></SPAN>";

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

}   ##resources


