#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm.pl
#
############################################################################

use CGI;
$q = new CGI;

require 'db.pl';

my $pathUrl =$pathWeb.'adm_2.pl';

if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

#### Check access to adm.pl ####
$code = $q->param('code');
# if $code is not defined then accessdenied
if ( $code eq '' ) { accessdenied(); return ;}
# if $code is not equal data from Passw table then accessdenied
my $sql="SELECT Code, Super FROM Passw WHERE Code='$code'";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check ) { accessdenied(); return ; }


# Select form from Account mode
$comAccount = $q->param('comAccount');
if ( $comAccount eq 'Account'     ) { accounttype(); }
elsif ( $comAccount eq '  Cancel  '   ) { accounttype(); }
elsif ( $comAccount eq 'Add Account Type' ) { edit_accounttype(); }
elsif ( $comAccount eq 'Edit_Account') { edit_accounttype(); }
elsif ( $comAccount eq '  Insert  ') { dbedit_accounttype(); }
elsif ( $comAccount eq '  Update  ') { dbedit_accounttype(); }
elsif ( $comAccount eq '  Delete  ') { dbedit_accounttype(); }


# Select form from SubAccount mode
$comSubAccount = $q->param('comSubAccount');
if ( $comSubAccount eq '  Cancel  '   ) { accounttype(); }
elsif ( $comSubAccount eq 'Add Type of Payment' ) { edit_subaccounttype(); }
elsif ( $comSubAccount eq 'Edit_SubAccount') { edit_subaccounttype(); }
elsif ( $comSubAccount eq '  Insert  ') { dbedit_subaccounttype(); }
elsif ( $comSubAccount eq '  Update  ') { dbedit_subaccounttype(); }
elsif ( $comSubAccount eq '  Delete  ') { dbedit_subaccounttype(); }


# Select form from Typeof Available mode
$comTypeOfAvailable = $q->param('comTypeOfAvailable');
if ( $comTypeOfAvailable eq 'TypeOfAvailable'   ) { typeofavailable(); }
elsif ( $comTypeOfAvailable eq '  Cancel  '       ) { typeofavailable(); }
elsif ( $comTypeOfAvailable eq 'Add Item') { edit_typeofavailable(); }
elsif ( $comTypeOfAvailable eq 'Edit_TypeOfAvailable' ) { edit_typeofavailable(); }
elsif ( $comTypeOfAvailable eq '  Insert  ') { dbedit_typeofavailable(); }
elsif ( $comTypeOfAvailable eq '  Update  ') { dbedit_typeofavailable(); }
elsif ( $comTypeOfAvailable eq '  Delete  ') { dbedit_typeofavailable(); }


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store Admin</TITLE>
<HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><STRONG>Access Denied.</STRONG></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied


############################################################################
sub accounttype      #19.02.2000
############################################################################

{

my $str_message=$_[0]; # Get 'successful' message

my $str_table="<table border='1' width='75%' cellspacing='2' cellpadding='0'>
            <TR BGCOLOR='silver'>
            <TH width='5%' ><FONT size=3> N </FONT></TH>
            <TH width='32%'><FONT size=3> Account Type</FONT></TH>
            <TH width='6%'><FONT size=3> Level</FONT></TH>
            <TH width='32%'><FONT size=3> Type of Payment </FONT></TH></TR>";


my $sql="SELECT Id, Name, Level FROM AccountType  WHERE Status=0 ORDER BY Level ";
dbexecute($sql);

my $n=1;
my $pathCategory='';
while (($Id,$Name, $Level) =dbfetch()) {

  $pathAccount=$pathUrl."?comAccount=Edit_Account&Id=$Id&code=$code";
  $str_table.="<TR><TD align='center'><FONT size=3>$n</FONT></TD>
               <TD align='left'><a href='".$pathAccount."'>
               <FONT size=3>$Name</FONT></a></TD>
               <TD align='center'><FONT size=3>$Level</FONT></TD>
               <TD align='left'>";


  $sql="SELECT SubAccountType.Id, SubAccountType.AccountType, SubAccountType.CreditCard, CreditCard.Name
        FROM SubAccountType, CreditCard
        WHERE SubAccountType.AccountType=$Id and SubAccountType.Status=0 and SubAccountType.CreditCard = CreditCard.Id";

  $cursor1=$dbh->prepare($sql);
  $cursor1->execute;
  $str_subaccounttype='';
    while (($Id, $AccountType, $CreditCard, $Name) =$cursor1->fetchrow_array) {
       $pathSubAccount=$pathUrl."?comSubAccount=Edit_SubAccount&Id=$Id&code=$code";
       $str_subaccounttype.="<a href='".$pathSubAccount."'><FONT size=3>$Name</FONT></a><BR>";
  }
  if ( $str_subaccounttype eq '' ) { $str_subaccounttype="&nbsp"; }
  $str_table.=$str_subaccounttype."</TD></TR>";
  $n++;
}
$str_table.="</Table>";

# Set Warning message if the table is empty
if ($n==1) { $str_table="The table is empty."; }


#HTML
print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<FORM METHOD='POST' ACTION=$pathUrl>
<CENTER>
<H3>Account Types List</H3>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
<input type=submit name=comAccount value='Add Account Type' > <input type=submit name=comSubAccount value='Add Type of Payment' >
</CENTER></FORM></BODY></HTML>
Browser
}   ##accounttype


