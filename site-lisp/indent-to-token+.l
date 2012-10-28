#|
This file is not part of xyzzy.

  indent-to-token+.l --- tokenを指定してインデント

    by bove-crach

■概要
  指定したtokenをセレクション範囲から探し出し、その中で最も桁が大きい位置にインデントを揃えます

  要は 「思いつくまま xyzzy」 の Masahiro Nakano さんが作成されたindent-to-tokenを改造しただけです
  Masahiro Nakanoさん多謝！
        思いつくまま xyzzy：Websiteはないようです...

■インストール
  1. indent-to-token+.l を site-lisp にコピーする。
  2. 必要に応じ，バイトコンパイルする。
        M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

        (require "indent-to-token+")

  ※ netinstallerで導入された方は「2.」以降だけで大丈夫です

■使い方
  M-x indent-to-token+                       : token の正規表現を元に複数行の桁を揃える
  M-x indent-to-token+-just-space            : indent-to-token+ で just-one-space もする
  M-x indent-to-token+-del-space             : indent-to-token+ で delete-horizontal-spaces もする
  M-x indent-to-token+-right-mode            : indent-to-token+の右揃えを行う
  M-x indent-to-token+-right-mode-just-space : indent-to-token+の右揃え で just-one-space もする
  M-x indent-to-token+-right-mode-del-space  : indent-to-token+の右揃え で delete-horizontal-spaces もする
  M-x indent-to-token+interact               : indent-to-token+ で 検索モードと削除モードを聞いてくれる

■キーバインド
  特に指定していません

