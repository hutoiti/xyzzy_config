#|
version  2006.09.15
category Utilities

■説明
キーバインドされている関数をポップアップメニューで表示する。

■問題点
・同じ関数に複数のキーが設定されていても、一つのキーしか表示できない。
・キーに関連付けられている関数が lambda 式だと
  不恰好な上に ctl-x-map などではちゃんとキーを表示できない。

■手動インストール方法
1. popup-key.l と popup-key.lc を ~/site-lisp に移動。
2. ~/.xyzzy か ~/site-lisp/siteinit.l に次の一文を追加。
   (require "popup-key")
3. xyzzy を再起動。
   ~/site-lisp/siteinit.l に書いたのなら
   Ctrl と Shift を押しながら xyzzy を起動して再ダンプ。

■アンインストール方法
NetInstaller で インストールしたときは、
NetInstaller 内で popup-key を選択して d を押す。

手動でインストールしたときは、
1. ESC ESC と入力。
2. (popup-key-uninstall) と入力。
3. .xyzzy か siteinit.l に書いた (require "popup-key") を削除。
4. ~/site-lisp の popup-key.l と popup-key.lc を削除。
5. 必要があればCtrl と Shift を押しながら xyzzy を起動して再ダンプ。

■使用例
表示(V) > ツールバー(Q) > ローカルキー(K) にチェックを入れて
そのバーを使うか、下記のようにキーバインド。

;ローカルキーとマイナーモードのキーをポップアップ
(global-set-key #\S-F1 'popup-key-local)

;マウスの位置ではなくカーソルの位置に表示したいというとき
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :any t)))

;同じキーで始まるものをまとめてツリー表示して欲しいとき。
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :expand t)))

;両方とも適用したい。
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :any t :expand t)))

