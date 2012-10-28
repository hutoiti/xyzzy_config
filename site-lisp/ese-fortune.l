;;; -*- Mode: Lisp; Last modified: <2008/01/03 22:36:03> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   ese-fortune.l --- dubious fortune mode
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  起動時にリファレンスとか，占いとか，TODOをランダムに表示します。

  TKI さんの fortune-yz をもとにつくったものです。

    http://www2.ocn.ne.jp/~cheerful/script/xyzzy/play/startword.html


■インストール

  1. reference.txt を取得し，etc フォルダにコピーする。

     NetInstaller からインストールした場合は，etc フォルダに置かれます。

  2. ese-fortune.l を site-lisp にコピーする。

  3. 必要に応じ，バイトコンパイルする。(任意)

       M-x byte-compile-file

  4. .xyzzy か siteinit.l に以下の記述を追加する。

       (require "ese-fortune")

  5. xyzzy を再起動すると，xyzzy Reference が表示されるようになります。


■使い方

    a : 自動更新のトグル
    i : 更新間隔(秒)を変更
    n : 次ページ
    j : 指定 No に移動
    q : 終了
    . : 終了


■設定例

  ;;; 起動時からぼうっと見る。(自動更新モード)
  (setq *ese-fortune-absent* t)

  ;;; ぼうっと見られてるときに，ブルブルする。
  ;;;   TKI さんの，shakeWindow を頂き，読み込んでおく。
  ;;;   http://www2.ocn.ne.jp/~cheerful/script/xyzzy/mode/shakeWindow.html
  (require "shakeWindow")

  ;;; バッファタブを非表示する。
  (setq *ese-fortune-buffer* " *ese-fortune*")

  ;;; 関連するキーワードを F1 で info-modoki-mode から引く。
  ;;; （info-modoki-mode が必要です）
  (define-key *ese-fortune-mode-map* '#\F1 'imm-refer-selection)

  ;;; その他，カスタマイズ用変数を参照して適当に。


■データ形式

  ese-fortune 用のデータは，1行を1件として扱います。改行コードはTABで表
  現します。サンプルは，以下のとおり。([  TAB  ]は，TAB文字をあらわす)

    1|格言です。[  TAB  ]    ── 権兵衛
    2|ねむくておきれません。１点
    3|夏休みのきまりごと[  TAB  ]  * 早寝[  TAB  ]  * 早起き[  TAB  ]  * 歯磨き!?


■データファイルの設定例

  xyzzy Reference 以外のデータを表示させる場合は，データファイルの指定を
  行います。データファイルを指定するには，以下の方法があります。

  # データファイルは，どこかからテキトーに探します。

    1. データファイルを指定する。

           (setq *ese-fortune-dat* "tentori.data")

    2. データフォルダを指定する

       *ese-fortune-dat* にフォルダを指定すると，フォルダに存在するファ
       イルすべてをデータファイルとして認識し，ランダムに選択します。

           (setq *ese-fortune-dat* "F:/foo/bar/")

    3. 複数のファイルを指定する。

       使用するデータファイルをランダムに選択します。
       *ese-fortune-dat-list* を指定した場合，*ese-fortune-dat* に優先し
       ます。

           (setq *ese-fortune-dat-list*
                 '("reference.dat"
                   "tentori.data"
                   ))

    4. etc フォルダ以外のファイルを指定する。

      *ese-fortune-dat* にフルパスでファイル指定します。

           (setq *ese-fortune-dat* "d:/foo/bar.dat")

      複数ファイルを指定する場合。

           (setq *ese-fortune-dat-list*
                 '("d:/foo/bar.dat"
                   "piyo.txt"
                   ))


■利用可能なデータファイル

  [点とり占い]

    Taro's Page [Let's Enjoy Tentori Fortune!] から，tentori.lzh を頂き，
    お言葉データ(tentori.data) をetc フォルダにコピーします。

      http://taro.haun.org/tenjoy.html

    点とり占いデータを使う場合は，データファイルの指定が必要です。

      (setq *ese-fortune-dat* "tentori.data")

  [(BSD産の) fortune 用データ]

    以下の手順で，ese-fortune 用のファイルに変換して使用することができます。

      1. fortune 用データファイルを準備する
      2. F12 キーを押す
      3. 変換元ファイル(fortune 用データファイル)を指定する
      4. 変換先ファイル(ese-fortune 用データファイル)を指定する
      5. データファイルを指定する

           (setq *ese-fortune-dat* "hoge.dat")


