#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / adm_trans.pl
#
############################################################################

use CGI;
use LWP::Simple;
$q = new CGI;

require 'db.pl';
require 'library.pl';

# set path for the forms of the current script
$pathUrl =$path_cgi_https.'adm_trans.pl';
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
if ( $comEdit eq ''                  ) { accessdenied();    }
elsif ( $comEdit eq 'Edit'           ) { transactions();    }
elsif ( $comEdit eq ' Save changes ' ) { db_transactions(); }
elsif ( $comEdit eq ' Delete order ' ) { db_transactions();  }
elsif ( $comEdit eq ' Cancel '       ) { list_transactions();  }
elsif ( $comEdit eq ' Printer friendly ' ) { transactions();    }


elsif ( $comEdit eq 'Search'        ) { query_transactions(); }
elsif ( $comEdit eq '  Query  '     ) { list_transactions();  }
elsif ( $comEdit eq 'Page'          ) { list_transactions();  }
elsif ( $comEdit eq 'Wish'          ) { wishlist();  }


}  ##enter


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


############################################################################
sub query_transactions      #17.02.2000 15:39
############################################################################

{

$StartDay=get_date(1);
$EndDay=get_date();


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLEAdmin</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
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
<BR><CENTER><h3>Orders Information</h3>
<table border='0' width='100%' cellspacing='0' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='15%'></TH><TH width='15%'></TH><TH width='45%'></TH></TR>
<hr width='70%'>
<br>
<TR ><TD align='right'>Established from:&nbsp;&nbsp;</TD>
    <TD align='left'> <input type=text name=StartDay value=$StartDay maxlength=10 size=10></TD>
    <TD align='right'>To:&nbsp;&nbsp;</TD>
    <TD align='left'> <input type=text name=EndDay value=$EndDay maxlength=10 size=10>
<INPUT type='checkbox' name='Period' value='1' onClick='all_dates()'> <font color='black' size=3> Select all dates</font>

    </TD>
</TR>
</TABLE>

<br>

<table border='0' width='100%' cellspacing='' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='15%'></TH><TH width='15%'></TH><TH width='45%'></TH></TR>
<TR ><TD align='right'>Order Status:&nbsp;&nbsp;</TD>
    <TD align='left'> <select name='StatusOrder'>
       <OPTION SELECTED VALUE=0>Active</OPTION>
       <OPTION VALUE=1>Deleted</OPTION>
       <OPTION VALUE=2>All Orders</OPTION>
       </SELECT></TD>
    <TD align='right'>Max.Rows:&nbsp;&nbsp;</TD>
    <TD valign='top'> <input type=text name=rowNumber value=20 maxlength=2 size=2> (on the page) </TD>
</TR>
</TABLE>

<BR>

<table border='0' width='100%' cellspacing='0' cellpadding='0'>
<TR><TH width='25%'></TH><TH width='75%'></TH></TR>
<TR><TD align='right'>Keyword(s) search:&nbsp;&nbsp;</TD>
    <TD align='left'> <input type=text name=SearchWord value='' maxlength=50 size=45> </TD>
</TR>
</TABLE>


<BR>
<hr width='70%'>
<BR>
<input type=hidden name=code value='$code'>
<input type=hidden name=page value='1'>

<input type=submit name=comEdit value='  Query  ' >

</CENTER>
</FORM>
</BODY></HTML>
Browser


}   ##query_transactions



############################################################################
sub list_transactions      #17.02.2000 15:39
############################################################################

