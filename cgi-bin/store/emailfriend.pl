#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / emailfriend.pl
#
############################################################################

use CGI;
use CGI::Cookie;
$q = new CGI;

require 'db.pl';
require 'library.pl';

dbconnect();
get_cookie();


$pathUrl =$path_cgi.'emailfriend.pl';

$comURL = $q->param('comURL');
$_=$comURL;   s/gomel/&/g; $comURL=$_;

$comSender = $q->param('comSender');
if ( $comSender eq 'Send')    { db_sender(); }
else {  sender();  }


############################################################################
sub sender      #05.07.00 8:03
############################################################################

{
if ( $str_message ne '') {
    if ( $check==1 ) { $str_scriptvar="document.form1.From.focus(); document.form1.From.select();";  }
    elsif ( $check==2 ) { $str_scriptvar="document.form1.To.focus(); document.form1.To.select();";  }
    elsif ( $check==3 ) { $str_scriptvar="document.form1.Copy.focus(); document.form1.Copy.select();";  }
    $str_scriptvar="alert('$str_message'); ".$str_scriptvar;
}

#F5FAFF
#d8e9f0
#f0f6f9

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store mailer</TITLE>
<link href="/store/js/store.css" rel=\"STYLESHEET\" type=\"text/css\">
<SCRIPT>

// check fields before send email
function check_field() {
   if (document.form1.From.value == '') {
        alert("The field \'E-mail From:\' is required"); document.form1.From.focus(); document.form1.From.select(); return;
   }
   if (document.form1.To.value == '') {
        alert("The field \'E-mail To:\' is required"); document.form1.To.focus(); document.form1.To.select(); return;
   }
  document.form1.submit();
}

function setFocus() {
       $str_scriptvar
    }
</SCRIPT></HEAD>

<BODY BGCOLOR=\"#ffffff\" onLoad=\"setFocus()\">
<FORM name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\">
<CENTER>
<input type=hidden name=comSender value=Send>
<input type=hidden name=comURL value=$comURL>
<table border=\"0\" width=\"380\" cellspacing=\"0\" cellpadding=\"0\">
<tr><td width=\"40\" height=10></td><td  colspan=2 width=\"340\"></td></tr>
<tr><td width=\"40\"></td>
    <td width=\"330\">
   <table border=\"0\" width=\"310\" cellspacing=\"0\" cellpadding=\"2\">



<TR><TD width=\"310\" colspan=2 height=20><span style=" COLOR: #1b5665; FONT-SIZE=13px; FONT-FAMILY: tahoma, veranda,  Arial, Helvetica, sans-serif; FONT-WEIGHT: bold; ">Send Store.com page refer to a colleague<span> <img  src="/store/icon/icon_mail.gif" width=20 height=20 align=right border=0 ></TD><tr>


<TR><TD width=\"310\" colspan=2 bgcolor='#468499'  height=16 class=Account><span style=" COLOR: #ffffff; FONT-SIZE=12px; FONT-FAMILY:  tahoma,veranda,  Arial, Helvetica, sans-serif; FONT-WEIGHT: bold; ">FROM:<span></TD><tr>
   <TR><TD width=160 class=Account>First Name<br>
            <INPUT name=FirstName value=\"$FirstName\" maxLength=30  style="BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 150px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif" >
       </TD>
       <TD width=150 class=Account>Last Name<br>
            <INPUT name=LastName value=\"$LastName\" maxLength=30  style="BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
             FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 150px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif" >
       </TD>
   </TR>
   <TR><TD colspan=2 class=Account>E-mail From:  <font color="#ff0000">*</font><br>
            <INPUT name=From value=\"$From\"  maxLength=50  style="BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
            FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 310px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif" >
       </TD>
   </TR>
<TR><TD colspan=2 height=15></TD><tr>
<TR><TD width=\"310\" colspan=2 bgcolor='#468499'  height=16 class=Account><span style=" COLOR: #ffffff; FONT-SIZE=12px; FONT-FAMILY:  tahoma,veranda,  Arial, Helvetica, sans-serif; FONT-WEIGHT: bold; ">TO:<span></TD><tr>
   <TR><TD colspan=2 class=Account>E-mail To: <font color="#ff0000">*</font><br>
            <INPUT name=To value=\"$To\"  maxLength=50  style="BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
            FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 310px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif" >
       </TD>
   </TR>
   <TR><TD colspan=2 class=Account>E-mail Copy To:<br>
            <INPUT name=Copy value=\"$Copy\"  maxLength=50  style="BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid;
            FONT-SIZE: 11px; BORDER-LEFT: #468499 1px solid; WIDTH: 310px; COLOR: #182520; BORDER-BOTTOM: #468499 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif" >
       </TD>
   </TR>
   <TR><TD colspan=2 class=Account>Add your comments<br>
           <textarea rows=9 name=Body style='BORDER-BOTTOM: #468499 1px solid; BORDER-LEFT: #468499 1px solid; BORDER-RIGHT: #468499 1px solid; BORDER-TOP: #468499 1px solid; COLOR: #182520; FONT-FAMILY: Verdana, Tahoma,  Arial, ms sans serif; FONT-SIZE: 11px; WIDTH: 310'>$Body</textarea>
       </TD>
   </TR>
   <TR><TD colspan=2>&nbsp;</TD></TR>
   <TR><TD colspan=2>
<!--   <a href="javascript:document.form1.submit()"><img  src="/store/btn/btn_send_email2.gif" width="97" height="20" border=0></a>&nbsp; -->
   <a href="javascript:check_field()"  title="send e-mail"><img  src="/store/btn/btn_send_email.gif" width="97" height="20" border=0 alt="send e-mail"></a>&nbsp;
   <a href="javascript:document.form1.reset()" title="reset"><img  src="/store/btn/btn_reset.gif" width="64" height="20" border=0 alt="reset"></a>&nbsp;
   <a href="javascript:self.close()" title="close window"><img  src="/store/btn/btn_close.gif" width="64" height="20" border=0  alt="close window"></a>
</TD></TR>
   </TABLE>
</td>
<td width=\"20\"></td>
<tr>
<tr><td width=\"40\" height=30></td>
    <td colspan=2 width=\"340\">&nbsp;<span style=" COLOR: #1b5665; FONT-SIZE=11px; FONT-FAMILY:  Tahoma, Arial, Helvetica, sans-serif; FONT-WEIGHT: normal; "><font color="#ff0000">*</font> required field<span><br>
    </TD>
  </TR>
</table>

</FORM>
</BODY></HTML>
Browser
}   ##sendermessages


