#|
version  2007.10.10
category Libraries

■説明
成り行きで作ることになってしまったタブ操作ライブラリのようなもの。
たぶん行き当たりばったりで仕様変更します。
利点はタブの入れ替えが多少容易なくらい。

■勝手な用語
bar    タブバーを識別するシンボル。'buffer-bar とか。
tab    タブを識別するシンボル。tab-bar-select-item とかで使う。
       sztab-add などをしたときに gensym で生成される
item   タブ(tab)に関連付けられたもの。bufbar2 ならバッファ。
       文字列とかでもよい。nil を指定するとおかしくなる。
add-position    :last :first :previous :next :after :before のどれか
delete-position :previous :next :after :before のどれか

tab-bar-select-item の item はここでいう tab のことなので、
この用語はよくなさそうなんだがどうすりゃいいんだか。

:next と :after
:previous と:before は同じ意味

■シンボルに勝手につけるプロパティ。直接触らず sztab-tab-xxx とか sztab-bar-xxx で。
bar
 :sztab-select-hook
 :sztab-caption-hook
 :sztab-tooltip-hook
 :sztab-menu-hook
 :sztab-test
 :sztab-add-position-variable
 :sztab-delete-position-variable
 :sztab-dont-run-select-hook
 :default-item-property-table
 :item-property-tables

tab
 :item
 :caption
 :tooltip
 :bar

■その他
select-hook caption-hook tooltip-hook menu-hook の引数は、item と tab

bufbar2.l では caption-hook と tooltip-hook を使っているが、
これらは使わず単純に指定してよい。
menu は menu-hook を使わないといけない。

item に対応する tab は変更されることがある。
同じ item を2つ以上管理するようなものには向いていないかもしれない。

sztab-item-property は存在していない item であろうと設定できてしまう。
つかこの機能はタブとあんまり関係ない。

■更新履歴
2007.10.10 関数の返値をまともに。
2006.10.20 sztab-item-property などを追加。
2006.09.21 いろいろ。
2006.09.15 いろいろ変更。
           toggle-command-bar の存在に気付き sztab-toggle を削除。
2006.09.04 sztab-create の &optional を &key に。
           sztab-set-item と sztab-modify も &key を使うように。
           sztab-toggle sztab-update-all sztab-modify-item を追加。
           勝手に require してることに気付いたが変更すんのめんどい。
2006.07.01 小物を追加。
2006.04.16 インデント方法をxyzzy標準のものに。
2006.04.14 やっぱり気になったので大幅修正。
2006.04.07 公開。

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

(in-package "editor")
(provide "sztab")

(export '(sztab-tab-item
	  sztab-tab-bar
	  sztab-tab-caption
	  sztab-tab-tooltip
	  sztab-bar-select-hook
	  sztab-bar-dont-run-select-hook
	  sztab-bar-caption-hook
	  sztab-bar-tooltip-hook
	  sztab-bar-menu-hook
	  sztab-bar-add-position-variable
	  sztab-bar-delete-position-variable
	  sztab-bar-test
	  sztab-bar-default-item-property-table
	  sztab-bar-item-property-tables
	  sztab-run-hook
	  sztab-run-caption-hook
	  sztab-run-tooltip-hook
	  sztab-run-menu-hook
	  sztab-run-select-hook
	  sztab-drsh
	  sztab-create
	  sztab-create-tab
	  sztab-add
	  sztab-add-item
	  sztab-add-tab
	  sztab-delete-tab
	  sztab-delete-item
	  sztab-item-to-tab
	  sztab-list-tabs
	  sztab-list-items
	  sztab-select-tab
	  sztab-current-tab
	  sztab-first-tab
	  sztab-last-tab
	  sztab-next-tab
	  sztab-previous-tab
	  sztab-select-next
	  sztab-select-previous
	  sztab-select-first
	  sztab-select-last
	  sztab-modify
	  sztab-modify-item
	  sztab-update
	  sztab-update-all
	  sztab-set-item
	  sztab-exchange
	  sztab-exchange-next-1
	  sztab-exchange-next
	  sztab-exchange-previous
	  sztab-default-item-property
	  sztab-item-property-table
	  sztab-add-item-property-table
	  sztab-item-property
	  sztab-set-item-property
	  sztab-minibuffer
	  sztab-reorder
	  sztab-sort))