■ ese-fortune 用のデータ形式でないデータファイルを直接使う

    拡張子を".dats"としたファイルを指定すると，以下のような形式のファイ
    ルをそのまま使用することができます。

    [hoge.dats]
      1|B&D で，トイレットペーパーを買う。
      2|
      3|  色はピンク。
      4|
      5|%
      6|マキロンをトイレにおいておく。
      7|
      8|%
      9|ひえさん。不具合です。 ０点

    TODO リストのように，変更を即反映させたいような場合は，この形式を利
    用するとよいでしょう。但し，実行する都度データ変換を行うため，処理は
    重くなります。


■更新履歴

  [Version 1.09.1] 2008-01-03 (水)
  ・absent-mode ON のままファイラを開くと，ファイラからフォーカスが外れて
    しまうため，テキトウな対処をした。

  [Version 1.09] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。
  ・reference.txt から reference.dat を必要に応じ自動作成するようにした。
    → 初回実行時と，更新時。
  ・改行認識文字列既定値(*ese-fortune-br*)をタブ文字に変更した。
  ・xyzzy Part7 657 さんの提案を取り込み，複数のデータファイルをランダム
    に表示できるようにした(今頃)。m(__)m
  ・ese-fortune 用のデータファイルでなくても，実行時に変換して見ることも
    できるようにした。
  ・データフォルダを指定できるようにした。
  ・info-modoki-mode で引きやすいように，シンタックスを定義した。
  ・ese-fortune 用バッファを，表示するようにした。
  ・再実行時に，バッファを作成しなおさないようにした。
  ・ぼうっと見れるようにした。（ふかえさんのアイディア）
  ・TKI さんの shakeWindow を読み込んでおくと，ぼうっと見てるときに
    ブルブルするようにした。

  [Version 1.08.3] 2003/07/06 (日)
  ・本体は site-lisp に，reference.dat　は etc に置くようにした。
  ・dat ファイルは，同梱しないようにした。
  ・あまり使わなさそうなキーバインドを削除した。

  [Version 1.08.2] 2003/05/05 (月)
  ・reference.dat を reference.xml から直接作成するようにした。また、
    表示してもあまりうれしくなさげな「目的別索引」とか「関数一覧」
    はデータに含めないようにした。これにより、ref2fortune は削除した。
  ・reference.dat を reference.xml 2003.04.30 版からつくったものに
    した。
  ・refernce.dat のみを同梱するようにした。

  [Version 1.08.1] 2003/04/19 (土)
  ・mixed.dat を同梱しないようにした。かわりに作成方法を追加してお
    いた。m(__)m

  [Version 1.08] 2003/04/06 (日)
  ・.xyzzy に (ese-fortune) とか書かなくてもいいようにした。
  ・xyzzy 起動時の ese-fortune 実行時点で、*scratch*, ミニバッファ
    以外のバッファが存在する場合は、起動しないようにした（つもり）。
  ・同梱の reference.dat を reference.xml 2003.03.30 版からつくった
    ものにした。

  [Version 1.07] 2003/02/18 (火)
  ・user パッケージに移した。（だけ。）

  [Version 1.06] 2002/12/06 (金)
  ・データファイル末尾の空白行まで選択してしまっていたのを修正した。
  ・*ese-fortune-title* を追加した。
  ・export するものをいくつか追加した。
  ・設定例とかを見直した。

  [Version 1.05] 2002/11/29 (金)
  ・xyzzy を SendTo とかから、ファイル名を指定して起動した場合、
    ese-fortune を実行しないようにしていたつもりが、そうなって
    なかったのを修正したつもり。
  ・その他、いらなさそうなところを少し削った。
  ・でも、かぜをひいているので、鼻水がついているかもしれない。１点

  [Version 1.04] 2002/11/26 (火)
  ・*ese-fortune-br* で改行認識文字列を指定できるようにした。
  ・mixed.dat をつくっておいた。

  [Version 1.03] 2002/11/25(月)
  ・ref2fortune を修正した。→ *.dat をすべて作成しなおした。
    ・もとの reference に \n 記述されている場合に、改行されてしまっていたところ。
    ・「■目的別索引」とかが、まとまってしまっていたところ。
  ・指定行に jump をつくった。（どちらかというと私の確認用）

  [Version 1.02] 2002/11/24(日)
  ・ref2fortune を修正した。
    ・行頭のホワイトスペースが削除されていたところ。
  ・同梱の reference.dat を reference.xml 2002.11.23版 から作り直した。
  ・ひとつのディレクトリにまとめた。
  ・その他細かい修正。

  [Version 1.01.1] 2002/11/22(金)
  ・そっと差し替え。

  [Version 1.01] 2002/11/22(金)
  ・random 関数に、二つ目の引数を与えた。佐野匡俊さんに感謝。

  [Version 1.00] 2002/11/21(木)
  ・とりあえず公開。