{


my $limit=100;

$StartDay=$q->param('StartDay');
$EndDay=$q->param('EndDay');
$rowNumber=$q->param('rowNumber');
# Check Status
$StatusOrder=$q->param('StatusOrder');
if ( $StatusOrder == 0) { $select_Status=" Transactions.Status = 0 AND ";  }
elsif ( $StatusOrder == 1) { $select_Status=" Transactions.Status = 1 AND ";  }
else { $select_Status=""; }
$str_button='';


$Id_Profile=$q->param('Id_Profile');
if ( $Id_Profile ) {
   $StartDay="2000-01-01";
   $EndDay=get_date();
   $rowNumber=20;
   $select_Status=" Transactions.Status = 0 AND Profile=$Id_Profile AND ";
   $str_button="<input type=button name=comEdit value='Close Window' onClick='self.close()'>";
}


# successful message from update or delete of profile
$str_report="<font color ='blue'>".$_[0]."</font>";
# Get number of the current page
$page=$q->param('page');
# Count last and first rows for the current page
my $rowLast=$page*$rowNumber;
my $rowFirst=($page-1)*$rowNumber;
my $n=$rowFirst;
my $str_navig='';
my $navig = 0;


my $str_font='';
my $str_green='';
my $str_table="
<table border='1' width='100%' cellspacing='2' cellpadding='1'>
<TR><TH width='4%'><font size=2>N</font></TH>
    <TH width='10%'><font size=2>Date</font></TH>
    <TH width='10%'><font size=2>Order #</font></TH>
    <TH width='10%'><font size=2>Account #</font></TH>
    <TH width='15%'><font size=2>Company</font></TH>
    <TH width='15%'><font size=2>City</font></TH>
    <TH width='15%'><font size=2>Country</font></TH>
    <TH width='10%'><font size=2>Total</font></TH>

    </TR>";

$searchIN='';
$searchIN=$q->param('searchIN');

$SearchWord=$q->param('SearchWord');
$_=$SearchWord;   (s/^\s+//); (s/\s+$//);  $SearchWord=$_;

if ($SearchWord ne '') {

   $sql = "SELECT Transactions.Id, StoreOrderNumber, Transactions.DatePurchased,
                  Transactions.EstabDiscountLevel,
                  Transactions.FirstName,Transactions.LastName,
                  Transactions.City, Transactions.Country  ,
                  Transactions.CompanyName, Transactions.Profile,
                  Transactions.Status, Profile.DateCreate
           FROM   Transactions, Profile
           WHERE  $select_Status Transactions.Profile = Profile.Id and Transactions.DatePurchased >= '$StartDay' AND Transactions.DatePurchased <= '$EndDay'
          ORDER BY Transactions.Id DESC ";
   dbexecute($sql);
   $i=0;
   while(($Id, $StoreOrderNumber, $DatePurchased, $EstabDiscountLevel, $FirstName,
   $LastName, $City, $Country, $CompanyName, $Id_Account, $Status, $DateCreate)=dbfetch()) {

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

      $pathUrlSearch="$pathUrl?comEdit=Edit&code=$code&Id=$Id&AccountNumber=$AccountNumber";
      $pathUrlSearch.="&StartDay=$StartDay&EndDay=$EndDay&StatusOrder=$StatusOrder&Id_Profile=$Id_Profile";

      $URL_FULL=$pathUrlSearch;
      $_= get($URL_FULL);
      if ( m/$SearchWord/i ) {  $searchIN.=$Id.",";  }
      else {  next;  }
  }
}

$str_searchIN='';
if ($searchIN ne '') {
   $str_searchIN="Transactions.Id IN (".$searchIN."0) and ";
}



$pathUrlPage="$pathUrl?comEdit=Page&code=$code&rowNumber=$rowNumber&Id_Profile=$Id_Profile";
$pathUrlPage.="&StartDay=$StartDay&EndDay=$EndDay&StatusOrder=$StatusOrder&searchIN=$searchIN";


$sql = "SELECT Transactions.Id, StoreOrderNumber, Transactions.DatePurchased,
               Transactions.EstabDiscountLevel,
               Transactions.FirstName,Transactions.LastName,
               Transactions.City, Transactions.Country  ,
               Transactions.CompanyName, Transactions.Profile,
               Transactions.Status, Profile.DateCreate
        FROM   Transactions, Profile
        WHERE  $str_searchIN $select_Status Transactions.Profile = Profile.Id and Transactions.DatePurchased >= '$StartDay' AND Transactions.DatePurchased <= '$EndDay'
        ORDER BY Transactions.Id DESC ";
dbexecute($sql);


$i=0;
while(($Id, $StoreOrderNumber, $DatePurchased, $EstabDiscountLevel, $FirstName,
$LastName, $City, $Country, $CompanyName, $Id_Account, $Status, $DateCreate)=dbfetch()) {


  if (($rowFirst<=$i)&&($i<$rowLast))  { # Select only rows for this page

    $n++;
    $Total = 0;

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


    $sql="SELECT OrderList.Id, OrderList.Quantity, OrderList.Price
          FROM  OrderList
          WHERE Trans=$Id and Status=0";
    $cursor1=$dbh->prepare($sql);
    $cursor1->execute;

    $Amount=0;
    $Subtotal=0;
    $Total=0;
    while (($IdOrderList, $Quantity, $Price)= $cursor1->fetchrow_array()) {
       $Amount=sprintf("%.2f", ($Price*$Quantity));      # Amount result
       $Subtotal=sprintf("%.2f", ($Subtotal+$Amount));   # Sub-Total result
    }
    $Total=sprintf("%.2f", ($Subtotal-($Subtotal*$EstabDiscountLevel)/100 ));  # Total result
    $Total=converter($Total);
    $Total="\$ ".$Total;


    $pathUrlEdit="$pathUrl?comEdit=Edit&code=$code&page=$page&rowNumber=$rowNumber&Id=$Id&AccountNumber=$AccountNumber";
    $pathUrlEdit.="&StartDay=$StartDay&EndDay=$EndDay&StatusOrder=$StatusOrder&Id_Profile=$Id_Profile&searchIN=$searchIN";


    if ( $Status == 1) { $str_font="#AAAAAA"; }
    else  { $str_font="#CCCCCC";  }


     $str_table.="
     <TR BGCOLOR=$str_font>
     <TD align='center'><font size=2>
     <a href='$pathUrlEdit'>$n</a></font></TD>
     <TD align='center'><font size=2>$DatePurchased</font></TD>
     <TD align='center'><font size=2>$StoreOrderNumber</font></TD>
     <TD align='center'><font size=2>$AccountNumber</font></TD>
     <TD align='center'><font size=2>$CompanyName</font></TD>
     <TD align='center'><font size=2>$City</font></TD>
     <TD align='center'><font size=2>$Country</font></TD>
     <TD align='right'><font size=2>$Total</font></TD></TR>";
  }
  $i++;

  if ((sprintf("%d",($i%$rowNumber)) == 0 )&&( $limit-1 >= $navig )) {
     $navig++;
     if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT> "; }
     else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a> ";}
  }
}
$str_table.="</TABLE>";


if (( $i > $navig*$rowNumber )&&( $limit-1 >= $navig )) {
  $navig++;
  if ( $page == $navig ){ $str_navig.="<FONT SIZE=2>$navig</FONT> "; }
  else { $str_navig.="<a href='$pathUrlPage&page=$navig'><FONT SIZE=2>$navig</FONT></a> ";}
}


$str_navig="<FONT SIZE=2><u>Pages</u>:</font> ".$str_navig;

# Count and check last page
$pageLast=sprintf("%d",($i%$rowNumber));
if ($pageLast==0) {$pageLast=($i/$rowNumber);}
else  {  $pageLast=sprintf("%d",($i/$rowNumber));  $pageLast++;  }
# Create string for html form
if ( $pageLast == 1) { $str_navig=''; }

$str_table.="
<table border='0' width='100%' cellspacing='0' cellpadding='0'>
<TR><TH width='100%'></TH></TR>
<TR><TD align='left'>$str_navig</TD><TR></TABLE>";

$str_page="(".(($page-1)*$rowNumber+1)."-$n of $i)";

if ( $i==0 ) {
  $str_table="
  <H3> NO MATCHES!! </H3>
  Your search did not return any results. Please return to previous page,  broaden your criteria<BR>
  and try again.  If the problem persists, please send description to <a href='mailto:info\@bipcorp.com' ><FONT color='blue'>info\@bipcorp.com</FONT></a><br>";
  $str_page=0;

}


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin / Orders History List</TITLE>

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
<form>
<H3><u>Search Result</u>: Orders - $str_page <a href='$pathUrl?comEdit=Search&code=$code'><font size=2></b>New Search</font></a></H3>
$str_report
$str_table
<br>
$str_button
</form>
</BODY></HTML>
Browser

}   ##list_Transactions




############################################################################
sub transactions      #17.02.2000 15:39
############################################################################

{


$Id=$q->param('Id');
$StartDay=$q->param('StartDay');
$EndDay=$q->param('EndDay');
$rowNumber=$q->param('rowNumber');
$page=$q->param('page');
$StatusOrder=$q->param('StatusOrder');
$AccountNumber=$q->param('AccountNumber');
$Id_Profile=$q->param('Id_Profile');
$Printer=$q->param('Printer');
$searchIN=$q->param('searchIN');


$str_table='';
$sql="SELECT StoreOrderNumber, PurchasingOrderNumber,
             FirstName, LastName, Email, Title, CompanyName,
             StreetAddress, City, State, Country, Phone, Zip, Fax,
             ShippingStreetAddress, ShippingCity, ShippingState, ShippingCountry,
             ShippingPhone, ShippingZip, ShippingFax,
             EstabDiscountLevel,
             CreditCard, DatePurchased,
             DateShipped, DatePaymentDue, DatePaymentReceived,
             ShippedVia, TrackingNumber,
             CreditCardType, CreditCardNumber, ExpirationMonth, ExpirationYear,
             SecurityCode, NameOnCard, Status
FROM Transactions
WHERE Transactions.Id=$Id";
dbexecute($sql);


$j=0;

while (($StoreOrderNumber, $PurchasingOrderNumber,
  $FirstName,$LastName,$Email, $Title, $CompanyName,
  $StreetAddress, $City,$State,$Country,
  $Phone,$Zip, $Fax,
  $ShippingStreetAddress, $ShippingCity,$ShippingState,$ShippingCountry,
  $ShippingPhone,$ShippingZip, $ShippingFax,
  $EstabDiscountLevelOrder,
  $CreditCard, $DatePurchased,
  $DateShipped, $DatePaymentDue, $DatePaymentReceived,
  $ShippedVia, $TrackingNumber,
  $CreditCardType, $CreditCardNumber, $ExpirationMonth, $ExpirationYear,
  $SecurityCode, $NameOnCard, $Status) =dbfetch()) {
  $j++;

  if ($DateShipped =='0000-00-00') { $DateShipped=''; }
  if ($DatePaymentDue =='0000-00-00') { $DatePaymentDue=''; }
  if ($DatePaymentReceived =='0000-00-00') { $DatePaymentReceived=''; }

  if ($Status == 1 ) { $str_status="&nbsp;<b>Status: <font color=#ff0000>Deleted</font></b>"; }

  if ( $comEdit ne 'Edit' )  {
      $DatePaymentDue=$q->param('DatePaymentDue');
      $DatePaymentReceived=$q->param('DatePaymentReceived');
      $DateShipped=$q->param('DateShipped');
      $ShippedVia=$q->param('ShippedVia');
      $TrackingNumber=$q->param('TrackingNumber');
  }

  $_=$DatePaymentDue;          s/\\//g; s/\"/&quot;/g; $DatePaymentDue=$_;
  $_=$DatePaymentReceived;     s/\\//g; s/\"/&quot;/g; $DatePaymentReceived=$_;
  $_=$DateShipped;             s/\\//g; s/\"/&quot;/g; $DateShipped=$_;
  $_=$ShippedVia;              s/\\//g; s/\"/&quot;/g; $ShippedVia=$_;
  $_=$TrackingNumber;          s/\\//g; s/\"/&quot;/g; $TrackingNumber=$_;



   if ($FirstName eq '') {  $body_text="Dear Sir or Madam";  }
   else { $body_text="Dear $FirstName";  }

   $str_table.="
   <br>
   <table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\" align=center>
  <TR>
    <TD  colspan=3 width=100% valign=top bgcolor='#BBBBBB' >&nbsp;<font color=\"#000000\"><b>&nbsp;&nbsp;Order \# $StoreOrderNumber Information</b> &nbsp;&nbsp;&nbsp; <i><b>$DatePurchased</b></i> &nbsp; $str_status</font></td>
  </TR>
  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>

  <TR>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD>Account #</TD><TD>$AccountNumber</TD></TR>
      <TR><TD width=30%>First Name</TD><TD width=70%>$FirstName&nbsp;</TD>
      </TR>
      <TR><TD >Last Name</TD><TD >$LastName&nbsp;</TD>
      </TR>
      </table>
  </TD>
  <TD width=26 ></TD>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD>Title</TD><TD>$Title&nbsp;</TD></TR>
      <TR><TD width=30%>Company</TD><TD width=70%>$CompanyName</TD>
      </TR>
      <TR><TD >E-mail</TD><TD ><a href='$path_cgi"."adm_sendemail.pl?comSender=Sender_one&code=$code&to=$Email&body_text=$body_text'>$Email</a></font></TD></TR>
      </table>
  </TD>
  </TR>
  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>
  <TR>
    <TD width=47% valign=top bgcolor='#BBBBBB' >&nbsp;<font color=\"#000000\"><b>Billing Address</b></font></td>
    <TD width=26 valign=top  ></TD>
    <TD width=47% valign=top bgcolor='#BBBBBB' >&nbsp;<font color=\"#000000\"><b>Shipping Address</b></font></td>
  </TR>
  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>


  <TR>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD width=30% >Street Address</TD><TD width=70%>$StreetAddress</TD></TR>
      <TR><TD >City</TD><TD>$City</TD></TR>
      <TR><TD  >State</TD><TD>$State&nbsp;</TD></TR>
      <TR><TD >Country </TD><TD >$Country</TD></TR>
      <TR><TD  >Zip </TD><TD>$Zip</TD></TR>
      <TR><TD >Phone</TD><TD >$Phone</TD></TR>
      <TR><TD  >Fax</TD> <TD>$Fax&nbsp;</TD>
      </TR>

      </table>
  </TD>
  <TD width=26 ></TD>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD width=30%>Street Address </TD><TD width=70%>$ShippingStreetAddress</TD></TR>
      <TR><TD >City</TD><TD >$ShippingCity</TD></TR>
      <TR><TD>State</TD><TD>$ShippingState&nbsp;</TD></TR>
      <TR><TD >Country</TD><TD >$ShippingCountry</TD></TR>
      <TR><TD>Zip</TD><TD>$ShippingZip</TD>
      </TR>
      <TR><TD >Phone</TD><TD >$ShippingPhone</TD></TR>
      <TR><TD>Fax</TD><TD>$ShippingFax&nbsp;</TD></TR>
      </table>
   </TD>
   </TR>

  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>
  <TR>
    <TD width=47% valign=top bgcolor='#BBBBBB' >&nbsp;<font color=\"#000000\"><b>Payment</b></font></td>
    <TD width=26 valign=top  ></TD>
    <TD width=47% valign=top bgcolor='#BBBBBB' >&nbsp;<font color=\"#000000\"><b>Shipping</b></font></td>
  </TR>
  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>

  <TR>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD width=45% >Type of Payment</TD><TD  width=55% >$CreditCard</TD></TR>
      <TR><TD>Credit Card Type</TD><TD>$CreditCardType</TD></TR>
      <TR><TD>Credit Card Number</TD><TD>$CreditCardNumber</TD></TR>
      <TR><TD>Expiration month/year</TD><TD>$ExpirationMonth $ExpirationYear</TD></TR>
      <TR><TD>Security code</TD><TD>$SecurityCode</TD></TR>
      <TR><TD>Name on card</TD><TD>$NameOnCard</TD></TR>
      <TR><TD>Date Payment Due</TD><TD ><input type=text name=DatePaymentDue value=\"$DatePaymentDue\" maxlength=10 size=10> yyyy-mm-dd</TD></TR>
      <TR><TD>Date Payment Received</TD><TD><input type=text name=DatePaymentReceived value=\"$DatePaymentReceived\" maxlength=10 size=10> yyyy-mm-dd</TD></TR>
      </table>
  </TD>
  <TD width=26 ></TD>
  <TD width=47%  valign=top>
      <table border=\"1\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">
      <TR><TD width=30%>Date Shipped</TD><TD width=70% ><input type=text name=DateShipped value=\"$DateShipped\" maxlength=10 size=10> yyyy-mm-dd</TD></TR>
      <TR><TD>Shipped via *</TD><TD  ><input type=text name=ShippedVia value=\"$ShippedVia\" maxlength=250 size=35></TD></TR>
      <TR><TD>Tracking # *</TD><TD><input type=text name=TrackingNumber value=\"$TrackingNumber\" maxlength=250 size=35></TD></TR>
      </table>
      * <font size=2><u>Example</u>: &lt;a href='http://www.ups.com/WebTracking/track?loc=en_US' target=ups&gt;UPS&lt;/a&gt;
      <br>To test url(s) save changes and open order again.</font>         
      <hr>        
      <b>TEST</b> Shipped via: $ShippedVia&nbsp;&nbsp;&nbsp;Tracking #: $TrackingNumber   
      

  </TD>
  </TR>
  <TR><td colspan=3 align=left width=100%  height=10><IMG height=1 src='/store/img/pix.gif'></td></TR>
</table>


<br>

 <TABLE cellSpacing=1 cellPadding=0 width=100% align=center  border=1 valign=MIDDLE>
 <TR bgcolor='#BBBBBB'>
 <TD height=20% align=middle ><font color='#000000'><b>Unit</b></font></TD>
 <TD width=43% align=middle ><font color='#000000'><b>Name</b></font></TD>
 <TD width=14% align=middle ><font color='#000000'><b>Unit Price,&nbsp;\$</b></font></TD>
 <TD width=8% align=middle ><font color='#000000'><b>Quantity</b></font></TD>
 <TD width=15% align=middle ><font color='#000000'><b>Total,&nbsp;\$</b></font></TD>
 </TR>";




 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Trans, Status
       FROM OrderList
       WHERE Trans = $Id and Status = 0
       ORDER BY Id";
 dbexecute($sql);
 while (( $IdOrderList, $ProductId, $ProductNumber, $ProductName, $OptionId,
          $OptionNumber, $OptionName, $Quantity, $Price, $Code, $Trans, $Status )=dbfetch()) {

    if ( $OptionId ==0 ) {
        $str_option="";
        $str_Number=$ProductNumber;
        $str_Name=$ProductName;
    }
    else  {
        $str_option="(for $ProductNumber)";
        $str_Number=$OptionNumber;
        $str_Name=$OptionName;
    }

    $Amount=sprintf("%.2f", ($Price*$Quantity));  # Amount result
    $SubTotal = $SubTotal + $Amount;

    $Price=converter($Price);
    $Amount=converter($Amount);

    $str_table.="<TR>
        <TD height=22 $str_bg_class2 align=center>$str_Number</TD>
        <TD height=22 $str_bg_class2 align=left>$str_Name $str_option</TD>
        <TD $str_bg_class2 align=right>$Price&nbsp;</TD>
        <TD $str_bg_class2 align=center> $Quantity</TD>
        <TD $str_bg_class2 class=Account align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }


 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevelOrder);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevelOrder/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);

 $str_table.="
 </TABLE>
 <table border='0' width='100%' cellspacing='1' cellpadding='0'>
  <TR class='plain'><TH width='83%'></TH><TH width='17%'></TH></TR>
  <tr class='plain'><TD align='right'><B>Sub - Total:</B></TD>
     <TD align='right'>\$ $SubTotal&nbsp;</TD></TR>
  <tr class='plain'><TD align='right'><B>Established Discount Level:</B></TD>
     <TD align='right'>\% $EstabDiscountLevelOrder&nbsp;</font></TD></TR>
  <tr class='plain'><TD align='right'>-------------------------</TD><TD align='right'>---------------</TD></TR>
  <tr class='plain'><TD align='right'><B>Total:</B></TD>
     <TD align='right'>\$ $Total&nbsp;</TD></TR>
  </table>

  <table border='0' width='100%' cellspacing='1' cellpadding='0'>
  <TR class='plain'><td align='right'>  <i>$string</i></TD></TR>
  </table>";

}


