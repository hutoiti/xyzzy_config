;;;  ghci.l -- GHCi (Glasgow Haskell Compiler interpreter) interface for xyzzy
;;;  Copyright (C) 2006 IMAI Takeo <usitukai@osk.3web.ne.jp>

;;; 初期設定いろいろ
(provide "ghci")
(in-package "editor")

(require "shell")

(export '(ghci-mode
	  *ghci-mode-map*
	  *ghci-command*
	  *ghci-window-height*
	  *ghci-interactive-mode-map*))

(defvar-local ghci-mode nil)
; キーマップ
(defvar *ghci-mode-map*
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap '(#\C-c #\l) 'ghci-load-file)
    (define-key keymap '(#\C-c #\q) 'ghci-quit)
    keymap))

; モードの設定
(defun ghci-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'ghci-mode arg sv)
  (if ghci-mode
      (set-minor-mode-map *ghci-mode-map*)
    (unset-minor-mode-map *ghci-mode-map*))
  (update-mode-line t))

; 変数
(defvar *ghci-command* "ghci")
(defvar *ghci-buffer-name* "*GHCi*")
(defvar *ghci-buffer* nil)
(defvar *ghci-process* nil)
(defvar *ghci-window-height* 20)

; バッファがなければ作成、あれば返す
(defun ghci-get-buffer ()
  (setq *ghci-buffer* (get-buffer-create *ghci-buffer-name*)))

; ghciにバッファをロードする
(defun ghci-load-file (&optional f)
  (interactive)
  (let ((buf (ghci-get-buffer)) ; 出力バッファ
	(win (get-buffer-window *ghci-buffer-name*)) ; 出力ウィンドウ
	(file (if f f
		(get-buffer-file-name))) ; ファイル（フルパス）
	proc ; プロセス
	)
    (if	(= (count-windows nil) 1)
	(split-window (- (screen-height) *ghci-window-height* 2)))
    (switch-to-buffer-other-window buf)
    (setq proc (buffer-process buf))
    (if (and proc (eq (process-status proc) ':run))
	proc
      (progn
	(erase-buffer buf)
	(setq proc (make-process *ghci-command*
				 :output buf))))
    (when file
      (ghci-send-string (concat ":l " file)))
    (ghci-interactive-mode)
    (end-of-buffer)))

; ghcのプロセスを返す
(defun ghci-get-process ()
  (if (deleted-buffer-p *ghci-buffer*)
      nil
    (buffer-process *ghci-buffer*)))

; ghcに文字列を送る
(defun ghci-send-string (str)
  (let ((proc (ghci-get-process)))
    (if proc
	(process-send-string proc
			     (concat str "\n"))
      nil)))

; ghciバッファを消す
(defun ghci-delete-buffer ()
  (when (not (deleted-buffer-p *ghci-buffer*))
    (let ((proc (buffer-process *ghci-buffer*)))
      (when proc
	(kill-process proc)))
    (delete-buffer *ghci-buffer*)))

; ghciのプロセスが生きてるか否か
(defun ghci-alive-p ()
   (and
    (not (deleted-buffer-p *ghci-buffer*))
    (buffer-process *ghci-buffer*)))


; ghciをやめる
(defun ghci-quit ()
  (interactive)
  (when (ghci-alive-p)
    (ghci-send-string ":q"))
  (sleep-for 1)
  (ghci-delete-buffer)
  (delete-other-windows))


;;; Minor mode に
(pushnew '(ghci-mode . "GHCi") *minor-mode-alist* :key #'car)


;;; ghci-interactive-mode (GHCi とのインタラクティブバッファ用）
(defvar *ghci-interactive-mode-map* nil)
(unless *ghci-interactive-mode-map*
  (setq *ghci-interactive-mode-map* (make-sparse-keymap))
  (define-key *ghci-interactive-mode-map* #\RET 'shell-send-input)
  (define-key *ghci-interactive-mode-map* '(#\C-c #\C-c) 'shell-send-interrupt))

(defun ghci-interactive-mode ()
  (setq mode-name "GHCi Interactive")
  (setq buffer-mode 'ghci-interactive-mode)
  (use-keymap *ghci-interactive-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil))

