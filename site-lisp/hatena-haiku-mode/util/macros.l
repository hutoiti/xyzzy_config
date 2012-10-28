;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/macros.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util/package")
  )

(in-package :hatena-haiku.util)

(export '(D
          D0
          and-let
          and-let*
          invoke-later
          with-gensyms
          with-keymap
          with-temporary-buffer
          with-temporary-set-buffer
          with-temporary-writable
          with-append-to-buffer
          with-stdout-point-start-end
          with-point-zero
          define-prefix-argument-command
          save-current-window-line
          save-current-point
          save-current-line-column
          save-match-data
          map-scan-buffer
          ))

(defun D(&rest args)
  #+hatena-haiku-mode-debug
  (apply 'D0 args))

(defun D0(&rest args)
  (msgbox "line=~D, col=~D, point=~D~%~S"
          (current-line-number) (current-column) (point) args)
  (car (last args)))


(defmacro and-let ((&rest vars) &body body)
  (let ((tag (gensym)))
    `(block ,tag
     (let (,@(mapcar #'(lambda (var)
                         `(,(car var) (or (progn ,@(cdr var))
                                          (return-from ,tag))))
                     vars))
       ,@body))))
(setf (get 'and-let 'ed::lisp-indent-hook) 'let)

(defmacro and-let* ((&rest vars) &body body)
  `(let (,@(mapcar #'car vars))
     (when (and ,@(mapcar #'(lambda (var)
                              `(setf ,@var))
                          vars))
       (progn ,@body))))