#####if ( $Id_Profile ) {


if ( $Printer ==1 ) { $str_button=""; }
else{
   $str_button="
   <input type=submit name=comEdit value=' Save changes ' >
   <input type=submit name=comEdit value=' Delete order ' onClick=\"return checkRemove()\">
   <input type=button name=comEdit value=' Printer friendly ' onClick='printerFriendly()' >
   <input type=submit name=comEdit value=' Cancel ' >";
}
$pathUrlPrinter="$pathUrl?comEdit=Edit&Printer=1&code=$code&Id=$Id&AccountNumber=$AccountNumber";


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin / Order History</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<link rel='stylesheet' href='/bip/image/style' type='text/css'>
<META content="MSHTML 5.00.2920.0" name=GENERATOR>

<SCRIPT>

// Set focus on Load or error
function setFocus() {
   $_[0];
}

function checkRemove () {
    if (confirm('Delete this order?')) { return true; }
    else  { return false; }
}

function printerFriendly() {
  msgWindow=window.open('$pathUrlPrinter','printerFriendly','menubar=yes,toolbars=yes, status=yes,scrollbars=yes,resizable=yes,width=800,height=600')
}
</SCRIPT>

</HEAD>
<BODY BGCOLOR='#CCCCCC' link="blue" vlink="blue"  onLoad=\"setFocus()\">
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
$str_table
<hr >
<br>
<input type=hidden name=code value='$code'>
<input type=hidden name=StartDay value='$StartDay'>
<input type=hidden name=EndDay value='$EndDay'>
<input type=hidden name=rowNumber value='$rowNumber'>
<input type=hidden name=page value=$page>
<input type=hidden name=StatusOrder value=$StatusOrder>
<input type=hidden name=AccountNumber value=$AccountNumber>
<input type=hidden name=Id_Profile value=$Id_Profile>
<input type=hidden name=searchIN value=$searchIN>
<input type=hidden name=Id value=$Id>


