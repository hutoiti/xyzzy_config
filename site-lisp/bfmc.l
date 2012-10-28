
(provide "bfmc")
(in-package "editor")

(defun bfmc-version nil
  (interactive)
  (and (interactive-p)
       (message "bfmc lapse ~A on 2010-11-13 18:30" (bfmc-version)))
  "007")

#| buffer frame marker controller for xyzzy-0.2.2.235

Copyright (c) 2008-2010 knenet \kneneglect_std(^o^)yahoo.co.jp/

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

MITライセンスです。著作者を明らかにすれば適当に使って良いです。
このソフトの使用によって生じた損益について、著作者は一切責任を持ちません。

■概要

list-buffersとpseudo-frame-selectorを合わせたようなものです。
ついでにpseudo-frameの操作が出来ます。マーカ云々は未実装です。

■導入

(require "bfmc")

を.xyzzyに書くなどして読み込みます。
netinstallerを用いてインストールした場合は不要です。

(define-key esc-map #\C-j 'bfmc-menu)
(define-key esc-map #\J 'bfmc-menu-frame)

などと好みに応じてキーバインドします。

アンインストールはこのファイルを削除して上記設定等を消せばいいです。

■使用方法

bfmc-menuで呼び出します。bfmc-menu-frameはpseudo-frame行から始まるだけです。
選択したいバッファやフレームが表示されてる行に合わせてC-mやjで選択します。
表示の見方は以下の通りです。

・バッファ行
選択バッファ(>) 削除予約(!) 読み取り専用／要保存(%*)
バッファ名 モード 行数 文字数 ナローイング 作業ディレクトリ

・フレーム行
選択フレーム(>) 削除予約(!) フレーム名 ... 関連バッファ(<選択バッファ>)

次に、大雑把なキー説明を示します。
C-m C-j j 項目を選択してbfmcを抜けます。
g 表示されている状態でbfmcを抜けます。
q 作業を中断してbfmcを抜けます。
p n 上下行に移動します。
f b フレーム・バッファに移動します。
    Universal Argmentで選択行から相対的に行指定できます。
l バッファを選択します。
o ウィンドウを全て閉じて選択バッファに移動します。
v h 垂直、水平にウィンドウを分割してから選択バッファに移動します。
u d 選択フレームでウィンドウを前後に移動します。
t 選択フレームで現在のウィンドウを閉じます。
w 現在のフレームの複製を作って選択します。
x 選択フレームの状態を表示します。
i 現在の行のバッファ名を省略せずにポップアップで表示します。
k 削除予約を切り替えます。削除予約(!)のついたアイテムはbfmc終了時に削除されます。
  バッファ削除は標準ではkill-bufferなので、保存が必要ならそのときに確認されます。
R 削除予約を実行します。
z Z c C それぞれウィンドウを縦に拡大縮小、横に拡大縮小します。
        Universal Argumentで変位を指定でき、高さ、幅ごとに変位量を保存します。

フレーム操作は一度フレームに移動します。確認が必要ないような場合も表示されますが、
それは仕様です。

■その他設定

グローバル変数や関数を見れば分かると思いますが、ありそうなものをいくつか挙げておきます。

・なぜ現在バッファ／フレームから始まらない？
*bfmc-cursor-at-open* で開始行を補正しています。0にすると現在の項目から始まります。

・表示されるバッファやフレームを制御したい。
*bfmc-buffer-filters* *bfmc-frame-filters* がフィルタのリストになってます。
正規表現で一致するアイテムを表示から外します。
pushnewあたりで正規表現式を追加すると良いです。
名前の一部を省略したい場合は *bfmc-substitute-buffer-name* で置換します。

(setq *bfmc-tbf* (list '("^\\*bfmc\\*$" "^ ") '("^\\*bfmc\\*$")))
(setf (cdr (last *bfmc-tbf*)) *bfmc-tbf*)

(defun bfmc-toggle-buffer-filters ()
  "バッファ表示フィルタを切り替える"
  (interactive)
  (setq *bfmc-buffer-filters* (pop *bfmc-tbf*))
  (ed::bfmc-refresh))

はお好みで。

・インクリメンタルサーチしたい。
(defun bfmc-isearch-buffer ()
  (interactive)
  (ed::bfmc-move-to-buffer 1)
  (isearch-forward))
(defun bfmc-isearch-frame ()
  (interactive)
  (ed::bfmc-move-to-frame 1)
  (isearch-forward))

とでも書きます。

・あるフレームが消せない。間違って消してしまうバッファがある。
*bfmc-no-rename-frames* *bfmc-no-delete-buffers*
で操作しないフレーム、削除予約しないバッファを管理しています。
string=で確認しているので、removeやpushnewで調整してください。
また、バッファは*bfmc-buffer-deleter*で削除関数を指定できます。


netinstallerではautoloadしているので、*bfmc-mode-map*への追加は

(defun bfmc-load-strap ()
  (define-key *bfmc-mode-map* #\e 'bfmc-toggle-buffer-filters)
  (define-key *bfmc-mode-map* #\s 'bfmc-isearch-buffer)
  (define-key *bfmc-mode-map* #\S 'bfmc-isearch-frame)
  (delete-hook '*bfmc-mode-hook* 'bfmc-load-strap))
(add-hook '*bfmc-mode-hook*  'bfmc-load-strap)

とでも書いて下さい。

■既知のバグ
ウィンドウ操作をすると、「削除されたウィンドウです」というメッセージが
でることがあります。その回避のために操作対象のフレームを表示しているの
ですが、それでも出てしまうことがあります。
その場合は、適当にフレーム移動するか、M-xなどでミニバッファに移動すると
直るようです。確実な回避方法があれば教えてください＞＜

■更新履歴
007 2010-11-13 18:30 フレーム作成の挙動変更
　　　　　　　　　　 バッファの表示方法を変更
　　　　　　　　　　 ウィンドウを閉じるコマンド(t)を追加
　　　　　　　　　　 バッファ名を表示するコマンド(i)を追加
　　　　　　　　　　 フレーム移動のバグを少し回避したつもり
006 2009-08-14 09:50 buggyだったのでmacroの位置を変更。
005 2009-08-13 22:55 選択等の操作をするとすんごいスペースが表示されるバグを修正。
003 2009-01-03 21:12 説明とかni-autoloadとかがnetinstallerに対応した。
002 2008-12-23 22:14 名前を置換するフィルタを付けた。表示を折り返さないようにした。
　　　　　　　　　　 出来るだけ表示が崩れないようにした。
001 2008-12-22 08:56 できた。

説明おわり|#

(defvar *bfmc-buffer* "*bfmc*" "bfmc menuのバッファ名")
(defvar *bfmc-frame* "bfmc" "bfmc menuのフレーム名")
(defvar *bfmc-buffer-filters* '("^\\*bfmc\\*$" "^ ") "bfmcで表示しないバッファ(regexp)")
(defvar *bfmc-frame-filters* '("^bfmc$") "bfmcで表示しないフレーム(regexp)")
(defvar *bfmc-no-delete-buffers* '("*scratch*") "bfmcで削除しないバッファ")
(defvar *bfmc-no-rename-frames* '("Den8" "2ch") "bfmcでリネームしないフレーム")
(defvar *bfmc-wait* 0.5 "フレームを表示する時間")
(defvar *bfmc-buffer-deleter* 'kill-buffer "bfmcでバッファを削除するコマンド")
(defvar *bfmc-cursor-at-open* 1 "bfmcを起動するときの選択行補正")
(defvar *bfmc-mode-hook* nil)
(defvar *bfmc-substitute-buffer-name* '(("^ " "MINIBUF:")) "bfmcで表示するバッファ名の置換リスト")
(defvar *bfmc-buffer-bar-order* t "bfmcの表示をバッファバーに合わせるかどうか")

(export '(*bfmc-buffer-filters* *bfmc-frame-filters* *bfmc-no-delete-buffers* *bfmc-no-rename-frames* *bfmc-mode-hook*
		  *bfmc-substitute-buffer-name* *bfmc-wait* *bfmc-buffer-deleter* *bfmc-cursor-at-open* *bfmc-mode-map*
		  *bfmc-buffer-bar-order*
		  bfmc-menu bfmc-menu-frame))
;上の説明で名前出したのだけ。あとhook。

(defvar *bfmc-mode-map* nil)
(unless *bfmc-mode-map*
  (setq *bfmc-mode-map* (make-sparse-keymap))
  (define-key *bfmc-mode-map* #\g 'bfmc-g)
  (define-key *bfmc-mode-map* #\LFD 'bfmc-enter)
  (define-key *bfmc-mode-map* #\RET 'bfmc-enter)
  (define-key *bfmc-mode-map* #\j 'bfmc-enter)
  (define-key *bfmc-mode-map* #\p 'bfmc-previous-line)
  (define-key *bfmc-mode-map* #\n 'bfmc-next-line)
  (define-key *bfmc-mode-map* #\f 'bfmc-move-to-frame)
  (define-key *bfmc-mode-map* #\b 'bfmc-move-to-buffer)
  (define-key *bfmc-mode-map* #\w 'bfmc-new-frame)
  (define-key *bfmc-mode-map* #\k 'bfmc-kill-toggle)
  (define-key *bfmc-mode-map* #\d 'bfmc-next-window)
  (define-key *bfmc-mode-map* #\u 'bfmc-previous-window)
  (define-key *bfmc-mode-map* #\t 'bfmc-close-window)
  (define-key *bfmc-mode-map* #\l 'bfmc-select)
  (define-key *bfmc-mode-map* #\R 'bfmc-refresh)
  (define-key *bfmc-mode-map* #\o 'bfmc-select-alone)
  (define-key *bfmc-mode-map* #\v 'bfmc-select-vertical)
  (define-key *bfmc-mode-map* #\h 'bfmc-select-horizontal)
  (define-key *bfmc-mode-map* #\x 'bfmc-preview)
  (define-key *bfmc-mode-map* #\r 'bfmc-rename-frame)
  (define-key *bfmc-mode-map* #\q 'bfmc-quit)
  (define-key *bfmc-mode-map* #\i 'bfmc-popup-info)
  (define-key *bfmc-mode-map* #\Z 'bfmc-shrink-window-vertical)
  (define-key *bfmc-mode-map* #\z 'bfmc-enlarge-window-vertical)
  (define-key *bfmc-mode-map* #\C 'bfmc-shrink-window-horizontal)
  (define-key *bfmc-mode-map* #\c 'bfmc-enlarge-window-horizontal))

(setq bfmc-table nil bfmc-cur-buffer nil bfmc-cur-frame nil bfmc-last-buffer nil bfmc-last-frame nil
	  bfmc-count nil bfmc-fp nil bfmc-delete-buffer-list nil bfmc-delete-frame-list nil
	  bfmc-cur-buffer-line 0 bfmc-cur-frame-line 0
	  bfmc-frame nil bfmc-buffer nil)

(eval-when (:compile-toplevel :execute)
(defmacro bfmc-force-write (&rest arg)
  (let ((r (gensym)))
	`(let ((,r buffer-read-only))
	   (setq buffer-read-only nil)
	   (prog1 (progn ,@arg)
		 (setq buffer-read-only ,r)))))

(defmacro bfmc-kill-toggle-sub (line N rimbo &optional except)
  (let ((target (gensym))
		(p (gensym)))
	`(let* ((,target (gethash ,line bfmc-table))
			(,p (if (or (eq ,N t) (eq ,N nil)) ,N
				  (if (= ,N 0) (not (member ,target ,rimbo))
					(> N 0)))))
	   (if ,p ,(if except `(if (member-if-not 'null (map 'list (lambda (x) (funcall (bfmc-match-name-func 'buffer-name x) ,target)) ,except))
							   (message "~A は消さないよ" (bfmc-substituted-buffer-name ,target))
							  (pushnew ,target ,rimbo))
				 `(pushnew ,target ,rimbo))
		 (setq ,rimbo (delete ,target ,rimbo)))
	   (bfmc-rewrite ,line))))

(defmacro bfmc-with-current (item &rest arg)
  ; 項目を取得しておく。
  `(let ((,item (gethash (current-line-number) bfmc-table)))
	 ,@arg))

(defmacro bfmc-sel-frame (item)
 ; "項目がフレームじゃないときはbfmc-cur-frameに"
  `(if (not (pseudo-frame-p ,item)) (setq ,item bfmc-cur-frame)))

(defmacro bfmc-with-frame (frame &rest arg)
  ; フレームに対する操作
  (let ((cur (gensym)))
	`(let ((,cur (selected-pseudo-frame)))
	   (prog2
		   (select-pseudo-frame ,frame)
		   (progn ,@arg)
		 (refresh-screen) (sit-for *bfmc-wait*) ; バグ持ちらしく外せないのです。
		 (select-pseudo-frame ,cur))))))

(defun bfmc-menu (&optional N)
  "bfmc-mode メニューを開く"
  (interactive "p")
  (bfmc-menu-sub 0 N))

(defun bfmc-menu-frame (&optional N)
  "bfmc-mode メニューを開く"
  (interactive "p")
  (bfmc-menu-sub 1 N))

(defun bfmc-menu-sub (index displacement)
  ;メニュー表示
  (or (eq bfmc-buffer (selected-buffer))
	  (eq bfmc-frame (selected-pseudo-frame))
	  (setq bfmc-cur-buffer (selected-buffer)
			bfmc-cur-frame (selected-pseudo-frame)
			bfmc-last-buffer bfmc-cur-buffer
			bfmc-last-frame bfmc-cur-frame))
  (if displacement nil (setq displacement *bfmc-cursor-at-open*))
  (if (setq bfmc-frame (find-pseudo-frame *bfmc-frame*))
	  (select-pseudo-frame bfmc-frame)
	(setq bfmc-frame (new-pseudo-frame *bfmc-frame*)))
  (or (setq bfmc-buffer (find-buffer *bfmc-buffer*))
	  (setq bfmc-buffer (get-buffer-create *bfmc-buffer*)))
  (set-buffer bfmc-buffer)
  (kill-all-local-variables)
  (make-local-variable 'buffer-read-only)
  (make-local-variable 'need-not-save)
  (make-local-variable 'kept-undo-information)
  (make-local-variable 'auto-save)
  (setq buffer-read-only t ; 書き換えるときだけnilに。
		need-not-save t
		kept-undo-information nil
		auto-save nil)
  (set-local-window-flags bfmc-buffer *window-flag-cursor-line* t)
  (set-buffer-fold-width nil bfmc-buffer)
  (setf buffer-mode 'bfmc-mode)
  (setf mode-name "bfmc-mode")
  (use-keymap *bfmc-mode-map*)
  (bfmc-construct-menu)
  (case index
	(0 (bfmc-move-to-buffer (+ bfmc-cur-buffer-line displacement) t))
	(1 (bfmc-move-to-frame (+ bfmc-cur-frame-line displacement) t)))
  (run-hooks '*bfmc-mode-hook*))

(defun bfmc-apply-filter (-name data-list filter-list)
  "(alias -> name) list:alias list:regexp -> list:alias"
  (reduce (lambda (data-list regexp) (remove-if (bfmc-match-name-func -name regexp) data-list))
		  (append (list data-list) filter-list)))

(defun bfmc-match-name-func (-name regexp)
  "(alias -> name) regexp -> (alias -> bool)"
  (lambda (x) (string-match regexp (funcall -name x))))

(defun bfmc-goto-line (n from to)
  "ループ仕様"
  (goto-line (- n (* (floor (- n from) (- to from)) (- to from)))))

(defun bfmc-add-frame (frame)
  "フレーム行追加"
  (setf (gethash bfmc-count bfmc-table) frame)
  (if (equal bfmc-cur-frame frame) (setq bfmc-cur-frame-line bfmc-count))
  (bfmc-frame-format 'bfmc-line bfmc-fp frame))

(defun bfmc-add-buffer (buffer)
  "バッファ行表示"
  (setf (gethash bfmc-count bfmc-table) buffer)
  (if (equal bfmc-cur-buffer buffer) (setq bfmc-cur-buffer-line bfmc-count))
  (bfmc-buffer-format 'bfmc-line bfmc-fp buffer))

(defun bfmc-rewrite (line)
  "行書き直し"
  (let ((obj (gethash line bfmc-table)))
	(cond
	 ((bufferp obj)
	  (bfmc-buffer-format (bfmc-force-format) (bfmc-rewrite-line-stream line) obj))
	 ((pseudo-frame-p obj)
	  (bfmc-frame-format (bfmc-force-format) (bfmc-rewrite-line-stream line) obj)))))


(defun bfmc-force-format ()
  (lambda (&rest arg) (bfmc-force-write (apply 'format arg))))

(defun bfmc-rewrite-line-stream (line)
  (save-excursion
	(set-buffer bfmc-buffer)
	(goto-line line)
	(bfmc-delete-line)
	(make-buffer-stream bfmc-buffer (point))))

(defun bfmc-delete-line ()
  (bfmc-force-write (delete-region (progn (goto-bol) (point)) (progn (goto-eol)(point)))))

(defun frame-buffers-format (cur-window window-list)
  ;フレーム行のバッファ
  (apply 'concat (map 'list #'(lambda (x) (concat " " (frame-buffer-format (cadr x) (eq cur-window (car x)))))
					  window-list)))

(defun bfmc-line (fp str &rest format)
  ;表示行を数えるformat
  (incf bfmc-count)
  (push (concat str "~%") format)
  (push fp format)
  (apply (bfmc-force-format) format))

(defun frame-buffer-format (buffer current-p)
  ;フレーム行のバッファ1つ分
  (let ((bn (if (deleted-buffer-p buffer)
				"deleted" (bfmc-substituted-buffer-name buffer))))
	(if current-p (concat "<" bn ">") bn)))

(defun bfmc-substituted-buffer-name (buffer)
  "名前にフィルタをかけて、省略する。"
  (abbreviate-display-string
   (reduce (lambda (str filter) (substitute-string str (car filter) (cadr filter)))
			   (append (list (buffer-name buffer)) *bfmc-substitute-buffer-name*))
   33))

(defun bfmc-buffer-info (buffer)
  (save-excursion
	(set-buffer buffer)
	(values (format nil "~A~{/~A~}" mode-name
					(map 'list #'(lambda (x) (if (symbolp (cdr x)) (symbol-value (cdr x)) (cdr x)))
						 (remove 'nil *minor-mode-alist* :key #'(lambda (x) (symbol-value (car x))))))
			buffer-read-only
			(need-buffer-save-p buffer)
			(- (buffer-size) (- (point-max) (point-min)))
			(point-min)
			(point-max)
			(format nil "~33A" (if (deleted-buffer-p buffer) "|deleted|"
								 (bfmc-substituted-buffer-name buffer)))
			(default-directory))))

(defun bfmc-buffer-format (func fp buffer)
  "バッファ行の形式"
  (multiple-value-bind
	  (mode ro ns narrowp pmin pmax bname bpath)
	  (bfmc-buffer-info buffer)
	(let* ((diff-length (- 57 (count-column bname) (count-column mode)))
		   (lines (format nil "~vD"
					(max (+ 8 (min diff-length 0)) 1)
					(buffer-lines buffer)))
		   (size (format nil "~vD"
				   (max (+ 10 (min diff-length 0) (- 8 (length lines))) 1)
				   (buffer-size buffer))))
	  (funcall func fp "~:[ ~;>~]~:[ ~;!~]~A ~A ~@vT~A ~A ~A~A ~A"
			   (eq bfmc-cur-buffer buffer)
			   (member buffer bfmc-delete-buffer-list)
			   (if ro "%" (if ns "*" " "))
			   ;
			   bname
			   (max diff-length 0)
			   mode
			   lines
			   size
			   (if (= narrowp 0) "" (format nil " (~A-~A)" pmin pmax))
			   bpath))))

(defun bfmc-frame-format (func fp frame)
  "フレーム行の形式" format
  (funcall func fp "~:[ ~;>~]~:[ ~;!~] ~15A .~A"
		   (equal bfmc-cur-frame frame)
		   (member frame bfmc-delete-frame-list)
		   (pseudo-frame-name frame)
		   (frame-buffers-format (cadr (pseudo-frame-winconf frame))
								 (caddr (pseudo-frame-winconf frame)))))

(defun bfmc-construct-menu ()
  "bfmc menu構造更新"
  (setq bfmc-table (make-hash-table :size 11)
		bfmc-count 1
		bfmc-fp (make-buffer-stream bfmc-buffer 0))
  (erase-buffer bfmc-buffer)
  (bfmc-line bfmc-fp "cks~@23Tbuffer-name~@10Tmode/minor-mode~@4Tlines~@7Tsize (narrow) directory")
  (setq buffer-start-line bfmc-count)
  (dolist (buffer (bfmc-apply-filter 'buffer-name
									 (buffer-list :buffer-bar-order *bfmc-buffer-bar-order*)
									 *bfmc-buffer-filters*))
	(bfmc-add-buffer buffer))
  (setq buffer-end-line bfmc-count)
  (bfmc-line bfmc-fp "")
  (bfmc-line bfmc-fp  "ck~@6Tframe-name~@3Tbuffers-of-frame" )
  (setq frame-start-line bfmc-count)
  (dolist (frame (bfmc-apply-filter 'pseudo-frame-name *pseudo-frame-list* *bfmc-frame-filters*))
	(bfmc-add-frame frame))
  (setq frame-end-line bfmc-count))

(defun bfmc-refresh (&optional (N 1))
  "とりあえずすっきりさせる。"
  (interactive "p")
  (map nil 'delete-pseudo-frame bfmc-delete-frame-list)
  (map nil *bfmc-buffer-deleter* bfmc-delete-buffer-list)
  (setq bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (bfmc-construct-menu)
  (if (> N 0)(bfmc-move-to-buffer)(bfmc-move-to-frame)))

(defun bfmc-enter ()
  "選択バッファ・フレームに移動"
  (interactive)
  (bfmc-with-current target
	(cond
	 ((bufferp target) (bfmc-exit bfmc-cur-frame target))
	 ((pseudo-frame-p target) (bfmc-exit target))
	 (t (error "ないよ。")))))

(defun bfmc-new-frame ()
  "フレームを作成して選択"
  (interactive)
  (let ((line (current-line-number))
		(winconf (bfmc-with-frame bfmc-cur-frame
				   (copy-list (pseudo-frame-winconf bfmc-cur-frame)))))
	(setq bfmc-cur-frame (call-interactively 'new-pseudo-frame))
	(set-window-configuration winconf)
	(select-pseudo-frame bfmc-frame)
	(bfmc-construct-menu)
	(goto-line line)))

(defun bfmc-move-to-buffer (&optional N ab)
  "バッファ行に移動"
  (interactive "p")
  (bfmc-goto-line (if N (if ab N (+ buffer-start-line N -1)) bfmc-cur-buffer-line)
				  buffer-start-line buffer-end-line))

(defun bfmc-move-to-frame (&optional N ab)
  "フレーム行に移動"
  (interactive "p")
  (bfmc-goto-line (if N (if ab N (+ frame-start-line N -1)) bfmc-cur-frame-line)
				  frame-start-line frame-end-line))

(defun bfmc-rename-frame ()
  "フレームの名前を変える"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(if (member (pseudo-frame-name sel) *bfmc-no-rename-frames* :test 'string=)
		(error "~A は変えないよ。" (pseudo-frame-name sel))
	  (let ((n (read-string "フレーム名: " :default (pseudo-frame-name sel))))
		(if (member n *bfmc-no-rename-frames* :test 'string=)
			(error "~A は予約されてるよ。" n)
		  (progn (bfmc-with-frame sel (trap-errors (rename-pseudo-frame n)))
			(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))))))

(defun bfmc-kill-toggle (&optional (N 0))
  "アイテム削除フラグの切り替え" ;0でトグル動作
  (interactive "p")
  (bfmc-with-current sel
	(cond
	 ((bufferp sel) (bfmc-kill-toggle-sub (current-line-number) N bfmc-delete-buffer-list *bfmc-no-delete-buffers*))
	 ((pseudo-frame-p sel) (bfmc-kill-toggle-sub (current-line-number) N bfmc-delete-frame-list))
	 (t (error "ないよ。"))))
  (bfmc-next-line))

(defun bfmc-next-line ()
  "適当に折り返す"
  (interactive)
  (cond
   ((eq (current-line-number) (1- buffer-end-line)) (goto-line buffer-start-line))
   ((eq (current-line-number) (1- frame-end-line)) (goto-line frame-start-line))
   (t (next-line))))

(defun bfmc-previous-line ()
  "適当に折り返す"
  (interactive)
  (cond
   ((eq (current-line-number) buffer-start-line) (goto-line (1- buffer-end-line)))
   ((eq (current-line-number) frame-start-line) (goto-line (1- frame-end-line)))
   (t (previous-line))))

(defun bfmc-select ()
  "選択する。"
  (interactive)
  (bfmc-with-current sel
	(cond ((bufferp sel)
		   (setq bfmc-cur-buffer sel)
		   (bfmc-rewrite bfmc-cur-buffer-line)
		   (bfmc-rewrite (setq bfmc-cur-buffer-line (current-line-number)))
;		   (bfmc-with-frame bfmc-cur-frame (set-buffer bfmc-cur-buffer))
		   (bfmc-rewrite bfmc-cur-frame-line))
		  ((pseudo-frame-p sel)
		   (setq bfmc-cur-frame sel)
		   (bfmc-rewrite bfmc-cur-frame-line)
		   (bfmc-rewrite (setq bfmc-cur-frame-line (current-line-number)))
		   (bfmc-move-to-buffer))
		  (t (message "ないよ")))))

(defun bfmc-select-vertical (&optional N)
  "垂直方向に分割して選択"
	(interactive "p")
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (trap-errors (split-window N t)) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))

(defun bfmc-select-horizontal (&optional N)
  "水平方向に分割して選択"
	(interactive "p")
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (trap-errors (split-window N nil)) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))

(let ((arg 4))
  (defun bfmc-enlarge-window-vertical (&optional N)
	"ウィンドウを縦に拡大"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (enlarge-window arg)))))

  (defun bfmc-shrink-window-vertical (&optional N)
	"ウィンドウを縦に縮小"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (shrink-window arg))))))

(let ((arg 4))
  (defun bfmc-enlarge-window-horizontal (&optional N)
	"ウィンドウを横に拡大"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (enlarge-window-horizontally arg)))))

  (defun bfmc-shrink-window-horizontal (&optional N)
	"ウィンドウを横に縮小"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (shrink-window-horizontally arg))))))


(defun bfmc-select-alone ()
  "他のウィンドウを閉じて選択"
  (interactive)
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (delete-other-windows) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))


(defun bfmc-preview ()
  "選択フレームを表示"
  (interactive)
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (sit-for 0.5))))

(defun bfmc-next-window ()
  "選択ウィンドウを進める"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (other-window 1 t))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-previous-window ()
  "選択ウィンドウを戻る"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (other-window -1 t))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-close-window (&optional N)
  "ウィンドウを閉じる"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (trap-errors (delete-window)))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-g ()
  "bfmc menuを閉じる。"
  (interactive)
  (bfmc-exit bfmc-cur-frame bfmc-cur-buffer)
  (message "でた。"))

(defun bfmc-exit (frame &optional buffer)
  ;bfmc menuから抜ける
  (delete-buffer bfmc-buffer)
  (map nil 'delete-pseudo-frame (adjoin bfmc-frame bfmc-delete-frame-list))
  (map nil *bfmc-buffer-deleter* bfmc-delete-buffer-list)
  (setq bfmc-frame nil bfmc-buffer nil bfmc-fp nil bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (select-pseudo-frame frame)
  (if buffer (set-buffer buffer))
  (refresh-screen))

(defun bfmc-quit ()
  "bfmc 予約している作業を止めて終了する。"
  (interactive)
  (delete-buffer bfmc-buffer)
  (delete-pseudo-frame bfmc-frame)
  (setq bfmc-frame nil bfmc-buffer nil bfmc-fp nil bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (select-pseudo-frame bfmc-last-frame)
  (message "やめた。"))

(defun bfmc-popup-info ()
  "現在の行のバッファ名をポップアップで表示する"
  (interactive)
  (bfmc-with-current sel
	(if (bufferp sel)
		(popup-string
		 (buffer-name sel)
		 (point)))))

; end of file bfmc.l  