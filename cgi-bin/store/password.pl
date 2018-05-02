#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / password.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();

$pathUrl =$path_cgi.'password.pl';

$sql="SELECT NameStore, NameDirector, Address, City, State,
             Zip, Country, Phone, Fax, Emailstore  FROM Setup";
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

if ( $str_message ne '') {
    if ( $check==1 ) { $str_scriptvar="document.form1.Email.focus(); document.form1.Email.select();";  }
    $str_scriptvar="alert('$str_message'); ".$str_scriptvar;
}


$str_menu_top="
  <SPAN style='FONT-WEIGHT: bold; FONT-SIZE: 10px; COLOR: #1b5665; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; TEXT-DECORATION: none'>&nbsp;&nbsp;
  <A class=PathSite  href='http://store.com'>Store.com</A> &gt; <A class=PathSite  href='$pathUrl'><u>Forgot password?</u></A></SPAN>";


print "Content-type: text/html\n\n";
$template_file=$path_html."html/password.html";
$VAR{'str_login'}=$str_login;
$VAR{'str_logout'}=$str_logout;

$VAR{'path_cgi'}=$path_cgi;
$VAR{'path_cgi_https'}=$path_cgi_https;
$VAR{'str_menu_top'}=$str_menu_top;
$VAR{'str_new_products'}=new_products();
$VAR{'str_special_products'}=special_products();

$VAR{'str_scriptvar'}=$str_scriptvar;
$VAR{'PhoneStore'}=$PhoneStore;
$VAR{'FaxStore'}=$FaxStore;
$VAR{'EmailStore'}=$EmailStore;

$VAR{'Login'}=$Login;
$VAR{'Email'}=$Email;


$template_file=parse_body($template_file, *STDOUT);
$VAR{'template_file'}=$template_file;

if ( !parse_template($path_html."html/template.html", *STDOUT)) {
      print "<HTML><BODY>Error access to HTML-file</BODY></HTML>";
}

}   ##sender


############################################################################
sub db_sender       #05.07.00 8:12  Send email
############################################################################

{

$Login=$q->param('Login');
$Email = $q->param('Email');
$check=0;

if (&email_check($Email)==0){
  $str_message= "Your E-mail: $Email - incorrect e-mail address ";
  $check=1;
  sender($str_message);
  return;
}

$sql = "SELECT Id, FirstName, CustomerID, Password
        FROM Profile 
        WHERE Email='$Email' and CustomerID = '$Login' and  Status=0";
dbexecute($sql);
($IdTMP, $FirstName, $CustomerIDTMP, $PasswordTMP) = dbfetch();

if ( !$IdTMP ) {
  $str_message="Invalid Login or E-mail address! Please try again.";
  sender($str_message);
  return;
}

if( $FirstName eq '' ) { $FirstName='Sir or Madam'; }


### set new login and password ###
@array1 = (
'a','b','c','d','f','g','h','i','j','k','l','m','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9',
'A','B','C','D','F','G','H','I','J','K','L','M','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'
);


$MyTmp='';
for ( $i=1; $i<11; $i++ ) {
 $r1=int(rand(70));
 $MyTmp.=$array1[$r1];
}
$PasswordTMP=$MyTmp;

##################################


$sql = "UPDATE Profile SET CustShifr='', Password ='$PasswordTMP'
        WHERE  Id=$IdTMP AND Status=0";

if (!dbdo($sql)) {
  $str_message="Database error! Please contact Store customer support.";
  sender($str_message);
  return;
}

$Subject="$NameStore messenger";
$Body="
Dear $FirstName,

Below is your New Login Information:
 
  Login = $CustomerIDTMP  
  Password = $PasswordTMP

We recommend that you save this information. If you have any questions
please contact our Customer Service at $EmailStore.

Thank you for the interest in our services.

$NameDirector,
Customer Service Representative
$NameStore
$EmailStore
";

send_mail($Email,$EmailStore,$Subject,$Body,"text");
send_mail($EmailStore,$EmailStore,$Subject,$Body,"text");

$str_login="class=expanded";
$str_logout="class=collapsed";
$str_StoreLogin="false";

$Email =''; $Login=''; 
$str_message= "New Password has been sent to your E-mail address";

sender($str_message);
return;

}   ##db_sender