(setf (get 'and-let* 'ed::lisp-indent-hook) 'let)


(defmacro invoke-later (dt &body body)
  `(start-timer ,dt #'(lambda () ,@body) t))
(setf (get 'invoke-later 'ed:lisp-indent-hook) 1)

(defmacro with-gensyms (syms &body body)
  `(let ,(mapcar #'(lambda (sym)
                     `(,sym (gensym)))
                 syms)
     ,@body))
(setf (get 'with-gensyms 'ed:lisp-indent-hook) 'let)

(defmacro with-keymap (keymap &body body)
  (with-gensyms (gkeymap)
    `(let ((,gkeymap ,keymap))
       ,@(mapcar #'(lambda (form)
                     (if (cadr form)
                         `(define-key ,gkeymap ,@form)
                       `(undefine-key ,gkeymap ,(car form))))
                 body)
       ,gkeymap)))
(setf (get 'with-keymap 'ed:lisp-indent-hook) 'let)

(defmacro with-temporary-buffer ((contents filter) &body body)
  (with-gensyms (tmp)
    `(save-window-excursion
       (save-excursion
         (let ((,tmp (get-buffer-create " *hatena-haiku-mode:tmp*")))
           (unwind-protect
               (with-set-buffer
                 (set-buffer ,tmp)
                 (erase-buffer ,tmp)
                 (insert ,contents)
                 (goto-char (point-min))
                 (save-excursion (funcall ,filter))
                 ,@body)
             (when (and ,tmp (bufferp ,tmp) (not (deleted-buffer-p ,tmp)))
               (delete-buffer ,tmp))))))))
(setf (get 'with-temporary-buffer 'ed:lisp-indent-hook) 'with-set-buffer)

(defmacro with-temporary-set-buffer ((buffer) &body body)
  (with-gensyms (original)
    `(let ((,original (selected-buffer)))
       (with-set-buffer
         (unwind-protect
             (progn
               (set-buffer ,buffer)
               ,@body)
           (set-buffer ,original))))))
(setf (get 'with-temporary-set-buffer 'ed:lisp-indent-hook) 'with-selected-window)

(defmacro with-temporary-writable ((buffer) &body body)
  `(with-temporary-set-buffer (,buffer)
     (let ((read-only buffer-read-only))
       (setf buffer-read-only nil)
       (unwind-protect
           (progn ,@body)
         (setf buffer-read-only read-only)))))
(setf (get 'with-temporary-writable 'lisp-indent-hook) 'with-selected-window)

(defmacro with-append-to-buffer ((buffer) &body body)
  `(with-output-to-buffer (,buffer (with-temporary-set-buffer (,buffer)
                                     (point-max)))
     ,@body))
(setf (get 'with-append-to-buffer 'lisp-indent-hook) 'with-output-to-buffer)

(defmacro with-stdout-point-start-end ((start end) output-form &body form)
  `(let ((,start (buffer-stream-point *standard-output*)))
     (progn ,output-form)
     (let ((,end (buffer-stream-point *standard-output*)))
       ,@form)))
(setf (get 'with-stdout-point-start-end 'lisp-indent-hook) 2)

(defmacro define-prefix-argument-command (name command)
  `(defun ,name (&rest args)
     (interactive)
     (dotimes (i (if *prefix-args* *prefix-value* 1))
       (apply ',command args))))

(defmacro with-point-zero (&body body)
  `(save-excursion
     (goto-char (point-min))
     ,@body))
(setf (get 'with-point-zero 'ed:lisp-indent-hook) 'save-excursion)

(defmacro save-current-window-line (&body body)
  (with-gensyms (gpoint gscroll)
    `(let ((,gscroll (get-window-line)))
       (unwind-protect
           (progn ,@body)
         (recenter ,gscroll)))))
(setf (get 'save-current-window-line 'ed:lisp-indent-hook) 'save-excursion)

(defmacro save-current-point (&body body)
  (with-gensyms (gpoint gscroll)
    `(let ((,gpoint (point)))
       (save-current-window-line
         (unwind-protect
             (progn ,@body)
           (goto-char ,gpoint))))))
(setf (get 'save-current-point 'ed:lisp-indent-hook) 'save-excursion)

(defmacro save-current-line-column (&body body)
  (with-gensyms (gline gcol)
    `(let ((,gline (current-line-number))
           (,gcol (current-column)))
       (save-current-window-line
         (unwind-protect
             (progn ,@body)
           (goto-line ,gline)
           (goto-column ,gcol))))))
(setf (get 'save-current-line-column 'ed:lisp-indent-hook) 'save-excursion)

(defmacro save-match-data (&body body)
  (with-gensyms (md)
    `(let ((,md (match-data)))
       (unwind-protect
           (progn ,@body)
         (store-match-data ,md)))))
(setf (get 'save-match-data 'ed:lisp-indent-hook) 'save-excursion)


(defmacro map-scan-buffer ((pattern &key
                                    no-dup case-fold reverse tail regexp
                                    left-bound right-bound last-match
                                    maxscan)
                           &body body)
  (with-gensyms (result
                 gpattern
                 gno-dup gcase-fold greverse gtail gregexp
                 gleft-bound gright-bound glast-match
                 gmaxscan)
    `(let ((,result)
           (,gpattern ,pattern)
           (,gno-dup ,no-dup)
           (,gcase-fold ,case-fold)
           (,greverse ,reverse)
           (,gtail ,tail)
           (,gregexp ,regexp)
           (,gleft-bound ,left-bound)
           (,gright-bound ,right-bound)
           (,glast-match ,last-match)
           (,gmaxscan (or ,maxscan -1)))
       (while (scan-buffer ,gpattern
                           :no-dup ,gno-dup
                           :case-fold ,gcase-fold
                           :reverse ,greverse
                           :tail ,gtail
                           :regexp ,gregexp
                           :left-bound ,gleft-bound
                           :right-bound ,gright-bound
                           :last-match ,glast-match)
         (push (progn ,@body) ,result)
         (when (zerop (decf ,gmaxscan))
           (return)))
       (reverse ,result))))
(setf (get 'map-scan-buffer 'ed:lisp-indent-hook) 'save-excursion)


(provide "hatena-haiku-mode/util/macros")

;;;; End
