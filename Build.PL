# $Id: Build.PL,v 1.1 2005/03/26 19:28:23 asc Exp $

use strict;
use Module::Build;

my $build = Module::Build->new(module_name => 'Net::Blogger',
			       # dist_author
			       # dist_abstract
			       dist_version_from => 'lib/Net/Blogger.pm',
			       license           => 'perl',
			       requires => {
				   'SOAP::Lite'    => '>= 0.55',
				   'CGI'           => '>= 0',
				   'Carp'          => '>= 0',
				   'Error'         => '>= 0',
				   'URI'           => '>= 0',
				   'Digest::MD5'   => '>= 0',
				   'HTTP::Cookies' => '>= 0',
			       },
			       build_requires => {
				   'Term::ReadKey' => '>= 0',
				   'Test::Simple'  => '>= 0.47',
			       },
			       create_readme      => 1,
			       create_makefile_pl => 'passthrough');

$build->create_build_script();
