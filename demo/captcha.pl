#!/usr/bin/perl

use strict;
use lib qw(../lib);

use Mojolicious::Lite;

my $CAPTCHA;

plugin captcha_renderer => { size => 50 };

any '/' => sub {
	my $self = shift;
	
	if ($self->req->param('submit')) {
		$self->check::form;
		
		return $self->render(ok => 1) 
			unless %{$self->stash('error')}
		;
	}
} => 'index';

get '/images/code.png' => sub {
	my $self = shift;
	
	my @letter = (0..9, 'a'..'z');
	
	my $code = join '', @letter[ map { int rand @letter } 1..5 ]; 
	$CAPTCHA->{lc $code} = 1;
	$self->render_data($self->captcha($code));
};

app->start;

sub check::form {
	my $self = shift;
	
	$self->stash(error => {
		(map { $_ => 'Empty'       } grep { !$self->req->param($_) } qw(name address captcha)),
		(map { $_ => 'Bad captcha' } grep {  $self->req->param($_) && ! delete $CAPTCHA->{lc $self->req->param($_)} } qw(captcha)),
	});
}

__DATA__
@@ index.html.ep
% my $e = $self->stash('error');
<html>
	<head>
		<title>Mojolicious::Plugin::CaptchaRenderer Demo</title>
	</head>
	<body>
		<% unless ($self->stash('ok')) { %>
		<h1>Test form</h1>
		<form action="/" method="post">
			<input name="name" value="<%= param('name') || 'Enter your name' %>" /><br />
			<%== "<b>$e->{name}</b><br/>" if $e->{name}; %>
			
			<input name="address" value="<%= param('address') || 'Enter your address' %>" /><br />
			<%== "<b>$e->{address}</b><br/>" if $e->{address}; %>
			
			<img src="/images/code.png" alt="captcha" /><input name="captcha" value="&lt;-- enter here" /><br />
			<%== "<b>$e->{captcha}</b><br/>" if $e->{captcha}; %>
			<input type="submit" value="Send form" name="submit" />
		</form>
		<% } else { %>
		<h1>Congratulations! Captcha test passed!</h1>
		<% } %>
	</body>
</html>