#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  /  db.pl.
#
############################################################################

# Initialize global vars
# Unix
#$path= 'http://store.com/store/';
#$path_admin= 'http://store.com/store/store.html';
#$path_cgi = 'http://store.com/cgi-bin/cgiwrap/store/store/';
#$path_cgi_https = 'http://store.com/cgi-bin/cgiwrap/store/store/';
#$path_html='/home/store/public_html/store/';
#$path_send_mail = '/usr/sbin/sendmail';

#$path_attach_files  = $path_html."send/";
#$path_product_image = $path_html."product_image/";
#$path_product_html  = $path_html."product_html/";
#$path_product_pdf   = $path_html."product_pdf/";
#$path_menu_js       = $path_html."js/";
#$path_banner         = $path_html."banner/";
#$path_forms         = $path_html."forms/";


# Windows
$path= 'http://localhost/store/';
$path_admin= 'http://localhost/store/store.html';
$path_cgi = 'http://localhost/cgi-bin/store/';
$path_cgi_https = 'http://localhost/cgi-bin/store/';
$path_html='C:\\Apache\\htdocs\\store\\';
$path_send_mail = '/usr/sbin/sendmail';
$path_attach_files = $path_html."\\send\\";

$path_product_image = $path_html."product_image\\";
$path_product_html  = $path_html."product_html\\";
$path_product_pdf   = $path_html."product_pdf\\";
$path_menu_js       = $path_html."js\\";
$path_banner        = $path_html."banner\\";
$path_option_image  = $path_html."option_image\\";

use CGI;
use DBI;

use MIME::Entity;
$q = new CGI;

############################################################################
sub dbconnect        #03.11.99 15:20    Connect to database
############################################################################

{

 my $dbname='dbname';
 my $dbuser='dbuser';
 my $dbpass='dbpass';

 $dbh=DBI->connect("DBI:mysql:$dbname",$dbuser,$dbpass)||
      print"Cannot connect to dbserver $DBI::errstr,\n";

#   $hostname='localhost';
# $dbh=DBI->connect("DBI:mysql:$dbname:$hostname",$dbuser,$dbpass)||
#      print"Cannot connect to dbserver $DBI::errstr,\n";

}   ##dbconnect

############################################################################
sub dbexecute       #01.11.99 15:42  Prepare and execute 'SELECT... ' query
############################################################################
{

  my($sql)=@_;
  $cursor=$dbh->prepare($sql);
  $cursor->execute;

}   ##dbexecute

############################################################################
sub dbfetch     #01.11.99 13:34    Fetch recorset
############################################################################
{

  $cursor->fetchrow_array;

}   ##dbfetch


############################################################################
sub dbdo     #01.11.99 13:34    Do query (INSERT, UPDATE or DELETE)
############################################################################
{

  my($sql)=@_;
  $dbh->do($sql);

}   ##dbdo


############################################################################
sub setcode     #28.10.00 12:50
############################################################################

{
  ($sec,$min,$hour,$mday,$mon,$year)= localtime(time);
   $mon+=$sec;
   $mday+=$min;
   $random1=int(rand(1000000*($sec+13)));
   $random2=int(rand(500000*($min+24)));
   $code="$random1$mon$mday$hour$random2$min$sec$$";

   return $code;

}   ##setcode

############################################################################
sub parse_template   # useful sub to enter data into html template files
############################################################################

