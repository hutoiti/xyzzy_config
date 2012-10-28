#|
This file is not part of xyzzy.

    generic-comment-toggle.l --- 汎用コメント&アンコメント を行う

        by bove-crach

■概要

    バッファモード毎のコメントアウトorアンコメントを行います
    要は HIEさんのページのNOTE->編集->1 行コメントをトグル を改造しただけです
        HIEさん多謝！
            HIE no Page          : http://hie.s64.xrea.com/
            1 行コメントをトグル : http://hie.s64.xrea.com/xyzzy/note/edit.html#toggle-one-line-comment

■インストール

    1. generic-comment-toggle.l を site-lisp にコピーする。

    2. 必要に応じ，バイトコンパイルする。
        M-x byte-compile-file

    3. .xyzzy か siteinit.l に以下の記述を追加する。
        (require "generic-comment-toggle")

■使い方

    M-x generic-comment-toggle                  : コメントアウトorアンコメントを行う
    M-x generic-comment-toggle-region           : リージョンのコメントアウトorアンコメントを行う
    M-x generic-comment-toggle-region-rectangle : リージョンを矩形としてコメントアウトorアンコメントを行う
    M-x generic-comment-toggle-comment-out      : コメントアウトを行う
    M-x generic-comment-toggle-uncomment        : アンコメントを行う

    通常は必要ありませんが、以下の要領でモード毎のコメントを追加できます
        (push ("モード名" "コメント開始文字" "コメント終了文字" "コメント無効化文字" "改行がある場合の挿入文字")
                 *generic-comment-list*)

    一行コメントの場合は以下のように設定
        例：lisp-mode
        (push (lisp-mode ";;" "" "" ";;" ) *generic-comment-list*)

    囲みコメントの場合は以下のように設定
        例：c-mode
        (push (c-mode "/* " " */" "+" " * ") *generic-comment-list*)

■キーバインド

    特に指定していません

