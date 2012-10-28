;;; -*- Mode: Lisp; Last updated: <2007/12/31 01:05:37>; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   bufmenu.l - バッファ操作用ポップアップメニュー
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  ・非表示バッファも含め，バッファの一覧をポップアップ表示します。
  ・KaMail とか www-mode を使用しているときに一覧からバッファの選択を行うと，
    「Frame 1」に移動して開きます。
  ・非表示バッファを選択した場合は，現在のフレームで開きます。
  ・バッファの一覧は，バッファ名，もしくは参照しているファイル名で表示し，それ
    ぞれ名前順にソートされます。
  ・必要に応じ，フレームの一覧も表示します。
  ・バッファバーコンテキストメニューに，バッファをまとめて閉じたり，実行したり
    名前をコピーしたりするメニューを追加します。


■製作理由

  何故こんなものをつくったかというと…，
  
  ・常日頃，KaMail などの独自フレームを使用する拡張ものを常時使用している
    のですが，[Frame 1 に移動] → [バッファ選択] という処理がメンドーであ
    る。
  ・www-mode などのバッファを非表示にして使っているのですが，よくよく他の
    バッファを開いてしまい戻せなくなってしまう。
  ・バッファバーに収まりきらない程多くのバッファを開いている中からバッファ
    を選択する場合に，select-buffer でも良いのですが，毎回ソートし直す必要
    があったり，私には必要ない情報があって見にくかったりする。
  ・場合によって，バッファリストをバッファ名で表示したり，ファイル名で表示
    したりしたかった。
  ・必要ないけどフレームをリストから選択してみたかった。
  ・xyzzy Note に書いていたバッファバーコンテキストメニュー用の Lisp に，
    目に余る部分が多々あった…。
  ・ふかえさんの Tips（タブブラウザっぽいメニュー）に少しばかり手を加えて
    使いたかった。（閉じて欲しくないバッファを指定したり）
  ・なんとなくつくってみたかった。
  
  から。


■インストール

  1. bufmenu.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "bufmenu")

  4. xyzzy を再起動し，設定を反映させる。
     siteinit.l に記述した場合は再ダンプもする。


■ツールバー設定

  ツールバーを使う場合は，[表示]-[ツールバー]-[bufmenu] にチェックを入れます。


■アンインストール

  1. ツールバー情報を削除する。
     ESC キーを２回押した後，ミニバッファに
       (bufmenu-uninstall-tool-bar)
    と入力し，Enter する。

  2. 初期化ファイルから設定を削除する。
     siteinit.l に記述していた場合は再ダンプする。

  3. このファイル bufmenu.l（および bufmenu.lc）を削除する。


■設定例

    ;;; バッファ選択ポップアップリスト表示 [C-Apps C-Apps]
    (global-set-key '(#\C-Apps #\C-Apps) 'bufmenu-popup)
    
    ;;; バッファバーコンテクストメニューを表示 [C-Apps Apps]
    (global-set-key '(#\C-Apps #\Apps) 'bufmenu-popup-buffer-bar-context-menu)

  とか。


