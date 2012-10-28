;;; -*- Mode: Lisp -*-
;;  action:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       action is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:
(in-package :odoc-mode)

(defvar *toggle-switch-list* nil)

(defvar *toggle-switch-hash* (make-hash-table :test 'equal))

(defvar *toggle-switch-string* nil )

(defvar *action-menber* nil
  "
1. search regex
2. function
3. delete point
4. goto point
")

(setq *action-default-member*
  '(
	("\\[index\\]" index nil nil)
	("[^\\]\\[\\([^\\\[]+?\\)\\]" create nil nil)
	))

;;(setq *toggle-switch-list* '(("{*}""{-}""{ }")))

(defun create()
  (let*((str
		 (save-excursion
		   (buffer-substring
			(progn(skip-syntax-spec-backward "^_(")(point))
			(progn(skip-syntax-spec-forward "^_)")(point)))))
		(dir (default-directory))
		(odoc (concat str "." *odoc-extension*)))
	(or(numberp(string-match "\\(http://\\||\\)" str))
	   (cond((file-exist-p(merge-pathnames str dir))
			 (find-file (merge-pathnames str dir)))
			((find odoc (directory dir) :test 'equal)
			 (find-file (merge-pathnames odoc dir)))
			(t (new-odoc str odoc dir))))))

;; toggle switch
(defun toggle-switch-color-push(keyword)
  (pushnew (apply #'compile-regexp-keyword
				  `(,keyword t ,*odoc-toggle-switch-color*))
		   *odoc-mode-formats* :test 'equal))

(defun add-toggle-switch(list)
  (mapc #'(lambda(x)
			(pushnew x *toggle-switch-list* :test 'equal))
		list))

(add-toggle-switch '(("{*}""{-}""{ }")))

(defun setup-toggle-switch()
  (dolist(g *toggle-switch-list*)
	(let((reg (add-regex g)))
	  (pushnew (list reg 'toggle-switch 1 nil)
			   *action-menber* :test 'equal)
	  (toggle-switch-color-push reg)
	  (do((x g (cdr x)))
		  ((atom x) *toggle-switch-hash*)
		(setf(gethash(car x) *toggle-switch-hash*)
			 (if (cadr x)(cadr x) (car g)))))))

(defun toggle-switch()
  (insert(gethash *toggle-switch-string* *toggle-switch-hash*))
  (backward-char))

(defun add-regex(list)
  (let((r)(last (car(last list))))
	(dolist (x list(apply #'concat (append (cons "\\("(nreverse r)) '("\\)"))))
	  (if (equal x last)
		  (push(regexp-quote x) r)
		(push (concat(regexp-quote x) "\\|") r)
		))))

; action main

(defvar *match-stock* nil)

(defun match-regex()
  (save-excursion
	(let((now(point))
		 (bol (progn(goto-bol)(point)))
		 ret)
	  (dolist(x *search-action-member* ret)
		(goto-char now)
		(while(scan-buffer(car x):regexp t :reverse t :no-dup t :limit bol)
		  (when(< (match-beginning 0) now (match-end 0))
			(setq *match-stock* (match-data))
			(return (setq ret (cdr x)))
			(or (backward-char 1))))))))

(defun action-color-push(keyword)
  (pushnew (apply #'compile-regexp-keyword
				  `(,keyword t ,*odoc-action-color*))
		   *odoc-mode-formats* :test 'equal))

(defun add-action(regex function &optional delete goto)
  (action-color-push regex)
  (pushnew (list regex
				 function
				 delete
				 goto)
		   *action-menber*
		   :test  'equal))


(defun add-action-list(list)
  (mapc #'(lambda(x)(apply #'add-action x)) list)
  (values *action-menber*
		  (action-setup)))

(defvar *action-hash* (make-hash-table :test 'equal))
(defvar *search-action-member* nil)

(defun action-setup()
  (setf *search-action-member*
		(mapcar #'(lambda(x)
					(setf(gethash (car x) *action-hash*)(cdr x))
					(cons (compile-regexp (car x))(car x)))
				*action-menber*)))

(defun action()
  (interactive)
  (if(eolp)(insert #\LFD)
	(let((op (gethash (match-regex) *action-hash*)))
	  (if op
		  (progn
			(store-match-data *match-stock*)
			(and (nth 1 op)
				 (setq *toggle-switch-string*
					   (buffer-substring (match-beginning (nth 1 op))(match-end (nth 1 op))))
				 (delete-region(match-beginning (nth 1 op))(match-end (nth 1 op))))
			(and(car op)
				(funcall (car op)))
			(store-match-data *match-stock*)
			(and (nth 2 op)
				 (goto-char(match-beginning(nth 2 op)))))
		(insert #\LFD)))))

(provide :odoc/mode/action)
;;end
