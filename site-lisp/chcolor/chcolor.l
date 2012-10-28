;;; -*- Mode: Lisp; Package: USER; Last modified: "2006/05/14 23:33:25" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;  chcolor.l --- バッファの「表示色」を切替え
;;;

;;;  概要:
;;;
;;;    xyzzy Part7 348, 354, 355, 361, 374 さん，および，
;;;    xyzzyの使い方がわからぬヤシ励ましあえその2 959 さん
;;;    の色設定を xyzzy Part7 420 さんの方法で変更して試し
;;;    てみる。
;;;
;;;    設定ファイルを読み書きするあたりを始め、いろいろと
;;;    SANO Masatoshi さんにもつくって頂きました。

;;;  インストール:
;;;
;;;    1. ディレクトリ chcolor を ~/site-lisp にコピーする。
;;;
;;;    2. .xyzzy とかに以下の記述を追加する。
;;;
;;;        (load-library "chcolor/chcolor")

;;;  使い方:
;;;
;;;    ・表示色を選択した後、表示色を変更
;;;
;;;        M-x chcolor
;;;
;;;      [表示色変更]
;;;         表示色設定パターンをファイルから選択し、現在バッファに反映
;;;         させる。
;;;
;;;      [既定色に戻す]
;;;         xyzzy.ini に設定されているパターンで表示して、次から開くバッ
;;;         ファは、chcolor による変更は行わないようにする。
;;;
;;;      [次から開くバッファも変更]
;;;         設定したパターンを次から開くバッファにも適用するかどうかの
;;;         切替え。
;;;
;;;      [常に全てのバッファを変更]
;;;         表示色変更時は、常に全てのバッファを変更するかどうかの切替え。
;;;
;;;      [表示色をファイルへ保存]
;;;         現在設定されている表示色パターンをファイルに書き出す。
;;;
;;;      [表示色変更終了]
;;;         次から開くバッファは、chcolor による変更は行わないよう
;;;         にする。
;;;
;;;    ・パターンファイルを選択して、表示色を変更
;;;
;;;        どこかから、chcolor-specify-file を実行する。

;;;  設定例:
;;;
;;;    ・キーバインド
;;;
;;;       (global-set-key #\M-e 'chcolor)
;;;
;;;      とか。
;;;
;;;    ・パターン番号を指定して、表示色を変更
;;;
;;;        ese-fortune(V1.07 以降)では、「黒板風」にする。
;;;
;;;          (add-hook '*ese-fortune-mode-hook*
;;;               #'(lambda () (chcolor-specify-file "黒板風")))

;;;  ■ ライセンス
;;;  
;;;    chcolor.l は NYSL Version 0.9982 に従います。
;;;  
;;;      NYSL - http://www.kmonos.net/nysl/
;;;  
;;;    A. 本ソフトウェアは Everyone'sWare です。このソフトを手にした一人一人が、
;;;       ご自分の作ったものを扱うのと同じように、自由に利用することが出来ます。
;;;  
;;;      A-1. フリーウェアです。作者からは使用料等を要求しません。
;;;      A-2. 有料無料や媒体の如何を問わず、自由に転載・再配布できます。
;;;      A-3. いかなる種類の 改変・他プログラムでの利用 を行っても構いません。
;;;      A-4. 変更したものや部分的に使用したものは、あなたのものになります。
;;;           公開する場合は、あなたの名前の下で行って下さい。
;;;  
;;;    B. このソフトを利用することによって生じた損害等について、作者は
;;;       責任を負わないものとします。各自の責任においてご利用下さい。
;;;  
;;;    C. 著作者人格権は HIE Masahiro，SANO Masatoshi に帰属します。著作権
;;;       は放棄します。
;;;  
;;;    D. 以上の３項は、ソース・実行バイナリの双方に適用されます。

;;;  更新履歴:
;;;
;;;    [Version 1.02] 2006/05/14 (日)
;;;    ・Windows XP で色設定の保存ができなくなっていたのを修正した。
;;;      米田さんに感謝。
;;;    ・ライセンスを適用した。
;;;
;;;    [Version 1.01] 2002/12/10 (火)
;;;    ・既定色をファイルに保存できなくなっていたのを修正した。
;;;    ・表示色変更を１度でも実行した後に、どこやらの hook で、
;;;      chcolor-specify-file を実行すると、それ以降のバッファで、
;;;      自分の意図した表示色でなくなってしまうのを修正した。
;;;
;;;    [Version 1.00] 2002/12/03 (火)
;;;    ・chcolor とした。

(provide "chcolor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign"))

(defvar *chcolor-refresh-next-buffer* t
  "chcolor: 次から開くバッファも変更")

(defvar *chcolor-refresh-all* t
  "chcolor: 常に全てのバッファを変更")

(defvar *chcolor-ini-dir* (concat (si:system-root) "site-lisp/chcolor/ini/")
  "chcolor: 表示色パターン設定ファイルの保存場所")

(defvar *chcolor-table* nil
  "chcolor: 表示色パターン")

(defvar *chcolor-keylist*
  '("textColor" "backColor" "ctlColor" "selectionTextColor" "selectionBackColor"
    "kwdColor1" "kwdColor2" "kwdColor3" "stringColor" "commentColor" "tagColor"
    "cursorColor" "caretColor" "imeCaretColor" "linenum" "reverse"
    "unselectedModeLineFg" "unselectedModeLineBg" "modeLineFg" "modeLineBg")
  "chcolor: ini file のキーのリスト")