■カスタマイズ

  山本さんの favorites.l で，特定のフレームの場合は既定のフレームに移動し
  て開く。

  (defun open-favorites-func (f)
    "お気に入りを開く"
    (if (string= (pathname-type f) "lnk")
        (setq f (resolve-shortcut f)))
    (cond ((not (file-exist-p f))
           (message "~A はリンク切れです" (file-namestring f)))
          (*favorites-open-with-shell*
           (shell-execute (map-slash-to-backslash f)))
          (t
           (bufmenu-select-default-frame)
           (find-file f)
           (add-history f '*minibuffer-file-name-history*))))

  bufmenu 最近使ったファイル一覧を特定のフレームの場合は既定のフレームに
  移動して開く。元ネタは，xyzzy Part6 332 さんの list-recents。

    (defun bufmenu-list-recents ()
      "bufmenu 最近使ったファイル一覧"
      (interactive)
      (let (hlist filename)
        (setq hlist (mapcar #'(lambda (x)
                                (list (abbreviate-display-string x 60 t) x))
                            *minibuffer-file-name-history*))
        (multiple-value-bind (result data)
            (dialog-box
             '(dialog 0 0 286 162
               (:caption "bufmenu : 最近使ったﾌｧｲﾙ")
               (:font 9 "ＭＳ Ｐゴシック")
               (:control
                (:listbox flist nil #x50b10111 7 7 216 148)
                (:button IDOK "OK" #x50010001 229 7 50 14)
                (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 229 24 50 14)))
             (list (cons 'flist hlist))
             `((flist :must-match t :enable (IDOK))))
          (when result
            (setq filename (car (cddr (assoc 'flist data))))
            (bufmenu-select-default-frame)
            (find-file filename)
            (add-history filename '*minibuffer-file-name-history*)))))

  バッファバーコンテキストメニューに，OHKUBOさんの browserex を追加する場
  合は，こんな感じで。

  (add-hook '*bufmenu-add-context-menu-middle-hook*
            #'(lambda ()
                (let (menu)
                  (setq menu *buffer-bar-context-menu*)
                  (flet ((buf () *buffer-bar-context-menu-buffer*))
                    (add-menu-separator menu)
                    (add-menu-item menu nil "ﾌﾞﾗｳｻﾞで表示(&B)"
                                   #'(lambda () (interactive)
                                       (set-buffer (buffer-name (buf)))
                                       (bx:navigate-current-buffer)))))))


■更新履歴

  [Version 1.05] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.04] いつ？
  ・メニューを全角カタカナに。

  [Version 1.03] 2004/10/31(日)
  ・「これ以外を閉じる」が正しく動作していなかったのを修正した。
    xyzzyの使い方が分からぬやし 励ましあえ その5 の 215 さん，216 さん
    ありがとうございます。m(_ _)m

  [Version 1.02] 2004/06/20(日)
  ・設置場所を site-lisp/bufmenu/bufmenu.l から，site-lisp/bufmenu.l
    に戻した。
  ・非表示バッファを選択したときは，フレームを移動しないようにした。
  ・既定のフレーム以外のフレームが存在しても「すべてのバッファを閉じる」
    が動作するようにした。
  ・バッファバーコンテクストメニューに余計なモノを追加するようにした。
  ・その他不具合修正とかいろいろ。

  [Version 1.01] 2003/05/30(金)
  ・「表示設定」変更後は，メニューを再表示するようにした。
  ・非表示バッファの表示方法を変更した。

  [Version 1.00 (2003.05.22)]
  ・つくった。


■ライセンス

  bufmenu.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2003-2007 HIE Masahiro

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

(provide "bufmenu")


;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定（適当にカスタマイズするあたり）
;;; ──────────────────────────────────── ;;;

;;; 既定のフレーム
(defvar *bufmenu-default-frame* "Frame 1")

;;; ここに登録したフレームでバッファを選択すると既定のフレームで開く
(defvar *bufmenu-hide-buffer-frame-list*
  '("2ch" "KaMail" "WWW" "*tterm*" "RSS" "NetInst" "CalMemo"))

;;; まとめて閉じる系のメニューで閉じないバッファのリスト
(defvar *bufmenu-no-close-buffer-list*
  '("*WWW " "*NetInstaller " "*KaMail:" "*RSS " "*CalMemo:" "*Diary" "*scratch*"))

;;; フレームメニューを表示する
(defvar *bufmenu-use-frame-menu* t)

;;; 表示設定メニューを表示しない
(defvar *bufmenu-hide-option-menu* nil)

;;; バッファ選択リストをファイル名で表示する
(defvar *bufmenu-use-file-name* t)

;;; 既定のフレームに移動して開く
(defvar *bufmenu-switch-pseudo-frame* t)

;;; バッファバーコンテクストメニューにいろいろ追加する
(defvar *use-buffer-bar-context-menu* t)

;;; バッファから送るのリスト
;;;   おそらく *filer-send-to-list* と同じ書式
;;;   オプション付で起動する場合はリストで記述
(defvar *bufmenu-send-to-list*
  (list
   '(" Internet Explorer" . "C:/Program Files/Internet Explorer/IEXPLORE.EXE")
   '(" Mozilla Firefox"   . "C:/Program Files/Mozilla Firefox/firefox.exe")
   '(" TeraPad(ro)"       . '("C:/usr/local/TeraPad/TeraPad.exe" "/r"))
   (cons "[Desktop]" (map-backslash-to-slash
		      (get-special-folder-location :desktop)))
   ))

;;; バッファバーコンテキストメニュー追加前に評価するフック
(defvar *bufmenu-add-context-menu-pre-hook* nil)

;;; バッファバーコンテキストメニュー追加中に評価するフック
(defvar *bufmenu-add-context-menu-middle-hook* nil)

;;; バッファバーコンテキストメニュー追加後に評価するフック
(defvar *bufmenu-add-context-menu-hook* nil)


;;; ──────────────────────────────────── ;;;
;;;  ■ メニュー表示用コマンド
;;; ──────────────────────────────────── ;;;

(defun bufmenu-popup (&optional apps)
  "bufmenu バッファ選択ポップアップリスト表示"
  (interactive)
  (bufmenu-mouse-popup t))

(defun bufmenu-popup-buffer-bar-context-menu ()
  "bufmenu バッファバーコンテクストメニューを表示"
  (interactive)
  (setq *buffer-bar-context-menu-buffer* (selected-buffer))
  (track-popup-menu *buffer-bar-context-menu*))


;;; ──────────────────────────────────── ;;;
;;;  ■ バッファをまとめて閉じる関数
;;; ──────────────────────────────────── ;;;

(defun bufmenu-kill-all-buffers (&optional exception)
  "bufmenu 全てのバッファを閉じる"
  (interactive)
  (let ((buffer-lst nil))
    (dolist (b (buffer-list) t)
      (let ((bn (buffer-name b)))
	(unless (or (string= bn " " :end1 1)
		    (string= bn exception)
		    (member-if #'(lambda (x)
				   (let ((lbn (length bn))
					 (lx (length x)))
				     (and (>= lbn lx)
					  (string= bn x :end1 lx))))
			       *bufmenu-no-close-buffer-list*))
	  (push b buffer-lst))))
    (when (and (> (list-length buffer-lst) 0)
	       (or exception
		   (yes-or-no-p "バッファを全部閉じますよ。")))
      (dolist (buffer buffer-lst t)
	(kill-buffer buffer)))))

(defun bufmenu-close-other-buffers ()
  "bufmenu 現在のバッファ以外を閉じる"
  (interactive)
  (bufmenu-kill-all-buffers
   (buffer-name *buffer-bar-context-menu-buffer*)))

;;; 左右のバッファをまとめて閉じる
;;;   ふかえさんの Tips を参考に m(_ _)m (version 0.2.2.233 以降)
;;;   *bufmenu-no-close-buffer-list* に登録されたバッファは閉じないように
(defun bufmenu-close-right-buffers (&optional left)
  "bufmenu 右のバッファをすべて閉じる"
  (interactive)
  (let ((mb *buffer-bar-context-menu-buffer*)
	(eb (get-next-buffer (if left :bottom :top) nil t)))
    (let ((nb (get-next-buffer mb left t)) b bn)
      (while (not (equal nb eb))
	(setq b nb
	      nb (get-next-buffer nb left t)
	      bn (buffer-name b))
	(unless (or (string= bn " " :end1 1)
		    (member-if #'(lambda (x)
				   (let ((lbn (length bn))
					 (lx (length x)))
				     (and (>= lbn lx)
					  (string= bn x :end1 lx))))
			       *bufmenu-no-close-buffer-list*))
	  (kill-buffer b))))
    (switch-to-buffer mb)))

(defun bufmenu-close-left-buffers ()
  "bufmenu 左のバッファをすべて閉じる"
  (interactive)
  (bufmenu-close-right-buffers t))


;;; ──────────────────────────────────── ;;;
;;;  ■ ツールバー関連の関数
;;; ──────────────────────────────────── ;;;

;;; bufmenu ツールバー定義
(defun bufmenu-tool-bar ()
  (create-tool-bar 'bufmenu-tool-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("バッファリスト" 21 bufmenu-mouse-popup))))

;;; bufmenu ツールバー登録
(define-command-bar 'bufmenu-tool-bar "bufmenu(&U)")

;;; bufmenu ツールバー削除
(defun bufmenu-uninstall-tool-bar ()
  (delete-command-bar 'bufmenu-tool-bar))


;;; ──────────────────────────────────── ;;;
;;;  ■ その他の関数
;;; ──────────────────────────────────── ;;;

;;; 状況に応じ既定のフレームに移動
(defun bufmenu-select-default-frame ()
  (when (and (member (ed::pseudo-frame-name (selected-pseudo-frame))
		     *bufmenu-hide-buffer-frame-list*
		     :test #'equal)
	     *bufmenu-switch-pseudo-frame*)
    (select-pseudo-frame (find-pseudo-frame *bufmenu-default-frame*))))

(defun bufmenu-switch-to-buffer (buffer)
  "bufmenu 既定のフレームで switch-to-buffer"
  (interactive "bSwitch to buffer: ")
  (bufmenu-select-default-frame)
  (switch-to-buffer buffer))

(defun bufmenu-sendto-dialog (file)
  "bufmenu 「送る」ダイアログ"
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box
       '(dialog 0 0 219 100
	 (:caption "送っちゃうよ")
	 (:font 9 "ＭＳ Ｐゴシック")
	 (:control
	  (:listbox list nil #x50b10111 7 7 150 82)
	  (:button IDOK "送る" #x50010001 162 7 50 14)
	  (:button IDCANCEL "送らない" #x50010000 162 24 50 14)))
       (list (cons 'list *bufmenu-send-to-list*))
       nil)
    (when result
      (let (len item cmd opt)
	(setq len (assoc 'list data))
	(if (equal (list-length len) 2)
	    (setq cmd (cddr (assoc 'list data)))
	  (progn
	    (setq item (cdddr (assoc 'list data)))
	    (setq cmd (caar item))
	    (setq opt (cadar item))))
	(if cmd
	    (if (file-directory-p cmd)
		(progn
		  (copy-file file (merge-pathnames (file-namestring file) cmd))
		  (shell-execute cmd))
	      (when (file-exist-p cmd)
		(call-process (concat (map-slash-to-backslash cmd)
				      (when opt
					(concat " " opt))
				      " \"" (map-slash-to-backslash file) "\"")
			      :wait nil)))
	  (message "なにもえらんでない。"))))))


;;; ──────────────────────────────────── ;;;
;;;  ■ バッファ選択ポップアップリスト
;;; ──────────────────────────────────── ;;;

(defun bufmenu-mouse-popup (&optional apps)
  "bufmenu ポップアップリスト表示"
  (interactive)
  (let ((menu (create-popup-menu)) submenu)
    (let ((bn (buffer-name (selected-buffer)))
	  (frame (member (ed::pseudo-frame-name (selected-pseudo-frame))
			 *bufmenu-hide-buffer-frame-list*
			 :test #'equal)))
      (save-excursion
	;; フレーム一覧
	(when (and *bufmenu-use-frame-menu*
		   (< 1 (list-length ed::*pseudo-frame-list*)))
	  (dolist (pfr ed::*pseudo-frame-list*)
	    (let ((item (ed::pseudo-frame-name pfr)))
	      (when (zerop (string/= item " "))
		(add-menu-item menu nil
			       (concat "[ " item " ]")
			       #'(lambda () (interactive)
				   (select-pseudo-frame (find-pseudo-frame item)))
			       #'(lambda ()
				   (when (string=
					  item
					  (ed::pseudo-frame-name (selected-pseudo-frame)))
				     :check))))))
	  (add-menu-separator menu nil))
	;; てんぽらりバッファ一覧
	(dolist (buffer (buffer-list))
	  (bufmenu-add-menu-item menu buffer bn frame 1))
	;; バッファ一覧
	(if *bufmenu-use-file-name*
	    (dolist (buffer (sort (buffer-list) #'string< :key #'get-buffer-file-name))
	      (bufmenu-add-menu-item menu buffer bn frame))
	  (dolist (buffer (buffer-list))
	    (bufmenu-add-menu-item menu buffer bn frame)))
	;; 非表示バッファ一覧
	(when (< 1 (list-length (let (lst)
				  (dolist (buf (buffer-list))
				    (let ((bn (buffer-name buf)))
				      (unless (zerop (string/= bn " "))
					(push bn lst))))
				  lst)))
	  (setq submenu (create-popup-menu))
	  (dolist (buffer (buffer-list))
	    (bufmenu-add-menu-item submenu buffer bn frame -1)))))
    (add-menu-separator menu nil)
    (when submenu
      (add-popup-menu menu submenu "非表示バッファ(&H)"))
    (unless *bufmenu-hide-option-menu*
      ;; 設定メニュー
      (add-popup-menu menu
		      (define-popup-menu
			(:item nil "フレームも表示(&F)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-use-frame-menu*
				   (not *bufmenu-use-frame-menu*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-use-frame-menu* :check)))
			(:item nil "ファイル名で表示(&N)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-use-file-name*
				   (not *bufmenu-use-file-name*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-use-file-name* :check)))
			(:item nil "非表示バッファ以外は既定のフレームで表示(&S)"
			 #'(lambda ()
			     (interactive)
			     (setq *bufmenu-switch-pseudo-frame*
				   (not *bufmenu-switch-pseudo-frame*))
			     (bufmenu-popup))
			 #'(lambda ()
			     (when *bufmenu-switch-pseudo-frame* :check)))
			)"表示設定(&S)"))
    (track-popup-menu menu (or apps :button2))))

;;; type: -1:hide, 0:normal, 1:temp
(defun bufmenu-add-menu-item (menu buffer bn frame &optional (type 0))
  "bufmenu メニューアイテムの追加"
  (let ((item (buffer-name buffer))
	(fn (get-buffer-file-name buffer)))
    (when (and (string/= item " *Minibuf0*")
	       (cond ((zerop type)
		      (and (zerop (string/= item "*"))
			   (zerop (string/= item " "))))
		     ((plusp type)
		      (not (zerop (string/= item "*"))))
		     ((minusp type)
		      (not (zerop (string/= item " "))))))
      (add-menu-item menu nil
		     (if *bufmenu-use-file-name*
			 (or fn item)
		       item)
		     #'(lambda () (interactive)
			 (when (and frame
				    *bufmenu-switch-pseudo-frame*
				    (not (string-match "^ " item)))
			   (select-pseudo-frame (find-pseudo-frame *bufmenu-default-frame*)))
			 (switch-to-buffer item))
		     #'(lambda ()
			 (when (string= item (buffer-name (selected-buffer)))
			   :check))))))


;;; ──────────────────────────────────── ;;;
;;;  ■ バッファバーコンテクストメニューにメニューを追加
;;; ──────────────────────────────────── ;;;

(defun bufmenu-add-buffer-bar-context-menu ()
  (run-hooks '*bufmenu-add-context-menu-pre-hook*)
  (when *use-buffer-bar-context-menu*
    (flet ((bn  () (buffer-name *buffer-bar-context-menu-buffer*))
	   (bfn () (get-buffer-file-name *buffer-bar-context-menu-buffer*))
	   (sb  () (bufmenu-switch-to-buffer (buffer-name *buffer-bar-context-menu-buffer*)))
	   ;; バッファのファイル名をベースに新しいファイル名を取得
	   (newfile ()
	     (let* ((newpathfile (read-file-name "新しいファイル名: "
						 :default (get-buffer-file-name))))
	       (if (file-exist-p newpathfile)
		   (progn
		     (message-box "~A ~A" newpathfile " はもうあるよん")
		     nil)
		 newpathfile)))
	   ;; バッファがファイルを参照していなければ :disable
	   (chkbfn ()
	     (unless (get-buffer-file-name *buffer-bar-context-menu-buffer*)
	       :disable)))
      (let (menu)
	(setq menu *buffer-bar-context-menu*)
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "これ以外を閉じる(&W)"   'bufmenu-close-other-buffers)
	(add-menu-item menu nil "すべて閉じる(&*)" 'bufmenu-kill-all-buffers)
	(add-menu-item menu nil "これより左を閉じる(&<)" 'bufmenu-close-left-buffers)
	(add-menu-item menu nil "これより右を閉じる(&>)" 'bufmenu-close-right-buffers)
	;------------------------------
;; 	(add-menu-separator menu)
;; 	(add-menu-item menu nil "Switch to buffer(&S)"
;; 		       #'(lambda () (interactive)
;; 			   (bufmenu-switch-to-buffer (bn))))
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "送る(&T)..."
		       #'(lambda () (interactive)
			   (bufmenu-sendto-dialog (bfn)))
		       #'chkbfn)
	(add-menu-item menu nil "ファイルを実行(&X)"
		       #'(lambda () (interactive) (shell-execute (bfn)))
		       #'chkbfn)
	;------------------------------
	(run-hooks '*bufmenu-add-context-menu-middle-hook*)
	;------------------------------
	(add-menu-separator menu)
	(add-popup-menu menu
			(define-popup-menu
			  (:item nil "ファイル名を変更(&R)"
			   #'(lambda () (interactive) (sb)
			       (let (f nf)
				 (setq f (get-buffer-file-name))
				 (setq nf (newfile))
				 (when (ignore-errors (rename nf))
				   (save-buffer)
				   (delete-file f)
				   (message "~A ~A" nf " にリネームしますた"))))
			   #'chkbfn)
			  (:item nil "ファイルをコピーして開く(&O)"
			   #'(lambda () (interactive) (sb)
			       (let (nf)
				 (setq nf (newfile))
				 (when nf
				   (copy-file (get-buffer-file-name) nf)
				   (find-file nf)
				   (message "~A ~A" nf " にコピーしますた"))))
			   #'chkbfn)
			  :sep
			  (:item nil "ファイルを削除(&D)"
			   #'(lambda () (interactive) (sb)
			       (let (f)
				 (setq f (get-buffer-file-name))
				 (and (no-or-yes-p "~A ~A" f "を削除します。")
				      (when (delete-file f)
					(delete-buffer (selected-buffer))
					(message "~A ~A" f  " を削除しますた")))))
			   #'chkbfn)
			  ) "ファイル操作(&F)")
	;------------------------------
	(add-popup-menu menu
			(define-popup-menu
			  (:item nil "バイトコンパイル(&C)"
			   #'(lambda () (interactive) (byte-compile-file (bfn)))
			   #'(lambda ()
			       (unless (equal (ignore-errors (pathname-type (bfn))) "l")
				 :disable)))
			  :sep
			  (:item nil "Eval buffer(&E)"
			   #'(lambda () (interactive)
			       (eval-buffer *buffer-bar-context-menu-buffer*)))
			  (:item nil "Load(&L)"
			   #'(lambda () (interactive) (load (bfn)))
			   #'chkbfn)
			  ) "Lisp(&L)")
	;------------------------------
	(add-menu-separator menu)
	(add-menu-item menu nil "バッファ名をコピー(&B)"
		       #'(lambda () (interactive) (copy-to-clipboard (bn))))
	(add-menu-item menu nil "ファイル名(/)をコピー(&R)"
		       #'(lambda () (interactive) (copy-to-clipboard (bfn)))
		       #'chkbfn)
	(add-menu-item menu nil "ファイル名(\\)をコピー(&F)"
		       #'(lambda () (interactive)
			   (copy-to-clipboard (map-slash-to-backslash (bfn))))
		       #'chkbfn)
	)))
  (run-hooks '*bufmenu-add-context-menu-hook*))

;;; 起動時にバッファバーコンテクストメニューに追加を実行
(add-hook '*init-app-menus-hook* #'bufmenu-add-buffer-bar-context-menu)


;;; bufmenu.l ends here.
