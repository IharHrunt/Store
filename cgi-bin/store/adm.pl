#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm.pl
#
############################################################################

use CGI;
$q = new CGI;
require 'db.pl';

# set path usual and secury for the forms of the current script
my $pathUrl =$path_cgi.'adm.pl';
my $pathUrlSec =$path_cgiSec.'adm.pl';
my $pathUrlProduct =$path_cgi.'adm_product.pl';
my $pathUrlSendEmail =$path_cgi.'adm_sendemail.pl';
my $pathUrlAccount =$path_cgi.'adm_account.pl';
my $pathUrlTransactions = $path_cgi.'adm_trans.pl';

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


# Select form from Category mode
$comCategory = $q->param('comCategory');
if ( $comCategory eq 'Category'     ) { category(); }
elsif ( $comCategory eq '  Cancel  '   ) { category(); }
elsif ( $comCategory eq 'Add Category' ) { edit_category(); }
elsif ( $comCategory eq 'Edit_Category') { edit_category(); }
elsif ( $comCategory eq '  Insert  ') { dbedit_category(); }
elsif ( $comCategory eq '  Update  ') { dbedit_category(); }
elsif ( $comCategory eq '  Delete  ') { dbedit_category(); }


# Select form from Subcategory mode
$comSubcategory = $q->param('comSubcategory');
if ( $comSubcategory eq '  Cancel  '   ) { category(); }
elsif ( $comSubcategory eq 'Add Subcategory' ) { edit_subcategory(); }
elsif ( $comSubcategory eq 'Edit_Subcategory') { edit_subcategory(); }
elsif ( $comSubcategory eq '  Insert  ') { dbedit_subcategory(); }
elsif ( $comSubcategory eq '  Update  ') { dbedit_subcategory(); }
elsif ( $comSubcategory eq '  Delete  ') { dbedit_subcategory(); }


# Select form from Manufacturer mode
$comManufacturer = $q->param('comManufacturer');
if ( $comManufacturer eq 'Manufacturer'     ) { manufacturer(); }
elsif ( $comManufacturer eq '  Cancel  '       ) { manufacturer(); }
elsif ( $comManufacturer eq 'Add Manufacturer' ) { edit_manufacturer(); }
elsif ( $comManufacturer eq 'Edit_Manufacturer') { edit_manufacturer(); }
elsif ( $comManufacturer eq '  Insert  ') { dbedit_manufacturer(); }
elsif ( $comManufacturer eq '  Update  ') { dbedit_manufacturer(); }
elsif ( $comManufacturer eq '  Delete  ') { dbedit_manufacturer(); }


# Select form from Typeof Business mode
$comTypeOfBusiness = $q->param('comTypeOfBusiness');
if ( $comTypeOfBusiness eq 'TypeOfBusiness'   ) { typeofbusiness(); }
elsif ( $comTypeOfBusiness eq '  Cancel  '       ) { typeofbusiness(); }
elsif ( $comTypeOfBusiness eq 'Add Type of Business') { edit_typeofbusiness(); }
elsif ( $comTypeOfBusiness eq 'Edit_TypeOfBusiness' ) { edit_typeofbusiness(); }
elsif ( $comTypeOfBusiness eq '  Insert  ') { dbedit_typeofbusiness(); }
elsif ( $comTypeOfBusiness eq '  Update  ') { dbedit_typeofbusiness(); }
elsif ( $comTypeOfBusiness eq '  Delete  ') { dbedit_typeofbusiness(); }


# Select form from Payment term mode
$comCreditCard = $q->param('comCreditCard');
if ( $comCreditCard eq 'CreditCard'   ) { creditcard(); }
elsif ( $comCreditCard eq '  Cancel  '       ) { creditcard(); }
elsif ( $comCreditCard eq 'Add Type of Payment') { edit_creditcard(); }
elsif ( $comCreditCard eq 'Edit_CreditCard' ) { edit_creditcard(); }
elsif ( $comCreditCard eq '  Insert  ') { dbedit_creditcard(); }
elsif ( $comCreditCard eq '  Update  ') { dbedit_creditcard(); }
elsif ( $comCreditCard eq '  Delete  ') { dbedit_creditcard(); }


# Select form from Password mode
$comPassw = $q->param('comPassw');
if ( $comPassw eq 'Passw'       ) { password(); }
elsif ( $comPassw eq '  Cancel  '  ) { password(); }
elsif ( $comPassw eq 'Create New Administrator') { edit_password(); }
elsif ( $comPassw eq 'Edit_Passw'  ) { edit_password(); }
elsif ( $comPassw eq '  Create  '  ) { dbedit_password(); }
elsif ( $comPassw eq '  Update  '  ) { dbedit_password(); }
elsif ( $comPassw eq '  Delete  '  ) { dbedit_password(); }
elsif ( $comPassw eq 'Logout'      ) { logout(); }


# Select form from Setup mode
$comSetup = $q->param('comSetup');
if ( $comSetup eq 'Setup'       ) { setup(); }
elsif ( $comSetup eq '  Update  '  ) { edit_setup(); }
elsif ( $comSetup eq '  Cancel  '  ) { main(); }

# Start main page if all params are not defined
if (( $comCategory eq '' )&&( $comSubcategory eq '' )
      &&( $comManufacturer eq '' )&&( $comTypeOfBusiness eq '' )
      &&( $comCreditCard eq '' )&&( $comPassw eq '' )
      &&( $comSetup eq '' )) { main(); }


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
sub main        #17.02.2000 15:39     Create form with menu
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Store Admin</TITLE>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<CENTER>
<br><br><br><br><br><br>
<H2> Welcome to Store Admin </H2>
<font size=1>� BIP Corporation, 2005. All right reserved</font>
</CENTER></BODY></HTML>
Browser
}   ##main


############################################################################
sub category      #19.02.2000    Create form with Category&Subcategory lists
############################################################################