;C-xで始まるキーをポップアップ ctl-x-map とかについては keymap.l を参照
(global-set-key '#\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key ctl-x-map :expand t)))

;これもローカルキーと同じようにポップアップ位置を変えられる。
(global-set-key '#\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key ctl-x-map :any t :expand t)))

■関数の説明

popup-key-local (&key any expand)
ローカルなキーをポップアップ。
メジャーモード(lisp-mode とか netinstaller みたいなの)と
マイナーモード(罫線モードみたいなの)の両方が表示されます。

:any はポップアップする位置。
:button1 :button2 にするか省略するとマウスの位置。
それ以外を指定するとカーソルの位置。
:expand はツリー化するかどうか。
これを t にすると、たとえば lisp-mode の ESC Ctrl+q と ESC Ctrl+x のような
同じキーを初めに押すものが一つの項目にまとめられてツリー化します。
省略するか nil にするとツリー化しません。
キーが多くないかぎりツリー化しないほうが見やすい気がします。

popup-key (keymap &key any expand)
指定したキーマップのキーをポップアップ。

keymap はキーマップ。ctl-x-map とか、spec-map とか。
これらのキーマップについては ~/lisp/keymap.l を参照

■更新履歴
2006.09.15 interactive でない関数も無理やり interactive 化するようにした。
           filer-keymap でも利用できるようになったが使い勝手悪い。
2006.04.16 documentation の扱いを修正。
           インデント方法をxyzzy標準のものに。
           カテゴリを変更。
2006.03.20 popup-key-add-doc を追加。
2006.03.15 公開。

■ライセンス
Copyright (c) 2006, sazasaza.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. Neither the name of the University nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

(provide "popup-key")
(in-package "editor")
(export '(popup-key
	  popup-key-local
	  popup-key-local-menu
	  popup-key-menu-fugaga
	  popup-key-menu
	  popup-key-list
	  popup-key-local-bar
	  popup-key-uninstall))

(defun popup-key (keymap &key (any :button2) expand)
  "popup-key: 指定したキーマップをポップアップ"
  (track-popup-menu (popup-key-menu
		     (popup-key-list ""
				     keymap
				     nil
				     :expand expand))
		    any))

(defun popup-key-local (&key (any :button2) expand)
  "popup-key: ローカルなキーをポップアップ"
  (interactive)
  (track-popup-menu (popup-key-local-menu :expand expand) any))

(defun popup-key-local-menu (&key expand menu)
  (let ((list (nreverse (popup-key-list ""
					(local-keymap)
					nil
					:expand expand))))
    (dolist (x (minor-mode-map))
      (push nil list)
      (dolist (y (popup-key-list ""
				      x
				      nil
				      :expand expand))
	(push y list)))
    (popup-key-menu (nreverse list) menu)))

(defun popup-key-menu-fugaga (item i)
  "(values popup tag name object)"
  (when item
    (cond ((atom item)
	   (values nil
		   nil
		   (concat "&" (string (code-char i)) ": "
			   (let ((s (documentation item 'function)))
			     (if s
				 (substring s 0 (position #\LFD s))
			       (string item))))
		   (if (commandp item)
		       item
		     #'(lambda ()
			 (interactive)
			 (funcall item)
			 ))))
	  ((eq :lambda (car item))
	   (values nil
		   nil
		   (concat "&"
			   (string (code-char i))
			   ": lambda - "
			   (second item))
		   (third item)))
	  (t
	   (values t
		   nil
		   (concat "&"
			   (string (code-char i))
			   ": "
			   (car item))
		   (popup-key-menu (cdr item)))))))

(defun popup-key-menu (list &optional menu)
  (unless menu
    (setq menu (create-popup-menu 'popup-key)))
  (let ((i (char-code #\1))
	(separator t))
    (dolist (x (if (car list)
		   list
		 (cdr list)))
      (multiple-value-bind (popup tag name object)
	  (popup-key-menu-fugaga x i)
	(if name
	    (progn
	      (setq separator nil)
	      (if popup
		  (add-popup-menu menu
				  object
				  name)
		(add-menu-item menu
			       tag
			       name
			       object))
	      (setq i (case (code-char i)
			(#\9 (char-code #\A))
			(#\Z (char-code #\{))
			(#\~ (char-code #\:))
			(#\@ (char-code #\SPC))
			(#\SPC i)
			(t (1+ i)))))
	  (unless separator
	    (add-menu-separator menu)
	    (setq separator t)))))
    menu))

;キーマップから関数のリストを返す。
;同じキーで始まるものは(list "キーもしくはマップ名" + 関数のリスト)
;lambdaは(list 'lambda "キーのstr" + 実際のlambda式)
;ほとんどkeymap.lのdescribe-bindings-1のコピペ
(defun popup-key-list (prefix keymap shadow &key prefix-string expand)
  (setq keymap (keymapp keymap))
  (when keymap
    (let (prefixlist result)
      (setq shadow (mapcan #'(lambda (x)
			       (setq x (keymapp x))
			       (and x (list x)))
			   shadow))
      (do ((index 0)
	   (nl nil))
	  ((>= index *full-keymap-length*))
	(let ((nindex (1+ index))
	      (bound (lookup-keymap-index keymap shadow index)))
	  (when bound
	    (if (>= index 128)
		(when nl
		  (push nil result)
		  (setq nl nil))
	      (unless nl
		(push nil result)
		(setq nl t)))
	    (cond ((symbolp bound)
		   (while (and (< nindex *full-keymap-length*)
			       (eq bound (lookup-keymap-index keymap shadow nindex)))
		     (setq nindex (1+ nindex)))
		   (push bound result))
		  ((keymapp bound))
		  (t
		   (push (list :lambda
			       (format nil
				       "~A~:C"
				       prefix
				       (*keymap-index-char index))
			       bound)
			 result))))
	  (setq index nindex)))
      (dotimes (index *full-keymap-length*)
	(let* ((c (*keymap-index-char index))
	       (x (lookup-keymap keymap c)))
	  (when (keymapp x)
	    (let ((y (mapcar #'(lambda (x) (lookup-keymap x c)) shadow)))
	      (when (notany #'(lambda (x) (and x (not (keymapp x)))) y)
		(let ((list (popup-key-list
			     (format nil "~A~:C " prefix c)
			     x
			     y
			     :prefix-string
			     (if (sequencep x)
				 (concat (format nil "~A~:C" prefix c) " prefix")
			       (string x))
			     :expand expand)))
		  (if expand
		      (push list prefixlist)
		    (dolist (x list)
		      (push x result)))))))))
      (if expand
	  (if prefix-string
	      (append (list prefix-string)
		      (nreverse prefixlist)
		      (nreverse result))
	    (append (nreverse prefixlist)
		    (nreverse result)))
	(nreverse result)))))

(defun popup-key-local-bar ()
  (create-tool-bar
   'popup-key-local-bar
   (merge-pathnames "toolbar.bmp" (etc-path))
   '(("ローカルキー" 59 popup-key-local))))
(define-command-bar 'popup-key-local-bar "ローカルキー(&K)")

(defun popup-key-uninstall ()
  (delete-command-bar 'popup-key-local-bar))
