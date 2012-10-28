;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:15:25> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   filer-extapart.l
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  �t�@�C������A�[�J�C�u���̃t�@�C�����w�肵�ēW�J���܂��B

  �f�B���N�g�����č\�z���Ȃ��œW�J����ꍇ�A���ݑΉ����Ă���`��
  �́Alha, zip, cab, tar �� 4 �ł��B�f�B���N�g�����č\�z���Ȃ�
  ��W�J����ꍇ�́Axyzzy �̋@�\�����̂܂܎g���Ă���̂ŁAxyzzy
  ���Ή����Ă���`���Ȃ�Ή��ł��悢�Ǝv���܂��B

  �f�B���N�g���̑I���ɂ́Anonentity ����
    http://members.tripod.co.jp/zauberer/microtips/xyzzy.html
  �́A select_directory.dll �g�킹�Ē����Ă��܂��B
  �����Ă����삵�܂����A�������ق����֗��Ǝv���܂��B

  �܂��Afiler.l �̃R�[�h����������g�킹�Ē����Ă܂��B
  ����ɁAxyzzy Part7 678 �̃R�[�h���Q�l�ɂ����Ă��������܂����B


���C���X�g�[��

  1. filer-extapart.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����A�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (load-library "filer-extapart")


���g����

  �EM-e: �W�J����f�B���N�g�����w�肵�ēW�J

  �EC-e: ����̃f�B���N�g���ɓW�J


���ݒ��

  �Eselect_directory.dll ���Ȃ��ꍇ
  (setq *extapart-use-select_directory* nil)

  �E�W�J����f�B���N�g���̊���l��ύX
  (setq *extapart-base-dir* "c:/tmp")

  �E�W�J����f�B���N�g���m�F���Ɋ���̃f�B���N�g�����J��
  (setq *extapart-use-base-dir* t)

  �E�t�@�C����W�J������W�J�����f�B���N�g�����J���Ȃ�
  (setq *extapart-open-filer-after-extract* nil)


���X�V����

  [Version 1.01] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.00] 2003/05/02 (��)
  �E�������B


�����C�Z���X

  filer-extapart.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

;;; winapi ;;;
(in-package "winapi")

(*define-dll-entry int Unlha (HWND LPCSTR LPSTR DWORD) "unlha32" "Unlha")
(*define-dll-entry int Tar   (HWND LPCSTR LPSTR DWORD) "tar32"   "Tar"  )
(*define-dll-entry int UnZip (HWND LPCSTR LPSTR DWORD) "unzip32" "UnZip")
(*define-dll-entry int Cab   (HWND LPCSTR LPSTR DWORD) "cab32"   "Cab"  )

(*define-dll-entry BOOL SelectDirectory (HWND LPCSTR LPCSTR LPSTR)
		   "select_directory" "SelectDirectory")

;;; user ;;;
(in-package "user")

(defun extapart-archiver (func cmd)
  (let* ((maxlen 10240)
	 (text (si:make-chunk nil maxlen)))
    (funcall func
	     (get-window-handle)
	     (si:make-string-chunk cmd)
	     text
	     maxlen)
    (si:unpack-string text 0)))

(defun extapart-lha   (cmd) (extapart-archiver #'winapi:Unlha cmd))
(defun extapart-tar   (cmd) (extapart-archiver #'winapi:Tar   cmd))
(defun extapart-unzip (cmd) (extapart-archiver #'winapi:UnZip cmd))
(defun extapart-cab   (cmd) (extapart-archiver #'winapi:Cab   cmd))

(defun extapart-select-directory-dialog (&optional title dir)
  (let ((result (si:make-chunk nil 256))
	(d (if dir dir
	     (default-directory)))
	(s (if title title
	     "�t�H���_�̑I��")))
    (si:pack-string result 0
		    (map-slash-to-backslash
		     (remove-trail-slash d)))
    (if (= 1 (winapi:SelectDirectory (winapi:FindWindow
				      (si:make-string-chunk "#32770")
				      (si:make-string-chunk d))
				     (si:make-string-chunk s)
				     0
				     result))
	(map-backslash-to-slash (si:unpack-string result 0))
      nil)))


(defvar *extapart-base-dir* (map-backslash-to-slash
			   (get-special-folder-location :desktop)))
(defvar *extapart-use-base-dir* nil)
(defvar *extapart-open-filer-after-extract* t)
(defvar *extapart-use-select_directory* t)

(defun extract-archive-apart (&optional arg)
  (let* ((file (ed::filer-fetch-file t))
	 (todir *extapart-base-dir*)
	 (bdir (if *extapart-use-base-dir*
		   todir
		 (filer-get-directory)))
	 usedir newdir)
    (unless todir
      (setq arg t))
    (when file
      (multiple-value-bind (result data1)
	  (dialog-box
	   `(dialog 0 0 273 237
		    (:caption ,(concat "[" (file-namestring file)
				       "] : �W�J����t�@�C���̑I��"))
		    (:font 9 "�l�r �o�S�V�b�N")
		    (:control
		     (:listbox list nil #x50b10911 7 7 259 202)
		     (:button IDOK "�W�J" #x50010001 158 216 50 14)
		     (:button IDCANCEL "��ݾ�" #x50010000 216 216 50 14)))
	   (list (cons 'list
		       (long-operation
			 (mapcar #'(lambda (x)
				     (list (cadr x)
					   (format nil "~d" (caddr x))
					   (apply #'format
						  nil "~d/~2,'0d/~2,'0d ~2,'0d:~2,'0d"
						  (cadddr x))
					   (car x)))
				 (list-archive file)))))
	   '((list :column (6 -10 18 100) :must-match t :enable (IDOK))))
	(when result
	  (when arg
	    (setq todir (if *extapart-use-select_directory*
			    (extapart-select-directory-dialog
			     "�W�J����f�B���N�g�����w�肵�ĉ������B"
			     bdir)
			  (directory-name-dialog :title   "�W�J����f�B���N�g��"
						 :default bdir))))
	  (when todir
	    (multiple-value-bind (result data2)
		(dialog-box '(dialog 0 0 231 87
			      (:caption "extapart")
			      (:font 9 "�l�r �o�S�V�b�N")
			      (:control
			       (:static IDC_STATIC "�ިڸ�؍쐬(&N):" #x50020000 7 38 60 8)
			       (:edit newdir nil #x50810080 7 47 162 14)
			       (:button usedir "�ިڸ�ؕt�œW�J(&M)" #x50010003 7 70 87 10)
			       (:button IDOK "OK" #x50010001 174 7 50 14)
			       (:button IDCANCEL "��ݾ�" #x50010000 174 24 50 14)
			       (:static IDC_STATIC "�W�J��(&C):" #x50020000 7 7 50 8)
			       (:edit todir nil #x50810880 7 16 162 14)))
			    (list (cons 'todir todir)
				  '(usedir . t))
			    nil)
	      (when result
		(setq newdir (cdr (assoc 'newdir data2)))
		(setq usedir (cdr (assoc 'usedir data2)))
		(when (< 0 (length newdir))
		  (setq todir (merge-pathnames newdir todir))
		  (create-directory todir))
		(multiple-value-bind (cmd opt)
		    (extapart-select-archiver file)
		  (mapc #'(lambda (f)
			    (let ((efile (nth 3 f)))
			      (if usedir
				  (extract-archive file todir efile)
				(when cmd
				  (funcall cmd (concat opt
						       " \"" file "\""
						       " \"" (append-trail-slash todir) "\""
						       " \"" efile "\""
						       ))))))
			(cdr (assoc 'list data1))))
		(when *extapart-open-filer-after-extract*
		  (filer-set-directory todir)
		  (filer-reload nil t)
		  (filer-reload nil nil)
		  )))))))))

(defun extapart-select-archiver (file)
  (cond ((string-matchp "\\.zip$" file) (values #'extapart-unzip "-u -j -o"))
	((string-matchp "\\.cab$" file) (values #'extapart-cab   "-x -i -j -n"))
	((string-matchp (concat "\\(\\.tar"
				"\\|\\.tar\\.gz"
				"\\|\\.tar\\.bz2"
				"\\|\\.tar\\.Z"
				"\\|\\.tgz"
				"\\|\\.tbz"
				"\\|\\.taz\\)$")
			file)
	 (values #'extapart-tar "--check-all-path=1 --use-directory=0 -xfo"))
	;((string-matchp "\\.bza$" file) (values nil ""))
	;((string-matchp "\\.gza$" file) (values nil ""))
	;((string-matchp "\\.yz1$" file) (values nil ""))
	;((string-matchp "\\.7z$"  file)  (values nil ""))
	(t (values #'extapart-lha "e -a1m1n1x0p1jf0"))))


(define-key filer-keymap #\C-e 'extract-archive-apart)
(define-key filer-keymap #\M-e #'(lambda () (extract-archive-apart t)))


;;; filer-extapart.l ends here.