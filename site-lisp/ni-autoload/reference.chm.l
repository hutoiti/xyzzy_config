(defvar *reference-html-help-file* "reference.chm")

(defun reference-show-html-help ()
  (ed::html-help (merge-pathnames
		  *reference-html-help-file*
		  (etc-path))
		 (ed::get-winhelp-topic)))

(defvar *reference-show-function* 'reference-show-html-help)
(defvar *reference-show-menu-function* 'reference-show-html-help)

(defun reference-show ()
  (interactive)
  (funcall *reference-show-function*))

(defun reference-show-menu ()
  (interactive)
  (funcall *reference-show-menu-function*))

(defun reference-add-menu-function ()
  (let ((help (get-menu *app-menu* 'ed::help)))
    (insert-menu-item help 2 'reference "ƒwƒ‹ƒv(&H)..." 'reference-show-menu)))
  
(add-hook '*init-app-menus-hook*
	  'reference-add-menu-function)

(define-key ed::*lisp-mode-map* #\F1 'reference-show)
(define-key ed::*lisp-interaction-mode-map* #\F1 'reference-show)
