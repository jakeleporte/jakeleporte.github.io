(define-module (utils)
  #:use-module (haunt artifact)
  #:use-module (haunt html)
  #:use-module (haunt builder blog)
  #:use-module (theme)
  #:export (static-page
	    anchor
	    link
	    stylesheet))

(define (stylesheet name)
  `(link (@ (rel "stylesheet")
            (href ,(string-append "/css/" name ".css")))))

(define (static-page title file-name body)
  (lambda (site posts)
    (serialized-artifact file-name
			 (with-layout picklehead-theme site title body)
                         sxml->html)))

(define (link name uri)
  `(a (@ (href ,uri)) ,name))

(define* (anchor content #:optional (uri content))
  `(a (@ (href ,uri)) ,content))
