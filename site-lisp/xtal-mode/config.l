;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/config.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/package")
  )

(in-package :xtal-mode)

(export '(*xtal-mode-map*
          *xtal-mode-syntax-table*
          *xtal-keyword-file*
          *xtal-indent-level*
          *xtal-electric-insert-close-parentheses*
          *xtal-electric-insert-close-string*
          *xtal-comment-column*
          *xtal-install-path*
          *xtal-command-xtal*
          *xtal-command-ix*
          *xtal-mode-output-buffer-name*
          *xtal-command-output-window-height*
          *xtal-ix-buffer-name*
          *xtal-ix-window-height*
          *xtal-mode-hook*
          *xtal-create-output-buffer-hook*
          *xtal-before-run-xtal-hook*
          *xtal-run-xtal-hook*
          *xtal-after-run-xtal-hook*
          *xtal-online-reference-url*
          *xtal-home-url*
          ))

(defvar *xtal-mode-map* nil
  "xtal-mode: �L�[�}�b�v")

(defvar *xtal-mode-syntax-table* nil
  "xtal-mode: �V���^�b�N�X�e�[�u��")

(defvar *xtal-keyword-file* "Xtal"
  "xtal-mode: �L�[���[�h�t�@�C����")


(defvar *xtal-indent-level* c-indent-level
  "xtal-mode: �C���f���g���x��")

(defvar *xtal-electric-insert-close-parentheses* t
  "xtal-mode: �����I�ɕ����ʂ�}������Ȃ� t")

(defvar *xtal-electric-insert-close-string* t
  "xtal-mode: �����I�ɕ���������Ȃ� t")

(defvar *xtal-comment-column* 60
  "xtal-mode: indent-for-comment �ő}������R�����g�̊J�n�ʒu")


(defvar *xtal-install-path* "C:/xtal"
  "xtal-mode: xtal �̃C���X�g�[���p�X (xtal.exe �̂���p�X)")

(defvar *xtal-command-xtal* "xtal.exe"
  "xtal-mode: xtal.exe �ւ̃p�X. ���΃p�X�̏ꍇ *xtal-instal-path* ����T���܂�")

(defvar *xtal-command-ix* "ix.exe"
  "xtal-mode: ix.exe �ւ̃p�X. ���΃p�X�̏ꍇ *xtal-instal-path* ����T���܂�")


(defvar *xtal-mode-output-buffer-name* "*Xtal*"
  "xtal-mode: xtal �R�}���h�̎��s���ʃo�b�t�@�̖��O")

(defvar *xtal-command-output-window-height* -10
  "xtal-mode: xtal �̎��s���ʂ�\������E�B���h�E�̍���")

(defvar *xtal-ix-buffer-name* "*ix*"
  "xtal-mode: ix �����s����o�b�t�@�̖��O")

(defvar *xtal-ix-window-height* -20
  "xtal-mode: ix �����s����E�B���h�E�̍���")


(defvar *xtal-mode-hook* nil
  "xtal-mode: xtal-mode ���s���ɌĂ΂��t�b�N")

(defvar *xtal-create-output-buffer-hook* nil
  "xtal-mode: xtal �R�}���h�̎��s���ʃo�b�t�@�쐬���ɌĂ΂��t�b�N")

(defvar *xtal-before-run-xtal-hook* nil
  "xtal-mode: xtal �R�}���h���s���O�ɌĂ΂��t�b�N")

(defvar *xtal-run-xtal-hook* nil
  "xtal-mode: xtal �R�}���h���s�J�n���ɌĂ΂��t�b�N�B������ xtal.exe �� process")

(defvar *xtal-after-run-xtal-hook* nil
  "xtal-mode: xtal �R�}���h�̎��s���I�������Ƃ��ɌĂ΂��t�b�N�B������ xtal.exe �� process")


(defvar *xtal-online-reference-url* "http://www.h5.dion.ne.jp/~putora/xtal_doc/"
  "xtal-mode: �I�����C�����t�@�����X�� URL")

(defvar *xtal-home-url* "http://code.google.com/p/xtal-language/"
  "xtal-mode: Home URL")


(provide "xtal-mode/config")

;;;; End