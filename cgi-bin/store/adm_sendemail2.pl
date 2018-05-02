#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_sendemail.pl
#
############################################################################

use CGI;
$q = new CGI;

require 'db.pl';

# set path for the forms of the current script
$pathUrl =$path_cgi.'adm_sendemail.pl';

if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

$code = $q->param('code');
# if $code is not defined then accessdenied
if ( $code eq '' ) { accessdenied(); return ;}
# if $code is not equal data from Password table then accessdenied
my $sql="SELECT Code, Super FROM Passw WHERE Code='$code'";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check ) { accessdenied(); return ; }


# Select form from 'Send message' mode
$comSender = $q->param('comSender');
if    ( $comSender eq 'Sender')    { sender(); }
elsif ( $comSender eq 'Sender_one')    { sender(); }
elsif ( $comSender eq ' Send ')    { db_sender(); }
elsif ( $comSender eq 'Attach')    { attach_file(); }
elsif ( $comSender eq 'Remove')    { remove_file(); }


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
<HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><STRONG>Access Denied.</STRONG></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied



############################################################################
sub sender      #05.07.00 8:03
############################################################################

{
# Get error or successful message for JScript alert
$message=$_[0];
# Get array of files to attach to email
$array_files=$_[1];


if ( $comSender eq 'Sender_one' ) { $to=$q->param('to'); }

# Select information from Setup to attach it to email's body
my $sql="SELECT NameStore, NameDirector, Address, City, State, Zip,
         Country,Phone,Emailstore,Fax FROM Setup";
dbexecute($sql);
($NameStore, $NameDirector, $AddressStore, $CityStore, $StateStore, $ZipStore,
$CountryStore, $PhoneStore, $EmailStore,$FaxStore)=dbfetch();
# Create string to email's body
$body="
$NameDirector
Customer Service Representative

$NameStore
Address: $AddressStore
$CityStore $StateStore  $ZipStore  $CountryStore.
Phone: $PhoneStore
Fax: $FaxStore
E-mail: $EmailStore.
";

# Set 'checked' if setup information is attached to body
if ( $AppendStore eq 'on' ) { $appendStoreChecked="checked";}
# Set 'checked' if you use 'all' mode to send email
if ( $All eq 'on' ) { $allChecked="checked";}


# Create 'type of business' pull-box
my $str_select1="<SELECT NAME=TypeOfBusiness onChange='checkAllbox()'>";
if ( $TypeOfBusiness eq '' ){ $str_select1.="<OPTION SELECTED VALUE=1000>All Types of business</OPTION>";}
else { $str_select1.="<OPTION VALUE=1000>All Types of business</OPTION>";    }
$sql="SELECT Id, Name FROM TypeOfBusiness WHERE Status=0 ORDER BY Name";
dbexecute($sql);
while (( $IdTmp,$Name ) =dbfetch()) {
      if ($IdTmp == $TypeOfBusiness) { $str_select1.="<OPTION SELECTED VALUE=$IdTmp>$Name</OPTION>"; }
      else { $str_select1.="<OPTION VALUE=$IdTmp>$Name</OPTION>"; }
  }
$str_select1.="</SELECT>";

# Create 'States' pull-box
my $str_select2="<select name='State' onchange='country(this.form);'>";
$sql="SELECT Id, Name FROM State  ORDER BY Name";
dbexecute($sql);
while (( $i,$Name ) =dbfetch()) {
    if ($i == 1) { $Name="All States (only US)"; }
    if ( ( $i == 1 ) && ($State eq '') )
       { $str_select2.="<OPTION SELECTED VALUE=1>All States (only US)</OPTION>"; }
    elsif ( $i == $State ) { $str_select2.="<OPTION SELECTED VALUE=$i>$Name</OPTION>"; }
    else { $str_select2.="<OPTION VALUE=$i>$Name</OPTION>"; }
 }
$str_select2.="</SELECT>";

# Create 'County' pull-box
my $str_select3="<select name='Country' onchange='state(this.form);' >";
$sql="SELECT Id, Name FROM Country ORDER BY Id";
dbexecute($sql);
while (( $i,$Name ) =dbfetch()) {
    if ($i == 1) { $Name="All Countries"; }
    if ( ($i == 1) && ($Country eq ''))
      { $str_select3.="<OPTION SELECTED VALUE=1>All Countries</OPTION>"; }
    elsif ($i == $Country) { $str_select3.="<OPTION SELECTED VALUE=$i>$Name</OPTION>"; }
    else { $str_select3.="<OPTION VALUE=$i>$Name</OPTION>"; }
 }
$str_select3.="</SELECT>";

# Create 'Payment terms' pull-box
my $str_select4="<select name='CreditCard' onChange='checkAllbox()' >";
if ( $CreditCard eq ''){ $str_select4.="<OPTION SELECTED VALUE=1000>All Types of Payment</OPTION>"; }
else { $str_select4.="<OPTION VALUE=1000>All Types of Payment</OPTION>"; }
$sql="SELECT Id, Name FROM CreditCard where Status=0 ORDER BY Name";
dbexecute($sql);
while (($IdPaymentTerms, $NamePaymentTerms) =dbfetch()) {
    if ( $IdPaymentTerms eq $CreditCard) { $str_select4.="<OPTION SELECTED VALUE=$IdPaymentTerms>$NamePaymentTerms</OPTION>"; }
    else { $str_select4.="<OPTION VALUE=$IdPaymentTerms>$NamePaymentTerms</OPTION>"; }
}
$str_select4.="</SELECT>";

# Create 'Company Name' pull-box
my $str_select5="<select name='CompanyName' onChange='checkAllbox()'>";
if (( $CompanyName eq '' )||( $CompanyName eq 'AllCompany')) { $str_select5.="<OPTION SELECTED VALUE='AllCompany'>All Companies</OPTION>"; }
else { $str_select5.="<OPTION VALUE='AllCompany'>All Companies</OPTION>"; }
$sql="SELECT Distinct CompanyName FROM Profile Where Status=0 ORDER BY CompanyName";
dbexecute($sql);
while (( $NameTmp ) =dbfetch()) {
    if ( $NameTmp eq $CompanyName ) { $str_select5.="<OPTION selected VALUE='$NameTmp'>$NameTmp</OPTION>"; }
    else { $str_select5.="<OPTION VALUE='$NameTmp'>$NameTmp</OPTION>"; }
 }
$str_select5.="</SELECT>";

# Create pull-box with attached files form @array_files
my $str_files='';
$str_select6="<SELECT multiple NAME='upload_files' SIZE=3>";
if ( $array_files[0] eq ''){
 $str_select6.="<OPTION VALUE='' selected>---no attachments---</OPTION>
                </SELECT>";
}
else {
   my $i=0;
   foreach (@array_files) {
      if ( $i==0 ) { $str_files.=$_; $str_select6.="<OPTION selected VALUE=$i>$_</OPTION>"; }
      else { $str_files.=",".$_; $str_select6.="<OPTION VALUE=$i>$_</OPTION>"; }
      $i++;
  }
  $str_select6.="<OPTION VALUE=''>
  &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
  &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
  &nbsp &nbsp &nbsp &nbsp &nbsp
  &nbsp &nbsp &nbsp</OPTION>";
  $str_select6.="</SELECT>";
}
# Set focus and alert for the form
if ( $str_message ne '') {
    if ( $str_scriptvar==1 ) { $str_scriptvar="document.form1.copy.focus(); document.form1.copy.select();";  }
    else {  $str_scriptvar="document.form1.to.focus(); document.form1.to.select();"; }
    $str_scriptvar.="alert('$str_message')";
}
else {  $str_scriptvar="document.form1.to.focus(); document.form1.to.select();"; }

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin (Send Message) </TITLE>
<SCRIPT>
// use this var to miss to validate data before submit
var shiftme=0;

// Allow to select from pull-box if 'All' check box is checked
function checkAllbox() {

  if (document.form1.All.checked==false) {
     alert('Check box before select data from pull-box !');
     document.form1.State.selectedIndex=0;
     document.form1.Country.selectedIndex=0;
     document.form1.TypeOfBusiness.selectedIndex=0;
     document.form1.CreditCard.selectedIndex=0;
     document.form1.CompanyName.selectedIndex=0;
    }
}

//check if there is file to upload to web-server
function setting_attach() {
    if (document.form1.filename.value == '') {
       alert('Please select file to attach first.'); document.form1.filename.focus();  shiftme=0;
    }
    else {shiftme=1; }
}
// check before submit if there is file to remove
// from list of uploaded files
function setting_remove() {
    var a = document.form1.upload_files.selectedIndex;
    if (document.form1.upload_files.options[a].value == '')  {
       alert('Please select file to remove.');  shiftme=0;
    }
    else {shiftme=1; }
}
// check fields before send email
function setting_send () {
   if (document.form1.to.value != '') {
   if (document.form1.subject.value != '' ) {
   if (document.form1.body_text.value != '' ) {shiftme=1; }
   else { alert('Field Body: can not be empty.'); document.form1.body_text.focus(); document.form1.body_text.select(); shiftme=0; }
   }
   else { alert('Field Subject: can not be empty.'); document.form1.subject.focus(); document.form1.subject.select(); shiftme=0; }
   }
   else { alert('Field To: can not be empty.'); document.form1.to.focus(); document.form1.to.select(); shiftme=0; }
}

function checkData () {
  if (shiftme ==0) { return false; }
  if  (shiftme ==1){ return true; }
}

// Append information to body from Setup
var mainbody='';
function appendsetup() {
   if (document.form1.AppendStore.checked) {
      mainbody =document.form1.body_text.value;
      document.form1.body_text.value=mainbody + document.form1.appendbody.value;
   }
   else { document.form1.body_text.value=mainbody; }
}

// celect mode: 1-send message 'To:' or according to
// pull-boxes at the bottom of the form
var sendto='';
var sendcopy='';
function clearfields() {
   if (document.form1.All.checked) {
     sendto=document.form1.to.value;
     sendcopy=document.form1.copy.value;
     document.form1.to.value='SEND TO ALL CUSTOMERS ';
     document.form1.copy.value='ACCORDING TO PULL-BOXES BELOW ';
    }
   else  {
   document.form1.to.value=sendto;
   document.form1.copy.value=sendcopy;
   document.form1.State.selectedIndex=0;
   document.form1.Country.selectedIndex=0;
   document.form1.TypeOfBusiness.selectedIndex=0;
   document.form1.CreditCard.selectedIndex=0;
   document.form1.CompanyName.selectedIndex=0;
   }
}
// set All States if Country is not USA
// and 'All' check box is checked
function state(f) {
  if (document.form1.All.checked==false) {
     alert('Check box before select data from pull-box !');
     document.form1.Country.selectedIndex=0;
  }
  else {
     if (f.Country.selectedIndex != 1) { f.State.options[0].selected=true; }
  }
}
// set Country equal USA if State is selected
// and 'All' check box is checked
function country(f) {
  if (document.form1.All.checked==false) {
     alert('Check box before select data from pull-box !');
     document.form1.State.selectedIndex=0;
    }
  else {
    f.Country.options[1].selected=true;
   }
}

function setFocus() {
       $str_scriptvar
    }


</SCRIPT></HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\"  onSubmit=\"return checkData()\">
<CENTER>
<h3>Send Email Message ( from $EmailStore )</h3>

<input type=hidden name=code value=\"$code\">
<input type=hidden name=appendbody value=\"$body\">
<input type=hidden name=str_files value=\"$str_files\">

<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\">
<TR><TH width=\"10%\"></TH><TH width=\"90%\"></TH></TR>
<TR><TD align=\"right\">To:</TD>
    <TD align=\"left\"><input type=text name=to value="$to" maxlength=50 size=40></TD></TR>
<TR><TD align=\"right\">Copy To:</TD>
    <TD align=\"left\"><input type=text name=copy value="$copy" maxlength=50 size=40></TD></TR>
<TR><TD align=\"right\">Subject:</TD>
    <TD align=\"left\"><input type=text name=subject value="$subject" maxlength=50 size=50></TD></TR>
<TR><TD align=\"right\" valign=\"top\">Body:</TD>
    <TD align=\"left\"><TEXTAREA NAME=body_text ROWS=12 COLS=60>$body_text</TEXTAREA></TD></TR>
<TR><TD align=\"right\" valign=\"top\"></TD>
    <TD align=\"left\"><INPUT type=\"checkbox\" name=\"AppendStore\" $appendStoreChecked onClick=\"appendsetup()\"> <font size=2>Click Box to append information from Setup to e-mail\"s body.</font>
    </TD></TR>
</TABLE>

<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\" width=\"100%\"\" bgcolor=\"\"#E0E0E0\">
<TR><TH width=\"10%\"></TH><TH width=\"63%\"></TH><TH width=\"27%\"></TH></TR>

<tr><td></td><td><font SIZE=\"1\" face=\"Arial, Helvetica, Condensed\">
Click the "Browse" button to locate the file you need, and select it. The file path will<br>
appear in the attachment field. Next, click "Attach" to attach the selected file to your<br>
message. When you send your message, the attached file is automatically enclosed.
</font>
<br><br>
&nbsp;Attachment:<input type=\"file\" name=\"filename\" size=22 >
</td>
<td align=left valign=top ><input type=\"submit\" name=\"comSender\" value=\"Attach\"  class=\"input\" onClick=\"setting_attach()\" > <input type=\"submit\" name=\"comSender\" value=\"Remove\" class=\"input\" onClick=\"setting_remove()\">
<br>
$str_select6
</td></tr>
</table>

<BR><BR>
<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\">
<TR><TH width=\"10%\"></TH><TH width=\"90%\"></TH></TR>
<TD align=\"right\" valign=\"top\"></TD>
<TD align=\"left\"><INPUT type=\"checkbox\" name=\"All\" $allChecked onClick=\"clearfields()\"> <font size=2>Click Box to send e-mail to all customers according to pull-boxes below.</font>
</TD></TR>
</TABLE>

<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"4\">
<TR><TH width=\"15%\"></TH><TH width=\"25%\"></TH><TH width=\"25%\"></TH><TH width=\"35%\"></TH></TR>
<TR><TD align=\"right\">State:</TD><TD align=\"left\">$str_select2</TD>
    <TD align=\"right\">Type of Business:</TD><TD align=\"left\">$str_select1</TD></TR>
<TR><TD align=\"right\">Country:</TD><TD align=\"left\">$str_select3</TD>
    <TD align=\"right\">Type of Payment:</TD><TD align=\"left\">$str_select4</TD></TR>
</TABLE>
<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"4\">
<TR><TH width=\"15%\"></TH><TH width=\"25%\"></TH><TH width=\"25%\"></TH><TH width=\"35%\"></TH></TR>
<TR><TD align=\"right\">CompanyName:</TD><TD align=\"left\">$str_select5</TD>
    <TD align=\"right\"></TD><TD align=\"left\"></TD></TR>
</TABLE>

<BR>// Add 1)selection of subscribers for emails 2)print list of who email is sending to 3)other options
<BR><BR>
<input type=submit name=comSender value=\" Send \" onClick=\"setting_send()\">
<input type=reset name=comSender value=\" Reset \">
<input type=hidden name=str_files value=\"$str_files\">


</FORM>
<BR>

</BODY></HTML>
Browser
}   ##sendermessages


