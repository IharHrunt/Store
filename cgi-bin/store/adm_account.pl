#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_account.pl
#
############################################################################

use CGI;
use LWP::Simple;
use locale;
$q = new CGI;

require 'db.pl';

# set path for the forms of the current script
$pathUrl =$path_cgi_https.'adm_account.pl';

if ( $ENV{'HTTP_REFFER'} == $pathUrl) { dbconnect(); }

$code = $q->param('code');

enter();


############################################################################
sub enter  #17.02.2000 15:39
############################################################################

{


# if $code is not defined then accessdenied
if ( $code eq '' ) { accessdenied(); return; }

# if $code is not equal data from Password table then accessdenied
my $sql="SELECT Code, Super FROM Passw WHERE Code='$code'";
dbexecute($sql);
($code_check, $super )=dbfetch();
if ( $code ne $code_check ) { accessdenied(); return; }


$comEdit = $q->param('comEdit');

if ( $comEdit eq ''               ) { accessdenied(); }
elsif ( $comEdit eq 'Edit'        ) { newaccount();   }
elsif ( $comEdit eq 'New'         ) { newaccount();   }
elsif ( $comEdit eq 'Establish Account' ) { db_newaccount(); }
elsif ( $comEdit eq 'Save changes'  ) { db_newaccount(); }
elsif ( $comEdit eq '   Cancel   '  ) { list_account();  }

elsif ( $comEdit eq 'Search'        ) { query_account(); }
elsif ( $comEdit eq '  Query  '    ) { list_account();  }
elsif ( $comEdit eq 'Page'          ) { list_account();  }

elsif ( $comEdit eq 'History'                  ) { history_list_account();  }
elsif ( $comEdit eq 'Return to previous page'  ) { history_list_account();  }
elsif ( $comEdit eq 'Edit_Old'                 ) { history_newaccount();   }

elsif ( $comEdit eq 'Transactions'  ) { transactions();  }

}  ##enter


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><STRONG>Access Denied.</STRONG></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied



############################################################################
sub query_account      #17.02.2000 15:39
############################################################################

{

#####<OPTION VALUE=5>Established by client</OPTION>

$StartDay=get_date(1);
$EndDay=get_date();


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>

<SCRIPT>

var mycurrdate;

function all_dates() {

 if ( document.form1.Period.checked ) {
   mycurrdate=document.form1.StartDay.value;
   document.form1.StartDay.value="2005-01-01";
 }
 else {
    document.form1.StartDay.value=mycurrdate;
 }
}

</SCRIPT>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
<BR><CENTER><h3>Accounts Information</h3>
<hr width='70%'>
<br>
<table border='0' width='100%' cellspacing='0' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='15%'></TH><TH width='15%'></TH><TH width='45%'></TH></TR>

<TR ><TD align='right'>Established from: </TD>
    <TD align='left'> <input type=text name=StartDay value=$StartDay maxlength=10 size=10></TD>
    <TD align='right'>To: </TD>
    <TD align='left'> <input type=text name=EndDay value=$EndDay maxlength=10 size=10>
<INPUT type='checkbox' name='Period' value='1' onClick='all_dates()'> <font color='black' size=3> Select all dates</font>

    </TD>
</TR>
</TABLE>
<BR>
<table border='0' width='100%' cellspacing='' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='15%'></TH><TH width='15%'></TH><TH width='45%'></TH></TR>

<TR ><TD align='right'>Account Status: </TD>
    <TD align='left'> <select name='StatusAccount'>
       <OPTION SELECTED VALUE=0>Active</OPTION>
       <OPTION VALUE=1>Closed</OPTION>
       <OPTION VALUE=2>All Accounts</OPTION>
       </SELECT></TD>
    <TD align='right'>Max.Rows: </TD>
    <TD valign='top'><input type=text name=rowNumber value=20 maxlength=2 size=2> (on the page) </TD>
</TR>
</TABLE>
<BR>
<table border='0' width='100%' cellspacing='0' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='75%'></TH></TR>
<TR><TD align='right'>Keyword(s) search:&nbsp;&nbsp;</TD>
    <TD align='left'> <input type=text name=SearchWord value='' maxlength=50 size=45> </TD>
</TR>
</TABLE>
<br>
<table border='0' width='100%' cellspacing='' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='75%'></TH></TR>
<TR><TD align='right'></TD><TD align='left'> To establish a New Account click on&nbsp;
<a href='$pathUrlNewAccount?comEdit=New&code=$code' TARGET='adm'
TITLE="Click here to create a new account."><font size='3'><b>New Account</b></font></a></TD></TR></TABLE>


<BR>

<hr width='70%'>
<BR>
<input type=hidden name=code value='$code'>
<input type=hidden name=page value='1'>
<input type=submit name=comEdit value='  Query  ' >
<br>

</CENTER>
</FORM>
</BODY></HTML>
Browser

}   ##query_account


############################################################################
sub list_account      #17.02.2000 15:39
############################################################################

