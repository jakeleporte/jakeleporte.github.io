(define-module (theme)
  #:use-module (haunt builder blog)
  #:use-module (haunt site)
  #:use-module (utils)
  #:export (picklehead-theme))

(define picklehead-theme
  (theme #:name "picklehead"
	 #:layout
	 (lambda (site title body)
	   `((doctype "html")
	     (head
	      (meta (@ (charset "utf-8")))
	      (title ,(string-append title " — " (site-title site)))
	      ,(stylesheet "picklehead"))
	     (body
	      (nav (ul (li ,(link "Blog" "/index.html"))
		       (li ,(link "Configurations" "/configs.html"))))
	      ,body)))))
