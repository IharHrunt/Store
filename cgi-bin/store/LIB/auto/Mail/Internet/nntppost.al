# NOTE: Derived from blib\lib\Mail\Internet.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Mail::Internet;

#line 556 "blib\lib\Mail\Internet.pm (autosplit into blib\lib\auto/Mail\Internet/nntppost.al)"
sub nntppost;

use Mail::Util qw(mailaddress);


require Net::NNTP;

 sub nntppost
{
 my $mail = shift;
 my %opt = @_;

 my $groups = $mail->get('Newsgroups') || "";
 my @groups = split(/[\s,]+/,$groups);

 return () unless @groups;

 my $art = $mail->dup;

 $art->replace('X-Mailer', "Perl5 Mail::Internet v" . $Mail::Internet::VERSION);

 unless($art->get('From'))
  {
   my $name = $ENV{NAME} || (getpwuid($>))[6];
   while( $name =~ s/\([^\(]*\)// ) {1};
   $art->replace('From',$name . " <" . mailaddress() . ">");
  }

 # Remove these incase the NNTP host decides to mail as well as me
 $art->delete(qw(To Cc Bcc)); 

 my @opt = ();
 push(@opt, $opt{'Host'}) if exists $opt{'Host'};
 push(@opt, 'Port', $opt{'Port'}) if exists $opt{'Port'};
 push(@opt, 'Debug', $opt{'Debug'}) if exists $opt{'Debug'};
warn join(" ",@opt);
 my $news = new Net::NNTP(@opt) or return ();

 $news->post(@{$art->header},"\n",@{$art->body});

 my $code = $news->code;
 $news->quit;

 return 240 == $code ? @groups : ();
}

# end of Mail::Internet::nntppost
1;