■設定例

    Ctrl + ; キーでセレクションまたは1行のコメントアウトorアンコメントを行う
        (global-set-key #\C-; 'generic-comment-toggle)

■ライセンス

    generic-comment-toggle.l は NYSL Version 0.9982 に従います。


NYSL Version 0.9982  http://www.kmonos.net/nysl/
----------------------------------------

A. 本ソフトウェアは Everyone'sWare です。このソフトを手にした一人一人が、
   ご自分の作ったものを扱うのと同じように、自由に利用することが出来ます。

  A-1. フリーウェアです。作者からは使用料等を要求しません。
  A-2. 有料無料や媒体の如何を問わず、自由に転載・再配布できます。
  A-3. いかなる種類の 改変・他プログラムでの利用 を行っても構いません。
  A-4. 変更したものや部分的に使用したものは、あなたのものになります。
       公開する場合は、あなたの名前の下で行って下さい。

B. このソフトを利用することによって生じた損害等について、作者は
   責任を負わないものとします。各自の責任においてご利用下さい。

C. 著作者人格権は bove-crach に帰属します。著作権は放棄します。

D. 以上の３項は、ソース・実行バイナリの双方に適用されます。


NYSL Version 0.9982 (en) (Unofficial)
----------------------------------------
A. This software is "Everyone'sWare". It means:
  Anybody who has this software can use it as if you're
  the author.

  A-1. Freeware. No fee is required.
  A-2. You can freely redistribute this software.
  A-3. You can freely modify this software. And the source
      may be used in any software with no limitation.
  A-4. When you release a modified version to public, you
      must publish it with your name.

B. The author is not responsible for any kind of damages or loss
  while using or misusing this software, which is distributed
  "AS IS". No warranty of any kind is expressed or implied.
  You use AT YOUR OWN RISK.

C. Copyrighted to bove-crach.

D. Above three clauses are applied both to source and binary
  form of this software.


■機能考察

 コメントトグル考察
 1.コメントとは何か
     コメントは以下のようなものがある
     例１
         // コメント
     例２
         /* コメント */
     例３
         /* コメント
          * コメント */
     例４
         /* コメント /+* コメント *+/ */

 2.何をしたいのか
     a.カーソルのある行を丸ごとコメントアウトしたい
     b.文がインデントされている場合は、インデントを考慮してコメントアウトしたい
       例  かんたら                  /* かんたら */
             どうたら        ->        /* どうたら */
               こうたら                  /* こうたら */

     c.カーソルのある行がコメントアウト中ならば、アンコメントしたい
     d.セレクションまたはリージョンで囲まれた一文をコメントアウトしたい
       例    こめんとあう<としまっせ>        <と>でセレクションされている場合
                 ↓
             こめんとあう/* としまっせ */    となる

     e.セレクションまたはリージョンで囲まれた一文がコメントアウトされていたらアンコメントしたい
     f.複数行のコメントアウトの場合、インデント後の先頭にコメントと分かる文字を入れたい
     g.複数行のコメントアウトの場合、インデントを考慮して以下のようなコメントアウトとしたい
       例  なんたら                  なんたら
           かんたら                  /* かんたら
             どうたら        ->       *   どうたら
               こうたら               *     こうたら
             ふむふむ                 *   ふむふむ */

     h.矩形選択されている場合、全ての行にコメントを入れたい
       例  なんたら                  なんたら
           かんたら                  かん/* たら */
             どうたら        ->        ど/* うたら */
               こうたら                  /* こうたら */
             ふむふむ                  ふ/* むふむ */

     i.コメントアウトする文字列の中に、すでにコメントアウトされている文があったら、
       途中のコメントアウトを無効化してからコメントアウトして欲しい
       例  コメント /* コメント */
             ↓
           /* コメント /+* コメント *+/ */

     j.アンコメント時にコメント無効化を解除して欲しい
       例  /* コメント /+* コメント *+/ */
             ↓
           コメント /* コメント */

 3.本品の守備範囲
 先ほど挙げた「2.」のような機能を全て有する

■更新履歴

    [Version 3.00] 2007.12.02
    ・さらにさらに処理最適化
    ・コメントアウト/アンコメントする度に行っていた(set-comment-words)を、
      最小限になるように。
	・パッケージを解除。独自のものにしようかと思うが保留

    [Version 2.01] 2007.03.24
    ・インデントなんて考慮すんな…って声を聞いたので、選択できるように。
    ・さらに処理最適化

    [Version 2.00] 2007.03.19
    ・秘密公開
    ・ほぼ完全改修
    ・矩形範囲のコメントアウトを実装
    ・とりあえず完成ということで、パッケージをeditorに設定
    ・コメント無効化文字列を分割して作成するように変更
    ・コメント無効化が複数回行われても、矛盾が発生しないように修正
    ・mmm-modeを考慮し、set-comment-wordsの呼び出しを無制限に変更
    ・改行時挿入文字が nil の場合にエラーとなっていたのを修正
    ・ゴールカラムを保存するように修正(多分いらない・・・)
    ・全体的に処理を最適化(途中)

    [Version 1.01] 2006.12.24
    ・アンコメントの動作を、「コメント開始文字とコメント終了文字だけ削除」から、
      「有効範囲内にあるコメント開始文字とコメント終了文字を削除」に変更
    ・公開関数に以下のものを追加
        1.generic-comment-toggle-comment-out
        2.generic-comment-toggle-uncomment

    [Version 1.00] 2006.12.16
    ・初版
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   おまじない
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide "generic-comment-toggle")

;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (unless (find-package "generic-comment-toggle")
;;     (defpackage "generic-comment-toggle"
;;       (:nicknames "gct")
;;       (:use "lisp" "editor"))))
;; (in-package "generic-comment-toggle")

