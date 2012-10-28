;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/window.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  )

(in-package :hatena-haiku.ui)

#|
„¡„Ÿ„¦„Ÿ„Ÿ„Ÿ„¦„Ÿ„¢
„   „       „   „ 
„   „       „   „ 
„ 2 „   1   „ 3 „ 
„   „       „   „ 
„   „¥„Ÿ„Ÿ„Ÿ„§  „ 
„   „   4   „   „ 
„¤„Ÿ„¨„Ÿ„Ÿ„Ÿ„¨„Ÿ„£
|#
(defun haiku-split-window-4 (&key main left right bottom)
  (setup-buffer main `((,left 0.2 :left)
                       (,right 0.2 :right)
                       (,bottom 0.2 :bottom))))

(defun haiku-split-window-3 (&key main left right)
  (setup-buffer main `((,left 0.2 :left)
                       (,right 0.2 :right))))

(defun haiku-split-window-2 (&key main left)
  (setup-buffer main `((,left 0.2 :left))))

(defun haiku-split-window-1 (&key main)
  (setup-buffer main nil))

(defun setup-buffer (main-window-buffer specs)
  (setup-window-by-sepc specs)
  (show-buffer main-window-buffer))

(defun setup-window-by-sepc (specs)
  (let ((base-width (frame-width))
        (base-height (frame-height)))
    (unless (one-window-p)
      (delete-other-windows))
    (dolist (spec specs)
      (multiple-value-bind (buffer ratio direction)
          (values-list spec)
        (split-window-and-set-buffer buffer ratio direction base-width base-height)))))


(provide "hatena-haiku-mode/ui/window")

;;;; End
