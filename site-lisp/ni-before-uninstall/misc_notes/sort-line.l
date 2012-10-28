;;; -*- Mode: Lisp; Package: user -*-
;;; sort-line.l --- sort-line.l の uninstall 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 13:02:17 +0900>

;; Description:
;;
;;     sort-line.l の uninstall 用モジュール
;;

(require "sort-line")
(sort-line::sort-line-uninstall)

;; アップデート時 history を維持するため
(setq lisp::*modules*
      (delete "sort-line" lisp::*modules* :test 'string-equal))

;;; sort-line.l ends here
