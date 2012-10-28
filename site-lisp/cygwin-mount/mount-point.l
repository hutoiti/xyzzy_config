;;;; -*- mode: lisp; package: cygwin-mount -*-
;;;;
;;;; File: cygwin-mount/mount-point.l
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
  )

(in-package :cygwin-mount)

(export '(cygmount-point-cygpath
          cygmount-point-winpath
          cygmount-point-flags
          cygmount-point-type

          cygmount-point-info
          cygdrive-prefix
          ))

(defvar *system-reg-root* :local-machine)
(defvar *user-reg-root* :current-user)

(defvar *reg-section*
  "SOFTWARE\\Cygnus Solutions\\Cygwin\\mounts v2")

(defvar *mount-flags-alist*
  '((#x002 . :binmode)
    (#x010 . :exec)
    (#x040 . :cygexec)
    (#x100 . :notexec)
    (#x800 . :managed)
    ))


(defun make-mount-point (&key cygpath winpath flags type)
  (list cygpath winpath flags type))

(defun cygmount-point-cygpath (mount-info)
  (car mount-info))

(defun cygmount-point-winpath (mount-info)
  (cadr mount-info))

(defun cygmount-point-flags (mount-info)
  (mount-flags->names (caddr mount-info)))

(defun cygmount-point-type (mount-info)
  (cadddr mount-info))



(defun cygmount-point-info (&key type path)
  (let ((r (mapcan #'cygmount-point-info-internal
                   (mount-types type))))
    (if path
        (search-by-cygpath path :info r :all t)
      r)))

(defun cygmount-point-info-internal (type)
  (mapcar #'(lambda (cygpath)
              (make-mount-point
               :cygpath cygpath
               :winpath (map-slash-to-backslash
                         (read-mount-info type cygpath "native"))
               :flags (read-mount-info type cygpath "flags")
               :type type))
          (mounted-path-list type)))


(defun search-by-cygpath (cygpath &key all (info (cygmount-point-info)))
  (search-mount-point cygpath
                      info all
                      :key 'cygmount-point-cygpath
                      :sorter 'sort-by-cygpath
                      :case-fold nil
                      ))

(defun search-by-winpath (winpath &key all (info (cygmount-point-info)))
  (search-mount-point (map-backslash-to-slash winpath)
                      info all
                      :key 'cygmount-point-winpath
                      :sorter 'sort-by-winpath
                      :case-fold t
                      ))

(defun search-mount-point (path info all &key key sorter case-fold)
  (let ((r (remove-if-not #'(lambda (mount)
                              (string-looking-at
                               (append-trail-slash (regexp-quote (map-backslash-to-slash mount)))
                               (append-trail-slash path)
                               :case-fold case-fold))
                          (funcall sorter info)
                          :key key)))
    (if all r (car r))))

(defun sort-by-cygpath (info)
  (sort-by-length info #'cygmount-point-cygpath))

(defun sort-by-winpath (info)
  (sort-by-length info #'cygmount-point-winpath))

(defun sort-by-length (info key)
  (flet ((path> (a b)
           (let ((la (length a))
                 (lb (length b)))
             (if (= la lb)
                 (string< a b)
               (> la lb)))))
    (stable-sort info #'path> :key key)))


(defun mount-types (type)
  (if type
      (list type)
    (list :user :system)))

(defun mount-type->reg-root (type)
  (case type
    (:user
     *user-reg-root*)
    (:system
     *system-reg-root*)
    (t
     (error 'type-error
            :datum type
            :expected-type '(or :user :system)))))


(defun mount-flags->names (flags)
  (flet ((to-list (flags)
           (remove-if #'null
                      (mapcar #'(lambda (pair)
                                  (when (not (zerop (logand flags (car pair))))
                                    (cdr pair)))
                              *mount-flags-alist*))))
    (let ((names (to-list flags)))
      (unless (find :binmode names)
        (push :textmode names))
      names)))


(defun mounted-path-list (type)
  (list-registry-key *reg-section* (mount-type->reg-root type)))


(defun read-mount-info (type cygpath name)
  (reg-read (mount-type->reg-root type)
            cygpath name))

(defun cygdrive-prefix ()
  (reg-read (mount-type->reg-root :system)
            nil "cygdrive prefix"))

(defun reg-read (reg-root subkey name)
  (read-registry (if subkey
                     (concat *reg-section* "\\" subkey)
                   *reg-section*)
                 name reg-root))


(provide "cygwin-mount/mount-point")

;;;; End
