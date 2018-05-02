#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_jscript.pl
#
############################################################################

use CGI;
$q = new CGI;
require 'db.pl';
require 'library.pl';

dbconnect();

$code = $q->param('code');

# if $code is not defined then accessdenied
if ( $code eq '' ) { accessdenied(); return; }

# if $code is not equal data from Password table then accessdenied
my $sql="SELECT Code, Super FROM Passw WHERE Code='$code'";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check ) { accessdenied(); return; }

report(); 


############################################################################
sub report
############################################################################

{

($error, $str_error_js, $str_table_js) = create_js_menu();

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR>
<pre>
<STRONG>$str_error_js</STRONG>

$str_table_js
</pre>
</BODY></HTML>
Browser

}   ##create_js_menu


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{
#Access Denied.
print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><STRONG>

Access Denied

</STRONG></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied