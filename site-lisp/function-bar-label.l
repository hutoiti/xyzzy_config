;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; function-bar-label.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:33:28 +0900>

;;; Commentary:

;; Description:
;;
;;  builtin �� set-function-bar-label ���g�����A
;;  get-function-bar-label �ł� label �擾���\�ɂ��܂��B
;;
;;  function-bar-label �ύX�̃^�C�~���O�ł̊����ݒ�̕ۑ����\��
;;  �Ȃ�܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� function-bar-label.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/function-bar-label.l
;;
;;      3. set-function-bar-label function ��p���� label ��ݒ肷��O
;;         (�T�^�I�ɂ� $XYZZY/site-lisp/siteinit.l �̐擪)�Ɉȉ��̃R�[
;;         �h��ǉ����܂��B
;;
;;              (require "function-bar-label")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. function-bar-label.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 14:30:51 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Mon, 22 Dec 2003 19:08:03 +0900
;;         �E���ō쐬�B
;;

;; Licence:
;;
;;    function-bar-label �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "function-bar-label")

(in-package "editor")

(export '(set-function-bar-label
          get-function-bar-label
          set-function-bar-label-map
          get-function-bar-label-map
          view-function-bar-label-map))

(defun function-char-p (char)
  (and (characterp char)
       (string-match "^#\\\\\\([SCM]-\\)*F[1-9][0-9]?$" (format nil "~S" char))))
(defun make-meta-char (char)
  (let (c)
    (if (characterp char)
        (setq c (read-from-string
                 (substitute-string (format nil "~S" char)
                                    "#\\\\" "#\\\\M-"))))
    c))

(defconstant *set-function-bar-label-org-func* #'set-function-bar-label)

(unless (fboundp 'get-function-bar-label)
  (let ((function-bar-label-map (make-sparse-keymap)))
    (defun set-function-bar-label (char label)
      (setq label (cond ((stringp label) label)
                        ((characterp label) (string label))
                        ((null label) (copy-string ""))
                        (t (format nil "~S" label))))
      (prog1
          (funcall *set-function-bar-label-org-func* char label)
        (define-key function-bar-label-map char label)))
    (defun get-function-bar-label (char)
      (let ((value (lookup-keymap function-bar-label-map char)))
        (cond ((stringp value) value)
              ((characterp value) (string value))
              ((null value) "")
              (t (format nil "~S" value)))))
    (defun set-function-bar-label-map (keymap)
      (when (keymapp keymap)
        (let (char)
          (dotimes (index *full-keymap-length*)
            (setq char (*keymap-index-char index))
            (when (function-char-p char)
              (set-function-bar-label char (lookup-keymap keymap char))
              (setq char (make-meta-char char))
              (set-function-bar-label char (lookup-keymap keymap char)))))))
    (defun get-function-bar-label-map ()
      (copy-keymap function-bar-label-map)))
  (si:*load-library "monkey") (gc))

(defun view-function-bar-label-map (&optional (verbose t) num)
  (interactive)
  (let ((keymap (get-function-bar-label-map)) c label)
    (cond ((null num) (setq num (number-of-function-bar-labels)))
          ((not (integerp num)) (setq num t)))
    (with-output-to-temp-buffer ("*Help*")
      (flet ((view-function-bar-label-map-1 (&optional meta-p)
               (dotimes (index *full-keymap-length*)
                 (setq c (*keymap-index-char index))
                 (when (function-char-p c)
                   (if meta-p (setq c (make-meta-char c)))
                   (setq label (lookup-keymap keymap c))
                   (if (and verbose (not (stringp label)))
                       (setq label ""))
                   (if (and (stringp label)
                            (or verbose (string/= label ""))
                            (or (eq num t)
                                (and (string-match "[1-9][0-9]*$"
                                                   (format nil "~S" c))
                                     (<= (read-from-string (match-string 0))
                                         num))))
                       (format t "~20S ~A~%" c label))))))
        (view-function-bar-label-map-1)
        (view-function-bar-label-map-1 t))))
  t)

;;; function-bar-label.l ends here