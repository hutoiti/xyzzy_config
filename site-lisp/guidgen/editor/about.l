; -*- mode: lisp; package: editor -*-

;; guidgen/editor/abount.l
;;
;;   Copyright (c) 2006 MIYAMUKO Katsuyuki.
;;
;;   See guidgen/docs/MIT-LICENSE for full license.
;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "guidgen/guidgen"))

(in-package :editor)
(use-package :guidgen)

(defun guidgen-about-message (&optional (interval 0.1))
  (interactive)
  (dolist (�i߁�߁j (split-string "(߁��)��( ߁�)��( �@ �)��(�@ �@)��(� �@ )��(��� )��(߁��)"
                                  "��"))
    (message (concat "guidgen " *guidgen-version* " ��������" �i߁�߁j "������!!!!"))
    (sit-for interval))
  (clear-message))


(provide "guidgen/editor/about")

;; End