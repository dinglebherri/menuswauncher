#!/usr/bin/perl

use File::Basename;

$| = 1;
my $version_num = "1.6";

# Eliminate persistence errors witnessed on some machines
my $fixer = `read NSGlobalDomain`;
		if ($fixer =~ m/ApplePersistence/) {
				my $fixer = `defaults delete NSGlobalDomain ApplePersistence`;
		}

# Check preferences
if (-e "~/library/preferences/com.ari.MenuSwauncher.plist") {
				goto PREFS;
		} else {
				&defaults;
}

PREFS:
my $my_prefs = `defaults read com.ari.MenuSwauncher`;

if ($my_prefs =~ m/login = 0/) {
	$start_login = 0;
} elsif ($my_prefs =~ m/login = 1/) {
	$start_login = 1;
}

if ($my_prefs =~ m/notify = 0/) {
	$notify = 0;
} elsif ($my_prefs =~ m/notify = 1/) {
	$notify = 1;
}

if ($my_prefs =~ m/mode = 0/) {
	$app_mode = 0;
} elsif ($my_prefs =~ m/mode = 1/) {
	$app_mode = 1;
}

if ($my_prefs =~ m/apps = 0/) {
	$app_menu = 0;
} elsif ($my_prefs =~ m/apps = 1/) {
	$app_menu = 1;
}

if ($my_prefs =~ m/utils = 0/) {
	$util_menu = 0;
} elsif ($my_prefs =~ m/utils = 1/) {
	$util_menu = 1;
}

if ($my_prefs =~ m/favs = 0/) {
	$favs_menu = 0;
} elsif ($my_prefs =~ m/favs = 1/) {
	$favs_menu = 1;
}

if ($my_prefs =~ m/dm = 0/) {
	$dark_mode = 0;
} elsif ($my_prefs =~ m/dm = 1/) {
	$dark_mode = 1;
}

if ($my_prefs =~ m/noprocess = 0/) {
	$show_process = 0;
} elsif ($my_prefs =~ m/noprocess = 1/) {
	$show_process = 1;
}


# Generate list of active apps for switching / openings
if ($show_process == 1) {
				if ($app_mode == 0) {
					my $active_apps = `osascript -e 'tell application "System Events" to get POSIX path of (file of every process whose background only is false)'`;
					my @apps_long = split(',', $active_apps);
					s{^\s+|\s+$}{}g foreach @apps_long;
					my @sorted_long_name = sort {lc basename($a) cmp lc basename($b)} @apps_long;
					my $count_apps = scalar @sorted_long_name;
					for (my $i=0; $i <= $count_apps-1; $i++) {
						my $short_app_name = basename($sorted_long_name[$i]);
						for ($short_app_name) {
								s/.app//g;
						}
						my $app_name = length $short_app_name;
						if ($app_name > 40) {
							substr($short_app_name, -60) = "...";
						}
						
						$get_icon = `defaults read "$sorted_long_name[$i]/Contents/Info" CFBundleIconFile`;
						chomp($get_icon);
						if ($get_icon !~ m/.icns/) {
							$get_icon = $get_icon . ".icns";
						}
							print "MENUITEMICON|$sorted_long_name[$i]/Contents/Resources/$get_icon|$short_app_name\n";
					}
						
					   print "----\n";

} elsif ($app_mode == 1) {
				# Generate list of active apps without Finder for termination
				my $active_apps = `osascript -e 'tell application "System Events" to get name of (processes where background only is false and name is not \"Finder\")'`;
				   my @apps = split(',', $active_apps);
				s{^\s+|\s+$}{}g foreach @apps;
				   my @sorted_apps = sort {lc $a cmp lc $b} @apps;
				   my $count_apps = scalar @sorted_apps;
				if (length($active_apps) > 1) {
						for (my $i=0; $i <= $count_apps-1; $i++) {
								if ($dark_mode == 0) {
										print "MENUITEMICON|kill_icon.png|$sorted_apps[$i]\n";
								} else {
										print "MENUITEMICON|inv_kill_icon.png|$sorted_apps[$i]\n";
								}
						}
				print "----\n";

				}

						# Show "kill all apps" option
						if (length($active_apps) > 1) {
								if ($dark_mode == 0) {
										print "MENUITEMICON|fallout_icon.png|Terminate all Apps\n";
								} else {
										print "MENUITEMICON|inv_fallout_icon.png|Terminate all Apps\n";
								}
						}
				}
}

