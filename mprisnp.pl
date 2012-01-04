#! /usr/bin/perl

use warnings;
#use stricts;

use Net::DBus;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '0.5.4';
%IRSSI = (
	authors     => 'Andrey Karepin',
	contact     => 'egdfree@opensue.org',
	name        => 'mprisnp',
	description => 'Say\'s a now listening music. Powered by openSUSE and Guru. Guru power!',
	license     => 'GPL-3.0',
	url         => 'http://opensuse.org/',
	changed     => '4.01.2012'
);

####------------------------------------------------------------------
### TODO: 
###	  add support to mpris v.2
###	  add listing running player's
###	  add help
####------------------------------------------------------------------

my $service_name;  #service name used + player name

Irssi::settings_add_str('MPRISNP', 'mprisnp_player', "amarok");
Irssi::settings_add_str('MPRISNP', 'mprisnp_format', "listen \%artist\% - \%title\% < \%album\% >");

### It's mpris v.1 ###

sub init {
    $player_name = Irssi::settings_get_str('mprisnp_player');
    if ($player_name) {
      $service_name = 'org.mpris.' . $player_name;
    }
    else {
      Irssi::print("Player name not set. Use /np_player YOU_PLAYER_NAME");
    }
}

sub get_player {
    my $player;
    eval {
        $player = Net::DBus->session()
			  ->get_service($service_name)
			  ->get_object('/Player','org.freedesktop.MediaPlayer');
    };

    Irssi::print("Player $player_name not running.") unless $player;

    return $player;
}

sub cmd_mprisnp_set_player {
    if ($_[0]) {
      Irssi::settings_set_str('mprisnp_player', $_[0]);
      $service_name = 'org.mpris.' . $_[0];
      Irssi::print("Set player to " . $_[0]);
    } else {
      Irssi::print("Currently used player: " . Irssi::settings_get_str('mprisnp_player'));
    }
}

sub cmd_mprisnp_set_format {
    if ($_[0]) {
      Irssi::settings_set_str('mprisnp_format', $_[0]);
    } else {
      Irssi::print('Currently used format string: ' . Irssi::settings_get_str('mprisnp_format'));
      Irssi::print('To chenge then use /np_format \%format_str\%. See /help mprisnp format for more information.');
    }
}

sub cmd_mprisnp_available_players {
    #my @players = @(Net::DBus->session());

    #Irssi::print("Available (running) player\'s in your system:");

    #foreach (@players) {
    #  Irssi::print("\t$_");
    #}
}

sub cmd_mprisnp_show {
    if (my $player = &get_player) {
      my $s_print_np = "listens to silence...";
      my ($data, $server, $witem) = @_;
      my $status = @{$player->GetStatus}[0];

      if ($status != 2) {
        my %player_meta = %{$player->GetMetadata};
        my $allow_meta = join '|', keys %player_meta;
        $s_print_np = Irssi::settings_get_str('mprisnp_format');
        $s_print_np =~ s/%($allow_meta)%/$player_meta{$1}/g;
      }

      $server->command("ACTION $witem->{name} $s_print_np");
    }
}

sub cmd_mprisnp_play {
    my $player = &get_player;
    $player->Play() if ($player);
}

sub cmd_mprisnp_pause {
    my $player = &get_player;
    $player->Pause() if ($player);
}

sub cmd_mprisnp_stop {
    my $player = &get_player;
    $player->Stop() if ($player);
}

sub cmd_mprisnp_next {
    my $player = &get_player;
    $player->Next() if ($player);
}

sub cmd_mprisnp_prev {
    my $player = &get_player;
    $player->Prev() if ($player);
}
#--------------------------------------------------------------------
# Irssi::signal_add_last / Irssi::command_bind
#--------------------------------------------------------------------

Irssi::command_bind('np','cmd_mprisnp_show', 'MPRISNP');
Irssi::command_bind('play','cmd_mprisnp_play', 'MPRISNP');
Irssi::command_bind('pause','cmd_mprisnp_pause', 'MPRISNP');
Irssi::command_bind('stop','cmd_mprisnp_stop', 'MPRISNP');
Irssi::command_bind('next','cmd_mprisnp_next', 'MPRISNP');
Irssi::command_bind('prev','cmd_mprisnp_prev', 'MPRISNP');
Irssi::command_bind('np_player','cmd_mprisnp_set_player', 'MPRISNP');
Irssi::command_bind('np_format','cmd_mprisnp_set_format', 'MPRISNP');
#Irssi::command_bind("help","cmd_help", "Irssi commands");

#--------------------------------------------------------------------
# The command that's executed at load time.
#--------------------------------------------------------------------

init();

#--------------------------------------------------------------------
# This text is printed at Load time.
#--------------------------------------------------------------------

#Irssi::print("Use /help mprisnp for more information."); 
Irssi::print("MPRISNP loaded OK.");
#- end
