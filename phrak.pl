#!/usr/bin/perl -w

package phrak;
use base qw(Bot::BasicBot);
use YAML::XS qw'DumpFile LoadFile';
use Data::Dumper;
our $oplist = YAML::XS::LoadFile("phrak.yaml");
our $tmplist = YAML::XS::LoadFile("phrak.yaml");

my $bot = phrak->new(
	server => 'irc.saurik.com',
	channels => ['#phrak'],
	nick => 'phrak');

sub reloadops{
	$oplist = YAML::XS::LoadFile("phrak.yaml");
}

sub addop{
	push($oplist->{"ops"},$_);	
}
sub said{
	my($self, $message) = @_;
	if($message->{body} =~ '!test'){
		$bot->say(channel => $message->{channel},
			body => "This is a test!\n");
	}
	elsif($message->{body} =~ '!oplist'){
		our @ops_iter;
		our $ops_num;
		foreach(@{$oplist -> { "ops" }}){
			push(@oparray,$_);
			$size = @oparray;
		}
		$bot->say(channel => $message->{channel},
		body => "The current list of Operators with Admin access are: \n");
		for ($x = 0;$x < $size; ++$x){
			$bot->say(channel => $message->{channel},
			body => $oparray[$x], address => $message->{who});
		}
	}
	elsif($message->{body} =~ '!addop'){
		if(grep { $_ eq $message->{who} } @{ $oplist->{"ops"} }){
			my $new_ops = $message->{body};
			$new_ops =~ s/!addop\s//;
			$new_ops =~ s/\'\s(.+)\'//;	
			$bot->say( channel => $message->{channel},
				   body => "Adding new ops: $new_ops",
				   address => $message->{who}
				);
			push($oplist->{"ops"},$new_ops);
			YAML::XS::DumpFile("phrak.yaml",$oplist);
			reloadops();
		}
		elsif(grep { $_ eq $message->{who} } @{ $tmplist->{"ops"} }){
			my $new_ops = $message->{body};
			$new_ops =~ s/!addop//;
			$bot->say( channel => $message->{channel},
				   body => "Adding new ops: $new_ops",
				   address => $message->{who}
				);
			push($oplist->{"ops"},$new_ops);
			YAML::XS::DumpFile("phrak.yaml",$tmplist);
			reloadops();
		}
		else{
			$bot->say( channel => $message->{channel},
				   body => 'Unable to add a new operator, Sorry for the inconvenience!',
				   address => $message->{who}
				);
		}
	}
	elsif($message->{body} =~ '!opme'){
		if(grep { $_ eq $message->{who} } @{ $oplist->{"ops"}}){
			$bot->mode("$message->{channel} +o $message->{who}");
		}
		else{
			$bot->say(channel => $message->{channel},
				body => "Your not an Op!!",
				address => $message->{who});
		}
	}
	elsif($message->{body} =~ '!deop'){
		if(grep { $_ eq $message->{who} } @{ $oplist->{"ops"}}){
			$bot->mode("$message->{channel} -o $message->{who}");
		}
		else{
			$bot->say(channel => $message->{channel},
			body => "Your not an Op!!",
			address => $message->{who});
		}
	}
	elsif($message->{body} =~ '!quit'){
		if(grep { $_ eq $message->{who} } @{ $oplist->{"ops"}}){
			$bot->shutdown($bot->quit_message());
		}
	}
		
	
}


sub chanjoin {
	
}

sub help { return '!test, !oplist' };

$bot->run();
