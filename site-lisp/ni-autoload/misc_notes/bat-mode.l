;;; -*- Mode: Lisp; Package: user -*-
;;; bat-mode.l --- bat-mode �� ni-autoload �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:46:25 +0900>

;; Description:
;;
;;     bat-mode �� ni-autoload �p���W���[��
;;

; �C�ӂ̎��_�Ŏ��s����̂�autoload�œǂݍ���
(export 'ed::bat-mode "ed")
(autoload 'bat-mode "bat-mode" t)
(pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)

;;; bat-mode.l ends here