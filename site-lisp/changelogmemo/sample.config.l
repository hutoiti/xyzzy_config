;;; -*- Mode: Lisp -*-
;;;
;;; config.l sample
;;;
;;; Last updated: "2006-03-08"
;;;

(in-package "changelogmemo")

;; �f�[�^�t�@�C���A�q�X�g���p�̃f�B���N�g��
(setq *cl-file* "~/cl/changelogmemo")
(setq *cl-history-directory* "~/cl/history/")

;; ���[�U�[��
(setq *cl-user* "YOUR NAME  <your@email.address>")

;; C-x 4 @ �̎��̃����E�B���h�E�̍���(nil �Ȃ番�����Ȃ�)
(setq *memo-window-height* 15)

;; chalow �̃R�}���h
(setq *chalow-command* "shell �ɑł� chalow �̃R�}���h")

;; �L�[�o�C���h
(global-set-key '(#\C-x #\4 #\@) 'add-memo-buffer)
(global-set-key '(#\C-c #\C-3) 'add-memo-buffer-from-clipboard)
(global-set-key '(#\C-3) 'add-memo-buffer-from-clipboard);winkey �p
(global-set-key '(#\C-x #\4 #\/) 'search-and)
(global-set-key '(#\C-x #\4 #\g) 'search-regexp)
(global-set-key '(#\C-x #\4 #\o) 'search-or)
(global-set-key '(#\C-x #\4 #\c) 'search-category)
(global-set-key '(#\C-x #\4 #\y) 'search-year)
(global-set-key '(#\C-x #\4 #\m) 'search-month)
(global-set-key '(#\C-x #\4 #\d) 'search-day)
(global-set-key '(#\C-x #\4 #\\) 'change-clmemo)
(global-set-key '(#\C-x #\4 #\h) 'convert-chalow)

;; �܂�Ԃ��Afill
(setq *memo-fold-width* 72)
(setq *memo-fill-column* 72)
(setq *search-fold-width* 80)
(setq *search-fill-column* 80)

;; migemo �������g�����߂̐ݒ�(�vmigemo, migemo.l)
;(require "changelogmemo/migemo")
;(global-set-key '(#\C-x #\4 #\j) 'search-migemo)

#|
;; ������ʂŃ^�u��\�����Ȃ��ݒ�
(global-set-key '(#\C-x #\4 #\/) 'esearch-and)
(global-set-key '(#\C-x #\4 #\g) 'esearch-regexp)
(global-set-key '(#\C-x #\4 #\o) 'esearch-or)
(global-set-key '(#\C-x #\4 #\c) 'esearch-category)
(global-set-key '(#\C-x #\4 #\y) 'esearch-year)
(global-set-key '(#\C-x #\4 #\m) 'esearch-month)
(global-set-key '(#\C-x #\4 #\d) 'esearch-day)
;(global-set-key '(#\C-x #\4 #\j) 'esearch-migemo)
;�܂�Ԃ��Afill
(setq *esearch-fold-width* 72)
(setq *esearch-fill-column* 72)
|#

#|
;; *scratch* �o�b�t�@�������o�b�t�@�Ƃ��Ďg��Ȃ��ݒ�
(global-set-key '(#\C-x #\4 #\@) 'add-memo)
(global-set-key '(#\C-c #\C-3) 'add-memo-from-clipboard)
(global-set-key #\C-3 'add-memo-from-clipboard);winkey �p
;�c�[���o�[�p�֐�
(setq *tool-bar-function* 'toggle-memo-tool-bar)
|#

#|
;; �F�t���̕ύX��
(setq *title-keyword*
      '("^\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
	nil (:color 1 0) nil 1 1))
(setq *title-keyword-with-tab*
      '("^\t\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
	nil (:color 1 0) nil 1 1))
(setq *date-keyword*
      '("^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z]).*$"
	nil (:color 12 0 :underline)))
|#

;; *scratch* ���I�����ɕۑ����Ă���ꍇ�̂��߂̐ݒ�
;(add-hook '*kill-xyzzy-hook* 'kill-clmemo-buffer)

;;;