############################################################################
sub edit_accounttype      #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];

$Id=$q->param('Id');
#if ( $comAccount eq 'Edit_Account') {
if (( $Id ne '' )&&( $comAccount ne '  Back  ')&&( $comAccount ne ' Back '))  {
  $sql="SELECT Id, Name, Level FROM AccountType  WHERE Id=$Id and Status=0 ORDER BY Level ";
  dbexecute($sql);
  ($Id,$Name, $Level ) =dbfetch();
 }

# Set button and title for the form
my $str='';
my $str_button='';
if (( $comAccount eq '  Back  ')||( $comAccount eq 'Edit_Account'))  {
  # Update and Delete record
  $str="Modify";
  $str_button="<input type=submit name=comAccount value='  Update  ' > ";
  $str_button.="<input type=button name=comAccount value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comAccount eq 'Add Account Type')||( $comAccount eq ' Back ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comAccount value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comAccount value='  Cancel  ' onClick='backform2()'>";

# Set up alert with error message
if ( $str_message ne '' ) {  $str_scriptvar="alert('$str_message');" ; }

$_=$Name;       s/\\//g;  s/\"/&quot;/g; $Name=$_;
$_=$Description;       s/\\//g;  s/\"/&quot;/g; $Description=$_;


print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<TITLE>Admin</TITLE>
<SCRIPT>
// use it for button 'Cancel' in order not to validate fields.
function backform2 () {
   document.form2.submit()
}
//use it for button 'Delete' in order not to validate fields
// and set up confirmation before deleting the record
function backform3 () {
 //  if (confirm('Delete this record?')) { document.form3.submit(); }
     alert(" You are not allowed to delete the record!");

}

// validate fiels before submit
function checkData () {


 if (document.form1.Name.value.length < 1)
   { alert(" The field \'Account Type Name\' cannot be empty."); document.form1.Name.focus();  document.form1.Name.select(); return false }

 if (document.form1.Level.value.length < 1)
   { alert(" The field \'Level\' cannot be empty."); document.form1.Level.focus();  document.form1.Level.select(); return false }

 else {
      return true
   }
}

// set focus on Load or error
function setFocus() {
    document.form1.Name.focus();
    document.form1.Name.select();
    $str_scriptvar
    }

</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comAccount value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comAccount value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
 <CENTER>
<H3>$str Account Type</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\">Name (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\"
                    maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">Level (required):</TD>
<TD align=\"left\"><input type=text name=Level value=\"$Level\"
                    maxlength=1 size=1></TD></TR>

</Table>

<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">

$str_button
</CENTER></FORM>
</BODY></HTML>
Browser
}   ##edit_accounttype