{

my $str_message=$_[0]; # Get 'successful' message

# Create header for Category table
my $str_table="<table border='1' width='75%' cellspacing='2' cellpadding='0'>
            <TR BGCOLOR='silver'>
            <TH width='5%' ><FONT size=3> N </FONT></TH>
            <TH width='35%'><FONT size=3> Category </FONT></TH>
            <TH width='35%'><FONT size=3> Subcategory </FONT></TH></TR>";

# Select all 'alive' categories from the database table
my $sql="SELECT Id, Name FROM Category  WHERE Status=0 ORDER BY Name ";
dbexecute($sql);

my $n=1;
my $pathCategory='';
# fetch all records from recordset to format table with categories
while (($Id,$Name) =dbfetch()) {

  # Set up link to update or delete this Category
  $pathCategory=$pathUrl."?comCategory=Edit_Category&Id=$Id&code=$code";
  # Format Category table
  $str_table.="<TR><TD align='center'><FONT size=3>$n</FONT></TD>
               <TD align='left'><a href='".$pathCategory."'>
               <FONT size=3>$Name</FONT></a></TD>
               <TD align='left'>";

  # Select list of Subcategories for the current Category
  $sql="SELECT Id, Name,Category FROM Subcategory  WHERE Status=0 ORDER BY Name ";
  # Create new cursor to keep recordset of Subcategories
  $cursor1=$dbh->prepare($sql);
  $cursor1->execute;
  $str_subcategory='';
  # fetch all records from recordset to format table with subcategories
  while (($key,$value,$source) =$cursor1->fetchrow_array) {
     if ( $Id == $source ) {
       # Set up link to update or delete this SubCategory
       $pathSubcategory=$pathUrl."?comSubcategory=Edit_Subcategory&Id=$key&code=$code";
       $str_subcategory.="<a href='".$pathSubcategory."'><FONT size=3>$value</FONT></a><BR>";
    }
  }
  if ( $str_subcategory eq '' ) { $str_subcategory="&nbsp"; }
  $str_table.=$str_subcategory."</TD></TR>";
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
<H3>Categories and Subcategories List</H3>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
<input type=submit name=comCategory value='Add Category' >
<input type=submit name=comSubcategory value='Add Subcategory' >
</CENTER></FORM></BODY></HTML>
Browser
}   ##category


############################################################################
sub edit_category      #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get Id of the selected category
$Id=$q->param('Id');
if (( $Id ne '' )&&( $comCategory ne '  Back  ')&&( $comCategory ne ' Back '))  {
  # Select data for this category
  $sql="SELECT Id, Name, Description FROM Category  WHERE  Id=$Id and Status=0";
  dbexecute($sql);
  ($Id,$Name, $Description ) =dbfetch();
 }

# Set button and title for the form
my $str='';
my $str_button='';
if (( $comCategory eq '  Back  ')||( $comCategory eq 'Edit_Category'))  {
  # Update and Delete record
  $str="Modify";
  $str_button="<input type=submit name=comCategory value='  Update  ' > ";
  $str_button.="<input type=button name=comCategory value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comCategory eq 'Add Category')||( $comCategory eq ' Back ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comCategory value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comCategory value='  Cancel  ' onClick='backform2()'>";

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
  if (confirm('Delete this Category ?')) { document.form3.submit(); }
}

// validate fiels before submit
function checkData () {


 if (document.form1.Name.value.length < 1)
   { alert(" The field \'Category Name\' cannot be empty."); document.form1.Name.focus();  document.form1.Name.select(); return false }

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
<input type=hidden name=comCategory value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comCategory value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
 <CENTER>
<H3>$str Category</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\">Name (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\"
                    maxlength=30 size=30></TD></TR>
<!--<TR><TD valign=\"top\" align=\"right\">Description: </TD>
<TD align=\"left\">
   <TEXTAREA NAME=Description ROWS=8 COLS=40>$Description</TEXTAREA>
</TD></TR>-->

</Table>

<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">

$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_category


############################################################################
sub dbedit_category        #19.02.2000 9:53
############################################################################
{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');              # Get Id of the selected record
$Name=$q->param('Name');          # Get Category name
$Description=$q->param('Description');

$_=$Name;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Name=$_;
$_=$Description;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Description=$_;
$str_message='';

# Insert
if ( $comCategory eq '  Insert  ') {
  $sql="INSERT INTO Category (Name,Status,Description) VALUES ('$Name',0, '$Description')";
  if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>";  }
  else { $str_message= "The record has not been inserted !"; $comCategory=' Back '; }
}

# Update
elsif ( $comCategory eq '  Update  ') {

  # Check before whether you have this category
  $sql="SELECT id FROM Category WHERE Id=$Id and Status=0";
  dbexecute($sql);
  my ($Id_check)=dbfetch();
  if ( defined $Id_check ) {

     $sql="UPDATE Category SET Name='$Name', Description='$Description' WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
     else { $str_message= "The record has not been updated !"; $comCategory='  Back  '; }
   }
  else  {  $str_message= "The record has been deleted another user !";  }
 }

# Delete ( Check before if you have product with this Category)
elsif( $comCategory eq '  Delete  ') {

   $sql="SELECT id FROM Product WHERE Category=$Id and Status<>1";
   dbexecute($sql);
   my ($Id_check)=dbfetch();
   if ( !defined $Id_check )
     {
      $sql="UPDATE Category SET status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully ! <P>"; }
      else  { $str_message= "The record cannot be deleted ! "; $comCategory='  Back  ';}
     }
   else  {
     $str_message= "The record cannot be deleted! You have the Product in this Category.";
     $comCategory='  Back  ';
   }
}

# Select form to continue on error or success
if (( $comCategory eq ' Back ')||( $comCategory eq '  Back  '))
  { edit_category($str_message); }
else
  { category($str_message); }



}   ##dbedit_category

############################################################################
sub edit_subcategory      #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get selected Category
$Id=$q->param('Id');
# Set up Category pull-box disabled and hidden field
# if you are updating the SubCategory
my $str_disabled='';
my $str_hidden='';
$CategoryHidden=$q->param('CategoryHidden'); 


if (( $Id ne '' )&&( $comSubcategory ne '  Back  ')&&( $comSubcategory ne ' Back '))  {
  $sql="SELECT Id, Name,Category,Description  FROM Subcategory  WHERE  Id=$Id and Status=0";
  dbexecute($sql);
  ($Id,$Name,$Category,$Description ) =dbfetch();
  $str_disabled='DISABLED';
  $CategoryHidden=$Category;
 }



# Set buttons and title message for the form
my $str_button='';
my $str='';
if (( $comSubcategory eq '  Back  ')||( $comSubcategory eq 'Edit_Subcategory')) {
  # Update or Delete record
  $str="Modify";
  $str_button="<input type=submit name=comSubcategory value='  Update  ' > ";
  $str_button.="<input type=button name=comSubcategory value='  Delete  ' onClick='backform3()'> ";

  if ($Category eq '' ) {
     $str_disabled='DISABLED';
     $Category=$CategoryHidden;
  }

}
elsif (( $comSubcategory eq 'Add Subcategory')||( $comSubcategory eq ' Back ')) {
  # Add new record
  $str= "Insert New";
  $str_button="<input type=submit name=comSubcategory value='  Insert  ' >  ";
}
$str_button.="<input type=button name=comSubcategory value='  Cancel  ' onClick='backform2()'>";
$str_hidden="<input type=hidden name=CategoryHidden value='$CategoryHidden'>";


# Create Category pull-box
my $str_select1="<SELECT NAME=Category $str_disabled>";
$str_select1.="<OPTION VALUE=99999>-- Select Category --";
# Select all 'alive' category from database table
$sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);
while (( $IdTmp,$NameTmp ) =dbfetch()) {
  if ( $IdTmp==$Category ) { $str_select1.="<OPTION SELECTED VALUE=$IdTmp >$NameTmp"; }
  else  { $str_select1.="<OPTION VALUE=$IdTmp>$NameTmp"; }
  }
