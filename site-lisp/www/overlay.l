;;;
;;; overlay.l
;;;
;;; 2000/06/27 by Shinji Yamamoto

(provide "www/overlay")

(in-package "www")

(defstruct
  (overlay-attr (:constructor create-overlay-attr
	      (bold underline strike-out foreground background prefix extend)))
  bold
  underline
  strike-out
  foreground
  background
  prefix
  extend)

(defstruct
  (overlay (:constructor create-overlay (on off)))
  on
  off)

(defvar *last-overlay-marker* nil)


(defun overlay-set-attr (tag &optional off)
  (let ((tattr (if off
		   (overlay-off (get (cadr tag) 'overlay))
		 (overlay-on (get (cadr tag) 'overlay)))))
    (let ((bold (overlay-attr-bold tattr))
	  (underline (overlay-attr-underline tattr))
	  (strike-out (overlay-attr-strike-out tattr))
	  (foreground (overlay-attr-foreground tattr))
	  (background (overlay-attr-background tattr))
	  (prefix (overlay-attr-prefix tattr))
	  (extend (overlay-attr-extend tattr)))
      (setq *last-overlay-marker* (cons (make-marker) tag))
      (apply #'modify-text-attributes tag
	     (append (and bold (list ':bold bold))
		     (and underline (list ':underline underline))
		     (and strike-out (list ':strike-out strike-out))
		     (and foreground (list ':foreground foreground))
		     (and background (list ':background background))
		     (and prefix (list ':prefix prefix))
		     (and extend (list ':extend extend))
		     (list ':test #'equal))))))

(defun overlay-handler ()
  (when (and *last-overlay-marker*
	     (null (minibuffer-window-p (selected-window))))
    (let ((obuf (selected-buffer)))
      (set-buffer (marker-buffer (car *last-overlay-marker*)))
      (overlay-set-attr (cdr *last-overlay-marker*) t)
      (setq *last-overlay-marker* nil)
      (set-buffer obuf)))
  (let ((point (point))
	start end tag)
    (cond ((multiple-value-bind (from to tg)
	       (find-text-attribute 'overlay :end point :from-end t :test #'eq
				    :key #'(lambda (x) (and (consp x) (car x))))
	     (if (and from (<= from point) (> to point))
		 (setq start from end to tag tg))))
	  ((multiple-value-bind (from to tg)
	       (find-text-attribute 'overlay :start point :test #'eq
				    :key #'(lambda (x) (and (consp x) (car x))))
	     (if (and from (<= from point) (>= to point))
		 (setq start from end to tag tg)))))
    (if start
	(overlay-set-attr tag))))
