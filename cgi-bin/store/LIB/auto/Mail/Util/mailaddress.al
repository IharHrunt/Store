# NOTE: Derived from blib\lib\Mail\Util.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Mail::Util;

#line 192 "blib\lib\Mail\Util.pm (autosplit into blib\lib\auto/Mail\Util/mailaddress.al)"
sub mailaddress {

 ##
 ## Return imediately if already found
 ##

 return $mailaddress if(defined $mailaddress);

 ##
 ## Get user name from environment
 ##

 $mailaddress = $ENV{MAILADDRESS} ||
                $ENV{USER} ||
                $ENV{LOGNAME} ||
                (getpwuid($>))[6] ||
                "postmaster";

 ##
 ## Add domain if it does not exist
 ##

 $mailaddress .= "@" . maildomain() unless($mailaddress =~ /\@/);

 $mailaddress;
}

1;
# end of Mail::Util::mailaddress
