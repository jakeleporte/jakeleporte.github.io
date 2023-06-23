;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu)
	     (gnu packages xorg)
	     (guix transformations)
	     ;; Import nonfree linux module
	     (nongnu packages linux)
	     (nongnu packages nvidia)
	     (nongnu system linux-initrd)
	     (nongnu services nvidia))
(use-service-modules admin
		     cups
		     desktop
		     networking
		     ssh
		     xorg
		     security-token
		     authentication
		     virtualization)

(define nvda-transform
  (options->transformation
   '((with-graft . "mesa=nvda"))))

(operating-system
 (kernel linux)
 (initrd microcode-initrd)
 ;; For nonfree wifi firmware
 (firmware (cons* iwlwifi-firmware
		  %base-firmware))
 (locale "en_US.utf8")
 (timezone "America/Chicago")
 (keyboard-layout (keyboard-layout
		   "us"
		   #:options '("ctrl:nocaps" "shift:both_capslock")))
 (host-name "kosher")

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "jakel")
                (comment "Jake Leporte")
                (group "users")
		(shell (file-append
			(specification->package "fish")
			"/bin/fish"))
                (home-directory "/home/jakel")
                (supplementary-groups '("wheel"
					"netdev"
					"audio"
					"video"
					;; For running VMs
					"libvirt" "kvm"
					"dialout")))
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append
	    (specifications->packages
	     (list "emacs"
		   "emacs-exwm"
		   "emacs-desktop-environment"
		   "nss-certs"
		   ))
            %base-packages))

 ;; (kernel-arguments (append
 ;; 		    '("modprobe.blacklist=nouveau"
 ;; 		      "nvidia_drm.modeset=1")
 ;; 		    %default-kernel-arguments))

 ;; (kernel-loadable-modules (list nvidia-module))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append (list (service gnome-desktop-service-type)
		;; For smartcard use
		(service pcscd-service-type)
		(service unattended-upgrade-service-type)
		;; For gnome-boxes
		(service libvirt-service-type
			 (libvirt-configuration
			  (unix-sock-group "libvirt")))
		(service virtlog-service-type))

          ;; This is the default list of services we
          ;; are appending to.
	  (modify-services
	   %desktop-services
	   (guix-service-type
	    config => (guix-configuration
		       (inherit config)
		       (substitute-urls
			(append (list "https://substitutes.nonguix.org")
				%default-substitute-urls))
		       (authorized-keys
			(append (list (plain-file "non-guix.pub"
						  "(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
  )
 )"))
				%default-authorized-guix-keys))))
	   (gdm-service-type
	    config => (gdm-configuration
		       (inherit config)
		       (wayland? #t))))))
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))
 (swap-devices (list (swap-space
                      (target (uuid
                               "d8a65187-1427-4995-8856-0b86464dd000")))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "01AD-2B4F"
                                     'fat32))
                       (type "vfat"))
                      (file-system
                       (mount-point "/")
                       (device (uuid
                                "1d028501-f503-44eb-b34c-1077b1f9d2b4"
                                'ext4))
                       (type "ext4"))
                      (file-system
                       (mount-point "/home")
                       (device (uuid
                                "c96451d0-8f4e-47ee-8b67-9df4b2e401a8"
                                'ext4))
                       (type "ext4")) %base-file-systems)))
