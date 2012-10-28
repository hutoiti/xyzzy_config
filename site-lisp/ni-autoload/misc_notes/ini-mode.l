;;; -*- Mode: Lisp; Package: user -*-
;;; ini-mode.l --- ini-mode の ni-autoload 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:48:51 +0900>

;; Description:
;;
;;     ini-mode の ni-autoload 用モジュール
;;

; 任意の時点で実行するのでautoloadで読み込む
(export 'ed::ini-mode "ed")
(autoload 'ini-mode "ini-mode" t)
(pushnew '("\\.ini$" . ini-mode) *auto-mode-alist* :test 'equal)

;;; ini-mode.l ends here