{
    local($template_file, *OUT) = @_;
    local($line, $line_copy, $changes);
    # Open the template file and parse each line
    if (!open(TEMPLATE, $template_file)) {
        $Error_Message = "Could not open $template_file ($!).";
        return(0);
    }
    while ($line = <TEMPLATE>) {
        # Initialize our variables
        $line_copy = '';
        $changes = 0;
        # Search for variables in the current line
        while ($line =~ /<<([^>]+)>>/) {
            # Build up the new line with the section of $line prior to the
            # variable and the value for $var_name (check %VAR, %CONFIG,
            # %FORM, then %ENV for match)
            ++$changes;
            if ($VAR{$1}) { $line_copy .= $` . $VAR{$1} }
            elsif ($CONFIG{$1}) { $line_copy .= $` . $CONFIG{$1} }
            elsif ($FORM{$1}) { $line_copy .= $` . $FORM{$1} }
            elsif ($ENV{$1}) { $line_copy .= $` . $ENV{$1} }
            else {
                --$changes;
                $line_copy .= $`;
            }
            # Change $line to the section of $line after the variable
            $line = $';
        }
        # Set $line according to whether or not any matches were found
        $line = $line_copy ? $line_copy . $line : $line;
        # Print line depending on presence of 0: and variables existing
        if (($line !~ s/^0://) || !$line_copy || $changes) {
            print OUT $line;
        }
    }
    close(TEMPLATE);
    return(1);
}  ##parse_template


############################################################################
sub email_check  #16.12.99 15:24   Check email address entered into the form
############################################################################

{

 local($email) = $_[0]; # Get string with email address

 if (($email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/ ||($email !~ /^.+\@localhost$/ &&
     $email !~ /^.+\@\[?(\w|[-.])+\.[a-zA-Z]{2,3}|[0-9]{1,3}\]?$/))||($email !~/\@/)||
     ($email =~/\s/)  )
   { return(0); } # email address is incorrect
 else
   { return(1); } # email address is correct

}  ##email_check


############################################################################
sub send_mail        #16.12.99 15:24    Send email
############################################################################
{


  # Set path to function sendmail()
  $mailprog = $path_send_mail;
  # Get mail header: to, from, subject, body, content-type( default text/plain)
  $mail_to = $_[0];
  $from = $_[1];
  $subj = $_[2];
  $body = $_[3];
  $type=$_[4];

  open(MAIL,"|$mailprog -t") or $message="Error sending your mail!";
  # Set up the mail headers:
  print MAIL "To: $mail_to\n";
  print MAIL "From: $from\n";
  print MAIL "Subject: $subj\n";
  if ($type eq 'html' ) {  print MAIL "Content-type: text/html\n\n";  }
  print MAIL $body;
  close (MAIL);

}   ##send_mail


############################################################################
sub attach        #19.09.00 15:36     Send email with attached files
############################################################################

{

# Get email header: to, from, subject, body, list attached files
$to = $_[0];
$from = $_[1];
$subj = $_[2];
$body = $_[3];
$str_files=$_[4];
@array_files=split(/,/, $str_files); # get array attached files

###    $ent = build MIME::Entity Type        => "text/html",

# Create the object, and set up the mail headers:
$message = MIME::Entity->build(
    Type     =>"multipart/mixed",
    -From    => "$from",
    -To      => "$to",
    -Subject => "$subj"
    );

attach  $message  Data=>"$body \n\n"; # attach email body

my $i=0; # loop var

# for each attached file check if its extention exist in
# MIME-type array and then attach it to email
foreach (@array_files) {

  # Get suffix (extention)of attached file
  my $where=rindex($_,".");
  my $suffix=substr($_,$where+1);
  $suffix= uc($suffix);

  # check if suffix belongs to MIME-type array.
  # If yes then attach file to email
  while (($key,$value)= each (%array_mime )) {
     if ( $suffix eq $key) {

       $attach_file = $path_attach_files.$_;
       attach $message  Path=>"$attach_file",
              Type        => "$value",
              Encoding    => "base64";
     }
  }
$i++;
}

# Set path to function sendmail() and send it.
$mailprog = $path_send_mail;
open(MAIL, "|$mailprog -t")  or die("mail open $mailprog error: $!");
$message->print(\*MAIL);
close(MAIL);

}   ##attach


############################################################################
sub get_date       #29.10.99 9:40  return date string like that '2000-06-19'
############################################################################
{

 my $wrk=$_[0]; # shift var, use it to format date string (see below)
 my ($sec,$min,$hour,$mday,$mon,$year)= localtime(time);
 $mon++;           # correct month
 $year=1900+$year; # set up format of year 'YYYY'

 if ( $mon<10)  { $mon="0$mon";}    # set up format of month 'MM'
 if ( $mday<10) { $mday="0$mday";}  # set up format of day 'DD'

 if (defined $wrk) {  $date="$year-$mon-01"; }
 else {  $date="$year-$mon-$mday"; }

 return ($date);

}   ##get_dat


############################################################################
sub check_date      #27.02.2000 20:31    Check date
############################################################################

{
# Get date string and split it into array
my @check=split(/-/,$_[0]);

if   ((($check[0]>1990)&&($check[0]<2199)&&($check[1]<=12 )&&($check[1]>0 )&&( $check[2]<=31 )&&($check[2]>0))&&
      ( ((($check[1]==4)||($check[1]==6)||($check[1]==9)||($check[1]==11)) && ($check[2]<=30)) ||
        ((($check[1]==1)||($check[1]==3)||($check[1]==5)||($check[1]==7)||($check[1]==8)||($check[1]==10)||($check[1]==12))&&($check[2]<=31)) ||
         (($check[1]==2)&&($check[2]<30 ))
      ))
 { $result='yes';} # date is correct
else
 { $result='no';}  # date is incorrect

return ($result);
}   ##check_date
         

############################################################################
sub currency_to_string
############################################################################
{
# Convert currency from $0.01 to $9,999,999.99 to string
# It's too lazy to write comments for this sub today.
# Probably some day I'll do it

$x=0;
$x=$_[0]; # Get currency


my %myarray=(
10=>'ten'    , 20=>'twenty', 30=>'thirty',
40=>'forty'  , 50=>'fifty' , 60=>'sixty' ,
70=>'seventy', 80=>'eighty', 90=>'ninety',

11=>'eleven'   , 12=>'twelve'  , 13=>'thirteen',
14=>'fourteen' , 15=>'fiveteen', 16=>'sixteen' ,
17=>'seventeen', 18=>'eighteen', 19=>'nineteen',

1=>'one', 2=>'two'  , 3=>'three', 4=>'four', 5=>'five',
6=>'six', 7=>'seven', 8=>'eight', 9=>'nine');

my $dollar=0; my $cent=0;

$cent=sprintf("%d",($x*100));
$dollar=sprintf("%d",$x)*100;
$cent=$cent-$dollar;
$dollar=sprintf("%d",($dollar/100));

#dollar
my $dollar1=0;
my $dollar2=0;
my $dollar3=0;
my $dollar4=0;
my $dollar5=0;
my $dollar6=0;
my $dollar7=0;

my $str_dollar1='';
my $str_dollar2='';
my $str_dollar3='';
my $str_dollar4='';
my $str_dollar5='';
my $str_dollar6='';
my $str_dollar7='';

my $str_dollar='';
my $str_out='';
my $str_cent='';
my $str_total='';

# 1 000 000 - 10 000 000 dollars
if (($dollar>=1000000)&&($dollar<10000000))
 {
   $dollar1=(substr($dollar,6,1));
   $dollar2=(substr($dollar,5,1))*10;
   $dollar3=(substr($dollar,4,1));
   $dollar4=(substr($dollar,3,1));
   $dollar5=(substr($dollar,2,1))*10;
   $dollar6=(substr($dollar,1,1));
   $dollar7=(substr($dollar,0,1));
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,4,2));
    }
   if ($dollar5==10)
    {
      $dollar5=0;
      $dollar4=(substr($dollar,2,2));
    }
 }
# 100 000 - 1 000 000 dollars
if (($dollar>=100000)&&($dollar<1000000))
 {
   $dollar1=(substr($dollar,5,1));
   $dollar2=(substr($dollar,4,1))*10;
   $dollar3=(substr($dollar,3,1));
   $dollar4=(substr($dollar,2,1));
   $dollar5=(substr($dollar,1,1))*10;
   $dollar6=(substr($dollar,0,1));
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,4,2));
    }
   if ($dollar5==10)
    {
      $dollar5=0;
      $dollar4=(substr($dollar,1,2));
    }

 }
# 20 000 - 100 000 dollars
if (($dollar>=20000)&&($dollar<100000))
 {
   $dollar1=(substr($dollar,4,1));
   $dollar2=(substr($dollar,3,1))*10;
   $dollar3=(substr($dollar,2,1));
   $dollar4=(substr($dollar,1,1));
   $dollar5=(substr($dollar,0,1))*10;
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,3,2));
    }
 }
# 1 000-20 000 dollars
if (($dollar>=1000)&&($dollar<10000))
 {
   $dollar1=(substr($dollar,3,1));
   $dollar2=(substr($dollar,2,1))*10;
   $dollar3=(substr($dollar,1,1));
   $dollar4=(substr($dollar,0,1));
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,2,2));
    }
 }
if (($dollar>=10000)&&($dollar<20000))
 {
   $dollar1=(substr($dollar,4,1));
   $dollar2=(substr($dollar,3,1))*10;
   $dollar3=(substr($dollar,2,1));
   $dollar4=(substr($dollar,0,2));
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,3,2));
    }
 }
# 100-1 000 dollars
if (($dollar>=100)&&($dollar<1000))
 {
   $dollar1=(substr($dollar,2,1));
   $dollar2=(substr($dollar,1,1))*10;
   $dollar3=(substr($dollar,0,1));
   if ($dollar2==10)
    {
      $dollar2=0;
      $dollar1=(substr($dollar,1,2));
    }
 }
# 20-100 dollars
if (($dollar>=20)&&($dollar<100))
 {
   $dollar1=(substr($dollar,1,1));
   $dollar2=(substr($dollar,0,1))*10;
 }
# 2-20 dollars
if (($dollar>=2)&&($dollar<20))
 { $dollar1=$dollar; }

if (!($dollar7==0))
  {
    for ($i=$dollar7; $i<10 ; $i++) {
    if ($i==$dollar7)
      { $str_dollar7=$myarray{$i}." million ";}
    }
  }

if (!($dollar6==0))
  {
    for ($i=$dollar6; $i<10 ; $i++) {
    if ($i==$dollar6)
      { $str_dollar6=$myarray{$i}." hundred ";}
    }
  }
if (!($dollar5==0))
  {
    for ($i=$dollar5; $i<100 ; $i=$i+10 ) {
    if ($i==$dollar5)
      {
       if ($dollar6==0)
        { $str_dollar5=$myarray{$i}; }
       else
        { $str_dollar5="and ".$myarray{$i}; }
      }
    }
  }
if (!($dollar4==0))
  {
    for ($i=$dollar4; $i<20 ; $i++) {
    if ($i==$dollar4)
      {
       if (($dollar5==0)&&(!($dollar6==0)))
        { $str_dollar4="and ".$myarray{$i};}
       elsif (!($dollar5==0))
        { $str_dollar4="-".$myarray{$i};}
       else
        { $str_dollar4=$myarray{$i};}
      }
    }
  }
if (!($dollar3==0))
  {
    for ($i=$dollar3; $i<10 ; $i++) {
    if ($i==$dollar3)
      { $str_dollar3.=$myarray{$i}." hundred ";}
    }
  }

if (!($dollar2==0))
  {
    for ($i=$dollar2; $i<100 ; $i=$i+10) {
    if ($i==$dollar2)
      {
       if ($dollar3==0)
         { $str_dollar2=$myarray{$i}; }
       else
         { $str_dollar2="and ".$myarray{$i}; }
      }
    }
  }
if (!($dollar1==0))
  {
    for ($i=$dollar1; $i<20 ; $i++) {
    if ($i==$dollar1)
      {
       if (($dollar2==0)&&(!($dollar3==0)))
        { $str_dollar1="and ".$myarray{$i};}
       elsif ( (!($dollar2==0))&&(($dollar3==0)||(!($dollar3==0))) )
        { $str_dollar1="-".$myarray{$i};}
       else
        { $str_dollar1=$myarray{$i};}
      }
    }
  }

if ($dollar>=1000000)
  { $str_dollar=$str_dollar7; }

if ($dollar>=1000)
  {
   if (( $str_dollar6 ne '')||($str_dollar5 ne '')||($str_dollar4 ne ''))
    {
     $str_dollar.=$str_dollar6.$str_dollar5.$str_dollar4;
     if (( $str_dollar5 eq '')&&($str_dollar4 eq ''))
       { $str_dollar.="thousand "; }
     else
       { $str_dollar.=" thousand "; }
    }
  }

if ($dollar>1)
  {
   $str_dollar.=$str_dollar3.$str_dollar2.$str_dollar1;
   if (($str_dollar2 eq '')&&($str_dollar1 eq ''))
     { $str_dollar.="dollars"; }
   else
     { $str_dollar.=" dollars"; }
  }

if ($dollar==1)
  { $str_dollar="one dollar"; }

#cent
my $cent1=0; my $cent2=0; my $str_cent='';

# 20-100 cents
if (($cent>=20)&&($cent<100))
  {
   $cent2=(substr($cent,0,1))*10;
   $cent1=(substr($cent,1,1));
  }
# 2-20 cents
if (($cent>=2)&&($cent<20))
  { $cent1=$cent; }

if (!($cent2==0))
  {
    for ($i=$cent2; $i<100 ; $i=$i+10) {
    if ($i==$cent2)
      { $str_cent.="$myarray{$i}"; }
    }
  }
if (!($cent1==0))
  {
    for ($i=$cent1; $i<20 ; $i++) {
    if ($i==$cent1)
      {
        if ($cent2==0)
          { $str_cent.=$myarray{$i}; }
        else
          { $str_cent.="-".$myarray{$i}; }
       }
    }
  }

if ($cent>1)
  { $str_cent=$str_cent." cents "; }
elsif ($cent==1)
  { $str_cent="one cent "; }
else
  { $str_cent=""; }

############### total ###############
my $str_total=ucfirst($str_dollar." ".$str_cent."only");
my $len_max=78;
my $len=length($str_total);
my $str_out='';

if ($len>=$len_max)
  {
    my $i=$len_max;
    my $tmp=substr($str_total,$i-1,1);
    if ($tmp ne ' ')
      {
        while ($tmp ne ' ') {
          $i--;
          $tmp=substr($str_total,$i-1,1);
        }
      }
    $str_out=substr($str_total,0,$i)."\n";
    $str_out.="   ".substr($str_total,($i),$len_max);
  }
else
  { $str_out=$str_total; }

return ($str_out);
}  ## currency_to_string


############################################################################
sub state_box   #15.09.00 11:41
############################################################################

{
# Create  'State' pull-box for the forms
# Get selected state
my $State=$_[0];
my $where=$_[1];
my $myStyle=$_[2];

if ($myStyle ne '') {
  $myStyle="style=\"FONT-SIZE: 12px;  FONT-FAMILY: Arial, Helvetica, sans-serif\"";
}

my $str_select="";

my $sql="SELECT Id, Name FROM State ORDER BY Name";
dbexecute($sql);

# Format pull-box with states
if ( $where == 0 ) {
     $str_select="<select $myStyle name='State' onchange='country(this.form);'>";
}
else {
    $str_select="<select $myStyle name='ShippingState' onchange='shippingcountry(this.form);'>";
}

# fetch all states set up the selected state
while (( $i,$Name ) =dbfetch()) {
    if ($i == 1) { $Name="-- Select State (US) --"; }

    if ( $State == $i ) { $str_select.="<OPTION SELECTED VALUE=$i>$Name</OPTION>"; }
    else { $str_select.="<OPTION VALUE=$i>$Name</OPTION>"; }
 }
$str_select.="</SELECT>";

return $str_select;

}   ##state_box


############################################################################
sub country_box       #15.09.00 11:48
############################################################################

{
# Create Country pull-box for the forms
# Get selected Country
my $Country=$_[0];
my $where=$_[1];
my $myStyle=$_[2];

if ($myStyle ne '') {
  $myStyle="style=\"FONT-SIZE: 12px; FONT-FAMILY: Arial, Helvetica, sans-serif\"";
}


my $str_select="";

$sql="SELECT Id, Name FROM Country ORDER BY Id";
dbexecute($sql);

# Format pull-box with countries
if ( $where == 0 ) { $str_select="<select $myStyle name='Country' onchange='state(this.form);' >"; }
else { $str_select="<select $myStyle name='ShippingCountry' onchange='shippingstate(this.form);' >"; }

# fetch all countries set up the selected country
while (( $i,$Name ) =dbfetch()) {
    if ( $Country == $i ) { $str_select.="<OPTION SELECTED VALUE=$i>$Name</OPTION>"; }
    else { $str_select.="<OPTION VALUE=$i>$Name</OPTION>"; }
 }
$str_select.="</SELECT>";

return $str_select;
}   ##country_box



############################################################################
sub type_of_business_box     #15.09.00 11:56
############################################################################

{
# Create Type of Business pull-box for the forms
# Get customer's type of business
my $TypeOfBusiness=$_[0];
my $myStyle=$_[1];

if ($myStyle ne '') {
  $myStyle="style=\"FONT-SIZE: 12px; FONT-FAMILY: Arial, Helvetica, sans-serif\"";
}



$sql="SELECT Id, Name FROM TypeOfBusiness WHERE Status=0 ORDER BY Name";
dbexecute($sql);

# format pull-box
my $str_select1="<SELECT $myStyle NAME=TypeOfBusiness onchange='typespecify(this.form);'>";
my $str_select.="<OPTION VALUE=0>-- Select Type of business --</OPTION>";
if ($TypeOfBusiness == 999) { $str_select.="<OPTION SELECTED VALUE=999>Other</OPTION>"; }
else {   $str_select.="<OPTION VALUE=999 >Other</OPTION>"; }


# fetch all 'alive' type of business and set up selected option
while (( $Id,$Name ) =dbfetch()) {
  if ( $Id==$TypeOfBusiness ) { $str_select.="<OPTION SELECTED VALUE=$Id>$Name</OPTION>"; }
  else { $str_select.="<OPTION VALUE=$Id>$Name</OPTION>"; }
}


$str_select1.=$str_select."</SELECT>";



return $str_select1;
}   ##type_of_business_box


############################################################################
sub paymentterms_box_new       #15.09.00 11:53
############################################################################

{

# Create Payment Terms group of radiobutton for the forms
# Get customer's payment term
my $PaymentTerms=$_[0];
my $myStyle=$_[1];
if ($myStyle ne '') { $myStyle="style=\"FONT-SIZE: 12px; FONT-FAMILY: Arial, Helvetica, sans-serif\""; }


if ( !defined $Perspect ) { $Perspect =1; } #NewComer
$sql="SELECT Id FROM AccountType WHERE  Status=0 and Level=$Perspect";
dbexecute($sql);
( $Id_AccountType )=dbfetch();


$sql="SELECT CreditCard.Id, CreditCard.Name
     FROM CreditCard, SubAccountType
     WHERE CreditCard.Status=0 and SubAccountType.Status=0 and
            CreditCard.Id=SubAccountType.CreditCard and SubAccountType.AccountType = $Id_AccountType
     ORDER BY CreditCard.Name";
dbexecute($sql);

$str_select="";
# fetch all countries set up the selected country
$i=0;
while (( $Id,$Name ) =dbfetch()) {

  if ( $Id == $PaymentTerms ) {
      $str_select.="<OPTION SELECTED VALUE=$Id>$Name</OPTION>";
      $i++;
  }
  else {
      $str_select.="<OPTION VALUE=$Id>$Name</OPTION>";
  }
}
if ($i ==0) {
   $str_select="<select $myStyle name='PaymentTerms' ><OPTION SELECTED VALUE=0>-- Select terms --</OPTION>".$str_select."</SELECT>";
}
else {
   $str_select="<select $myStyle name='PaymentTerms' ><OPTION VALUE=0>-- Select terms --</OPTION>".$str_select."</SELECT>";
}

return $str_select;

}   ##paymentterms_box_new


############################################################################
sub paymentterms_box       #15.09.00 11:53
############################################################################

{
# Create Payment Terms group of radiobutton for the forms
# Get customer's payment term
my $PaymentTerms=$_[0];


$sql="SELECT Id, Name FROM CreditCard where Status=0 ORDER BY Name";
dbexecute($sql);

# format group of radiobutton
my $str_select='';
# fetch all 'alive' payment termsand set up checked for the selected payment term
while (($Id, $Name) =dbfetch()) {
  if ( $Id == $PaymentTerms )
   { $str_select.="<INPUT type='radio' name=PaymentTerms value=$Id CHECKED>$Name"; }
  else
   { $str_select.="<INPUT type='radio' name=PaymentTerms value=$Id >$Name";}
  $str_select.="<br>";
}

return $str_select;

}   ##paymentterms_box


############################################################################
sub cust_category_box_new       #15.09.00 11:27
############################################################################

{

my $Category=$_[0];
$myStyle="Account";


$sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);

# Create html table header
my $str_select="
<table border='0' width='100%' cellspacing='1' cellpadding='2'>
<TR class=$myStyle><TH width='33%'></TH><TH width='33%'></TH><TH width='%33'></TR>
<TR class=$myStyle><TD></TD><TD></TD><TD></TD>";

my $check=0; # shift var
my $a=0;     # loop var
# fetch all 'alive' categories and set up checked for the selected categories
while (($i, $Name) = dbfetch()) {
    if (( $a%3) == 0 ) {$str_select.="</TR><TR class=$myStyle>"; }
    $a++;
    $check=0;
    # check box if $Category =$i
    foreach (@Category) {  if ( $_ == $i ) { $check=1; } }
    if ( $check == 1) {
        $str_select.="<TD align='right' class=$myStyle>$Name<INPUT TYPE='checkbox' NAME='Category' VALUE=$i CHECKED></TD> ";
      }
    else {
       $str_select.="<TD align='right' class=$myStyle>$Name<INPUT TYPE='checkbox' NAME='Category' VALUE=$i ></TD>";
    }
}

# format the end of html table
if (($a%3) == 1 ) {$str_select.="<TD></TD><TD></TD></Table><BR>"; }
elsif (( $a%3) == 2) {$str_select.="<TD></TD><TD></TD></Table><BR>"; }
else {$str_select.="</Table><BR>"; }


return $str_select;
}   ##cust_category_box_new


############################################################################
sub cust_category_box       #15.09.00 11:27
############################################################################

{

my $Category=$_[0];



$sql="SELECT Id, Name FROM Category WHERE Status=0 ORDER BY Name";
dbexecute($sql);

# Create html table header
my $str_select="
<table border='0' width='100%' cellspacing='1' cellpadding='2'>
<TR ><TH width='35%'></TH><TH width='35%'></TH><TH width='%35'></TR>
<TR ><TD></TD><TD></TD><TD></TD>";

my $check=0; # shift var
my $a=0;     # loop var
# fetch all 'alive' categories and set up checked for the selected categories
while (($i, $Name) = dbfetch()) {
    if (( $a%3) == 0 ) {$str_select.="</TR><TR>"; }
    $a++;
    $check=0;
    # check box if $Category =$i
    foreach (@Category) {  if ( $_ == $i ) { $check=1; } }
    if ( $check == 1) {
        $str_select.="<TD align='right' >$Name
                <INPUT TYPE='checkbox' NAME='Category' VALUE=$i CHECKED></TD> ";
      }
    else {
       $str_select.="<TD align='right'>$Name
                <INPUT TYPE='checkbox' NAME='Category' VALUE=$i ></TD>";
    }
}

# format the end of html table
if (($a%3) == 1 ) {$str_select.="<TD></TD><TD></TD></Table><BR>"; }
elsif (( $a%3) == 2) {$str_select.="<TD></TD><TD></TD></Table><BR>"; }
else {$str_select.="</Table><BR>"; }


return $str_select;
}   ##cust_category_box


############################################################################
sub cust_perspect_box       #15.09.00 11:38
############################################################################

{
# Create Customer's status group of radio-buttons for the forms

my $Perspect=$_[0]; # Get customer's status
my $str_perspect='';

$sql="SELECT Id, Name, Level FROM AccountType WHERE  Status=0 ORDER BY Level";
dbexecute($sql);

while (($Id, $Name, $Level ) =dbfetch()) {
  if ( $Level == $Perspect )
   { $str_perspect.="<INPUT type='radio' name=Perspect value=$Level CHECKED>$Name"; }
  else
   { $str_perspect.="<INPUT type='radio' name=Perspect value=$Level>$Name"; }
}

return $str_perspect;

}   ##cust_perspect_box



############################################################################
sub change_page        #03.11.99 15:20  Calculate #page for Navigator
############################################################################
{
 my $com=$_[0];         # use it to define page's number
 my $fun=$_[1];         # use it value to define next function to continue
 my $str_message=$_[2]; # simple transit it to the next function

 # set up first page
 if (($com eq 'First')||($com eq '   Query   ')||($com eq 'CategoryProduct')||
    ($com eq 'CategoryProductSpecials')||($com eq ' Retrieve Order History ')||($com eq '  Query  ') )
  {$page=1;}
 # set up current page
 elsif(($com eq 'Current')||($com eq 'Product')||($com eq 'ProductSpecials')||($com eq ' Cancel ')||
       ($com eq '  Cancel  ')||($com eq '     Ok     ')||($com eq 'Trans')||($com eq ' Continue '))
  {$page=$q->param('page');}
 # set up previous page
 elsif($com eq 'Previous') {
   $page=$q->param('page');
   $page=$page-1;
 }
 # set up next page
 elsif ($com eq 'Next') {

   $page=$q->param('page');
   $page=$page+1;
 }
 # set up last page
 elsif ($com eq 'Last') {

   $pageLast=$q->param('pageLast');
   $page=$pageLast;
  }
# get and keep $search throug pages scolling
$_=$q->param('Search');
(s/^\s+//);
$Search=$_;

# select fuction to continue for bpth 'customer' and 'admin' mode
if ( $fun==1 ) { product($page,$Search,$str_message); }
elsif( $fun==2 ){ transactions($page,$Search,$str_message);}
else { customer($page,$Search,$str_message);}

}   ##change_page





############################################################################
# MIME-type array to upload files('Send message' admin mode)
############################################################################

%array_mime=(
"XLS"=> "application/vnd.ms-excel",
"AAB"=> "application/x-authorware-bin",
"AAM"=> "application/x-authorware-map",
"AAS"=> "application/x-authorware-seg",
"ACC"=> "chemical/x-synopsys-accord",
"AI"=> "application/postscript",
"AIF"=> "audio/x-aiff",
"AIFC"=> "audio/x-aiff",
"AIFF"=> "audio/x-aiff",
"AIS"=> "text/plain",
"ANO"=> "application/x-annotator",
"APM"=> "application/studiom",
"ASD"=> "application/astound",
"ASN"=> "application/astound",
"ASP"=> "application/x-asap",
"AU"=> "audio/basic",
"AVI"=> "video/x-msvideo",
"BCPIO"=> "application/x-bcpio",
"BIN"=> "application/octet-stream",
"CDF"=> "application/x-netcdf",
"CGI"=> "text/plain",
"CHAT"=> "application/x-chat",
"CHM"=> "chemical/x-cs-chemdraw",
"CLASS"=> "application/octet-stream",
"CMX"=> "image/x-cmx	",
"COD"=> "image/cis-cod",
"CPIO"=> "application/x-cpio",
"CPT"=> "application/mac-compactpro",
"CSH"=> "application/x-csh",
"DCR"=> "application/x-director",
"DFX"=> "application/dsptype",
"DIR"=> "application/x-director",
"DLL"=> "application/octet-stream",
"DMS"=> "application/octet-stream",
"DOC"=> "application/msword",
"DSP"=> "application/dsptype",
"DVI"=> "application/x-dvi",
"DWG"=> "application/autocad",
"DXR"=> "application/x-director",
"EPB"=> "application/x-epublisher",
"EPS"=> "application/postscript",
"ES"=> "audio/echospeech",
"ETX"=> "text/x-setext",
"EVY"=> "application/envoy",
"EXE"=> "application/octet-stream",
"FAXMGR"=> "application/x-fax-manager",
"FAXMGRJOB"=> "application/x-fax-manager-job",
"FGD"=> "application/x-director",
"FID"=> "image/fif",
"FM"=> "application/x-framemaker",
"FRAME"=> "application/x-framemaker",
"FRM"=> "application/x-framemaker",
"GIF"=> "image/gif",
"GTAR"=> "application/x-gtar",
"GZ"=> "application/x-gzip",
"HDF"=> "application/x-hdf",
"HQX"=> "application/mac-binhex40",
"HTM"=> "text/html",
"HTML"=> "text/html",
"ICE"=> "x-conference/x-cooltalk",
"ICO"=> "image/ico",
"IEF"=> "image/ief",
"IMD"=> "application/immedia",
"INS"=> "application/x-insight",
"INSIGHT"=> "application/x-insight",
"INST"=> "application/x-install",
"IV"=> "application/x-inventor",
"JPE"=> "image/jpeg",
"JPEG"=> "image/jpeg",
"JPG"=> "image/jpeg",
"JS"=> "application/x-javascript",
"KAR"=> "audio/midi",
"LATEX"=> "application/x-latex",
"LHA"=> "application/octet-stream",
"LIC"=> "application/x-enterlicense",
"LICMGR"=> "application/x-licensemgr",
"M3U"=> "audio/x-mpegurl",
"MAIL"=> "application/x-mailfolder",
"MAKER"=> "application/x-framemaker",
"MAN"=> "application/x-troff-man",
"MCF"=> "image/vasa",
"ME"=> "application/x-troff-me",
"MID"=> "audio/midi",
"MID"=> "audio/x-midi",
"MIF"=> "application/x-mailfolder",
"MOL"=> "chemical/x-mdl-molfile",
"MOV"=> "video/quicktime",
"MOVIE"=> "video/x-sgi-movie",
"MP2"=> "audio/mpeg",
"MP2A"=> "audio/x-mpeg2",
"MP2V"=> "video/x-mpeg2",
"MP3"=> "audio/x-mpeg",
"MP3URL"=> "audio/x-mpegurl",
"MPA2"=> "audio/x-mpeg2",
"MPE"=> "video/mpeg",
"MPEG"=> "video/mpeg",
"MPG"=> "video/mpeg",
"MPGA"=> "audio/mpeg	",
"MPS"=> "video/x-mpeg-system",
"MPV2"=> "video/x-mpeg2	",
"MS"=> "application/x-troff-ms",
"MV"=> "video/x-sgi-movie	",
"NC"=> "application/x-netcdf",
"NFO"=> "text/warez-info",
"ODA"=> "application/oda",
"PAT"=> "audio/x-pat",
"PBM"=> "image/x-portable-bitmap",
"PCD"=> "image/x-photo-cd",
"PDB"=> "chemical/x-pdb",
"PDF"=> "application/pdf",
"PGM"=> "image/x-portable-graymap",
"PL"=> "text/plain",
"PNG"=> "image/png",
"PNM"=> "image/x-portable-anymap",
"PPM"=> "image/x-portable-pixmap",
"PPT"=> "application/powerpoint",
"PREF"=> "text/plain",
"PS"=> "application/postscript",
"PUZ"=> "application/x-crossword",
"QT"=> "video/quicktime",
"RA"=> "audio/x-realaudio",
"RAM"=> "audio/x-pn-realaudio",
"RAS"=> "image/x-cmu-raster",
"RGB"=> "image/x-rgb",
"RPM"=> "audio/x-pn-realaudio-plugin",
"RTF"=> "application/rtf",
"RTX"=> "text/richtext",
"RXN"=> "chemical/x-mdl-rxn",
"SBK"=> "audio/x-sbk",
"SDS"=> "application/x-onlive",
"SGI-LPR"=> "application/x-sgi-lpr",
"SGM"=> "text/x-sgml",
"SGML"=> "text/x-sgml",
"SH"=> "application/x-sh",
"SHAR"=> "application/x-shar",
"SHTML"=> "text/html",
"SIT"=> "application/x-stuffit",
"SKC"=> "chemical/x-mdl-isis",
"SKD"=> "application/x-koan",
"SKM"=> "application/x-koan",
"SKP"=> "application/x-koan",
"SKT"=> "application/x-koan",
"SMD"=> "chemical/x-smd",
"SMI"=> "chemical/x-daylight-smiles",
"SND"=> "audio/basic",
"SPL"=> "application/futuresplash",
"SPR"=> "application/x-sprite",
"SPRITE"=> "application/x-sprite",
"SRC"=> "application/x-wais-source",
"STM"=> "text/html",
"STR"=> "audio/x-str",
"SV4CPIO"=> "application/x-sv4cpio",
"SV4CRC"=> "application/x-sv4crc",
"SVR"=> "x-world/x-svr",
"SWF"=> "application/x-shockwave-flash",
"SYS"=> "video/x-mpeg-system",
"T"=> "application/x-troff",
"TALK"=> "text/x-speech",
"TAR"=> "application/x-tar",
"TARDIST"=> "application/x-tardist",
"TCL"=> "application/x-tcl",
"TEX"=> "application/x-tex",
"TEXI"=> "application/x-texinfo",
"TEXINFO"=> "application/x-texinfo",
"TGZ"=> "application/x-compressed",
"TIF"=> "image/tiff",
"TIFF"=> "image/tiff",
"TR"=> "application/x-troff",
"TROFF"=> "application/x-troff",
"TSI"=> "audio/tsplayer",
"TSV"=> "text/tab-separated-values",
"TVM"=> "application/x-tvml",
"TVM"=> "application/x-tvml",
"TXT"=> "text/plain",
"USTAR"=> "application/x-ustar",
"VCD"=> "application/x-cdlink",
"VIV"=> "video/vivo",
"VIVO"=> "video/vivo",
"VMD"=> "application/vocaltec-media-desc",
"VMF"=> "application/vocaltec-media-file",
"VOX"=> "audio/voxware",
"VRJ"=> "x-world/x-vrt",
"VRJT"=> "x-world/x-vrt",
"VRML"=> "x-world/x-vrml",
"WAV"=> "audio/x-wav",
"WKZ"=> "application/x-wingz",
"WRL"=> "x-world/x-vrml",
"XAR"=> "application/vnd.xara",
"XBM"=> "image/x-xbitmap",
"XPM"=> "image/x-xpixmap",
"XWD"=> "image/x-xwindowdump",
"XYZ"=> "chemical/x-pdb",
"Z"=> "application/x-compress",
"ZIP"=> "application/x-zip-compressed",
"ZTARDIST"=> "application/x-ztardist"
);