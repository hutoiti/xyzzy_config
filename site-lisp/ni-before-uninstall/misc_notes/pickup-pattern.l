;;; -*- Mode: Lisp; Package: user -*-
;;; pickup-pattern.l --- pickup-pattern.l の uninstall 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:14:50 +0900>

;; Description:
;;
;;     pickup-pattern.l の uninstall 用モジュール
;;

(require "pickup-pattern")
(ed::pickup-pattern-uninstall)

;; アップデート時 history を維持するため(の布石)
(setq lisp::*modules*
      (delete "pickup-pattern" lisp::*modules* :test 'string-equal))

;;; pickup-pattern.l ends here