(defmacro sztab-tab-item (tab)
  "sztab: tab に関連付けられたもの"
  `(get ,tab :item))
(defmacro sztab-tab-bar (tab)
  "sztab: tab が属している bar"
  `(get ,tab :bar))
(defmacro sztab-tab-caption (tab)
  "sztab: 直接 setf せずに sztab-modify でセットするか、sztab-update で"
  `(get ,tab :caption))
(defmacro sztab-tab-tooltip (tab)
  "sztab: 直接 setf せずに sztab-modify でセットするか、sztab-update で"
  `(get ,tab :tooltip))

(defmacro sztab-bar-select-hook (bar)
  "sztab: タブが選択されたときのフック。"
  `(get ,bar :sztab-select-hook))
(defmacro sztab-bar-dont-run-select-hook (bar)
  "sztab: non-nil なら select-hook をしない"
  `(get ,bar :sztab-dont-run-select-hook))
(defmacro sztab-bar-caption-hook (bar)
  "sztab: item と tab から caption を返す関数"
  `(get ,bar :sztab-caption-hook))
(defmacro sztab-bar-tooltip-hook (bar)
  "sztab: item と tab から tooltip を返す関数"
  `(get ,bar :sztab-tooltip-hook))
(defmacro sztab-bar-menu-hook (bar)
  "sztab: item と tab から menu を返す関数"
  `(get ,bar :sztab-menu-hook))
(defmacro sztab-bar-add-position-variable (bar)
  "sztab: タブの追加位置の変数"
  `(get ,bar :sztab-add-position-variable))
(defmacro sztab-bar-delete-position-variable (bar)
  "sztab: 削除したときアクティブにするタブの方向の変数"
  `(get ,bar :sztab-delete-position-variable))
(defmacro sztab-bar-test (bar)
  "sztab: sztab-item-to-tab で item を探すときに使う。無指定なら equal"
  `(get ,bar :sztab-test))

(defmacro sztab-bar-default-item-property-table (bar)
  "sztab: 無指定時のプロパティ"
  `(get ,bar :default-item-property-table))
(defmacro sztab-bar-item-property-tables (bar)
  "sztab: item のプロパティのリスト"
  `(get ,bar :item-property-tables))

(defmacro sztab-run-hook (tab type &optional item bar)
  (let ((g (gensym)))
    `(let ((,g (get (or ,bar
			(sztab-tab-bar ,tab))
		    ,type)))
       (if ,g (funcall ,g
		       (or item
			   (sztab-tab-item ,tab))
		       ,tab)))))

(defun sztab-run-caption-hook (tab &optional item bar)
  "sztab: tab から caption を返してもらう"
  (sztab-run-hook tab :sztab-caption-hook item bar))
(defun sztab-run-tooltip-hook (tab &optional item bar)
  "sztab: tab から tooltip を返してもらう"
  (sztab-run-hook tab :sztab-tooltip-hook item bar))
(defun sztab-run-menu-hook (tab &optional item bar)
  "sztab: tab から menu を返してもらう"
  (sztab-run-hook tab :sztab-menu-hook item bar))

(defun sztab-run-select-hook (tab)
  (let ((bar (sztab-tab-bar tab)))
    (unless (sztab-bar-dont-run-select-hook bar)
      (let ((hook (sztab-bar-select-hook bar)))
	(if hook
	    (funcall hook (sztab-tab-item tab) tab))))))

(defmacro sztab-drsh (bar &body body)
  "sztab: body の間 select-hook をしない"
  (let ((g (gensym)))
    `(let ((,g (sztab-bar-dont-run-select-hook ,bar)))
       (setf (sztab-bar-dont-run-select-hook ,bar) t)
       (unwind-protect
	   ,@body
	 (setf (sztab-bar-dont-run-select-hook ,bar) ,g)))))
(setf (get 'sztab-drsh 'lisp-indent-hook) 1)