■ライセンス

  ese-fortune.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2002-2007 HIE Masahiro

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

(provide "ese-fortune")

(defconstant *ese-fortune-version* "1.09")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定
;;; ──────────────────────────────────── ;;;

(defvar *ese-fortune-enable* t
  "ese-fortune: 起動時に ese-fortune を実行")

(defvar *ese-fortune-dat* "reference.dat"
  "ese-fortune: データファイル")

(defvar *ese-fortune-dat-list* nil
  "ese-fortune: データファイルのリスト")

(defvar *ese-fortune-br* "\t"
  "ese-fortune: 改行認識文字列")

(defvar *ese-fortune-buffer* "*ese-fortune*"
  "ese-fortune: データ表示用バッファ名")

(defvar *ese-fortune-src-type* "dats"
  "ese-fortune: 実行時にデータ変換を行うファイルの拡張子")

(defvar *ese-fortune-dat-separator* "^%\n"
  "ese-fortune: データ自動変換時区切り文字列(正規表現)
* この正規表現にマッチする部分が改行(\n)に変換される。
* この単位がデータ 1 件とみなされる。")

(defvar *ese-fortune-absent* nil
  "ese-fortune: 起動時からぼうっと見る")

(defvar *ese-fortune-absent-interval* 10
  "ese-fortune: 更新間隔(秒)")

(defvar *ese-fortune-reference-update* t
  "ese-fortune: reference.txt 更新時に reference.dat を自動更新する")

(defvar *ese-fortune-title*
  " ese-fortune ver.~A --- ~A [No.~5,'0D]  a: absent, i: interval, n: next, j: jump, q: quit~%~%"
  "ese-fortune: タイトル文字列")

(defvar *ese-fortune-tmp-buffer* "*ese-fortune-tmp*"
  "ese-fortune: 一時バッファ")

(defvar *ese-fortune-open-filer-func* #'open-filer
  "ese-fortune: 「ファイラを開く」コマンド")

(defvar *ese-fortune-random-state* nil)


;;; ──────────────────────────────────── ;;;
;;;  ■ 対話的な関数
;;; ──────────────────────────────────── ;;;

(defun ese-fortune (&optional number file)
  "ese-fortune: 実行"
  (interactive)
  ;; *ese-fortune-dat* が nil なら終了
  (unless *ese-fortune-dat*
    (return-from ese-fortune nil))
  ;; データファイルに reference.dat が指定されている場合の処理
  (when (string= *ese-fortune-dat* "reference.dat")
    (let ((dat (merge-pathnames "reference.dat" (etc-path)))
	  (txt (merge-pathnames "reference.txt" (etc-path))))
      ;; reference.dat がない or 古い場合に作成/更新
      (if (file-exist-p txt)
	  (when (or (not (file-exist-p dat))
		    (and *ese-fortune-reference-update*
			 (> (file-write-time txt) (file-write-time dat))))
	    (ese-fortune-reftxt2dat))
	;; txt も dat もなければ終了
	(return-from ese-fortune nil)
	)))
  ;; データファイルの選択
  (let (dat fbuf tbuf blines num msg)
    (if file
	;; データファイルが引数指定されていれば優先的に使用する
	(setq dat file)
      (progn
	(let (files)
	  ;; ファイルリストを取得
	  (setq files (if (file-directory-p *ese-fortune-dat*)
			  (directory *ese-fortune-dat*
				     :absolute t
				     :wild "*"
				     :file-only t)
			*ese-fortune-dat-list*))
	  ;; ファイルリストが存在すれば，ファイルをランダムに選択
	  (if files
	      (let ((len (list-length files)))
		(setq dat (nth (random len *ese-fortune-random-state*) files)))
	    ;; ファイルリストがなければ *ese-fortune-dat* をデータファイルとする
	    (setq dat *ese-fortune-dat*)))
	;; ファイル名のみ指定の場合は(etc-path)を付加
	(when (string= (file-namestring dat) dat)
	  (setq dat (merge-pathnames dat (etc-path))))))
    ;; ese-fortune バッファの形成
    (if (setq fbuf (find-buffer *ese-fortune-buffer*))
	(progn
	  (set-buffer fbuf)
	  (setq buffer-read-only nil)
	  (delete-region (point-min) (point-max)))
      (progn
	(setq fbuf (create-new-buffer *ese-fortune-buffer*))
	(set-buffer fbuf)
	(ese-fortune-mode *ese-fortune-absent*)))
    ;; データファイルから今回表示するデータを取得
    (when (file-exist-p dat)
      ;; 作業用バッファとデータの準備
      (setq tbuf (create-new-buffer *ese-fortune-tmp-buffer*))
      (set-buffer tbuf)
      (insert-file-contents dat)
      ;; 必要に応じ拡張子の場合はデータ変換処理を行う
      (when (equal *ese-fortune-src-type*
		   (pathname-type dat))
	(ese-fortune-make-dat *ese-fortune-dat-separator*))
      (setq blines (1- (buffer-lines)))
      (goto-char (point-min))
      ;; 表示するデータの行数をランダムに選択
      (if number
	  (if (or (< number 1)
		  (> number blines))
	      (setq num -1)
	    (setq num (1- number)))
	(setq num (random blines *ese-fortune-random-state*)))
      ;; 指定行のデータを取得
      (if (= num -1)
	  (setq msg (format nil "1 ～ ~D までしかないよ。" blines))
	(progn
	  (forward-line num)
	  (setq msg (buffer-substring
		     (progn (goto-bol)(point))
		     (progn (goto-eol)(point))))))
      (setq msg (substitute-string msg *ese-fortune-br* "\n" ))
      (delete-buffer tbuf))
    ;; データを表示する
    (set-buffer fbuf)
    (insert (format nil *ese-fortune-title*
		    *ese-fortune-version*
		    (file-namestring dat)
		    (1+ (or num -1))))
    (unless num (insert "データがありません。０点"))
    (when msg (insert msg))
    ;; 現在のデータファイル名を記憶しておく
    (setq *ese-fortune-dat-current* dat))
  ;; バッファの状態を整える
  (goto-char (point-min))
  (setq buffer-read-only t)
  (set-buffer-modified-p nil)
  )

(defun ese-fortune-jump (num)
  "ese-fortune: 表示中のデータファイル指定行に移動"
  (interactive "nNo: ")
  (ese-fortune num *ese-fortune-dat-current*))

(defun ese-fortune-open-filer ()
  "ese-fortune: absent-mode を終了させファイラを開く"
  (interactive)
  (ese-fortune-absent-mode nil)
  (funcall *ese-fortune-open-filer-func*))

(defun ese-fortune-quit ()
  "ese-fortune: おわる"
  (interactive)
  (ese-fortune-absent-mode nil)
  (delete-buffer (selected-buffer)))


;;; ──────────────────────────────────── ;;;
;;;  ■ ese-fortune-mode
;;; ──────────────────────────────────── ;;;

(defvar *ese-fortune-mode-hook* nil)

(defvar *ese-fortune-mode-map* nil)
(unless *ese-fortune-mode-map*
  (setq *ese-fortune-mode-map* (make-sparse-keymap))
  (define-key *ese-fortune-mode-map* '#\a 'ese-fortune-absent-mode)
  (define-key *ese-fortune-mode-map* '#\i 'ese-fortune-set-absent-interval)
  (define-key *ese-fortune-mode-map* '#\n 'ese-fortune)
  (define-key *ese-fortune-mode-map* '#\j 'ese-fortune-jump)
  (define-key *ese-fortune-mode-map* '#\q 'ese-fortune-quit)
  (define-key *ese-fortune-mode-map* '#\. 'ese-fortune-quit)
  (define-key *ese-fortune-mode-map* '#\F12 'ese-fortune-fortune2dat)
  (define-key *ese-fortune-mode-map* '(#\C-c #\C-f) 'ese-fortune-open-filer)
  )

(defvar *ese-fortune-mode-syntax-table* nil)
(unless *ese-fortune-mode-syntax-table*
  (setq *ese-fortune-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *ese-fortune-mode-syntax-table*  #\-)
  (set-syntax-symbol *ese-fortune-mode-syntax-table*  #\*)
  )

(defun ese-fortune-mode(&optional absent)
  (interactive)
  (kill-all-local-variables)
  (setf buffer-mode 'ese-fortune-mode)
  (setq mode-name "ese-fortune")
  (use-keymap *ese-fortune-mode-map*)
  (use-syntax-table *ese-fortune-mode-syntax-table*)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (setq *ese-fortune-random-state* (make-random-state t))
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf (+ *window-flag-newline*
				   *window-flag-tab*
				   *window-flag-full-width-space*
				   *window-flag-eof*
				   *window-flag-cursor-line*
				   *window-flag-line-number*
				   *window-flag-half-width-space*
				   *window-flag-scrolling*)
			    nil)
    (set-local-window-flags buf (+ (if (boundp '*window-flag-fold-mark*)
				       *window-flag-fold-mark*
				     *window-flag-fold-line*))
			    t))
  (when absent
    (ese-fortune-absent-mode t))
  (run-hooks '*ese-fortune-mode-hook*))


;;; ──────────────────────────────────── ;;;
;;;  ■ 起動処理
;;; ──────────────────────────────────── ;;;

;;; xyzzy 起動時に ese-fortune を実行
(add-hook '*post-startup-hook* #'(lambda ()
				   (when (and *ese-fortune-enable*
					      ;; 引数としてファイルが指定されている場合は動作させないように
					      ;; と思ったが，あんまり意味ない？
					      (= 2 (length (buffer-list))))
				     (ese-fortune))))


;;; ──────────────────────────────────── ;;;
;;;  ■ ぼうっと見るための関数
;;; ──────────────────────────────────── ;;;

(defun ese-fortune-set-absent-interval ()
  "ese-fortune: 画面が切り替わる秒数を変更"
  (interactive)
  (let ((absent *ese-fortune-absent-mode*))
    (ese-fortune-absent-mode nil)
    (message "現在の設定値： ~D 秒" *ese-fortune-absent-interval*)
    (setq *ese-fortune-absent-interval* (read-integer "absent interval: "))
    (when absent
      (ese-fortune-absent-mode t))))

;;; ぼうっと見る
(defun ese-fortune-absent ()
  (if (find-buffer *ese-fortune-buffer*)
      (when (equal *ese-fortune-buffer* (buffer-name (selected-buffer)))
	(ese-fortune)
	(when (fboundp 'shake-window)
	  (shake-window)))
    (ese-fortune-return-to-me))
  (refresh-screen))

;;; ぼうっと見始める
(defun ese-fortune-absent-start ()
  (start-timer *ese-fortune-absent-interval* 'ese-fortune-absent))

;;; われに返る
(defun ese-fortune-return-to-me ()
  (stop-timer 'ese-fortune-absent))


;;; ──────────────────────────────────── ;;;
;;;  ■ ese-fortune-absent-mode
;;; ──────────────────────────────────── ;;;

(defvar-local *ese-fortune-absent-mode* nil)

(defun ese-fortune-absent-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*ese-fortune-absent-mode* arg sv)
  (update-mode-line t)
  (if *ese-fortune-absent-mode*
      (ese-fortune-absent-start)
    (ese-fortune-return-to-me))
  t)

(pushnew '(*ese-fortune-absent-mode* . "I am absentminded.") *minor-mode-alist* :key #'car)


;;; ──────────────────────────────────── ;;;
;;;  ■ データファイル作成
;;; ──────────────────────────────────── ;;;

(defun ese-fortune-reftxt2dat ()
  "ese-fortune: reference.txt からデータファイルを作成"
  (interactive)
  (long-operation
    (let ((txt (merge-pathnames "reference.txt" (etc-path)))
	  (dat (merge-pathnames "reference.dat" (etc-path)))
	  ;; この正規表現にマッチしない要素はスキップ
	  (reg ".*\\[    section\\]:.*")
	  ;(reg ".*\\(\\[    section\\]:\\|Copyright (c)\\).*")  ; なんのライセンスかわからなくなる。２点
	  (bufname "*reference.dat*")
	  buf)
      (when (file-exist-p txt)
	;; 作業用バッファとデータの準備
	(setq buf (create-new-buffer bufname))
	(set-buffer buf)
	(insert-file-contents txt t)
	;; データ変換開始
	(while (scan-buffer "^■" :regexp t :no-dup t)
	  (save-excursion
	    (save-restriction
	      (narrow-to-region (point)
				(progn
				  (or (scan-buffer "^■" :regexp t :tail nil :no-dup t)
				      (goto-char (point-max)))
				  (forward-char -1)
				  (point)))
	      (goto-char (point-min))
	      ;; section 指定のない要素はスキップ
	      (if (string-match reg (buffer-substring (point-min) (point-max)))
		  (replace-buffer "\n" "\t" :regexp t)
		(delete-region (point-min) (point-max))))))
	;; バッファ先頭から最初のセクションまでを削除
	(goto-char (point-min))
	(delete-region (point)
		       (progn
			 (scan-buffer "^■" :regexp t)
			 (point)))
	;; 改行だけの行を削除
	(replace-buffer "^\n" "" :regexp t)
	;; dat ファイルがあれば退避する
	(when (or (not (file-exist-p dat))
		  (copy-file dat (concat dat ".bak")
			     :if-exists :overwrite
			     :if-access-denied :error)
		  ;(yes-or-no-p "~A を上書きして良いですか？" dat)
		  )
	  (write-file dat))
	(delete-buffer buf)))))

(defun ese-fortune-fortune2dat ()
  "ese-fortune: fortune用データファイルをese-fortune用データファイルに変換"
  (interactive)
  (let ((bufname "*ese-fortune-fortune2dat*")
	buf src dat defdatname
	)
    (setq src (file-name-dialog
	       :title "変換元ファイルの指定 (fortune用データファイル)"
	       :multiple nil
	       :must-exist t
	       :filter '(("すべてのファイル(*.*)" . "*.*"))))
    (when (and src (file-exist-p src))
      (setq defdatname (merge-pathnames (concat (pathname-name src) ".dat") (etc-path)))
      (setq dat (file-name-dialog
		 :title "変換先ファイルの指定 (ese-fortune用データファイル)"
		 :default defdatname
		 :multiple nil
		 :filter '(("datファイル(*.dat)" . "*.dat")
			   ("すべてのファイル(*.*)" . "*.*"))))
      (when dat
	;; 作業用バッファとデータの準備
	(setq buf (create-new-buffer bufname))
	(set-buffer buf)
	(insert-file-contents src)
	;; データ変換
	(ese-fortune-make-dat "^%\n")
	;; dat ファイルがあれば退避する
	(when (file-exist-p dat)
	  (copy-file dat (concat dat ".bak")
		     :if-exists :overwrite
		     :if-access-denied :error))
	;; ファイルに書き込み
	(write-region (point-min) (point-max) dat)
	(delete-buffer buf)
	;; 確認用に作成したdatファイルを開く
	(find-file dat)))))

;;; ソースデータから ese-fortune 用データを適当に作成
;;;   引数として，データ区切りを表す正規表現を指定する
(defun ese-fortune-make-dat (reg &optional br)
  (let ((brtag "<ese-fortune-br>"))                    ; 仮改行を表す文字列
    (untabify (point-min) (point-max))                 ; 1. TAB文字を半角スペースに置換
    (goto-char 0) (replace-buffer reg brtag :regexp t) ; 2. 指定された正規表現部分を仮改行に置換
    (goto-char 0) (replace-buffer "\n" "\t")           ; 3. 改行をタブに置換
    (goto-char 0) (replace-buffer brtag (or br "\n"))  ; 4. 仮改行を改行に置換
    (goto-char 0) (replace-buffer "^\n" "" :regexp t)  ; 5. 改行だけの行を削除
    (goto-char (point-max)) (insert #\LFD)             ; 6. 末尾に改行を加える
    ))

;;; ese-fortune.l ends here.
