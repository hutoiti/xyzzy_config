;;;; -*- mode: lisp; package: cygwin-mount -*-
;;;;
;;;; File: cygwin-mount/resolver.l
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
  (require "cygwin-mount/mount-point")
  )

(in-package :cygwin-mount)

(export '(cygmount-cygpath->winpath
          cygmount-winpath->cygpath
          ))

(defun cygmount-cygpath->winpath (cygpath)
  (let ((winpath (cygmount-cygpath->winpath-internal cygpath)))
    (map-slash-to-backslash
     (or winpath cygpath ""))))

(defun cygmount-cygpath->winpath-internal (cygpath)
  (if (or (null cygpath) (string= "" cygpath))
      cygpath
    (multiple-value-bind (drive path)
        (parse-cygdrive cygpath)
      (if drive
          (merge-pathnames (or path "/") (concat drive ":"))
        (let ((mount (search-by-cygpath path)))
          (when mount
            (path-replace-prefix cygpath
                                 (cygmount-point-cygpath mount)
                                 (cygmount-point-winpath mount))))))))

(defun cygmount-winpath->cygpath (winpath)
  (let ((cygpath (cygmount-winpath->cygpath-internal winpath)))
    (map-backslash-to-slash
     (or cygpath winpath ""))))

(defun cygmount-winpath->cygpath-internal (winpath)
  (if (or (null winpath) (string= "" winpath))
      winpath
    (let ((mount (search-by-winpath winpath)))
      (if mount
          (path-replace-prefix winpath
                               (cygmount-point-winpath mount)
                               (cygmount-point-cygpath mount))
        (path-replace-prefix (substitute-string winpath ":" "")
                             ""
                             (cygdrive-prefix))))))


(defun parse-cygdrive (cygpath)
  (if (string-looking-at (concat (cygdrive-prefix) "/\\([a-zA-Z]\\)\\(/.*\\)?$")
                         cygpath)
      (values (match-string 1) (match-string 2))
    (values nil cygpath)))


(defun path-replace-prefix (path from to)
  (path-join to (substring path (length from))))

(defun path-join (&rest path-list)
  (remove-trail-slash
   (reduce #'(lambda (acc e)
               (concat (append-trail-slash acc)
                       (substitute-string (map-backslash-to-slash e) "^/" "")))
           (cdr path-list)
           :initial-value (car path-list))))


(provide "cygwin-mount/resolver")

;;; End