############################################################################
sub db_sender       #05.07.00 8:12  Send email
############################################################################

{

# Get params from 'sender' form
$FirstName = $q->param('FirstName');
$LastName = $q->param('LastName');
$From = $q->param('From');
$To=$q->param('To');
$Copy=$q->param('Copy');
$Body=$q->param('Body');
$_=$Body;    s/\r//g;  $Body=$_;

$check=0;
$Subject="Store messenger";

if (&email_check($From)==0){
  $str_message.= "From: $From - incorrect e-mail address.  ";
  $check=1;
  sender($str_message);
  return;
}

if (&email_check($To)==0){
  $str_message.= "To: $To - incorrect e-mail address.  ";
  $check=2;
  sender($str_message);
  return;
}

if ( $Copy ne '' ) {
     if (&email_check($Copy)==0) {
         $str_message.= "Copy To: $Copy - incorrect  e-mail address.  ";
         $check=3;
         sender($str_message);
         return;
       }
}


if (($FirstName eq '') && ($LastName eq '')) {
   $FirstName ="(name not specified)";
}


$BodyApp="Dear Sir or Madam,

Your associate, $FirstName $LastName, thought you might find the following
information from http://store.com to be interesting and helpful.

Store.com - Satellite Earth Station Eqiupment
$comURL
-------------------------------------------
$Body
-------------------------------------------

You have not been subscribed to any email lists, so there is no need to
unsubscribe. If you feel you have received this message in error, please
contact our customer support department support\@store.com

Sincerely,

Store Customer Sevice";


send_mail($To,$From,$Subject,$BodyApp,"text");
$str_message.= " E-mail to $To has been sent.  ";

if ( $Copy ne '' ) {
    send_mail($Copy,$From,$Subject,$BodyApp,"text");
    $str_message.= " E-mail to $Copy has been sent. ";
}

# empty all fields if everything is ok
$To='';  $Copy='';  $Body=''; $FirstName = ''; $LastName = ''; $From ='';

 sender($str_message);
 return;

}   ##db_sender