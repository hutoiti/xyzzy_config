;;; -*- Mode: Lisp; Package: user -*-
;;; popup-mode-memo.l --- popup-mode-memo.l �� ni-autoload �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 11:39:31 +0900>

;; Description:
;;
;;     popup-mode-memo.l �� ni-autoload �p���W���[��
;;

; �N��������g�p���邽��require�œǂݍ���
(require "popup-mode-memo")
(global-set-key #\C-F12 'popup-mode-memo)
(set-function-bar-label #\C-F12 "memo")

;;; popup-mode-memo.l ends here