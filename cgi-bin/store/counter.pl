#!c:\perl\bin\MSWin32-x86\perl.exe
#!/usr/bin/perl
############################################################################
# Store 2005 by Ihar Hrunt. smartcgi@mail.ru  / counter.pl
#
############################################################################

require 'db.pl';

$counter='';
$path_counter=$path_menu_js."counter.dat";

open(FILE, $path_counter);
read(FILE, $counter, 100000, 0);
close (FILE);

if ((defined $counter)&&($counter ne '')) {

  $counter++;
  unlink ($path_counter);

  open(FILE, ">> $path_counter");
  print FILE $counter;
  close(FILE);
  print "Location: /store/img/pix.gif\n\n";

}

exit;

