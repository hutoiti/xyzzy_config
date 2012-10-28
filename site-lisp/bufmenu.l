;;; -*- Mode: Lisp; Last updated: <2007/12/31 01:05:37>; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   bufmenu.l - �o�b�t�@����p�|�b�v�A�b�v���j���[
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  �E��\���o�b�t�@���܂߁C�o�b�t�@�̈ꗗ���|�b�v�A�b�v�\�����܂��B
  �EKaMail �Ƃ� www-mode ���g�p���Ă���Ƃ��Ɉꗗ����o�b�t�@�̑I�����s���ƁC
    �uFrame 1�v�Ɉړ����ĊJ���܂��B
  �E��\���o�b�t�@��I�������ꍇ�́C���݂̃t���[���ŊJ���܂��B
  �E�o�b�t�@�̈ꗗ�́C�o�b�t�@���C�������͎Q�Ƃ��Ă���t�@�C�����ŕ\�����C����
    ���ꖼ�O���Ƀ\�[�g����܂��B
  �E�K�v�ɉ����C�t���[���̈ꗗ���\�����܂��B
  �E�o�b�t�@�o�[�R���e�L�X�g���j���[�ɁC�o�b�t�@���܂Ƃ߂ĕ�����C���s������
    ���O���R�s�[�����肷�郁�j���[��ǉ����܂��B


�����엝�R

  ���̂���Ȃ��̂����������Ƃ����Ɓc�C
  
  �E������CKaMail �Ȃǂ̓Ǝ��t���[�����g�p����g�����̂��펞�g�p���Ă���
    �̂ł����C[Frame 1 �Ɉړ�] �� [�o�b�t�@�I��] �Ƃ��������������h�[�ł�
    ��B
  �Ewww-mode �Ȃǂ̃o�b�t�@���\���ɂ��Ďg���Ă���̂ł����C�悭�悭����
    �o�b�t�@���J���Ă��܂��߂��Ȃ��Ȃ��Ă��܂��B
  �E�o�b�t�@�o�[�Ɏ��܂肫��Ȃ��������̃o�b�t�@���J���Ă��钆����o�b�t�@
    ��I������ꍇ�ɁCselect-buffer �ł��ǂ��̂ł����C����\�[�g�������K�v
    ����������C���ɂ͕K�v�Ȃ���񂪂����Č��ɂ��������肷��B
  �E�ꍇ�ɂ���āC�o�b�t�@���X�g���o�b�t�@���ŕ\��������C�t�@�C�����ŕ\��
    �����肵���������B
  �E�K�v�Ȃ����ǃt���[�������X�g����I�����Ă݂��������B
  �Exyzzy Note �ɏ����Ă����o�b�t�@�o�[�R���e�L�X�g���j���[�p�� Lisp �ɁC
    �ڂɗ]�镔�������X�������c�B
  �E�ӂ�������� Tips�i�^�u�u���E�U���ۂ����j���[�j�ɏ����΂�����������
    �g�����������B�i���ė~�����Ȃ��o�b�t�@���w�肵����j
  �E�Ȃ�ƂȂ������Ă݂��������B
  
  ����B


���C���X�g�[��

  1. bufmenu.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����C�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "bufmenu")

  4. xyzzy ���ċN�����C�ݒ�𔽉f������B
     siteinit.l �ɋL�q�����ꍇ�͍ă_���v������B


���c�[���o�[�ݒ�

  �c�[���o�[���g���ꍇ�́C[�\��]-[�c�[���o�[]-[bufmenu] �Ƀ`�F�b�N�����܂��B


���A���C���X�g�[��

  1. �c�[���o�[�����폜����B
     ESC �L�[���Q�񉟂�����C�~�j�o�b�t�@��
       (bufmenu-uninstall-tool-bar)
    �Ɠ��͂��CEnter ����B

  2. �������t�@�C������ݒ���폜����B
     siteinit.l �ɋL�q���Ă����ꍇ�͍ă_���v����B

  3. ���̃t�@�C�� bufmenu.l�i����� bufmenu.lc�j���폜����B


���ݒ��

    ;;; �o�b�t�@�I���|�b�v�A�b�v���X�g�\�� [C-Apps C-Apps]
    (global-set-key '(#\C-Apps #\C-Apps) 'bufmenu-popup)
    
    ;;; �o�b�t�@�o�[�R���e�N�X�g���j���[��\�� [C-Apps Apps]
    (global-set-key '(#\C-Apps #\Apps) 'bufmenu-popup-buffer-bar-context-menu)

  �Ƃ��B


���J�X�^�}�C�Y

  �R�{����� favorites.l �ŁC����̃t���[���̏ꍇ�͊���̃t���[���Ɉړ���
  �ĊJ���B

  (defun open-favorites-func (f)
    "���C�ɓ�����J��"
    (if (string= (pathname-type f) "lnk")
        (setq f (resolve-shortcut f)))
    (cond ((not (file-exist-p f))
           (message "~A �̓����N�؂�ł�" (file-namestring f)))
          (*favorites-open-with-shell*
           (shell-execute (map-slash-to-backslash f)))
          (t
           (bufmenu-select-default-frame)
           (find-file f)
           (add-history f '*minibuffer-file-name-history*))))

  bufmenu �ŋߎg�����t�@�C���ꗗ�����̃t���[���̏ꍇ�͊���̃t���[����
  �ړ����ĊJ���B���l�^�́Cxyzzy Part6 332 ����� list-recents�B

    (defun bufmenu-list-recents ()
      "bufmenu �ŋߎg�����t�@�C���ꗗ"
      (interactive)
      (let (hlist filename)
        (setq hlist (mapcar #'(lambda (x)
                                (list (abbreviate-display-string x 60 t) x))
                            *minibuffer-file-name-history*))
        (multiple-value-bind (result data)
            (dialog-box
             '(dialog 0 0 286 162
               (:caption "bufmenu : �ŋߎg����̧��")
               (:font 9 "�l�r �o�S�V�b�N")
               (:control
                (:listbox flist nil #x50b10111 7 7 216 148)
                (:button IDOK "OK" #x50010001 229 7 50 14)
                (:button IDCANCEL "��ݾ�" #x50010000 229 24 50 14)))
             (list (cons 'flist hlist))
             `((flist :must-match t :enable (IDOK))))
          (when result
            (setq filename (car (cddr (assoc 'flist data))))
            (bufmenu-select-default-frame)
            (find-file filename)
            (add-history filename '*minibuffer-file-name-history*)))))

  �o�b�t�@�o�[�R���e�L�X�g���j���[�ɁCOHKUBO����� browserex ��ǉ������
  ���́C����Ȋ����ŁB

  (add-hook '*bufmenu-add-context-menu-middle-hook*
            #'(lambda ()
                (let (menu)
                  (setq menu *buffer-bar-context-menu*)
                  (flet ((buf () *buffer-bar-context-menu-buffer*))
                    (add-menu-separator menu)
                    (add-menu-item menu nil "��׳�ނŕ\��(&B)"
                                   #'(lambda () (interactive)
                                       (set-buffer (buffer-name (buf)))
                                       (bx:navigate-current-buffer)))))))


���X�V����

  [Version 1.05] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.04] ���H
  �E���j���[��S�p�J�^�J�i�ɁB

  [Version 1.03] 2004/10/31(��)
  �E�u����ȊO�����v�����������삵�Ă��Ȃ������̂��C�������B
    xyzzy�̎g������������ʂ₵ ��܂����� ����5 �� 215 ����C216 ����
    ���肪�Ƃ��������܂��Bm(_ _)m

  [Version 1.02] 2004/06/20(��)
  �E�ݒu�ꏊ�� site-lisp/bufmenu/bufmenu.l ����Csite-lisp/bufmenu.l
    �ɖ߂����B
  �E��\���o�b�t�@��I�������Ƃ��́C�t���[�����ړ����Ȃ��悤�ɂ����B
  �E����̃t���[���ȊO�̃t���[�������݂��Ă��u���ׂẴo�b�t�@�����v
    �����삷��悤�ɂ����B
  �E�o�b�t�@�o�[�R���e�N�X�g���j���[�ɗ]�v�ȃ��m��ǉ�����悤�ɂ����B
  �E���̑��s��C���Ƃ����낢��B

  [Version 1.01] 2003/05/30(��)
  �E�u�\���ݒ�v�ύX��́C���j���[���ĕ\������悤�ɂ����B
  �E��\���o�b�t�@�̕\�����@��ύX�����B

  [Version 1.00 (2003.05.22)]
  �E�������B


�����C�Z���X

  bufmenu.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2003-2007 HIE Masahiro

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

(provide "bufmenu")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�i�K���ɃJ�X�^�}�C�Y���邠����j
;;; ������������������������������������������������������������������������ ;;;

;;; ����̃t���[��
(defvar *bufmenu-default-frame* "Frame 1")

;;; �����ɓo�^�����t���[���Ńo�b�t�@��I������Ɗ���̃t���[���ŊJ��
(defvar *bufmenu-hide-buffer-frame-list*
  '("2ch" "KaMail" "WWW" "*tterm*" "RSS" "NetInst" "CalMemo"))

;;; �܂Ƃ߂ĕ���n�̃��j���[�ŕ��Ȃ��o�b�t�@�̃��X�g
(defvar *bufmenu-no-close-buffer-list*
  '("*WWW " "*NetInstaller " "*KaMail:" "*RSS " "*CalMemo:" "*Diary" "*scratch*"))

;;; �t���[�����j���[��\������
(defvar *bufmenu-use-frame-menu* t)

;;; �\���ݒ胁�j���[��\�����Ȃ�
(defvar *bufmenu-hide-option-menu* nil)

;;; �o�b�t�@�I�����X�g���t�@�C�����ŕ\������
(defvar *bufmenu-use-file-name* t)

;;; ����̃t���[���Ɉړ����ĊJ��
(defvar *bufmenu-switch-pseudo-frame* t)

;;; �o�b�t�@�o�[�R���e�N�X�g���j���[�ɂ��낢��ǉ�����
(defvar *use-buffer-bar-context-menu* t)

;;; �o�b�t�@���瑗��̃��X�g
;;;   �����炭 *filer-send-to-list* �Ɠ�������
;;;   �I�v�V�����t�ŋN������ꍇ�̓��X�g�ŋL�q
(defvar *bufmenu-send-to-list*
  (list
   '(" Internet Explorer" . "C:/Program Files/Internet Explorer/IEXPLORE.EXE")
   '(" Mozilla Firefox"   . "C:/Program Files/Mozilla Firefox/firefox.exe")
   '(" TeraPad(ro)"       . '("C:/usr/local/TeraPad/TeraPad.exe" "/r"))
   (cons "[Desktop]" (map-backslash-to-slash
		      (get-special-folder-location :desktop)))
   ))

;;; �o�b�t�@�o�[�R���e�L�X�g���j���[�ǉ��O�ɕ]������t�b�N
(defvar *bufmenu-add-context-menu-pre-hook* nil)

;;; �o�b�t�@�o�[�R���e�L�X�g���j���[�ǉ����ɕ]������t�b�N
(defvar *bufmenu-add-context-menu-middle-hook* nil)

;;; �o�b�t�@�o�[�R���e�L�X�g���j���[�ǉ���ɕ]������t�b�N
(defvar *bufmenu-add-context-menu-hook* nil)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���j���[�\���p�R�}���h
;;; ������������������������������������������������������������������������ ;;;

(defun bufmenu-popup (&optional apps)
  "bufmenu �o�b�t�@�I���|�b�v�A�b�v���X�g�\��"
  (interactive)
  (bufmenu-mouse-popup t))

(defun bufmenu-popup-buffer-bar-context-menu ()
  "bufmenu �o�b�t�@�o�[�R���e�N�X�g���j���[��\��"
  (interactive)
  (setq *buffer-bar-context-menu-buffer* (selected-buffer))
  (track-popup-menu *buffer-bar-context-menu*))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �o�b�t�@���܂Ƃ߂ĕ���֐�
;;; ������������������������������������������������������������������������ ;;;

(defun bufmenu-kill-all-buffers (&optional exception)
  "bufmenu �S�Ẵo�b�t�@�����"
  (interactive)
  (let ((buffer-lst nil))
    (dolist (b (buffer-list) t)
      (let ((bn (buffer-name b)))
	(unless (or (string= bn " " :end1 1)
		    (string= bn exception)
		    (member-if #'(lambda (x)
				   (let ((lbn (length bn))
					 (lx (length x)))
				     (and (>= lbn lx)
					  (string= bn x :end1 lx))))
			       *bufmenu-no-close-buffer-list*))
	  (push b buffer-lst))))
    (when (and (> (list-length buffer-lst) 0)
	       (or exception
		   (yes-or-no-p "�o�b�t�@��S�����܂���B")))
      (dolist (buffer buffer-lst t)
	(kill-buffer buffer)))))

(defun bufmenu-close-other-buffers ()
  "bufmenu ���݂̃o�b�t�@�ȊO�����"
  (interactive)
  (bufmenu-kill-all-buffers
   (buffer-name *buffer-bar-context-menu-buffer*)))

;;; ���E�̃o�b�t�@���܂Ƃ߂ĕ���
;;;   �ӂ�������� Tips ���Q�l�� m(_ _)m (version 0.2.2.233 �ȍ~)
;;;   *bufmenu-no-close-buffer-list* �ɓo�^���ꂽ�o�b�t�@�͕��Ȃ��悤��
(defun bufmenu-close-right-buffers (&optional left)
  "bufmenu �E�̃o�b�t�@�����ׂĕ���"
  (interactive)
  (let ((mb *buffer-bar-context-menu-buffer*)
	(eb (get-next-buffer (if left :bottom :top) nil t)))
    (let ((nb (get-next-buffer mb left t)) b bn)
      (while (not (equal nb eb))
	(setq b nb
	      nb (get-next-buffer nb left t)
	      bn (buffer-name b))
	(unless (or (string= bn " " :end1 1)
		    (member-if #'(lambda (x)
				   (let ((lbn (length bn))
					 (lx (length x)))
				     (and (>= lbn lx)
					  (string= bn x :end1 lx))))
			       *bufmenu-no-close-buffer-list*))
	  (kill-buffer b))))
    (switch-to-buffer mb)))

(defun bufmenu-close-left-buffers ()
  "bufmenu ���̃o�b�t�@�����ׂĕ���"
  (interactive)
  (bufmenu-close-right-buffers t))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �c�[���o�[�֘A�̊֐�
;;; ������������������������������������������������������������������������ ;;;

;;; bufmenu �c�[���o�[��`
(defun bufmenu-tool-bar ()
  (create-tool-bar 'bufmenu-tool-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("�o�b�t�@���X�g" 21 bufmenu-mouse-popup))))

;;; bufmenu �c�[���o�[�o�^
(define-command-bar 'bufmenu-tool-bar "bufmenu(&U)")

;;; bufmenu �c�[���o�[�폜
(defun bufmenu-uninstall-tool-bar ()
  (delete-command-bar 'bufmenu-tool-bar))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���̑��̊֐�
;;; ������������������������������������������������������������������������ ;;;

;;; �󋵂ɉ�������̃t���[���Ɉړ�
(defun bufmenu-select-default-frame ()
  (when (and (member (ed::pseudo-frame-name (selected-pseudo-frame))
		     *bufmenu-hide-buffer-frame-list*
		     :test #'equal)
	     *bufmenu-switch-pseudo-frame*)
    (select-pseudo-frame (find-pseudo-frame *bufmenu-default-frame*))))

(defun bufmenu-switch-to-buffer (buffer)
  "bufmenu ����̃t���[���� switch-to-buffer"
  (interactive "bSwitch to buffer: ")
  (bufmenu-select-default-frame)
  (switch-to-buffer buffer))

(defun bufmenu-sendto-dialog (file)
  "bufmenu �u����v�_�C�A���O"
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box
       '(dialog 0 0 219 100
	 (:caption "�������Ⴄ��")
	 (:font 9 "�l�r �o�S�V�b�N")
	 (:control
	  (:listbox list nil #x50b10111 7 7 150 82)
	  (:button IDOK "����" #x50010001 162 7 50 14)
	  (:button IDCANCEL "����Ȃ�" #x50010000 162 24 50 14)))
       (list (cons 'list *bufmenu-send-to-list*))
       nil)
    (when result
      (let (len item cmd opt)
	(setq len (assoc 'list data))
	(if (equal (list-length len) 2)
	    (setq cmd (cddr (assoc 'list data)))
	  (progn
	    (setq item (cdddr (assoc 'list data)))
	    (setq cmd (caar item))
	    (setq opt (cadar item))))
	(if cmd
	    (if (file-directory-p cmd)
		(progn
		  (copy-file file (merge-pathnames (file-namestring file) cmd))
		  (shell-execute cmd))
	      (when (file-exist-p cmd)
		(call-process (concat (map-slash-to-backslash cmd)
				      (when opt
					(concat " " opt))
				      " \"" (map-slash-to-backslash file) "\"")
			      :wait nil)))
	  (message "�Ȃɂ������łȂ��B"))))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �o�b�t�@�I���|�b�v�A�b�v���X�g
;;; ������������������������������������������������������������������������ ;;;

(defun bufmenu-mouse-popup (&optional apps)
  "bufmenu �|�b�v�A�b�v���X�g�\��"
  (interactive)
  (let ((menu (create-popup-menu)) submenu)
    (let ((bn (buffer-name (selected-buffer)))
	  (frame (member (ed::pseudo-frame-name (selected-pseudo-frame))
			 *bufmenu-hide-buffer-frame-list*
			 :test #'equal)))
      (save-excursion
	;; �t���[���ꗗ
	(when (and *bufmenu-use-frame-menu*
		   (< 1 (list-length ed::*pseudo-frame-list*)))
	  (dolist (pfr ed::*pseudo-frame-list*)
	    (let ((item (ed::pseudo-frame-name pfr)))
	      (when (zerop (string/= item " "))
		(add-menu-item menu nil
			       (concat "[ " item " ]")
			       #'(lambda () (interactive)
				   (select-pseudo-frame (find-pseudo-frame item)))
			       #'(lambda ()
				   (when (string=
					  item
					  (ed::pseudo-frame-name (selected-pseudo-frame)))
				     :check))))))
	  (add-menu-separator menu nil))
	;; �Ă�ۂ��o�b�t�@�ꗗ
	(dolist (buffer (buffer-list))
	  (bufmenu-add-menu-item menu buffer bn frame 1))
	;; �o�b�t�@�ꗗ
	(if *bufmenu-use-file-name*
	    (dolist (buffer (sort (buffer-list) #'string< :key #'get-buffer-file-name))
	      (bufmenu-add-menu-item menu buffer bn frame))
	  (dolist (buffer (buffer-list))
	    (bufmenu-add-menu-item menu buffer bn frame)))
	;; ��\���o�b�t�@�ꗗ
	(when (< 1 (list-length (let (lst)
				  (dolist (buf (buffer-list))
				    (let ((bn (buffer-name buf)))
				      (unless (zerop (string/= bn " "))
					(push bn lst))))
				  lst)))
	  (setq submenu (create-popup-menu))
	  (dolist (buffer (buffer-list))
	    (bufmenu-add-menu-item submenu buffer bn frame -1)))))
    (add-menu-separator menu nil)
    (when submenu
      (add-popup-menu menu submenu "��\���o�b�t�@(&H)"))
    (unless *bufmenu-hide-option-menu*
      ;; �ݒ胁�j���[
      (add-popup-menu menu
		      (define-popup-menu
			(:item nil "�t���[�����\��(&F)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-use-frame-menu*
				   (not *bufmenu-use-frame-menu*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-use-frame-menu* :check)))
			(:item nil "�t�@�C�����ŕ\��(&N)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-use-file-name*
				   (not *bufmenu-use-file-name*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-use-file-name* :check)))
			(:item nil "��\���o�b�t�@�ȊO�͊���̃t���[���ŕ\��(&S)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-switch-pseudo-frame*
				   (not *bufmenu-switch-pseudo-frame*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-switch-pseudo-frame* :check)))
			)"�\���ݒ�(&S)"))
    (track-popup-menu menu (or apps :button2))))

;;; type: -1:hide, 0:normal, 1:temp
(defun bufmenu-add-menu-item (menu buffer bn frame &optional (type 0))
  "bufmenu ���j���[�A�C�e���̒ǉ�"
  (let ((item (buffer-name buffer))
	(fn (get-buffer-file-name buffer)))
    (when (and (string/= item " *Minibuf0*")
	       (cond ((zerop type)
		      (and (zerop (string/= item "*"))
			   (zerop (string/= item " "))))
		     ((plusp type)
		      (not (zerop (string/= item "*"))))
		     ((minusp type)
		      (not (zerop (string/= item " "))))))
      (add-menu-item menu nil
		     (if *bufmenu-use-file-name*
			 (or fn item)
		       item)
		     #'(lambda () (interactive)
			 (when (and frame
				    *bufmenu-switch-pseudo-frame*
				    (not (string-match "^ " item)))
			   (select-pseudo-frame (find-pseudo-frame *bufmenu-default-frame*)))
			 (switch-to-buffer item))
		     #'(lambda ()
			 (when (string= item (buffer-name (selected-buffer)))
			   :check))))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �o�b�t�@�o�[�R���e�N�X�g���j���[�Ƀ��j���[��ǉ�
;;; ������������������������������������������������������������������������ ;;;

(defun bufmenu-add-buffer-bar-context-menu ()
  (run-hooks '*bufmenu-add-context-menu-pre-hook*)
  (when *use-buffer-bar-context-menu*
    (flet ((bn  () (buffer-name *buffer-bar-context-menu-buffer*))
	   (bfn () (get-buffer-file-name *buffer-bar-context-menu-buffer*))
	   (sb  () (bufmenu-switch-to-buffer (buffer-name *buffer-bar-context-menu-buffer*)))
	   ;; �o�b�t�@�̃t�@�C�������x�[�X�ɐV�����t�@�C�������擾
	   (newfile ()
	     (let* ((newpathfile (read-file-name "�V�����t�@�C����: "
						 :default (get-buffer-file-name))))
	       (if (file-exist-p newpathfile)
		   (progn
		     (message-box "~A ~A" newpathfile " �͂���������")
		     nil)
		 newpathfile)))
	   ;; �o�b�t�@���t�@�C�����Q�Ƃ��Ă��Ȃ���� :disable
	   (chkbfn ()
	     (unless (get-buffer-file-name *buffer-bar-context-menu-buffer*)
	       :disable)))
      (let (menu)
	(setq menu *buffer-bar-context-menu*)
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "����ȊO�����(&W)"   'bufmenu-close-other-buffers)
	(add-menu-item menu nil "���ׂĕ���(&*)" 'bufmenu-kill-all-buffers)
	(add-menu-item menu nil "�����荶�����(&<)" 'bufmenu-close-left-buffers)
	(add-menu-item menu nil "������E�����(&>)" 'bufmenu-close-right-buffers)
	;------------------------------
;; 	(add-menu-separator menu)
;; 	(add-menu-item menu nil "Switch to buffer(&S)"
;; 		       #'(lambda () (interactive)
;; 			   (bufmenu-switch-to-buffer (bn))))
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "����(&T)..."
		       #'(lambda () (interactive)
			   (bufmenu-sendto-dialog (bfn)))
		       #'chkbfn)
	(add-menu-item menu nil "�t�@�C�������s(&X)"
		       #'(lambda () (interactive) (shell-execute (bfn)))
		       #'chkbfn)
	;------------------------------
	(run-hooks '*bufmenu-add-context-menu-middle-hook*)
	;------------------------------
	(add-menu-separator menu)
	(add-popup-menu menu
			(define-popup-menu
			  (:item nil "�t�@�C������ύX(&R)"
			   #'(lambda () (interactive) (sb)
			       (let (f nf)
				 (setq f (get-buffer-file-name))
				 (setq nf (newfile))
				 (when (ignore-errors (rename nf))
				   (save-buffer)
				   (delete-file f)
				   (message "~A ~A" nf " �Ƀ��l�[�����܂���"))))
			   #'chkbfn)
			  (:item nil "�t�@�C�����R�s�[���ĊJ��(&O)"
			   #'(lambda () (interactive) (sb)
			       (let (nf)
				 (setq nf (newfile))
				 (when nf
				   (copy-file (get-buffer-file-name) nf)
				   (find-file nf)
				   (message "~A ~A" nf " �ɃR�s�[���܂���"))))
			   #'chkbfn)
			  :sep
			  (:item nil "�t�@�C�����폜(&D)"
			   #'(lambda () (interactive) (sb)
			       (let (f)
				 (setq f (get-buffer-file-name))
				 (and (no-or-yes-p "~A ~A" f "���폜���܂��B")
				      (when (delete-file f)
					(delete-buffer (selected-buffer))
					(message "~A ~A" f  " ���폜���܂���")))))
			   #'chkbfn)
			  ) "�t�@�C������(&F)")
	;------------------------------
	(add-popup-menu menu
			(define-popup-menu
			  (:item nil "�o�C�g�R���p�C��(&C)"
			   #'(lambda () (interactive) (byte-compile-file (bfn)))
			   #'(lambda ()
			       (unless (equal (ignore-errors (pathname-type (bfn))) "l")
				 :disable)))
			  :sep
			  (:item nil "Eval buffer(&E)"
			   #'(lambda () (interactive)
			       (eval-buffer *buffer-bar-context-menu-buffer*)))
			  (:item nil "Load(&L)"
			   #'(lambda () (interactive) (load (bfn)))
			   #'chkbfn)
			  ) "Lisp(&L)")
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "�o�b�t�@�����R�s�[(&B)"
		       #'(lambda () (interactive) (copy-to-clipboard (bn))))
	(add-menu-item menu nil "�t�@�C����(/)���R�s�[(&R)"
		       #'(lambda () (interactive) (copy-to-clipboard (bfn)))
		       #'chkbfn)
	(add-menu-item menu nil "�t�@�C����(\\)���R�s�[(&F)"
		       #'(lambda () (interactive)
			   (copy-to-clipboard (map-slash-to-backslash (bfn))))
		       #'chkbfn)
	)))
  (run-hooks '*bufmenu-add-context-menu-hook*))

;;; �N�����Ƀo�b�t�@�o�[�R���e�N�X�g���j���[�ɒǉ������s
(add-hook '*init-app-menus-hook* #'bufmenu-add-buffer-bar-context-menu)


;;; bufmenu.l ends here.