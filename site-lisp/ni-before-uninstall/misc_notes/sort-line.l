;;; -*- Mode: Lisp; Package: user -*-
;;; sort-line.l --- sort-line.l �� uninstall �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 13:02:17 +0900>

;; Description:
;;
;;     sort-line.l �� uninstall �p���W���[��
;;

(require "sort-line")
(sort-line::sort-line-uninstall)

;; �A�b�v�f�[�g�� history ���ێ����邽��
(setq lisp::*modules*
      (delete "sort-line" lisp::*modules* :test 'string-equal))

;;; sort-line.l ends here