$str_select1.="</SELECT>";


# Set up error message for Jscript alert
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
  if (confirm('Delete this Subcategory ?')) { document.form3.submit(); }
}
// validate forms fiels before submit
function checkData () {
   if (document.form1.Name.value != '') {
     if ((document.form1.Category.selectedIndex != 0))
       { return true }
     else { alert("The field \'Category\' cannot be empty.");  document.form1.Category.focus();  return false; }
   }
   else { alert("The field \'Subcategory\' cannot be empty.");
     document.form1.Name.focus(); document.form1.Name.select();
     return false
   }
}
// Set up focus on Load or error
function setFocus() {
    document.form1.Name.focus();
    document.form1.Name.select();
    $str_scriptvar;
    }

</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comSubcategory value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
$str_hidden
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comSubcategory value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
$str_hidden
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
 <CENTER>
<H3>$str Subcategory.</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"3\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\">Subcategory (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\"
      maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">Category (required):</TD><TD align=\"left\">$str_select1</TD></TR>
<!--<TR><TD valign=\"top\" align=\"right\">Description: </TD>
<TD align=\"left\">
   <TEXTAREA NAME=Description ROWS=8 COLS=40>$Description</TEXTAREA>
</TD></TR>-->

</Table>

<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
$str_hidden

$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_subcategory


############################################################################
sub dbedit_subcategory        #19.02.2000 9:53
############################################################################
{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$str_message='';
$Id=$q->param('Id');             # Get Id of the selected record
$Name=$q->param('Name');         # Get Subcategory name
$Description=$q->param('Description');
$_=$Name;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Name=$_;
$_=$Description;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Description=$_;


$Category=$q->param('Category'); 
$CategoryHidden=$q->param('CategoryHidden');                                  



# Insert SubCategory
if ( $comSubcategory eq '  Insert  ') {

  $sql="INSERT INTO Subcategory (Name,Category,Status,Description) VALUES ('$Name',$Category,0,'$Description')";
  if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>";  }
  else { $str_message= "The record has not been inserted !"; $comSubcategory=' Back '; }
}

# Update SubCategory
elsif ( $comSubcategory eq '  Update  ')  {

     $sql="UPDATE Subcategory SET Name='$Name'  WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
     else { $str_message= "The record has not been updated !"; $comSubcategory='  Back  '; }
}

# Delete SubCategory ( Check before if you have product with this SubCategory )
elsif( $comSubcategory eq '  Delete  ') {

   $sql="SELECT id FROM Product WHERE Subcategory='$Id' and Status<>1";
   dbexecute($sql);
   my ($Id_check)=dbfetch();
   if ( !defined $Id_check ) {
      $sql="UPDATE Subcategory SET Status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully ! <P>"; }
      else  { $str_message= "The record cannot be deleted ! "; $comSubcategory='  Back  ';}
     }
   else  {
     $str_message= "The record cannot be deleted! You have the Product with this Subcategory.";
     $comSubcategory='  Back  ';
   }
}

# Select form to continue on error or success
if (( $comSubcategory eq ' Back ')||( $comSubcategory eq '  Back  '))
  { edit_subcategory($str_message); }
else
  { category($str_message); }


}   ##dbedit_subcategory


############################################################################
sub manufacturer    #19.02.2000 8:47  Create form with list of manufacturers
############################################################################

{

# Get 'successful' message
my $str_message=$_[0];
# Create table's header.
my $str_table="<table border='1' width='75%' cellspacing='2' cellpadding='0'>
    <TR BGCOLOR='silver'><TH width='10%' >N </TH><TH width='65%'>Manufacturer Name</TH></TR>";

# Select all 'alive' manufacturers
my $sql="SELECT Id, Name FROM Manufacturer  WHERE Status=0 ORDER BY Name ";
dbexecute($sql);
$n=1;
my $pathManufacturer='';
# fetch all records from recordset to format table with manufacturers
while (($Id,$Name) =dbfetch()) {
   # Set up link to update or delete this manufacturer
   $pathManufacturer=$pathUrl."?comManufacturer=Edit_Manufacturer&Id=$Id&code=$code";
   $str_table.="<TR><TD align='center'><a href='".$pathManufacturer."'><FONT SIZE='3'>$n</font></a></TD>
                    <TD align='left'> $Name</TD></TR>";
  $n++;
 }
$str_table.="</Table>";
# Set warning message if the table is empty
if ($n==1)  { $str_table="The table is empty."; }


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
<H3>Manufacturers List</H3>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
<input type=submit name=comManufacturer value='Add Manufacturer' >
</CENTER></FORM></BODY></HTML>
Browser
}   ##manufacturer

############################################################################
sub edit_manufacturer       #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get Id of the selected manufacturer
my $Id=$q->param('Id');
if (( $Id ne '' )&&( $comManufacturer ne '  Back  ')&&( $comManufacturer ne ' Back '))  {
   # Select data for this manufacturer
   $sql="SELECT Id, Name FROM Manufacturer  WHERE  Id=$Id and Status=0";
   dbexecute($sql);
   ($Id, $Name) =dbfetch();
 }

# Set up button and title message for the form
my $str='';
my $str_button='';
if (( $comManufacturer eq '  Back  ')||( $comManufacturer eq 'Edit_Manufacturer'))
 {
  # Update or Delete record
  $str="Modify";
  $str_button="<input type=submit name=comManufacturer value='  Update  ' > ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comManufacturer value='  Update  ' > ";
  $str_button.="<input type=button name=comManufacturer value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comManufacturer eq 'Add Manufacturer')||( $comManufacturer eq ' Back '))
 {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comManufacturer value='  Insert  ' >  ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comManufacturer value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comManufacturer value='  Cancel  ' onClick='backform2()'>";

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
   if (document.form1.Name.value != '')  { return true }
   else { alert("The field \'Name\' cannot be empty.");
          document.form1.Name.focus();
          return false
 }
}
// Set up focus on Load or error
function setFocus() {
    document.form1.Name.focus();
    document.form1.Name.select();
    $str_scriptvar;
    }

</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comManufacturer value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comManufacturer value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
<CENTER>
<H3>$str Manufacturer</H3>
<P>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\"> Name (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\"
      maxlength=30 size=30></TD></TR>
             </Table>
<P>
<input type=hidden name=Id value=$Id>
<input type=hidden name=code value=\"$code\">
$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_manufacturer


############################################################################
sub dbedit_manufacturer       #19.02.2000 9:53
############################################################################
{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');      # Get Id of the selected record
$Name=$q->param('Name');  # Get manufacturer's name
$_=$Name;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Name=$_;
$str_message='';          # error or successful message

# Insert
if ( $comManufacturer eq '  Insert  ')  {

   $sql="INSERT INTO Manufacturer (Name,Status) VALUES ('$Name',0)";
   if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>";  }
   else { $str_message= "The record has not been inserted !"; $comManufacturer=' Back '; }
 }

# Update
elsif ( $comManufacturer eq '  Update  ')  {

  # Check before whether you have this manufacturer
  $sql="SELECT id FROM Manufacturer WHERE Id=$Id and Status=0";
  dbexecute($sql);
  my ($Id_check)=dbfetch();
  if ( defined $Id_check ) {
     $sql="UPDATE Manufacturer SET Name='$Name' WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>";  }
     else { $str_message= "The record has not been updated !"; $comManufacturer='  Back  '; }
   }
  else { $str_message= "The record was deleted another user !<P>";  }
 }

# Delete ( Check before if you have product with this Manufacturer )
elsif( $comManufacturer eq '  Delete  ')
 {
   $sql="SELECT id FROM Product WHERE ManufacturerName=$Id and Status<>1";
   dbexecute($sql);
   my ($Id_check)=dbfetch();
   if ( !defined $Id_check ) {

      $sql="UPDATE Manufacturer SET  status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully !<P> "; }
      else  { $str_message= "The record cannot be deleted ! "; $comManufacturer='  Back  ';}
     }
   else {
     $str_message= "The record cannot be deleted! You have the product with this manufacturer.";
     $comManufacturer='  Back  ';
   }
 }

