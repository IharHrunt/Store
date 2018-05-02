#!/usr/bin/perl
use CGI;
#use MIME::Entity;
$q = new CGI;
require 'storedb.pl';
$pathUrl =$pathWeb.'test1.pl';

my $com = $q->param('com');
if ( $com eq '' ) {sender(); }
else { attach(); }



############################################################################
sub sender      #05.07.00 8:03
############################################################################

{

print "Content-type: text/html\n\n";
print "<HTML><HEAD></HEAD><BODY BGCOLOR='#CCCCCC' > ";

print "<FORM name='form1' METHOD='POST' ACTION=$pathUrl enctype='multipart/form-data' >";

#print $q->start_multipart_form(-method=>'post', -action=>$pathUrl);

print "<CENTER>
<table border='0' cellpadding='4' cellspacing='0' width='85%'' bgcolor=''#E0E0E0'><tr>
<td class='top'>&nbsp;Attach file(<B> Not ready yet </B>):</td>
<td><input type='file' name='filename' size=22 style='width:290px' class='input'></td>
<td align=left><input type='submit' name='com' value='Attach'  class='input'></td>
</tr></table>
</CENTER>
<FORM><BODY><HTML>";


}   ##sender



############################################################################
sub attach      #12.09.00 14:09
############################################################################

{

$filename=$q->param(filename);
$filename=~m/^.*(\\|\/)(.*)/;
$name = $2;
open (FILE, ">>D:\\$name");
#open (FILE, ">/home/store/public_html/send/$name") or die $!;
binmode(FILE);
while(<$filename>){
   print FILE ;
}
close(FILE);





print "Content-type: text/html\n\n";
print "<HTML><HEAD></HEAD><BODY BGCOLOR='#CCCCCC' > ";
print "Ok <BR>";
print "<BODY><HTML>";


}   ##attach
