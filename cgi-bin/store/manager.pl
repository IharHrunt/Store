#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# manager.pl by Ihar Hrunt. smartcgi@mail.ru
#
############################################################################

use CGI;
$q = new CGI;

$pathUrl="http://store.com/cgi-bin/cgiwrap/store/store/manager.pl";
$pathdownload="http://store.com/";
$path="/home/store/public_html/";
$slash="/";
$slash_len=1;
$dircode=16877;
$dircode2=16837;

#$path="C:\\Apache\\htdocs\\";
#$pathdownload="http://localhost/";
#$pathUrl="http://localhost/cgi-bin/store/manager.pl";
#$slash="\\";
#$slash_len=2;
#$dircode=16895;

$pathfile=$q->param('pathfile');
$pathdown=$q->param('pathdown');
if ( $pathfile eq '' ) {  $pathfile=$path; }
if ( $pathdown eq '' ) {  $pathdown=$pathdownload; }


#############
#if ( $pathfile !~/\/home\/vybor\/public_html\/anticrisis\//){ accessdenied(); return; }
#if ( $pathfile !~/C:\\Apache\\htdocs\\anticrisis\\/){ accessdenied(); return; }
#############


$com = $q->param('com');
if    ( $com eq ''      )  { check(); }
elsif ( $com eq 'Upload File(s)')  { upload_file(); }
elsif ( $com eq 'View'  )  { view_file(); }
elsif ( $com eq 'Delete')  { remove_file(); }
elsif ( $com eq 'Rename')  { rename_file(); }
elsif ( $com eq ' MkDir ' ) { mk_dir(); }


############################################################################
sub check      #17.02.2000 15:39   
############################################################################

{

my $user = $q->param('user'); 
my $pass = $q->param('pass'); 

########
# if (( lc($user) eq "moscow" ) && ( $pass eq "moscow" )) { sender(); return; }
# else { accessdenied(); }
########

sender(); return;


}   ##check


############################################################################
sub accessdenied      #17.02.2000 15:39   Create 'Access Denied' form
############################################################################

{

#Access Denied.
print <<Browser;
Content-type: text/html\n\n
<HTML>
<HEAD>
<TITLE>Web Files Manager</TITLE>
</HEAD>
<BODY BGCOLOR='#CCCCCC'>
<BR><CENTER><h2> Access Denied </h2>

</b></CENTER>
</BODY></HTML>
Browser

}   ##accessdenied


############################################################################
sub sender      #05.07.00 8:03
############################################################################

{
$message=$_[0];


opendir(DIR, $pathfile) || die "can't opendir $pathfile: $!";
  @array_files=readdir(DIR);
closedir DIR;
@array_files = sort {uc($a) cmp uc($b)} @array_files;


my $str_scriptvar='';
if ( $message ne '' ) { $str_scriptvar="alert('$message')"; }

my $str_select="<table border='1' cellpadding='1' cellspacing='0' width='100%'' >
<tr><td align='center' colspan=4><b>$pathfile</b></td></tr>\n";

my $str_select1="";
my $str_select2="";

#<tr><td align='center'><b>Dir/File</b></td><td align='center'><b>Size, B</b></td><td align='center'><b>Date/Time</b></td></tr>\n";

if ( $array_files[0] eq ''){  $str_select.="No files"; }
else {
   my $i=0;
   foreach (@array_files) {
      if ( $_ eq '.' ) { next; }
      $i++;

      ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
      $mtime,$ctime,$blksize,$blocks) = stat($pathfile.$_);
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

      $year=1900+$year; $mon=1+$mon;

      if ( $mon<10)  { $mon="0$mon";}    # set up format of month 'MM'
      if ( $mday<10) { $mday="0$mday";}  # set up format of day 'DD'
      $fdate="$year-$mon-$mday";

      if ( $sec<10)  { $sec="0$sec";}
      if ( $min<10) { $min="0$min";}
      if ( $hour<10) { $hour="0$hour";}
      $ftime="$hour:$min:$sec";

      if (($mode == $dircode)||($mode == $dircode2)) {
         if ($_ eq '..') {
           if   ( $pathfile le $path ) {
              $ffile="<b>$_</b>";
              $pathfile=$path;
           }
           else {

            $len = length ($pathfile);
            $tmp = substr($pathfile, 0, $len-$slash_len );
            $r = rindex $tmp, $slash;
            $pathfiletop=substr($tmp, 0, $r+1);

            $len = length ($pathdown);
            $tmp = substr($pathdown, 0, $len-1 );
            $r = rindex $tmp, $slash;
            $pathdowntop=substr($tmp, 0, $r+1);


            $ffile="<a href='$pathUrl?com=View&pathdown=$pathdowntop&pathfile=$pathfiletop' title='Up Directory'><b>$_</b></a>";
           }
           $str_select1.="<tr><td>&nbsp;$ffile</td><td align=center><b>< &nbsp;Up&nbsp; ></b></td><td>&nbsp;<b>$fdate $ftime</b></td><td align=center><b>box</b></td></tr>\n";
         }
         else {
           $ffile="<a href='$pathUrl?com=View&pathdown=$pathdown$_$slash&pathfile=$pathfile$_$slash' title='Down Directory'><b>$_</b></a>";
           $str_select1.="<tr><td>&nbsp;$ffile</td><td align=center><b>< DIR ></b></td><td>&nbsp;<b>$fdate $ftime</b></td><td align=center><INPUT type='checkbox' name='rem_files' value='$_'></td></tr>\n";

         }
      }
      else {
         $ffile="<a href='".$pathdown.$_."' target='new$i' title='Download File'>$_</a>";
         $str_select2.="<tr><td>&nbsp;$ffile</td><td align=right>$size&nbsp;</td><td>&nbsp;$fdate $ftime</td><td align=center><INPUT type='checkbox' name='rem_files' value='$_'></td></tr>\n";
      }
   }
}
$str_select.=$str_select1.$str_select2."</table>";



