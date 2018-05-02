#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / contact.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

$pathUrl =$path_cgi.'contact.pl';


$sql="SELECT NameStore, NameDirector, Address, City, State, Zip, 
             Country, Phone, Fax, Emailstore  FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $FaxStore, $EmailStore)=dbfetch();


$comSender = $q->param('comSender');
if ( $comSender eq 'Send')    { db_sender(); }
else {  sender();  }


############################################################################
sub sender      #05.07.00 8:03
############################################################################

{

$str_scriptvar=''; 
if ( $str_message ne '') {
    if ( $check==1 ) { $str_scriptvar="document.form1.From.focus(); document.form1.From.select();";  }
    $str_scriptvar="alert('$str_message'); ".$str_scriptvar;
}

$str_scriptvar="
  setFocusDouble(); 
}

function setFocusDouble() {
  GetTime();  
  $str_scriptvar
}

function GetTime() { 
  var dt = new Date();
  var def = dt.getTimezoneOffset()/60;
  var gmt = (dt.getHours() + def);

  var ending = \":\" + IfZero(dt.getMinutes()) + \":\" +  IfZero(dt.getSeconds());
  var pacif = check24(((gmt + (24-8)) >= 24) ? ((gmt + (24-8)) - 24) : (gmt + (24-8)));
  document.clock.pacif.value = \" \" + (IfZero(pacif) + ending);
  setTimeout(\"GetTime()\", 1000);
}

function IfZero(num) {
  return ((num <= 9) ? (\"0\" + num) : num);
}

function check24(hour) {
  return (hour >= 24) ? hour - 24 : hour;
";



$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Contact Us</u></A></SPAN>";


print "Content-type: text/html\n\n";
$template_file=$path_html."html/contact.html";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();

$VAR{'str_scriptvar'}=$str_scriptvar.$str_clock;
$VAR{'PhoneStore'}=$PhoneStore;
$VAR{'FaxStore'}=$FaxStore;
$VAR{'EmailStore'}=$EmailStore;

$VAR{'From'}=$From;
$VAR{'Body'}=$Body;


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

}   ##sender


############################################################################
sub db_sender       #05.07.00 8:12  Send email
############################################################################

{

# Get params from 'sender' form
$To=$EmailStore;
$From = $q->param('From');
$Subject="Message from Contact Us form";
$Body=$q->param('Body');
$_=$Body;    s/\r//g;  $Body=$_;
$check=0;

if (&email_check($From)==0){
  $str_message.= "E-mail From: $From - incorrect e-mail address ";
  $check=1;
  sender($str_message);
  return;
}

send_mail($To,$From,$Subject,$Body,"text");
$str_message.= "Your Message has been sent to Store Customer Support";

$From =''; $Body=''; 

sender($str_message);
return;

}   ##db_sender