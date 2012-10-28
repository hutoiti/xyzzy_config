;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/menu.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/base")
  (require "xtal-mode/completion")
  (require "xtal-mode/comment")
  (require "xtal-mode/indent")
  (require "xtal-mode/outline")
  (require "xtal-mode/path")
  (require "xtal-mode/process")
  (require "xtal-mode/ix-mode")
  )

(in-package :xtal-mode)

(export '(xtal-track-popup-menu
          xtal-add-bookmark-menu
          ))

(defparameter *xtal-menu-name* "&Xtal")
(defparameter *xtal-menu-tag* 'xtal)
(defparameter *xtal-menu-position* 'ed::help)
(defparameter *xtal-popup-menu* nil)

(defun xtal-define-popup-menu ()
  (define-popup-menu 'xtal
    (:item nil "&Xtal �Ŏ��s" 'xtal-run-with-current-buffer)
    (:item nil "���s���ʂ����" 'xtal-close-output-buffer)
    (:item nil "���s���ʂ̍ŏ��̃G���[�s�ɃW�����v" 'xtal-first-error)
    (:sep :above-ix)
    (:item nil "ix �� xyzzy ���Ŏ��s (&I)" 'ix)
    (:item nil "ix ���O���Ŏ��s (&J)" 'ix-console)
    (:sep :above-comment)
    (:item nil "���[�W�������R�����g�A�E�g" 'xtal-comment-region)
    (:item nil "���[�W�������R�����g����" 'xtal-uncomment-region)
    (:item nil "�R�����g���g�O��" 'xtal-toggle-comment-line
     #'(lambda () (if (xtal-in-multiline-comment-p)
                      :disable
                    (if (or (xtal-in-comment-p) (xtal-beginning-of-one-line-comment-p))
                        :check))))
    (:sep :above-indent)
    (:item nil "�o�b�t�@���C���f���g" 'xtal-indent-buffer)
    (:sep :above-outline)
    (:item nil "�N���X�E���\�b�h�ꗗ(&L)..." 'list-function)
    (:sep :above-edit)
    (:item nil "�X�e�[�g�����g���}�[�N" 'xtal-mark-statement)
    (:item nil "���̃X�e�[�g�����g" 'xtal-forward-statement)
    (:item nil "�O�̃X�e�[�g�����g" 'xtal-backward-statement)
    (:item nil "����X�R�[�v�̎��̃X�e�[�g�����g" 'xtal-forward-statement-in-scope)
    (:item nil "����X�R�[�v�̑O�̃X�e�[�g�����g" 'xtal-backward-statement-in-scope)
    (:item nil "�X�R�[�v����Ɉړ�" 'xtal-up-statement)
    (:item nil "�X�R�[�v�����Ɉړ�" 'xtal-down-statement)
    (:item nil "�O��̃X�e�[�g�����g�����ւ�" 'xtal-transpose-statement)
    (:sep :above-path)
    (:item nil "Xtal �C���X�g�[���p�X���G�N�X�v���[���ŊJ�� (&E)" 'xtal-open-install-path-by-explorer)
    (:item nil "Xtal �C���X�g�[���p�X���R�}���h�v�����v�g�ŊJ�� (&C)" 'xtal-open-install-path-by-command-prompt)
    (:sep :above-manual)
    (:item :home-page "Xtal &Home Page"
     (open-url-command *xtal-home-url*))
    (:item :online-reference "Xtal �I�����C�����t�@�����X (&O)"
     (open-url-command *xtal-online-reference-url*))
    (:sep :above-version)
    (:item :version (concat "xtal-mode &version " (xtal-mode-version))
     'xtal-mode-show-credit)
    ))

(defun xtal-popup-menu ()
  (or *xtal-popup-menu*
      (setf *xtal-popup-menu* (xtal-define-popup-menu))))


(defun insert-xtal-menu (&key (menu (current-menu))
                              (position *xtal-menu-position*)
                              (menu-name *xtal-menu-name*))
  (when (menup menu)
    (setq menu (copy-menu-items menu (create-menu *xtal-menu-tag*)))
    (delete-xtal-menu menu)
    (cond
     ((and (numberp position) (integerp position))
      (insert-popup-menu menu position (xtal-popup-menu) menu-name))
     ((and (symbolp position) (get-menu-position menu position))
      (insert-popup-menu menu (get-menu-position menu position)
                         (xtal-popup-menu) menu-name))
     (t
      (add-popup-menu menu (xtal-popup-menu) menu-name)))
    (use-local-menu menu)))

(defun delete-xtal-menu (&optional (menu (current-menu)))
  (when (menup menu)
    (while (delete-menu menu *xtal-menu-tag*))))

(defun insert-xtal-menu-all-buffers ()
  (save-excursion
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (when (eq buffer-mode 'xtal-mode)
        (insert-xtal-menu)))))

(defun xtal-track-popup-menu ()
  (interactive)
  (track-popup-menu (xtal-popup-menu)))

(defun xtal-add-bookmark-menu (tag name url)
  (let* ((menu (xtal-popup-menu))
         (pos (and menu (get-menu-position menu :above-version))))
    (when pos
      (insert-menu-item menu pos
                        tag name (open-url-command url)))))


;;; ������

(unless *app-menu*
  ;; local-menu �͑��̃��j���[���S�Đ������ꂽ��ɕύX���ׂ��Ȃ̂�
  ;; *init-app-menus-hook* �łȂ� *post-startup-hook* �Ŏ��s
  (add-hook '*post-startup-hook* 'insert-xtal-menu-all-buffers))

;; xtal �̎��s���ʃo�b�t�@�ɂ����j���[��t����
(add-hook '*xtal-create-output-buffer-hook* 'insert-xtal-menu)


(defun xtal-mode-setup-menu ()
  (insert-xtal-menu))


(provide "xtal-mode/menu")

;;;; End