;;; -*- Mode: Lisp -*-
;;;
;;; config.l sample
;;;
;;; Last updated: "2006-03-08"
;;;

(in-package "changelogmemo")

;; データファイル、ヒストリ用のディレクトリ
(setq *cl-file* "~/cl/changelogmemo")
(setq *cl-history-directory* "~/cl/history/")

;; ユーザー名
(setq *cl-user* "YOUR NAME  <your@email.address>")

;; C-x 4 @ の時のメモウィンドウの高さ(nil なら分割しない)
(setq *memo-window-height* 15)

;; chalow のコマンド
(setq *chalow-command* "shell に打つ chalow のコマンド")

;; キーバインド
(global-set-key '(#\C-x #\4 #\@) 'add-memo-buffer)
(global-set-key '(#\C-c #\C-3) 'add-memo-buffer-from-clipboard)
(global-set-key '(#\C-3) 'add-memo-buffer-from-clipboard);winkey 用
(global-set-key '(#\C-x #\4 #\/) 'search-and)
(global-set-key '(#\C-x #\4 #\g) 'search-regexp)
(global-set-key '(#\C-x #\4 #\o) 'search-or)
(global-set-key '(#\C-x #\4 #\c) 'search-category)
(global-set-key '(#\C-x #\4 #\y) 'search-year)
(global-set-key '(#\C-x #\4 #\m) 'search-month)
(global-set-key '(#\C-x #\4 #\d) 'search-day)
(global-set-key '(#\C-x #\4 #\\) 'change-clmemo)
(global-set-key '(#\C-x #\4 #\h) 'convert-chalow)

;; 折り返し、fill
(setq *memo-fold-width* 72)
(setq *memo-fill-column* 72)
(setq *search-fold-width* 80)
(setq *search-fill-column* 80)

;; migemo 検索を使うための設定(要migemo, migemo.l)
;(require "changelogmemo/migemo")
;(global-set-key '(#\C-x #\4 #\j) 'search-migemo)

#|
;; 検索画面でタブを表示しない設定
(global-set-key '(#\C-x #\4 #\/) 'esearch-and)
(global-set-key '(#\C-x #\4 #\g) 'esearch-regexp)
(global-set-key '(#\C-x #\4 #\o) 'esearch-or)
(global-set-key '(#\C-x #\4 #\c) 'esearch-category)
(global-set-key '(#\C-x #\4 #\y) 'esearch-year)
(global-set-key '(#\C-x #\4 #\m) 'esearch-month)
(global-set-key '(#\C-x #\4 #\d) 'esearch-day)
;(global-set-key '(#\C-x #\4 #\j) 'esearch-migemo)
;折り返し、fill
(setq *esearch-fold-width* 72)
(setq *esearch-fill-column* 72)
|#

#|
;; *scratch* バッファをメモバッファとして使わない設定
(global-set-key '(#\C-x #\4 #\@) 'add-memo)
(global-set-key '(#\C-c #\C-3) 'add-memo-from-clipboard)
(global-set-key #\C-3 'add-memo-from-clipboard);winkey 用
;ツールバー用関数
(setq *tool-bar-function* 'toggle-memo-tool-bar)
|#

#|
;; 色付けの変更例
(setq *title-keyword*
      '("^\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
	nil (:color 1 0) nil 1 1))
(setq *title-keyword-with-tab*
      '("^\t\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
	nil (:color 1 0) nil 1 1))
(setq *date-keyword*
      '("^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z]).*$"
	nil (:color 12 0 :underline)))
|#

;; *scratch* を終了時に保存している場合のための設定
;(add-hook '*kill-xyzzy-hook* 'kill-clmemo-buffer)

;;;
