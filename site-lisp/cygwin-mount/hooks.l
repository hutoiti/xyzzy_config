;;;; -*- mode: lisp; package: editor -*-
;;;;
;;;; File: cygwin-mount/hooks.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2005,2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   cygwin-mount is released under an MIT license.
;;;;   See cygwin-mount/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "cygwin-mount/package")
  (require "cygwin-mount/resolver")
  )

(in-package :editor)

(export '(cygwin-mount-before-find-file-hook
          cygwin-mount-deactivate
          cygwin-mount-activate
          cygwin-mount-active-p
          cygwin-mount-toggle
          ))

;; 引数で指定して起動すると勝手にドライブ文字がつけられるので
;; まずドライブ文字を消して試してみる。
(defun cygwin-mount-before-find-file-hook (filename)
  (when (and filename (not (file-exist-p filename)))
    (dolist (f (list (substitute-string filename "^[a-zA-Z]:" "")
                     filename))
      (let ((winpath (cygmount:cygmount-cygpath->winpath f)))
        (when (and winpath (file-exist-p winpath))
          (return (ed::find-file-internal winpath)))))))

(defun cygwin-mount-activate ()
  (interactive)
  (add-hook '*before-find-file-hook* 'cygwin-mount-before-find-file-hook)
  (message "Activate cygwin-mount"))

(defun cygwin-mount-deactivate ()
  (interactive)
  (delete-hook '*before-find-file-hook* 'cygwin-mount-before-find-file-hook)
  (message "Deactivate cygwin-mount"))

(defun cygwin-mount-active-p ()
  (not (null (find  'cygwin-mount-before-find-file-hook *before-find-file-hook*))))

(defun cygwin-mount-toggle ()
  (interactive)
  (if (cygwin-mount-active-p)
      (cygwin-mount-deactivate)
    (cygwin-mount-activate)))


(provide "cygwin-mount/hooks")

;;; End
