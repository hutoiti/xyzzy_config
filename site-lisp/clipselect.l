;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:13:20> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   clipselect.l --- �N���b�v�{�[�h��������I�����ē\��t��
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  xyzzy ����т��̑��̃A�v���P�[�V�������N���b�v�{�[�h�ɃR�s�[����
  �f�[�^�̗������쐬���A�|�b�v�A�b�v���X�g����I�����ē\��t���܂��B

  �Z���N�V����������΁A�㏑�����ē\��t���܂��B

  ���ɗ����ɑ��݂��镶������R�s�[�����ꍇ�́A�����̗v�f���폜���āA
  ���炽�߂Đ擪�v�f�Ƃ��Ēǉ����܂��B

  ������̒��ɉ��s���܂܂��ꍇ�́A�w�肵�������ɒu�������ă��X�g
  �ɕ\�����܂��B

  ���X�g�ɕ\������镶�����́A*clipselect-string-length* �Ŏw�肵��
  �l�܂ł����\�����܂���B�����񂪏ȗ�����Ă���ꍇ�́A������ " ..."
  ��\�����܂��B

  nonentity ����́A�u�܂����낿���Ղ�xyzzy����v
         http://members.tripod.co.jp/zauberer/microtips/xyzzy.html
  �ɂ��� clipstore.l ���Q�l�ɁAclipview.l ���g�킹�Ă��������A
  �����Ă݂܂����Bnonentity ����ɂ́Aclipview.l �̓����z�z������
  ���Ă����������ӂł��B

  ���܂��ł��� clipselect-yank �́A�{�c����
                              http://member.nifty.ne.jp/seiya-suda/
  �� yank-select ���Q�l�ɂ����Ă��������܂����B������́A�L�������O
  ����I�����ē\��t���܂��B


���C���X�g�[��

  1. clipview.l �� clipselect.l �� ~/site-lisp �ɃR�s�[����B

  2. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "clipselect")

�g����:

  �E��������I�����ē\��t��  M-x clipselect
  �Eclipboard �Ɠ������ؑ�    M-x clipselect-toggle-sync

���ݒ��

  �E�L�[�o�C���h

      (define-key ctl-x-map #\Insert 'clipselect-paste)
      (define-key ctl-x-map #\y 'clipselect-yank)
      (define-key ctl-x-map #\F9 'clipselect-yank-selection)

    �Ƃ��B


���X�V����

  [Version 1.05] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.04.1] 2004/07/04 (��)
  �E�ҏW���j���[�ɂ��ǉ��ł���悤�ɂ����B
  �E�u�Z���N�V���������O����\��t���v�����������B
  �Eclipselect �� clipselect-paste �ɕύX�����B

  [Version 2003.05.13]
  �E�E�N���b�N���j���[�֒ǉ������B
  �Eyankselect �� clipselect-yank �ɕύX�����B

  [Version 1.03] 2003/04/09 (��)
  �E���X�g�̕\���������𐧌����邽�߂ɁA�� popup-menu ���g���悤�ɂ����B
  �E���s��ʂ̕����ɒu�������ĕ\���ł���悤�ɂ����B
  �Eclipselect-sync �� clipselect-toggle-sync �ɕύX�����B
  �E���܂��ŁAyankselect �������B
  �E������ clipview.l ��V�������̂ɂ����B�inonentity ���񂠂肪�Ƃ��������܂��B�j

  [Version 1.02.1] 2003/01/15 (��)
  �E�I�������p hook �̒ǉ�/�폜�𒚔J�ɂ���悤�ɂ����B

  [Version 1.02] 2003/01/15 (��)
  �E�ォ��N������ xyzzy ���ɏI��������ƁAclipboard �Ɠ��������
    �Ȃ��Ȃ�s����C�������B�i����j

  [Version 1.01] 2003/01/14 (��)
  �Eclipselect-copy, clipselect-kill ���s�v�Ȃ��Ƃɍ����C�t���폜�����B
  �E*clipselect-sync*, clipselect-sync ��ǉ������B
  �E�f�[�^�����̃z���C�g�X�y�[�X����щ��s���폜���Ȃ��悤�ɂ����B
  �Eclipselect-clear, *clipselect-enable-self-owner* ���폜�����B
  �Eclipselect-viewer-hook ���폜���Aclipselect-push �ɂ܂Ƃ߂��B

  [Version 1.00] 2002/12/30 (��)
  �E�������B


�����C�Z���X

  clipselect.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2002-2007 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

|#

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "clipview"))

(provide "clipselect")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�i�K���ɃJ�X�^�}�C�Y���邠����j
;;; ������������������������������������������������������������������������ ;;;

;;; xyzzy �N������ clipboard �Ɠ������J�n
(defvar *clipselect-sync* t)

;;; �ۑ����闚���̐�
(defvar *clipselect-ring-max* 16)

;;; �|�b�v�A�b�v���j���[�̕\��������
(defvar *clipselect-string-length* 50)

;;; ���s��u�������镶��
(defvar *clipselect-new-line-char* "��")

;;; �ҏW���j���[�֒ǉ�����
(defvar *clipselect-add-menu* t)

;;; �V���[�g�J�b�g���j���[�֒ǉ�����
(defvar *clipselect-add-popup-menu* t)

;;; ���j���[�}���ʒu
(defvar *clipselect-menu-position* 4)

(defvar *clipselect-ring* nil)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �N���b�v�{�[�h���𑀍�
;;; ������������������������������������������������������������������������ ;;;

(defun clipselect-paste ()
  "clipselect: �N���b�v�{�[�h�̗�������I�����ē\��t��"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *clipselect-ring*))
      (let* ((str (string (nth arg *clipselect-ring*)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'clipselect
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))

;;; ���֐����Ƃ̌݊�
(setf (symbol-function 'clipselect) 'clipselect-paste)

#|
;;; �O�Ɏg���Ă�����
(defun clipselect-paste ()
  "clipselect: �N���b�v�{�[�h�̗�������I�����ē\��t��"
  (interactive "*")
  (let (from to)
    (selection-start-end (start end)
      (setq from start)(setq to end))
    (popup-list *clipselect-ring*
		#'(lambda (str)
		    (when (and from to)
		      (delete-region from to))
		    (insert str)
		    (refresh-screen)))))
|#

(defun clipselect-toggle-sync ()
  "clipselect: �N���b�v�{�[�h�Ƃ̓�����؂�ւ�"
  (interactive)
  (if *clipselect-sync*
      (progn (setq *clipselect-sync* nil)
	(win-user::delete-clipboard-viewer-hook 'clipselect-push)
	(delete-hook '*kill-xyzzy-hook* 'clipselect-exit)
	(message "clipselect-sync stop."))
    (progn (setq *clipselect-sync* t)
      (win-user::add-clipboard-viewer-hook 'clipselect-push)
      (add-hook '*kill-xyzzy-hook* 'clipselect-exit)
      (message "clipselect-sync start."))))

(defun clipselect-push ()
  (let ((str (get-clipboard-data)))
    (when str
      (setq *clipselect-ring* (remove str *clipselect-ring* :test #'string=))
      (setq *clipselect-ring*
	    (ed::push-kill-ring str *clipselect-ring* *clipselect-ring-max*)))))

(defun clipselect-exit ()
  (win-user::delete-clipboard-viewer-hook 'clipselect-push))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� *kill-ring*/*selection-ring* ����
;;; ������������������������������������������������������������������������ ;;;

(defun clipselect-yank ()
  "clipselect: �L�������O����I�����ē\��t��"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *kill-ring*))
      (let* ((str (car (ed::current-kill arg t)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'yankselect
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))

(defun clipselect-yank-selection ()
  "clipselect: �Z���N�V���������O����I�����ē\��t��"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *selection-ring*))
      (let* ((str (cdr (ed::current-selection arg t)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'clipselect2
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���j���[
;;; ������������������������������������������������������������������������ ;;;

;;; �ҏW���j���[�ɒǉ�
;;;   OHKUBO ����� multiple-replace.l ���璸�� m(_ _)m
(defun clipselect-insert-menu (&key menu position head-sep tail-sep)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::edit)))
  (when (menup menu)
    ;(clipselect-delete-menu menu)
    (unless (and (numberp position) (integerp position) (not (minusp position))
		 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
	     (not (minusp position))
	     (get-menu menu position t))
	(insert-menu-separator menu (incf position) 'clipselect-sep))
    (insert-menu-item menu (incf position) nil
		      "��������I�����ē\��t��(&H)..."
		      'clipselect-paste
		      #'(lambda ()
			  (unless *clipselect-ring*
			    :disable)))
    (insert-menu-item menu (incf position) nil
		      "�L�������O����I�����ē\��t��(&K)..."
		      'clipselect-yank
		      #'(lambda ()
			  (unless *kill-ring*
			    :disable)))
    (insert-menu-item menu (incf position) nil
		      "�Z���N�V���������O����I�����ē\��t��(&Y)..."
		      'clipselect-yank-selection
		      #'(lambda ()
			  (unless *selection-ring*
			    :disable)))
    (if (and tail-sep
	     (get-menu menu (incf position) t))
	(insert-menu-separator menu position 'clipselect-sep))))

;;; �V���[�g�J�b�g���j���[�ɒǉ�
(defun clipselect-insert-popup-menu ()
  (let (pos menu)
    (setq pos *clipselect-menu-position*)
    (setq menu *app-popup-menu*)
    (setq pos (1- pos))
    (insert-menu-separator menu (incf pos))
    (insert-menu-item menu (incf pos) nil
		      "��������I�����ē\��t��(&H)..."
		      'clipselect-paste
		      #'(lambda ()
			  (unless *clipselect-ring*
			    :disable)))
    (insert-menu-item menu (incf pos) nil
		      "�L�������O����I�����ē\��t��(&K)..."
		      'clipselect-yank
		      #'(lambda ()
			  (unless *kill-ring*
			    :disable)))
    (insert-menu-item menu (incf pos) nil
		      "�Z���N�V���������O����I�����ē\��t��(&Y)..."
		      'clipselect-yank-selection
		      #'(lambda ()
			  (unless *selection-ring*
			    :disable)))
    (insert-menu-separator menu (incf pos))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �N�����̏���
;;; ������������������������������������������������������������������������ ;;;

(defun clipselect-init ()
  (when *clipselect-add-menu*
    (clipselect-insert-menu :position 7 :head-sep t :tail-sep t))
  (when *clipselect-add-popup-menu*
    (clipselect-insert-popup-menu))
  (when *clipselect-sync*
    (win-user::add-clipboard-viewer-hook 'clipselect-push)
    (add-hook '*kill-xyzzy-hook* 'clipselect-exit)))

(add-hook '*init-app-menus-hook* #'clipselect-init)


;;; clipselect.l ends here.