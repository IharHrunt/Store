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


if ( $comSender eq 'Sender_one' ) {
    $to=$q->param('to');
    $body_text=$q->param('body_text');
}

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
$AddressStore $CityStore $StateStore $ZipStore $CountryStore
Phone: $PhoneStore
Fax: $FaxStore
E-mail: $EmailStore.
";

# Set 'checked' if setup information is attached to body
if ( $AppendStore eq 'on' ) { $appendStoreChecked="checked";}
# Set 'checked' if you use 'all' mode to send email

if ( $All eq 'on' ) { 
   $allChecked="checked";
   $disabled="disabled";
}
else {
   $allChecked="";
   $disabled="";
}


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

if ( $str_scriptvar==1 ) { 
   $str_scriptvar="document.form1.copy.focus(); document.form1.copy.select();";  
}
else {  
   $str_scriptvar="if (document.form1.to.disabled != true) { document.form1.to.focus(); document.form1.to.select(); } "; 
}

if ( $str_message ne '') {
  $str_scriptvar.="alert('$str_message')";
}


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin (Send Message) </TITLE>
<SCRIPT>
// use this var to miss to validate data before submit
var shiftme=0;

//check if there is file to upload to web-server
function setting_attach() {
    if (document.form1.filename.value == '') {
       alert('Please select file to attach.'); document.form1.filename.focus();  shiftme=0;
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

   if ((document.form1.to.value == '')&&(document.form1.to.disabled == false)) {
     alert("The field \'To:\' can not be empty."); document.form1.to.focus(); document.form1.to.select(); shiftme=0; return;
   }
   if (document.form1.subject.value == '' ) {
     alert("The field \'Subject:\' can not be empty."); document.form1.subject.focus(); document.form1.subject.select(); shiftme=0;  return;
   }
   if (document.form1.body_text.value == '' ) {
      alert("The field \'Body:\' can not be empty."); document.form1.body_text.focus(); document.form1.body_text.select(); shiftme=0;  return; 
   }
   shiftme=1; 
   return;

}

function checkData () {
  if (shiftme == 0) { return false; }
  if (shiftme == 1) { return true; }
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

// select mode: 1-send message 'To:' or according to
// pull-boxes at the bottom of the form
var sendto='';
var sendcopy='';
function clearfields() {
   if (document.form1.All.checked) {
     sendto=document.form1.to.value;
     sendcopy=document.form1.copy.value;
//     document.form1.to.value='SEND EMAIL TO ALL SUBSCRIBERS ';
     document.form1.to.value='';
     document.form1.copy.value='';
     document.form1.to.disabled=true;
     document.form1.copy.disabled=true;
    }
   else  {
     document.form1.to.value=sendto;
     document.form1.copy.value=sendcopy;
     document.form1.to.disabled=false;
     document.form1.copy.disabled=false;

   }
}

function setFocus() {
   $str_scriptvar
}

</SCRIPT></HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl enctype=\"multipart/form-data\"  onSubmit=\"return checkData()\">
<CENTER>
<h3>Send Email Message ( From: $EmailStore )</h3>

<input type=hidden name=code value=\"$code\">
<input type=hidden name=appendbody value=\"$body\">
<input type=hidden name=str_files value=\"$str_files\">

<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\">
<TR><TH width=\"10%\"></TH><TH width=\"90%\"></TH></TR>
<TR><TD align=\"right\">To:</TD>
    <TD align=\"left\"><input type=text name=to value="$to" maxlength=250 size=40 $disabled></TD></TR>
<TR><TD align=\"right\">Copy To:</TD>
    <TD align=\"left\"><input type=text name=copy value="$copy" maxlength=250 size=40 $disabled></TD></TR>
<TR><TD align=\"right\">Subject:</TD>
    <TD align=\"left\"><input type=text name=subject value="$subject" maxlength=50 size=50></TD></TR>
<TR><TD align=\"right\" valign=\"top\">Body:</TD>
    <TD align=\"left\"><TEXTAREA NAME=body_text ROWS=12 COLS=60>$body_text</TEXTAREA></TD></TR>


<TR><TD align=\"right\" valign=\"top\"></TD>
    <TD align=\"left\"><INPUT type=\"checkbox\" name=\"AppendStore\" $appendStoreChecked onClick=\"appendsetup()\"> <font size=2>Swith ON the box to append information from Setup to e-mail\"s body.</font>
    <br><INPUT type=\"checkbox\" name=\"All\" $allChecked onClick=\"clearfields()\"> <font size=2>Switch ON the box to send e-mail to subscribers of Store notifications.</font>
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
&nbsp;Attachment: <input type=\"file\" name=\"filename\" size=40 >
</td>
<td align=left valign=top ><input type=\"submit\" name=\"comSender\" value=\"Attach\"  class=\"input\" onClick=\"setting_attach()\" > <input type=\"submit\" name=\"comSender\" value=\"Remove\" class=\"input\" onClick=\"setting_remove()\">
<br>
$str_select6
</td></tr>
</table>
<BR><BR>
<input type=hidden name=str_files value=\"$str_files\">
<input type=submit name=comSender value=\" Send \" onClick=\"setting_send()\">
<input type=reset name=comSender value=\" Reset \">
</FORM>
$str_list_subscribers
<br><br>
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



# Set default warning message
$str_message="Please select file to attach to email!";
# Get uploaded file with its path
$filename=$q->param(filename);
if ( $filename ne '') {

  if ($filename=~m/^.*(\\|\/)(.*)/) {  $name_attach = $2; }
  else { $name_attach=$filename; }

  # Open file in binary mode on web-server and write it
  open (FILE, ">$path_attach_files"."$name_attach") or $str_message="File $name_attach has not been attached to e-mail!";
  #$name_attach='';
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
  while (($key,$value)= each (%array_mime )) {   if ( $suffix eq $key) { $lookme=1; } }
  if ( $lookme == 0 ){ $str_message="File ($name_attach) must have a proper extension for MIME encode!"; $name_attach='';}
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

# return to 'sender' form with  empty message and array of uploaded files
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
$_=$body_tmp;    s/\r//g;  $body_tmp=$_;

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

  $email_date=get_date();
 $str_list_subscribers="
   <br><br><hr><br>
   <table border='0' width='100%' cellspacing='0' cellpadding='0'>
   <TR><TD align=left><font size=3><b>&nbsp;E-mail Report</b></font></TD>
              <TD align=right><font size=3><b><i>$email_date&nbsp;</i></b></font></TD></tr>
   <TR><TD align=left colspan=2 height=10></TD></tr></table>

   <table border='1' width='100%' cellspacing='2' cellpadding='1'>
    <TR><TH width='3%'><font size=2>n</font></TH>
    <TH width='11%'><font size=2>Account #</font></TH>
    <TH width='20%'><font size=2>First, Last Name</font></TH>
    <TH width='13%'><font size=2>Company</font></TH>
    <TH width='13%'><font size=2>City</font></TH>
    <TH width='13%'><font size=2>Country</font></TH>
    <TH width='25%'><font size=2>E-mail</font></TH>
    </TR>";


  my $sql="SELECT DISTINCT Profile.Email, Profile.Id, Profile.DateCreate, Profile.FirstName, Profile.LastName,
                  Profile.CompanyName, Profile.City, Country.Name
                  From Profile, Country
                  WHERE Country.Id=Profile.Country and  Profile.Status=0 and Profile.Subscriber=1
                  ORDER BY Profile.Id";
  dbexecute($sql);
  $n=0;
  # fetch all record from recordset and send email to each
  while(($All_email, $Id_Account, $DateCreate, $FirstName, $LastName, $Company, $City, $Country) = dbfetch()) {
     # send if email address is not empty
     if ( $All_email ne '' ) {
        # if list of uploaded files is empty start send_mail()
        # else attach() to send email
        if ( $str_files eq '')  {  send_mail($All_email,$from,$subject,$body_tmp,"text"); }
        else { attach($All_email,$from,$subject,$body_tmp, $str_files); }

        $n++;

        ###########################################################
        if ( $Id_Account < 10) { $AccountNumber='000'.$Id_Account; }
        elsif (( $Id_Account > 9)&&( $Id_Account < 100)) { $AccountNumber='00'.$Id_Account; }
        elsif (( $Id_Account > 99)&&( $Id_Account < 1000)) { $AccountNumber='0'.$Id_Account; }
        else { $AccountNumber=$Id_Account; }
        $curDate=$DateCreate;
        $curDate3=substr($curDate, 2 , 2);
        $curDate2=substr($curDate, 5 , 2);
        $curDate1=substr($curDate, 8 , 2);
        $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
        ##########################################################

        $str_list_subscribers.="
          <TR><TD align=center><font size=2>$n</font></TD>
              <TD align=center><font size=2>$AccountNumber</font></TD>
              <TD align=center><font size=2>$FirstName $LastName&nbsp;</font></TD>
              <TD align=center><font size=2>$Company</font></TD>
              <TD align=center><font size=2>$City</font></TD>
              <TD align=center><font size=2>$Country</font></TD>
              <TD align=center><font size=2>$All_email</font></TD></TR>";
     }

  }
  # count sent messages and empty all fields if everything is ok
  if ( $n > 0 ) {
      $str_list_subscribers.="</table>";
      $str_message.= "E-mails have been sent to $n subscribers. E-mail report at the bottom of the page.";
      $to='';  $copy='';  $subject='';  $body_text='';  $AppendStore='';  $All='';  @array_files='';
      sender($str_message);
      return;
    }
  else {
    # Set error message for 'sender' form
    $str_list_subscribers="";
    $str_message.= "E-mail to subscribers cannot be sent. List of subscribers is empty.";
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
     $to='';  $copy='';  $subject='';  $body_text='';  $AppendStore='';  $All='';  @array_files='';
     sender($str_message);
     return;
}

}   ##db_sender