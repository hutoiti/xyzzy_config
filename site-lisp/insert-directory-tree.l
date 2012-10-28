;;; -*- Mode: Lisp -*-
;;; insert-directory-tree.l --- �f�B���N�g���c���[�̏o��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/19 01:38:21 +0900>

;;; Commentary:

;; Description:
;;
;;  �f�B���N�g���c���[���o�͂��܂��B
;;

;; Installation:
;;
;;      1. �W�J���� insert-directory-tree.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/insert-directory-tree.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (autoload 'insert-directory-tree "insert-directory-tree" t)
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. insert-directory-tree.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Usage:
;;
;;      M-x insert-directory-tree
;;

;; Setting example:
;;
;;      (require "insert-directory-tree")
;;

;; Customize:
;;
;;      ; �t�@�C���T�C�Y���o��
;;      (setq *insert-directory-tree-leaf-function*
;;            #'(lambda (file)
;;                (unless (file-directory-p file)
;;                  (format nil "\t~D Bytes" (file-length file)))))
;;
;;      ; �t�@�C���̍X�V�������o��
;;      (setq *insert-directory-tree-leaf-function*
;;            #'(lambda (file)
;;                (unless (file-directory-p file)
;;                  (format-date-string "\t(%y/%m/%d %H:%M:%S)"
;;                                      (cadr (get-file-info file))))))
;;

;; Changes:
;;
;;      Wed, 19 Oct 2005 01:15:32 +0900
;;        �ENANRI ����̊g������荞�݁B
;;          *insert-directory-tree-leaf-function* �ɁAfile �������ɂ�
;;          �蕶�����Ԃ��֐����w�肷�邱�Ƃŏ���t���o�͂���B
;;
;;      Sat, 08 Oct 2005 14:37:47 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Sat, 08 Jan 2005 06:17:25 +0900
;;        �Ebox-fixation-mode.l �쐬�ɔ����A�c�����b(0x8162)����
;;          ��(0x84A0)�ɕύX�B
;;
;;      Sun, 13 Jun 2004 20:00:56 +0900
;;        �E�o�̓t�H�[�}�b�g�ꕔ�C���B
;;        �ENetInstaller �Ή��B
;;
;;      Tue, 04 Mar 2003 21:44:48 +0900
;;        �Ehonami ���񂩂璸���Ă������O�t�@�C�����X�g�g���𓝍��B
;;        �E�C���B
;;
;;      Fri, 19 Oct 2001 13:19:20 +0900
;;        �E�쐬
;;

;; Licence:
;;
;;    insert-directory-tree �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "insert-directory-tree")

(defvar *insert-directory-tree-ignore-list* '("^CVS/$" ".*lc$")
  "�f�B���N�g���c���[�쐬���ɖ�������t�H���_/�t�@�C���� (���K�\��) �̃��X�g")
(defvar *insert-directory-tree-verbose-p* nil
  "non-nil �Ȃ� *insert-directory-tree-ignore-list* �̎w��𖳎����ăc���[���쐬����")

(defvar *insert-directory-tree-leaf-function* nil
  "file�������ɂƂ蕶�����Ԃ��֐�")

(defun insert-directory-tree (directory)
  "�f�B���N�g���c���[���쐬"
  (interactive "*Ddirectory: "
    :default0 (if (get-buffer-file-name)
                  (directory-namestring (get-buffer-file-name))
                (si:system-root)))
  (labels ((insert-leaf (base branch &optional file directory directory-p)
             (insert (format nil "~A~A~@[ ~A~]~@[~A~]~@[~A~]~%" base branch
                             file (and directory-p "/")
                             (and file
                                  directory
                                  *insert-directory-tree-leaf-function*
                                  (funcall *insert-directory-tree-leaf-function* (merge-pathnames file directory))))))
           (insert-directory-tree-1 (base-directory &optional (base-str ""))
             (let (file-list directory-list last-file last-directory)
               (dolist (file (directory base-directory))
                 (when (or *insert-directory-tree-verbose-p*
                           (not (member file *insert-directory-tree-ignore-list*
                                        :test #'(lambda (string regexp)
                                                  (string-match regexp string)))))
                   (if (string-match "/$" file)
                       (push (string-right-trim "/" file) directory-list)
                     (push file file-list))))
               (setq file-list (stable-sort file-list #'string-lessp))
               (setq directory-list (stable-sort directory-list #'string-lessp))
               (setq last-file (car (last file-list)))
               (setq last-directory (car (last directory-list)))
               (dolist (file file-list)
                 (if (and (eq file last-file) (not directory-list))
                     (insert-leaf base-str "��" file base-directory)
                   (insert-leaf base-str "��" file base-directory)))
               (dolist (file directory-list)
                 (insert-leaf base-str "��")
                 (if (eq file last-directory)
                     (progn
                       (insert-leaf base-str "��" file base-directory t)
                       (insert-directory-tree-1 (merge-pathnames file base-directory)
                                                (concat base-str "   ")))
                   (progn
                     (insert-leaf base-str "��" file base-directory t)
                     (insert-directory-tree-1 (merge-pathnames file base-directory)
                                              (concat base-str "�� "))))))))
    (unless (file-directory-p directory)
      (return-from insert-directory-tree nil))
    (setq directory (append-trail-slash (map-backslash-to-slash directory)))
    (insert (format nil "~A~%" directory))
    (insert-directory-tree-1 directory " ")))

;;; insert-directory-tree.l ends here