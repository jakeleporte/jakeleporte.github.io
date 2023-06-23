;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
	     (guix build utils)
	     (gnu home services)
             (gnu home services shells)
	     (gnu home services ssh)
	     (ice-9 string-fun)
	     (ice-9 match)
	     (srfi srfi-1))

(define hfile-root
  (dirname (current-filename)))
(define (hfile filename)
  (string-append hfile-root "/" filename))

(define cfile-root
  (string-append hfile-root "/config"))
(define (cfile filename)
  (string-append cfile-root "/" filename))
(define (uncfile filename)
  (string-replace-substring filename
			    (string-append cfile-root "/")
			    ""))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages
  (specifications->packages
   (list
    "bind:utils"
    "emacs"
    "emacs-all-the-icons"
    "emacs-company"
    "emacs-doom-modeline"
    "emacs-doom-themes"
    "emacs-elpy"
    "emacs-fish-mode"
    "emacs-geiser-guile"
    "emacs-guix"
    "emacs-ligature"
    "emacs-magit"
    "emacs-multi-vterm"
    "emacs-org-bullets"
    "emacs-paredit"
    "emacs-pdf-tools"
    "emacs-projectile"
    "emacs-rg"
    "emacs-rust-mode"
    "emacs-use-package"
    "emacs-vterm"
    "emacs-vterm-toggle"
    "emacs-which-key"
    "emacs-yasnippet"
    "fcitx5"
    "fcitx5-chinese-addons"
    "fcitx5-configtool"
    "file"
    "firefox"
    "font-adobe-source-han-sans:cn"
    "font-google-noto"
    "font-microsoft-cascadia"
    "git"
    "git:send-email"
    "gnome-shell-extension-appindicator"
    "gnome-tweaks"
    "gnu-standards"
    "guile"
    "jami"
    "jami-docs"
    "ncurses"
    "opensc"
    "openssh"
    "python"
    "recutils"
    "ripgrep"
    "qemu"
    "quassel"
    "telegram-desktop"
    "virt-manager"
    "xdg-utils")))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list (simple-service 'environment-variables
			home-environment-variables-service-type
			`(("GTK_IM_MODULE" . "fcitx")
			  ("QT_IM_MODULE" . "fcitx")
			  ("XMODIFIERS" . "@im=fcitx")
			  ;; ("GUIX_GTK2_IM_MODULE_FILE" . "$HOME/.guix-profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache")
			  ;; ("GUIX_GTK3_IM_MODULE_FILE" . "$HOME/.guix-profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")
			  ))
	(service home-fish-service-type
		 (home-fish-configuration
		  (config
		   (list
		    (local-file "fish/config.fish")))))
	(service home-xdg-configuration-files-service-type
		 (map (lambda (config-file)
			`(,(uncfile config-file) ,(local-file config-file)))
		      (find-files (string-append cfile-root "/"))))
	(service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("e" . "emacsclient")
                             ("grep" . "grep --color=auto")
                             ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")))
                  (bashrc (list (local-file "bash/bashrc"))))))))
