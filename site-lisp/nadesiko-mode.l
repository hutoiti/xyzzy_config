;;; -*- Mode: Lisp; Package: USER; Last modified: "2007/12/31 01:12:21"; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   nadesiko-mode.l --- �Ȃł������[�h
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  ���{��v���O���~���O���� �Ȃł��� (http://nadesi.com/) �ҏW�p��
  ���W���[���[�h�ł��B


���C���X�g�[��

  1. nadesiko-mode.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����C�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "nadesiko-mode")
      (pushnew '("\\.nako" . nadesiko-mode) *auto-mode-alist* :test 'equal)

  4. xyzzy ���ċN�����C�ݒ�𔽉f������B
     siteinit.l �ɋL�q�����ꍇ�͍ă_���v������B


���L�[�o�C���h



���ݒ��

  ;;; �Ȃł����� C:/nadesiko/ �ɃC���X�g�[�������ꍇ
  (defvar *nadesiko-path* "C:/nadesiko/")


�����ӎ���

�E���j���[�� [���s] �́C�o�b�t�@�̃f�[�^���ۑ�����Ă���K�v������܂��B
  ���ۑ����Ɏ��s����Ɓu�t�@�C���ɕۑ�����H�v�Ɩ₢�����܂��B������ "��
  ����" ��I������Ǝ��s����܂���B�������C[�I��͈͂܂���1�s���s]���g
  �p����ƁC���ۑ��̏�Ԃł����s���邱�Ƃ��ł��܂��B

�E�Ȃł����G�f�B�^�ŊJ���ĕҏW����ꍇ�́C[�r������] �� "���Ȃ�" �� 
  "�ҏW���Ă�Ƃ�����" �ɂ��Ă����Ȃ��Ƒʖڂł��B

�E������̋�؂蕶���Ƃ��āu�v��w�x���g���ƁC\ �ɂ��G�X�P�[�v��������
  ����B����ȏꍇ�́C "" �� `` ���g���Ă��������B

�E�C���f���g�Ȃ�Ăނ��������Ƃ͂ł��܂���BRET(newline) �� 
  LFD(newline-and-indent) ������ւ��Ă��邾���ł��B


���X�V����:

  [Version 1.04] 2007-12-31 (��)
  �EMIT���C�Z���X�ɂ����B
  �E�F�t�����ɁC��������ɗ\�����}�b�`������悤�ɂ����B

  [Version 1.03] ���H
  �E���p�X�y�[�X���܂ރp�X�̏������s���������̂��C�������B
  �E���݂��Ȃ��Θb�����s���폜�����B

  [Version 1.02]
  �Erequire ���Ďg���悤�ɂ����B
  �E�֐��������낢��ƕύX�����B
  �E���p�X�y�[�X 4 �ŃC���f���g����悤�ɂ����B
  �ETAB �L�[�ŃC���f���g�ł���悤�ɂ����B

  [Version 1.01] 2005-03-03 (Thu)
  �E�^�u�ŃC���f���g����悤�ɂ����B
  �Eshift-selection, unshift-selection �����ꂼ�� M-i, M-u �Ƀo�C���h�����B

  [Version 1.00] 2005-03-01 (Tue)
  �E�������B


�����C�Z���X

  nadesiko-mode.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007 HIE Masahiro

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

(provide "nadesiko-mode")

(defconstant *nadesiko-mode-version* "1.03")

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�i�K���ɃJ�X�^�}�C�Y���邠����j
;;; ������������������������������������������������������������������������ ;;;

;;; �C���X�g�[���p�X
(defvar *nadesiko-path* "C:/usr/local/nadesiko/")

;;; ���s�t�@�C����
(defvar *nadesiko-execute-file* "vnako.exe")

;;; �Ȃł��� Web Site
(defvar *nadesiko-home-url* "http://nadesi.com/")

;;; ���K�\���F�t���p�\���F
(defvar *nadesiko-comment-color* '(:keyword :comment)) ; �R�����g
(defvar *nadesiko-syntax-keyword-color* '(:color 12 0))	; �\���L�[���[�h
(defvar *nadesiko-reserve-word-color* '(:color 12 0)) ; �\���
(defvar *nadesiko-josi-color* '(:color 9 0)) ; ����
(defvar *nadesiko-brackets-color* '(:keyword :string)) ; ���ʁi������j
(defvar *nadesiko-integer-color* '(:color 12 0)) ; ���l
(defvar *nadesiko-label-color* '(:color 5 0)) ; ���x��
(defvar *nadesiko-operator-color* '(:color 4 0)) ; ���Z�q
(defvar *nadesiko-punc-color* '(:color 14 0)) ; ��Ǔ_
(defvar *nadesiko-misc-color* '(:color 14 0)) ; ���낢��

;;; �C���f���g����
(defvar *nadesiko-indent-columns* 4)

;;; �^�u�ŃC���f���g
(defvar *nadesiko-indent-tabs-mode* nil)

(defvar *nadesiko-menu-name*  "�Ȃł���(&N)")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���̑��̕ϐ��ݒ�
;;; ������������������������������������������������������������������������ ;;;

(defvar *nadesiko-app-menu* nil)
(defvar *nadesiko-command-menu* nil)
(defvar *nadesiko-mode-hook* nil)
(defvar *nadesiko-regexp-keyword-list* nil)

(defvar *nadesiko-mode-map* nil)
(unless *nadesiko-mode-map*
  (setq *nadesiko-mode-map* (make-sparse-keymap))
  (define-key *nadesiko-mode-map* #\RET 'newline-and-indent)
  (define-key *nadesiko-mode-map* #\LFD 'newline)
  (define-key *nadesiko-mode-map* #\TAB 'nadesiko-indent-line)
  (define-key *nadesiko-mode-map* '(#\C-c #\e) 'nadesiko-editor)
  (define-key *nadesiko-mode-map* '(#\C-c #\x) 'nadesiko-file-execute)
  (define-key *nadesiko-mode-map* '(#\C-c #\p) 'nadesiko-command-menu)
  (define-key *nadesiko-mode-map* '(#\C-c #\C-x) 'nadesiko-execute-partly)
  (define-key *nadesiko-mode-map* '(#\C-c #\?) 'nadesiko-version))

(defvar *nadesiko-mode-syntax-table* nil)
(unless *nadesiko-mode-syntax-table*
  (setq *nadesiko-mode-syntax-table* (make-syntax-table))
  (set-syntax-match *nadesiko-mode-syntax-table* #\( #\))
  (set-syntax-match *nadesiko-mode-syntax-table* #\( #\))
  (set-syntax-escape *nadesiko-mode-syntax-table* #\\)
  (set-syntax-string *nadesiko-mode-syntax-table* #\")
  (set-syntax-string *nadesiko-mode-syntax-table* #\`)
  (set-syntax-start-comment *nadesiko-mode-syntax-table* #\#)
  (set-syntax-end-comment *nadesiko-mode-syntax-table* #\LFD nil t)
  (set-syntax-start-multi-comment *nadesiko-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *nadesiko-mode-syntax-table* "*/")
  )

(setq *nadesiko-regexp-keyword-list*
      (compile-regexp-keyword-list
       `(
	 ;;�R�����g
	 ("\\(��\\|�f\\|'\\|//\\|��\\).*" t ((0 . ,*nadesiko-comment-color*)))
	 ;;�\���L�[���[�h
	 ("\\(�Ⴆ��\\|�J��Ԃ�\\|�J��Ԃ�\\|�߂�\\|������\\|������\\|�I���\\|�I���\\)"
	  t ((1 . ,*nadesiko-syntax-keyword-color*)))
	 ;;�\���
	 (,(concat "\\(�\��\\|��\\|���\\|�͂�\\|������\\|�����܂�\\|�L�����Z��\\|�I��\\|�I�t"
		   "\\|����\\|�i�f�V�R\\|������\\|���l\\|����\\|����\\|�ϐ�\\|�z��\\|����"
		   "\\|�n�b�V��\\|�O���[�v\\|�ϐ��錾\\|�K�v\\|�s�v\\|����\\|�Ȃ�\\|�Ȃ��"
		   "\\|��\\|��\\|����\\|�J\\|�G���[\\|�Ď�\\|��������\\|���[�v"
		   "\\|��\\|��\\|�����\\|�����\\)")
	  t ((0 . ,*nadesiko-reserve-word-color*)))
	 ;;����
	 (,(concat "\\(�łȂ����\\|�ɂ���\\|�Ȃ��\\|�Ƃ���\\|���炢\\|�Ȃ̂�\\|�܂ł�"
		   "\\|�Ȃ�\\|���\\|����\\|�܂�\\|�ق�\\|����\\|����\\|�Ȃ�\\|�Ƃ�\\|����"
		   "\\|��\\|��\\|��\\|��\\|��\\|��\\|��\\|��\\|��\\)")
	  t ((0 . ,*nadesiko-josi-color*)))
	 ("\\(?:\\([0-9�O-�X]+\\)\\(��\\)\\|[})�j]\\(��\\)\\)"
	  t ((1 . ,*nadesiko-integer-color*) (2 . ,*nadesiko-reserve-word-color*)
	     (3 . ,*nadesiko-reserve-word-color*)))
	 ;;���x��
	 ("^[������].*" t ((0 . ,*nadesiko-label-color*)))
	 ;;��Ǔ_
	 ("[][�A�C�B;]" t ((0 . ,*nadesiko-punc-color*)))
	 ;;���낢��
	 ("[][()�i�j#��\\��@���I�`����]" t ((0 . ,*nadesiko-misc-color*)))
	 ;;���Z�q
	 ("[�{�|�~���^�������������O!|&��=��]" t ((0 . ,*nadesiko-operator-color*)))
	 ("\\([ �@0-9�O-�X]+\\)\\([<>*/+^-]\\)\\([ �@0-9�O-�X]+\\)" t
	  ((1 . ,*nadesiko-integer-color*) (2 . ,*nadesiko-operator-color*) (3 . ,*nadesiko-integer-color*)))
	 ;;���ʁi������̋�؂蕶���j
	 ("\\(�u[^�v]*�v\\|�w[^�x]*�x\\)" t ((0 . ,*nadesiko-brackets-color*)))
	 ;;���l
	 ;("[^a-zA-Z]+\\([0-9]+\\)[^a-zA-Z]+" t ((1 . ,*nadesiko-integer-color*)))
	 ("[0-9�O-�X]+" t ((0 . ,*nadesiko-integer-color*)))
	 )))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �Ȃł������[�h
;;; ������������������������������������������������������������������������ ;;;

(defun nadesiko-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'nadesiko-mode)
  (setq mode-name "Nadesiko")
  (use-keymap *nadesiko-mode-map*)
  (use-syntax-table *nadesiko-mode-syntax-table*)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *nadesiko-regexp-keyword-list*)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *nadesiko-indent-tabs-mode*)
  (nadesiko-menu-update)
  (run-hooks '*nadesiko-mode-hook*))

;;; �Ȃł����G�f�B�^�ŊJ��
(defun nadesiko-editor (&optional file)
  (interactive)
  (when (or (not (buffer-modified-p))
	    (and (yes-or-no-p "�t�@�C����ۑ����܂���B")
		 (save-buffer)))
    (call-process (concat (merge-pathnames "nakopad.exe" *nadesiko-path*) " \""
			  (map-slash-to-backslash (or file (get-buffer-file-name))) "\""))))

;;; �Ȃł����t�@�C�����s
(defun nadesiko-file-execute (&optional file wait)
  (interactive)
  (if (or file
	  (not (buffer-modified-p))
	  (and (yes-or-no-p "�t�@�C����ۑ����܂���B")
	       (save-buffer)))
      (call-process (concat (merge-pathnames *nadesiko-execute-file* *nadesiko-path*) " \""
			    (map-slash-to-backslash (or file (get-buffer-file-name))) "\"")
		    :wait wait)
    (message "���s�𒆎~�����B")))

;;; �Ȃł������s
(defun nadesiko-execute (data &optional file)
  (interactive "s�Ȃł�������: ")
  (let ((f (make-temp-file-name "_" "nako" "~/")))
    (with-open-file (s f
		       :direction :output
		       :if-exists :overwrite
		       :if-does-not-exist :create)
      (format s "~A~%" data))
    (when (file-exist-p f)
      (nadesiko-file-execute f t)
      (sit-for 1)
      (delete-file f))))

;;; �ɂ���
(defun nadesiko-about ()
  (interactive)
  (message "�Ȃł������[�h for xyzzy version ~A" *nadesiko-mode-version*)
  (nadesiko-file-execute (merge-pathnames "tools/about.nako" *nadesiko-path*)))

;;; �Ȃł����������s
(defun nadesiko-execute-partly ()
  (interactive)
  (let (s e code)
    (if (pre-selection-p)
	(selection-start-end (start end)
	  (setf s start
		e end))
      (save-excursion
	(setf s (progn (goto-bol) (point))
	      e (progn (goto-eol) (point)))))
    (reverse-region s e t)
    (next-line)
    (setf code (buffer-substring s e))
    (nadesiko-execute code)))

;;; �}�j���A���\��
(defun nadesiko-manual ()
  (interactive)
  (shell-execute (merge-pathnames "index.htm" (merge-pathnames "doc" *nadesiko-path*))))

;;; �z�[���y�[�W�\��
(defun nadesiko-home ()
  (interactive)
  (shell-execute *nadesiko-home-url* t))

;;; �C���`�L�C���f���g
(defun nadesiko-indent-line (&optional arg)
  (interactive "p")
  (if (pre-selection-p)
      (if arg
	  (unshift-selection *nadesiko-indent-columns*)
	(shift-selection *nadesiko-indent-columns*))
    (let ((p (bolp))
	  (x (if arg -1 1)))
      (save-excursion
	(shift-region (progn (goto-bol) (point))
		      (progn (goto-eol) (point))
		      (* x *nadesiko-indent-columns*)))
      (when p (back-to-indentation)))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �Ȃł����R�}���h���j���[
;;; ������������������������������������������������������������������������ ;;;

;;; �R�}���h���j���[�\��
(defun nadesiko-command-menu ()
  (interactive)
  (unless *nadesiko-command-menu*
    (nadesiko-create-popup-menu))
  (track-popup-menu *nadesiko-command-menu*))

;;; command.txt ����|�b�v�A�b�v���j���[���쐬
(defun nadesiko-create-popup-menu ()
  (long-operation
    (let ((b (get-buffer-create "*nadesiko-cmd*")))
      (set-buffer b)
      (insert-file-contents
       (merge-pathnames "command.txt" (merge-pathnames "tools" *nadesiko-path*)))
      (goto-char (point-min))
      (let ((menu (create-popup-menu)) m1 m2)
	(while (not (eobp))
	  (message "�Ȃł������j���[�쐬�� ... ~D" (current-line-number))
	  (when (looking-at "^+")
	    (setf m1 (create-popup-menu))
	    (add-popup-menu menu m1
			    (buffer-substring (progn (forward-char 1) (point))
					      (progn (goto-eol) (point)))))
	  (when (looking-at "^-")
	    (setf m2 (create-popup-menu))
	    (add-popup-menu m1 m2
			    (buffer-substring (progn (forward-char 1) (point))
					      (progn (goto-eol) (point)))))
	  (when (looking-at "^|")
	    (let ((c (buffer-substring (progn (forward-char 1) (point))
				       (progn (scan-buffer ",\"") (point))))
		  (s (buffer-substring (progn (scan-buffer "\",\"" :no-dup t :tail t) (point))
				       (progn (scan-buffer "\",") (point)))))
	      (add-menu-item m2 nil (concat c "	" s)
			     #'(lambda () (interactive) (insert c)))))
	  (next-line)
	  (goto-bol))
	(delete-buffer b)
	(setf *nadesiko-command-menu* menu)))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �Ȃł����A�v�����j���[
;;; ������������������������������������������������������������������������ ;;;

(defun nadesiko-menu-update ()
  (interactive)
  (use-local-menu (nadesiko-add-menu)))

(defun nadesiko-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'ed::help)
                       *nadesiko-app-menu*
                       *nadesiko-menu-name*)
    menu))

(add-hook
 '*init-app-menus-hook*
 #'(lambda ()
     (unless *nadesiko-app-menu*
       (setq *nadesiko-app-menu*
	     (let ((menu (create-popup-menu)))
	       (add-menu-item menu nil "�Ȃł����G�f�B�^�ŊJ��(&E)" 'nadesiko-editor)
	       (add-menu-item menu nil "�Ȃł����R�}���h���j���[(&P)" 'nadesiko-command-menu)
	       (add-menu-separator menu)
	       (add-menu-item menu nil "���s(&X)" 'nadesiko-file-execute)
	       (add-menu-item menu nil "�I��͈͂܂���1�s�������s(&L)" 'nadesiko-execute-partly)
	       (add-menu-separator menu)
	       (add-popup-menu menu
			       (define-popup-menu
				 (:item nil "�W��GUI - vnako.exe(&G)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "vnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "vnako.exe") :check)))
				 (:item nil "�Ȉ�GUI - gnako.exe(&U)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "gnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "gnako.exe") :check)))
				 (:item nil "�R���\�[�� - cnako.exe(&C)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "cnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "cnako.exe") :check)))
				 ) "�Ȃł������s����(&Y)")

	  (add-menu-separator menu)
	  (add-menu-item menu nil "�}�j���A��(&H)" 'nadesiko-manual)
	  (add-menu-item menu nil "�Ȃł����̃y�[�W(&H)" 'nadesiko-home)
	  (add-menu-item menu nil "�ɂ���(&A)..."  'nadesiko-about)
	  menu)))))

(defun nadesiko-toggle-execute-file (&optional file)
  (interactive)
  (setf *nadesiko-execute-file*
	(or file (cond ((equal *nadesiko-execute-file* "vnako.exe") "gnako.exe")
		       ((equal *nadesiko-execute-file* "gnako.exe") "cnako.exe")
		       (t "vnako.exe")))))


;;; nadesiko-mode.l �́C�����܂ŁB