$str_button

</form>

</BODY></HTML>
Browser

} ## transactions



############################################################################
sub db_transactions      #17.02.2000 15:39
############################################################################

{


$Id=$q->param('Id');
$StartDay=$q->param('StartDay');
$EndDay=$q->param('EndDay');
$rowNumber=$q->param('rowNumber');
$page=$q->param('page');
$StatusOrder=$q->param('StatusOrder');
$AccountNumber=$q->param('AccountNumber');
$Id_Profile=$q->param('Id_Profile');
$searchIN=$q->param('searchIN');

$DatePaymentDue=$q->param('DatePaymentDue');
$DatePaymentReceived=$q->param('DatePaymentReceived');
$DateShipped=$q->param('DateShipped');
$ShippedVia=$q->param('ShippedVia');
$TrackingNumber=$q->param('TrackingNumber');
$_=$DatePaymentDue;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $DatePaymentDue=$_;
$_=$DatePaymentReceived;    (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $DatePaymentReceived=$_;
$_=$DateShipped;            (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $DateShipped=$_;
$_=$ShippedVia;             (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $ShippedVia=$_;
$_=$TrackingNumber;         (s/^\s+//); (s/\s+$//); s/\\//g; s/&quot;/\"/g; s/\'/\\\'/g;  $TrackingNumber=$_;



if ( $comEdit eq ' Delete order ' ) {
    $sql = "UPDATE Transactions SET Status=1
            WHERE  Id=$Id";
    if (dbdo($sql)) {
       list_transactions("The record has been deleted successfully !"); return;
    }
    else {
      transactions("alert('Database error. The record has not been deleted !')");  return;
    }
}
elsif ( $comEdit eq ' Save changes ' ) {


    $_= $DatePaymentDue;
    if (($DatePaymentDue ne '')&&( !(m/([2][0][0-2][0-9])-(([0][1-9])|([1][0-2]))-(([0][1-9])|([1-2][0-9])|([3][0-1]))/i) )) {
       transactions("alert('Date Payment Due is incorrect. The record has not been saved !')");  return;
    }

    $_= $DatePaymentReceived;  
    if (($DatePaymentReceived ne '')&&( !(m/([2][0][0-2][0-9])-(([0][1-9])|([1][0-2]))-(([0][1-9])|([1-2][0-9])|([3][0-1]))/i) )) {
       transactions("alert('Date Payment Received is incorrect. The record has not been saved !')");  return;
    }

    $_= $DateShipped;  
    if (($DateShipped ne '')&&( !(m/([2][0][0-2][0-9])-(([0][1-9])|([1][0-2]))-(([0][1-9])|([1-2][0-9])|([3][0-1]))/i) )) {
       transactions("alert('Date Shipped is incorrect. The record has not been saved !')");  return;
    }


    $sql = "UPDATE Transactions SET DatePaymentDue='$DatePaymentDue', DatePaymentReceived='$DatePaymentReceived',
            DateShipped='$DateShipped', ShippedVia='$ShippedVia', TrackingNumber='$TrackingNumber'
            WHERE  Id=$Id";
    if (dbdo($sql)) {
       list_transactions("The record has been saved successfully !"); return;
    }
    else {
      transactions("alert('Database error. The record has not been saved !')");  return;
    }
}

} ## db_transactions



############################################################################
sub wishlist      #17.02.2000 15:39
############################################################################

{


 $Id_Profile=$q->param('Id_Profile');
 $AccountNumber=$q->param('AccountNumber');

 $str_table="
  <h3>Account #$AccountNumber  Wish List <h/3>
  <br><br>
  <TABLE cellSpacing=1 cellPadding=0 width=100% align=center  border=1 valign=MIDDLE>
  <TR>
   <TD width=15%   align=middle><font color=#000000><b>Unit</b></font></TD>
   <TD width=45%   align=middle><font color=#000000><b>Name</b></font></TD>
   <TD width=15%   align=middle><font color=#000000><b>Price,&nbsp;\$</b></font></TD>
   <TD width=10%   align=middle><font color=#000000><b>Qantity</b></font></TD>
   <TD width=15%   align=middle><font color=#000000><b>Total,&nbsp;\$</b></font></TD>
  </TR>";





 $SubTotal=0;
 $i=0;

 $sql="SELECT DISTINCT  Id, ProductId, ProductNumber, ProductName, OptionId,
              OptionNumber, OptionName, Quantity, Price, Code, Profile, Status
       FROM WishList
       WHERE Profile=$Id_Profile and Status=0
       ORDER BY Id";
 dbexecute($sql);
 while (( $IdOrderList, $ProductId, $ProductNumber, $ProductName, $OptionId,
          $OptionNumber, $OptionName, $Quantity, $Price, $Code, $Tmp, $Status )=dbfetch()) {

    if ( $OptionId ==0 ) {
        $str_option="";
        $str_Number=$ProductNumber;
        $str_Name=$ProductName;
    }
    else  {
        $str_option="(for $ProductNumber)";
        $str_Number=$OptionNumber;
        $str_Name=$OptionName;
    }

    $Amount=sprintf("%.2f", ($Price*$Quantity));  # Amount result
    $SubTotal = $SubTotal + $Amount;

    $Price=converter($Price);
    $Amount=converter($Amount);

    $str_table.="<TR>
        <TD height=22 $str_bg_class2 align=center>$str_Number</TD>
        <TD height=22 $str_bg_class2 align=left>$str_Name $str_option</TD>
        <TD $str_bg_class2 align=right>$Price&nbsp;</TD>
        <TD $str_bg_class2 align=center> $Quantity</TD>
        <TD $str_bg_class2 class=Account align=right>$Amount&nbsp;</TD>
        </TR>";

     $i++;
 }


 $SubTotal=sprintf("%.2f",  $SubTotal);
 $EstabDiscountLevel =sprintf("%.2f", $EstabDiscountLevel);
 $Total=sprintf("%.2f",  ($SubTotal - ($SubTotal*$EstabDiscountLevel/100)));

 $SubTotal=converter($SubTotal);
 $Total=converter($Total);


 # for recalculate and direction to continue
 $str_table.="
       <input type=hidden name=SelCat value='$SelCat' >
       <input type=hidden name=SelSubCat value='$SelSubCat' >
       <input type=hidden name=SelManuf value='$SelManuf' >
       <input type=hidden name=Id value='$Id' >
       <input type=hidden name=com value='$com' >
       ";


 $str_table.="</table>";


 if ( $i==0 ) {
      $str_table="<b><font color=#ff0000>Your Wish List is empty</font></b>";
      $template_file=$path_html."html/wishlist_empty.html";

 }
 else  {

    $i=0;
    $sql="SELECT Id FROM WishList WHERE Profile=$Id_Profile and Status=0";
    dbexecute($sql);
    while (( $IdWishList )=dbfetch()) {
      $i++;
    }
    if ( $i==0 ) {
      $str_table="<b><font color=#ff0000>Your Wish List is empty</font></b>";
      $template_file=$path_html."html/wishlist_empty.html";
   }
   else {
     $template_file=$path_html."html/wishlist.html";
   }
 }


print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Admin / Wish List</TITLE>
<META content='text/html; charset=windows-1251' http-equiv=Content-Type>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: blue; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: blue;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>
<link rel='stylesheet' href='/bip/image/style' type='text/css'>
<META content="MSHTML 5.00.2920.0" name=GENERATOR>


</HEAD>
<BODY BGCOLOR='#CCCCCC' link="blue" vlink="blue" >
<FORM Name='form1' METHOD='POST' ACTION=$pathUrl >
$str_table

<br>
<input type=button name=comEdit value='Close Window' onClick='self.close()'>

</form>

</BODY></HTML>
Browser


}   ##wishlist


