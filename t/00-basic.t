use strict;
use Test::More;

plan tests => 6;

use_ok("Carp");
use_ok("Net::Blogger");
use_ok("Term::ReadKey");

my $blogger = undef;
my $success = 0;

my $debug = &ask_yesno("Enable debugging output");
$blogger  = Net::Blogger->new(debug=>$debug);

isa_ok($blogger,"Net::Blogger");

$blogger->Proxy(&ask("URI of a working Blogger API server"));
$blogger->Username(&ask("Username"));
$blogger->Password(&ask_password());
$blogger->AppKey(&ask("App key (optional)"));

my $id = $blogger->GetBlogId(blogname=>&ask("Blog name"));

ok($blogger->BlogId($id));

my $post    = &ask("Please enter some text");
my $publish = &ask_yesno("Publish this text");

ok($blogger->newPost(postbody=>\$post,publish=>$publish));

#

sub ask_yesno {
  my $answer = &ask(@_);
  return ($answer =~ /^y(es)*$/i) ? 1 : 0;
}

sub ask {
  my $question = shift;
  &diag("\n$question ? ");

  my $answer = <STDIN>;
  chomp $answer;
  return $answer;
}

sub ask_password {
    my $pass = undef;

    my $prompt = "\nPlease enter password";

    while (! $pass) {

      &diag("$prompt: ");

      &Term::ReadKey::ReadMode("noecho");
      $pass = &Term::ReadKey::ReadLine(0);
      chomp $pass;

      &Term::ReadKey::ReadMode("normal");
      &diag("\n");
    }

    return $pass;
}
