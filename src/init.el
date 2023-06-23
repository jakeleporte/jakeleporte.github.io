;;; init.el --- Initialization file for GNU Emacs
;;; Jake Leporte <someone@example.com>


;;;
;;; Functions
;;;

(defun efs/run-in-background (command)
  (let ((command-parts (split-string command "[ ]+")))
    (apply #'call-process `(,(car command-parts) nil 0 nil ,@ (cdr command-parts)))))

(defun efs/set-wallpaper ()
  (interactive)
  (start-process-shell-command
   "feh" nil "feh --bg-scale /usr/share/backgrounds/Way_by_Kacper_Ślusarczyk.jpg"))

;; This function should be used only after configuring autorandr!
(defun efs/update-displays ()
  (efs/run-in-background "autorandr --change --force")
  (efs/set-wallpaper)
  (message "Display config: %s"
           (string-trim (shell-command-to-string "autorandr --current"))))

(defun efs/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun efs/exwm-update-title ()
  (pcase exwm-class-name
    ("firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))))

(defun efs/configure-window-by-class ()
  (interactive)
  (pcase exwm-class-name
    ("firefox" (exwm-workspace-move-window 2))
    ("Slack" (exwm-workspace-move-window 4))
    ("Sol" (exwm-workspace-move-window 3))
    ("mpv" (exwm-floating-toggle-floating)
     (exwm-layout-toggle-mode-line))))

(defun jpl/my-exwm-workspace-switch (w-num)
  (interactive)
  (if (and (> w-num 0) (< w-num exwm-workspace-number))
      (exwm-workspace-switch w-num)))

(defun efs/polybar-exwm-workspace ()
  (pcase exwm-workspace-current-index
    (1 "❶ ② ③ ④")
    (2 "① ❷ ③ ④")
    (3 "① ② ❸ ④")
    (4 "① ② ③ ❹")))

(defun efs/exwm-init-hook ()
  ;; Make workspace 1 be the one where we land at startup
  (exwm-workspace-switch-create 1)

  ;; Launch apps that will run in the background
  ;; Launch apps that will run in the background
  (efs/run-in-background "nm-applet")
  (efs/run-in-background "blueman-applet")
  (efs/start-panel))

(defun efs/send-polybar-hook (module-name hook-index)
  (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

(defun efs/send-polybar-exwm-workspace ()
  (efs/send-polybar-hook "exwm-workspace" 1))

(defun exwm-config--fix/ido-buffer-window-other-frame ()
  "Fix `ido-buffer-window-other-frame'."
  (defalias 'exwm-config-ido-buffer-window-other-frame
    (symbol-function #'ido-buffer-window-other-frame))
  (defun ido-buffer-window-other-frame (buffer)
    "This is a version redefined by EXWM.

You can find the original one at `exwm-config-ido-buffer-window-other-frame'."
    (with-current-buffer (window-buffer (selected-window))
      (if (and (derived-mode-p 'exwm-mode)
               exwm--floating-frame)
          ;; Switch from a floating frame.
          (with-current-buffer buffer
            (if (and (derived-mode-p 'exwm-mode)
                     exwm--floating-frame
                     (eq exwm--frame exwm-workspace--current))
                ;; Switch to another floating frame.
                (frame-root-window exwm--floating-frame)
              ;; Do not switch if the buffer is not on the current workspace.
              (or (get-buffer-window buffer exwm-workspace--current)
                  (selected-window))))
        (with-current-buffer buffer
          (when (derived-mode-p 'exwm-mode)
            (if (eq exwm--frame exwm-workspace--current)
                (when exwm--floating-frame
                  ;; Switch to a floating frame on the current workspace.
                  (frame-selected-window exwm--floating-frame))
              ;; Do not switch to exwm-mode buffers on other workspace (which
              ;; won't work unless `exwm-layout-show-all-buffers' is set)
              (unless exwm-layout-show-all-buffers
                (selected-window)))))))))

(defun exwm-config-ido ()
  "Configure Ido to work with EXWM."
  (ido-mode 1)
  (add-hook 'exwm-init-hook #'exwm-config--fix/ido-buffer-window-other-frame))

(defvar efs/polybar-process nil
  "Holds the process of the running Polybar instance, if any")

(defun efs/kill-panel ()
  (interactive)
  (when efs/polybar-process
    (ignore-errors
      (kill-process efs/polybar-process)))
  (setq efs/polybar-process nil))

(defun efs/start-panel ()
  (interactive)
  (efs/kill-panel)
  (setq efs/polybar-process (start-process-shell-command "polybar" nil "polybar main")))


;;;
;;; Server initialization
;;;

;; (require 'server)
;; ;; Delete any existing servers
;; (server-force-delete)
;; ;; (A lock file may have been left after an unexpected poweroff event)
;; (server-start)


;;;
;;; Package management initialization
;;;

;;; Previously, this code initialized emacs's native package managemen
;;; system, and set up some repository information.  Nowadays, I plan
;;; to manage as much of my software as possible, and certainly all my
;;; Emacs packages, with Guix.  If a package isn't already in Guix,
;;; it's trivial to add to my local Guix and to contribute back, in
;;; case any other Guix users are interested (as with emacs-ligature,
;;; which isn't even on MELPA).

;; Initialize package sources
;; Configure MELPA
;; (require 'package)
;; (setq package-archives '(("melpa" . "https://melpa.org/packages/")
;;                          ("org" . "https://orgmode.org/elpa/")
;;                          ("elpa" . "https://elpa.gnu.org/packages/")))

(require 'use-package)

;; prettify `lambda'
(defun my-pretty-lambda ()
  "Make `lambda' show as a pretty unicode lambda"
  (setq prettify-symbols-alist
	'(("lambda" . 955))))
(add-hook 'scheme-mode-hook 'my-pretty-lambda)
(global-prettify-symbols-mode t)

;; Don't make backup files
(setq make-backup-files nil)
;; If instead you want backup files saved to their own directory,
;; comment the previous line and uncomment the next one
					;(setq backup-directory-alist '(("" . "~/.config/emacs/backup")))

(use-package eldoc
  :init
  (eldoc-add-command
   'paredit-backward-delete
   'paredit-close-round))

(use-package projectile
  :init
  (projectile-mode +1)
  :bind
  (:map projectile-mode-map
	("C-c p" . projectile-command-map)))

(use-package tramp
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq tramp-default-method "ssh"))

(use-package which-key
  :init
  (which-key-mode 1))

(use-package vterm
  :config
  (setq vterm-kill-buffer-on-exit t))

(use-package vterm-toggle
  :bind
  ("C-c t" . vterm-toggle))

(use-package multi-vterm
  :bind
  ("C-c v" . multi-vterm))


;;;
;;; Base UI Setup
;;;

;; Make some more room
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(fringe-mode -1)

;; Disable the startup screen
(setq inhibit-startup-screen t)

;; Only use y-or-n-p, not yes-or-no-p
(defalias 'yes-or-no-p 'y-or-n-p)

;; Set human-readable file sizes in dired
(setq dired-listing-switches "-alh")

;; Enable disabled commands
(setq disabled-command-function nil)

;; Set default font globally
(add-to-list 'default-frame-alist '(font . "Cascadia Code PL-12"))
(set-face-attribute 'default t :font "Cascadia Code PL-12")
;; And enable ligatures
(use-package ligature
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures '(prog-mode markdown-mode help-mode vterm-mode)
			  '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                            ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                            "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                            "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                            "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                            "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                            "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                            "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                            ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                            "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                            "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                            "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                            "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package pdf-tools
  :config
  ;; Enable pdf-tools
  (pdf-tools-install))


;;;
;;; Programming and mode behavior setup
;;;

(use-package files
  :config
  ;; Delete trailing whitespace on save
  (add-hook 'after-save-hook 'delete-trailing-whitespace))

;; Add user keybindings for compilation
(use-package compile
  :bind (:map prog-mode-map
	      ("C-c c" . compile)
	      ("C-c r" . recompile)))

(use-package company
  :config
  (global-company-mode))

(use-package rust-mode)

(use-package geiser-guile)

(use-package elpy
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable))

(use-package rg
  :config
  (rg-enable-default-bindings))

(use-package rg-isearch
  :config
  (define-key isearch-mode-map (kbd "M-s r") 'rg-isearch-menu))


;;;
;;; EXWM condiguration
;;;

;; (use-package exwm
;;   :config
;;   ;; Set the default number of workspaces
;;   (setq exwm-workspace-number 5)


;;   ;; Automatically move EXWM buffer to current workspace when selected
;;   (setq exwm-layout-show-all-buffers t)

;;   ;; Display all EXWM buffers in every workspace buffer list
;;   (setq exwm-workspace-show-all-buffers t)

;;   ;; When window "class" updates, use it to set the buffer name
;;   (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

;;   ;; When window title updates, use it to set the buffer name
;;   (add-hook 'exwm-update-title-hook #'efs/exwm-update-title)

;;   ;; When EXWM starts up, do some extra configuration
;;   (add-hook 'exwm-init-hook #'efs/exwm-init-hook)

;;   ;; Update panel indicator when workspace changes
;;   (add-hook 'exwm-workspace-switch-hook #'efs/send-polybar-exwm-workspace)

;;   ;; Configure windows as they're created
;;   ;; (add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)

;;   ;; NOTE: Uncomment the following two options if you want window buffers
;;   ;;       to be available on all workspaces!

;;   ;; Automatically move EXWM buffer to current workspace when selected
;;   ;; (setq exwm-layout-show-all-buffers t)

;;   ;; Display all EXWM buffers in every workspace buffer list
;;   ;; (setq exwm-workspace-show-all-buffers t)

;;   ;; NOTE: Uncomment this option if you want to detach the minibuffer!
;;   ;; Detach the minibuffer (show it with exwm-workspace-toggle-minibuffer)
;;   ;;(setq exwm-workspace-minibuffer-position 'top)

;;   (setq exwm-input-global-keys
;;         `(
;;           ;; 's-r': Reset (to line-mode).
;;           ([?\s-r] . exwm-reset)
;;           ;; 's-w': Switch workspace.
;;           ([?\s-w] . exwm-workspace-switch)
;;           ;; 's-&': Launch application.
;;           ([?\s-&] . (lambda (command)
;;                        (interactive (list (read-shell-command "$ ")))
;;                        (start-process-shell-command command nil command)))
;;           ;; 's-N': Switch to certain workspace.
;;           ,@(mapcar (lambda (i)
;;                       `(,(kbd (format "s-%d" i)) .
;;                         (lambda ()
;;                           (interactive)
;;                           (exwm-workspace-switch-create ,i))))
;;                     (number-sequence 0 9))))
;;   (setq exwm-input-simulation-keys
;;         '(([?\C-b] . [left])
;;           ([?\C-f] . [right])
;;           ([?\C-p] . [up])
;;           ([?\C-n] . [down])
;;           ([?\C-a] . [home])
;;           ([?\C-e] . [end])
;;           ([?\M-v] . [prior])
;;           ([?\C-v] . [next])
;;           ([?\C-d] . [delete])
;;           ([?\C-k] . [S-end delete])))

;;   ;; Emacs transparency settings
;;   (set-frame-parameter (selected-frame) 'alpha '(90 . 90))
;;   (add-to-list 'default-frame-alist '(alpha . (90 . 90)))
;;   (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;;   (add-to-list 'default-frame-alist '(fullscreen . maximized))

;;   ;; (require 'exwm-randr)
;;   ;; (setq exwm-randr-workspace-output-plist '(1 "eDP-1"))
;;   ;; (add-hook 'exwm-randr-screen-change-hook
;;   ;;           (lambda ()
;;   ;;             (start-process-shell-command
;;   ;;              "xrandr" nil "xrandr --output DP-1 --right-of eDP-1 --auto")))
;;   ;; (exwm-randr-enable)

;;   ;; Enable EXWM
;;   (exwm-enable)

;;   ;; Configure Ido
;;   (exwm-config-ido)

;;   ;; Other configurations
;;   (exwm-config-misc))

;; ;; Ctrl+Q will enable the next key to be sent directly
;; (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;; (use-package exwm-systemtray
;;   :config (exwm-systemtray-enable))

(use-package desktop-environment
  :after exwm
  :config (desktop-environment-mode)
  :custom
  (desktop-environment-volume-toggle-command
   "amixer -D pulse set Master toggle > /dev/null && echo -n 'Toggle mute'")
  (desktop-environment-screenlock-command "i3lock -i ~/flag-plain.png")
  (desktop-environment-brightness-small-increment "2%+")
  (desktop-environment-brightness-small-decrement "2%-")
  (desktop-environment-brightness-normal-increment "5%+")
  (desktop-environment-brightness-normal-decrement "5%-"))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-modeline
  :config
  (display-battery-mode -1)
  :init
  (doom-modeline-mode 1))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-acario-dark t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; org-mode configuration
(use-package org
  :init
  (setq org-hide-emphasis-markers t)
  (setq org-pretty-entities t)
  (font-lock-add-keywords 'org-mode
			  '(("^ +\\([-*]\\) "
			     (0 (prog1 ()
				  (compose-region
				   (match-beginning 1)
				   (match-end 1) "•")))))))

;; org-bullets
(use-package org-bullets
  :init (add-hook 'org-mode-hook 'org-bullets-mode))

;; Line numbers in text and programming modes
(use-package display-line-numbers
  :config
  (dolist (mode-hook '(prog-mode-hook text-mode-hook))
    (add-hook mode-hook #'display-line-numbers-mode)))

(use-package simple
  :config
  (column-number-mode))

(use-package time
  :config
  (setq display-time-24hr-format t
	display-time-default-load-average nil
	display-time-format "%F %H:%M"
	display-time-day-and-date t)
  (display-time-mode))

(exwm-config-ido)

(use-package paredit
  :config
  (dolist (mode-hook '(emacs-lisp-mode-hook
		       ;; eval-expression-minibuffer-setup-hook
		       ielm-mode-hook
		       lisp-mode-hook
		       lisp-interaction-mode-hook
		       scheme-mode-hook))
    (add-hook mode-hook #'enable-paredit-mode)))

(use-package ox-latex
  :config
  (setq org-latex-listings 'minted
	org-latex-packages-alist '(("" "minted"))
	org-latex-pdf-process
	'("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
  (setq org-latex-minted-options
	'(("linenos" ""))))

(efs/set-wallpaper)


;;;
;;; Guile and Guix configuration
;;;

(use-package geiser-guile
  :config
  ;; Assuming the Guix checkout is in ~/dev/guix.
  (setq guix-checkout "~/dev/guix")
  (add-to-list 'geiser-guile-load-path guix-checkout))

;; Yasnippet configuration
(use-package yasnippet
  :config
  (setq guix-yas-snippet-dir
	(concat guix-checkout "/etc/snippets/yas"))
  (add-to-list 'yas-snippet-dirs guix-yas-snippet-dir)
  (yas-global-mode 1))

;; For automatic copyright insertion and update features
(setq user-fill-name "Jake Leporte")
(setq user-mail-address "someone@example.com")
(setq copyright-names-regexp
      (format "%s <%s>" user-full-name user-mail-address))
(load-file (concat guix-checkout "/etc/copyright.el"))


;;;
;;; Custom block- autogenerated
;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval progn
	   (require 'lisp-mode)
	   (defun emacs27-lisp-fill-paragraph
	       (&optional justify)
	     (interactive "P")
	     (or
	      (fill-comment-paragraph justify)
	      (let
		  ((paragraph-start
		    (concat paragraph-start "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
		   (paragraph-separate
		    (concat paragraph-separate "\\|\\s-*\".*[,\\.]$"))
		   (fill-column
		    (if
			(and
			 (integerp emacs-lisp-docstring-fill-column)
			 (derived-mode-p 'emacs-lisp-mode))
			emacs-lisp-docstring-fill-column fill-column)))
		(fill-paragraph justify))
	      t))
	   (setq-local fill-paragraph-function #'emacs27-lisp-fill-paragraph))
     (eval modify-syntax-entry 43 "'")
     (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (eval let
	   ((root-dir-unexpanded
	     (locate-dominating-file default-directory ".dir-locals.el")))
	   (when root-dir-unexpanded
	     (let*
		 ((root-dir
		   (expand-file-name root-dir-unexpanded))
		  (root-dir*
		   (directory-file-name root-dir)))
	       (unless
		   (boundp 'geiser-guile-load-path)
		 (defvar geiser-guile-load-path 'nil))
	       (make-local-variable 'geiser-guile-load-path)
	       (require 'cl-lib)
	       (cl-pushnew root-dir* geiser-guile-load-path :test #'string-equal))))
     (eval with-eval-after-load 'yasnippet
	   (let
	       ((guix-yasnippets
		 (expand-file-name "etc/snippets/yas"
				   (locate-dominating-file default-directory ".dir-locals.el"))))
	     (unless
		 (member guix-yasnippets yas-snippet-dirs)
	       (add-to-list 'yas-snippet-dirs guix-yasnippets)
	       (yas-reload-all))))
     (eval setq-local guix-directory
	   (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go"))))
