;;; -*- Mode: Lisp; Package: user -*-
;;; mayu-mode.l --- mayu-mode の ni-autoload 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:42:18 +0900>

;; Description:
;;
;;     mayu-mode の ni-autoload 用モジュール
;;

; 任意の時点で実行するのでautoloadで読み込む
(export 'ed::mayu-mode "ed")
(autoload 'mayu-mode "mayu-mode" t)
(pushnew '("\\.mayu$" . mayu-mode) *auto-mode-alist* :test 'equal)

;;; mayu-mode.l ends here
