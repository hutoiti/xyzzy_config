;;; -*- Mode: Lisp; Package: SORT-LINE -*-
;;; sort-line.l --- �s�\�[�g

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:58:55 +0900>

;;; Commentary:

;; Description:
;;
;;  �C�ӂ̃J�����ȍ~���L�[�Ƃ��āA�o�b�t�@�S�́^�I��͈͂̍s�̃\�[�g��
;;  �s���܂��B
;;
;;  �I��͈͂̐擪�s�ɂ��ẮA�J�[�\������`�I���̉E��̏ꍇ�������A
;;  �s�S�̂��܂܂�Ă��Ȃ��Ƃ��\�[�g�͈͂Ƃ݂Ȃ��܂��B
;;  �I��͈̖͂����s�ɂ��ẮA�J�[�\�����s���̏ꍇ�A��`�I���̍�����
;;  �ꍇ�������\�[�g�͈͂Ƃ݂Ȃ��܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� sort-line.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;         toolbar-sort-line.bmp �� $XYZZY/etc �ɃR�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/sort-line.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "sort-line")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;
;;      5. ���j���[�́u�\���v���u�c�[���o�[�v�ɒǉ�����Ă���
;;         �u�s�\�[�g�v���`�F�b�N���A�c�[���o�[��\�����܂��B
;;

;; Uninstallation:
;;
;;      1. ESC ESC (sort-line::sort-line-uninstall) �ƃ^�C�v���A
;;         sort-line.l �֘A�̏��� xyzzy ����폜���܂��B
;;
;;      2. sort-line.l �Ɋւ���L�q���폜���܂��B
;;
;;      3. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Setting example:
;;
;;      ;; �L�[�{�[�h�ł̑���̐ݒ��
;;      (require "sort-line")
;;      (global-set-key #\S-F11 'sort-line:sort-string-ascending)
;;      (set-function-bar-label #\S-F11 "sort A")
;;      (global-set-key #\S-C-F11 'sort-line:sort-string-descending)
;;      (set-function-bar-label #\S-C-F11 "sort Z")
;;      (global-set-key #\S-F12 'sort-line:sort-number-ascending)
;;      (set-function-bar-label #\S-F12 "sort 1")
;;      (global-set-key #\S-C-F12 'sort-line:sort-number-descending)
;;      (set-function-bar-label #\S-C-F12 "sort 9")
;;

;; Customize:
;;
;;      ;; �啶������������ʂ���
;;      (setq sort-line:*sort-line-case-fold* nil)
;;      ;; �啶������������ʂ��Ȃ�
;;      (setq sort-line:*sort-line-case-fold* t)
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 12:53:26 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Fri, 15 Apr 2005 00:02:42 +0900
;;        �E�R�����g�C���B
;;        �Exyzzy 0.2.2.234 �Ή�
;;          - ���p�J�i��S�p�J�i�ɕύX�B
;;        �Esort-line-uninstall �� interactive �łȂ��֐��ɕύX�B
;;
;;      Wed, 03 Mar 2004 00:12:05 +0900
;;        �ENetInstaller �Ή��B
;;        �E���̑��B
;;
;;      Fri, 08 Mar 2002 23:23:11 +0900
;;        �E��`�I��͈͂��L�[�Ƃ��ă\�[�g�ł���悤�ɁB
;;        �E�L�[�̃J�����w����\�ɁB
;;        �E�I���`���̕ϊ��R�}���h�̒ǉ��B
;;        �E���̑��B
;;
;;      Fri, 11 Jan 2002 05:33:35 +0900
;;        �Epsetq �� rotatef �ŏ��������B
;;
;;      Fri, 28 Dec 2001 22:19:07 +0900
;;        �Elisp �����Ń\�[�g���邱�ƂɈӖ��͂Ȃ��悤�ȋC������
;;          ����ǎg���Ă�����̂����J�B
;;

;; Licence:
;;
;;    sort-line �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "sort-line")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "sort-line")
    (defpackage "sort-line" (:use "lisp" "editor"))))

(in-package "sort-line")

(export '(sort-string-ascending sort-string-descending
          sort-number-ascending sort-number-descending
          sort-string-length-ascending sort-string-descending
          sort-line-tool-bar
          *sort-line-case-fold*))

(defvar *sort-line-case-fold* t
  "�啶������������ʂ��Ȃ�")

(defun sort-line (predicate &optional converter reverse nomsg)
  (let ((selection-type (get-selection-type))
        line-from   ; �擪�s
        line-to     ; �����s (�܂�)
        column-from ; �J�n�J����
        column-to)  ; �I���J���� (�܂܂Ȃ�)
    (if (not selection-type)
        (if (or nomsg
                (yes-or-no-p "~D �J�����ȍ~���L�[�Ƃ��ă\�[�g���܂����H" (current-column)))
            (setq column-from (current-column))
          (return-from sort-line nil))
      (let ((p1 (selection-point)) (p2 (selection-mark)))
        (if (> p1 p2)
            (rotatef p1 p2))
        (case selection-type
          ((1) ; �s���[�h�I��
           (setq line-from (progn (goto-char p1) (current-line-number)))
           (setq line-to
                 (progn (goto-char p2) (backward-line) (current-line-number))))
          ((2) ; �������[�h�I��
           (setq line-from (progn (goto-char p1) (current-line-number)))
           (setq line-to
                 (progn (goto-char p2) (if (bolp) (backward-line)) (current-line-number))))
          ((3) ; ��`�I��
           (let ((c1 (progn (goto-char p1) (current-column)))
                 (c2 (progn (goto-char p2) (current-column))))
             (if (< c1 c2)
                 (progn
                   (setq line-from (progn (goto-char p1) (current-line-number)))
                   (setq line-to (progn (goto-char p2) (current-line-number)))
                   (setq column-from c1)
                   (setq column-to c2))
               (progn
                 (setq line-from (progn (goto-char p1) (forward-line) (current-line-number)))
                 (setq line-to (progn (goto-char p2) (backward-line) (current-line-number)))
                 (setq column-from c2)
                 (setq column-to c1))))))))
    (sort-line-1 predicate converter reverse line-from line-to column-from column-to)))

(defun sort-line-1 (predicate converter reverse line-from line-to column-from column-to)
  (if reverse
      (setq reverse -1)
    (setq reverse 1))
  (unless line-from
    (setq line-from 1))
  (unless line-to
    (goto-char (point-max))
    (if (eobp)
        (backward-char))
    (setq line-to (current-line-number)))
  (unless column-from
    (setq column-from 0))
  (goto-line line-from)
  (let (lines key str p1 p2)
    (while (<= (current-line-number) line-to)
      (setq str (buffer-substring (point) (progn (goto-eol) (point))))
      (if (and (= column-from 0) (eq column-to nil))
          (setq key str)
        (progn
          (unless (or (>= (goto-column column-from) column-from)
                      (eolp))
            (forward-char 1))
          (setq p1 (point))
          (if column-to
              (goto-column column-to)
            (goto-eol))
          (setq p2 (point))
          (unless (<= p1 p2)
            (setq p2 p1))
          (setq key (buffer-substring p1 p2))))
      (if converter
          (setq key (funcall converter key)))
      (push (list (current-line-number) key str) lines)
      (unless (forward-line)
        (return)))
    (flet ((stable-predicate (unit-A unit-B)
             (let ((line-number-A (car unit-A))
                   (line-number-B (car unit-B))
                   (key-A (cadr unit-A))
                   (key-B (cadr unit-B)))
               (cond
                ((and (null key-A) (null key-B))
                 (< line-number-A line-number-B))
                ((null key-A) nil)
                ((null key-B) t)
                (t
                 (case (* (funcall predicate key-A key-B) reverse)
                   (1 nil)
                   (-1 t)
                   (0 (< line-number-A line-number-B))
                   (t (< line-number-A line-number-B))))))))
      (setq lines (stable-sort lines #'stable-predicate)))
    (goto-line line-from)
    (dolist (line (mapcar #'caddr lines))
      (delete-region (point) (progn (goto-eol) (point)))
      (insert line)
      (forward-line))))

(defun sort-line-cmp (str-a str-b)
  "�啶������������ʂ��ĕ������r"
  (cond
   ((string< str-a str-b) -1)
   ((string= str-a str-b)  0)
   (t 1)))

(defun sort-line-cmp-p (str-a str-b)
  "�啶������������ʂ��Ȃ��ŕ������r"
  (cond
   ((string-lessp str-a str-b) -1)
   ((string-equal str-a str-b)  0)
   (t 1)))

(defun sort-line-<=> (int-a int-b)
  "����r"
  (cond
   ((< int-a int-b) -1)
   ((= int-a int-b) 0)
   (t 1)))

(defvar *integer-regexp* (compile-regexp "^[ \t]*\\(-?[0-9]+\\)"))
(defun sort-line-convert-to-integer (str)
  "������𐮐��ɕϊ�"
  (if (string-match *integer-regexp* str)
      (parse-integer (match-string 1))
    nil))

(defun sort-line-convert-to-length (str)
  "������𕶎��񒷂ɕϊ�"
  (length str))

(defun sort-string-ascending ()
  "������ŏ����Ƀ\�[�g"
  (interactive "*")
  (sort-line (if *sort-line-case-fold*
                 #'sort-line-cmp-p #'sort-line-cmp)
             nil nil))

(defun sort-string-descending ()
  "������ō~���Ƀ\�[�g"
  (interactive "*")
  (sort-line (if *sort-line-case-fold*
                 #'sort-line-cmp-p #'sort-line-cmp)
             nil t))

(defun sort-number-ascending ()
  "�擪�̐����ŏ����Ƀ\�[�g"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-integer nil))

(defun sort-number-descending ()
  "�擪�̐����ō~���Ƀ\�[�g"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-integer t))

(defun sort-string-length-ascending ()
  "�����񒷂ŏ����Ƀ\�[�g"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-length nil))

(defun sort-string-length-descending ()
  "�����񒷂ō~���Ƀ\�[�g"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-length t))

(defun change-selection-type ()
  "�I���`���̕ύX�A�܂��̓��[�W������I���ɕϊ�"
  (interactive)
  (case (get-selection-type)
    (1 (set-selection-type 2 t))
    (2 (set-selection-type 3 t))
    (3 (set-selection-type 1 t))
    (t
     (let ((from (mark t)) (to (point)))
       (when from
         (save-restriction
           (narrow-to-region from to)
           (if (< from to)
               (progn
                 (goto-char (point-min))
                 (selection-end-of-buffer))
             (progn
               (goto-char (point-max))
               (selection-beginning-of-buffer)))
           (set-selection-type 2 t)))))))

;;; tool-bar
(defun tool-bar-update-change-selection-type ()
  (or (mark t) (get-selection-type) :disable))

(defun sort-line-tool-bar ()
  (create-tool-bar
   'sort-line-tool-bar
   (merge-pathnames "toolbar-sort-line.bmp" (etc-path))
   '(("������ŏ����Ƀ\�[�g" 0 sort-string-ascending)
     ("������ō~���Ƀ\�[�g" 1 sort-string-descending)
     ("�����ŏ����Ƀ\�[�g" 2 sort-number-ascending)
     ("�����ō~���Ƀ\�[�g" 3 sort-number-descending)
;     ("�I���`���̕ύX" 4 change-selection-type tool-bar-update-change-selection-type)
     )))

;; tool-bar �o�^
(define-command-bar 'sort-line-tool-bar "�s�\�[�g(&L)")

;;; uninstall
(defun sort-line-uninstall ()
  "sort-line �̃A���C���X�g�[��"
  (delete-command-bar 'sort-line::sort-line-tool-bar)
  (let ((package (find-package "sort-line")))
    (dolist (x (copy-list ed::*history-variable-list*))
      (if (eq (symbol-package x) package)
          (unregister-history-variable x)))))

;;; sort-line.l ends here