;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; Minor-mode
;;;
;;; presented by TKI
;;
;;  view-mode をマイナー化しました。
;;  キーワードがそのまま表示できるはずです。

;; view-modeって？
;; 主に編集はせずに、見るためのものです。
;; たとえば,リードオンリーの時にあわせて使い誤って変更させない時のモードです。
;;ちなみに C-x C-q で リードオンリーの切り替えができます。

;用意
;ダウンロードして
; ~/site-lisp/ などの下に置いてください。

;;実行
;; ~/site-lisp/ からの相対パスで
;;(require "tki/minorviewmode.l");で読み込んで
;M-x view-minor-mode;で実行

;読み込みのみ(リードオンリー)ファイルを自動感知して欲しい時は
;(add-hook '*find-file-hooks* 'ed:minor-mode-checking-read-only)
;を .xyzzyなんかに
#|

履歴
2010/09/07
*view-minor-mode-hook*から*view-minor-mode-toggle-hook* に変更
auto copy機能追加(*view-minor-mode-auto-copy*)

2005/01/11
toggle のバグ修正
help を修正

2005/01/02
k,h の割り当て変更
F1 で ローカル(view-minor-mode の)ヘルプに

2005/01/01
copy-line-as-kill を修正

2003/11/10
キーの割り当て一部修正
(toggle-read-only)を上書き

2003/1/10
less ぽく

2002/12/21
hook、読み込み時に切り替えられるように
C-w ,C-k に対応
C-p ,C-n はそのまま
RET 割り当てやってみました。

2002/12/15
公開
|#

;ここだけマイナー関係ないです
;Shift-SPACE キーの割り当てです
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

;セレクション範囲を auto-copy (clipboard)
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
    "ーーーーーーーー \n"
    "usage               " (find-command-key 'view-minor-mode-help) "\n"
    "toggle  上書き禁止  C-x C-q \n"
    "\n"
    "char    前 " (find-command-key 'backward-char) " <-> " (find-command-key 'forward-char) " 後\n"
    "char  ↑上 " (find-command-key 'previous-line) " <-> " (find-command-key 'next-line) " 下↓\n"
    "line    前 " (find-command-key 'beginning-of-virtual-line) " <-> " (find-command-key 'end-of-virtual-line) " 後\n"
    "page    前 " (find-command-key 'previous-page) " <-> " (find-command-key 'previous-page) " 後\n"
    "buf     前 " (find-command-key 'beginning-of-buffer) " <-> " (find-command-key 'end-of-buffer) " 後\n"
    "検索    前 " (find-command-key 'isearch-backward) " <-> " (find-command-key 'isearch-forward) " 後\n"
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
  "copy-line で行の先頭なら改行も取り込み"
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

;置き換え
(defun toggle-read-only (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'buffer-read-only arg sv)
  (view-minor-mode)
  (when buffer-read-only
    (popup-string " ***  read only !!! ***" (point))))