print <<Browser;
Content-type: text/html\n\n
<HTML>
<TITLE>Web Files Manager</TITLE>
<HEAD>
<STYLE>A {TEXT-DECORATION: none }
A:link { COLOR: black; TEXT-DECORATION: underline }
A:active { COLOR: #ff0000 }
A:visited { COLOR: black;  TEXT-DECORATION: underline}
A:hover { COLOR: #ff0000; TEXT-DECORATION: underline }
</STYLE>

<SCRIPT>
function check_attach() {

    if (document.form1.filename1.value == '') {
       alert('Please select the file to upload.');
       document.form1.filename1.focus();
       return false;
    }
    else { return true; }
}

function check_remove() {
    if (confirm("DIR/File(s) you specified will be deleted! Are you sure?")) {
      return true
    }
    else {  return false; }
}

function check_rename() {
    if (document.form1.newdirname.value == '') {
       alert('Please specify DIR or File new name that will be used for the replacement.');
       document.form1.newdirname.focus();
       return false;
    }
    else {
        if (confirm("DIR or File you specified will be renamed with a new name! Are you sure?")) {
          return true
        }
        else { return false; }
   }
}

function check_mkdir() {
    if (document.form1.dirname.value == '') {
       alert('Please specify DIR name.');
       document.form1.dirname.focus();
       return false;
    }
    else { return true; }
}

function setFocus () {
  $str_scriptvar
}


</SCRIPT></HEAD>
<BODY BGCOLOR='#CCCCCC' onLoad='setFocus()'>
<FORM name='form1' METHOD='POST' ACTION=$pathUrl enctype='multipart/form-data'>
<CENTER>
<h2>Web Files Manager *</h2>

<table border='1' cellpadding='1' cellspacing='0' width='100%'' >
<TR><TD width='55%' valign='top'>
  $str_select
  <br>
  &nbsp; * <font size=2>DIRs or Files names are CASE SENSITIVE as UNIX platform is used.</font><br>
    &nbsp; ** <font size=2>To Open DIR or Download File please click on the link with its name.</font>
</TD>
<TD width='45%' valign='top'>

<table border='0' cellpadding='0' cellspacing='0' width='90%'' align=center>
<tr><td align = 'left'>
<br>
<b>Upload File(s):</b><br>
<font SIZE='1' face='Arial, Helvetica, Condensed'>
Click the "Browse" button to locate the file you need, and select it. The file path will
appear in the 'Input' field. Next, open directory on Web-server where you want to put
your file and click "Upload File(s)" to upload the selected file to Web-Server.
</font>
</td></tr></table>

<table border='0' cellpadding='0' cellspacing='0' width='90%'' align=center>
<tr><td align = 'left'>

<table border='0' cellpadding='4' cellspacing='0' width='100%'' bgcolor=''#E0E0E0'>
<tr><td align='left'>
Local Directories (Input):<br>
<input type='file' name='filename1' size=22 >
</td></tr>
<tr><td align = 'left'>
<input type='file' name='filename2' size=22 >
</td></tr>
<tr><td align = 'left'>
<input type='file' name='filename3' size=22 >
</td></tr>
<tr><td align = 'left'>
<input type='file' name='filename4' size=22 >
</td></tr>
<tr><td align = 'left'>
<br>

<input type=hidden name=pathfile value="$pathfile">
<input type=hidden name=pathfiletop value="$pathfiletop">
<input type=hidden name=pathdown value="$pathdown">
<input type=hidden name=pathdowntop value="$pathdowntop">

<input type='submit' name='com' value='Upload File(s)' onClick='return check_attach()' >

<hr>
<table border='0' cellpadding='0' cellspacing='0' width='100%'' align=center>
<tr><td align = 'left'>
<br>
<b>Make Dir:</b><br><font SIZE='1' face='Arial, Helvetica, Condensed'>
To make a new directory please open directory on Web-server where you want to
put it in then specify a new directory name in the field below and click on the button
"MkDir".
</font>
</td></tr></table>

<input type='text' name='dirname' size=30 style='width:290px'>
<br><br>
<input type='submit' name='com' value=' MkDir ' onClick='return check_mkdir()'>

<hr>
<table border='0' cellpadding='0' cellspacing='0' width='100%'' align=center>
<tr><td align = 'left'>
<br>
<b>Rename Dir/File</b><br><font SIZE='1' face='Arial, Helvetica, Condensed'>
To rename DIR or File please  SWITCH ON the box <b><u>(ONLY ONE BOX IN OTHER CASE THE FIRST OCCURANCE WILL BE REPLACED WITH A NEW NAME ONLY)</u></b> upon that DIR or File
which you want to rename then specify its new name in the field below and
click on the button "Rename".
</font>
</td></tr></table>

<input type='text' name='newdirname' size=30 style='width:290px'>
<br><br>
<input type='submit' name='com' value='Rename'  onClick='return check_rename()'>

<hr>
<table border='0' cellpadding='0' cellspacing='0' width='100%'' align=center>
<tr><td align = 'left'>
<br>
<b>Delete Dir/File:</b><br><font SIZE='1' face='Arial, Helvetica, Condensed'>
To delete  DIR or File please SWITCH ON the box(es) upon that DIR/File(s) on Web-server listings
and click on the button "Delete". <u>WARNING!  THE DIR SPECIFIED FOR DELETING MUST BE EMPTY!</u>
</font>
</td></tr></table>
<br>
<input type='submit' name='com' value='Delete'  onClick='return check_remove()'>
</td></tr>
</table>
</td></tr></table>
</form>
</TD></TR></table>
<br>
<div align=left>&nbsp;<font size=2>&copy; BIP Corporation, 2002. All right reserved.</font></b></div>
<br>
</BODY></HTML>
Browser
}   ##sendermessages


############################################################################
sub upload_file      #12.09.00 14:09
############################################################################

{

$filename1=$q->param('filename1');
$filename2=$q->param('filename2');
$filename3=$q->param('filename3');
$filename4=$q->param('filename4');

$mess1=write_file($filename1);
$mess2=write_file($filename2);
$mess3=write_file($filename3);
$mess4=write_file($filename4);

$message=$mess1.$mess2.$mess3.$mess4;


sender($message);

}   ##upload_file

############################################################################
sub write_file      #19.09.00 10:58
############################################################################

{

$filename=$_[0];
$message_tmp='';

if ( $filename ne '') {

  if ($filename=~m/^.*(\\|\/)(.*)/) {
    $name_attach = $2;
  }
  else {
    $name_attach=$filename;
  }
  $message_tmp="* Error. File \"$name_attach\" has NOT been uploaded!!!\\n";

  if (!(  open (FILE, ">$pathfile/$name_attach")  )) {
     $pathfile='';
     sender("* Error! Directory not found on the web-server.");
     return;
  }

  binmode(FILE);
  while(<$filename>){  print FILE ; }
  close(FILE);
  $message_tmp="* File \"$name_attach\" has been uploaded successfully.\\n";
}

return $message_tmp;

}   ##write_file


############################################################################
sub view_file      #19.09.00 10:58
############################################################################

{

  if (!(  opendir (FILE, "$pathfile")  )) {
     $pathfile='';
     sender("* Error! Directory not found on the web-server.");
     return;
  }
  closedir DIR;

  sender();


}   ##view_file


############################################################################
sub mk_dir   #19.09.00 10:58
############################################################################

{


$dirname=$q->param('dirname');
if ($dirname eq '' ) {
  $message="* Error. Please specify a name of the directory.";
  sender($message);
  return;
}

if (!( opendir(DIR, $pathfile) )) {
   $pathfile='';
   sender("* Error! Directory not found on the web-server.");
   return;
}

if (mkdir($pathfile.$slash.$dirname, 0755)) { $message="* DIR \"$dirname\" has been made successfully."; }
else { $message="* Error. The directory has not been made."; }

sender($message);

}   ##mk_dir


############################################################################
sub remove_file    #19.09.00 10:58   Remove file from list of uploaded files
############################################################################

{


# Get list of file to remove from list of uploaded files
@rem_files=$q->param('rem_files');


if (!( opendir(DIR, $pathfile) )) {
   $pathfile='';
   sender("* Error! Directory not found on the web-server.");
   return;
}

@dots=readdir(DIR);
closedir DIR;

$message1='';
$err='';
$check=0;
@dots = sort {uc($a) cmp uc($b)} @dots;
@rem_files = sort {uc($a) cmp uc($b)} @rem_files;

foreach $dots(@dots) {

   foreach $rem_files(@rem_files) {

     if ( $rem_files eq $dots ) {
        $check++;
        $comm=$pathfile.$dots;
        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
        $mtime,$ctime,$blksize,$blocks) = stat($comm);
        if ($mode == $dircode) {
            if (rmdir $comm ) {  $message1.="* DIR \"".$dots."\" has been deleted successfully.\\n"; }
            else { $err.="* Error! DIR \"".$dots."\" has NOT been deleted. Check if this DIR has file(s) or subdir inside.\\n"; }
        }
        else {
            if (unlink $comm ) {  $message1.="* File \"".$dots."\" has been deleted successfully.\\n"; }
            else { $err.="* Error! File \"".$dots."\" has NOT been deleted.\\n"; }
       }

     }
   }
}

if ($check==0) { $message="Nothing has been specified to delete!"; }
else { $message=$message1.$err; }

sender($message);

}   ##remove_file


