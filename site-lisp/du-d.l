;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:15:06> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   du-d.l --- �f�B���N�g�����̃T�C�Y���o��
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  OHKUBO Hiroshi ����� insert-directory-tree.l ���Q�l�ɁA�f�B���N
  �g�����̃T�C�Y���o�͂�����̂������Ă݂��B


���C���X�g�[��

  1. du-d.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����A�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (load-library "du-d")


���g����

  �E�w��f�B���N�g���ȉ��̊e�f�B���N�g���̃T�C�Y���o��

      M-x dud

  �E�w��f�B���N�g���ȉ��̊e�f�B���N�g���ƃt�@�C���̃T�C�Y���o��

      M-x dud-all

  �E�w��f�B���N�g���ȉ��̊e�f�B���N�g���̃T�C�Y���c���[�`���ŏo��

      M-x dud-tree

  �E�w��f�B���N�g���ȉ��̊e�f�B���N�g���ƃt�@�C���̃T�C�Y���c���[�`���ŏo��

      M-x dud-tree-all


���X�V����

  [Version 1.01] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.00] 2002/12/16 (��)
  �E�������B


�����C�Z���X

  du-d.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "du-d")

(defun dud (&optional dir tree all)
  (interactive)
  (when (not dir)
    (setq dir
	  (read-directory-name "Dir: "
			       :default (if (get-buffer-file-name)
					    (directory-namestring (get-buffer-file-name))
					  (si:system-root)))))
  (message "�f�[�^���擾���Ă��܂��D�D�D")
  (long-operation
    (unless (file-directory-p dir)
      (return-from dud nil))
    (let* ((bname "*dud*")
	   (buf (progn (when (find-buffer bname)
			 (delete-buffer bname))
		  (get-buffer-create bname))))
      (set-buffer buf)
      (setq need-not-save t)
      (setq dir (append-trail-slash (map-backslash-to-slash dir)))
      (if tree
	  (progn
	    (insert (format nil "~A [~:D]~%" dir (dud-dir-size dir)))
	    (dud-expansion dir "" t all))
	(progn
	  (insert (format nil "~D	~A~%" (dud-dir-size dir) dir))
	  (dud-expansion dir "" nil all)))
      (set-buffer-modified-p nil)))
  (goto-char (point-min))
  (message "done."))

(defun dud-expansion (base-dir &optional (bstr "") tree all)
  (let (file-list dir-list last-file last-dir)
    (dolist (file (directory base-dir :absolute t))
      (if (string-match "/$" file)
	  (push (string-right-trim "/" file) dir-list)
	(when all (push file file-list))))
    (setq dir-list (stable-sort dir-list #'string-lessp))
    (setq last-dir (car (last dir-list)))
    (when all
      (setq file-list (stable-sort file-list #'string-lessp))
      (setq last-file (car (last file-list)))
      (dolist (file file-list)
	(let ((f (file-namestring file))
	      (flen (file-length file)))
	  (if tree
	      (if (and (eq file last-file) (not dir-list))
		  (insert (format nil "~A~A ~A --- [~:D]~%" bstr "��" f flen))
		(insert (format nil "~A~A ~A --- [~:D]~%" bstr "��" f flen)))
	    (insert (format nil "~D	~A~%" flen file))))))
    (dolist (dir dir-list)
      (message "scaning ~A ..." dir)
      (let ((d (substitute-string dir (directory-namestring dir) ""))
	    (dsize (dud-dir-size dir)))
	(if tree
	    (progn
	      (insert (format nil "~A~A~%" bstr "�b"))
	      (if (eq dir last-dir)
		  (progn
		    (insert (format nil "~A~A ~A/ [~:D]~%" bstr "��" d dsize))
		    (dud-expansion dir (concat bstr "   ") t all))
		(progn
		  (insert (format nil "~A~A ~A/ [~:D]~%" bstr "��" d dsize))
		  (dud-expansion dir (concat bstr "�b ") t all))))
	  (progn
	    (insert (format nil "~D	~A/~%" dsize dir))
	    (dud-expansion dir nil nil all)))))))

(defun dud-dir-size (dir)
  (let (dir-list (total-size  0))
    (setq dir-list (directory dir
			      :wile "*.*"
			      :absolute t
			      :file-only t
			      :recursive t
			      :show-dots t))
    (dolist (f dir-list)
      (setq total-size (+ total-size (file-length f))))
    total-size))

(defun dud-all (&optional dir)
  (interactive)
  (dud dir nil t))

(defun dud-tree (&optional dir)
  (interactive)
  (dud dir t))

(defun dud-tree-all (&optional dir)
  (interactive)
  (dud dir t t))


;;; du-d.l ends here.