;;; -*- Mode: Lisp -*-
;;; popup-mode-memo.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.3
;; Time-stamp: <2005/10/08 11:48:23 +0900>

;;; Commentary:

;; Description:
;;
;;  ���[�h���̃L�[�o�C���f�B���O�⎩���Őݒ肵���������|�b�v�A�b�v�\��
;;  ���܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� popup-mode-memo.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/popup-mode-memo.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "popup-mode-memo")
;;              (global-set-key #\C-F12 'popup-mode-memo)
;;              (set-function-bar-label #\C-F12 "memo")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. popup-mode-memo.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Key bind:
;;
;;      C-F12   �����̃|�b�v�A�b�v�\��
;;

;; Setting example:
;;
;;      (require "popup-mode-memo")
;;      (global-set-key #\C-F12 'popup-mode-memo)
;;      (set-function-bar-label #\C-F12 "memo")
;;
;;      ; �ݒ�
;;      (setq *popup-mode-memo-view-minormode-bindings* t)
;;      (setq *popup-mode-memo-view-local-bindings* t)
;;      (setq *popup-mode-memo-view-global-bindings* nil)
;;      (setq *popup-mode-memo-one-side-local* nil)
;;
;;      ;------------------------------------------------------------
;;      ;; buffer-mode �Ŏw��
;;      ; �Ƃ肠��������Ă݂�
;;      (popup-mode-memo-add-bottom 'lisp-interaction-mode "�͂���" "��" "�O��")
;;      ; �擪�ɂ���Ă݂�
;;      (popup-mode-memo-add-top 'lisp-interaction-mode "�擪1" "�擪2")
;;      ; �����ɂ���Ă݂�
;;      (popup-mode-memo-add-bottom 'lisp-interaction-mode "����1" "����2")
;;      ; �㏑�����Ă݂�
;;      (popup-mode-memo-add-new 'lisp-interaction-mode "�㏑��1" "�㏑��2")
;;      ; �폜���Ă݂�
;;      (popup-mode-memo-del 'lisp-interaction-mode)
;;
;;      ;; mode-name �Ŏw��
;;      (popup-mode-memo-add-bottom "Lisp Interaction" "�͂���" "��" "�O��")
;;      (popup-mode-memo-add-top "Lisp Interaction" "�擪1" "�擪2")
;;      (popup-mode-memo-add-bottom "Lisp Interaction" "����1" "����2")
;;      (popup-mode-memo-add-new "Lisp Interaction" "�㏑��1" "�㏑��2")
;;      (popup-mode-memo-del "Lisp Interaction")
;;      ;------------------------------------------------------------
;;
;;      ;; ex.
;;
;;      (popup-mode-memo-add-new
;;       'lisp-interaction-mode
;;       "F1:           info-modoki"
;;       "F5:           �J���Ă���t�@�C���� byte-compile"
;;       "F10:          load-library ���̏�ŉ����ƑΏۃt�@�C�����J��"
;;       "C-c b:        siteinit.l ���R���p�C�����A�_���v�t�@�C��������"
;;       "C-x C-e:      �Ō�̃Z���e���X��]�� (eval-last-sexp)"
;;      )
;;
;;      (popup-mode-memo-add-new
;;       'editor::diff-mode
;;       "n:            diff-forward"
;;       "ESC Down:     diff-forward"
;;       "p:            diff-backward"
;;       "ESC Up:       diff-backward"
;;       "m:            diff-merge              (�V�����Ƀ}�[�W)"
;;       "r:            diff-merge-reverse      (����V�Ƀ}�[�W)"
;;       "u:            diff-undo"
;;       "q:            diff-quit"
;;      )
;;
;;      (popup-mode-memo-add-new
;;       "Lisp"
;;       "F1:           info-modoki"
;;       "C-x C-e:      �Ō�̃Z���e���X��]�� (eval-last-sexp)"
;;      )
;;

;; Changes:
;;
;;      [Version 0.0.0.3]
;;      Sat, 08 Oct 2005 11:12:44 +0900
;;        �ENetInstaller �Ή��B
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Fri, 18 Jan 2002 22:31:21 +0900
;;        �E�֐����ύX�B
;;          join-string-list �� popup-mode-memo-join-string-list �ɁB
;;        �E�ϐ����ύX�B
;;          popup-mode-memo-list �� *popup-mode-memo-list* �ɁB
;;
;;      [Version 0.0.0.2]
;;      Fri, 17 Aug 2001 17:00:44 +0900
;;        �E*popup-mode-memo-one-side-local* �ϐ��̒ǉ�
;;          t ���ƃ���������ꍇ
;;          *popup-mode-memo-view-local-bindings* �� t �ł�
;;          binding ��\�����Ȃ��B
;;          minor mode �̂��Ƃ��l���Ă��Ȃ�������ƓK���B
;;
;;      [Version 0.0.0.1]
;;      Fri, 17 Aug 2001 11:53:06 +0900
;;        �E�����܂Ƃ��ɂ��Č��J
;;
;;      [Version 0.0.0.0]
;;        �E�Ƃ肠���������Ă݂�
;;

;; Memo
;;
;;      �Eminor mode �ɑ΂��郁�����������Ă��Ȃ��B
;;      �E�ǂ̃��[�h�ɂ����� (global) �̃������K�v�������B
;;

;; Licence:
;;
;;    popup-mode-memo �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "popup-mode-memo")

(defconstant *popup-mode-memo-version* "0.0.0.3"
  "popup-mode-memo: �o�[�W����")

;;------------------------------------------------------------------------------
(defvar *popup-mode-memo-view-minormode-bindings* t
  "popup-mode-memo: �}�C�i�[���[�h�̃L�[�o�C���f�B���O�\��")
(defvar *popup-mode-memo-view-local-bindings* t
  "popup-mode-memo: ���[�J�����[�h�̃L�[�o�C���f�B���O�\��")
(defvar *popup-mode-memo-view-global-bindings* nil
  "popup-mode-memo: �O���[�o���ȃL�[�o�C���f�B���O�\��")

(defvar *popup-mode-memo-one-side-local* nil
  "popup-mode-memo: ���[�J�����[�h�Ƀ���������ꍇ binding �̕\���Ȃ�")
;;------------------------------------------------------------------------------

(defvar *popup-mode-memo-list* nil
  "popup-mode-memo: popup-mode-memo �̃��X�g")

(defun popup-mode-memo ()
  "popup-mode-memo: mode ���̃����� popup �\��"
  (interactive)
  (let ((local (local-keymap))
        (global *global-keymap*)
        (minor (minor-mode-map))
        (shadow nil)
        (memo-string "")
        (local-memo-existp nil)
        (need-separator nil))
    (long-operation
      (setq memo-string (concat memo-string (format nil "======== [(~A)/~A] ========\n" mode-name buffer-mode)))
      ;; mode-name ���� memo
      (let ((tmp (popup-mode-memo-string-mode-name mode-name)))
        (when tmp
          (setq need-separator t)
          (setq memo-string (concat memo-string tmp))
          (setq local-memo-existp t)))
      ;; buffer-mode ���� memo
      (let ((tmp (popup-mode-memo-string-buffer-mode buffer-mode)))
        (when tmp
          (when need-separator
            (setq memo-string (concat memo-string "\n------------------------------\n")))
          (setq need-separator t)
          (setq memo-string (concat memo-string tmp))
          (setq local-memo-existp t)))
      (message "Building binding list...")
      ;; minor mode bindings
      (when (and *popup-mode-memo-view-minormode-bindings* minor)
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (setq memo-string (concat memo-string (format nil "Minor Mode Bindings:~%key\t\tbinding~%---\t\t-------")))
        (mapc #'(lambda (x)
                  (setq memo-string (concat memo-string (describe-bindings-1-string "" x shadow)))
                  (push x shadow))
              minor)
        (setq memo-string (concat memo-string "\n")))
      ;; mode bindings
      (when (and *popup-mode-memo-view-local-bindings*
                 (not (and *popup-mode-memo-one-side-local* local-memo-existp)))
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (setq memo-string (concat memo-string (format nil "Local Bindings:~%key\t\tbinding~%---\t\t-------")))
        (setq memo-string (concat memo-string (describe-bindings-1-string "" local shadow))))
      ;; global bindings
      (when *popup-mode-memo-view-global-bindings*
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (push local shadow)
        (setq memo-string (concat memo-string (format nil "~%Global Bindings:~%key\t\tbinding~%---\t\t-------")))
        (setq memo-string (concat memo-string (describe-bindings-1-string "" global shadow))))
      (message "Building binding list...done")
      (popup-string memo-string (point)))))

(defun popup-mode-memo-add-bottom (mode &rest memo-list)
  "popup-mode-memo: mode �ɑ΂��郁���𖖔��ɒǉ�"
  (interactive)
  (let ((existp nil))
    (dolist (mode-memo *popup-mode-memo-list*)
      (when (equal mode (car mode-memo))
        (setq existp t)
        (nconc mode-memo memo-list)))
    (unless existp
      (push (cons mode memo-list) *popup-mode-memo-list*))))

(defun popup-mode-memo-add-top (mode &rest memo-list)
  "popup-mode-memo: mode �ɑ΂��郁����擪�ɒǉ�"
  (interactive)
  (let ((existp nil))
    (dolist (mode-memo *popup-mode-memo-list*)
      (when (equal mode (car mode-memo))
        (setq existp t)
        (dolist (str (reverse memo-list))
          (push str (cdr mode-memo)))))
    (unless existp
      (push (cons mode memo-list) *popup-mode-memo-list*))))

(defun popup-mode-memo-del (mode)
  "popup-mode-memo: mode �̃������폜"
  (interactive)
  (let ((tmp-list))
    (dolist (mode-memo *popup-mode-memo-list*)
      (unless (equal mode (car mode-memo))
        (push mode-memo tmp-list)))
    (setq *popup-mode-memo-list* (reverse tmp-list))))

(defun popup-mode-memo-add-new (mode &rest memo-list)
  "popup-mode-memo: mode �̃�����V�K�쐬"
  (interactive)
  (popup-mode-memo-del mode)
  (push (cons mode memo-list) *popup-mode-memo-list*))

;;----------------------------------------------------------------------
;; Local function
(defun describe-bindings-1-string (prefix keymap shadow)
  (let ((str ""))
    (setq keymap (keymapp keymap))
    (when keymap
      (setq shadow (mapcan #'(lambda (x)
                               (setq x (keymapp x))
                               (and x (list x)))
                           shadow))
      (do ((index 0)
           (nl nil))
          ((>= index *full-keymap-length*))
        (let ((nindex (1+ index))
              (bound (ed::lookup-keymap-index keymap shadow index)))
          (when bound
            (if (>= index 128)
                (when nl
                  (setq str (concat str (format nil "~%")))
                  (setq nl nil))
              (unless nl
                (setq str (concat str (format nil "~%")))
                (setq nl t)))
            ; key �̕\��
            (setq str (concat str (format nil "~A~:C" prefix (*keymap-index-char index))))
            ; binding �̕\��
            (cond ((symbolp bound)
                   (while (and (< nindex *full-keymap-length*)
                               (eq bound (ed::lookup-keymap-index keymap shadow nindex)))
                     (setq nindex (1+ nindex)))
                   (when (/= index (1- nindex))
                     (setq str (concat str (format nil " ... ~A~:C" prefix (*keymap-index-char (1- nindex))))))
                   ; �X�y�[�X��K���ɂ����B
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "~S~%" bound))))
                  ((keymapp bound)
                   ; �X�y�[�X��K���ɂ����B
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "Prefix Command~%"))))
                  (t
                   ; �X�y�[�X��K���ɂ����B
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "Command~%"))))))
          (setq index nindex)))
      (dotimes (index *full-keymap-length*)
        (let* ((c (*keymap-index-char index))
               (x (ed::lookup-keymap keymap c)))
          (when (keymapp x)
            (let ((y (mapcar #'(lambda (x) (ed::lookup-keymap x c)) shadow)))
              (when (notany #'(lambda (x) (and x (not (keymapp x)))) y)
                (setq str (concat str (describe-bindings-1-string (format nil "~A~:C " prefix c) x y)))))))))
    str))

(defun popup-mode-memo-string-buffer-mode (&optional (mode-symbol buffer-mode))
  (dolist (mode-memo *popup-mode-memo-list*)
    (if (symbolp (car mode-memo))
        (when (equal mode-symbol (car mode-memo))
          (return-from popup-mode-memo-string-buffer-mode
            (popup-mode-memo-join-string-list "\n" (cdr mode-memo)))))))

(defun popup-mode-memo-string-mode-name (&optional (mode-string mode-name))
  (dolist (mode-memo *popup-mode-memo-list*)
    (if (stringp (car mode-memo))
        (when (equal mode-string (car mode-memo))
          (return-from popup-mode-memo-string-mode-name
            (popup-mode-memo-join-string-list "\n" (cdr mode-memo)))))))

(defun popup-mode-memo-join-string-list (join str-list)
  (let ((return-str "") (cnt (length str-list)))
    (dolist (str str-list)
      (decf cnt)
      (setq return-str (concat return-str str (if (plusp cnt) join ""))))
    return-str))

;;; popup-mode-memo.l ends here