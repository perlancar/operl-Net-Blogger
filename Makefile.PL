use ExtUtils::MakeMaker;

WriteMakefile(
	      'NAME'	     => 'Net::Blogger',
	      ($[ >= 5.005) ?
	      (AUTHOR   => 'Aaron Straup Cope (cpan@aaronland.net)',
	       ABSTRACT => 'Modules to interact with the Blogger API') : (),
	      'VERSION_FROM' => 'lib/Net/Blogger.pm',
	      'PREREQ_PM'    => {
				 SOAP::Lite    => '0.55',
				 Carp          => 0,
				 Error         => 0,
				 URI           => 0, 
				 # For testing
				 Term::ReadKey => 0,
				},
	      dist	        => {COMPRESS => 'gzip', SUFFIX => 'tar.gz'},
	     );
