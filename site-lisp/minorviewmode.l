;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; Minor-mode
;;;
;;; presented by TKI
;;
;;  view-mode ���}�C�i�[�����܂����B
;;  �L�[���[�h�����̂܂ܕ\���ł���͂��ł��B

;; view-mode���āH
;; ��ɕҏW�͂����ɁA���邽�߂̂��̂ł��B
;; ���Ƃ���,���[�h�I�����[�̎��ɂ��킹�Ďg������ĕύX�����Ȃ����̃��[�h�ł��B
;;���Ȃ݂� C-x C-q �� ���[�h�I�����[�̐؂�ւ����ł��܂��B

;�p��
;�_�E�����[�h����
; ~/site-lisp/ �Ȃǂ̉��ɒu���Ă��������B

;;���s
;; ~/site-lisp/ ����̑��΃p�X��
;;(require "tki/minorviewmode.l");�œǂݍ����
;M-x view-minor-mode;�Ŏ��s

;�ǂݍ��݂̂�(���[�h�I�����[)�t�@�C�����������m���ė~��������
;(add-hook '*find-file-hooks* 'ed:minor-mode-checking-read-only)
;�� .xyzzy�Ȃ񂩂�
#|

����
2010/09/07
*view-minor-mode-hook*����*view-minor-mode-toggle-hook* �ɕύX
auto copy�@�\�ǉ�(*view-minor-mode-auto-copy*)

2005/01/11
toggle �̃o�O�C��
help ���C��

2005/01/02
k,h �̊��蓖�ĕύX
F1 �� ���[�J��(view-minor-mode ��)�w���v��

2005/01/01
copy-line-as-kill ���C��

2003/11/10
�L�[�̊��蓖�Ĉꕔ�C��
(toggle-read-only)���㏑��

2003/1/10
less �ۂ�

2002/12/21
hook�A�ǂݍ��ݎ��ɐ؂�ւ�����悤��
C-w ,C-k �ɑΉ�
C-p ,C-n �͂��̂܂�
RET ���蓖�Ă���Ă݂܂����B

2002/12/15
���J
|#

;���������}�C�i�[�֌W�Ȃ��ł�
;Shift-SPACE �L�[�̊��蓖�Ăł�
(set-extended-key-translate-table exkey-S-space #\F16)


;---------------------------------------------
(provide "page")

(in-package "editor")

(export '(next-page-half previous-page-half))

(defun next-page-half ()
  (interactive)
  (let ((pshw))
    (setq pshw *page-scroll-keep-window-position*)
    (setq *page-scroll-keep-window-position* t)
    (next-page)
    (setq *page-scroll-keep-window-position* pshw)
    )
  )
(defun previous-page-half ()
  (interactive)
  (let ((pshw))
    (setq pshw *page-scroll-keep-window-position*)
    (setq *page-scroll-keep-window-position* t)
    (previous-page)
    (setq *page-scroll-keep-window-position* pshw)
    )
  )


;---------------------------------------------
(provide "view-minor")

(in-package "editor")

(export
 '(view-minor-mode *view-minor-mode* *view-minor-mode-map*
   *view-minor-mode-toggle-hook*
   *view-minor-mode-help-str* *view-minor-mode-auto-copy*

   view-minor-mode-help copy-line-as-kill minor-mode-checking-read-only
   view-mode-selection-copy))

;----------------------------------------
;customize

;�Z���N�V�����͈͂� auto-copy (clipboard)
(defvar *view-minor-mode-auto-copy* t)



(defvar-local *view-minor-mode* nil)
(defvar *view-minor-mode-toggle-hook* nil)
(defvar *view-minor-mode-map* nil)

(unless *view-minor-mode-map*
  (setq *view-minor-mode-map* (make-sparse-keymap))
  (define-key *view-minor-mode-map* #\SPC 'next-page)
  (define-key *view-minor-mode-map* #\n 'next-virtual-line)
  (define-key *view-minor-mode-map* #\p 'previous-virtual-line)
  (define-key *view-minor-mode-map* #\C-n 'next-line)
  (define-key *view-minor-mode-map* #\C-p 'previous-line)
  (define-key *view-minor-mode-map* #\SPC 'next-page)
  (define-key *view-minor-mode-map* #\RET 'next-page)

  (define-key *view-minor-mode-map* #\C-h 'previous-page)
  (define-key *view-minor-mode-map* #\F1 'view-minor-mode-help)
  (define-key *view-minor-mode-map* #\F16 'previous-page); shift -SPACE

  (define-key *view-minor-mode-map* #\C-w 'copy-region-as-kill)
  (define-key *view-minor-mode-map* #\C-k 'copy-line-as-kill)

  (define-key *view-minor-mode-map* #\b 'next-page)
  (define-key *view-minor-mode-map* #\h 'backward-char)
  (define-key *view-minor-mode-map* #\j 'next-line)
  (define-key *view-minor-mode-map* #\l 'forward-char)
  (define-key *view-minor-mode-map* #\k 'previous-line)
  (define-key *view-minor-mode-map* #\/ 'isearch-forward)
  (define-key *view-minor-mode-map* #\M-u 'isearch-exit)

  (define-key *view-minor-mode-map* #\H 'backward-char)
  (define-key *view-minor-mode-map* #\L 'forward-char)
  (define-key *view-minor-mode-map* #\N 'isearch-repeat-backward)

  (define-key *view-minor-mode-map* #\^ 'beginning-of-virtual-line)
  (define-key *view-minor-mode-map* #\$ 'end-of-virtual-line)

  (define-key *view-minor-mode-map* #\d 'next-page-half)
  (define-key *view-minor-mode-map* #\C-d 'next-page-half)
  (define-key *view-minor-mode-map* #\u 'previous-page-half)
  (define-key *view-minor-mode-map* #\C-u 'previous-page-half)

  ; (define-key *view-minor-mode-map* #\r #'(lambda() (interactive)(refresh-screen)))
  ; (define-key *view-minor-mode-map* #\C-r 'isearch-backward)
  ;  (define-key *view-minor-mode-map* #\C-r 'refresh-screen)
  ;  (define-key *view-minor-mode-map* #\C-l 'refresh-screen)

  (define-key *view-minor-mode-map* #\R 'close-and-read-and-minor-mode)

  (define-key *view-minor-mode-map* #\g 'beginning-of-buffer)
  (define-key *view-minor-mode-map* #\< 'beginning-of-buffer)
  (define-key *view-minor-mode-map* #\G 'end-of-buffer)
  (define-key *view-minor-mode-map* #\> 'end-of-buffer)
  (define-key *view-minor-mode-map* #\LBtnUp 'view-mode-selection-copy)

  (dotimes (i 9)
    (define-key *view-minor-mode-map* (code-char (+(char-code #\0) i)) 'goto-line)
    )
  )


(defvar-local buffer-read-only-p nil)
(defvar *view-minor-mode-help-str*
 '(popup-string
  (concat
    "view-minor-mode-help \n"
    "�[�[�[�[�[�[�[�[ \n"
    "usage               " (find-command-key 'view-minor-mode-help) "\n"
    "toggle  �㏑���֎~  C-x C-q \n"
    "\n"
    "char    �O " (find-command-key 'backward-char) " <-> " (find-command-key 'forward-char) " ��\n"
    "char  ���� " (find-command-key 'previous-line) " <-> " (find-command-key 'next-line) " ����\n"
    "line    �O " (find-command-key 'beginning-of-virtual-line) " <-> " (find-command-key 'end-of-virtual-line) " ��\n"
    "page    �O " (find-command-key 'previous-page) " <-> " (find-command-key 'previous-page) " ��\n"
    "buf     �O " (find-command-key 'beginning-of-buffer) " <-> " (find-command-key 'end-of-buffer) " ��\n"
    "����    �O " (find-command-key 'isearch-backward) " <-> " (find-command-key 'isearch-forward) " ��\n"
   )
  (point)))

;;------------------------------

(defun view-minor-mode-help ()
  (interactive)
 (eval *view-minor-mode-help-str*)
 )

(defun minor-mode-checking-read-only()
  (interactive)
  (if buffer-read-only (view-minor-mode)))

;;------------------------------
(defun find-command-key (command &optional (keymap *view-minor-mode-map*) (type :string))
 (let ((key))
  (setq key (car (find command (cdr keymap) :key 'cdr)))
   (if (equal type :string)
       (format nil "~S"   key)
     key)))

(defun copy-line-as-kill (&optional lines)
  "copy-line �ōs�̐擪�Ȃ���s����荞��"
  (interactive)
  (when (eq *last-command* 'kill-region)
    (setq *this-command* 'kill-region))

  (copy-region-as-kill
   (point)
   (progn
     (cond ((null lines)
            (cond ((eolp) (forward-line 1))
                  ((bolp) (goto-eol)(forward-char))
                  (t (goto-eol))))
           ((zerop lines) (if(bolp)(forward-line -1)(goto-bol)))
           (t (forward-line lines)))
     (point)))
   (setq *this-command* 'kill-region))

(defun close-and-read-and-minor-mode ()
  (interactive)
  (let ((fn))
    (setq fn (get-buffer-file-name (selected-buffer)))
    (setq buffer-read-only nil)
    (erase-buffer (selected-buffer))
    (insert-file fn))

  (view-minor-mode t)
  (refresh-screen))

(defun view-mode-selection-copy()
 (interactive)
  (if *view-minor-mode-auto-copy* (copy-selection-to-clipboard)))

;;------------------------------
(defun view-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*view-minor-mode* arg sv)
  (if buffer-read-only
      (progn
        (set-minor-mode-map *view-minor-mode-map*)
        (setq buffer-read-only-p buffer-read-only))
    (progn
      (unset-minor-mode-map *view-minor-mode-map*)))
  (update-mode-line t)
  (run-hook-with-args '*view-minor-mode-toggle-hook* *view-minor-mode*))

(pushnew '(*view-minor-mode* . "View") *minor-mode-alist* :key #'car)


;----------------------------------------


(provide "buffer")

(in-package "editor")

(export '(toggle-read-only))

;�u������
(defun toggle-read-only (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'buffer-read-only arg sv)
  (view-minor-mode)
  (when buffer-read-only
    (popup-string " ***  read only !!! ***" (point))))

