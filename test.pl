use strict;

BEGIN { $| = 1; print "1..3\n"; }

use Carp;
use Net::Blogger;
use Term::ReadKey;

my $blogger = undef;
my $success = 0;

# 1

$blogger = Net::Blogger->new(debug=>&ask_yesno("Enable debugging output"));

if (ref($blogger) ne "Net::Blogger") {
  carp $!;
  print "not ok 1\n";
} else {
  $success++;
  print "ok 1\n";
}

# 2
     
$blogger->Proxy(&ask("URI of a working Blogger API server"));
$blogger->Username(&ask("Username"));
$blogger->Password(&ask_password());
$blogger->AppKey(&ask("App key (optional)"));

my $id = $blogger->GetBlogId(blogname=>&ask("Blog name"));

if (! $blogger->BlogId($id)) {
  carp $blogger->LastError();
  print "not ok 2\n";
} else {
  $success++;
  print "ok 2\n";
}

# 3

my $post    = &ask("Please enter some text");
my $publish = &ask_yesno("Publish this text");

if (! $blogger->newPost(postbody=>\$post,publish=>$publish)) {
  carp $blogger->LastError();
  print "not ok 3\n";
} else {
  $success++;
  print "ok 3\n";
}

END {
  if ($success == 3) {
    print "Passed all tests\n";
  }
}

sub ask_yesno {
  my $answer = &ask(@_);
  return ($answer =~ /^y(es)*$/i) ? 1 : 0;
}

sub ask {
  my $question = shift;
  print $question."? ";
  my $answer = <STDIN>;
  chomp $answer;
  return $answer;
}

sub ask_password {
    my $pass = undef;

    my $prompt = "Please enter password";
    
    while (! $pass) {

	print "$prompt: ";
	
	&Term::ReadKey::ReadMode("noecho");
        $pass = &Term::ReadKey::ReadLine(0);
        chomp $pass;
        &Term::ReadKey::ReadMode("normal");
        print "\n";
    }    

    return $pass;
}