# Select form to continue on error or success
if (( $comManufacturer eq ' Back ')||( $comManufacturer eq '  Back  '))
  { edit_manufacturer($str_message); }
else
  { manufacturer($str_message); }


}   ##dbedit_manufacturer



############################################################################
sub typeofbusiness  #19.02.2000    Create form with list of type of business
############################################################################

{
my $str_message=$_[0]; # Get 'successful' mesage

# Create table's header.
my $str_table="<table border='1' width='75%' cellspacing='2' cellpadding='0'>
   <TR BGCOLOR='silver'><TH width='10%' >N</TH><TH width='65%'>Name</TH></TR>";

# Select all 'alive' type of business
my $sql="SELECT Id, Name FROM TypeOfBusiness  WHERE Status=0 ORDER BY Name ";
dbexecute($sql);
$n=1;
my $pathTypeOfBusiness='';
# fetch all records from recordset to format
# table with types of business
while (($Id,$Name) =dbfetch()) {
   # Set up link to update or delete this type of business
   $pathTypeOfBusiness=$pathUrl."?comTypeOfBusiness=Edit_TypeOfBusiness&Id=$Id&code=$code";
   $str_table.="<TR><TD align='center'><a href='".$pathTypeOfBusiness."'><FONT size='3'>$n</FONT></a></TD>
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
<H3> Types of Business List</H3>
<P>
<font color='black'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
<input type=submit name=comTypeOfBusiness value='Add Type of Business' >
</CENTER></FORM></BODY></HTML>
Browser
}   ##typeofbusiness

############################################################################
sub edit_typeofbusiness       #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get Id of the selected type of business
my $Id=$q->param('Id');
if (( $Id ne '' )&&( $comTypeOfBusiness ne '  Back  ')&&( $comTypeOfBusiness ne ' Back '))  {
   # Select data for this type of business
   $sql="SELECT Id, Name FROM TypeOfBusiness  WHERE  Id=$Id and Status=0";
   dbexecute($sql);
   ($Id,$Name) =dbfetch();
 }

# Set up button and title message for the form
my $str='';
my $str_button='';
if (( $comTypeOfBusiness eq '  Back  ')||( $comTypeOfBusiness eq 'Edit_TypeOfBusiness')) {
  # Update or delete record
  $str="Modify";
  $str_button="<input type=submit name=comTypeOfBusiness value='  Update  ' > ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comTypeOfBusiness value='  Update  ' > ";
  $str_button.="<input type=button name=comTypeOfBusiness value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comTypeOfBusiness eq 'Add Type of Business')||( $comTypeOfBusiness eq ' Back ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comTypeOfBusiness value='  Insert  ' >  ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comTypeOfBusiness value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comTypeOfBusiness value='  Cancel  ' onClick='backform2()'>";

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
<input type=hidden name=comTypeOfBusiness value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comTypeOfBusiness value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
<CENTER>
<H3>$str Type of Business</H3>
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
}   ##edit_typeofbusiness


############################################################################
sub dbedit_typeofbusiness       #19.02.2000 9:53
############################################################################

{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');      # Get Id of the selected record
$Name=$q->param('Name');  # Get type of business name
$_=$Name;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Name=$_;

$str_message='';          # error or successful message

# Insert
if ( $comTypeOfBusiness eq '  Insert  ')  {

   $sql="INSERT INTO TypeOfBusiness (Name, Status) VALUES ('$Name', 0)";
   if (dbdo($sql)) { $str_message= "The record has been inserted successfully !<P>"; }
   else  {  $str_message= "The record  has not been inserted !"; $comTypeOfBusiness=' Back '; }
 }

# Update
elsif ( $comTypeOfBusiness eq '  Update  ') {
  # Check before whether you have this type of business
  $sql="SELECT id FROM TypeOfBusiness WHERE Id=$Id and Status=0";
  dbexecute($sql);
  my ($Id_check)=dbfetch();
  if ( defined $Id_check ) {

     $sql="UPDATE TypeOfBusiness SET Name='$Name' WHERE Id=$Id";
     if (dbdo($sql)) { $str_message= "The record  has been  updated successfully !<P>"; }
     else { $str_message= "The record  has not been updated !"; $comTypeOfBusiness='  Back  '; }
    }
  else  { $str_message= "The record was deleted another user !<P>"; }
}

# Delete ( Check before if you have Customer with this Type of business )
elsif( $comTypeOfBusiness eq '  Delete  ') {

   $sql="SELECT id FROM Profile WHERE TypeOfBusiness=$Id and Status<>1";
   dbexecute($sql);
   my ($Id_check)=dbfetch();
   if ( !defined $Id_check )  {

      $sql="UPDATE TypeOfBusiness SET status=1 WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully !<P> "; }
      else  { $str_message= "The record cannot be deleted ! ";$comTypeOfBusiness='  Back  '; }
     }
   else  { $str_message= "The record cannot be deleted! You have Account with this Type Of Business."; $comTypeOfBusiness='  Back  ';}
 }

# Select form to continue on error or success
if (( $comTypeOfBusiness eq ' Back ')||( $comTypeOfBusiness eq '  Back  '))
  { edit_typeofbusiness($str_message); }
else
  { typeofbusiness($str_message); }

}   ##dbedit_typeofbusiness



############################################################################
sub creditcard      #19.02.2000 8:47  Create form with list of payment terms
############################################################################