■設定例
  Alt + i キーで indent-to-token+
    (global-set-key #\M-i 'indent-to-token+)

■ ライセンス

  indent-to-token+.l は NYSL Version 0.9982 に従います。

NYSL Version 0.9982
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

■考察
  ・左揃え概要
  例：
  1        10  40  50   100  400
  40       50  100 400  500  1000
  100      402220 511100 1444000 4555000 5000
  ↓ 正規表現＝[0-9]+
  1        10     40     50      100     400
  40       50     100    400     500     1000
  100      402220 511100 1444000 4555000 5000

  ・右揃え概要
  例：
  1        10  40  50   100  400
  40       50  100 400  500  1000
  100      402220 511100 1444000 4555000 5000
  ↓ 正規表現＝[0-9]+
    1          10     40      50     100   400
   40          50    100     400     500  1000
  100      402220 511100 1444000 4555000  5000

■ToDo
  ・処理の最適化

■更新履歴
  [Version 1.03] 2008.01.07
  ・右揃えに対応するため、処理を見直し

  [Version 1.02] 2007/04/14
  ・大改造

  [Version 1.01] 2007/03/03
  ・token の正規表現にグループ化\(...\)がある場合に、どのグループでindent-toするか聞くようにした
  ・tab-columns の区切りに合わせるオプションを追加
  ・indent-to したときに、挿入文字を空白にするオプションを追加

  [Version 1.00] 2007/02/24
  ・初版

|#
(provide "indent-to-token+")
(in-package "editor")

(export '(; settings
		  *indent-to-token+-nth-regexp*
		  *indent-to-token+-tab-columns*
		  *indent-to-token+-untabify*
		  ; function
		  indent-to-token+
		  indent-to-token+-just-space
		  indent-to-token+-del-space
		  indent-to-token+-right-mode
		  indent-to-token+-right-mode-just-space
		  indent-to-token+-right-mode-del-space
		  indent-to-token+interact
		  ; other
		  indent-to-token+-exec-narrow-range
		  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; settings
;; 複数グループ化の何番目をindent-to対象とするかを聞いて欲しい
;; t : 聞く    nil : 聞かない
(defvar *indent-to-token+-nth-regexp*  t)
;; 区切りをtab-columnsに合わせてindent-toして欲しい
;; t : する    nil : しない
(defvar *indent-to-token+-tab-columns* nil)
;; indent-toするときにtabじゃなくて空白を入れたい
;; t : 空白で  nil : tabで
(defvar *indent-to-token+-untabify*    t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; おまけ
;; ナローイングする関数
(defvar indent-to-token+-exec-narrow-range 'narrow-selection)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 内部用settings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; interactive function
(defun indent-to-token+-just-space ()
  "indent-to-token+ で just-one-space もする"
  (interactive) (indent-to-token+ nil 0 1))

(defun indent-to-token+-del-space ()
  "indent-to-token+ で delete-horizontal-spaces もする"
  (interactive) (indent-to-token+ nil 0 2))

;; 右揃え
(defun indent-to-token+-right-mode ()
  "indent-to-token+の右揃えを行う"
  (interactive) (indent-to-token+ nil 1))

(defun indent-to-token+-right-mode-just-space ()
  "indent-to-token+の右揃え で just-one-space もする"
  (interactive) (indent-to-token+ nil 1 1))

(defun indent-to-token+-right-mode-del-space ()
  "indent-to-token+の右揃え で delete-horizontal-spaces もする"
  (interactive) (indent-to-token+ nil 1 2))

;; まるち
(defun indent-to-token+interact ()
  "indent-to-token+ で 検索モードと削除モードを聞いてくれる"
  (interactive)
  (let (arrange-mode delete-space)
	(minibuffer-prompt "検索モード L=左揃え R=右揃え : ")
	(loop (case (read-char *keyboard*)
			((#\L #\l) (setf arrange-mode 0) (return t))
			((#\R #\r) (setf arrange-mode 1) (return t))
			(#\C-g     (quit))))
	(minibuffer-prompt "削除モード N=なし O=空白1つ D=空白なし : ")
	(loop (case (read-char *keyboard*)
			((#\N #\n) (setf delete-space 0) (return t))
			((#\O #\o) (setf delete-space 1) (return t))
			((#\D #\d) (setf delete-space 2) (return t))
			(#\C-g     (quit))))
	(indent-to-token+ nil arrange-mode delete-space)
	))

;; 本体
(defun indent-to-token+ ( &optional regexp (arrange-mode 0) (delete-space 0))
  "token の正規表現を元に複数行の桁を揃える"
  (interactive)
  (let (search-group data times max-data)
;;; 検索正規表現、検索位置、検索モードを指定する
	;; 正規表現の決定
	(unless regexp
	  (setf regexp (read-string "indent-to-token+ 検索する正規表現 : ")))
	(when (string= regexp "")
	  (plain-error "検索する正規表現が不正です"))
	;; グループがある場合は揃える場所を決めてもらう
	(if (and *indent-to-token+-nth-regexp*
			 (string-match "\\\\(.+\\\\)" regexp))
		(setf search-group (read-integer "検索するグループ : "))
	  (setf search-group 0))
	(setf regexp (compile-regexp regexp))
;;; token出現リストを作成
	(save-excursion
	  (save-restriction
		;; 範囲指定
		(unless (funcall indent-to-token+-exec-narrow-range)
		  (plain-error "有効範囲が指定できてないっす"))
		;; グループ指定位置が合っているか確認
		(goto-char (point-min))
		(scan-buffer regexp)
		(or (match-beginning search-group)
			(match-end       search-group)
			(plain-error "グループ指定が間違ってるっす"))
		;; 出現桁取得
		(goto-char (point-min))
		(while (scan-buffer regexp)
		  (let ( start end work )
			(setf start (match-beginning  search-group))
			(setf end   (match-end        search-group))
			(setf work  (buffer-substring start end))
			(goto-char start)
			;; 削除系は ここから
			(cond ((= delete-space 2)
				   (delete-horizontal-spaces) (setf work (string-left-trim " \t" work)))
				  ((= delete-space 1)
				   (just-one-space) (setf work (string-left-trim " \t" work))
				   (when (string= work "") (setf work " "))))
			(setf start (point))
			(setf end (+ start (count-column work)))
			;; 削除系は ここまで
			(setf work (list (current-column) (progn (goto-char (+ (point) (- end start) )) (current-column))))
			(unless (eq (current-line-number) (caar data))
			  (push (list (current-line-number) '(0 0)) data))
			(push (append (pop data) (list work)) data)
			(goto-char end)
			))))
;;; token出現リストができなかったらここで終わり
	(unless data (plain-error "tokenが検出されませんでした"))
;;; token出現桁数の最大値
	(setf times (first (sort (mapcar #'list-length data) #'>)))
;;; 移動する桁を算出
	(setf max-data '(0))
	(do ((counta 2 (incf counta))
		 (work   0 (setf work (car max-data)))
		 (buf    0))
		((>= counta times) counta)
	  (mapcar #'(lambda (x)
				  (and (car (nth counta x))
					   (setf buf (+ (car max-data) (- (nth arrange-mode (nth counta x)) (nth arrange-mode (nth (1- counta) x)))))
					   (> buf work)
					   (setf work buf)))
			  data)
	  (push work max-data))
;;; 移動位置をtab幅に合わせる
	(when *indent-to-token+-tab-columns*
	  (let ((work 0) (work-list (cdr (reverse max-data))))
		(dotimes (counta (list-length work-list))
		  ;; 移動しようとした位置と tab-columns の余りを出す
		  ;; 余った分だけ足しこんでtab位置とする
		  (setf work (+ (- (tab-columns) (mod (+ (nth counta work-list) work) (tab-columns))) work))
		  (setf (nth counta work-list) (+ (nth counta work-list) work)))
		(setf max-data (revappend work-list '(0)))))
	(setf max-data (reverse max-data))
;;; 移動
	(dolist (record data)
	  ; 該当行に移動
	  (goto-line (car record))
	  (do ((counta 2 (incf counta)) (diff 0) (column 0) (indent 0))
		  ((not (nth counta record)))
		(cond
		 ; 左揃え
		 ((= arrange-mode 0)
		  (setf diff (- (nth 0 (nth counta record)) (nth 0 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (nth (- counta 1) max-data)))
		 ; 右揃え
		 ((= arrange-mode 1)
		  (setf diff (- (nth 0 (nth counta record)) (nth 1 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (- (nth (- counta 1) max-data) (- (nth 1 (nth counta record)) (nth 0 (nth counta record))))))
		 ; 該当なしの場合は左揃え処理
		 ; 中央揃えとか擬似インデントとか色々できそうだよなぁ
		 (t
		  (setf diff (- (nth 0 (nth counta record)) (nth 0 (nth (1- counta) record))))
		  (setf column (+ diff (nth (- counta 2) max-data)))
		  (setf indent (nth (- counta 1) max-data)))
		 )
		(goto-column column)
		(indent-to indent)
		(when *indent-to-token+-untabify*
		  (untabify (point) (- (point) indent)))
		)
	  )
	))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; static function
(defun narrow-selection ()
  "セレクション範囲をナローイングする"
  (and (pre-selection-p)
	   (narrow-to-region (selection-mark) (selection-point))
	   (return-from narrow-selection t))
  nil)

(defun narrow-region ()
  "リージョン範囲をナローイングする"
  (and (mark t)
	   (narrow-to-region (region-beginning) (region-end))
	   (return-from narrow-region t))
  nil)

(defun narrow-region-or-selection ()
  "セレクション範囲をナローイングする"
  (or  (narrow-selection)
	   (narrow-region)
	   (return-from narrow-region-or-selection nil))
  t)
