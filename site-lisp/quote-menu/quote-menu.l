;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; quote-menu.l
;;;

;;;
;;; $HeadURL: file:///g:/repo/xyzzy/site-lisp/quote-menu/tags/release/0.0.0.2/quote-menu.l $
;;;
;;; $LastChangedDate: 2004-05-23 13:05:29 +0900 (Sun, 23 May 2004) $
;;;
;;; $LastChangedRevision: 16 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; Install and Settings
;;;
;;;   NetInstaller �ȊO�ŃC���X�g�[�������ꍇ
;;;
;;;     ~/.xyzzy �������� siteinit.l ��
;;;
;;;       (require "quote-menu/quote-menu")
;;;
;;;     �ƒǉ����ĕۑ��Axyzzy ���ċN��������B
;;;     siteinit.l �ɒǉ������ꍇ�́A�_���v�t�@�C����
;;;     ��蒼���B
;;;

;;;
;;; Options
;;;
;;;   *quote-string-list*
;;;     ���p���̃��X�g�B���X�g�̐擪�ɂ��镶����
;;;     �f�t�H���g�Ŏg���܂�
;;;
;;;   *quote-use-customize-menu*
;;;     ���j���[�́u�ҏW(E)�v���g�����āA���ڂ�ǉ����邩�ǂ����B
;;;     �f�t�H���g�Ŏg���܂�
;;;
;;;   *quote-use-customize-icon*
;;;     �W�����j���[�̃c�[���o�[���g�����邩�ǂ����B
;;;     �f�t�H���g�ł͎g���܂���B�g���ꍇ�́A������
;;;     �A�C�R���t�@�C�����������Ȃ���΂Ȃ�܂���
;;;
;;;   *quote-tool-bar-icon-file*
;;;     �c�[���o�[���g�������ꍇ�̃A�C�R���t�@�C���̖��O�B
;;;     �����ō�����A�C�R���t�@�C����(etc-path)�̃f�B���N�g��
;;;     �ȉ��ɒu���Ă��������B
;;;
;;;   �����̐ݒ�́A(require "quote-menu")�̑O�ɐݒ肵�Ă��������B
;;;
;;;   ��
;;;     (setq ed::*quote-use-customize-icon* t)
;;;     (setq ed::*quote-tool-bar-icon-file* "toolbar_test.bmp")
;;;     (require "quote-menu")
;;;     ;; �����require�̌�ł���
;;;     (setq ed::*quote-use-customize-menu* t)
;;;     ;; ������̐ݒ肪1�̏ꍇ�ł����X�g�ɂ��Ă�������
;;;     (setq ed::*quote-string-list* '(">> " "| "))
;;;

;;;
;;; �W�����j���[�̃A�C�R���t�@�C���̍���
;;;
;;;   01. (etc-path)�ɂ���A"toolbar.bmp"��ʖ��ŃR�s�[����B
;;;   02. �摜�ҏW�\�t�g�ŃR�s�[�����t�@�C�����J���B
;;;   03. �摜�̃T�C�Y��ύX����Btoolbar.bmp�̉�����
;;;       1264�s�N�Z���Ȃ̂ŁA�ǉ�����A�C�R���̐���
;;;       16���|���������������L����B
;;;   04. �L�����ꏊ�ɃA�C�R�����쐬����B�A�C�R���̃T�C�Y��
;;;       16x16�s�N�Z���ȓ��Ɏ��܂�悤�ɍ쐬����B
;;;   05. 16�F��BMP�t�@�C���Ƃ��ĕۑ�����B
;;;
;;;   GIMP���g�����ȒP�ȍ�����
;;;     http://www5d.biglobe.ne.jp/~lostland/ndiary/topics/200405_2.html#d22_t3
;;;   �ɂ���܂��̂ŁA������Ȃ������ꍇ�͂�������Q�Ƃ��Ă��������B
;;;

;;;
;;; code
;;;

(provide "quote-menu")

(in-package "editor")

(export '(insert-quote-string-to-selection
          delete-quote-string-from-selection
          add-quote-string-to-clipboard-data
          copy-to-clipboard-with-quote-string
          ))
          
(defvar *quote-string-list* '(">" "| "))
(defvar *quote-use-customize-menu* t)
(defvar *quote-use-customize-icon* nil)
(defvar *quote-tool-bar-icon-file* nil)

(defun insert-quote-string-to-selection (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (save-excursion
      (save-restriction
        (narrow-to-region (selection-mark) (selection-point))
        (goto-char (point-min))
        (loop
          (goto-bol)
          (insert (nth (1- type) *quote-string-list*) arg)
          (when (eql (point-max) (progn (goto-eol) (point)))
            (return))
          (forward-line 1))))))

(defun delete-quote-string-from-selection (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (save-excursion
      (save-restriction
        (narrow-to-region (selection-mark) (selection-point))
        (goto-char (point-min))
        (loop
          (do ((i 0 (1+ i)))
              ((= i arg))
            (goto-bol)
            (when (looking-at (format nil "^~A" (nth (1- type) *quote-string-list*)))
              (delete-char (length (nth (1- type) *quote-string-list*))))
            )
          (when (eql (point-max) (progn (goto-eol) (point)))
            (return))
          (forward-line 1))))))

(defun add-quote-string-to-clipboard-data (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (let ((replace-pattern "\n"))
    (insert
    (substitute-string
       (format nil "~A~A"
         (progn
           (let ((result nil))
             (dolist
              (i
                 (make-sequence 'list arg
                                :initial-element
                                (nth (1- type) *quote-string-list*)) result)
               (setq result (concat result i)))))
               (get-clipboard-data))
       "\n" (dotimes (tmp arg replace-pattern)
              (setq replace-pattern
              (format nil "~A~A"
                      replace-pattern
                      (nth (1- type) *quote-string-list*))))))))

(defun copy-to-clipboard-with-quote-string (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (let ((replace-pattern "\n"))
      (copy-to-clipboard
         (format nil "~A~A"
         (progn
           (let ((result nil))
             (dolist
              (i
                 (make-sequence 'list arg
                                :initial-element
                                (nth (1- type) *quote-string-list*)) result)
               (setq result (concat result i)))))
         (substitute-string
            (buffer-substring (selection-mark) (selection-point))
            "\n" (dotimes (tmp arg replace-pattern)
            (setq replace-pattern
                  (format nil "~A~A"
                          replace-pattern
                          (nth (1- type) *quote-string-list*))))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun quote-menu-init ()
  (when *quote-use-customize-menu*
    (add-popup-menu *app-popup-menu*
                    (define-popup-menu
                      (:item 'add-quote "�I��͈͂̍s���Ɉ��p��t��"
                       'insert-quote-string-to-selection :selection)
                      (:item nil "�I��͈͂̍s���ɂ�����p�����̏���"
                       'delete-quote-string-from-selection :selection)
                      ) "�g���߂ɂ�")
    (add-menu-separator (get-menu *app-menu* 1 t))
    (add-popup-menu (get-menu *app-menu* 1 t)
                    (define-popup-menu
                      (:item 'add-quote "�I��͈͂̍s���Ɉ��p��t��"
                       'insert-quote-string-to-selection :selection)
                      (:item nil "�I��͈͂̍s���ɂ�����p�����̏���"
                       'delete-quote-string-from-selection :selection)
                      ) "�g���߂ɂ�")
    (unless (get-menu-position (get-menu *app-menu* 1 t) 'ext-copy-1)
      (insert-menu-item
         (get-menu *app-menu* 1 t) 5 'ext-copy-1
         "���p���R�s�[" 'copy-to-clipboard-with-quote-string :selection))
    (unless (get-menu-position (get-menu *app-menu* 1 t) 'ext-paste-1)
      (insert-menu-item
         (get-menu *app-menu* 1 t) 8 'ext-paste-1
         "���p���\��t��" 'add-quote-string-to-clipboard-data :clipboard))
    (unless (get-menu-position *app-popup-menu* 'quote-copy)
      (insert-menu-item *app-popup-menu* 2 'quote-copy
                        "���p���R�s�["
                        'copy-to-clipboard-with-quote-string :selection))
    (unless (get-menu-position *app-popup-menu* 'quote-paste)
      (insert-menu-item *app-popup-menu* 5 'quote-paste
                        "���p���\��t��"
                        'add-quote-string-to-clipboard-data :clipboard))
    )
  )

(if (and *quote-use-customize-menu*
         *app-menu*)
    (quote-menu-init)
  (add-hook '*init-app-menus-hook* 'quote-menu-init))

(when *quote-use-customize-icon*
  (defun std-tool-bar ()
    (create-tool-bar
       'std-tool-bar
       (merge-pathnames *quote-tool-bar-icon-file* (etc-path))
       '(("�V�K�쐬" 24 new-file)
         ("�J��" 22 open-file-dialog)
         ("�㏑���ۑ�" 20 save-buffer-dialog :modified)
         ("�S�ĕۑ�" 75 save-all-buffers)
         :sep
         ("���" 29 print-selected-buffer-dialog)
         :sep
         ("�؂���" 7 kill-selection-to-clipboard :modify-any-selection)
         ("�R�s�[" 9 copy-selection-to-clipboard :any-selection)
         ("���p���R�s�[" 79 copy-to-clipboard-with-quote-string :any-selection)
         ("�\��t��" 2 paste-from-clipboard :clipboard)
         ("���p���\�t" 80 add-quote-string-to-clipboard-data :clipboard)
         :sep
         ("���ɖ߂�" 0 undo :undo)
         ("����ς茳�ɖ߂��Ȃ�" 1 redo :redo)
         :sep
         ("����" 5 search-dialog)
         ("�O������" 3 repeat-backward-search tool-bar-update-search)
         ("��������" 4 repeat-forward-search tool-bar-update-search)
         :sep
         ("grep" 74 grep-dialog)
         :sep
         ("�܂�Ԃ��Ȃ�" 76
          set-buffer-fold-type-none set-buffer-fold-type-none-update)
         ("�w��ʒu�Ő܂�Ԃ�" 77
          set-buffer-fold-type-column set-buffer-fold-type-column-update)
         ("����޳���Ő܂�Ԃ�" 78
          set-buffer-fold-type-window set-buffer-fold-type-window-update)
         )))
  )