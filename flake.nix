{
	description = "Fuad-MBP";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		nix-darwin.url = "github:nix-darwin/nix-darwin/master";
		nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { nixpkgs, nix-darwin, ... }:
		let
			username = "fuad";

			mac-config = { pkgs, ... } : {
				nixpkgs.hostPlatform = "aarch64-darwin";
				nixpkgs.config.allowUnfree = true;

				nix.settings.experimental-features = [ "nix-command" "flakes" ];

				users.users."${username}".shell = pkgs.zsh;

				system = {
					defaults = {
						dock = rec {
							autohide = true;
							show-recents = false;
							magnification = true;
							tilesize = 24;
							largesize = tilesize * 5;

							persistent-apps = [
								"/Applications/Slack.app"
								"/Applications/Claude.app"
								"/Applications/Ghostty.app"
								"/Applications/DataGrip.app"
								"/Applications/Google Chrome.app"
								"/Applications/Visual Studio Code.app"
							];
						};

						finder = {
							ShowPathbar = true;
							FXPreferredViewStyle = "Nlsv";
							AppleShowAllExtensions = true;

							NewWindowTarget = "Other";
							NewWindowTargetPath = "file:///Users/${username}/Downloads/";
						};

						NSGlobalDomain."com.apple.trackpad.scaling" = 2.5;
						".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;
					};

					primaryUser = username;
					stateVersion = 7;
				};

				environment.shells = [ pkgs.zsh ];

				environment.variables = {
					EDITOR = "nvim";
					VISUAL = "nvim";
				};

				environment.pathsToLink = [ "/share" ];

				environment.systemPackages = with pkgs; [
					awscli direnv fzf git go
					neovim nodejs_latest python3 stow
					terraform tmux tree-sitter wget
					zoxide zsh-autosuggestions zsh-history-substring-search
					zsh-syntax-highlighting
				];

				programs.zsh.enable = true;

				security.pam.services.sudo_local.touchIdAuth = true;

				homebrew = {
					enable = true;
					onActivation = {
						cleanup = "zap";
						autoUpdate = true;
					};
					casks = [
						"1password" "aldente"
						"betterdisplay" "claude-code" "cursor" "datagrip" "displaylink" "docker-desktop"
						"finicky" "font-hasklug-nerd-font" "ghostty" "google-chrome" "insomnia"
						"maccy" "numi" "postman" "postman-agent" "postman-cli" "rocket" "session-manager-plugin"
						"shottr" "slack" "visual-studio-code" "vorssaint" "wireshark-app" "nikitabobko/tap/aerospace"
					];
					# brews = [];
				};

				launchd.user.agents = {
					aerospace.serviceConfig = {
						RunAtLoad = true;
						ProgramArguments = [ "/usr/bin/open" "-a" "Aerospace" ];
					};
				};
			};
		in
			{
				darwinConfigurations."pc" = with nix-darwin.lib; darwinSystem {
					modules = [ mac-config ];
				};
			};
}