(export '(;; variable
		  *generic-comment-list*
		  *generic-comment-toggle-before-hook*
		  *generic-comment-toggle-after-hook*
		  ;; function
		  generic-comment-toggle
		  generic-comment-toggle-region
		  generic-comment-toggle-region-rectangle
		  generic-comment-toggle-comment-out
		  generic-comment-toggle-uncomment
		  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   変数定義(公開用)
;;;;;;;;;;;;;;;;
;; メジャーモード毎にコメントをリスト登録
;; コメントリスト内容
;; '("モード名" "コメント開始文字" "コメント終了文字" "コメント無効化文字" "改行がある場合の挿入文字")
(defvar *generic-comment-list* nil
  ; 指定の仕方
  ; (lisp-mode ";; "  ""    ""  ";; " )
  ; (c-mode    "/* " " */" "+" " * ")
  )
;; インデントを考慮する
(defvar *generic-comment-indent-consideration* t)
;; 一応 HOOKとか入れとく（使い道は・・・）
(defvar *generic-comment-toggle-before-hook* nil)
(defvar *generic-comment-toggle-after-hook*  nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   変数定義(内部用)
;;;;;;;;;;;;;;;;
;; コメント文字受け口
(defvar comment-head          nil) ; コメント開始文字
(defvar comment-tail          nil) ; コメント終了文字
(defvar comment-invalid       nil) ; コメント無効化文字
(defvar comment-split         nil) ; コメント中の改行時挿入文字
;; コメント無効化文字列を保持っとく
(defvar regexp-head-invalid   nil) ; コメント開始文字の正規表現
(defvar regexp-tail-invalid   nil) ; コメント終了文字の正規表現
(defvar regexp-head-uninvalid nil) ; コメント開始文字の無効化正規表現
(defvar regexp-tail-uninvalid nil) ; コメント終了文字の無効化正規表現
;; 前回動作時のモード（set-comment-words の呼び出しを最小限に）
(defvar *generic-comment-before-mode* nil)
;; コメントアウト or アンコメントステータス
;; 1:任意 2:コメントアウト 3:アンコメント
;; 通常は 1
(defvar *comment-status* 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   公開関数 (第１層)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun generic-comment-toggle ( &optional (*region-status* nil) )
  "コメントアウトorアンコメントを行う"
  (interactive)
  ;; 現在のバッファに登録されているコメント文字を受け取る
  (unless (eq *generic-comment-before-mode* buffer-mode)
	(set-comment-words))
  (run-hooks '*generic-comment-toggle-before-hook*)
  (let ((goal-column (goal-column)) start end)
	(save-excursion
	  (save-restriction
		;; セレクション選択中
		(cond
		 ((get-selection-type)
		  (case (get-selection-type)
			;; 行モード選択
			;; 文字モード選択
			((1 2) (generic-comment-toggle-normal (selection-mark) (selection-point)))
			;; 矩形選択
			(3 (generic-comment-toggle-rectangle (selection-mark) (selection-point)))))
		 ;; リージョン選択中
		 ((and *region-status* (mark))
		  (case *region-status*
			;; 通常選択
			(1 (generic-comment-toggle-normal (mark) (point)))
			;; 矩形選択
			(2 (generic-comment-toggle-rectangle (mark) (point)))))
		 ;; 1行コメント
		 (t
		  ;; 現在行の行頭と行末を保存
		  (goto-bol)
		  (when *generic-comment-indent-consideration* (back-to-indentation))
		  (setf start (point))
		  (goto-eol)
		  (setf end (point))
		  (generic-comment-toggle-normal start end)))
		))
	(set-goal-column goal-column))
  (run-hooks '*generic-comment-toggle-after-hook*))

(defun generic-comment-toggle-region()
  "リージョンのコメントアウトorアンコメントを行う"
  (interactive)
  ;; リージョンの操作方法を通常選択とする
  (generic-comment-toggle 1))

(defun generic-comment-toggle-region-rectangle()
  "リージョンを矩形選択としてコメントorアンコメントを行う"
  (interactive)
  ;; リージョンの選択方法を矩形選択とする
  (generic-comment-toggle 2))

(defun generic-comment-toggle-comment-out()
  "コメントアウトを行う"
  (interactive)
  ;; コメント設定をコメントアウトとする
  (setf *comment-status* 2)
  (generic-comment-toggle nil)
  (setf *comment-status* 1))

(defun generic-comment-toggle-uncomment()
  "アンコメントを行う"
  (interactive)
  ;; コメント設定をアンコメントとする
  (setf *comment-status* 3)
  (generic-comment-toggle nil)
  (setf *comment-status* 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   内部関数 (第２層)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun set-comment-words()
;;; コメント文字をセットする
  (let ((comment-list (find buffer-mode *generic-comment-list* :key #'car)))
	(cond
	 ;; もし *generic-comment-list* にモードが登録されていたらそちらを使う
	 (comment-list
	  (setf comment-head    (nth 1 comment-list)) ; コメント開始文字
	  (setf comment-tail    (nth 2 comment-list)) ; コメント終了文字
	  (setf comment-invalid (nth 3 comment-list)) ; コメント無効化文字
	  (setf comment-split   (nth 4 comment-list)) ; コメント中の改行時挿入文字
	  )
	 (t ;; 現在モードから登録されているコメント文字を引っ張ってくる
	  (setf comment-head    comment-start) ; コメント開始文字
	  (setf comment-tail    comment-end  ) ; コメント終了文字
	  ;; 無効化文字と改行挿入文字は初期値を入れておく
	  (setf comment-invalid "+"          ) ; コメント無効化文字
	  (setf comment-split   ""           ) ; コメント中の改行時挿入文字
	  ;; comment-tail が空文字の時は、C++系コメントなので
	  ;; comment-invalid がいらない かつ comment-split は comment-head である
	  (when (string= comment-tail "")
		(setf comment-invalid "")
		(setf comment-split comment-head))
	  )))
;;; コメント文字チェック
  ;; comment-head が空文字の時は、そもそもコメントにできない
  (when (or (string= comment-head "")
			(not comment-head) )
	(setf comment-head nil comment-tail nil comment-invalid nil comment-split nil)
	(plain-error "コメント開始文字が空文字なんで、コメントにできませんが？"))
;;; コメント無効化文字列の作成
  ;; comment-invalid が "" でない かつ コメント文字長が2以上なら作る
  (let ((head (string-trim " \t" comment-head))
		(tail (string-trim " \t" comment-tail)))
	(when (and (not (string= comment-invalid ""))
			   (> (length head) 1)
			   (> (length tail) 1))
	  (setf regexp-head-invalid
			(format nil "\\(~A\\)\\(~A*~A\\)"
					(regexp-quote (substring head 0 1))
					(regexp-quote comment-invalid)
					(regexp-quote (substring head 1))))
	  (setf regexp-head-uninvalid
			(format nil "\\(~A\\)~A\\(~A*~A\\)"
					(regexp-quote (substring head 0 1))
					(regexp-quote comment-invalid)
					(regexp-quote comment-invalid)
					(regexp-quote (substring head 1))))
	  (setf regexp-tail-invalid
			(format nil "\\(~A~A*\\)\\(~A\\)"
					(regexp-quote (substring tail 0 1))
					(regexp-quote comment-invalid)
					(regexp-quote (substring tail 1))))
	  (setf regexp-tail-uninvalid
			(format nil "\\(~A~A*\\)~A\\(~A\\)"
					(regexp-quote (substring tail 0 1))
					(regexp-quote comment-invalid)
					(regexp-quote comment-invalid)
					(regexp-quote (substring tail 1))))
	  ))
;;; コメント文字列の生成が完了したので、現在バッファモードを保存する
  (setf *generic-comment-before-mode* buffer-mode)
  )

(defun generic-comment-toggle-normal( start end )
  "通常選択のコメントアウトorアンコメントを行う"
  ;; コメントアウトかアンコメントか判断
  (if (generic-comment-toggle-sub-setup start end)
	  ;; コメントアウトする
	  (generic-comment-toggle-sub-comment-out)
	;; アンコメントする
	(generic-comment-toggle-sub-uncomment)))

(defun generic-comment-toggle-rectangle( start end )
  "矩形選択のコメントアウトorアンコメントを行う"
  ;; コメントアウトかアンコメントか判断
  (let (func  goalcolumn  start-line start-coluwm  end-line  work-data)
	(if (generic-comment-toggle-sub-setup start end)
		(setf func 'generic-comment-toggle-sub-comment-out)
	  (setf func 'generic-comment-toggle-sub-uncomment))
;;; 必要な情報を設定
	(setf goalcolumn (goal-column))
	(goto-char start)
	(setf start-line (current-virtual-line-number))
	(setf start-coluwm (current-virtual-column))
	(goto-char end)
	(setf end-line (current-virtual-line-number))
;;; 処理範囲を確定して実行
	(do ((counta start-line (incf counta)))
		;; 終了位置の行を超えたら終了
		((> counta end-line))
	  (widen)
	  (goto-virtual-line counta)
	  (goto-virtual-column start-coluwm)
	  (setf work-data (point))
	  (goto-virtual-column goalcolumn)
	  ;; 漢字とかあるとたまに行き過ぎるので、戻る
	  (when (> (current-virtual-column) goalcolumn)
		(backward-char))
	  (narrow-to-region work-data (point))
	  (funcall func)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   内部関数 (第３層)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun generic-comment-toggle-sub-setup(start end)
  "comment-out,uncommentの共通処理抜き出し"
  (let (string-that-comments keyreg which-proc)
	;; start > end だと何かと不便なので、start <= end に統一
	(if (> start end)  (rotatef start end))
	;; ナローイングを行い、編集箇所を指定する
	(narrow-to-region start end)
	;; 文字列を取得
	(setf string-that-comments (buffer-substring (point-min) (point-max)))
	;; 複数行の可能性があるので、1行にしてしまう
	(setf string-that-comments (substitute-string string-that-comments "\n" ""))
	;; コメントアウトかアンコメントか判断
	(setq keyreg (format nil "^\\(~A\\)+\\(.*\\)\\(~A\\)+$"
						 (regexp-quote (string-trim " \t" comment-head))
						 (regexp-quote (string-trim " \t" comment-tail))))
	(if (string-looking-at keyreg string-that-comments)
		(setf which-proc nil)
	  (setf which-proc t))
	;; *comment-status*の設定により最終判断
	(case *comment-status*
	  (2 (setf which-proc t))
	  (3 (setf which-proc nil)))
	which-proc
	))

(defun generic-comment-toggle-sub-comment-out()
  "文字列のコメントアウトを行う"
  (unless *executing-macro*
	(message "comment-out"))
  ;; すでにコメントがある場合、コメント無効化を行う
  (when regexp-head-invalid
	(let ((work (format nil "\\1~A\\2" (regexp-quote comment-invalid))))
	  (goto-char (point-min))
	  (replace-buffer regexp-head-invalid work :regexp t)))
  (when regexp-tail-invalid
	(let ((work (format nil "\\1~A\\2" (regexp-quote comment-invalid))))
	  (goto-char (point-min))
	  (replace-buffer regexp-tail-invalid work :regexp t)))
  ;; インデント位置を考慮したコメントアウトを行うので、挿入位置を求める
  ;; (point-max)位置に移動して、終了位置の表示行番号を保存
  (goto-char (point-max))
  (setf comment-end-line (current-virtual-line-number))
  (setf point-end (point))
  ;; (point-min)位置に移動して、開始位置の表示行番号を保存
  (goto-char (point-min))
  (setf comment-start-line (current-virtual-line-number))
  (setf comment-start-coluwm (current-virtual-column))
  ;; インデントの最小桁数を算出
  (do ((counta comment-start-line (incf counta)))
	  ;; 終了位置の行を超えたら終了
	  ((> counta comment-end-line))
	;; counta 行目の先頭行に移動
	(goto-virtual-line counta)
	(goto-virtual-bol)
	;; コメント基準桁が現在桁より大きかったら桁を入れ替える
	(if (> comment-start-coluwm (current-virtual-column))
		(setf comment-start-coluwm (current-virtual-column))))
  ;; 先頭と末尾にコメントキーを挿入する
  (goto-char (point-max))
  (insert comment-tail)
  (goto-char (point-min))
  (goto-column comment-start-coluwm)
  (insert comment-head)
  ;; コメント範囲に改行が含まれるなら
  (when (and (> comment-end-line comment-start-line)
			 (not (string= comment-split "")))
	(let (start-position end-position)
	  (goto-virtual-line (+ comment-start-line 1))
	  (goto-column comment-start-coluwm)
	  (setf start-position (point))
	  (goto-virtual-line comment-end-line)
	  (goto-column comment-start-coluwm)
	  (setf end-position (point))
	  ;; コメント中の改行時挿入文字を挿入する
	  (string-rectangle start-position end-position comment-split)))
  )

(defun generic-comment-toggle-sub-uncomment()
  "文字列のアンコメントを行う"
  (unless *executing-macro*
	(message "uncomment"))
  ;; 先頭のコメントキーを削除する
  (goto-char (point-min))
  (let ((head (concat (regexp-quote (string-trim " \t" comment-head)) "[ \t]?")))
	(replace-buffer head "" :regexp t :once t))
  ;; 末尾のコメントキーを削除する
  (when (not (string= comment-tail ""))
	(goto-char (point-min))
	(let ((tail (concat "[ \t]?" (regexp-quote (string-trim " \t" comment-tail)))))
	  (replace-buffer tail "" :regexp t :once t )))
  ;; コメント中の改行時挿入文字を削除する
  (goto-char (point-min))
  (unless (string= comment-split "")
	(replace-buffer (format nil "^\\([ \t]*\\)\\(~A\\)" (regexp-quote comment-split)) "\\1" :regexp t))
  ;; 途中にコメント無効化文字列がある場合は、コメント無効化を解除する
  (when regexp-head-uninvalid
	(goto-char (point-min))
	(replace-buffer regexp-head-uninvalid "\\1\\2":regexp t))
  (when regexp-tail-uninvalid
	(goto-char (point-min))
	(replace-buffer regexp-tail-uninvalid "\\1\\2":regexp t))
  )

#| おまけ

(defun gct-region-or-other()
  "rv-region選択中 は generic-comment-toggle-region を使用する"
  (interactive)
  (if (and (modulep "rv-region")
		   *rv-region-stay-on*)
	  (generic-comment-toggle-region)
	(generic-comment-toggle)))

|#
