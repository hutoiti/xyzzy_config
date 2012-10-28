;;; -*- Mode: Lisp; Package: USER; Last updated: "2007/12/31 01:05:52" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   info-modoki-mode.l --- reference.txt 参照用モード
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  reference.txt を参照します。


■インストール

  1. info-modoki-mode.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. 「reference.txt」を手に入れ，etc フォルダにコピーする。

  4. キーワードファイル「lisp」を手に入れ，etc フォルダにコピーする。

  5. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "info-modoki-mode")

  「reference.txt」，キーワードファイル「lisp」は，

      http://hie.s64.xrea.com/xyzzy/note/use_reference.html

  から入手するか，reference.xml から佐野さんの xml2xxx.l などを使って作
  成するかしてください。


■使い方

    M-x imm1 : セレクションまたはカレントワードでリファレンスを参照
    M-x immr : タイトルを指定してリファレンスを参照
    M-x immf : 全文検索
    M-x imms : セクション検索
    M-x immt : キーワードにマッチするタイトル一覧を表示
    M-x immi : 目的別索引
    M-x immp : 既存のリファレンスバッファを表示
    M-x immg : セレクションまたはカレントワードで lisp フォルダを Grep（おまけ）
    C-x F1   : ポップアップメニューを表示


■キーバインド

  info-modoki-mode

    F1  : セレクションの文字列またはカーソル位置の単語を参照
    F4  : 関数の実態へタグジャンプ
    RET :     同  上
    r   : タイトルを指定してリファレンスを参照
    t   : キーワードを指定してタイトルを検索し，一覧を作成
    T   : セレクションの文字列またはカーソル位置の単語でタイトルを検索し，一覧を作成
    s   : セクション検索
    f   : 全文検索
    i   : 目的別索引表示
    M-left : 戻る
    h   : 参照履歴をポップアップで一覧表示
    g   : タイトルをキーに lisp フォルダを grep
    G   : カーソル位置の単語をキーに lisp フォルダを grep
    c   : タイトルをキルリングに追加
    b   : info-modoki-mode バッファをトグル
    q   : 終了
    Q   : 終了＆バッファ削除

    [全文検索/セクション検索バッファ用]
    l   : 全文検索でヒットした全タイトルをポップアップで一覧表示
    n   : 次の項目へ移動
    p   : 前の項目へ移動
    SPC : 次ページへ移動
    C-h : 前ページへ移動

  imm-summary-mode（タイトル一覧用マイナーモード）

    F1  : 現在行のタイトルを参照
    RET : 現在行のタイトルを参照
    TAB : 現在行のタイトルを参照（フォーカスは移動しない）
    SPC : 現在行のタイトルを参照＆スクロールまたは次行のタイトルを参照


