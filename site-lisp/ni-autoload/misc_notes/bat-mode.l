;;; -*- Mode: Lisp; Package: user -*-
;;; bat-mode.l --- bat-mode の ni-autoload 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:46:25 +0900>

;; Description:
;;
;;     bat-mode の ni-autoload 用モジュール
;;

; 任意の時点で実行するのでautoloadで読み込む
(export 'ed::bat-mode "ed")
(autoload 'bat-mode "bat-mode" t)
(pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)

;;; bat-mode.l ends here