{
# Get 'successful' message
my $str_message=$_[0];
# Create table's header.
my $str_table="<table border='1' width='85%' cellspacing='2' cellpadding='0'>
          <TR BGCOLOR='silver'><TH width='10%' >N</TH><TH width='15%'>Name</TH><TH width='40%'>Description</TH>
          <TH width='20%'>Conditions of sale</TH></TR>";

# Select all 'alive' payment terms
my $sql="SELECT Id, Name, Description, ConditionsOfSale FROM CreditCard  WHERE Status=0 ORDER BY Name ";
dbexecute($sql);

my $n=1;
my $pathTypeOfBusiness='';
# fetch all records from recordset to format table with payment terms
while (($Id,$Name, $Description, $ConditionsOfSale) =dbfetch()) {
   # Set up link to update or delete this payment term
   if ( $ConditionsOfSale ne '')   { $ConditionsOfSale="Available"; }
   else    {
      $ConditionsOfSale="Not available";
   }

   $pathCreditCard=$pathUrl."?comCreditCard=Edit_CreditCard&Id=$Id&code=$code";
   $str_table.="<TR><TD align='center' valign=top><a href='".$pathCreditCard."'><FONT size='3'>$n</FONT></a></TD>
                <TD align='left' valign=top>$Name</TD><TD align='left' valign=top>$Description</TD>
                <TD align='center' valign=top>$ConditionsOfSale</TD></TR>";
  $n++;
 }
$str_table.="</Table>";

# Set warning message if the table is empty
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

<BODY BGCOLOR=\"#CCCCCC\">
<FORM METHOD=\"POST\" ACTION=$pathUrl>
<CENTER>
<H3>Types of Payment List</H3>
<P>
<font color=\"black\">$str_message</font>
$str_table
<P>
<input type=hidden name=code value=\"$code\">
<input type=submit name=comCreditCard value=\"Add Type of Payment\" >
</CENTER></FORM></BODY></HTML>
Browser
}   ##creditcard

############################################################################
sub edit_creditcard       #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get error message for Jscript alert
my $str_message=$_[0];
# Get Id of the selected payment term
my $Id=$q->param('Id');

if (( $Id ne '' )&&( $comCreditCard ne '  Back  ')&&( $comCreditCard ne ' Back '))  {
   # Select data for this payment term
   $sql="SELECT Id, Name, Description, ConditionsOfSale FROM CreditCard  WHERE Id=$Id and Status=0 ORDER BY Name ";
   dbexecute($sql);
   ($Id, $Name, $Description, $ConditionsOfSale) =dbfetch();
 }

# Set up buttons title message for the form and
my $str='';
my $str_button='';
if (( $comCreditCard eq '  Back  ')||( $comCreditCard eq 'Edit_CreditCard')) {
  # Update or delete record
  $str="Modify ";
  $str_button="<input type=submit name=comCreditCard value='  Update  ' > ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comCreditCard value='  Update  ' > ";
  $str_button.="<input type=button name=comCreditCard value='  Delete  ' onClick='backform3()'> ";
 }
elsif (( $comCreditCard eq 'Add Type of Payment')||( $comCreditCard eq ' Back ')) {
  # Insert new record
  $str= "Insert New";
  $str_button="<input type=submit name=comCreditCard value='  Insert  ' >  ";
  # use this hidden field to solve incorrect MS IE's behaviour
  $str_button.="<input type=hidden name=comCreditCard value='  Insert  ' >  ";
 }
$str_button.="<input type=button name=comCreditCard value='  Cancel  ' onClick='backform2()'>";

# Set up alert with error message for Jscript
if ( $str_message ne '' ) {  $str_scriptvar="alert('$str_message');" ; }

$_=$Name;       s/\\//g;  s/\"/&quot;/g; $Name=$_;
$_=$Description;       s/\\//g;  s/\"/&quot;/g; $Description=$_;
$_=$ConditionsOfSale;       s/\\//g;  s/\"/&quot;/g; $ConditionsOfSale=$_;

if ($Description ne '') { $Description.=" "; }
if ($ConditionsOfSale ne '') { $ConditionsOfSale.=" "; }

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
   if (document.form1.Name.value.length == 0) {
    alert("The field \'Name\' cannot be empty."); document.form1.Name.focus(); return false
   }
   if (document.form1.Description.value.length == 0) {
    alert("The field \'Description\' cannot be empty."); document.form1.Description.focus(); return false
   }
   return true;
}
// Set up focus on Load or error
function setFocus() {
    document.form1.Name.focus();
    document.form1.Name.select();
    $str_scriptvar
}

</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comCreditCard value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
<input type=hidden name=Name value=\"$Name\">
<input type=hidden name=Description value=\"$Description\">
<input type=hidden name=FileName1 value=\"$FileName1\">
<input type=hidden name=FileName2 value=\"$FileName2\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comCreditCard value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\">
<CENTER>
<H3>$str Type of Payment</H3>
<p>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\"> Name (required):</TD>
<TD align=\"left\"><input type=text name=Name value=\"$Name\" maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\" valign=top>* Description (required):</TD>
<TD align=\"left\"><textarea rows=7 name=Description cols=50>$Description</textarea>
</TD></TR>
<TR><TD align=\"right\" valign=top>Conditions of Sale:</TD>
<TD align=\"left\"><textarea rows=7 name=ConditionsOfSale cols=50>$ConditionsOfSale</textarea></TD></TR>


</Table>
<P>
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">

$str_button

</FORM>
<br>
<font size=2>* To format Description and Conditions of Sale at front side of Store you can use html tags</font>

</CENTER>

</BODY></HTML>
Browser
}   ##edit_creditcard