############################################################################
sub dbedit_accounttype        #19.02.2000 9:53
############################################################################
{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');              # Get Id of the selected record
$Name=$q->param('Name');          # Get Category name
$Level=$q->param('Level');

$_=$Name;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Name=$_;
$str_message='';

# Insert
if ( $comAccount eq '  Insert  ') {

  $sql="SELECT Id FROM AccountType  WHERE Status=0 and Level=$Level";
  dbexecute($sql);
  ($Id_Check) =dbfetch();

   if ( !defined $Id_Check ) {
     $sql="INSERT INTO AccountType (Name,Status,Level) VALUES ('$Name',0, $Level)";
     if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>";  }
     else { $str_message= "The record has not been inserted !"; $comAccount=' Back '; }
   }
   else {
     $str_message= "The record has not been inserted ! You have another Account Type with the same Level."; $comAccount=' Back ';
   }
}

# Update
elsif ( $comAccount eq '  Update  ') {

  $sql="SELECT Id FROM AccountType  WHERE Status=0 and Id<>$Id and Level=$Level";
  dbexecute($sql);
  ($Id_Check) =dbfetch();

   if ( !defined $Id_Check ) {
     $sql="UPDATE AccountType SET Name='$Name', Level='$Level' WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
     else { $str_message= "The record has not been updated !"; $comAccount='  Back  '; }
   }
   else {
     $str_message= "The record has not been updated ! You have another Account Type with the same Level.";  $comAccount='  Back  ';
   }
}

# Delete ( Check before if you have product with this Category)
elsif( $comAccount eq '  Delete  ') {

      $sql="UPDATE AccountType SET Status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully ! <P>"; }
      else  { $str_message= "The record cannot be deleted ! "; $comAccount='  Back  ';}
   }

# Select form to continue on error or success
if (( $comAccount eq ' Back ')||( $comAccount eq '  Back  '))
  { edit_accounttype($str_message); }
else
  { accounttype($str_message); }

}   ##dbedit_accounttype




############################################################################
sub edit_subaccounttype      #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get selected Category
$Id=$q->param('Id');
my $str_disabled='';
my $str_hidden='';
#if (  $comSubAccount eq 'Edit_SubAccount')  {
if (( $Id ne '' )&&( $comSubAccount ne '  Back  ')&&( $comSubAccount ne ' Back '))  {
  $sql="SELECT Id, AccountType, CreditCard  FROM SubAccountType  WHERE  Id=$Id and Status=0";
  dbexecute($sql);
  ($Id, $AccountType, $CreditCard) =dbfetch();
  $str_disabled='DISABLED';
  $str_hidden="<input type=hidden name=AccountType value='$AccountType'>";
 }

my $str_select1="<SELECT NAME=AccountType $str_disabled>";
$str_select1.="<OPTION VALUE=0>-- Select Account Type --";
$sql="SELECT Id, Name FROM AccountType WHERE Status=0 ORDER BY Level";
dbexecute($sql);
while (( $IdTmp,$NameTmp ) =dbfetch()) {
  if ( $IdTmp==$AccountType ) { $str_select1.="<OPTION SELECTED VALUE=$IdTmp >$NameTmp"; }
  else  { $str_select1.="<OPTION VALUE=$IdTmp>$NameTmp"; }
  }
$str_select1.="</SELECT>";


my $str_select2="<SELECT NAME=CreditCard>";
$str_select2.="<OPTION VALUE=0>-- Select Type of Payment --";
$sql="SELECT Id, Name FROM CreditCard WHERE Status=0 ORDER BY Name";
dbexecute($sql);
while (( $IdTmp,$NameTmp ) =dbfetch()) {
  if ( $IdTmp==$CreditCard ) { $str_select2.="<OPTION SELECTED VALUE=$IdTmp >$NameTmp"; }
  else  { $str_select2.="<OPTION VALUE=$IdTmp>$NameTmp"; }
  }
$str_select2.="</SELECT>";



# Set buttons and title message for the form
my $str_button='';
my $str='';
if (( $comSubAccount eq '  Back  ')||( $comSubAccount eq 'Edit_SubAccount')) {
  # Update or Delete record
  $str="Modify";
  $str_button="<input type=submit name=comSubAccount value='  Update  ' > ";
  $str_button.="<input type=button name=comSubAccount value='  Delete  ' onClick='backform3()'> ";
}
elsif (( $comSubAccount eq 'Add Type of Payment')||( $comSubAccount eq ' Back ')) {
  # Add new record
  $str= "Insert New";
  $str_button="<input type=submit name=comSubAccount value='  Insert  ' >  ";
}
$str_button.="<input type=button name=comSubAccount value='  Cancel  ' onClick='backform2()'>";

# Set up error message for Jscript alert
if ( $str_message ne '' ) {  $str_scriptvar="alert('$str_message');" ; }


