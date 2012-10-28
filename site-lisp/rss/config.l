;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: config.l 731 2006-09-01 18:09:41Z torihat $
;
; config.l sample
;
; by HATTORI Masashi

(in-package "rss")

;;; www-mode�ŊJ��
;(require "rss/open-www")

;;; �N�����ɃI�����C�����[�h�ɂ���
;(rss-toggle-online t)

;;; �u���E�U�̍����ݒ�
;(setq *rss-browser-height* 400)

;;; Description �\���f�t�H���g�ݒ�
;(setq *rss-item-show-description* t)

;;; ���ǌ������̐ݒ�
; ���ǂ̍X�V���ꂽ�G���g�����Ώۂɂ��邩�ǂ���
;(setq *rss-search-unread-with-updated* t)
; ���̖��ǂ��������炻����J�����ǂ���
;(setq *rss-search-next-unread-open*  t)
; �`���l�����ɖ��ǂ��Ȃ������ꍇ�Ɏ��̃`���l����T���ɍs�����ǂ���
;(setq *rss-search-next-unread-menu*  t)
; �O���[�v���ɖ��ǂ��Ȃ������ꍇ�Ɏ��̃O���[�v��T���ɍs�����ǂ���
;(setq *rss-search-next-unread-group* t)

;;; �L���b�V��
; �ߋ��̃G���g�����܂�n���܂ŃL���b�V������
;�i�f�t�H���g�͉ߋ��̃G���g�����L���b�V�����Ȃ��j
;(setq *rss-cache-max-number* 30)
; ������n���܂ŃL���b�V������i�f�t�H���g��100���j
;(setq *rss-history-max-number* 200)
; �N���b�v����G���g���̏���i�f�t�H���g��100���j
;(setq *rss-clip-max-number* 300)

;;; Hyper Estraier�Ō����i�vhecmd�j
;(require "rss/hyper-estraier")
;
;; hook �ŃC���f�b�N�X�o�^
;(add-hook '*rss-start-hook*      'he-init)
;(add-hook '*rss-finish-hook*     'he-sync)
;(add-hook '*rss-open-rss-hook*   'he-sync)
;(add-hook '*rss-fetch-data-hook* 'he-gather-entries)
;
;; �L�[�o�C���h
;(define-key *rss-group-map*    #\/ 'he-search)
;(define-key *rss-menu-map*     #\/ 'he-search)
;(define-key *rss-mode-map*     #\/ 'he-search)
;(define-key *rss-clip-map*     #\/ 'he-search)
;(define-key *rss-history-map*  #\/ 'he-search)
;
;(define-key *rss-group-map* #\C 'he-group-gather-all)
;(define-key *rss-menu-map*  #\C 'he-menu-gather-all)

;;; �z�F�ݒ蓙
; �O���[�v�ꗗ�^�C�g��
;(setq *rss-attribute-group-title* '(:bold t))
; �O���[�v�ꗗ
;(setq *rss-attribute-group* nil)
; �O���[�v�ꗗ�i���ǗL��j
;(setq *rss-attribute-group-unread* '(:foreground 1))
; �`���l���ꗗ�^�C�g��
;(setq *rss-attribute-menu-title* '(:bold t))
; �`���l���ꗗ
;(setq *rss-attribute-menu* nil)
; �`���l���ꗗ�i���ǗL��j
;(setq *rss-attribute-menu-unread* '(:foreground 1))
; �G���g���ꗗ�`���l����
;(setq *rss-attribute-channel-title* '(:bold t))
; �G���g���ꗗ�`���l�� Description
;(setq *rss-attribute-channel-description* nil)
; �G���g���^�C�g���i���ǁj
;(setq *rss-attribute-item-title* '(:bold nil
;				   :foreground 1))
; �G���g���^�C�g���i���ǁj
;(setq *rss-attribute-item-title-unread* '(:bold t
;					  :foreground 1))
; �G���g�� Description
;(setq *rss-attribute-item-description* nil)

;;; LIRS�`���̃t�B���^�ݒ�
;; �ő�\�������i��������ƒx���j
;(setq *lirs-items-max* 30)
;; �t�B���^��������URL�̃p�^�[��
;; �i�f�t�H���g�� "lirs.txt" "lirs.txt.gz" "lirs.gz" �Ƀ}�b�`�j
;(setq *lirs-url-regexp* "lirs\\(\.txt\\|\.txt.gz\\|\.gz\\)$")
;; �t�B���^��������URL��o�^
;(rss-filter-regist "�o�^����URL1" 'lirs-filter)
;(rss-filter-regist "�o�^����URL2" 'lirs-filter)

;;; hina-di�`���̃t�B���^�ݒ�
;; �ő�\�������i��������ƒx���j
;(setq *hina-di-items-max* 30)
;; �t�B���^��������URL�̃p�^�[��
;; �i�f�t�H���g�� "*.di" �Ƀ}�b�`�j
;(setq *hina-di-url-regexp* "\.di$")
;; �t�B���^��������URL��o�^
;(rss-filter-regist "�o�^����URL1" 'hina-di-filter)
;(rss-filter-regist "�o�^����URL2" 'hina-di-filter)

;;; hina.txt�`���̃t�B���^�ݒ�
;; �ő�\�������i��������ƒx���j
;(setq *hina-txt-items-max* 30)
;; �t�B���^��������URL�̃p�^�[��
;; �i�f�t�H���g�� "*.di" �Ƀ}�b�`�j
;(setq *hina-txt-url-regexp* "\.di$")
;; �t�B���^��������URL��o�^
;(rss-filter-regist "�o�^����URL1" 'hina-txt-filter)
;(rss-filter-regist "�o�^����URL2" 'hina-txt-filter)