print "----\n";

if ($app_mode == 0) {
		if ($app_menu == 1) {
				# Generate app list for Applications Folder
				my @output = `ls -1 -F /Applications`;
				chomp @output;

				# Remove file extensions and delete references to subdirectories
				for (@output) {
						s/.app\///g;
				}

				# App Blacklist - remove non-apps and apps I wrote from here
				for my $index(reverse 0..$#output) {
						if ($output[$index] =~ /\// || $output[$index] =~ /Menu Swauncher/ || $output[$index] =~ /Menu Snappr/ || $output[$index] =~ /Menu Spot/ || $output[$index] =~ /.pdf/ || $output[$index] =~ /.txt/ || $output[$index] =~ /.doc/ || $output[$index] =~ /.png/ || $output[$index] =~ /.jpg/ || $output[$index] =~ /.rtfd/) {
								splice(@output, $index, 1, ());
						}
				}

				# Sort list of apps in the /Applications folder
				my @sorted_apps = sort {lc $a cmp lc $b} @output;
				my $count_apps = scalar @sorted_apps;
				print "SUBMENU|Launch Applications ($count_apps)|";
						for (my $i=0; $i <= $count_apps-1; $i++) {
							my $app_name = length $sorted_apps[$i];
							if ($app_name > 40) {
								substr($sorted_apps[$i], -60) = "...";
							}
								print $sorted_apps[$i] . "|";
						}
				print "\n";
		}

		if ($util_menu == 1) {
				# Generate app list for Utilities Folder
				my @output = `ls -1 -F /Applications/Utilities/`;
				chomp @output;
				# remove file extensions and delete references to subdirectories
				for (@output) {
						s/.app\///g;
				}

				if ($output[$index] =~ /\// || $output[$index] =~ /Menu Swauncher/ || $output[$index] =~ /Menu Snappr/ || $output[$index] =~ /Menu Spot/ || $output[$index] =~ /.pdf/ || $output[$index] =~ /.txt/ || $output[$index] =~ /.doc/ || $output[$index] =~ /.png/ || $output[$index] =~ /.jpg/ || $output[$index] =~ /.rtfd/) {
						splice(@output, $index, 1, ());
				}

				# Sort list of apps in the /Applications/Utilities folder
				my @sorted_apps = sort {lc $a cmp lc $b} @output;
				my $count_apps = scalar @sorted_apps;
				print "SUBMENU|Launch Utilities ($count_apps)|";
						for (my $i=0; $i <= $count_apps-1; $i++) {
							my $app_name = length $sorted_apps[$i];
							if ($app_name > 40) {
								substr($sorted_apps[$i], -60) = "...";
							}
								print $sorted_apps[$i] . "|";
						}
				print "\n";
		}

		# Load favorites apps file
		if ($favs_menu == 1) {
				my $who = `whoami`;
				chomp($who);
				# Replace user in file path
				$favorites = "/Users/ari/documents/wwu_favorites.txt";
				$favorites =~ s/ari/$who/g;
				if (-e $favorites) {
						open (FH, "< $favorites") or die "Can't open $favorites for read: $!";
						my @favorite_apps;
								while (<FH>) {
										push (@favorite_apps, $_);
								}
								chomp(@favorite_apps);
						close FH or die "Cannot close $file: $!";

				# Strip out cruft from file - eg. app extensions and blank lines in the Favorites file
						for (@favorite_apps) {
								s/.app//g;
								s/\n\n//g;
						}
						# Remove non-apps from Favorites apps array
						for my $index(reverse 0..$#favorite_apps) {
							 if ($favorite_apps[$index] =~ /.html/ || $favorite_apps[$index] =~ /.pdf/ || $favorite_apps[$index] =~ /.rtfd/ || $favorite_apps[$index] =~ /.doc/ || $favorite_apps[$index] =~ /.txt/ || $favorite_apps[$index] =~ /.png/ || $favorite_apps[$index] =~ /.jpg/ || $favorite_apps[$index] !~ /\/Applications/) {
								  splice(@favorite_apps, $index, 1, ());
							 }
						}

				# Ensure there's only one entry per app
				my @filtered_favs = uniq(@favorite_apps);
				# Sort list of apps found in the Favorites file
				my @sorted_fav_apps = sort {lc(basename($a)) cmp lc(basename($b))} @filtered_favs;
				my $count_apps = scalar @filtered_favs;

				print "SUBMENU|Launch Favorites ($count_apps)|";
				for (my $i=0; $i <= $count_apps-1; $i++) {
					my $app_name = length $sorted_fav_apps[$i];
					if ($app_name > 40) {
						substr($sorted_fav_apps[$i], -60) = "...";
					}
					
						print basename($sorted_fav_apps[$i]) . "|";
				}
										print "\n";
				# Option to edit Favorite Apps
				print "----\n";
								print "----\n";
						if ($dark_mode == 0) {
								print "MENUITEMICON|edit_icon.png|Edit Favorites\n";
						} else {
								print "MENUITEMICON|inv_edit_icon.png|Edit Favorites\n";
						}
								print "----\n";
						} else {
								# unselect "Show Favorite Apps" menu item is file doesn't exist
								print "----\n";
								my $command = `defaults write com.ari.MenuSwauncher favs 0`;
						}
		} else {
			print "----\n";
		}
		
		if ($dark_mode == 0) {
			print "MENUITEMICON|ss_icon.png|Activate Screen Saver\n";
			print "MENUITEMICON|lock_icon.png|Lock Computer Screen\n";
		} else {
			print "MENUITEMICON|inv_ss_icon.png|Activate Screen Saver\n";
			print "MENUITEMICON|inv_lock_icon.png|Lock Computer Screen\n";
		}

		print "----\n";
}