print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<TITLE>Admin</TITLE>
<SCRIPT>
// use it for button 'Cancel' in order not to validate fields.
function backform2 () {
   document.form2.submit()
}
//use it for button 'Delete' in order not to validate fields
// and set up confirmation before deleting the record
function backform3 () {
  if (confirm('Delete this record?')) { document.form3.submit(); }
}
// validate forms fiels before submit
function checkData () {

     if (document.form1.AccountType.selectedIndex == 0) {
        alert("The field \'Account Type\' cannot be empty.");  document.form1.AccountType.focus();  return false;
      }
     if (document.form1.CreditCard.selectedIndex == 0) {
        alert("The field \'Type of Payment\' cannot be empty.");  document.form1.CreditCard.focus();  return false;
      }
     return true;
}
// Set up focus on Load or error
function setFocus() {
   document.form1.AccountType.focus();
   $str_scriptvar;
 }

</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">

<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comSubAccount value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comSubAccount value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
 <CENTER>
<H3>$str Type of Payment.</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"3\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\">Account Type (required):</TD><TD align=\"left\">$str_select1</TD></TR>
<TR><TD align=\"right\">Type of Payment (required):</TD><TD align=\"left\">$str_select2</TD></TR>
</Table>

<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
$str_hidden

$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_subaccounttype


############################################################################
sub dbedit_subaccounttype        #19.02.2000 9:53
############################################################################
{
$str_message='';
$Id=$q->param('Id');
$AccountType=$q->param('AccountType');
$CreditCard =$q->param('CreditCard');


if ( $comSubAccount eq '  Insert  ') {
  $sql="INSERT INTO SubAccountType (AccountType, CreditCard, Status) VALUES ($AccountType, $CreditCard, 0)";
  if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>";  }
  else { $str_message= "The record has not been inserted !"; $comSubAccount=' Back '; }
}

elsif ( $comSubAccount eq '  Update  ')  {
     $sql="UPDATE SubAccountType SET AccountType=$AccountType, CreditCard=$CreditCard WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
     else { $str_message= "The record has not been updated !"; $comSubAccount='  Back  '; }
}

elsif( $comSubAccount eq '  Delete  ') {
      $sql="UPDATE SubAccountType SET Status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully ! <P>"; }
      else  { $str_message= "The record cannot be deleted ! "; $comSubAccount='  Back  ';}
}

# Select form to continue on error or success
if (( $comSubAccount eq ' Back ')||( $comSubAccount eq '  Back  '))
  { edit_subaccounttype($str_message); }
else
  { accounttype($str_message); }


}   ##dbedit_subaccounttype


############################################################################
sub typeofavailable  #19.02.2000    
############################################################################

{
my $str_message=$_[0]; # Get 'successful' mesage

# Create table's header.
my $str_table="<table border='1' width='75%' cellspacing='2' cellpadding='0'>
   <TR BGCOLOR='silver'><TH width='10%' >N</TH><TH width='65%'>Name</TH></TR>";

# Select all 'alive' type of product availability
my $sql="SELECT Id, Name FROM TypeOfAvailable WHERE Status=0 ORDER BY Id ";
dbexecute($sql);
$n=1;
my $pathTypeOfAvailable='';
# fetch all records from recordset to format table
while (($Id,$Name) =dbfetch()) {

   $pathTypeOfAvailable=$pathUrl."?comTypeOfAvailable=Edit_TypeOfAvailable&Id=$Id&code=$code";
   $str_table.="<TR><TD align='center'><a href='".$pathTypeOfAvailable."'><FONT size='3'>$n</FONT></a></TD>
             <TD align='left'>$Name</TD></TR>";
  $n++;
 }
$str_table.="</Table>";

# Set up warning message if the table is empty
if ($n==1) { $str_table="The table is empty."; }


#HTML
print <<Browser;
Content-type: text/html\n\n
<HTML>
<TITLE>Admin</TITLE>
<HEAD>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
</HEAD>

<BODY BGCOLOR='#CCCCCC'>
<FORM METHOD='POST' ACTION=$pathUrl>
<CENTER>
<H3> Product Availability</H3>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
<input type=submit name=comTypeOfAvailable value='Add Item' >
</CENTER></FORM></BODY></HTML>
Browser
}   ##typeofavailable

############################################################################
sub edit_typeofavailable       #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];

