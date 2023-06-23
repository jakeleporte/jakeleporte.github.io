(use-modules (haunt asset)
	     (haunt builder blog)
	     (haunt post)
	     (haunt builder assets)
	     (haunt reader commonmark)
	     (haunt reader skribe)
	     (haunt site)
	     (theme)
	     (utils))

(define %collections
  `(("Blog Posts" "index.html" ,posts/reverse-chronological)))

(define configs-page
  (static-page
   "Configurations"
   "configs.html"
   `((h2 "Guix System Configurations")
     (p "I run " ,(anchor "GNU Guix System" "https://guix.gnu.org")
	" on both a laptop and a desktop computer.  I'm not the most
proficient Guix user, and there's plenty of other Guix configurations
online to reference!  On my laptop, I also run "
	,(anchor
	  "Guix Home"
	  "https://guix.gnu.org/manual/devel/en/html_node/Home-Configuration.html")
	", so that
configuration is incluced here as well.")
     (ul (li ,(anchor "Guix System Configuration - Laptop" "src/kosher.scm"))
	 (li ,(anchor "Guix Home Configuration" "src/kosher-home.scm")))
     (h2 "Emacs Configuration")
     (p "I use " ,(anchor "GNU Emacs" "https://www.gnu.org/software/emacs/")
	" as my text editor- and really, as my computing environment in
general :).  In the past, I've used "
	,(anchor "EXWM" "https://github.com/ch11ng/exwm")
	" as my window manager, and I plan to use it again in the future, but
for the moment, it's easier for me to just use GNOME, so those
portions of the configuration are commented out.  I manage my Emacs
packages with Guix- you can see the Emacs packages I use in my "
	,(anchor "Guix Home configuration" "src/kosher-home.scm") ".")
     (ul (li ,(anchor "Emacs Configuration" "src/init.el"))))))

(site #:title "Picklehead Web"
      #:domain "jakeleporte.github.io"
      #:default-metadata
      '((author . "Jake Leporte")
	(email . "jakeleporte@yahoo.com"))
      #:readers (list commonmark-reader skribe-reader)
      #:builders (list (blog #:theme picklehead-theme
			     #:collections %collections)
		       configs-page
		       (static-directory "favicon" "/")
		       (static-directory "src")
		       (static-directory "css")
		       (static-directory "images")))
