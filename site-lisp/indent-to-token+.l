#|
This file is not part of xyzzy.

  indent-to-token+.l --- token���w�肵�ăC���f���g

    by bove-crach

���T�v
  �w�肵��token���Z���N�V�����͈͂���T���o���A���̒��ōł������傫���ʒu�ɃC���f���g�𑵂��܂�

  �v�� �u�v�����܂� xyzzy�v �� Masahiro Nakano ���񂪍쐬���ꂽindent-to-token���������������ł�
  Masahiro Nakano���񑽎ӁI
        �v�����܂� xyzzy�FWebsite�͂Ȃ��悤�ł�...

���C���X�g�[��
  1. indent-to-token+.l �� site-lisp �ɃR�s�[����B
  2. �K�v�ɉ����C�o�C�g�R���p�C������B
        M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

        (require "indent-to-token+")

  �� netinstaller�œ������ꂽ���́u2.�v�ȍ~�����ő��v�ł�

���g����
  M-x indent-to-token+                       : token �̐��K�\�������ɕ����s�̌��𑵂���
  M-x indent-to-token+-just-space            : indent-to-token+ �� just-one-space ������
  M-x indent-to-token+-del-space             : indent-to-token+ �� delete-horizontal-spaces ������
  M-x indent-to-token+-right-mode            : indent-to-token+�̉E�������s��
  M-x indent-to-token+-right-mode-just-space : indent-to-token+�̉E���� �� just-one-space ������
  M-x indent-to-token+-right-mode-del-space  : indent-to-token+�̉E���� �� delete-horizontal-spaces ������
  M-x indent-to-token+interact               : indent-to-token+ �� �������[�h�ƍ폜���[�h�𕷂��Ă����

���L�[�o�C���h
  ���Ɏw�肵�Ă��܂���

���ݒ��
  Alt + i �L�[�� indent-to-token+
    (global-set-key #\M-i 'indent-to-token+)

�� ���C�Z���X

  indent-to-token+.l �� NYSL Version 0.9982 �ɏ]���܂��B

NYSL Version 0.9982
----------------------------------------

A. �{�\�t�g�E�F�A�� Everyone'sWare �ł��B���̃\�t�g����ɂ�����l��l���A
   �������̍�������̂������̂Ɠ����悤�ɁA���R�ɗ��p���邱�Ƃ��o���܂��B

  A-1. �t���[�E�F�A�ł��B��҂���͎g�p������v�����܂���B
  A-2. �L��������}�̂̔@�����킸�A���R�ɓ]�ځE�Ĕz�z�ł��܂��B
  A-3. �����Ȃ��ނ� ���ρE���v���O�����ł̗��p ���s���Ă��\���܂���B
  A-4. �ύX�������̂╔���I�Ɏg�p�������̂́A���Ȃ��̂��̂ɂȂ�܂��B
       ���J����ꍇ�́A���Ȃ��̖��O�̉��ōs���ĉ������B

B. ���̃\�t�g�𗘗p���邱�Ƃɂ���Đ��������Q���ɂ��āA��҂�
   �ӔC�𕉂�Ȃ����̂Ƃ��܂��B�e���̐ӔC�ɂ����Ă����p�������B

C. ����Ґl�i���� bove-crach �ɋA�����܂��B���쌠�͕������܂��B

D. �ȏ�̂R���́A�\�[�X�E���s�o�C�i���̑o���ɓK�p����܂��B



NYSL Version 0.9982 (en) (Unofficial)
----------------------------------------
A. This software is "Everyone'sWare". It means:
  Anybody who has this software can use it as if you're
  the author.

  A-1. Freeware. No fee is required.
  A-2. You can freely redistribute this software.
  A-3. You can freely modify this software. And the source
      may be used in any software with no limitation.
  A-4. When you release a modified version to public, you
      must publish it with your name.

B. The author is not responsible for any kind of damages or loss
  while using or misusing this software, which is distributed
  "AS IS". No warranty of any kind is expressed or implied.
  You use AT YOUR OWN RISK.

C. Copyrighted to bove-crach.

D. Above three clauses are applied both to source and binary
  form of this software.

���l�@
  �E�������T�v
  ��F
  1        10  40  50   100  400
  40       50  100 400  500  1000
  100      402220 511100 1444000 4555000 5000
  �� ���K�\����[0-9]+
  1        10     40     50      100     400
  40       50     100    400     500     1000
  100      402220 511100 1444000 4555000 5000

  �E�E�����T�v
  ��F
  1        10  40  50   100  400
  40       50  100 400  500  1000
  100      402220 511100 1444000 4555000 5000
  �� ���K�\����[0-9]+
    1          10     40      50     100   400
   40          50    100     400     500  1000
  100      402220 511100 1444000 4555000  5000

��ToDo
  �E�����̍œK��

���X�V����
  [Version 1.03] 2008.01.07
  �E�E�����ɑΉ����邽�߁A������������

  [Version 1.02] 2007/04/14
  �E�����

  [Version 1.01] 2007/03/03
  �Etoken �̐��K�\���ɃO���[�v��\(...\)������ꍇ�ɁA�ǂ̃O���[�v��indent-to���邩�����悤�ɂ���
  �Etab-columns �̋�؂�ɍ��킹��I�v�V������ǉ�
  �Eindent-to �����Ƃ��ɁA�}���������󔒂ɂ���I�v�V������ǉ�

  [Version 1.00] 2007/02/24
  �E����

|#
(provide "indent-to-token+")
(in-package "editor")

(export '(; settings
		  *indent-to-token+-nth-regexp*
		  *indent-to-token+-tab-columns*
		  *indent-to-token+-untabify*
		  ; function
		  indent-to-token+
		  indent-to-token+-just-space
		  indent-to-token+-del-space
		  indent-to-token+-right-mode
		  indent-to-token+-right-mode-just-space
		  indent-to-token+-right-mode-del-space
		  indent-to-token+interact
		  ; other
		  indent-to-token+-exec-narrow-range
		  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; settings
;; �����O���[�v���̉��Ԗڂ�indent-to�ΏۂƂ��邩�𕷂��ė~����
;; t : ����    nil : �����Ȃ�
(defvar *indent-to-token+-nth-regexp*  t)
;; ��؂��tab-columns�ɍ��킹��indent-to���ė~����
;; t : ����    nil : ���Ȃ�
(defvar *indent-to-token+-tab-columns* nil)
;; indent-to����Ƃ���tab����Ȃ��ċ󔒂���ꂽ��
;; t : �󔒂�  nil : tab��
(defvar *indent-to-token+-untabify*    t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ���܂�
;; �i���[�C���O����֐�
(defvar indent-to-token+-exec-narrow-range 'narrow-selection)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; �����psettings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; interactive function
(defun indent-to-token+-just-space ()
  "indent-to-token+ �� just-one-space ������"
  (interactive) (indent-to-token+ nil 0 1))

(defun indent-to-token+-del-space ()
  "indent-to-token+ �� delete-horizontal-spaces ������"
  (interactive) (indent-to-token+ nil 0 2))

;; �E����
(defun indent-to-token+-right-mode ()
  "indent-to-token+�̉E�������s��"
  (interactive) (indent-to-token+ nil 1))

(defun indent-to-token+-right-mode-just-space ()
  "indent-to-token+�̉E���� �� just-one-space ������"
  (interactive) (indent-to-token+ nil 1 1))

(defun indent-to-token+-right-mode-del-space ()
  "indent-to-token+�̉E���� �� delete-horizontal-spaces ������"
  (interactive) (indent-to-token+ nil 1 2))

;; �܂邿
(defun indent-to-token+interact ()
  "indent-to-token+ �� �������[�h�ƍ폜���[�h�𕷂��Ă����"
  (interactive)
  (let (arrange-mode delete-space)
	(minibuffer-prompt "�������[�h L=������ R=�E���� : ")
	(loop (case (read-char *keyboard*)
			((#\L #\l) (setf arrange-mode 0) (return t))
			((#\R #\r) (setf arrange-mode 1) (return t))
			(#\C-g     (quit))))
	(minibuffer-prompt "�폜���[�h N=�Ȃ� O=��1�� D=�󔒂Ȃ� : ")
	(loop (case (read-char *keyboard*)
			((#\N #\n) (setf delete-space 0) (return t))
			((#\O #\o) (setf delete-space 1) (return t))
			((#\D #\d) (setf delete-space 2) (return t))
			(#\C-g     (quit))))
	(indent-to-token+ nil arrange-mode delete-space)
	))

;; �{��
(defun indent-to-token+ ( &optional regexp (arrange-mode 0) (delete-space 0))
  "token �̐��K�\�������ɕ����s�̌��𑵂���"
  (interactive)
  (let (search-group data times max-data)
;;; �������K�\���A�����ʒu�A�������[�h���w�肷��
	;; ���K�\���̌���
	(unless regexp
	  (setf regexp (read-string "indent-to-token+ �������鐳�K�\�� : ")))
	(when (string= regexp "")
	  (plain-error "�������鐳�K�\�����s���ł�"))
	;; �O���[�v������ꍇ�͑�����ꏊ�����߂Ă��炤
	(if (and *indent-to-token+-nth-regexp*
			 (string-match "\\\\(.+\\\\)" regexp))
		(setf search-group (read-integer "��������O���[�v : "))
	  (setf search-group 0))
	(setf regexp (compile-regexp regexp))
;;; token�o�����X�g���쐬
	(save-excursion
	  (save-restriction
		;; �͈͎w��
		(unless (funcall indent-to-token+-exec-narrow-range)
		  (plain-error "�L���͈͂��w��ł��ĂȂ�����"))
		;; �O���[�v�w��ʒu�������Ă��邩�m�F
		(goto-char (point-min))
		(scan-buffer regexp)
		(or (match-beginning search-group)
			(match-end       search-group)
			(plain-error "�O���[�v�w�肪�Ԉ���Ă����"))
		;; �o�����擾
		(goto-char (point-min))
		(while (scan-buffer regexp)
		  (let ( start end work )
			(setf start (match-beginning  search-group))
			(setf end   (match-end        search-group))
			(setf work  (buffer-substring start end))
			(goto-char start)
			;; �폜�n�� ��������
			(cond ((= delete-space 2)
				   (delete-horizontal-spaces) (setf work (string-left-trim " \t" work)))
				  ((= delete-space 1)
				   (just-one-space) (setf work (string-left-trim " \t" work))
				   (when (string= work "") (setf work " "))))
			(setf start (point))
			(setf end (+ start (count-column work)))
			;; �폜�n�� �����܂�
			(setf work (list (current-column) (progn (goto-char (+ (point) (- end start) )) (current-column))))
			(unless (eq (current-line-number) (caar data))
			  (push (list (current-line-number) '(0 0)) data))
			(push (append (pop data) (list work)) data)
			(goto-char end)
			))))
;;; token�o�����X�g���ł��Ȃ������炱���ŏI���
	(unless data (plain-error "token�����o����܂���ł���"))
;;; token�o�������̍ő�l
	(setf times (first (sort (mapcar #'list-length data) #'>)))
;;; �ړ����錅���Z�o
	(setf max-data '(0))
	(do ((counta 2 (incf counta))
		 (work   0 (setf work (car max-data)))
		 (buf    0))
		((>= counta times) counta)
	  (mapcar #'(lambda (x)
				  (and (car (nth counta x))
					   (setf buf (+ (car max-data) (- (nth arrange-mode (nth counta x)) (nth arrange-mode (nth (1- counta) x)))))
					   (> buf work)
					   (setf work buf)))
			  data)
	  (push work max-data))
;;; �ړ��ʒu��tab���ɍ��킹��
	(when *indent-to-token+-tab-columns*
	  (let ((work 0) (work-list (cdr (reverse max-data))))
		(dotimes (counta (list-length work-list))
		  ;; �ړ����悤�Ƃ����ʒu�� tab-columns �̗]����o��
		  ;; �]�������������������tab�ʒu�Ƃ���
		  (setf work (+ (- (tab-columns) (mod (+ (nth counta work-list) work) (tab-columns))) work))
		  (setf (nth counta work-list) (+ (nth counta work-list) work)))
		(setf max-data (revappend work-list '(0)))))
	(setf max-data (reverse max-data))
;;; �ړ�
	(dolist (record data)
	  ; �Y���s�Ɉړ�
	  (goto-line (car record))
	  (do ((counta 2 (incf counta)) (diff 0) (column 0) (indent 0))
		  ((not (nth counta record)))
		(cond
		 ; ������
		 ((= arrange-mode 0)
		  (setf diff (- (nth 0 (nth counta record)) (nth 0 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (nth (- counta 1) max-data)))
		 ; �E����
		 ((= arrange-mode 1)
		  (setf diff (- (nth 0 (nth counta record)) (nth 1 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (- (nth (- counta 1) max-data) (- (nth 1 (nth counta record)) (nth 0 (nth counta record))))))
		 ; �Y���Ȃ��̏ꍇ�͍���������
		 ; ���������Ƃ��[���C���f���g�Ƃ��F�X�ł���������Ȃ�
		 (t
		  (setf diff (- (nth 0 (nth counta record)) (nth 0 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (nth (- counta 1) max-data)))
		 )
		(goto-column column)
		(indent-to indent)
		(when *indent-to-token+-untabify*
		  (untabify (point) (- (point) indent)))
		)
	  )
	))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; static function
(defun narrow-selection ()
  "�Z���N�V�����͈͂��i���[�C���O����"
  (and (pre-selection-p)
	   (narrow-to-region (selection-mark) (selection-point))
	   (return-from narrow-selection t))
  nil)

(defun narrow-region ()
  "���[�W�����͈͂��i���[�C���O����"
  (and (mark t)
	   (narrow-to-region (region-beginning) (region-end))
	   (return-from narrow-region t))
  nil)

(defun narrow-region-or-selection ()
  "�Z���N�V�����͈͂��i���[�C���O����"
  (or  (narrow-selection)
	   (narrow-region)
	   (return-from narrow-region-or-selection nil))
  t)