if ($app_mode == 0) {
	$mode = "    Terminate Mode";
} elsif ($app_mode == 1) {
	$mode = "✓ Terminate Mode";
}

if ($app_menu == 0) {
	$appf = "    Show Applications Menu";
} elsif ($app_menu == 1) {
	$appf = "✓ Show Applications Menu";
}

if ($util_menu == 0) {
	$utilf = "    Show Utilities Menu";
} elsif ($util_menu == 1) {
	$utilf = "✓ Show Utilities Menu";
}

if ($favs_menu == 0) {
	$favf = "    Show Favorites Menu";
} elsif ($favs_menu == 1) {
	$favf = "✓ Show Favorites Menu";
}

if ($show_process == 0) {
	$show_apps = "    Show Running Applications";
} elsif ($show_process == 1) {
	$show_apps = "✓ Show Running Applications";
}

if ($start_login == 0) {
	$login = "    Start at Login";
} elsif ($start_login == 1) {
	$login = "✓ Start at Login";
}

if ($show_process == 1) {
	print "SUBMENU|Settings|$mode|$show_apps|$appf|$utilf|$favf|$login\n";
} elsif ($show_process == 0) {
	print "SUBMENU|Settings|$show_apps|$appf|$utilf|$favf|$login\n";
} elsif ($app_mode == 1) {
	print "SUBMENU|Settings|$mode|$appf|$utilf|$favf|$login\n";
} elsif ($app_mode == 0) {
	print "SUBMENU|Settings|$mode|$show_apps|$appf|$utilf|$favf|$login\n";
}


