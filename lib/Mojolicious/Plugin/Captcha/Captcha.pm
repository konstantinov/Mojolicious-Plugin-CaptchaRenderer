package Mojolicious::Plugin::Captcha;

use strict;
use warnings;
use File::Temp;

use base 'Mojolicious::Plugin';

BEGIN {
	die 'Module Image::Magick not properly installed' unless eval { require Image::Magick; 1 }
}

sub register {
	my ($self,$app,$conf) = @_;
	
	$conf = {
		color          => 'black',
		bgcolor        => 'white',
		size           => 60,
		fond           => 'sans-serif',
		wave_amplitude => 7,
		wave_length    => 80,
		%$conf,
	};
	
	$app->renderer->add_handler(
		captcha => sub {
			my ($r,$c,$output,$options) = @_;
			
			$$output = captcha($c,$conf);
		}
	);
}

sub captcha {
	my ($c,$conf) = @_;
	
	my $img = Image::Magick->new(size => '400x400', magick => 'png');
	my $x; $x = $img->Read('gradient:#ffffff-#ffffff');
	
	$x = $img->Annotate(
		pointsize   => $conf->{'size'}, 
		fill        => $conf->{'color'}, 
		text        => $c->stash('code'), 
		geometry    => '+0+' . $conf->{'size'},
		font        => $conf->{'font'},
	);
	
	warn $x if $x;
	$x = $img->Wave(amplitude => $conf->{'wave_amplitude'}, wavelength => $conf->{'wave_length'});
	warn $x if $x;
	$x = $img->Trim;
	warn $x if $x;
	
	my $body = '';
	
	{
		my $fh = File::Temp->new(UNLINK => 1, DIR => $ENV{'MOJO_TMPDIR'});
		$x = $img->Write('png:' . $fh->filename);
		open $fh, '<', $fh->filename;
		local $/;
		$body = <$fh>;
	}
	warn $x if $x;
	
	
	$c->tx->res->headers->content_type('image/png');
	return $body;
}

1;