#<input type=button name=closewin value=\" Close \" onClick=\"self.close()\" >

############################################################################
sub attach_file      #12.09.00 14:09
############################################################################

{
# Get params from 'sender' form
$to=$q->param('to');
$copy=$q->param('copy');
$subject=$q->param('subject');
$body_text=$q->param('body_text');
$AppendStore = $q->param('AppendStore');
$All = $q->param('All');
$State=$q->param('State');
$Country=$q->param('Country');
$TypeOfBusiness=$q->param('TypeOfBusiness');
$CreditCard=$q->param('CreditCard');
$CompanyName=$q->param('CompanyName');


# Set default warning message
$str_message="Please select file to attach to email!";
# Get uploaded file with its path
$filename=$q->param(filename);
if ( $filename ne '') {

$filename=~m/^.*(\\|\/)(.*)/;
# Get file name
$name_attach = $2;

# Open file in binary mode on web-server and write it
open (FILE, ">$path_attach_files"."$name_attach") or die $!;

binmode(FILE);
while(<$filename>){  print FILE ; }
close(FILE);

$str_message='';
# Get extention of the uploaded file
my $where=rindex($name_attach,".");
my $suffix=substr($name_attach,$where+1);
$suffix= uc($suffix);

############# ???? ######################################
# Check if extention of the uploaded file exists in array
# of MIME types for proper coding else return error message
my $lookme=0; # vector var
#while (($key,$value)= each (%array_mime )) {   if ( $suffix eq $key) { $lookme=1; } }
#if ( $lookme == 0 ){ $str_message="File must have a proper extension to encode!"; $name_attach='';}
#########################################################

}

# Get list of uploaded files
$str_files=$q->param('str_files');
@array_files=split(/,/, $str_files);
# Add new uploaded file to the list

my $i=0;
foreach (@array_files) { $i++; }
    $array_files[$i]=$name_attach;

# Return 'sender' form with message and array of uploaded files
sender($str_message, @array_files);


}   ##attach_file