print "----\n";
print "About...\n";

# Process user input
my $line = shift(@ARGV);

# If an active app, switch to it. If an app in the Applications or Utilities folders, launch it
if ($line ne "") {

		# Open selected app, if not Terminate mode launch it otherwise quit it
		if ($app_mode == 0) {
				my $command = `open -a \"$line\"`;
		} elsif ($app_mode == 1) {
		# Terminate selected app
				my $command = `osascript -e 'tell application \"$line\" to quit'`;
		}
}

# Terminate all apps and play sound
if ($line =~ m/Terminate all Apps/) {
		system("afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/Ellipsis.aiff");
		my $command = `osascript <<EOF
		tell application "System Events" to set quitapps to name of every application process
				whose visible is true and name is not "Finder"
				repeat with closeall in quitapps
				quit application closeall
				end repeat
		EOF`;
}

# Open selected favorite app
if ($line =~ m/Edit Favorites/) {
		my $command = `open -e $favorites`;
}

if ($line =~ /Screen Saver/) {
	my $command = `/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine`;
}

if ($line =~ /Lock Computer Screen/) {
	my $command = `pmset displaysleepnow`;
}

if ($line =~ m/Applications Menu/) {
		$app_menu = 1 - $app_menu;
		my $command = `defaults write com.ari.MenuSwauncher apps $app_menu`;
}

if ($line =~ m/Utilities Menu/) {
		$util_menu = 1 - $util_menu;
		my $command = `defaults write com.ari.MenuSwauncher utils $util_menu`;
}

if ($line =~ m/Favorites Menu/) {
		$favs_menu = 1 - $favs_menu;
		my $command = `defaults write com.ari.MenuSwauncher favs $favs_menu`;
}

if ($line =~ m/Show Running Applications/) {
		$show_process = 1 - $show_process;
		my $command = `defaults write com.ari.MenuSwauncher noprocess $show_process`;
}


if ($line =~ m/Terminate/) {
		$app_mode = 1 - $app_mode;
		my $command = `defaults write com.ari.MenuSwauncher mode $app_mode`;
		system("afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/Select.aiff");
}

# Set start at login option
if ($line =~ m/Start at Login/) {
		$start_login = 1 - $start_login;
		my $command = `defaults write com.ari.MenuSwauncher login $start_login`;

		if ($start_login == 1) {
				my $command = `osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Menu Swauncher.app", hidden:false}'`;
		} elsif ($start_login == 0) {
				my $command = `osascript -e 'tell application "System Events" to delete login item "Menu Swauncher"'`;
		}
}

if ($line =~ /About.../) {
		my $icon = `cp launcher_icon.png /tmp/icon.icns`;
		&dialog("Menu Swauncher $version_num\n\nA simple application launcher utility for macOS\n\nAri Feldman (25 October 2018)\ninfo\@widgetworx.com");
		my $command = `rm /tmp/icon.icns`;
}

sub uniq {
		my %seen;
		grep !$seen{$_}++, @_;
}

sub defaults {
		$start_login = 0;
		$notify = 0;
		$app_mode = 0;
		$app_menu = 1;
		$util_menu = 0;
		$favs_menu = 0;
		$show_process = 1;

		my $command = `osascript <<EOF
		tell application "System Events"
				tell appearance preferences
						if dark mode is true then
							do shell script "/usr/bin/defaults write com.ari.MenuSwauncher dm 1"
							else
							do shell script "/usr/bin/defaults write com.ari.MenuSwauncher dm 0"
						end if
				end tell
		end tell
		EOF`;
}

# Subs that enable Applescript dialog to be displayed
sub dialog {
	my ($text) = @_;
		my $command = `osascript <<EOF
		tell application "System Events"
				(display dialog "$text" buttons {"OK"} default button 1 with icon alias \"Macintosh HD:tmp:icon.icns\")
		 end tell
		EOF`;
}
