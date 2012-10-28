; -*- Mode: Lisp; Package: editor -*-

#|
= nsis-mode - NSIS �t�@�C����ҏW�����肷��

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/nsis-mode.html>))
* Version: $Id: nsis-mode.l,v 1.9 2004/08/09 14:03:15 miyamuko Exp $


== ����

NSIS �X�N���v�g�t�@�C���̕ҏW�p���[�h�ł��B

* �K���ȃC���f���g
* �K���ȐF�Â�
* �L�[���[�h�̕⊮
* Function �� !define �̃^�O�W�����v


== �C���X�g�[��

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + (({ni-autoload})) ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/nsis-mode.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) �g���q�� nsi (NSIS Script File) �܂��� nsh (NSIS Header File)
    �̃t�@�C�����J�����Ƃ��Ɏ����I�� nsis-mode �ɂȂ�悤��
    ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; nsis-mode
        (require "nsis-mode")
        (pushnew '("\\.ns[ih]$" . nsis-mode) *auto-mode-alist* :test 'equal)

(4) �ݒ�𔽉f������ɂ� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B


== ���t�@�����X

=== �L�[���蓖��

: ((%TAB%))
    �C���f���g����B

    Compiler directive (!define�Ƃ�) �̓C���f���g���܂���B

: ((%RET%))
    ���s�{�C���f���g�t���B

: ((%M-TAB%))
    �L�[���[�h�Ƒg�ݍ��݊֐��̕⊮�B

    ��s���镶��������΂��̕�������n�܂�L�[���[�h���c�[���`�b�v�ŕ\�����܂��B
    ��s���镶�����Ȃ���΂��ׂẴL�[���[�h��\�����܂��B

=== �ϐ�

--- *nsis-indent-level*
--- *nsis-continued-statement-offset*

�C���f���g���x����ݒ肵�܂��B

    ;; �C���f���g�̕�(���}�� _ �̕���, default=2)
    (setq *nsis-indent-level* 4)

    ;; �p���s�̃I�t�Z�b�g(���}�� - �̕���, default=4)
    (setq *nsis-continued-statement-offset* 4)

    ;; Section "Modern User Interface" SecContribModernUI
    ;; ____SetOutPath "$INSTDIR" \
    ;; ____----"\Examples\Modern UI"
    ;; EndSection


== ���ꂩ���邩������Ȃ�����

* �ւȂ��傱�Ȃ̂ŕ��u
  * ���ꂩ��������Ă��������B


== �֘A���邩������Ȃ��y�[�W

: Nullsoft Scriptable Install System // NSIS Developer Site
    ((<URL:http://nsis.sf.net/>))

: NSIS related software - NSIS Archive
    ((<URL:http://nsis.sourceforge.net/archive/nsisweb.php?page=8&instances=0>))


== ���C�Z���X

nsis-mode �͏C�� BSD ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

  Copyright (C) 2003-2004 MIYAMUKO Katsuyuki. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1 Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer as the first lines
  of this file unmodified.

  2 Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
|#


(provide "nsis-mode")
(in-package "editor")
(export '(*nsis-mode-hook*
          *nsis-mode-map*
          *nsis-comment-column*
          *nsis-indent-level*
          *nsis-continued-statement-offset*
          nsis-completion
          nsis-mode))

; �t�b�N
(defvar *nsis-mode-hook* nil
  "nsis-mode: �t�b�N�ϐ�")

; configuration
(defvar *nsis-comment-column* nil)
(defvar *nsis-indent-level* 2
  "�C���f���g�œ����X�y�[�X�̐�")
(defvar *nsis-continued-statement-offset* 4
  "�o�b�N�X���b�V���Ōp�������s�̃C���f���g")

; �L�[���[�h
(defvar *nsis-completion-list* nil
  "nsis-mode: �⊮���X�g�̃|�b�v�A�b�v")

(defvar *nsis-keyword-hash-table* nil)
(defvar *nsis-keyword-file* "NSIS")

;; label color
(defvar *nsis-label-color* '(:keyword 0 :bold)
  "nsis-mode: ���x���̐F")

(defvar *nsis-regexp-keyword-list* nil
  "nsis-mode: ���K�\���L�[���[�h���X�g")

(setq *nsis-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;; ���x���s
     ("[a-zA-Z0-9_]+:" t ((0 . ,*nsis-label-color*)))
     )))


;; �V���^�b�N�X�e�[�u��
(defvar *nsis-mode-syntax-table* nil)
(unless *nsis-mode-syntax-table*
  (setq *nsis-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *nsis-mode-syntax-table* c))))
  ; �ȉ�mode�ɍ��킹�Đݒ�
  (set-syntax-word *nsis-mode-syntax-table* #\$)
  (set-syntax-string *nsis-mode-syntax-table* #\")
  (set-syntax-string *nsis-mode-syntax-table* #\')
  (set-syntax-escape *nsis-mode-syntax-table* #\\)
  (set-syntax-symbol *nsis-mode-syntax-table* #\_)
  (set-syntax-symbol *nsis-mode-syntax-table* #\!)
  (set-syntax-symbol *nsis-mode-syntax-table* #\.)
  (set-syntax-start-comment *nsis-mode-syntax-table* #\;)
  (set-syntax-start-comment *nsis-mode-syntax-table* #\#)
  (set-syntax-end-comment *nsis-mode-syntax-table* #\LFD))

;; �L�[�}�b�v
(defvar *nsis-mode-map* nil)
(unless *nsis-mode-map*
  (setq *nsis-mode-map* (make-sparse-keymap))
  ; �ȉ��L�[����
  (define-key *nsis-mode-map* #\! 'nsis-electric-insert)
  (define-key *nsis-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *nsis-mode-map* #\TAB 'nsis-indent-line)
  (define-key *nsis-mode-map* #\C-M-q 'indent-sexp)
  (define-key *nsis-mode-map* #\RET 'nsis-newline-and-indent)
  (define-key *nsis-mode-map* #\M-TAB 'nsis-completion)       ; �⊮
  )


(defun nsis-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (nsis-indent-line))

(defun nsis-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (nsis-indent-line)
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (nsis-indent-line))

(defun nsis-indent-line ()
  (interactive "*")
  (if (or (not (interactive-p))
          *c-tab-always-indent*
          (save-excursion
            (skip-chars-backward " \t")
            (bolp)))
      ; ������ς�������
      (let ((column (calc-nsis-indent)))
        (when (integerp column)
          (save-excursion
            (goto-bol)
            (delete-region (point)
                           (progn
                             (skip-chars-forward " \t")
                             (point)))
            (indent-to column)))
        (if (and (bolp) column)
            (skip-chars-forward " \t")))
    (insert "\t"))
  t)

(defun nsis-previous-line ()
  "�O�̗L���ȍs�܂Ŗ߂�"
  (let ((in-conditional-compilation nil))
    (save-restriction
      (while (forward-line -1)
        (goto-bol)
        (cond
         ;; !else �̒��ɂ���ꍇ !ifdef �̑O�܂Ŗ߂�
         (in-conditional-compilation
          (if (looking-at "[ \t]*!ifn?def")
              (setq in-conditional-compilation nil)))
         ((looking-at "[ \t]*!else")
          (setq in-conditional-compilation t))
         ((not (or (nsis-space-line) (nsis-continued-line) (nsis-compiler-directive)))
          (return-from nsis-previous-line t))
         ))
      )))

(defun nsis-space-line ()
  "��s���ǂ���"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun nsis-continued-line ()
  "�p���s���ǂ���"
  (let ((result nil))
    (save-excursion
      (if (equal nil (forward-line -1))
          (return-from nsis-continued-line nil))
      (goto-eol)
      (setq result (looking-back "\\"))
      (forward-line +1)
;      (msgbox "~D is continue? => ~A" (current-line-number) result)
      result
      )))

(defun nsis-compiler-directive ()
  "compiler directive ���ǂ���"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*!")))

(defun calc-nsis-indent ()
  "�C���f���g���鐔�𐔂���B�p���s�Ȃ� + *nsis-continued-statement-offset*"
  (let ((column 0))
    ; compiler directive �̓C���f���g�Ȃ�
    (if (nsis-compiler-directive)
        (return-from calc-nsis-indent 0))

    (save-excursion
      ;�O�̍s�𒲂ׂ�
      (when (nsis-previous-line)
        (save-restriction
          (narrow-to-region (progn (goto-eol) (point))
                            (progn (goto-bol) (point)))
          (goto-bol)
          (skip-chars-forward " \t")
          ; �C���f���g��
          (setq column (current-column))
;          (msgbox "base indent(line ~D): ~D" (current-line-number) column)

          ; �J�����̂�����΃C���f���g���𑝂₷
          (cond
           ((looking-at "\\<\\(Function\\|SubSection\\|Section\\)\\>")
            (incf column *nsis-indent-level*)
;            (msgbox "Function | Section | SubSection ~D" column)
            ))
          )))
    ; ���݂̍s�𒲂ׂ�
    (save-excursion
      (save-restriction
        ; ���ݍs���p���s�Ȃ� *nsis-continued-statement-offset* �����₷
        (if (nsis-continued-line)
            (return-from calc-nsis-indent
              (+ column *nsis-continued-statement-offset*)))

        (narrow-to-region (progn (goto-eol) (point))
                          (progn (goto-bol) (point)))
        (goto-bol)
        (skip-chars-forward " \t")
        ; �����̂�����΃C���f���g�������炷
        (cond
         ((looking-at "\\<\\(Function\\|Section\\|SubSection\\)End\\>")
          (decf column *nsis-indent-level*)
;          (msgbox "End ~D" column)
          ))
        ))
    column
    ))


; �⊮
;; addrev-table
(defvar *nsis-mode-abbrev-table* nil)
(unless *nsis-mode-abbrev-table*
  (define-abbrev-table '*nsis-mode-abbrev-table*))

;; popup �⊮
(defun nsis-completion ()
  "nsis-mode: �⊮"
  (interactive)
  (or *nsis-completion-list*
      (setq *nsis-completion-list* (make-list-from-keyword-table *nsis-keyword-hash-table*))
      (return-from nsis-completion nil))
  (let ((opoint (point)))
    (skip-syntax-spec-backward "w_")
    (let ((from (point)))
      (goto-char opoint)
      ; :list-ignore-case=�⊮�ő啶������������ʂ��Ȃ�, :list=����
      (do-completion from opoint :list-ignore-case *nsis-completion-list*
                     nil nil *nsis-completion-list* ; xyzzy 0.2.2.211�ȑO���g���ꍇ�̓R�����g�A�E�g
                     ))))

; Function ���̈ꗗ
(defun nsis-build-summary-of-functions ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "^[ \t]*Function[ \t]+\\([a-zA-Z0-9_.]+\\)" :regexp t :tail t)
        (push (list (current-line-number)
                    (match-string 1))
              result )))
    (nreverse result) ))

; tag
(pushnew '(nsis-maketags "*.ns[ih]") *maketags-list* :key #'car)

(defun tags-find-nsis-point (class name functionp point)
  (goto-char (- point *jump-tag-limit*))
  (and (or (scan-buffer "^!define[ \t]+[A-Z_]+"
                        :regexp t :limit (+ point *jump-tag-limit*))
           (scan-buffer (concat "^[ \t]*Function[ \t]+"
                                (regexp-quote name)
                                "[ \t]+")
                        :regexp t :limit (+ point *jump-tag-limit*)))
       (point)))

;; Function ���^�O�t��
;;   Function name
(defun nsis-maketags (file count)
  (goto-char (point-min))
  (while (scan-buffer "^[ \t]*\\(!define\\|Function\\)[ \t]+" :regexp t :tail t :case-fold t)
    (do-events)
    (let ((opoint (point)))
      (skip-chars-forward "a-zA-Z0-9_.")
      (unless (= opoint (point))
        (format t "~A~A~D" (buffer-substring opoint (point)) file opoint)
        (setq count (1+ count)))))
  count)


; mode�̎��s
(defun nsis-mode ()
  "nsis-mode"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "NSIS")
  (setq buffer-mode 'nsis-mode)
  (use-syntax-table *nsis-mode-syntax-table*)
  (use-keymap *nsis-mode-map*)

  ; ����W�J
  (setq *local-abbrev-table* *nsis-mode-abbrev-table*)

  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f") ; forward|backward-paragraph �ňړ�����i���ʒu
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)

  ; �^�O�֘A
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'tags-find-target-simple)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'tags-find-nsis-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'nsis-build-summary-of-functions)

  ; indent
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'nsis-indent-line)
  (make-local-variable 'mode-newline-and-indent-command)
  (setq mode-newline-and-indent-command 'nsis-newline-and-indent)

  ; comment
  (setq comment-start "; " comment-end "") ; indent-for-comment�ő}�������z
  (setq comment-start-skip ";+[ \t]*")
  (setq comment-indent-function 'calc-nsis-indent)
  (when *nsis-comment-column*
    (setq comment-column *nsis-comment-column*))

  ; keyword
  (and *nsis-keyword-file*
       (null *nsis-keyword-hash-table*)
       (setq *nsis-keyword-hash-table*
             (load-keyword-file *nsis-keyword-file* t))) ; t=�啶������������ʂ��Ȃ�, nil=����
  (when *nsis-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *nsis-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *nsis-regexp-keyword-list*)

  ; �t�b�N�̎��s
  (run-hooks '*nsis-mode-hook*))