############################################################################
sub remove_file    #19.09.00 10:58   Remove file from list of uploaded files
############################################################################

{

# Get params from 'sender' form
$to=$q->param('to');
$copy=$q->param('copy');
$subject=$q->param('subject');
$body_text=$q->param('body_text');
$AppendStore = $q->param('AppendStore');
$All = $q->param('All');
$State=$q->param('State');
$Country=$q->param('Country');
$TypeOfBusiness=$q->param('TypeOfBusiness');
$CreditCard=$q->param('CreditCard');
$CompanyName=$q->param('CompanyName');

# Get list of file to remove from list of uploaded files
@upload_files=$q->param('upload_files');

# Get list of uploaded files
$str_files=$q->param('str_files');
@array_files_tmp=split(/,/, $str_files);
@array_files;

# remove selected files from list of uploaded files
my $i=0;
my $y=0;
foreach (@array_files_tmp) {
    $remove_item=0;
    foreach (@upload_files) {  if ( $y == $_ ) { $remove_item=1; }  }
    if ( $remove_item==0) { $array_files[$i]=$array_files_tmp[$y]; $i++; }
    $y++;
}

# return to 'sender' form with  empty message and
#array of uploaded files
sender('', @array_files);

}   ##remove_file


############################################################################
sub db_sender       #05.07.00 8:12  Send email
############################################################################

