function __fish_command_not_found_handler --on-event fish_command_not_found
	/data/data/com.termux/files/usr/libexec/termux/command-not-found $argv[1]
end