############################################################################
sub dbedit_creditcard       #19.02.2000 9:53
############################################################################
{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');      # Get Id of the selected record
$Name=$q->param('Name');  # Get payment term's name
$Description=$q->param('Description');
$ConditionsOfSale=$q->param('ConditionsOfSale');


$_=$Name;            (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Name=$_;
$_=$Description;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $Description=$_;
$_=$ConditionsOfSale;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g; $ConditionsOfSale=$_;



$str_message='';          # error or successful message


# Insert
if ( $comCreditCard eq '  Insert  ') {
   if ($str_message ne '') {
      $comCreditCard=' Back ';  $str_message.= " The record has not been inserted !";
   }
   else {
      $sql="INSERT INTO CreditCard (Name, Description, ConditionsOfSale, Status) VALUES ('$Name', '$Description', '$ConditionsOfSale', 0)";
      if (dbdo($sql)) { $str_message= "<font color='blue'>The record has been inserted successfully !<P></font>"; }
      else { $comCreditCard=' Back ';  $str_message= "The record has not been inserted !";  }
   }
}

# Update
elsif ( $comCreditCard eq '  Update  ') {

   if ($str_message ne '') {
      $comCreditCard='  Back  '; $str_message.= " The record has not been updated !";
   }
    else  {
      $sql="UPDATE CreditCard SET Name='$Name', Description='$Description',
                   ConditionsOfSale='$ConditionsOfSale'  WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
      else {$str_message= "The record has not been updated !";  $comCreditCard='  Back  '; }
   }
}

# Delete. Note. I do NOT check before if you
# have Customer  with this payment term !!!!!
elsif( $comCreditCard eq '  Delete  ')  {

   $sql="UPDATE CreditCard SET status=1 WHERE Id=$Id";
  if (dbdo($sql)) { $str_message= "The record has been deleted successfully !<P> "; }
  else  { $str_message= "The record cannot be deleted ! "; $comCreditCard='  Back  ';}
#       $str_message= "The record cannot be deleted ! "; $comCreditCard='  Back  ';
 }

# Select form to continue on error or success
if (( $comCreditCard eq ' Back ')||( $comCreditCard eq '  Back  '))
  { edit_creditcard ($str_message); }
else
  { creditcard ($str_message); }

}   ##dbedit_creditcard


############################################################################
sub password      #21.02.2000 15:57 Create form with list of administrators
############################################################################

{
# Note.$status with lower 's' is a status for the current Admin
#      $Status with upper 'S' is a status for other admins

# Get 'successful' message
my $str_message=$_[0];

# Create table's header
my $str_table="<table border='1' width='60%' cellspacing='2' cellpadding='0'>
   <TR BGCOLOR='silver'><TH width='5%' >N</TH><TH width='35%'>Administrator</TH><TH width='20%'>Status</TH></TR>";

# select data from 'Password' table according to Status
# of Admin ('Supervisor' or 'User')
if ( $super==1 ) { $sql="SELECT Id, User, Super FROM Passw ORDER BY User "; }
else { $sql="SELECT Id, User, Super FROM Passw WHERE Code='$code'"; }
dbexecute($sql);

$n=1;
my $pathPassw='';
# fetch all records from recordset to format table with admins
while (($Id,$User,$Super) =dbfetch()) {
  # Set string for html page according $Super
  if ( $Super==1 ) { $Status='Supervisor'; }
  else { $Status='User'; }
  # Set up link to update or delete this admin

  #$pathPassw=$pathUrl."?comPassw=Edit_Passw&Id=$Id&code=$code";
  $pathPassw=$pathUrlSec."?comPassw=Edit_Passw&Id=$Id&code=$code";
  $str_table.="<TR><TD align='center'>$n</TD><TD align='left'><a href='".$pathPassw."'>
               <FONT size='3'>$User</FONT></a></TD><TD align='center'>$Status</TD></TR>";
  $n++;
 }
$str_table.="</Table>";

# Set warning message if the table is empty
# ( I hope you'll never see it )
if ($n==1) { $str_table="The table is empty."; }

# Create button if the current Admin has status 'Supervisor'
if ( $super==1 )  { $str_button="<input type=submit name=comPassw value='Create New Administrator' >"; }

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
<FORM METHOD='POST' ACTION=$pathUrlSec>
<CENTER>
<H3>Administrators</H3>
<P>
<font color='blue'>$str_message</font>
$str_table
<P>
<input type=hidden name=code value='$code'>
$str_button
</CENTER></FORM></BODY></HTML>
Browser
}   ##password


############################################################################
sub edit_password       #19.02.2000 9:16
############################################################################
{
# Create form to insert, update or delete the selected record

# Get Error message for Jscript alert
my $str_message=$_[0];
# Get Id of the selected record
my $Id=$q->param('Id');
  if (( $Id ne '' )&&(( $comPassw ne ' Back ')&&( $comPassw ne '  Back  ')))
   {
     # Select data for the selected record
     $sql="SELECT Id, User,Password,Code,Super FROM Passw  WHERE Id=$Id ";
     dbexecute($sql);
     ($Id,$User,$Password,$Code,$Super) =dbfetch();
      $Password2=$Password;
   }

$_=$User;          s/\\//g; s/\"/&quot;/g; $User=$_;
$_=$Password;      s/\\//g; s/\"/&quot;/g; $Password=$_;
$_=$Password2;     s/\\//g; s/\"/&quot;/g; $Password2=$_;

my $disabled='';
if ( $super == 1 ) {
  # The current Admin is 'Supervisor'
  $disabled="<TR><TD align='right'>User Name:</TD>
             <TD align='left'><input type=text name=User value=\"$User\" maxlength=10 size=15 >
             (4-10 chars)</TD></TR>
             <TR><TD align='right'> Status:</TD>
             <TD align='left'><SELECT NAME=Super>";
  # Set up default value for pull-box according to $Super
  if ( $Super ==1 )
   { $disabled.="<OPTION SELECTED VALUE=1>Supervisor<OPTION VALUE=0>User</SELECT></TD></TR>"; }
  else
   { $disabled.="<OPTION SELECTED VALUE=0>User<OPTION VALUE=1>Supervisor</SELECT></TD></TR>"; }
 }
else  {
   # The current Admin is 'User'
   $disabled='';
   $str_hidden="<input type=hidden name=User value=\"$User\">
                <input type=hidden name=Super value=$Super> ";
 }
# Create html table
my $str_table = "<table border='0' width='100%' cellspacing='1' cellpadding='1'>
             <TR><TH width='40%'></TH><TH width='60%'></TH></TR>
             $disabled
             <TR><TD align='right'> Password:</TD>
             <TD align='left'><input type=password name=Password value='".$Password."'
                               maxlength=10 size=15>(6-10 chars, case sensitive) </TD></TR>
             <TR><TD align='right'>Re-enter Password:</TD>
             <TD align='left'><input type=password name=Password2 value='".$Password2."'
                               maxlength=10 size=15></TD></TR>
             </Table>";

# Set up buttons and title message for the form
my $str='';
my $str_button='';
if (( $comPassw eq '  Back  ')||( $comPassw eq 'Edit_Passw')) {
  # Update or delete the record
  $str="Modify";
  $str_button="<input type=submit name=comPassw value='  Update  ' > ";
  # Create button 'Delete' if the current Admin is 'Supervisor'
  if ( $super ==1 )
    { $str_button.="<input type=button name=comPassw value='  Delete  ' onClick='backform3()'> "; }
 }
elsif ((( $comPassw eq 'Create New Administrator')||( $comPassw eq ' Back '))&&( $super ==1 ))  {
  # Insert new record
  # Create button 'Insert' if the current Admin is 'Supervisor'
  $str= "Create New";
  $str_button="<input type=submit name=comPassw value='  Create  ' >  ";
 }

$str_button.="<input type=button name=comPassw value='  Cancel  ' onClick='backform2()'>";

# Set up alert with error message for Jscript
if ( $str_message ne '') { $str_scriptvar="alert('$str_message')"; }


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
  if (confirm('Delete this Administrator ?')) { document.form3.submit(); }
}
// validate form's fiels before submit
function checkData () {
   if (document.form1.User.value.length >3 ) {
     if (document.form1.Password.value.length >5) {
        if (document.form1.Password.value == document.form1.Password2.value) {return true }
        else { alert("The fields \'Password\' and \'Re-Enter Password\' are not equal."); document.form1.Password2.focus(); document.form1.Password2.select(); return false }
     }
     else { alert("The field \'Password\' cannot be less 6 chars."); document.form1.Password.focus(); document.form1.Password.select(); return false }
   }
   else { alert("The field \'UserName\' cannot be less than 4 chars."); document.form1.User.focus(); document.form1.User.select(); return false }
}
// set focus on Load or error
function setFocus() {
 document.form1.User.focus(); document.form1.User.select();
 $str_scriptvar
}
</SCRIPT>
</HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM Name=\"form3\" METHOD=\"POST\" ACTION=$pathUrlSec >
<input type=hidden name=comPassw value=\"  Delete  \" >
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=User value=\"$User\">
<input type=hidden name=Password value=\"$Password\">
<input type=hidden name=Password2 value=\"$Password2\">
<input type=hidden name=Super value=\"$Super\">
<input type=hidden name=code value=\"$code\">
</FORM>

<FORM Name=\"form2\" METHOD=\"POST\" ACTION=$pathUrlSec >
<input type=hidden name=comPassw value=\"  Cancel  \" >
<input type=hidden name=code value=\"$code\">
</FORM>
<FORM Name=\"form1\" METHOD=\"POST\" ACTION=$pathUrlSec onSubmit=\"return checkData()\">
<CENTER>
<H3>$str Administrator</H3>
<P>
$str_table
<P>
$str_hidden
<input type=hidden name=Id value=\"$Id\">
<input type=hidden name=code value=\"$code\">
$str_button
</CENTER></FORM>

</BODY></HTML>
Browser
}   ##edit_password

