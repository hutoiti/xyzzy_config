;;; -*- Mode: Lisp; Package: USER; Last modified: "2006/05/14 23:33:25" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;  chcolor.l --- �o�b�t�@�́u�\���F�v��ؑւ�
;;;

;;;  �T�v:
;;;
;;;    xyzzy Part7 348, 354, 355, 361, 374 ����C����сC
;;;    xyzzy�̎g�������킩��ʃ��V��܂���������2 959 ����
;;;    �̐F�ݒ�� xyzzy Part7 420 ����̕��@�ŕύX���Ď���
;;;    �Ă݂�B
;;;
;;;    �ݒ�t�@�C����ǂݏ������邠������n�߁A���낢���
;;;    SANO Masatoshi ����ɂ������Ē����܂����B

;;;  �C���X�g�[��:
;;;
;;;    1. �f�B���N�g�� chcolor �� ~/site-lisp �ɃR�s�[����B
;;;
;;;    2. .xyzzy �Ƃ��Ɉȉ��̋L�q��ǉ�����B
;;;
;;;        (load-library "chcolor/chcolor")

;;;  �g����:
;;;
;;;    �E�\���F��I��������A�\���F��ύX
;;;
;;;        M-x chcolor
;;;
;;;      [�\���F�ύX]
;;;         �\���F�ݒ�p�^�[�����t�@�C������I�����A���݃o�b�t�@�ɔ��f
;;;         ������B
;;;
;;;      [����F�ɖ߂�]
;;;         xyzzy.ini �ɐݒ肳��Ă���p�^�[���ŕ\�����āA������J���o�b
;;;         �t�@�́Achcolor �ɂ��ύX�͍s��Ȃ��悤�ɂ���B
;;;
;;;      [������J���o�b�t�@���ύX]
;;;         �ݒ肵���p�^�[����������J���o�b�t�@�ɂ��K�p���邩�ǂ�����
;;;         �ؑւ��B
;;;
;;;      [��ɑS�Ẵo�b�t�@��ύX]
;;;         �\���F�ύX���́A��ɑS�Ẵo�b�t�@��ύX���邩�ǂ����̐ؑւ��B
;;;
;;;      [�\���F���t�@�C���֕ۑ�]
;;;         ���ݐݒ肳��Ă���\���F�p�^�[�����t�@�C���ɏ����o���B
;;;
;;;      [�\���F�ύX�I��]
;;;         ������J���o�b�t�@�́Achcolor �ɂ��ύX�͍s��Ȃ��悤
;;;         �ɂ���B
;;;
;;;    �E�p�^�[���t�@�C����I�����āA�\���F��ύX
;;;
;;;        �ǂ�������Achcolor-specify-file �����s����B

;;;  �ݒ��:
;;;
;;;    �E�L�[�o�C���h
;;;
;;;       (global-set-key #\M-e 'chcolor)
;;;
;;;      �Ƃ��B
;;;
;;;    �E�p�^�[���ԍ����w�肵�āA�\���F��ύX
;;;
;;;        ese-fortune(V1.07 �ȍ~)�ł́A�u�����v�ɂ���B
;;;
;;;          (add-hook '*ese-fortune-mode-hook*
;;;               #'(lambda () (chcolor-specify-file "����")))

;;;  �� ���C�Z���X
;;;  
;;;    chcolor.l �� NYSL Version 0.9982 �ɏ]���܂��B
;;;  
;;;      NYSL - http://www.kmonos.net/nysl/
;;;  
;;;    A. �{�\�t�g�E�F�A�� Everyone'sWare �ł��B���̃\�t�g����ɂ�����l��l���A
;;;       �������̍�������̂������̂Ɠ����悤�ɁA���R�ɗ��p���邱�Ƃ��o���܂��B
;;;  
;;;      A-1. �t���[�E�F�A�ł��B��҂���͎g�p������v�����܂���B
;;;      A-2. �L��������}�̂̔@�����킸�A���R�ɓ]�ځE�Ĕz�z�ł��܂��B
;;;      A-3. �����Ȃ��ނ� ���ρE���v���O�����ł̗��p ���s���Ă��\���܂���B
;;;      A-4. �ύX�������̂╔���I�Ɏg�p�������̂́A���Ȃ��̂��̂ɂȂ�܂��B
;;;           ���J����ꍇ�́A���Ȃ��̖��O�̉��ōs���ĉ������B
;;;  
;;;    B. ���̃\�t�g�𗘗p���邱�Ƃɂ���Đ��������Q���ɂ��āA��҂�
;;;       �ӔC�𕉂�Ȃ����̂Ƃ��܂��B�e���̐ӔC�ɂ����Ă����p�������B
;;;  
;;;    C. ����Ґl�i���� HIE Masahiro�CSANO Masatoshi �ɋA�����܂��B���쌠
;;;       �͕������܂��B
;;;  
;;;    D. �ȏ�̂R���́A�\�[�X�E���s�o�C�i���̑o���ɓK�p����܂��B

;;;  �X�V����:
;;;
;;;    [Version 1.02] 2006/05/14 (��)
;;;    �EWindows XP �ŐF�ݒ�̕ۑ����ł��Ȃ��Ȃ��Ă����̂��C�������B
;;;      �ēc����Ɋ��ӁB
;;;    �E���C�Z���X��K�p�����B
;;;
;;;    [Version 1.01] 2002/12/10 (��)
;;;    �E����F���t�@�C���ɕۑ��ł��Ȃ��Ȃ��Ă����̂��C�������B
;;;    �E�\���F�ύX���P�x�ł����s������ɁA�ǂ����� hook �ŁA
;;;      chcolor-specify-file �����s����ƁA����ȍ~�̃o�b�t�@�ŁA
;;;      �����̈Ӑ}�����\���F�łȂ��Ȃ��Ă��܂��̂��C�������B
;;;
;;;    [Version 1.00] 2002/12/03 (��)
;;;    �Echcolor �Ƃ����B

(provide "chcolor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign"))

(defvar *chcolor-refresh-next-buffer* t
  "chcolor: ������J���o�b�t�@���ύX")

(defvar *chcolor-refresh-all* t
  "chcolor: ��ɑS�Ẵo�b�t�@��ύX")

(defvar *chcolor-ini-dir* (concat (si:system-root) "site-lisp/chcolor/ini/")
  "chcolor: �\���F�p�^�[���ݒ�t�@�C���̕ۑ��ꏊ")

(defvar *chcolor-table* nil
  "chcolor: �\���F�p�^�[��")

(defvar *chcolor-keylist*
  '("textColor" "backColor" "ctlColor" "selectionTextColor" "selectionBackColor"
    "kwdColor1" "kwdColor2" "kwdColor3" "stringColor" "commentColor" "tagColor"
    "cursorColor" "caretColor" "imeCaretColor" "linenum" "reverse"
    "unselectedModeLineFg" "unselectedModeLineBg" "modeLineFg" "modeLineBg")
  "chcolor: ini file �̃L�[�̃��X�g")

(defvar *chcolor-menu* nil)

(defun chcolor-init ()
  "chcolor: menu �̍X�V"
  (setq *chcolor-menu*
	(define-popup-menu
	  ;----------------------------------------------------------------------------
	  (:item nil "�\���F�ύX(&O)" 'chcolor-select-file)
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "���o�b�t�@������F�ɖ߂�(&D)"
	   #'(lambda ()(interactive)(set-buffer-colors nil)))
	  (:item nil "�S�o�b�t�@������F�ɖ߂�(&R)"
	   #'(lambda ()(interactive)(setq *chcolor-table* nil)(chcolor-set -1 t)))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "������J���o�b�t�@���ύX(&N)" 'chcolor-toggle-refresh-next-buffer
	   #'(lambda ()(and *chcolor-refresh-next-buffer* :check)))
	  (:item nil "��ɑS�Ẵo�b�t�@��ύX(&A)" 'chcolor-toggle-refresh-all
	   #'(lambda ()(and *chcolor-refresh-all* :check)))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "�\���F���t�@�C���֕ۑ�(&S)"
	   #'(lambda ()(interactive)
	       (chcolor-set)(refresh-screen)
	       (and (yes-or-no-p "���ݕ\���F���t�@�C���ɕۑ����܂���B")
		    (chcolor-save-to-ini
		     (read-file-name "FileName: " :default *chcolor-ini-dir*)
		     *chcolor-keylist*))))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "�\���F�ύX�I��(&Q)"
	   #'(lambda ()(interactive)(setq *chcolor-table* nil)(chcolor-stop-hook))
	   #'(lambda ()(unless *chcolor-table* :disable)))
	  ;----------------------------------------------------------------------------
	  )))

(defun chcolor ()
  (interactive)
  (unless *chcolor-menu* (chcolor-init))
  (track-popup-menu *chcolor-menu*))

(defun chcolor-select-file ()
  "chcolor: �ݒ�t�@�C����I�����\���F��ύX"
  (interactive)
  (toggle-ime nil)
  (multiple-value-bind (file result)
      (let ((*filer-last-file-mask* '("*")))
	(filer *chcolor-ini-dir* nil "�\���F�p�^�[���̑I��" nil))
    (when result
      (unless (file-directory-p file)
	(let (nextbuf)
	  (if *chcolor-refresh-next-buffer* (setq nextbuf 1)(setq nextbuf -1))
	  (setq *chcolor-table* (chcolor-load-from-ini file *chcolor-keylist*))
	  (chcolor-set nextbuf *chcolor-refresh-all*))))))

(defun chcolor-set (&optional nextbuf all)
  "chcolor: �\���F�p�^�[�����g���ĕ\���F��ύX"
  (let (tbl)
    (if *chcolor-table*
	(setq tbl (make-array 20 :initial-contents *chcolor-table*))
      (setq tbl nil))
    (if all
	(let ((sb (buffer-name (selected-buffer))))
	  (dolist (buf (buffer-list))
	    (set-buffer buf)(set-buffer-colors tbl))
	  (set-buffer sb))
      (set-buffer-colors tbl))
    (when nextbuf
      (cond ((= nextbuf  1)(chcolor-start-hook))
	    ((= nextbuf -1)(chcolor-stop-hook))))))

(defun chcolor-specify-file (file)
  "chcolor: �ݒ�t�@�C�����w�肵�ĕ\���F��ύX"
  (let (tbl pn)
    (if file
	(progn (setq pn (merge-pathnames file *chcolor-ini-dir*))
	  (when (file-exist-p pn)
	    (setq tbl (make-array 20 :initial-contents
				  (chcolor-load-from-ini pn *chcolor-keylist*)))))
      (setq tbl nil))
    (set-buffer-colors tbl)))

(defun chcolor-toggle-refresh-next-buffer ()
  "chcolor: ������J���o�b�t�@���ύX���邩�ǂ����̐ؑւ�"
  (interactive)
  (if *chcolor-refresh-next-buffer*
      (setq *chcolor-refresh-next-buffer* nil)
    (progn
      (setq *chcolor-refresh-next-buffer* t)(chcolor-set))))

(defun chcolor-toggle-refresh-all ()
  "chcolor: ��ɑS�Ẵo�b�t�@��ύX���邩�ǂ����̐ؑւ�"
  (interactive)
  (if *chcolor-refresh-all*
      (setq *chcolor-refresh-all* nil)
    (progn
      (setq *chcolor-refresh-all* t)(chcolor-set nil t))))

(defun chcolor-start-hook ()
  "chcolor: ������J���o�b�t�@�ɂ� chcolor ��K�p"
  (add-hook '*fundamental-mode-hook* 'chcolor-hook))

(defun chcolor-stop-hook ()
  "chcolor: ������J���o�b�t�@�ɂ� chcolor ��K�p���Ȃ��悤��"
  (delete-hook '*fundamental-mode-hook* 'chcolor-hook))

(defun chcolor-hook ()
  (and *chcolor-refresh-next-buffer* (chcolor-set)))


(let ((dll "kernel32"))
  (c:define-dll-entry c:int chcolor-get-private-profile-string-a
    ((c:char *) (c:char *) (c:char *) (c:char *) c:int (c:char *))
    dll "GetPrivateProfileStringA")
  (c:define-dll-entry c:int chcolor-write-private-profile-string-a
    ((c:char *) (c:char *) (c:char *) (c:char *))
    dll "WritePrivateProfileStringA"))

(defun chcolor-get-private-profile-string (App Key Def Size File)
  "chcolor: ini file ����l���擾"
  (let ((chunk (si:make-chunk nil Size)))
    (chcolor-get-private-profile-string-a (si:make-string-chunk App)
			      (si:make-string-chunk Key)
			      (si:make-string-chunk Def)
			      chunk
			      Size
			      (si:make-string-chunk File))
    (si:unpack-string chunk 0)))

(defun chcolor-write-private-profile-string (App Key Str File)
  "chcolor: ini file �֒l��ۑ�"
  (chcolor-write-private-profile-string-a (si:make-string-chunk App)
			      (si:make-string-chunk Key)
			      (si:make-string-chunk Str)
			      (si:make-string-chunk File)))

(defun chcolor-load-from-ini (file kl)
  "chcolor: ini file ����\���F�p�^�[�����擾"
  (mapcar #'(lambda (str)
	      (let ((ret 0))
		(setq str (string-downcase
			   (chcolor-get-private-profile-string "Colors" str "#0" 100 file)))
		(dotimes (i (length str))
		  (cond
		   ((lower-case-p (char str i))
		    (setq ret (* 16 (+ ret(- (char-code (char str i)) 87)))))
		   ((digit-char-p (char str i))
		    (setq ret (* 16 (+ ret(- (char-code (char str i)) 48)))))))
		(setq ret (/ ret 16))))
	  kl))

(defun chcolor-save-to-ini (file kl)
  "chcolor: ini file �֕\���F�p�^�[����ۑ�"
  (let ((tw))
    (if *chcolor-table* (setq tw *chcolor-table*)
      (setq tw (chcolor-load-from-ini (chcolor-get-xyzzy-ini-name) kl)))
    (mapcar #'(lambda (Key Val)
		(chcolor-write-private-profile-string "Colors"  Key (format nil "#~X" Val) file))
	    kl tw)))

(defun chcolor-get-xyzzy-ini-name ()
  "chcolor: xyzzy.ini �̃t���p�X���擾"
  (merge-pathnames "xyzzy.ini" (user-config-path)))


;;;
;;;  End of chcolor.l
;;;