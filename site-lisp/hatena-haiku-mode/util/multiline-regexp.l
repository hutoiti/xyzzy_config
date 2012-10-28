;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/multiline-regexp.l
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
  (require "hatena-haiku-mode/util/macros")
  )

(in-package :hatena-haiku.util)

(export '(multiline-match-string
          with-multiline-regexp-buffer-if
          with-multiline-regexp-buffer
          with-multiline-regexp-string
          ))

(defun multiline-match-string (regnum)
  (let ((s (ed::match-string regnum)))
    (when s
      (save-match-data
        (alt-newline->newline-string s)))))

(defmacro with-multiline-regexp-buffer-if ((multiline-mode buffer &key (restore t)) &body body)
  `(if ,multiline-mode
       (with-multiline-regexp-buffer ((selected-buffer) t)
         ,@body)
     (progn
       ,@body)))
(setf (get 'with-multiline-regexp-buffer-if 'ed:lisp-indent-hook) 'with-open-file)

(defmacro with-multiline-regexp-buffer ((buffer restore) &body body)
  (with-gensyms (gbuffer)
    `(flet ((match-string (regnum)
              (multiline-match-string regnum)))
       (let ((,gbuffer ,buffer))
         (unwind-protect
             (progn
               (newline->alt-newline-buffer ,gbuffer)
               ,@body)
           (when ,restore
             (alt-newline->newline-buffer ,gbuffer)))))))
(setf (get 'with-multiline-regexp-buffer 'ed:lisp-indent-hook) 'with-open-file)

(defmacro with-multiline-regexp-string ((str) &body body)
  `(flet ((match-string (regnum)
            (multiline-match-string regnum)))
     (let ((,str (newline->alt-newline-string ,str)))
       (alt-newline->newline-string (progn ,@body)))))
(setf (get 'with-multiline-regexp-string 'ed:lisp-indent-hook) 'with-open-file)


(provide "hatena-haiku-mode/util/multiline-regexp")

;;;; End
