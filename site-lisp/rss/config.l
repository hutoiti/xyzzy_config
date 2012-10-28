;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: config.l 731 2006-09-01 18:09:41Z torihat $
;
; config.l sample
;
; by HATTORI Masashi

(in-package "rss")

;;; www-modeで開く
;(require "rss/open-www")

;;; 起動時にオンラインモードにする
;(rss-toggle-online t)

;;; ブラウザの高さ設定
;(setq *rss-browser-height* 400)

;;; Description 表示デフォルト設定
;(setq *rss-item-show-description* t)

;;; 未読検索時の設定
; 既読の更新されたエントリも対象にするかどうか
;(setq *rss-search-unread-with-updated* t)
; 次の未読を見つけたらそれを開くかどうか
;(setq *rss-search-next-unread-open*  t)
; チャネル内に未読がなかった場合に次のチャネルを探しに行くかどうか
;(setq *rss-search-next-unread-menu*  t)
; グループ内に未読がなかった場合に次のグループを探しに行くかどうか
;(setq *rss-search-next-unread-group* t)

;;; キャッシュ
; 過去のエントリを含めn件までキャッシュする
;（デフォルトは過去のエントリをキャッシュしない）
;(setq *rss-cache-max-number* 30)
; 履歴をn件までキャッシュする（デフォルトは100件）
;(setq *rss-history-max-number* 200)
; クリップするエントリの上限（デフォルトは100件）
;(setq *rss-clip-max-number* 300)

;;; Hyper Estraierで検索（要hecmd）
;(require "rss/hyper-estraier")
;
;; hook でインデックス登録
;(add-hook '*rss-start-hook*      'he-init)
;(add-hook '*rss-finish-hook*     'he-sync)
;(add-hook '*rss-open-rss-hook*   'he-sync)
;(add-hook '*rss-fetch-data-hook* 'he-gather-entries)
;
;; キーバインド
;(define-key *rss-group-map*    #\/ 'he-search)
;(define-key *rss-menu-map*     #\/ 'he-search)
;(define-key *rss-mode-map*     #\/ 'he-search)
;(define-key *rss-clip-map*     #\/ 'he-search)
;(define-key *rss-history-map*  #\/ 'he-search)
;
;(define-key *rss-group-map* #\C 'he-group-gather-all)
;(define-key *rss-menu-map*  #\C 'he-menu-gather-all)

;;; 配色設定等
; グループ一覧タイトル
;(setq *rss-attribute-group-title* '(:bold t))
; グループ一覧
;(setq *rss-attribute-group* nil)
; グループ一覧（未読有り）
;(setq *rss-attribute-group-unread* '(:foreground 1))
; チャネル一覧タイトル
;(setq *rss-attribute-menu-title* '(:bold t))
; チャネル一覧
;(setq *rss-attribute-menu* nil)
; チャネル一覧（未読有り）
;(setq *rss-attribute-menu-unread* '(:foreground 1))
; エントリ一覧チャネル名
;(setq *rss-attribute-channel-title* '(:bold t))
; エントリ一覧チャネル Description
;(setq *rss-attribute-channel-description* nil)
; エントリタイトル（既読）
;(setq *rss-attribute-item-title* '(:bold nil
;				   :foreground 1))
; エントリタイトル（未読）
;(setq *rss-attribute-item-title-unread* '(:bold t
;					  :foreground 1))
; エントリ Description
;(setq *rss-attribute-item-description* nil)

;;; LIRS形式のフィルタ設定
;; 最大表示件数（多くすると遅い）
;(setq *lirs-items-max* 30)
;; フィルタをかけるURLのパターン
;; （デフォルトは "lirs.txt" "lirs.txt.gz" "lirs.gz" にマッチ）
;(setq *lirs-url-regexp* "lirs\\(\.txt\\|\.txt.gz\\|\.gz\\)$")
;; フィルタをかけるURLを登録
;(rss-filter-regist "登録するURL1" 'lirs-filter)
;(rss-filter-regist "登録するURL2" 'lirs-filter)

;;; hina-di形式のフィルタ設定
;; 最大表示件数（多くすると遅い）
;(setq *hina-di-items-max* 30)
;; フィルタをかけるURLのパターン
;; （デフォルトは "*.di" にマッチ）
;(setq *hina-di-url-regexp* "\.di$")
;; フィルタをかけるURLを登録
;(rss-filter-regist "登録するURL1" 'hina-di-filter)
;(rss-filter-regist "登録するURL2" 'hina-di-filter)

;;; hina.txt形式のフィルタ設定
;; 最大表示件数（多くすると遅い）
;(setq *hina-txt-items-max* 30)
;; フィルタをかけるURLのパターン
;; （デフォルトは "*.di" にマッチ）
;(setq *hina-txt-url-regexp* "\.di$")
;; フィルタをかけるURLを登録
;(rss-filter-regist "登録するURL1" 'hina-txt-filter)
;(rss-filter-regist "登録するURL2" 'hina-txt-filter)
