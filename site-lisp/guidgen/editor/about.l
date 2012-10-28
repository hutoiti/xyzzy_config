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
  (dolist (（ﾟ∀ﾟ） (split-string "(ﾟ∀ﾟ)━( ﾟ∀)━( 　 ﾟ)━(　 　)━(ﾟ 　 )━(∀ﾟ )━(ﾟ∀ﾟ)"
                                  "━"))
    (message (concat "guidgen " *guidgen-version* " ｷﾀ━━━" （ﾟ∀ﾟ） "━━━!!!!"))
    (sit-for interval))
  (clear-message))


(provide "guidgen/editor/about")

;; End
