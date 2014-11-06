#!/usr/bin/perl

use Module::Build;
my $build = Module::Build->new(
	dist_abstract => 'Non-blocking framework for message interchange over pipes or ssh',
	dist_author   => 'Nick Andrew <nick@nick-andrew.net>',
	dist_version  => '0.001',
	installdirs   => 'vendor',
	module_name   => 'AnyEvent::TtyServer',
	requires      => {
		AnyEvent     => 0,
		JSON         => 0,
		'IPC::Open2' => 0,
	},
);

$build->create_build_script;
