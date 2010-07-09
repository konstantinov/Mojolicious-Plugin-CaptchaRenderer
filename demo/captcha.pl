#!/usr/bin/perl

use lib qw(../lib);

use Mojolicious::Lite;

plugin captcha_renderer => { size => 50 };

get '/' => sub {
	my $self = shift;
	
	$self->render(handler => 'captcha', code => '12345');
};



app->start;