############################################################################
sub dbedit_password       #19.02.2000 9:53
############################################################################

{
# Execute query in order to insert,  update or delete
# the selected record  in the database table.

$Id=$q->param('Id');              # Get Id of the selected record
$User=$q->param('User');          # Get user name
$Password=$q->param('Password');  # Get Password
$Password2=$q->param('Password2');# Get Password replay
$Super=$q->param('Super');        # Get status for this admin

$_=$User;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $User=$_;
$_=$Password;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password=$_;
$_=$Password2;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password2=$_;

$str_message='';
# Set $Status = 'User', if the current Admin is 'User'.
# because he has not right to increase his status
if ( $super==0 ) { $Super=0; }

# Insert
if (( $comPassw eq '  Create  ')&&( $super==1 )) {

   $sql="INSERT INTO Passw (User,Password,Super) VALUES ('$User','$Password',$Super)";
   if (dbdo($sql))  { $str_message= "The record has been inserted successfully !<P>"; }
   else { $str_message= "The record has not been inserted !"; $comPassw=' Back '; }
 }

# Update
elsif ( $comPassw eq '  Update  ') {
  # Check before whether you have this admin
  $sql="SELECT Id, Code FROM Passw WHERE Id=$Id";
  dbexecute($sql);
  my ($Id_check, $Code_check)=dbfetch();
  if ( defined $Id_check ) {

     # admin with status 'User' updates only himself
     if (( $Code_check eq $code)&&($super == 0))  {
       $sql="UPDATE Passw SET User='$User', Password='$Password', Super=0 WHERE Id=$Id";
       if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
       else { $str_message= "The record has not been updated !"; $comPassw='  Back  ';}
     }
     # admin with status 'Supervisor' updates other admin (User or Supervisor)
     elsif (( $Code_check ne $code)&&($super == 1))  {
       $sql="UPDATE Passw SET User='$User', Password='$Password', Super=$Super WHERE Id=$Id";
       if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
       else { $str_message= "The record has not been updated !"; $comPassw='  Back  ';}
     }
     # admin with status 'Supervisor' updates himself
     elsif (( $Code_check eq $code)&&($super == 1))  {
       if ( $Super == 1 ) {
          $sql="UPDATE Passw SET User='$User', Password='$Password', Super=1 WHERE Id=$Id";
          if (dbdo($sql)) { $str_message= "The record has been updated successfully !<P>"; }
          else { $str_message= "The record has not been updated !"; $comPassw='  Back  ';}
        }
       else { $str_message= "You cannot set your Status equal to User! "; $comPassw='  Back  ';}
      }

   }
  else { $str_message= "The record has been deleted another user !<P>";  }
 }

# Delete ( Check before if you are going to delete yourself )
elsif(( $comPassw eq '  Delete  ')&&( $super==1 ))  {

  $sql="SELECT Code FROM Passw WHERE Id=$Id";
  dbexecute($sql);
  my ($Code_check)=dbfetch();
  if ( $Code_check ne $code)
    {
      $sql="DELETE FROM Passw WHERE Id=$Id";
      if (dbdo($sql)) { $str_message= "The record has been deleted successfully !<P> "; }
      else { $str_message= "The record cannot be deleted !"; $comPassw='  Back  ';}
    }
  else { $str_message= "You cannot delete yourself! "; $comPassw='  Back  ';}
 }

# if error occured return back to edit mode
# else return to password table form
if (( $comPassw eq ' Back ')||( $comPassw eq '  Back  '))
  { edit_password ($str_message); }
else
  { password ($str_message); }


}   ##dbedit_password

############################################################################
sub logout      #25.11.00 21:19
############################################################################

{

  $sql="UPDATE Passw SET Code=''  WHERE Code='$code'";
  dbdo($sql);
  $pathLogout=$path_admin;
  print("Location: $pathLogout \n\n")

}   ##logout




############################################################################
sub setup       #30.11.99 11:29   Create form with Store's Setup
############################################################################