{


my $limit=100;
$StartDay=$q->param('StartDay');
$EndDay=$q->param('EndDay');

# Check Status
$StatusAccount=$q->param('StatusAccount');
if ( $StatusAccount == 2) { $select_Status=""; }
else { $select_Status=" Profile.Status = $StatusAccount AND "; }



# successful message from update or delete of profile
$str_report="<font color ='black'>".$_[0]."</font>";
# Get number of the current page
$page=$q->param('page');
# Count last and first rows for the current page
my $rowNumber=$q->param('rowNumber');
my $rowLast=$page*$rowNumber;
my $rowFirst=($page-1)*$rowNumber;
my $n=$rowFirst;
my $str_navig='';
my $navig = 0;


my $str_font='';
my $str_green='';
my $str_table="
<table border='1' width='100%' cellspacing='2' cellpadding='1'>
<TR><TH width='4%'><font size=2>n</font></TH>
    <TH width='9%'><font size=2>Established</font></TH>
    <TH width='9%'><font size=2>Number</font></TH>
    <TH width='20%'><font size=2>First, Last Name</font></TH>
    <TH width='15%'><font size=2>Company</font></TH>
    <TH width='13%'><font size=2>Country</font></TH>
    <TH width='20%'><font size=2>E-mail</font></TH>
    <TH width='10%'><font size=2>Type</font></TH>
    </TR>";


$searchIN='';
$searchIN=$q->param('searchIN');

$SearchWord=$q->param('SearchWord');
$_=$SearchWord;   (s/^\s+//); (s/\s+$//);  $SearchWord=$_;

if ($SearchWord ne '') {

   $sql="SELECT DISTINCT Profile.Id, Profile.DateCreate, Profile.FirstName, Profile.LastName,
         Profile.CompanyName,  Profile.Email, Country.Name, AccountType.Name,
         Profile.CustomerID, Profile.Status
         FROM AccountType, Profile LEFT JOIN Country ON  Profile.Country = Country.Id
         WHERE $select_Status AccountType.Level=Profile.Perspect
            AND (Profile.DateCreate >='$StartDay' AND Profile.DateCreate <= '$EndDay'
                AND  Profile.DateCreate >= '2005-01-01' )
         ORDER BY Profile.Id DESC ";
   dbexecute($sql);

   while (($Id, $DateCreate, $FirstName, $LastName, $CompanyName, $Email, $Country, $AccountType,
   $CustomerID, $Status) =dbfetch()) {


   ###########################################################
   if ( $Id < 10) { $AccountNumber='000'.$Id; }
   elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
   elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
   else { $AccountNumber=$Id; }
   $curDate=$DateCreate;
   $curDate3=substr($curDate, 2 , 2);
   $curDate2=substr($curDate, 5 , 2);
   $curDate1=substr($curDate, 8 , 2);
   $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
   ##########################################################


   $pathUrlSearch="$pathUrl?comEdit=Edit&code=$code&rowNumber=$rowNumber&Id=$Id";
   $pathUrlSearch.="&StartDay=$StartDay&EndDay=$EndDay&StatusAccount=$StatusAccount&text=yes";

   $URL_FULL=$pathUrlSearch;
   $_= get($URL_FULL);
   if ( m/$SearchWord/i ) {  $searchIN.=$Id.",";  }
   else {  next;  }
  }

}

$str_searchIN='';
if ($searchIN ne '') {
   $str_searchIN="Profile.Id IN (".$searchIN."0) and ";
}


$pathUrlPage="$pathUrl?comEdit=Page&code=$code&rowNumber=$rowNumber";
$pathUrlPage.="&StartDay=$StartDay&EndDay=$EndDay";
$pathUrlPage.="&StatusAccount=$StatusAccount&searchIN=$searchIN";



$sql="SELECT DISTINCT Profile.Id, Profile.DateCreate, Profile.FirstName, Profile.LastName,
         Profile.CompanyName,  Profile.Email, Country.Name, AccountType.Name,
         Profile.CustomerID, Profile.Status
      FROM AccountType, Profile LEFT JOIN Country ON  Profile.Country = Country.Id
      WHERE $str_searchIN $select_Status AccountType.Level=Profile.Perspect
            AND (Profile.DateCreate >='$StartDay' AND Profile.DateCreate <= '$EndDay'
                AND  Profile.DateCreate >= '2005-01-01' )
      ORDER BY Profile.Id DESC ";
dbexecute($sql);


    $CURDATE=get_date();

$i=0;

while (($Id, $DateCreate, $FirstName, $LastName, $CompanyName, $Email, $Country, $AccountType,
$CustomerID, $Status) =dbfetch()) {

  if (($rowFirst<=$i)&&($i<$rowLast))  { # Select only rows for this page
    $n++;

    if ( $Status ==1 ) { $str_font='#AAAAAA'; $str_Status ="<Font color='black'><i>Closed</i></font>"}
    else { $str_font='#DDDDDD';  $str_Status ="<Font color='red'><i>Active</i></font>"}


    ###########################################################
    if ( $Id < 10) { $AccountNumber='000'.$Id; }
    elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
    elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
    else { $AccountNumber=$Id; }
    $curDate=$DateCreate;
    $curDate3=substr($curDate, 2 , 2);
    $curDate2=substr($curDate, 5 , 2);
    $curDate1=substr($curDate, 8 , 2);
    $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
    ##########################################################


    if ($FirstName eq '') {  $body_text="Dear Sir or Madam";  }
    else { $body_text="Dear $FirstName";  }


    $pathUrlEdit="$pathUrl?comEdit=Edit&code=$code&page=$page&rowNumber=$rowNumber&Id=$Id";
    $pathUrlEdit.="&StartDay=$StartDay&EndDay=$EndDay";
    $pathUrlEdit.="&StatusAccount=$StatusAccount&searchIN=$searchIN";
    $str_table.="
    <TR BGCOLOR=$str_font>
    <TD align='center' $str_green><font size=2>
    <a href='$pathUrlEdit'>$n</a></font></TD>
    <TD align='center'><font size=2>$DateCreate</font></TD>
    <TD align='center'><font size=2>$AccountNumber</font></TD>
    <TD align='left'><font size=2>&nbsp;$FirstName $LastName</font></TD>
    <TD align='center'><font size=2>&nbsp;$CompanyName</font></TD>
    <TD align='left'><font size=2>$Country</font></TD>
    <TD align='center'><font size=2><a href='$path_cgi"."adm_sendemail.pl?comSender=Sender_one&code=$code&to=$Email&body_text=$body_text'>$Email</a></font></TD>
        <TD align='center'><font size=2><i>$AccountType</i></font></TD>
    </TR>";
  }
  $i++;
  if ((sprintf("%d",($i%$rowNumber)) == 0 )&&( $limit-1 >= $navig )) {
    $navig++;
    if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT> &nbsp;"; }
    else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a> &nbsp;";}
  }
}
$str_table.="</TABLE>";

if (( $i > $navig*$rowNumber )&&( $limit-1 >= $navig )) {
  $navig++;
  if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT> &nbsp;"; }
  else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a> &nbsp;";}
}
$str_navig="&nbsp;<font size='2'><u>Pages</u>: &nbsp;".$str_navig."</font>";

# Count and check last page
$pageLast=sprintf("%d",($i%$rowNumber));
if ($pageLast==0) {$pageLast=($i/$rowNumber);}
else  {  $pageLast=sprintf("%d",($i/$rowNumber));  $pageLast++;  }
# Create string for html form
if ( $pageLast == 1) { $str_navig=''; }

$str_table.=$str_navig;

$str_page="(".(($page-1)*$rowNumber+1)."-$n of $i)";

if ( $i==0 ) {
  $str_table="
  <H3> NO MATCHES!! </H3>
  Your search did not return any results. Please return to previous page,  broaden your criteria<BR>
  and try again.  If the problem persists, please send description to <a href='mailto:info\@bipcorp.com' ><FONT color='blue'>info\@bipcorp.com</FONT></a>";
  $str_page=0;


}

print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<META content="MSHTML 5.00.2920.0" name=GENERATOR>
</HEAD>
<BODY BGCOLOR='#CCCCCC' link="blue" vlink="blue" >
<H3><u>Search Result</u>: Accounts - $str_page &nbsp;<a href='$pathUrl?comEdit=Search&code=$code'><font size=2></b>New Search</font></a></H3>
$str_report
$str_table

</BODY></HTML>
Browser

}   ##list_account


############################################################################
sub newaccount      #17.02.2000 15:39
############################################################################

{

my $Id=$q->param('Id');
$StartDay=$q->param('StartDay');
$EndDay=$q->param('EndDay');
$StatusAccount=$q->param('StatusAccount');
$rowNumber=$q->param('rowNumber');
$page=$q->param('page');
$searchIN=$q->param('searchIN');


if (( $comEdit eq 'Establish Account'  )||( $comEdit eq 'New'  )){

  $str_button="<input type=submit name=comEdit value='Establish Account' onClick='return checkData()' >";
  $str_name="New";
  $DateCreate_date=get_date();
  $AccountNumber="New";
  if ( !defined $Perspect )  { $Perspect=0;  }
  if ( !defined $EstabDiscountLevel )  { $EstabDiscountLevel="0.00";  }
 

}
else {
  $str_button="<input type=submit name=comEdit value='Save changes' onClick='return checkData()' >
               <input type=submit name=comEdit value='   Cancel   ' >";

  if ( $comEdit eq 'Edit'  ) {


       $sql="SELECT CustomerID, Password, FirstName, LastName, Email,Title,
                    CompanyName, Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip,Status,DateCreate,
                    Category, Perspect, Notes
           FROM Profile
           WHERE  Id=$Id ";
       dbexecute($sql);
      ($CustomerID, $Password, $FirstName, $LastName, $Email, $Title, $CompanyName, $Subscriber,
       $StreetAddress, $City, $State, $Country, $TypeOfBusiness,$TypeOfBusinessSpecify,
       $CurProjShortDescription, $BankReferences, $TradeReferences, $EstabDiscountLevel,
       $PaymentTerms, $Phone, $ShippingStreetAddress, $ShippingCity, $ShippingState,
       $ShippingCountry, $ShippingPhone, $ShippingFax, $ShippingZip, $Fax, $Zip,$Status,
       $DateCreate, $str_Category, $Perspect, $Notes) =dbfetch();
       # Set up check box 'checked' if Billing Adr. equal Shipping Adr.
       if (($StreetAddress eq $ShippingStreetAddress)&&($StreetAddress ne '')&&
       ($City eq $ShippingCity)&&($City ne '')&&($State ne '')&& ( $State eq $ShippingState )&&
       ($Country eq $ShippingCountry)&&($Country ne '')&&($Phone eq $ShippingPhone)&&($Phone ne ''))
       { $checked='CHECKED'; }

  }


    ###########################################################
    if ( $Id < 10) { $AccountNumber='000'.$Id; }
    elsif (( $Id > 9)&&( $Id < 100)) { $AccountNumber='00'.$Id; }
    elsif (( $Id > 99)&&( $Id < 1000)) { $AccountNumber='0'.$Id; }
    else { $AccountNumber=$Id; }
    $curDate=$DateCreate;
    $curDate3=substr($curDate, 2 , 2);
    $curDate2=substr($curDate, 5 , 2);
    $curDate1=substr($curDate, 8 , 2);
    $AccountNumber=$curDate3.$curDate2.$curDate1.$AccountNumber;
    ##########################################################


}


$text=$q->param('text');
if ($text eq 'yes') {

   $sql="SELECT Name FROM TypeOfBusiness WHERE Status=0 and Id=$TypeOfBusiness";
   dbexecute($sql);
   $str_select1=dbfetch();


   $sql="SELECT Name FROM State WHERE Id=$State";
   dbexecute($sql);
   $str_select2=dbfetch();

   $sql="SELECT Name FROM State WHERE Id=$ShippingState";
   dbexecute($sql);
   $str_select21=dbfetch();


   $sql="SELECT Name FROM Country WHERE Id=$Country";
   dbexecute($sql);
   $str_select3=dbfetch();

   $sql="SELECT Name FROM Country WHERE Id=$ShippingCountry";
   dbexecute($sql);
   $str_select31=dbfetch();

   $sql="SELECT Name FROM CreditCard WHERE Status=0 and Id=$PaymentTerms";
   dbexecute($sql);
   $str_select4=dbfetch();


   $sql="SELECT Name FROM AccountType WHERE  Status=0 and Level=$Perspect";
   dbexecute($sql);
   $str_perspect=dbfetch();

}
else {
   $str_select1=type_of_business_box($TypeOfBusiness);
   $str_select2=state_box($State, 0);
   $str_select21=state_box($ShippingState, 1);
   $str_select3=country_box($Country, 0);
   $str_select31=country_box($ShippingCountry, 1);
   $str_perspect=cust_perspect_box($Perspect);
   $str_select4=paymentterms_box_new($PaymentTerms); 
}


if ( $str_Category ne '' ) { @Category=split(/,/, $str_Category); }
my $str_select5=cust_category_box(@Category);

if ($Subscriber == 1) { $Subscriber='CHECKED'; }

$str_radiobutton_status="
   <INPUT type='radio' name=Status value=0  Checked >Active
   <INPUT type='radio' name=Status value=1 >Closed";

if ( $Status==1 ){
   $str_radiobutton_status="
   <INPUT type='radio' name=Status value=0  >Active
   <INPUT type='radio' name=Status value=1 Checked>Closed";
 }


my $str_message=$_[0];
my $scriptvar=$_[1];
if (  $scriptvar==1 ) { $str_scriptvar=$str_message; }
else { $str_scriptvar="document.form1.FirstName.focus();  document.form1.FirstName.select();"; }


#### Account History
$sql = "SELECT Profile_Old.Id FROM Profile_Old  WHERE Profile_Old.Id_Parent=$Id";
dbexecute($sql);
($Id_Old )=dbfetch();
if( defined $Id_Old) {
  $pathUrlHistory=$pathUrl."?comEdit=History&code=$code&Id=$Id&AccountNumber=$AccountNumber";
  $str_History="<a href='$pathUrlHistory' TARGET='WinHistory' onClick='windowHistory()'><font size=2 >Account History List</font></a>";
}
else {
  $str_History="<font size=2 color='blue'>Account History is empty</font>";
}


$sql = "SELECT Id FROM Transactions  WHERE Profile=$Id and Status=0";
dbexecute($sql);
($Id_Trans )=dbfetch();
if( defined $Id_Trans) {

  $pathUrlTransactions=$path_cgi_https."adm_trans.pl?comEdit=Page&code=$code&Id_Profile=$Id&page=1";
  $str_Transactions="<a href='$pathUrlTransactions' TARGET='WinHistory' onClick='windowHistoryTrans()'><font size=2 >Orders History List</font></a>";
}
else {
  $str_Transactions="<font size=2 color='blue'>Orders History is empty.</font>";
}


$sql = "SELECT Id FROM WishList WHERE Profile=$Id  and Status=0";
dbexecute($sql);
($Id_Wish )=dbfetch();
if( defined $Id_Wish) {

  $pathUrlWishList=$path_cgi_https."adm_trans.pl?comEdit=Wish&code=$code&Id_Profile=$Id&AccountNumber=$AccountNumber";
  $str_Wish="<a href='$pathUrlWishList' TARGET='WinWishList' onClick='windowWishList()'><font size=2 >Wish List</font></a>";
}
else {
  $str_Wish="<font size=2 color='blue'>Wish List is empty.</font>";
}


#############################################
$_=$FirstName;     s/\\//g; s/\"/&quot;/g; $FirstName=$_;
$_=$LastName;      s/\\//g; s/\"/&quot;/g; $LastName=$_;
$_=$Email;         s/\\//g; s/\"/&quot;/g; $Email=$_;
$_=$Title;                   s/\\//g; s/\"/&quot;/g; $Title=$_;
$_=$CompanyName;             s/\\//g; s/\"/&quot;/g; $CompanyName=$_;

$_=$StreetAddress; s/\\//g; s/\"/&quot;/g; $StreetAddress=$_;
$_=$City;          s/\\//g; s/\"/&quot;/g; $City=$_;
$_=$State;         s/\\//g; s/\"/&quot;/g; $State=$_;
$_=$Zip;           s/\\//g; s/\"/&quot;/g; $Zip=$_;
$_=$Phone;         s/\\//g; s/\"/&quot;/g; $Phone=$_;
$_=$Fax;           s/\\//g; s/\"/&quot;/g; $Fax=$_;
$_=$ShippingStreetAddress; s/\\//g; s/\"/&quot;/g; $ShippingStreetAddress=$_;
$_=$ShippingCity;          s/\\//g; s/\"/&quot;/g; $ShippingCity=$_;
$_=$ShippingState;         s/\\//g; s/\"/&quot;/g; $ShippingState=$_;
$_=$ShippingZip;           s/\\//g; s/\"/&quot;/g; $ShippingZip=$_;
$_=$ShippingPhone;         s/\\//g; s/\"/&quot;/g; $ShippingPhone=$_;
$_=$ShippingFax;           s/\\//g; s/\"/&quot;/g; $ShippingFax=$_;

$_=$TypeOfBusiness;          s/\\//g; s/\"/&quot;/g; $TypeOfBusiness=$_;
$_=$TypeOfBusinessSpecify;   s/\\//g; s/\"/&quot;/g; $TypeOfBusinessSpecify=$_;

$_=$CurProjShortDescription; s/\\//g; s/\"/&quot;/g; $CurProjShortDescription=$_;
$_=$BankReferences;          s/\\//g; s/\"/&quot;/g; $BankReferences=$_;
$_=$TradeReferences;         s/\\//g; s/\"/&quot;/g; $TradeReferences=$_;
$_=$Notes;                   s/\\//g; s/\"/&quot;/g; $Notes=$_;

if ($CurProjShortDescription ne '') { $CurProjShortDescription.=" "; }
if ($BankReferences ne '') { $BankReferences.=" "; }
if ($TradeReferences ne '') { $TradeReferences.=" "; }
if ($Notes ne '') { $Notes.=" "; }


$_=$EstabDiscountLevel;      s/\\//g; s/\"/&quot;/g; $EstabDiscountLevel=$_;
$_=$CustomerID;       s/\\//g; s/\"/&quot;/g; $CustomerID=$_;
$_=$Password;         s/\\//g; s/\"/&quot;/g; $Password=$_;
$_=$Password2;        s/\\//g; s/\"/&quot;/g; $Password2=$_;
#############################################



print <<Browser;
Content-type: text/html\n\n
<HTML>
<head>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>


<SCRIPT>


// open  Account History in new window
function windowHistory() {
  msgWindow=window.open('$pathUrlHistory>>','WinHistory','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=700,height=420')
}

function windowHistoryTrans() {
  msgWindow=window.open('$pathUrlTransactions>>','WinHistory','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=700,height=420')
}

function windowWishList() {
  msgWindow=window.open('$pathUrlWishList>>','WinWishList','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=700,height=420')
}



// fill 'Shipping Address' fields if they equal to 'Billing Address'
function clearfields(f) {

   if (document.form1.ClearField.checked) {
     document.form1.ShippingStreetAddress.value=document.form1.StreetAddress.value;
     document.form1.ShippingCity.value=document.form1.City.value;
     document.form1.ShippingState.selectedIndex=document.form1.State.selectedIndex;
     document.form1.ShippingCountry.selectedIndex=document.form1.Country.selectedIndex;
     document.form1.ShippingPhone.value=document.form1.Phone.value;
     document.form1.ShippingFax.value=document.form1.Fax.value;
     document.form1.ShippingZip.value=document.form1.Zip.value;

   }
   else  {
     document.form1.ShippingStreetAddress.value='';
     document.form1.ShippingCity.value='';
     document.form1.ShippingState.selectedIndex=0;
     document.form1.ShippingCountry.selectedIndex=0
     document.form1.ShippingPhone.value='';
     document.form1.ShippingFax.value='';
     document.form1.ShippingZip.value='';

  }
}

// shift 'State' pull-box if country not equal USA
function state(f) {
     if (f.Country.selectedIndex != 1) {
        f.State.options[0].selected=true;
     }
}
// shift 'ShippingState' pull-box if ShippingCountry not equal USA
function shippingstate(f) {
     if (f.ShippingCountry.selectedIndex != 1) {
        f.ShippingState.options[0].selected=true;
     }
}


// set Country equal USA if selected state from 'State' pull-box
function country(f) {
   f.Country.options[1].selected=true;
}
// set ShippingCountry equal USA if selected state from 'ShippingState' pull-box
function shippingcountry(f) {
   f.ShippingCountry.options[1].selected=true;
}


// set type of business equal 'other' if Specify is not equal ''
function typeofbusiness(f) {
   if( f.TypeOfBusinessSpecify.value != '') {
        f.TypeOfBusiness.options[1].selected=true;
   }
}
// set Specify equal '' if TypeOfBusiness is not equal 'other'
function typespecify(f) {
   if (f.TypeOfBusiness.selectedIndex != 1) {
      f.TypeOfBusinessSpecify.value = '';
  }

  // if ((f.TypeOfBusiness.selectedIndex != 0)&&(f.TypeOfBusiness.selectedIndex != 1)) {
  //    f.TypeOfBusinessSpecify.value = '';
  //}

}
//validate fields before submit
function checkData () {

if (document.form1.CompanyName.value.length >0) {
if (document.form1.Email.value.length >0) {
if (document.form1.StreetAddress.value.length >0) {
if (document.form1.City.value.length >0) {
if (document.form1.Country.selectedIndex != 0) {
if (((document.form1.State.selectedIndex == 0)&&(document.form1.Country.selectedIndex != 1))||
    ((document.form1.State.selectedIndex != 0)&&(document.form1.Country.selectedIndex == 1))) {
if (document.form1.Zip.value.length >0) {
if (document.form1.Phone.value.length >0) {

if (document.form1.ShippingStreetAddress.value.length >0) {
if (document.form1.ShippingCity.value.length >0) {
if (document.form1.ShippingCountry.selectedIndex != 0) {
if (((document.form1.ShippingState.selectedIndex == 0)&&(document.form1.ShippingCountry.selectedIndex != 1))||
    ((document.form1.ShippingState.selectedIndex != 0)&&(document.form1.ShippingCountry.selectedIndex == 1))) {
if (document.form1.ShippingZip.value.length >0) {
if (document.form1.ShippingPhone.value.length >0) {
if ((document.form1.EstabDiscountLevel.value==0)||((document.form1.EstabDiscountLevel.value>=0)&&(document.form1.EstabDiscountLevel.value<100))) {
   return true}

else { alert("Data in the field \'Established Discount Level\' is incorrect."); document.form1.EstabDiscountLevel.focus();  document.form1.EstabDiscountLevel.select(); return false }
}
else { alert("The field \'Phone\' (Shipping Address) cannot be empty."); document.form1.ShippingPhone.focus();  document.form1.ShippingPhone.select(); return false }
}
else { alert("The field \'Zip\' (Shipping Address) cannot be empty."); document.form1.ShippingZip.focus();  document.form1.ShippingZip.select(); return false }
}
else { alert("The field \'State\' (Shipping Address) cannot be empty."); document.form1.ShippingState.focus();  return false }
}
else { alert("The field \'Country\' (Shipping Address) cannot be empty."); document.form1.ShippingCountry.focus();  return false }
}
else { alert("The field \'City\' (Shipping Address) cannot be empty."); document.form1.ShippingCity.focus();  document.form1.ShippingCity.select(); return false }
}
else { alert("The field \'Street Address\' (Shipping Address) cannot be empty."); document.form1.ShippingStreetAddress.focus();  document.form1.ShippingStreetAddress.select(); return false }
}

else { alert("The field \'Phone\' (Billing Address) cannot be empty."); document.form1.Phone.focus();  document.form1.Phone.select(); return false }
}
else { alert("The field \'Zip\' (Billing Address) cannot be empty."); document.form1.Zip.focus();  document.form1.Zip.select(); return false }
}
else { alert("The field \'State\' (Billing Address) cannot be empty."); document.form1.State.focus(); return false }
}
else { alert("The field \'Country\' (Billing Address) cannot be empty."); document.form1.Country.focus(); return false }
}
else { alert("The field \'City\' (Billing Address) cannot be empty."); document.form1.City.focus();  document.form1.City.select(); return false }
}
else { alert("The field \'Street Address\' (Billing Address) cannot be empty."); document.form1.StreetAddress.focus();  document.form1.StreetAddress.select(); return false }
}
else { alert("The field \'Email\' cannot be empty."); document.form1.Email.focus();  document.form1.Email.select(); return false }
}
else { alert("The field \'Company Name\' cannot be empty."); document.form1.CompanyName.focus();  document.form1.CompanyName.select(); return false }
}


// Set focus on Load or error
function setFocus() {
  $str_scriptvar
 }

</SCRIPT>
</HEAD>
<BODY BGCOLOR='#CCCCCC' onLoad='setFocus()'>
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
<CENTER>
<H3>Account <b># $AccountNumber</b></H3>
<P>

<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="5%"></TH><TH width="70%"></TH><TH width="25%"></TH></TR>
<TR><TD align="left"></TD><TD><font size=2><b>Established: $DateCreate </TD><TD align="left">$str_History</TD></TR>
<tr><TD align="left"></TD><td align="left" ><FONT COLOR="red"size=3 >*</FONT><FONT SIZE=2 > Required field.</FONT></td>
<td align="left" >$str_Transactions</td></tr>
<TR><TD align="left"></TD><TD><font size=2></TD><TD align="left">$str_Wish</TD></TR>

</TABLE>

<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right" valign=top ><B><u>General Info</u>:</B></TD><TD align="left"></TD></TR>
<TR><TD align="right">First Name :</TD>
    <TD align="left"><input type=text name=FirstName value="$FirstName" maxlength=40 size=25></TD></TR>
<TR><TD align="right">Last Name:</TD>
    <TD align="left"><input type=text name=LastName value="$LastName"  maxlength=40 size=25></TD></TR>
<TR><TD align="right">Title:</TD>
    <TD align="left"><input type=text name=Title value="$Title"  maxlength=50 size=40></TD></TR>
<TR><TD align="right">Company Name <font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=CompanyName value="$CompanyName"  maxlength=100 size=40></TD></TR>
<TR><TD align="right">E-mail<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Email value="$Email"   maxlength=50 size=35></TD></TR>
<TR><TD align="right"></TD> <TD align="left"><INPUT type=checkbox value=1 $Subscriber  name=Subscriber> Subscriber for E-mail notifications</TD></TR>
</table>

<table border="0" width="100%" cellspacing="1" cellpadding="3">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right" valign=top ><B><u>Payment Terms</u>:</B></TD> <TD align="left"></TD></TR>
<TR><TD align="right">Account Type:</TD><TD align="left">$str_perspect</TD></TR>
<TR><TD valign="top" align="right">Payment Terms:</TD><TD align="left">$str_select4</TD></TR>
<TR><TD align="right">Established Discount Level:</TD>
    <TD align="left"> <input type=text name=EstabDiscountLevel value="$EstabDiscountLevel" maxlength=10 size=10></TD></TR>
</Table>


<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>


<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>


<TR><TD align="right" valign=top ><B><u>Billing Address</u>:</B></TD> <TD align="left"></TD></TR>
<TR><TD align="right">Street Address<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=StreetAddress value="$StreetAddress" maxlength=100 size=40></TD></TR>
<TR><TD align="right">City<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=City value="$City" maxlength=50 size=30></TD></TR>
<TR><TD align="right">State<font color="red"> * </font>:</TD>
    <TD align="left">$str_select2</TD></TR>
<TR><TD align="right">Country<font color="red"> * </font>:</TD>
    <TD align="left">$str_select3 </TD></TR>
<TR><TD align="right">Zip<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Zip value="$Zip"  maxlength=10 size=10></TD></TR>
<TR><TD align="right">Phone<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Phone value="$Phone"  maxlength=40 size=30></TD></TR>
<TR><TD align="right">Fax :</TD>
    <TD align="left"><input type=text name=Fax value="$Fax"  maxlength=40 size=30></TD></TR>

<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
<TR><TD align="right" valign=top ><B><u>Shipping Address</u>:</B></TD> <TD align="left">
            ( if the same as billing address - click checkbox
             <INPUT type="checkbox"  name="ClearField" $checked
             onClick="clearfields(this)"> <BR> or else specify)</TD></TR>

<TR><TD align="right">Street Address<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingStreetAddress value="$ShippingStreetAddress" maxlength=100 size=40></TD></TR>
<TR><TD align="right">City<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name="ShippingCity" value="$ShippingCity"  maxlength=50 size=30></TD></TR>
<TR><TD align="right">State<font color="red"> * </font>:</TD>
    <TD align="left">$str_select21</TD></TR>
<TR><TD align="right">Country<font color="red"> * </font>:</TD>
    <TD align="left">$str_select31</TD></TR>
<TR><TD align="right">Zip<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingZip value="$ShippingZip" maxlength=10 size=10 ></TD></TR>
<TR><TD align="right">Phone<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingPhone value="$ShippingPhone" maxlength=40 size=30 ></TD></TR>
<TR><TD align="right">Fax :</TD>
    <TD align="left"><input type=text name=ShippingFax value="$ShippingFax" maxlength=40 size=30 ></TD></TR>
<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
</TABLE>

<B><u>Types of products interested in</u>:</B>

$str_select5


<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>

<TR><TD align="right" valign="top" >Type of business:</TD>
    <TD align="left">$str_select1 <BR> if other - specify:
             <input type=text name=TypeOfBusinessSpecify value="$TypeOfBusinessSpecify"
             maxlength=100 size=49 onchange="typeofbusiness(this.form);"></TD></TR>

<TR><TD align="right" valign="top">Current Project Short Description:</TD>
    <TD align="left"><TEXTAREA NAME=CurProjShortDescription ROWS=6 COLS=50>$CurProjShortDescription</TEXTAREA> </TD></TR>
<TR><TD align="right"valign="top" >Bank References:</TD>
    <TD align="left"><TEXTAREA NAME=BankReferences ROWS=6 COLS=50>$BankReferences</TEXTAREA> </TD></TR>
<TR><TD align="right"valign="top" >Trade References:</TD>
    <TD align="left"><TEXTAREA NAME=TradeReferences ROWS=6 COLS=50>$TradeReferences</TEXTAREA> </TD></TR>
<TR><TD align="right" valign="top">Notes:</TD>
    <TD align="left"><TEXTAREA NAME=Notes ROWS=6 COLS=50>$Notes</TEXTAREA> </TD></TR>
</Table>


<table border="0" width="100%" cellspacing="1" cellpadding="3">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
<TR><TD align="right">Login:</TD>
    <TD align="left"><input type=text name=CustomerID value="$CustomerID" maxlength=20 size=20> </TD></TR>
<TR><TD align="right">Password:</TD>
    <TD align="left"><input type=text  name=Password value="$Password" maxlength=10 size=10></TD></TR>
<TR><TD align="right">Re-enter Password:</TD>
    <TD align="left"><input type=text name=Password2 value="$Password" maxlength=10 size=10></TD></TR>

<TR><TD align="right"><br><b>Account Status</b>:</TD>
    <TD align="left"><br>$str_radiobutton_status</TD></TR>

</Table>

<P>
<input type=hidden name=code value="$code">
<input type=hidden name=StartDay value="$StartDay">
<input type=hidden name=EndDay value="$EndDay">
<input type=hidden name=StatusAccount value="$StatusAccount">
<input type=hidden name=rowNumber value="$rowNumber">
<input type=hidden name=searchIN value="$searchIN">
<input type=hidden name=page value=$page>
<input type=hidden name=Id value=$Id>
<input type=hidden name=DateCreate value=$DateCreate>

$str_button
<br><br>
</CENTER></FORM></BODY></HTML>

Browser

} ##new_account


############################################################################
sub db_newaccount      #17.02.2000 15:39
############################################################################

{


# Get data of the selected Customer
$DateCreate=$q->param('DateCreate');


$Id=$q->param('Id');
$CustomerID=$q->param('CustomerID');
$Password=$q->param('Password');
$Password2=$q->param('Password2');
$FirstName=$q->param('FirstName');
$LastName=$q->param('LastName');
$Email=$q->param('Email');
$Title=$q->param('Title');
$CompanyName=$q->param('CompanyName');
$Subscriber=$q->param('Subscriber');
if ($Subscriber eq '') { $Subscriber=0; }


# Billing Address
$City=$q->param('City');
$State=$q->param('State');
$Country=$q->param('Country');
$StreetAddress=$q->param('StreetAddress');
$Zip=$q->param('Zip');
$Phone=$q->param('Phone');
$Fax=$q->param('Fax');
# Shipping Address
$ShippingStreetAddress=$q->param('ShippingStreetAddress');
$ShippingCity=$q->param('ShippingCity');
$ShippingState=$q->param('ShippingState');
$ShippingCountry=$q->param('ShippingCountry');
$ShippingZip=$q->param('ShippingZip');
$ShippingPhone=$q->param('ShippingPhone');
$ShippingFax=$q->param('ShippingFax');

$TypeOfBusiness=$q->param('TypeOfBusiness');
$TypeOfBusinessSpecify=$q->param('TypeOfBusinessSpecify');
$CurProjShortDescription=$q->param('CurProjShortDescription');
$BankReferences=$q->param('BankReferences');
$TradeReferences=$q->param('TradeReferences');
$EstabDiscountLevel=$q->param('EstabDiscountLevel');
  if ( $EstabDiscountLevel eq '')  { $EstabDiscountLevel="0.00"; }
$PaymentTerms=$q->param('PaymentTerms');

# Get Category interested in
@Category=$q->param('Category');
$i=0;
foreach (@Category) {
   $i++;
   if ( $i==1 ) { $str_Category.=$_; }
   else { $str_Category.=",".$_; }
}

# Set up status of the customer
$Perspect=$q->param('Perspect');
if ( $Perspect eq ''){ $Perspect = 0;}

$Notes=$q->param('Notes');

$Status=$q->param('Status');
if ( $Status eq ''){ $Status = 0;}


# check fields before enter database
#############################################
$_=$FirstName;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $FirstName=$_;
$_=$LastName;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $LastName=$_;
$_=$Email;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Email=$_;
$_=$Title;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Title=$_;
$_=$CompanyName;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CompanyName=$_;

$_=$StreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $StreetAddress=$_;
$_=$City;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $City=$_;
$_=$State;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $State=$_;
$_=$Zip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Zip=$_;
$_=$Phone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Phone=$_;
$_=$Fax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Fax=$_;
$_=$ShippingStreetAddress; (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingStreetAddress=$_;
$_=$ShippingCity;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingCity=$_;
$_=$ShippingState;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingState=$_;
$_=$ShippingZip;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingZip=$_;
$_=$ShippingPhone;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingPhone=$_;
$_=$ShippingFax;          (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippingFax=$_;

$_=$TypeOfBusiness;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TypeOfBusiness=$_;
$_=$TypeOfBusinessSpecify;  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TypeOfBusinessSpecify=$_;
$_=$CurProjShortDescription;(s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CurProjShortDescription=$_;
$_=$BankReferences;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $BankReferences=$_;
$_=$TradeReferences;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TradeReferences=$_;
$_=$EstabDiscountLevel;     (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $EstabDiscountLevel=$_;
$_=$Notes;                  (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Notes=$_;

$_=$CustomerID;      (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $CustomerID=$_;
$_=$Password;        (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password=$_;
$_=$Password2;       (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $Password2=$_;
#############################################


if (&email_check($Email)==0) {
   newaccount("document.form1.Email.focus();  document.form1.Email.select();
   alert('Incorrect Email Address. The Account has not been accepted !')", 1 );
   return;
 }



######### Establish Account ##########
if ( $comEdit eq 'Establish Account'  ){

   ##### Check User Name
  if ($CustomerID ne '') {

     $sql="SELECT CustomerID FROM Profile WHERE CustomerID='$CustomerID'";
     dbexecute($sql);
     ($CustomerID_check) =dbfetch();
     if ( defined $CustomerID_check ) {
       newaccount("document.form1.CustomerID.focus();  document.form1.CustomerID.select();
       alert('This Login is used by other user. Please select another Login.')", 1 );
       return;
     }
  }


  $sql="INSERT INTO Profile (
            CustomerID , Password , FirstName, LastName, Email, Title, CompanyName, Subscriber,
            StreetAddress, City, State, Country,TypeOfBusiness, TypeOfBusinessSpecify,
            CurProjShortDescription, BankReferences,TradeReferences,EstabDiscountLevel,
            PaymentTerms, Status,Phone, ShippingStreetAddress, ShippingCity,
            ShippingState, ShippingCountry, ShippingPhone,
            Fax, Zip, ShippingFax, ShippingZip, DateCreate,Category,Perspect,
            Notes )
     VALUES ('$CustomerID','$Password', '$FirstName', '$LastName', '$Email','$Title',
            '$CompanyName', $Subscriber, '$StreetAddress','$City','$State','$Country','$TypeOfBusiness',
            '$TypeOfBusinessSpecify','$CurProjShortDescription','$BankReferences',
            '$TradeReferences', $EstabDiscountLevel,'$PaymentTerms',0 ,'$Phone', '$ShippingStreetAddress',
            '$ShippingCity', '$ShippingState','$ShippingCountry', '$ShippingPhone',
            '$Fax', '$Zip', '$ShippingFax', '$ShippingZip', '$DateCreate',
            '$str_Category',$Perspect , '$Notes')";


  if (dbdo($sql)) {

   $CustomerID=''; $Password=''; $Password2='';  $FirstName=''; $LastName='';
   $Email=''; $Title=''; $CompanyName=''; $Subscriber='';  $StreetAddress=''; $City ='';
   $State=''; $Country=''; $TypeOfBusiness=''; $TypeOfBusinessSpecify='';
   $CurProjShortDescription=''; $BankReferences='';
   $TradeReferences=''; $EstabDiscountLevel='0.00'; $PaymentTerms=''; $Status=0;
   $Phone=''; $ShippingStreetAddress=''; $ShippingCity=''; $ShippingState='';
   $ShippingCountry=''; $ShippingPhone='';  $Fax=''; $Zip='';
   $ShippingFax=''; $ShippingZip=''; $DateCreate=''; $Parent='';
   @Category=''; $Perspect=0; $Notes=''; $str_Category='';

   newaccount ("document.form1.FirstName.focus();  document.form1.FirstName.select();
   alert('New Account has been established')", 1 );
   return ;
  }
  else  {
    newaccount ("document.form1.FirstName.focus();  document.form1.FirstName.select();
    alert('Database error. The Record has not been inserted !')", 1 );
    return ;
  }
}


############# Save Changes ##################
elsif ( $comEdit eq 'Save changes'  ){

  ##### Check User Name
  if ($CustomerID ne '') {
    $sql="SELECT Id FROM Profile WHERE CustomerID='$CustomerID'";
    dbexecute($sql);

    while(($Id_check) =dbfetch()) {
      if ($Id_check ne $Id) {
        newaccount("document.form1.CustomerID.focus();  document.form1.CustomerID.select();
        alert('This Login is used by other user. Please select another Login.')", 1 );
        return;
      }
    }
  }

   $DateCreateOld=get_date();
   $sql="INSERT INTO Profile_Old ( Id_Parent, CustomerID, Password, FirstName, LastName, Email, Title,
                    CompanyName, Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip, Status, DateCreate,
                    Category, Perspect, Notes  )
             SELECT Id, CustomerID, Password, FirstName, LastName, Email, Title,
                    CompanyName, $Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip, Status, '$DateCreateOld',
                    Category, Perspect, Notes
             FROM Profile
             WHERE Id=$Id ";
   dbdo($sql);


   $sql="UPDATE Profile SET CustomerID='$CustomerID',Password='$Password',
                FirstName='$FirstName', LastName='$LastName', Email='$Email', Title='$Title',
                CompanyName='$CompanyName', Subscriber=$Subscriber,StreetAddress='$StreetAddress',City='$City',
                State='$State',Country='$Country',TypeOfBusiness='$TypeOfBusiness',
                CurProjShortDescription='$CurProjShortDescription',BankReferences='$BankReferences',
                TradeReferences='$TradeReferences', EstabDiscountLevel=$EstabDiscountLevel,
                PaymentTerms='$PaymentTerms',TypeOfBusinessSpecify='$TypeOfBusinessSpecify',
                Phone='$Phone', ShippingStreetAddress='$ShippingStreetAddress',
                ShippingCity='$ShippingCity', ShippingState='$ShippingState',
                ShippingCountry='$ShippingCountry', ShippingPhone='$ShippingPhone',
                ShippingZip='$ShippingZip',ShippingFax='$ShippingFax',
                Zip='$Zip', Fax='$Fax',Category ='$str_Category',Perspect=$Perspect,
                Notes='$Notes', Status=$Status
          WHERE Id=$Id";


  if (dbdo($sql)) {
    list_account("Account information has been saved."); return ;
  }
  else {
     # Return to previous form ('Modify') with error  message
     newaccount("document.form1.FirstName.focus();  document.form1.FirstName.select();
     alert('Database error. The record has not been saved !')", 1 );
     return;
  }
}


} ##db_newaccount



############################################################################
sub history_list_account      #17.02.2000 15:39
############################################################################

{

my $limit=100;
$Id=$q->param('Id');
$AccountNumber=$q->param('AccountNumber');


$str_table="<table border='1' width='100%' cellspacing='2' cellpadding='1'>
<TR><TH width='4%'><font size=2>n</font></TH>
    <TH width='11%'><font size=2>Modified</font></TH>
    <TH width='25%'><font size=2>First, Last Name</font></TH>
    <TH width='20%'><font size=2>Company</font></TH>
    <TH width='15%'><font size=2>City</font></TH>
    <TH width='15%'><font size=2>Country</font></TH>
    <TH width='10%'><font size=2>Status</font></TH>

    </TR>";



$sql="SELECT DISTINCT Profile_Old.Id, Profile_Old.DateCreate, Profile_Old.FirstName, Profile_Old.LastName,
         Profile_Old.CompanyName,  Profile_Old.City, Country.Name, State.Name,
         Profile_Old.CustomerID, Profile_Old.Status
      FROM State, Profile_Old LEFT JOIN Country ON  Profile_Old.Country = Country.Id
      WHERE State.Id=Profile_Old.State and Profile_Old.Id_Parent=$Id
      ORDER BY Profile_Old.Id DESC ";
dbexecute($sql);


$n=0;

while (($Id_Old, $DateCreate, $FirstName, $LastName,$CompanyName,$City, $Country, $State,
$CustomerID, $Status) =dbfetch()) {


    if ( $Status ==1 ) { $str_font='#AAAAAA'; $str_Status ="<Font color='black'><i>Closed</i></font>"}
    else { $str_font='#DDDDDD';  $str_Status ="<Font color='red'><i>Active</i></font>"}

    $n++;
    $pathUrlEdit="$pathUrl?comEdit=Edit_Old&code=$code&Id=$Id_Old&AccountNumber=$AccountNumber";

    $str_table.="
    <TR BGCOLOR=$str_font>
    <TD align='center' $str_green><font size=2>
    <a href='$pathUrlEdit'>$n</a></font></TD>
    <TD align='center'><font size=2>$DateCreate</font></TD>
    <TD align='left'><font size=2>&nbsp;$FirstName $LastName</font></TD>
    <TD align='center'><font size=2>&nbsp;$CompanyName</font></TD>
    <TD align='left'><font size=2>$City</font></TD>
    <TD align='left'><font size=2>$Country</font></TD>
    <TD align='center'><font size=2>$str_Status</font></TD>
    </TR>";

}
$str_table.="</TABLE>";


if ( $n==0 ) {
  $str_table="
  <H3> NO MATCHES!! </H3>
  Your search did not return any results. Please return to previous page,  broaden your criteria<BR>
  and try again.  If the problem persists, please send description to <a href='mailto:info\@bipcorp.com' ><FONT color='blue'>info\@bipcorp.com</FONT></a>";

}


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin / Customer Account History List</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<META content="MSHTML 5.00.2920.0" name=GENERATOR>
</HEAD>
<BODY BGCOLOR='#CCCCCC' link="blue" vlink="blue" >
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
<H3><u>Account #$AccountNumber History List</u></H3>
$str_table
<br><br>
<input type=button name=comEdit value='Close Window' onClick='self.close()'>
</form>

</BODY></HTML>
Browser

}   ##history_list_account




############################################################################
sub history_newaccount      #17.02.2000 15:39
############################################################################

{

$Id=$q->param('Id');
$AccountNumber=$q->param('AccountNumber');


       $sql="SELECT CustomerID, Password, FirstName, LastName, Email,Title,
                    CompanyName, Subscriber, StreetAddress, City, State, Country,
                    TypeOfBusiness,TypeOfBusinessSpecify, CurProjShortDescription, BankReferences,
                    TradeReferences, EstabDiscountLevel, PaymentTerms,Phone,
                    ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
                    ShippingPhone, ShippingFax, ShippingZip, Fax, Zip,Status,DateCreate,
                    Category, Perspect, Notes
           FROM Profile_Old
           WHERE  Id=$Id ";
       dbexecute($sql);
      ($CustomerID, $Password, $FirstName, $LastName, $Email, $Title, $CompanyName, $Subscriber,
       $StreetAddress, $City, $State, $Country, $TypeOfBusiness,$TypeOfBusinessSpecify,
       $CurProjShortDescription, $BankReferences, $TradeReferences, $EstabDiscountLevel,
       $PaymentTerms, $Phone, $ShippingStreetAddress, $ShippingCity, $ShippingState,
       $ShippingCountry, $ShippingPhone, $ShippingFax, $ShippingZip, $Fax, $Zip,$Status,
       $DateCreate,$str_Category,$Perspect,$Notes) =dbfetch();
       # Set up check box 'checked' if Billing Adr. equal Shipping Adr.
       if (($StreetAddress eq $ShippingStreetAddress)&&($StreetAddress ne '')&&
       ($City eq $ShippingCity)&&($City ne '')&&($State ne '')&& ( $State eq $ShippingState )&&
       ($Country eq $ShippingCountry)&&($Country ne '')&&($Phone eq $ShippingPhone)&&($Phone ne ''))
       { $checked='CHECKED'; }



# Create pull-boxes for the form
my $str_select1=type_of_business_box($TypeOfBusiness);
my $str_select2=state_box($State, 0);
my $str_select21=state_box($ShippingState, 1);
my $str_select3=country_box($Country, 0);
my $str_select31=country_box($ShippingCountry, 1);
my $str_perspect=cust_perspect_box($Perspect);
my $str_select4=paymentterms_box_new($PaymentTerms);
if ( $str_Category ne '' ) { @Category=split(/,/, $str_Category); }
my $str_select5=cust_category_box(@Category);

if ($Subscriber == 1) { $Subscriber='CHECKED'; }


$str_radiobutton_status="
   <INPUT type='radio' name=Status value=0  Checked >Active
   <INPUT type='radio' name=Status value=1 >Closed";

if ( $Status==1 ){
   $str_radiobutton_status="
   <INPUT type='radio' name=Status value=0  >Active
   <INPUT type='radio' name=Status value=1 Checked>Closed";
 }

#############################################
$_=$FirstName;     s/\\//g; s/\"/&quot;/g; $FirstName=$_;
$_=$LastName;      s/\\//g; s/\"/&quot;/g; $LastName=$_;
$_=$Email;         s/\\//g; s/\"/&quot;/g; $Email=$_;
$_=$Title;                   s/\\//g; s/\"/&quot;/g; $Title=$_;
$_=$CompanyName;             s/\\//g; s/\"/&quot;/g; $CompanyName=$_;

$_=$StreetAddress; s/\\//g; s/\"/&quot;/g; $StreetAddress=$_;
$_=$City;          s/\\//g; s/\"/&quot;/g; $City=$_;
$_=$State;         s/\\//g; s/\"/&quot;/g; $State=$_;
$_=$Zip;           s/\\//g; s/\"/&quot;/g; $Zip=$_;
$_=$Phone;         s/\\//g; s/\"/&quot;/g; $Phone=$_;
$_=$Fax;           s/\\//g; s/\"/&quot;/g; $Fax=$_;
$_=$ShippingStreetAddress; s/\\//g; s/\"/&quot;/g; $ShippingStreetAddress=$_;
$_=$ShippingCity;          s/\\//g; s/\"/&quot;/g; $ShippingCity=$_;
$_=$ShippingState;         s/\\//g; s/\"/&quot;/g; $ShippingState=$_;
$_=$ShippingZip;           s/\\//g; s/\"/&quot;/g; $ShippingZip=$_;
$_=$ShippingPhone;         s/\\//g; s/\"/&quot;/g; $ShippingPhone=$_;
$_=$ShippingFax;           s/\\//g; s/\"/&quot;/g; $ShippingFax=$_;

$_=$TypeOfBusiness;          s/\\//g; s/\"/&quot;/g; $TypeOfBusiness=$_;
$_=$TypeOfBusinessSpecify;   s/\\//g; s/\"/&quot;/g; $TypeOfBusinessSpecify=$_;
$_=$CurProjShortDescription; s/\\//g; s/\"/&quot;/g; $CurProjShortDescription=$_;
$_=$BankReferences;          s/\\//g; s/\"/&quot;/g; $BankReferences=$_;
$_=$TradeReferences;         s/\\//g; s/\"/&quot;/g; $TradeReferences=$_;
$_=$EstabDiscountLevel;      s/\\//g; s/\"/&quot;/g; $EstabDiscountLevel=$_;
$_=$Notes;                   s/\\//g; s/\"/&quot;/g; $Notes=$_;

$_=$CustomerID;       s/\\//g; s/\"/&quot;/g; $CustomerID=$_;
$_=$Password;         s/\\//g; s/\"/&quot;/g; $Password=$_;
$_=$Password2;        s/\\//g; s/\"/&quot;/g; $Password2=$_;
#############################################

print <<Browser;
Content-type: text/html\n\n
<HTML>
<TITLE>Admin / Customer Account History</TITLE>
<head>
<SCRIPT>



// fill 'Shipping Address' fields if they equal to 'Billing Address'
function clearfields(f) {

   if (document.form1.ClearField.checked) {
     document.form1.ShippingStreetAddress.value=document.form1.StreetAddress.value;
     document.form1.ShippingCity.value=document.form1.City.value;
     document.form1.ShippingState.selectedIndex=document.form1.State.selectedIndex;
     document.form1.ShippingCountry.selectedIndex=document.form1.Country.selectedIndex;
     document.form1.ShippingPhone.value=document.form1.Phone.value;
     document.form1.ShippingFax.value=document.form1.Fax.value;
     document.form1.ShippingZip.value=document.form1.Zip.value;

   }
   else  {
     document.form1.ShippingStreetAddress.value='';
     document.form1.ShippingCity.value='';
     document.form1.ShippingState.selectedIndex=0;
     document.form1.ShippingCountry.selectedIndex=0
     document.form1.ShippingPhone.value='';
     document.form1.ShippingFax.value='';
     document.form1.ShippingZip.value='';

  }
}

// shift 'State' pull-box if country not equal USA
function state(f) {
     if (f.Country.selectedIndex != 1) {
        f.State.options[0].selected=true;
     }
}
// shift 'ShippingState' pull-box if ShippingCountry not equal USA
function shippingstate(f) {
     if (f.ShippingCountry.selectedIndex != 1) {
        f.ShippingState.options[0].selected=true;
     }
}


// set Country equal USA if selected state from 'State' pull-box
function country(f) {
   f.Country.options[1].selected=true;
}
// set ShippingCountry equal USA if selected state from 'ShippingState' pull-box
function shippingcountry(f) {
   f.ShippingCountry.options[1].selected=true;
}


// set type of business equal 'other' if Specify is not equal ''
function typeofbusiness(f) {
   if( f.TypeOfBusinessSpecify.value != '') {
        f.TypeOfBusiness.options[1].selected=true;
   }
}
// set Specify equal '' if TypeOfBusiness is not equal 'other'
function typespecify(f) {
   if ((f.TypeOfBusiness.selectedIndex != 0)&&(f.TypeOfBusiness.selectedIndex != 1)) {
      f.TypeOfBusinessSpecify.value = '';
  }
}
//validate fields before submit
function checkData () {

if (document.form1.CompanyName.value.length >0) {
if (document.form1.Email.value.length >0) {
if (document.form1.StreetAddress.value.length >0) {
if (document.form1.City.value.length >0) {
if (document.form1.Country.selectedIndex != 0) {
if (((document.form1.State.selectedIndex == 0)&&(document.form1.Country.selectedIndex != 1))||
    ((document.form1.State.selectedIndex != 0)&&(document.form1.Country.selectedIndex == 1))) {
if (document.form1.Zip.value.length >0) {
if (document.form1.Phone.value.length >0) {

if (document.form1.ShippingStreetAddress.value.length >0) {
if (document.form1.ShippingCity.value.length >0) {
if (document.form1.ShippingCountry.selectedIndex != 0) {
if (((document.form1.ShippingState.selectedIndex == 0)&&(document.form1.ShippingCountry.selectedIndex != 1))||
    ((document.form1.ShippingState.selectedIndex != 0)&&(document.form1.ShippingCountry.selectedIndex == 1))) {
if (document.form1.ShippingZip.value.length >0) {
if (document.form1.ShippingPhone.value.length >0) {
   return true}

else { alert("The field \'Phone\' (Shipping Address) cannot be empty."); document.form1.ShippingPhone.focus();  document.form1.ShippingPhone.select(); return false }
}
else { alert("The field \'Zip\' (Shipping Address) cannot be empty."); document.form1.ShippingZip.focus();  document.form1.ShippingZip.select(); return false }
}
else { alert("The field \'State\' (Shipping Address) cannot be empty."); document.form1.ShippingState.focus();  return false }
}
else { alert("The field \'Country\' (Shipping Address) cannot be empty."); document.form1.ShippingCountry.focus();  return false }
}
else { alert("The field \'City\' (Shipping Address) cannot be empty."); document.form1.ShippingCity.focus();  document.form1.ShippingCity.select(); return false }
}
else { alert("The field \'Street Address\' (Shipping Address) cannot be empty."); document.form1.ShippingStreetAddress.focus();  document.form1.ShippingStreetAddress.select(); return false }
}

else { alert("The field \'Phone\' (Billing Address) cannot be empty."); document.form1.Phone.focus();  document.form1.Phone.select(); return false }
}
else { alert("The field \'Zip\' (Billing Address) cannot be empty."); document.form1.Zip.focus();  document.form1.Zip.select(); return false }
}
else { alert("The field \'State\' (Billing Address) cannot be empty."); document.form1.State.focus(); return false }
}
else { alert("The field \'Country\' (Billing Address) cannot be empty."); document.form1.Country.focus(); return false }
}
else { alert("The field \'City\' (Billing Address) cannot be empty."); document.form1.City.focus();  document.form1.City.select(); return false }
}
else { alert("The field \'Street Address\' (Billing Address) cannot be empty."); document.form1.StreetAddress.focus();  document.form1.StreetAddress.select(); return false }
}
else { alert("The field \'Email\' cannot be empty."); document.form1.Email.focus();  document.form1.Email.select(); return false }
}
else { alert("The field \'Company Name\' cannot be empty."); document.form1.CompanyName.focus();  document.form1.CompanyName.select(); return false }
}


// Set focus on Load or error
function setFocus() {
  document.form1.FirstName.focus();  document.form1.FirstName.select();
 }

</SCRIPT>
</HEAD>
<BODY BGCOLOR='#CCCCCC' onLoad='setFocus()'>
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
<CENTER>
<H3>Account # $AccountNumber History</H3>
<P>

<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="5%"></TH><TH width="70%"></TH><TH width="25%"></TH></TR>
<TR><TD align="left"></TD>
<TD align="left"><font size=2>Modified: $DateCreate </font></TD>
<TD></TD></TR>

</TABLE>

<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right" valign=top ><B><u>General Info</u>:</B></TD> <TD align="left"></td></TR>
<TR><TD align="right">First Name :</TD>
    <TD align="left"><input type=text name=FirstName value="$FirstName" maxlength=40 size=25></TD></TR>
<TR><TD align="right">Last Name:</TD>
    <TD align="left"><input type=text name=LastName value="$LastName"  maxlength=40 size=25></TD></TR>
<TR><TD align="right">Title:</TD>
    <TD align="left"><input type=text name=Title value="$Title"  maxlength=50 size=40></TD></TR>
<TR><TD align="right">Company Name <font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=CompanyName value="$CompanyName"  maxlength=100 size=40></TD></TR>
<TR><TD align="right">E-mail<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Email value="$Email"   maxlength=50 size=35></TD></TR>
<TR><TD align="right">Status:</TD><TD align="left">$str_perspect</TD></TR>
<TR><TD align="right"></TD> <TD align="left"><INPUT type=checkbox value=1 $Subscriber  name=Subscriber> Subscriber for E-mail notifications</TD></TR>
<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>

<TR><TD align="right" valign=top ><B><u>Billing Address</u>:</B></TD> <TD align="left"></td></TR>
<TR><TD align="right">Street Address<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=StreetAddress value="$StreetAddress" maxlength=100 size=40></TD></TR>
<TR><TD align="right">City<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=City value="$City" maxlength=50 size=30></TD></TR>
<TR><TD align="right">State<font color="red"> * </font>:</TD>
    <TD align="left">$str_select2</TD></TR>
<TR><TD align="right">Country<font color="red"> * </font>:</TD>
    <TD align="left">$str_select3 </TD></TR>
<TR><TD align="right">Zip<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Zip value="$Zip"  maxlength=10 size=10></TD></TR>
<TR><TD align="right">Phone<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=Phone value="$Phone"  maxlength=40 size=30></TD></TR>
<TR><TD align="right">Fax :</TD>
    <TD align="left"><input type=text name=Fax value="$Fax"  maxlength=40 size=30></TD></TR>

<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
<TR><TD align="right" valign=top ><B><u>Shipping Address</u>:</B></TD> <TD align="left">
            ( if the same as billing address - ON checkbox
             <INPUT type="checkbox"  name="ClearField" $checked
             onClick="clearfields(this)"> <BR> else - specify)</TD></TR>

<TR><TD align="right">Street Address<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingStreetAddress value="$ShippingStreetAddress" maxlength=100 size=40></TD></TR>
<TR><TD align="right">City<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name="ShippingCity" value="$ShippingCity"  maxlength=50 size=30></TD></TR>
<TR><TD align="right">State<font color="red"> * </font>:</TD>
    <TD align="left">$str_select21</TD></TR>
<TR><TD align="right">Country<font color="red"> * </font>:</TD>
    <TD align="left">$str_select31</TD></TR>
<TR><TD align="right">Zip<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingZip value="$ShippingZip" maxlength=10 size=10 ></TD></TR>
<TR><TD align="right">Phone<font color="red"> * </font>:</TD>
    <TD align="left"><input type=text name=ShippingPhone value="$ShippingPhone" maxlength=40 size=30 ></TD></TR>
<TR><TD align="right">Fax :</TD>
    <TD align="left"><input type=text name=ShippingFax value="$ShippingFax" maxlength=40 size=30 ></TD></TR>
<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
</TABLE>

<B>Types of products interested in:</B>

$str_select5


<table border="0" width="100%" cellspacing="1" cellpadding="2">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>

<TR><TD align="right" valign="top" >Type of business:</TD>
    <TD align="left">$str_select1 <BR> if other - specify:
             <input type=text name=TypeOfBusinessSpecify value="$TypeOfBusinessSpecify"
             maxlength=100 size=49 onchange="typeofbusiness(this.form);"></TD></TR>

<TR><TD align="right" valign="top">Current Project Short Description:</TD>
    <TD align="left"><TEXTAREA NAME=CurProjShortDescription ROWS=6 COLS=50>$CurProjShortDescription</TEXTAREA> </TD></TR>
<TR><TD align="right"valign="top" >Bank References:</TD>
    <TD align="left"><TEXTAREA NAME=BankReferences ROWS=6 COLS=50>$BankReferences</TEXTAREA> </TD></TR>
<TR><TD align="right"valign="top" >Trade References:</TD>
    <TD align="left"><TEXTAREA NAME=TradeReferences ROWS=6 COLS=50>$TradeReferences</TEXTAREA> </TD></TR>
<TR><TD align="right" valign="top">Notes:</TD>
    <TD align="left"><TEXTAREA NAME=Notes ROWS=6 COLS=50>$Notes</TEXTAREA> </TD></TR>
</Table>


<table border="0" width="100%" cellspacing="1" cellpadding="3">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right">Established Discount Level:</TD>
    <TD align="left"> <input type=text name=EstabDiscountLevel value="$EstabDiscountLevel" maxlength=13 size=13></TD></TR>
<TR><TD valign="top" align="right">Payment Terms:</TD><TD align="left">$str_select4</TD></TR>
</Table>

<table border="0" width="100%" cellspacing="1" cellpadding="3">
<TR><TH width="30%"></TH><TH width="70%"></TH></TR>
<TR><TD align="right"><BR></TD> <TD align="left"></TD></TR>
<TR><TD align="right">Login:</TD>
    <TD align="left"><input type=text name=CustomerID value="$CustomerID" maxlength=20 size=20></TD></TR>
<TR><TD align="right">Password:</TD>
    <TD align="left"><input type=text  name=Password value="$Password" maxlength=10 size=10></TD></TR>
<TR><TD align="right">Re-enter Password:</TD>
    <TD align="left"><input type=text name=Password2 value="$Password" maxlength=10 size=10></TD></TR>

<TR><TD align="right">Status:</TD>
    <TD align="left">$str_radiobutton_status</TD></TR>

</Table>

<P>
<input type=hidden name=code value="$code">
<input type=button name=comEdit value='Return to previous page' onClick='self.history.back()'>
</CENTER></FORM></BODY></HTML>
Browser


} ##history_newaccount