{

# Get params from 'sender' form

$to=$q->param('to');
$copy=$q->param('copy');
$subject=$q->param('subject');
$body_text=$q->param('body_text');
$body_tmp=$body_text;
$AppendStore = $q->param('AppendStore');
$All = $q->param('All');

# Get email address of the Store from Setup
my $sql="SELECT Emailstore FROM Setup";
dbexecute($sql);
$from = dbfetch();

# Get list of uploaded files
$str_files=$q->param('str_files');
@array_files=split(/,/, $str_files);
$str_scriptvar=0;
$str_message='';
$send='yes';

# Send message according to pull-boxes at the bottom of the form
if ( $All eq 'on' ){

  # Set string for $sql accoring to data from pull-box
  # otherwise set emty string
  # Select State
  $State=$q->param('State');
  $StateQuery='';
  if ( $State != 1) { $StateQuery= " and State='".$State."'";  }
  # Select Country
  $Country=$q->param('Country');
  $CountryQuery='';
  if ( $Country != 1) { $CountryQuery= " and Country='".$Country."'";  }
  # Select Type Of BusinessQuery
  $TypeOfBusiness=$q->param('TypeOfBusiness');
  $TypeOfBusinessQuery='';
  if ( $TypeOfBusiness != 1000) { $TypeOfBusinessQuery= " and TypeOfBusiness=".$TypeOfBusiness;  }
  # Select Payment terms
  $CreditCard=$q->param('CreditCard');
  $CreditCardQuery='';
  if ( $CreditCard != 1000) { $CreditCardQuery= " and PaymentTerms=".$CreditCard;  }
  # Select Company name
  $CompanyName=$q->param('CompanyName');
  $CompanyNameQuery='';
  if ( $CompanyName ne 'AllCompany') { $CompanyNameQuery= " and CompanyName='".$CompanyName."'"; }

  my $sql="SELECT email From Profile WHERE Status=0 $CompanyNameQuery $StateQuery  $CountryQuery
                  $TypeOfBusinessQuery  $CreditCardQuery    ";
  dbexecute($sql);
  $n=0;
  # fetch all record from recordset and send email to each
  while(($All_email) = dbfetch()) {
     # send if email address is not empty
     if ( $All_email ne '' ) {
        # if list of uploaded files is empty start send_mail()
        # else attach() to send email
        if ( $str_files eq '')  {  send_mail($All_email,$from,$subject,$body_tmp,"text"); }
        else { attach($All_email,$from,$subject,$body_tmp, $str_files); }
     }
     $n++;
  }
  # count sent messages and empty all fields if everything is ok
  if ( $n > 0 ) {
      $str_message.= "E-mail to customers ( $n ) according to your choice has been sent.";
      $to='';  $copy='';  $subject='';  $body_text='';
      $AppendStore='';  $All='';  $State='';  $Country='';
      $TypeOfBusiness='';  $CreditCard='';  $CompanyName='';
      @array_files='';
      sender($str_message);
      return;
    }
  else {
    # Set error message for 'sender' form
    $str_message.= "E-mail to customers according to your choice cannot be sent. You have empty email list. Select other variants in pull-boxes at bottom of the window.";
    sender($str_message);
    return;
  }

}
else {
# Send message according to 'To:' and 'Copy To:'
    # Return to 'sender' if email address in field 'To:'
    # is incorrect
    if (&email_check($to)==0){
      $str_message.= "TO: $to - incorrect e-mail address.  ";
      sender($str_message);
      return;
    }
    if ( $copy ne '' ) {
       # If field 'Copy To:' is not empty and email address
       # in it is incorrect return to 'sender' form
       if (&email_check($copy)==0) {
         $str_message.= "COPY TO: $copy - incorrect  e-mail address.  ";
         $str_scriptvar=1;
         sender($str_message);
         return;
       }
     }
     # if list of uploaded files is empty start send_mail()
     # else attach() to send email
     if ( $str_files eq '')  {  send_mail($to,$from,$subject,$body_tmp,"text"); }
     else { attach($to,$from,$subject,$body_tmp, $str_files); }
     $str_message.= "OK. E-mail to $to has been sent.";

     if ( $copy ne '' ) {
        # if list of uploaded files is empty start send_mail()
        # else attach() to send email
        if ( $str_files eq '')  {  send_mail($copy,$from,$subject,$body_tmp,"text"); }
        else {attach($copy,$from,$subject,$body_tmp, $str_files); }
        $str_message.= " E-mail to $copy has been sent.  ";
     }
     # empty all fields if everything is ok
     $to='';  $copy='';  $subject='';  $body_text='';
     $AppendStore='';  $All='';  $State='';  $Country='';
     $TypeOfBusiness='';  $CreditCard='';  $CompanyName='';
     @array_files='';
     sender($str_message);
     return;
}

}   ##db_sender