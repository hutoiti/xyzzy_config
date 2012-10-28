;;; -*- Mode: Lisp; Package: user -*-
;;; multiple-replace.l --- multiple-replace.l の uninstall 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:33:37 +0900>

;; Description:
;;
;;     multiple-replace.l の uninstall 用モジュール
;;

(require "multiple-replace")
(ed::multiple-replace-uninstall)

;; アップデート時 history を維持するため
(setq lisp::*modules*
      (delete "multiple-replace" lisp::*modules* :test 'string-equal))

;; multiple-replace.l ends here