my $Id=$q->param('Id');
if (( $Id ne '' )&&( $comTypeOfAvailable ne '  Back  ')&&( $comTypeOfAvailable ne ' Back '))  {

   $sql="SELECT Id, Name FROM TypeOfAvailable  WHERE  Id=$Id and Status=0";
   dbexecute($sql);
   ($Id,$Name) =dbfetch();
 }

# Set up button and title message for the form
my $str='';
my $str_button='';
if (( $comTypeOfAvailable eq '  Back  ')||( $comTypeOfAvailable eq 'Edit_TypeOfAvailable')) {
  # Update or delete record
  $str="Modify";
  $str_button="<input type=submit name=comTypeOfAvailable value='  Update  ' > ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comTypeOfAvailable value='  Update  ' > ";
  $str_button.="<input type=button name=comTypeOfAvailable value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comTypeOfAvailable eq 'Add Item')||( $comTypeOfAvailable eq ' Back ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comTypeOfAvailable value='  Insert  ' >  ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comTypeOfAvailable value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comTypeOfAvailable value='  Cancel  ' onClick='backform2()'>";

# Set up alert with error message for Jscript
if ( $str_message ne '' ) {  $str_scriptvar="alert('$str_message');" ; }

$_=$Name;       s/\\//g;  s/\"/&quot;/g; $Name=$_;


print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<TITLE>Admin</TITLE>
<SCRIPT>
// use it for button 'Cancel' in order not to validate fields.
function backform2 () {
   document.form2.submit()
}
//use it for button 'Delete' in order not to validate fields
// and set up confirmation before deleting the record
function backform3 () {
   if (confirm('Delete this record ?')) { document.form3.submit(); }
}
// validate form's fiels before submit
function checkData () {
   if (document.form1.Name.value != '')  {return true }
   else { alert("The field \'Name\' cannot be empty.");
    document.form1.Name.focus();
    return false }
}
// set up focus on Load or error
function setFocus() {
    document.form1.Name.focus();
    document.form1.Name.select();
    $str_scriptvar
    }

</SCRIPT>
</HEAD>

<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comTypeOfAvailable value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comTypeOfAvailable value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
<CENTER>
<H3>$str Record</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"30%\"></TH><TH width=\"70%\"></TH></TR>
<TR><TD align=\"right\"> Name (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\"
maxlength=50 size=50></TD></TR></Table>

<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_typeofavailable


############################################################################
sub dbedit_typeofavailable       #19.02.2000 9:53
############################################################################

{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');      # Get Id of the selected record
$Name=$q->param('Name');  # Get name
$_=$Name;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Name=$_;

$str_message='';          # error or successful message

# Insert
if ( $comTypeOfAvailable eq '  Insert  ')  {

   $sql="INSERT INTO TypeOfAvailable (Name, Status) VALUES ('$Name', 0)";
   if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>"; }
   else  {  $str_message= "The record  has not been inserted !"; $comTypeOfAvailable=' Back '; }
 }

# Update
elsif ( $comTypeOfAvailable eq '  Update  ') {
  $sql="SELECT id FROM TypeOfAvailable WHERE Id=$Id and Status=0";
  dbexecute($sql);
  my ($Id_check)=dbfetch();
  if ( defined $Id_check ) {

     $sql="UPDATE TypeOfAvailable SET Name='$Name' WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record  has been  updated successfully !<P>"; }
     else { $str_message= "The record  has not been updated !"; $comTypeOfAvailable='  Back  '; }
    }
  else  { $str_message= "The record was deleted another user !<P>"; }
}

# Delete ( Check before if you have Product with this type )
elsif( $comTypeOfAvailable eq '  Delete  ') {


   $sql="SELECT id FROM Product WHERE TypeOfAvailable=$Id and Status<>1";
   dbexecute($sql);
   my ($Id_check)=dbfetch();
   if ( !defined $Id_check )  {

      $sql="UPDATE TypeOfAvailable SET status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully !<P> "; }
      else  { $str_message= "The record cannot be deleted ! ";$comTypeOfAvailable='  Back  '; }
     }
   else  { $str_message= "The record cannot be deleted! You have Product with this item."; $comTypeOfAvailable='  Back  ';}
 }

# Select form to continue on error or success
if (( $comTypeOfAvailable eq ' Back ')||( $comTypeOfAvailable eq '  Back  '))
  { edit_typeofavailable($str_message); }
else
  { typeofavailable($str_message); }

}   ##dbedit_typeofavailable

