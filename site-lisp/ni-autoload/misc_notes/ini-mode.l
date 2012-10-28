;;; -*- Mode: Lisp; Package: user -*-
;;; ini-mode.l --- ini-mode �� ni-autoload �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:48:51 +0900>

;; Description:
;;
;;     ini-mode �� ni-autoload �p���W���[��
;;

; �C�ӂ̎��_�Ŏ��s����̂�autoload�œǂݍ���
(export 'ed::ini-mode "ed")
(autoload 'ini-mode "ini-mode" t)
(pushnew '("\\.ini$" . ini-mode) *auto-mode-alist* :test 'equal)

;;; ini-mode.l ends here