############################################################################
sub rename_file    #19.09.00 10:58
############################################################################

{

@rem_files=$q->param('rem_files');
$newdirname=$q->param('newdirname');

if (!( opendir(DIR, $pathfile) )) {
   $pathfile='';
   sender("* Error! Directory not found on the web-server.");
   return;
}

@dots=readdir(DIR);
closedir DIR;

$message1='';
$err='';
$check=0;
@dots = sort {uc($a) cmp uc($b)} @dots;
@rem_files = sort {uc($a) cmp uc($b)} @rem_files;

foreach $dots(@dots) {

   foreach $rem_files(@rem_files) {

     if ( $rem_files eq $dots ) {
        $check++;
        $comm=$pathfile.$dots;
        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,
        $mtime,$ctime,$blksize,$blocks) = stat($comm);
        if ($mode == $dircode) {
            if (rename ($comm, $pathfile.$newdirname ) == 1) {  $message1.="* DIR \"".$dots."\" has been renamed to \"".$newdirname."\" successfully.\\n"; }
            else { $err.="* Error! DIR \"".$dots."\" has NOT been renamed. \\n"; }
        }
        else {
            if (rename ($comm, $pathfile.$newdirname ) == 1) {  $message1.="* File \"".$dots."\" has been renamed to \"".$newdirname."\" successfully.\\n"; }
            else { $err.="* Error! File \"".$dots."\" has NOT been renamed.\\n"; }
       }

     }
   }
}

if ($check==0) { $message="Nothing has been specified to rename!"; }
else { $message=$message1.$err; }

sender($message);

}   ##rename_file






