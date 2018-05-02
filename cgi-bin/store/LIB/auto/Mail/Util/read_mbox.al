# NOTE: Derived from blib\lib\Mail\Util.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Mail::Util;

#line 79 "blib\lib\Mail\Util.pm (autosplit into blib\lib\auto/Mail\Util/read_mbox.al)"
sub read_mbox;


use FileHandle;
use Carp;
require POSIX;

 sub read_mbox {
 my $file  = shift;
 my $fd    = FileHandle->new($file,"r") || croak "cannot open '$file': $!\n";
 my @mail  = ();
 my $mail  = [];
 my $blank = 1;

 local $_;

 while(<$fd>) {
  if($blank && /\AFrom .*\d{4}/) {
   push(@mail, $mail) if scalar(@{$mail});
   $mail = [ $_ ];
   $blank = 0;
  }
  else {
   $blank = m#\A\Z#o ? 1 : 0;
   push(@{$mail}, $_);
  }
 }

 push(@mail, $mail) if scalar(@{$mail});

 $fd->close;

 return wantarray ? @mail : \@mail;
}

# end of Mail::Util::read_mbox
1;
