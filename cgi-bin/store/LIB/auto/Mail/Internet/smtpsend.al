# NOTE: Derived from blib\lib\Mail\Internet.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Mail::Internet;

#line 483 "blib\lib\Mail\Internet.pm (autosplit into blib\lib\auto/Mail\Internet/smtpsend.al)"
sub smtpsend;

use Carp;
use Mail::Util qw(mailaddress);
use Mail::Address;
use Net::Domain qw(hostname);
use Net::SMTP;


 sub smtpsend 
{
 my $src  = shift;
 my($mail,$smtp,@hosts);

 require Net::SMTP;

 @hosts = qw(mailhost localhost);
 unshift(@hosts, split(/:/, $ENV{SMTPHOSTS})) if(defined $ENV{SMTPHOSTS});

 foreach $host (@hosts) {
  $smtp = eval { Net::SMTP->new($host) };
  last if(defined $smtp);
 }

 croak "Cannot initiate a SMTP connection" unless(defined $smtp);

 $smtp->hello( hostname() );
 $mail = $src->dup;

 $mail->delete('From '); # Just in case :-)

 $mail->replace('X-Mailer', "Perl5 Mail::Internet v" . $Mail::Internet::VERSION);

 # Ensure the mail has the following headers
 # Sender, From, Reply-To

 my($from,$name,$tag);

 $name = (getpwuid($>))[6] || $ENV{NAME} || "";
 while($name =~ s/\([^\(]*\)//) { 1; }

 $from = sprintf "%s <%s>", $name, mailaddress();
 $from =~ s/\s{2,}/ /g;

 foreach $tag (qw(Sender From Reply-To))
  {
   $mail->add($tag,$from) unless($mail->get($tag));
  }

 # An original message should not have any Received lines

 $mail->delete('Received');

 # Who is it to

 my @rcpt = ($mail->get('To', 'Cc', 'Bcc'));
 my @addr = map($_->address, Mail::Address->parse(@rcpt));

 return () unless(@addr);

 $mail->delete('Bcc'); # Remove blind Cc's

 # Send it

 my $ok = $smtp->mail( mailaddress() ) &&
            $smtp->to(@addr) &&
            $smtp->data(join("", @{$mail->header},"\n",@{$mail->body}));

 $smtp->quit;

 $ok ? @addr : ();
}

# end of Mail::Internet::smtpsend
1;