(defun sztab-create (bar &key
			 select-hook
			 caption-hook
			 tooltip-hook
			 menu-hook
			 add-position-variable
			 delete-position-variable
			 test)
  (setf (sztab-bar-select-hook bar) select-hook)
  (setf (sztab-bar-dont-run-select-hook bar) nil)
  (setf (sztab-bar-caption-hook bar) caption-hook)
  (setf (sztab-bar-tooltip-hook bar) tooltip-hook)
  (setf (sztab-bar-menu-hook bar) menu-hook)
  (setf (sztab-bar-add-position-variable bar) add-position-variable)
  (setf (sztab-bar-delete-position-variable bar) delete-position-variable)
  (setf (sztab-bar-test bar) test)

  (setf (sztab-bar-default-item-property-table bar) (make-hash-table :test #'equalp))
  (setf (sztab-bar-item-property-tables bar) '())
  (create-tab-bar bar 'sztab-run-select-hook))

(defun sztab-create-tab (bar item)
  "sztab: tab を生成"
  (let ((tab (gensym "tab")))
    (setf (sztab-tab-bar tab) bar)
    (setf (sztab-tab-item tab) item)
    tab))

(defun sztab-add (bar item caption tooltip &optional position position-symbol)
  "sztab: caption と tooltip を指定してタブを追加。ただし sztab-update などと併用すると書き換えられる"
  (let ((tab (sztab-create-tab bar item)))
    (setf (sztab-tab-caption tab) caption)
    (setf (sztab-tab-tooltip tab) tooltip)
    (sztab-add-tab tab position position-symbol)))

(defun sztab-add-item (bar item &optional position position-symbol)
  "sztab: caption-hook と tooltip-hook とを使ってタブを追加"
  (let ((tab (sztab-create-tab bar item)))
    (setf (sztab-tab-caption tab) (sztab-run-caption-hook tab))
    (setf (sztab-tab-tooltip tab) (sztab-run-tooltip-hook tab))
    (sztab-add-tab tab position position-symbol)))

(defun sztab-add-tab (tab &optional position position-symbol)
  "sztab: caption と tooltip が既に指定されている tab を追加"
  (let* ((bar (sztab-tab-bar tab))
	 (pos (if (sztab-bar-add-position-variable bar)
		  (symbol-value (sztab-bar-add-position-variable bar)))))
    (tab-bar-add-item bar
		      tab
		      (sztab-tab-caption tab)
		      (sztab-tab-tooltip tab)
		      'sztab-run-menu-hook
		      (or position
			  (case pos
			    (:next :after)
			    (:previous :before)
			    (t pos)))
		      (or position-symbol
			  (sztab-current-tab bar)))
    tab))

(defun sztab-delete-tab (tab)
  "sztab: タブを削除"
  (let* ((bar (sztab-tab-bar tab))
	 (tab2 (if (eq (sztab-current-tab bar) tab)
		   (case (if (sztab-bar-delete-position-variable bar)
			     (symbol-value (sztab-bar-delete-position-variable bar)))
		     ((:after :next)
		      (or (sztab-next-tab tab t)
			  (sztab-previous-tab tab t)))
		     ((:before :previous)
		      (or (sztab-previous-tab tab t)
			  (sztab-next-tab tab t)))))))
    (if tab2 (sztab-select-tab tab2))
    (tab-bar-delete-item bar tab)))

(defun sztab-delete-item (bar item)
  "sztab: item のタブを削除"
  (let ((tab (sztab-item-to-tab bar item)))
    (if tab
	(sztab-delete-tab tab))))

(defun sztab-item-to-tab (bar item)
  "sztab: item の tab を探す"
  (let ((test (or (sztab-bar-test bar)
		  #'equal)))
    (find-if #'(lambda (tab) (funcall test item (sztab-tab-item tab)))
	     (sztab-list-tabs bar))))

(defun sztab-list-tabs (bar)
  "sztab: タブ順どおりの tab のリスト"
  (tab-bar-list-items bar))
(defun sztab-list-items (bar)
  "sztab: タブ順どおりの item のリスト"
  (let (result)
    (dolist (x (sztab-list-tabs bar))
      (push (sztab-tab-item x) result))
    (nreverse result)))

(defun sztab-select-tab (tab)
  "sztab: tab を選択状態に。たぶんフックもする。"
  (let ((bar (sztab-tab-bar tab)))
    (and (tool-bar-exist-p bar)
	 (not (eq tab (sztab-current-tab bar)))
	 (tab-bar-select-item bar tab)
	 (sztab-run-select-hook tab))))

(defun sztab-current-tab (bar)
  "sztab: 選択されているタブの tab"
  (car (tab-bar-current-item bar)))
(defun sztab-first-tab (bar)
  "sztab: 先頭の tab"
  (car (sztab-list-tabs bar)))
(defun sztab-last-tab (bar)
  "sztab: 最後の tab"
  (car (last (sztab-list-tabs bar))))
(defun sztab-next-tab (tab &optional not-rotate)
  "sztab: 後の tab"
  (let ((bar (sztab-tab-bar tab)))
    (or (safe-cadr (member (or tab
			       (sztab-current-tab bar))
			   (sztab-list-tabs bar)))
	(unless not-rotate
	  (sztab-first-tab bar)))))
(defun sztab-previous-tab (tab &optional not-rotate)
  "sztab: 前の tab"
  (let* ((bar (sztab-tab-bar tab))
	 (l (sztab-list-tabs bar))
	 (pos (1- (position (or tab (sztab-current-tab bar))
			    l))))
    (or (unless (= -1 pos)
	  (nth pos l))
	(unless not-rotate
	  (sztab-last-tab bar)))))

(defun sztab-select-next (bar &optional not-rotate)
  "sztab: 後のタブを選択"
  (sztab-select-tab (sztab-next-tab (sztab-current-tab bar)
				    not-rotate)))
(defun sztab-select-previous (bar &optional not-rotate)
  "sztab: 前のタブを選択"
  (sztab-select-tab (sztab-previous-tab (sztab-current-tab bar)
					not-rotate)))

(defun sztab-select-first (bar)
  "sztab: 最初のタブを選択"
  (sztab-select-tab (sztab-first-tab bar)))
(defun sztab-select-last (bar)
  "sztab: 最後のタブを選択"
  (sztab-select-tab (sztab-last-tab bar)))

(defun sztab-modify (tab &key caption (tooltip nil tt))
  "sztab: tab の caption や tooltip を変更。タブを再描画。ただし sztab-update などと併用すると書き換えられる"
  (if caption
      (setf (sztab-tab-caption tab) caption))
  (if tt
      (setf (sztab-tab-tooltip tab) tooltip))
  (tab-bar-modify-item (sztab-tab-bar tab)
		       tab
		       caption
		       tooltip
		       'sztab-run-menu-hook))

(defun sztab-modify-item (bar item &key caption (tooltip nil tt))
  "sztab: item の caption や tooltip を変更。タブを再描画。ただし sztab-update などと併用すると書き換えられる"
  (let ((tab (sztab-item-to-tab bar item)))
    (if tab
	(apply #'sztab-modify
	       (nconc (list tab)
		      (if caption
			  (list :caption caption))
		      (if tt
			  (list :tooltip tooltip)))))))

(defun sztab-update (tab)
  "sztab: tab を caption-hook と tooltip-hook を使って更新。タブを再描画。"
  (let ((caption (sztab-run-caption-hook tab))
	(tooltip (sztab-run-tooltip-hook tab)))
    (unless (equal (list (sztab-tab-caption tab)
			 (sztab-tab-tooltip tab))
		   (list caption tooltip))
      (sztab-modify tab :caption caption :tooltip tooltip))
    tab))

(defun sztab-update-all (bar)
  "sztab: bar を caption-hook と tooltip-hook を使って更新。タブを再描画。"
  (mapc #'sztab-update (sztab-list-tabs bar))
  t)

(defun sztab-set-item (tab item &key update caption (tooltip nil tt))
  "sztab: tab に関連付けられた item を変更。タブを再描画。"
  (setf (sztab-tab-item tab) item)
  (if update
      (sztab-update tab)
    (when (or caption tt)
      (apply #'sztab-modify
	     (nconc (list tab)
		    (if caption
			(list :caption caption))
		    (if tt
			(list :tooltip tooltip))))))
  item)


;違う bar 間で入れ替えることは考えていない
(defun sztab-exchange (a-tab b-tab)
  "sztab: tab の位置を入れ替え。sztab-caption-hook などはしない。"
  (if (and a-tab b-tab)
      (let* ((bar (sztab-tab-bar a-tab))
	     (a-item (sztab-tab-item a-tab))
	     (a-caption (sztab-tab-caption a-tab))
	     (a-tooltip (sztab-tab-tooltip a-tab))
	     (current (sztab-current-tab bar))
	     (c (if (eq current a-tab)
		    b-tab
		  (if (eq current b-tab)
		      a-tab))))
	(sztab-set-item a-tab
			(sztab-tab-item b-tab)
			:caption (sztab-tab-caption b-tab)
			:tooltip (sztab-tab-tooltip b-tab))
	(sztab-set-item b-tab
			a-item
			:caption a-caption
			:tooltip a-tooltip)
	(sztab-drsh bar
	  (if c (sztab-select-tab c)))
	t)))

(defun sztab-exchange-next-1 (tab &optional reverse not-rotate)
  (let ((bar (sztab-tab-bar tab))
	(tab2 (if reverse
		  (sztab-previous-tab tab t)
		(sztab-next-tab tab t))))
    (if tab2
	(sztab-exchange tab tab2)
      (unless not-rotate
	(sztab-drsh bar
	  (let ((selected (eq (sztab-current-tab bar) tab)))
	    (tab-bar-delete-item bar tab)
	    (sztab-add-tab tab
			   (if reverse
			       :last
			     :first))
	    (if selected
		(sztab-select-tab tab))
	    t))))))

(defun sztab-exchange-next (tab &optional not-rotate)
  "sztab: 指定した tab とその後の tab とを入れ替え"
  (sztab-exchange-next-1 tab nil not-rotate))
(defun sztab-exchange-previous (tab &optional not-rotate)
  "sztab: 指定した tab とその前の tab とを入れ替え"
  (sztab-exchange-next-1 tab t not-rotate))

;プロパティ関連。もっと楽な方法ないのか
(defmacro sztab-default-item-property (bar key)
  "無指定時のプロパティ"
  `(gethash ,key (sztab-bar-default-item-property-table ,bar)))

(defun sztab-item-property-table (bar item)
  (safe-cdr (assoc item
		   (sztab-bar-item-property-tables bar)
		   :test (sztab-bar-test bar))))
(defun sztab-make-item-property-table (bar item)
  (let ((table (make-hash-table :test #'equalp)))
    (push (cons item table)
	  (sztab-bar-item-property-tables bar))
    table))

(defun sztab-item-property (bar item key)
  "item のプロパティ"
  (let ((table (sztab-item-property-table bar item)))
    (multiple-value-bind (a b)
	(if table
	    (gethash key table (sztab-default-item-property bar key))
	  (sztab-default-item-property bar key))
      (values a b table))))
(defun sztab-set-item-property (bar item key value)
  (setf (gethash key
		 (or (sztab-item-property-table bar item)
		     (sztab-make-item-property-table bar item)))
	value))
(defsetf sztab-item-property sztab-set-item-property)

;

(defun sztab-minibuffer (bar prompt
			     &key
			     (key #'(lambda (tab) (sztab-tab-caption tab)))
			     case-fold
			     default
			     history
			     (must-match t))
  "sztab: ミニバッファで選んだ tab を返す。"
  (let* ((tabs (sztab-list-tabs bar))
	 (result (completing-read prompt (mapcar key tabs)
				  :case-fold case-fold :default default :history history :must-match must-match)))
    (values (find-if #'(lambda (x) (string-equal (funcall key x) result)) tabs)
	    result)))

;適当
(defun sztab-reorder (bar tab-list)
  "sztab: 指定した tab-list の順番に並び替え"
  (let ((old (sztab-list-tabs bar))
	(current (sztab-current-tab bar)))
    (unless (equal old tab-list)
      (sztab-drsh bar
	(dolist (x old)
	  (tab-bar-delete-item bar x))
	(dolist (x tab-list)
	  (sztab-add-tab x :last))
	(sztab-select-tab current)
	)))
  t)

(defun sztab-sort (bar predicate &optional tab)
  "sztab: ソート"
  (sztab-reorder bar
		 (stable-sort (sztab-list-tabs bar)
			      (if tab
				  predicate
				#'(lambda (a b)
				    (funcall predicate
					     (sztab-tab-item a)
					     (sztab-tab-item b)))))))