{

# Set focus on the first field of the form on Load
$str_message=$_[0];
$str_scriptvar="";
if ( $str_message  ne '' ) {
   $str_scriptvar.=" alert('$str_message');";
}


# Set focus on the email field if it is not correct
if ( $comSetup eq 'Back' ) {
    # Get error message for Jscript alert

    if ( $str_message  ne '' ) {
       $str_scriptvar="document.form1.Emailstore.focus(); document.form1.Emailstore.select();
                       alert('$str_message');";
    }
 }
else  {
  # Select data from 'Setup' table
  my $sql="SELECT NameStore, NameDirector, Address,City, State, Country ,
                  Zip, Phone,Fax, Emailstore From Setup";
  dbexecute($sql);
  ($NameStore,$NameDirector,$Address,$City,$State,$Country,$Zip,
   $Phone,$Fax,$Emailstore)=dbfetch();
}


$_=$NameStore;    s/\\//g; s/\"/&quot;/g; $NameStore=$_;
$_=$NameDirector; s/\\//g; s/\"/&quot;/g; $NameDirector=$_;
$_=$Address;      s/\\//g; s/\"/&quot;/g; $Address=$_;
$_=$City;         s/\\//g; s/\"/&quot;/g; $City=$_;
$_=$State;        s/\\//g; s/\"/&quot;/g; $State=$_;
$_=$Country;      s/\\//g; s/\"/&quot;/g; $Country=$_;
$_=$Zip;          s/\\//g; s/\"/&quot;/g; $Zip=$_;
$_=$Phone;        s/\\//g; s/\"/&quot;/g; $Phone=$_;
$_=$Fax;          s/\\//g; s/\"/&quot;/g; $Fax=$_;
$_=$Emailstore;   s/\\//g; s/\"/&quot;/g; $Emailstore=$_;


# HTML
print <<Browser;
Content-type: text/html\n\n
<HTML><HEAD>
<TITLE>Admin</TITLE>
<SCRIPT>
// use it for button 'Cancel' in order not to validate fields.
function backform () {
   document.form2.submit()
}
// validate fields before submit
function checkData () {
if (document.form1.NameStore.value != '') {
if (document.form1.NameDirector.value != '' ) {
if (document.form1.Address.value != '' ) {
if (document.form1.City.value != '' ) {
if (document.form1.State.value != '' ) {
if (document.form1.Country.value != '' ) {
if (document.form1.Zip.value != '' ) {
if (document.form1.Phone.value != '' ) {
if (document.form1.Emailstore.value != '' )
  {return true }
else { alert("The field \'E-mail\' cannot be empty."); document.form1.Emailstore.focus();  document.form1.Emailstore.select(); return false }
}
else { alert("The field \'Phone\' cannot be empty."); document.form1.Phone.focus();  document.form1.Phone.select(); return false }
}
else { alert("The field \'Zip\' cannot be empty."); document.form1.Zip.focus();  document.form1.Zip.select(); return false }
}
else { alert("The field \'Country\' cannot be empty."); document.form1.Country.focus();  document.form1.Country.select(); return false }
}
else { alert("The field \'State\' cannot be empty."); document.form1.State.focus();  document.form1.State.select(); return false }
}
else { alert("The field \'City\' cannot be empty."); document.form1.City.focus();  document.form1.City.select(); return false }
}
else { alert("The field \'Street Address\' cannot be empty."); document.form1.Address.focus();  document.form1.Address.select(); return false  }
}
else { alert("The field \'Customer Service Representative\' cannot be empty."); document.form1.NameDirector.focus();  document.form1.NameDirector.select(); return false  }
}
else { alert("The field \'Name Store\' cannot be empty."); document.form1.NameStore.focus();  document.form1.NameStore.select(); return false  }
}

// set focus on Load or error
function setFocus() {
         $str_scriptvar
}

</SCRIPT></HEAD>
<BODY BGCOLOR=\"#CCCCCC\" onLoad=\"setFocus()\">
<FORM NAME=\"form2\" METHOD=\"POST\" ACTION=$pathUrl >
<input type=hidden name=comSetup value=\"  Cancel  \">
<input type=hidden name=code value=\"$code\">
</FORM>
<FORM NAME=\"form1\" METHOD=\"POST\" ACTION=$pathUrl onSubmit=\"return checkData()\"><CENTER>
<center><h3> <font color=\"#000000\">Setup</font> </h3></center>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR ><TH width=\"70%\"></TH><TH width=\"30%\"></TH></TR>
<TR><TD align=\"right\"></TD><TD align=\"left\"><font size=2 color=\"black\"> All fields are required.</FONT></TD></TR>
</table>
<table border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"1\">
<TR ><TH width=\"40%\"></TH><TH width=\"60%\"></TH></TR>
<TR><TD align=\"right\"> Name of Store :</TD>
    <TD align=\"left\"><input type=text name=NameStore value=\"$NameStore\" maxlength=25 size=25></TD></TR>
<TR><TD align=\"right\">Customer Service Representative :</TD>
    <TD align=\"left\"><input type=text name=NameDirector value=\"$NameDirector\" maxlength=25 size=25></TD></TR>
<TR><TD align=\"right\">Street Address:</TD>
<TD align=\"left\"><input type=text name=Address value=\"$Address\" maxlength=40 size=40></TD></TR>
<TR><TD align=\"right\">City:</TD>
    <TD align=\"left\"><input type=text name=City value=\"$City\" maxlength=25 size=25></TD></TR>
<TR><TD align=\"right\">State:</TD>
    <TD align=\"left\"><input type=text name=State value=\"$State\" maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">Country:</TD>
    <TD align=\"left\"><input type=text name=Country value=\"$Country\" maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">Zip:</TD>
    <TD align=\"left\"><input type=text name=Zip value=\"$Zip\" maxlength=10 size=10></TD></TR>
<TR><TD align=\"right\">Phone:</TD>
    <TD align=\"left\"><input type=text name=Phone value=\"$Phone\" maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">Fax:</TD>
<TD align=\"left\"><input type=text name=Fax value=\"$Fax\" maxlength=30 size=30></TD></TR>
<TR><TD align=\"right\">E-mail:</TD>
<TD align=\"left\"><input type=text name=Emailstore value=\"$Emailstore\" maxlength=30 size=30></TD></TR>
</Table>
<P>
<input type=hidden name=code value=\"$code\">
<input type=submit name=comSetup value=\"  Update  \" >
<input type=reset name=comSetup value=\"  Reset  \" >
<input type=button name=comSetup value=\"  Cancel  \" onClick=\" backform()\" >
</CENTER></FORM>


</BODY></HTML>
Browser

}   ##setup

############################################################################
sub edit_setup     #30.11.99 12:03 Update Store's Setup
############################################################################

{

# Get all params using CGI
$NameStore=$q->param('NameStore');
$NameDirector=$q->param('NameDirector');
$Address=$q->param('Address');
$City=$q->param('City');
$State=$q->param('State');
$Country=$q->param('Country');
$Zip=$q->param('Zip');
$Phone=$q->param('Phone');
$Fax=$q->param('Fax');
$Emailstore=$q->param('Emailstore');

$_=$NameStore;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $NameStore=$_;
$_=$NameDirector;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $NameDirector=$_;
$_=$Address;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Address=$_;
$_=$City;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
$_=$State;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $State=$_;
$_=$Country;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Country=$_;
$_=$Zip;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
$_=$Phone;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
$_=$Fax;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
$_=$Emailstore;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Emailstore=$_;

$str_message='';
$str_button='';

# validate email address
if (&email_check($Emailstore)==0) {
    $str_message= "The record has not been inserted ! Incorrect e-mail address.";
    $comSetup = 'Back';
    setup($str_message);
    return ;

 }

# update Setup
$sql="UPDATE Setup SET NameStore='$NameStore', NameDirector='$NameDirector',
      Address='$Address', City='$City', State='$State',Country='$Country',
      Zip='$Zip', Phone='$Phone', Fax='$Fax' , Emailstore='$Emailstore' ";
if (dbdo($sql)) {
      $str_message="The record has been updated successfully!";
  }
else { $str_message= "The record has not been updated!";  }


    setup($str_message);


}   ##edit_setup