(defvar *chcolor-menu* nil)

(defun chcolor-init ()
  "chcolor: menu の更新"
  (setq *chcolor-menu*
	(define-popup-menu
	  ;----------------------------------------------------------------------------
	  (:item nil "表示色変更(&O)" 'chcolor-select-file)
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "現バッファを既定色に戻す(&D)"
	   #'(lambda ()(interactive)(set-buffer-colors nil)))
	  (:item nil "全バッファを既定色に戻す(&R)"
	   #'(lambda ()(interactive)(setq *chcolor-table* nil)(chcolor-set -1 t)))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "次から開くバッファも変更(&N)" 'chcolor-toggle-refresh-next-buffer
	   #'(lambda ()(and *chcolor-refresh-next-buffer* :check)))
	  (:item nil "常に全てのバッファを変更(&A)" 'chcolor-toggle-refresh-all
	   #'(lambda ()(and *chcolor-refresh-all* :check)))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "表示色をファイルへ保存(&S)"
	   #'(lambda ()(interactive)
	       (chcolor-set)(refresh-screen)
	       (and (yes-or-no-p "現在表示色をファイルに保存しますよ。")
		    (chcolor-save-to-ini
		     (read-file-name "FileName: " :default *chcolor-ini-dir*)
		     *chcolor-keylist*))))
	  ;----------------------------------------------------------------------------
	  :sep
	  (:item nil "表示色変更終了(&Q)"
	   #'(lambda ()(interactive)(setq *chcolor-table* nil)(chcolor-stop-hook))
	   #'(lambda ()(unless *chcolor-table* :disable)))
	  ;----------------------------------------------------------------------------
	  )))

(defun chcolor ()
  (interactive)
  (unless *chcolor-menu* (chcolor-init))
  (track-popup-menu *chcolor-menu*))

(defun chcolor-select-file ()
  "chcolor: 設定ファイルを選択し表示色を変更"
  (interactive)
  (toggle-ime nil)
  (multiple-value-bind (file result)
      (let ((*filer-last-file-mask* '("*")))
	(filer *chcolor-ini-dir* nil "表示色パターンの選択" nil))
    (when result
      (unless (file-directory-p file)
	(let (nextbuf)
	  (if *chcolor-refresh-next-buffer* (setq nextbuf 1)(setq nextbuf -1))
	  (setq *chcolor-table* (chcolor-load-from-ini file *chcolor-keylist*))
	  (chcolor-set nextbuf *chcolor-refresh-all*))))))

(defun chcolor-set (&optional nextbuf all)
  "chcolor: 表示色パターンを使って表示色を変更"
  (let (tbl)
    (if *chcolor-table*
	(setq tbl (make-array 20 :initial-contents *chcolor-table*))
      (setq tbl nil))
    (if all
	(let ((sb (buffer-name (selected-buffer))))
	  (dolist (buf (buffer-list))
	    (set-buffer buf)(set-buffer-colors tbl))
	  (set-buffer sb))
      (set-buffer-colors tbl))
    (when nextbuf
      (cond ((= nextbuf  1)(chcolor-start-hook))
	    ((= nextbuf -1)(chcolor-stop-hook))))))

(defun chcolor-specify-file (file)
  "chcolor: 設定ファイルを指定して表示色を変更"
  (let (tbl pn)
    (if file
	(progn (setq pn (merge-pathnames file *chcolor-ini-dir*))
	  (when (file-exist-p pn)
	    (setq tbl (make-array 20 :initial-contents
				  (chcolor-load-from-ini pn *chcolor-keylist*)))))
      (setq tbl nil))
    (set-buffer-colors tbl)))

(defun chcolor-toggle-refresh-next-buffer ()
  "chcolor: 次から開くバッファも変更するかどうかの切替え"
  (interactive)
  (if *chcolor-refresh-next-buffer*
      (setq *chcolor-refresh-next-buffer* nil)
    (progn
      (setq *chcolor-refresh-next-buffer* t)(chcolor-set))))

(defun chcolor-toggle-refresh-all ()
  "chcolor: 常に全てのバッファを変更するかどうかの切替え"
  (interactive)
  (if *chcolor-refresh-all*
      (setq *chcolor-refresh-all* nil)
    (progn
      (setq *chcolor-refresh-all* t)(chcolor-set nil t))))

(defun chcolor-start-hook ()
  "chcolor: 次から開くバッファにも chcolor を適用"
  (add-hook '*fundamental-mode-hook* 'chcolor-hook))

(defun chcolor-stop-hook ()
  "chcolor: 次から開くバッファには chcolor を適用しないように"
  (delete-hook '*fundamental-mode-hook* 'chcolor-hook))

(defun chcolor-hook ()
  (and *chcolor-refresh-next-buffer* (chcolor-set)))


(let ((dll "kernel32"))
  (c:define-dll-entry c:int chcolor-get-private-profile-string-a
    ((c:char *) (c:char *) (c:char *) (c:char *) c:int (c:char *))
    dll "GetPrivateProfileStringA")
  (c:define-dll-entry c:int chcolor-write-private-profile-string-a
    ((c:char *) (c:char *) (c:char *) (c:char *))
    dll "WritePrivateProfileStringA"))

(defun chcolor-get-private-profile-string (App Key Def Size File)
  "chcolor: ini file から値を取得"
  (let ((chunk (si:make-chunk nil Size)))
    (chcolor-get-private-profile-string-a (si:make-string-chunk App)
			      (si:make-string-chunk Key)
			      (si:make-string-chunk Def)
			      chunk
			      Size
			      (si:make-string-chunk File))
    (si:unpack-string chunk 0)))

(defun chcolor-write-private-profile-string (App Key Str File)
  "chcolor: ini file へ値を保存"
  (chcolor-write-private-profile-string-a (si:make-string-chunk App)
			      (si:make-string-chunk Key)
			      (si:make-string-chunk Str)
			      (si:make-string-chunk File)))

(defun chcolor-load-from-ini (file kl)
  "chcolor: ini file から表示色パターンを取得"
  (mapcar #'(lambda (str)
	      (let ((ret 0))
		(setq str (string-downcase
			   (chcolor-get-private-profile-string "Colors" str "#0" 100 file)))
		(dotimes (i (length str))
		  (cond
		   ((lower-case-p (char str i))
		    (setq ret (* 16 (+ ret(- (char-code (char str i)) 87)))))
		   ((digit-char-p (char str i))
		    (setq ret (* 16 (+ ret(- (char-code (char str i)) 48)))))))
		(setq ret (/ ret 16))))
	  kl))

(defun chcolor-save-to-ini (file kl)
  "chcolor: ini file へ表示色パターンを保存"
  (let ((tw))
    (if *chcolor-table* (setq tw *chcolor-table*)
      (setq tw (chcolor-load-from-ini (chcolor-get-xyzzy-ini-name) kl)))
    (mapcar #'(lambda (Key Val)
		(chcolor-write-private-profile-string "Colors"  Key (format nil "#~X" Val) file))
	    kl tw)))

(defun chcolor-get-xyzzy-ini-name ()
  "chcolor: xyzzy.ini のフルパスを取得"
  (merge-pathnames "xyzzy.ini" (user-config-path)))


;;;
;;;  End of chcolor.l
;;;