■設定例

  F1 キーで，カーソル位置の単語（またはセレクションの文字列）を
  reference.txt から引く。

    (define-key ed::*lisp-mode-map* #\F1 'imm-refer-selection)
    (define-key ed::*lisp-interaction-mode-map* #\F1 'imm-refer-selection)


■更新履歴

  [Version 2.05] 2007-12-31 (月)
  ・MITライセンスにした。

  [Version 2.04] 2006-10-14 (Sat)
  ・reference.txt 20061001版のフォーマットに対応。
  ・*imm-section-list* 更新。

  [Version 2.03] 2005-06-12 (Sun)
  ・タグジャンプの対象検索方法の(手抜きな)修正等。

  [Version 2.02] 2005-06-11 (Sat)
  ・佐野さんから頂いた，関数の実態へタグジャンプできるパッチを
    取り込み。感謝です。m(_ _)m

  [Version 2.01] 2004-11-28 (Sun)
  ・OHKUBOさんの素早い御指摘によりimm-refer-selection の alias 
    を imm1 に変更した。(^^;

  [Version 2.00] 2004-11-27 (Sat)
  ・imm-refer を書き直した。（info-modoki.l からの引用をなくした。）
  ・ライセンスを NYSL とした。
  ・全文検索ができるようにした。
  ・指定セクション抽出ができるようにした。
  ・目的別索引を必要な部分だけ表示するようにした。
  ・使わなさげな機能を削除した。
  ・キーバインドをいくらか変更した。
  ・その他いろいろな変更。

  [Version 1.04] 2003/07/04 22:28:32 +0900
  ・imm-search で何もヒットしなかったときは，バッファを表示しな
    いようにした。
  ・apropos, describe-* な関数を info-modoki-mode で使ってみた。

  [Version 1.03] 2003/06/19 18:01:26 +0900
  ・imm-copy-title を追加した。
  ・imm-grep あたりの動作を少し変更した。

  [Version 1.02] 2003/06/11 23:08:46 +0900
  ・imm-grep-title は，info-modoki-mode でしか使わないのでそのよ
    うに，合わせて imm-grep も変更した。
  ・imm-grep-title 実行時にセレクションが存在していると，うまく
    動作していなかったのを修正した。
  ・imm-history-back を M-left にもバインドした。
  ・その他細かい変更。

  [Version 1.01] 2003/06/11 00:10:22 +0900
  ・(require "grepd") を追加した。

  [Version 1.00] 2003/06/10 06:19:12 +0900
  ・初版


■ライセンス

  info-modoki-mode.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

|#

(provide "info-modoki-mode")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定（適当にカスタマイズするあたり）
;;; ──────────────────────────────────── ;;;

;;; reference.txt のパス
(defvar *imm-reference-file* (merge-pathnames "etc/reference.txt"
					      (si:system-root)))

(defvar *info-modoki-mode-keyword-file* "lisp")

;;; imm-full-search 用キーワードの色（set-text-attribute）
(defvar *imm-atter-full-search* '(:foreground 1))

;;; imm-full-search 用セパレータ
(defvar *imm-full-search-sep*
  "#|((((((((((((((((((((((((((((((((( 亀 )))))))))))))))))))))))))))))))))|#")

;;; リファレンスのセクション一覧
(defvar *imm-section-list*
  '("データ型" "変数と定数" "制御構造" "パッケージ" "関数" "マクロ"
    "シンボル" "数値" "文字" "文字エンコーディング" "文字列" "シーケンス" "リスト"
    "ハッシュ" "配列" "チャンク" "評価" "入出力" "ファイルシステム" "エラー"
    "ウィンドウ" "バッファ" "ミニバッファ" "リージョン" "モード"
    "シンタックス" "キーマップ" "テキスト" "検索・正規表現" "ダイアログ"
    "日付・時間" "メニュー" "ファイラ" "ポジション" "プロセス"
    "システム" "その他" "未分類"))

;;; ──────────────────────────────────── ;;;
;;;  ■ その他の変数設定
;;; ──────────────────────────────────── ;;;

(defvar *imm-buffer* " *imm*")
(defvar *imm-buffer-refer* " *imm-refer*")
(defvar *imm-buffer-titles* " *imm-titles*")
(defvar *imm-buffer-search* " *imm-full-search*")

(defvar *info-modoki-mode-keyword-hash-table* nil)
(defvar *info-modoki-mode-hook* nil)
(defvar *info-modoki-mode-quit-hook* nil)
(defvar *info-modoki-mode-map* nil)

(defvar-local *imm-summary-mode* nil)
(defvar *imm-summary-mode-map* nil)

(defvar *imm-full-search-title-list* nil)
(defvar *imm-history* nil)
(defvar *imm-history-pointer* nil)
(defvar *imm-menu* nil)


;;; ──────────────────────────────────── ;;;
;;;  ■ リファレンス参照
;;; ──────────────────────────────────── ;;;

(defun imm-refer-selection ()
  "info-modoki-mode セレクションの文字列またはカレントワードを参照"
  (interactive)
  (let (str)
    (if (save-excursion
	  (goto-bol)
	  (and (eq buffer-mode 'info-modoki-mode)
	       (looking-at "^\\(■\\|  - \\)")))
	(imm-refer-from-title)
      (when (setf str (imm-keyword))
	(imm-refer str)))))

(defun imm-refer (str &optional nohistory otherwindow)
  "info-modoki-mode リファレンス照会"
  (interactive "sReference(regexp): ")
  (unless (equal str "")
    (let (b r)
      (save-excursion
	(setf b (imm-erase-buffer *imm-buffer-refer*))
	(imm-load)
	(with-output-to-buffer (b)
	  (when (scan-buffer (compile-regexp (concat "^■" (regexp-quote str) "[ \t]*$")))
	    (setf from (point))
	    (format t "~A"
		    (buffer-substring
		     (point)
		     (progn
		       (or (scan-buffer "^■" :regexp t :no-dup t)
			   (goto-char (point-max)))
		       (- (point) 2))))))
	(set-buffer b)
	(unless (eq (point-min) (point-max))
	  (unless nohistory
	    (setf *imm-history* (remove str *imm-history* :test #'equal))
	    (push str *imm-history*))
	  (setf r t)))
      (unless r
	(imm-msgbox str)
	(return-from imm-refer nil))
      (if (and (not otherwindow)
	       (eq buffer-mode 'info-modoki-mode))
	  (set-buffer b)
	(pop-to-buffer b t))
      (info-modoki-mode t)
      (goto-char (point-min)))))

(defun imm-show-index ()
  "info-modoki-mode 目的別索引表示"
  (interactive)
  (imm-refer "目的別索引"))


;;; ──────────────────────────────────── ;;;
;;;  ■ タイトル検索
;;; ──────────────────────────────────── ;;;

;;; ■つかってなーい
;;; セレクションがなければカレントワードを参照
(defun imm-titles-selection ()
  "info-modoki-mode セレクションの文字列からタイトル検索＆一覧を作成"
  (interactive)
  (let (str)
    (when (setf str (imm-keyword))
      (imm-titles str))))

(defun imm-titles (pattern)
  "info-modoki-mode タイトル検索＆一覧を作成"
  (interactive "sReference Titles (regexp): ")
  (unless (zerop (length pattern))
    (let (ptn b r)
      (setf ptn pattern)
      ;; 先頭一致の場合の処理
      (if (string-match "\\(\\^\\)\\(.*\\)" pattern)
	  (setf pattern (string-replace-match pattern "^■\\2"))
	(setf pattern (concat "^■.*" pattern)))
      (save-excursion
	(setf b (imm-erase-buffer *imm-buffer-titles*))
	(imm-load)
	(with-output-to-buffer (b)
	  (while (scan-buffer (compile-regexp pattern) :regexp t)
	    (format t "~A~%" (buffer-substring (progn (goto-bol)(point))
					       (progn (goto-eol)(point))))))
	(set-buffer b)
	(unless (eq (point-min) (point-max))
	  (setf r t)))
      (unless r
	(imm-msgbox ptn)
	(return-from imm-titles nil))
      (if (eq buffer-mode 'info-modoki-mode)
	  (set-buffer b)
	(pop-to-buffer b t))
      (info-modoki-mode)
      (imm-summary-mode))))


;;; ──────────────────────────────────── ;;;
;;;  ■ 全文検索
;;; ──────────────────────────────────── ;;;

(defun imm-full-search (pattern &optional nocolor)
  "info-modoki-mode 全文検索"
  (interactive "sReference Full-text search (regexp): ")
  (setf *imm-full-search-title-list* nil)
  (let (b r)
    (save-excursion
      (setf b (imm-erase-buffer *imm-buffer-search*))
      (imm-load)
      (with-output-to-buffer (b)
	(while (scan-buffer pattern :regexp t)
	  (scan-buffer "^■" :regexp t :reverse t)
	  (if (looking-at "^■関数一覧")
	      (return)
	    (pushnew (save-excursion
		       (buffer-substring (1+ (point))
					 (progn (goto-eol) (point))))
		     *imm-full-search-title-list* :test #'equal))
	  (format t "~A~%~A" *imm-full-search-sep*
		  (buffer-substring
		   (point)
		   (progn
		     (or (scan-buffer "^■" :regexp t :no-dup t)
			 (goto-char (point-max)))
		     (point))))))
      (set-buffer b)
      (unless (eq (point-min) (point-max))
	(setf r t)))
    (unless r
      (imm-msgbox pattern)
      (return-from imm-full-search nil))
    (if (eq buffer-mode 'info-modoki-mode)
	(set-buffer b)
      (pop-to-buffer b t))
    (info-modoki-mode t)
    (goto-char (point-min))
    ;; キーワードに着色
    (unless nocolor
      (save-excursion
	(while (scan-buffer pattern :regexp t :no-dup t)
	  (when (looking-at pattern)
	    (apply #'set-text-attribute (match-beginning 0) (match-end 0)
		   'imm
		   *imm-atter-full-search*)))))))

(defun imm-query-section ()
  "info-modoki-mode セクション検索"
  (interactive)
  (popup-list *imm-section-list*
	      #'(lambda (s)
		  (imm-full-search (regexp-quote (concat "[    section]: " s)) t)
		  (refresh-screen))))

(defun imm-popup-title-list (&optional arg)
  "info-modoki-mode 全文検索にヒットしたタイトル一覧"
  (interactive "p")
  (when (equal (buffer-name (selected-buffer))
	       *imm-buffer-search*)
    (let ((menu (create-popup-menu)) lst p)
      (setf lst (if arg
		    (sort (copy-tree *imm-full-search-title-list*)
			  #'string-lessp)
		  (reverse (copy-tree *imm-full-search-title-list*))))
      (save-excursion
	(goto-bol)
	(when (looking-for *imm-full-search-sep*)
	  (next-line))
	(scan-buffer "^■" :regexp t :reverse t :tail t)
	(setf p (string-right-trim " \t" (buffer-substring (point) (progn (goto-eol) (point))))))
      (dolist (item lst)
	(let ((s item))
	  (add-menu-item menu nil s
			 #'(lambda () (interactive)
			     (goto-char (point-min))
			     (scan-buffer
			      (compile-regexp (concat "^■" (regexp-quote s) "[ \t]*$")))
			     (previous-line)
			     (recenter 0))
			 #'(lambda ()
			     (when (string= s p) :check))
			 )))
      (track-popup-menu menu))))


;;; ──────────────────────────────────── ;;;
;;;  ■ info-modoki-mode
;;; ──────────────────────────────────── ;;;

(unless *info-modoki-mode-map*
  (setf *info-modoki-mode-map* (make-sparse-keymap))
  (define-key *info-modoki-mode-map* '#\F1  'imm-refer-selection)
  (define-key *info-modoki-mode-map* '#\RET 'imm-refer-selection)
  (define-key *info-modoki-mode-map* '#\r   'imm-refer)
  (define-key *info-modoki-mode-map* '#\f   'imm-full-search)
  (define-key *info-modoki-mode-map* '#\t   'imm-titles)
  (define-key *info-modoki-mode-map* '#\T   'imm-titles-selection)
  (define-key *info-modoki-mode-map* '#\s   'imm-query-section)
  (define-key *info-modoki-mode-map* '#\i   'imm-show-index)
  (define-key *info-modoki-mode-map* '#\M-Left 'imm-history-back)
  (define-key *info-modoki-mode-map* '#\h   'imm-popup-history)
  (define-key *info-modoki-mode-map* '#\l   'imm-popup-title-list)
  (define-key *info-modoki-mode-map* '#\g   'imm-grep-title)
  (define-key *info-modoki-mode-map* '#\G   'imm-grep)
  (define-key *info-modoki-mode-map* '#\c   'imm-copy-title)
  (define-key *info-modoki-mode-map* '#\q   'imm-quit)
  (define-key *info-modoki-mode-map* '#\Q   'imm-quit-and-delete-buffer)
  (define-key *info-modoki-mode-map* '#\n   'imm-next-node)
  (define-key *info-modoki-mode-map* '#\p   'imm-previous-node)
  (define-key *info-modoki-mode-map* '#\SPC 'next-page)
  (define-key *info-modoki-mode-map* '#\C-h 'previous-page)
  (define-key *info-modoki-mode-map* '#\b   'imm-switch-to-buffer)
  )

(defun info-modoki-mode (&optional full-search)
  (interactive)
  (kill-all-local-variables)
  (setf buffer-mode 'info-modoki-mode)
  (setf mode-name "info-modoki-mode")
  (use-keymap *info-modoki-mode-map*)
  (use-syntax-table ed::*lisp-mode-syntax-table*)
  (and *info-modoki-mode-keyword-file*
       (null *info-modoki-mode-keyword-hash-table*)
       (setf *info-modoki-mode-keyword-hash-table*
	     (load-keyword-file *info-modoki-mode-keyword-file* t)))
  (when *info-modoki-mode-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setf keyword-hash-table *info-modoki-mode-keyword-hash-table*))
  ;; タグジャンプ用
  (set-default-directory (merge-pathnames "lisp" (si:system-root)))
  (make-local-variable 'tags-find-target)
  (setf tags-find-target #'imm-tags-find-target)
  (make-local-variable 'tags-find-point)
  (setf tags-find-point #'ed::lisp-tags-find-point)
  ;; バッファの状態を調整
  (setf need-not-save t)
  (setf kept-undo-information nil)
  (setf auto-save nil)
  (setf hide-restricted-region t)
  (set-buffer-modified-p nil)
  (setf buffer-read-only t)
  ;(setf ed::*paren-status* nil)
  (when (member "paren" *modules* :test #'string=)
    (setf ed::*paren-status* nil))
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf (+ *window-flag-newline*
				   *window-flag-tab*
				   *window-flag-full-width-space*
				   *window-flag-eof*
				   *window-flag-line-number*
				   *window-flag-half-width-space*
				   *window-flag-scrolling*)
			    nil)
    (set-local-window-flags buf (+ (if (boundp '*window-flag-fold-mark*)
				       *window-flag-fold-mark*
				     *window-flag-fold-line*))
			    t))
  (run-hooks '*info-modoki-mode-hook*))

;;; 現在地点と関連する関数名の切り出し
(defun imm-tags-find-target ()
  (let* ((opoint (point))
	 (name (progn
		 (scan-buffer "■\\(.+\\)$" :regexp t :reverse t)
		 (match-string 1)
		 ))
	 (functionp (progn
		      (scan-buffer "\\[       type\\]: \\(.+\\)$" :regexp t)
		      (when (member (match-string 1)
				    '("Special Form" "Accessor" "Macro" "Function")
				    :test 'equal) t))
		    ))
    (goto-char opoint)
    (values nil name functionp)))

(defun imm-history-back ()
  "info-modoki-mode リファレンス参照履歴を遡る"
  (interactive)
  (let (h p s)
    (setf h *imm-history*)
    (if (eq *last-command* 'imm-history-back)
	(setf p (cdr *imm-history-pointer*))
      (setf p (cdr h)))
    (save-excursion
      (goto-char (point-min))
      (if (looking-at "^■目的別索引")
	  (setf s (car h)
		*imm-history-pointer* h)
	(setf s (car p)
	      *imm-history-pointer* p)))
    (if (zerop (length s))
	(message "ないよん")
      (imm-refer s t))))

(defun imm-popup-history ()
  "info-modoki-mode リファレンス参照履歴一覧"
  (interactive)
  (let ((menu (create-popup-menu nil))
	(i 0))
    (dolist (item *imm-history*)
      (when (> i 15)
	(return nil))
      (let ((title item))
	(add-menu-item menu nil
		       title
		       #'(lambda () (interactive)
			   (imm-refer title t))))
      (setf i (1+ i)))
    (track-popup-menu menu)))

(defun imm-copy-title ()
  "info-modoki-mode タイトルをキルリングに追加"
  (interactive)
  (when (eq buffer-mode 'info-modoki-mode)
    (let ((str (imm-title)))
      (unless (zerop (length str))
	(ed::kill-new str)
	(message "title copied")))))

(defun imm-quit (&optional arg)
  "info-modoki-mode 終了"
  (interactive "p")
  (when (eq buffer-mode 'info-modoki-mode)
    (when arg
      (close-selected-buffer))
    (if (> (count-windows) 1)
	(delete-window)
      (unless arg
	(previous-buffer)))
    (run-hooks '*info-modoki-mode-quit-hook*)))

(defun imm-quit-and-delete-buffer ()
  "info-modoki-mode 終了＆バッファ削除"
  (interactive)
  (imm-quit t))

(defun imm-next-node (&optional previous)
  "info-modoki-mode 全文検索バッファで次の項目に移動"
  (interactive)
  (scan-buffer *imm-full-search-sep* :no-dup t :reverse previous)
  (recenter 0))

(defun imm-previous-node (&optional previous)
  "info-modoki-mode 全文検索バッファで前の項目に移動"
  (interactive)
  (imm-next-node t))

(defun imm-switch-to-buffer ()
  "info-modoki-mode リファレンスバッファを切替"
  (interactive)
  (let ((lst (list *imm-buffer-refer* *imm-buffer-titles* *imm-buffer-search*)))
    (if (eq buffer-mode 'info-modoki-mode)
	;; リファレンスバッファを切替
	(progn
	  (while (not (equal (buffer-name (selected-buffer)) (car lst)))
	    (let ((x (pop lst)))
	      (setf lst (nconc lst (list x)))))
	  (dolist (b (cdr lst))
	    (when (find-buffer b)
	      (set-buffer b)
	      (return))))
      ;; 既存のリファレンスバッファを表示
      (dolist (b lst)
	(when (find-buffer b)
	  (pop-to-buffer b t)
	  (return))))))


;;; ──────────────────────────────────── ;;;
;;;  ■ imm-summary-mode
;;; ──────────────────────────────────── ;;;

(unless *imm-summary-mode-map*
  (setf *imm-summary-mode-map* (make-sparse-keymap))
  (define-key *imm-summary-mode-map* '#\TAB 'imm-view)
  (define-key *imm-summary-mode-map* '#\SPC 'imm-view-next))

(defun imm-summary-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*imm-summary-mode* arg sv)
  (update-mode-line t)
  (if *imm-summary-mode*
      (set-minor-mode-map *imm-summary-mode-map*)
    (unset-minor-mode-map *imm-summary-mode-map*))
  t)

(pushnew '(*imm-summary-mode* . "imm-titles") *minor-mode-alist* :key #'car)

(defun imm-view ()
  "info-modoki-mode 現在行のタイトルを参照"
  (interactive)
  (when (imm-refer-from-title t)
    (other-window -1)))

(defun imm-view-next ()
  "info-modoki-mode 現在行のタイトルを参照＆スクロールまたは次行のタイトルを参照"
  (interactive)
  (let ((s (imm-title)))
    (if (eq *last-command* 'imm-view-next)
	(progn
	  (other-window 1)
	  (let ((r (next-page)))
	    (recenter)
	    (other-window -1)
	    (unless r
	      (next-line)
	      (imm-view))))
      (imm-view))))

;;; 索引名またはタイトルを参照
(defun imm-refer-from-title (&optional otherwindow)
  (let (beg end)
    (save-excursion
      (setf end (progn
		  (goto-eol)
		  (point)))
      (setf beg (progn
		  (goto-bol)
		  (cond ((looking-at "^  - ")
			 (forward-char 4))
			((looking-at "^■")
			 (forward-char 1))
			(t
			 (return-from imm-refer-from-title nil)))
		  (point))))
    (unless (= beg end)
      (imm-refer (buffer-substring beg end) nil otherwindow)))
  t)


;;; ──────────────────────────────────── ;;;
;;;  ■ Grep
;;; ──────────────────────────────────── ;;;

(require "grepd")

(defun imm-grep (&optional keyword)
  "info-modoki-mode lisp フォルダを Grep"
  (interactive)
  (let ((key (if keyword keyword (imm-keyword))))
    (ed::scan-files key "*.l" (merge-pathnames "lisp" (si:system-root)))))

(defun imm-grep-title ()
  "info-modoki-mode タイトルをキーに lisp フォルダを Grep"
  (interactive)
  (when (eq buffer-mode 'info-modoki-mode)
    (imm-grep (imm-title))))


;;; ──────────────────────────────────── ;;;
;;;  ■ apropos, describe
;;; ──────────────────────────────────── ;;;

(defun imm-apropos ()
  (interactive)
  (call-interactively #'apropos)
  (info-modoki-mode))

(defun imm-command-apropos ()
  (interactive)
  (call-interactively #'command-apropos)
  (info-modoki-mode))

(defun imm-describe-key ()
  (interactive)
  (call-interactively #'describe-key)
  (when (equal (buffer-name (selected-buffer)) "*Help*")
    (info-modoki-mode)))

(defun imm-describe-bindings ()
  (interactive)
  (call-interactively #'describe-bindings)
  (info-modoki-mode))


;;; ──────────────────────────────────── ;;;
;;;  ■ 補助関数
;;; ──────────────────────────────────── ;;;

;;; カーソル位置の単語またはセレクションの文字列を返す
(defun imm-keyword ()
  (let ((str nil)
	beg end)
    (if (pre-selection-p)
	(selection-start-end (b e)
	  (setf beg b
		end e))
      (save-excursion
	(setf end (progn
		    (or (skip-syntax-spec-forward "w_")
			(skip-syntax-spec-backward "^w_"))
		    (point)))
	(setf beg (progn
		    (skip-syntax-spec-backward "w_")
		    (point)))))
    (setf str (if (= beg end) "" (buffer-substring beg end)))
    str))

;;; タイトルを返す
(defun imm-title ()
  (save-excursion
    (stop-selection)
    (goto-char (point-min))
    (forward-char 1)
    (imm-keyword)))

;;; リファレンスのロード
(defun imm-load ()
  (set-buffer (or (find-buffer *imm-buffer*)
		  (let ((b (create-new-buffer *imm-buffer*)))
		    (set-buffer b)
		    (insert-file-contents *imm-reference-file*)
		    b)))
  (goto-char (point-min)))

;;; 指定したバッファの内容を削除
(defun imm-erase-buffer (buffer)
  (let ((b (switch-to-buffer buffer)))
    (setf buffer-read-only nil)
    (erase-buffer b)
    b))

;;; キーワードが見つからなかった場合のメッセージ
(defun imm-msgbox (str)
  (case (apply 'message-box
	       `(,(concat str "\n\nキーワードが見つからんけど，なんかする？")
		 "info-modoki-mode" nil
		 :button1 "しない(&C)"
		 :button2 "タイトル検索(&T)"
		 :button3 "全文検索(&F)"
		 :button4 "目的別索引(&I)"
		 ))
    (:button1 nil)
    (:button2 (imm-titles str))
    (:button3 (imm-full-search str))
    (:button4 (imm-show-index))))


;;; ──────────────────────────────────── ;;;
;;;  ■ Menu
;;; ──────────────────────────────────── ;;;

(defun imm-menu ()
  (interactive)
  (unless *imm-menu*
    (setf *imm-menu*
	  (define-popup-menu
	    (:item nil "リファレンス参照(&R)"                 'imm-refer)
	    (:item nil "リファレンス全文検索(&F)"             'imm-full-search)
	    (:item nil "リファレンスセクション検索(&S)"       'imm-query-section)
	    (:item nil "リファレンスタイトル検索(&T)"         'imm-titles)
	    (:item nil "セレクションの文字列を参照(&1)"       'imm-refer-selection)
	    (:item nil "既存のリファレンスバッファを表示(&P)" 'imm-switch-to-buffer)
	    :sep
	    (:item nil "セレクションの文字列でLispフォルダをGrep(&G)" 'imm-grep)
	    :sep
	    (:item nil "apropos(&A)"         'imm-apropos)
	    (:item nil "command-apropos(&C)" 'imm-command-apropos)
	    (:item nil "describe-key(&K)"    'imm-describe-key)
	    (:item nil "describe-describe-bindings(&B)" 'imm-describe-bindings)
	    )))
  (track-popup-menu *imm-menu*))

(global-set-key '(#\C-x #\F1) 'imm-menu)


;;; ──────────────────────────────────── ;;;
;;;  ■ alias
;;; ──────────────────────────────────── ;;;

(setf (symbol-function 'imm1) #'imm-refer-selection)
(setf (symbol-function 'immr) #'imm-refer)
(setf (symbol-function 'immf) #'imm-full-search)
(setf (symbol-function 'imms) #'imm-query-section)
(setf (symbol-function 'immt) #'imm-titles)
(setf (symbol-function 'immi) #'imm-show-index)
(setf (symbol-function 'immp) #'imm-switch-to-buffer)
(setf (symbol-function 'immg) #'imm-grep)


;;; info-modoki-mode.l ends here.
