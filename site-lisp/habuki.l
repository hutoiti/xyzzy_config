(provide "habuki")
(defun habuki-version nil
  (interactive)
  (and (interactive-p)
       (message "小ノ目 lapse ~A on 2009-01-03 21:56" (habuki-version)))
  "011")

#| habuki for xyzzy-0.2.2.235

Copyright (c) 2008-2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

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

漢直「小ノ目（はぶき）」のマイナーモードが実行できます。
練習用のモードも有ります。

■導入
habuki.lはsite-lisp下に、habuki.rl habuki-kanji.rlは~/に置きます。
(require "habuki")
を.xyzzyに書くなどして読み込みます。
netinstallerを用いてインストールした場合は不要です。

(global-set-key #\C-2 'habuki-mode)
(setq *habuki-normal-rule* '("~/habuki.rl" "~/habuki-kanji.rl")
      *habuki-abbrev-rule* "~/habuki-abbrev.rule")
などと.xyzzyに書きます。

■使用方法

使いたいバッファでhabuki-modeを実行します。
ホームポジションはqwerty配列に対して、左人差し指がG、右人差し指がKの位置です。
適当に押せば適当な字が出ます。
qwertyのQ →ヘルプが出ます。 ~ →機能一覧みたいが出ます。

配列の詳細は後日、別ファイルにて説明する……かも。

■履歴

lapse011 2009-01-03 21:56 netinstallerに対応してみた。
lapse010 2008-03-25 12:02 おまじないをしてみた。
lapse00f 2008-03-24 11:11 setqを減らしてみた。
lapse00e 2008-03-23 13:26 おかしなところを少し改良した。
lapse00d 2008-03-22 01:10 バッファ表示とabbrev表示の区別。
lapse00c 2008-03-17 22:58 ヘルプの表示を修正。
lapse00b 2008-03-14 17:19 なんでhabuki-outputを使わない。
lapse00a 2008-03-13 03:45 スタンバイしてすぐのhabuki-count-off。
lapse009 2008-03-11 19:32 habuki-count-toggleとかhabuki-test-regionとか。
lapse008 2008-03-10 00:27 ギリシャ字の大文字小文字変換。
lapse007 2008-03-08 20:35 登録語とメモの表示機能を付けた。
lapse006 2008-03-05 18:08 abbrev機能と盤面出力機能（別ファイル）を付けた。
lapse005 2008-03-03 23:00 overwrite-modeの使い道が分かった。
lapse004 2008-02-28 23:34 ハッシュを無駄に使うのを止めた。
lapse003 2008-02-26 22:05 小ノ目に名称変更。辞書と番号を分ける。
lapse002 2007-03-28 02:41 ひととおり調整。
lapse001 2007-02-26 10:25 とりあえず完成。

説明終わり|#

;●●ritual●●
(eval-when (:compile-toplevel :load-toplevel)
(defpackage "habuki" (:use "lisp" "editor"))
(use-package "habuki")
(in-package "habuki"))

;●●macros●●
;macro-function
(eval-when (:compile-toplevel :execute) ; コンパイルしたら呼び出さない。
(defun group (source n)
  (if (zerop n) (error "zero length"))
  (labels ((rec (source acc)
	     (let ((rest (nthcdr n source)))
	       (if (consp rest)
		   (rec rest (cons (subseq source 0 n) acc))
		 (nreverse (cons source acc))))))
    (if source (rec source nil) nil)))

;macro
(defmacro series (num func &rest args)
  (if (listp func)
      `(progn ,@(mapcar #'(lambda (x) `(,@func ,@x)) (group args num)))
    `(progn ,@(mapcar #'(lambda (x) `(,func ,@x)) (group args num)))))

(defmacro comp-in (func x y &rest args)
  `(setf (symbol-function ',func) (lambda ,args (,x (,y ,@args)))))

(defmacro strings (&rest args)
  (apply #'concat args))

(defmacro chars (str)
  `(quote ,(coerce str 'list)))

(defmacro ihabuki (act func &rest args)
  `(defun ,func ()
     ,(if act
	  `(interactive ,act)
	`(interactive))
     ,@args
     (setq *habuki-input* "")
     (habuki-help)))

(defmacro with-clear-help-buffer (&rest args)
  `(with-set-buffer
     (save-excursion
	 (erase-buffer (switch-to-buffer habuki-help-buff-name))
	 (insert "\n\n\n")
	 ,@args)))

(defmacro push-habuki-help-alt (stack pos dispc)
  `(push (habuki-help-alt ,pos ,dispc) ,stack))
)
(let nil ;*charm
;●●variables●●
(defvar-local *habuki-mode* nil)
(series
 2 defvar
 *habuki-mode-hook* nil
 *habuki-help-activate-hook* nil
 *habuki-memo*
 '("!ｘｍｈｂ（∥）ｆｃｌ；| |  1-7:省出力／表示 0:省表示のリセット 9:省表示一覧 ?:省表示 q:省出力"
   "ｙ５１２ｄ？－ｗ４７８△||  =:省登録 ,j:アンドゥリドゥ m:改行 -:カウント /:規則評価 w:草"
   "┃ｊ，．０６９３／＾＝┃?|  PNBF:上下左右 .:全角スペース d:削除 h:後退 ;:このメモを表示 "
   " ━━━ｚｋ￢ｐ□━━━　|  C-2:終了 x:盤面表示切り替え h:ヘルプ表示切り替え")

 *habuki-normal-rule* nil
 *habuki-abbrev-rule* nil

 *habuki-help-on* nil
 *habuki-help-after-num* 2
 *habuki-help-before-num* 1
 *habuki-help-keyboard-on* t
 *habuki-help-word* ""
 *habuki-abbrev-output-method* nil

 *habuki-cur-root-name* ""
 *habuki-num-convert* "GERKOWHP`J"
 *habuki-lone-char* (chars "17\\a]ncxz./")

 *habuki-test-left-char* "23456qwertysdfghvb"
 *habuki-test-home-char* "wergkop@"
 *habuki-mode-map* nil
 
 *habuki-rule-table* nil
 *habuki-anti-rule-table* nil
 *habuki-abbrev-rule-list* nil
 *habuki-convert-table* nil
 *habuki-help-table* nil
 *habuki-input* nil

 *habuki-count-on* nil
 *habuki-count-start* nil
 *habuki-count* 0)

(export
 '(habuki-mode
   *habuki-mode-hook* *habuki-help-activate-hook* *habuki-memo*
   *habuki-normal-rule* *habuki-abbrev-rule*
   *habuki-help-on* *habuki-help-after-num* *habuki-help-before-num*
   *habuki-help-keyboard-on* *habuki-help-word* *habuki-abbrev-output-method*
   *habuki-cur-root-name* *habuki-num-convert* *habuki-lone-char* 
   *habuki-test-left-char* *habuki-test-home-char* *habuki-mode-map*))

(setq habuki-num (map 'list 'cons *habuki-num-convert* '(0 1 2 3 4 5 6 7 8 9))
      habuki-all-char (chars "1234567890-^\\qwertyuiop@[asdfghjkl;:]zxcvbnm,./"))
(setq habuki-char (set-difference habuki-all-char *habuki-lone-char*)
      habuki-help-buff-name " *小ノ目ヘルプ*")

(unless *habuki-mode-map*
  (setq *habuki-mode-map* (make-keymap))
  (dolist (c habuki-all-char)
    (define-key *habuki-mode-map* c 'habuki-input))
  (dolist (c (coerce (substring *habuki-num-convert* 1 8) 'list))
    (define-key *habuki-mode-map* c 'habuki-input-abbrev))
  (series
   2 (define-key *habuki-mode-map*)
   #\Q 'habuki-help-toggle
   #\" 'habuki-help-keyboard-toggle
   #\V 'habuki-set-help-before-num
   #\< 'habuki-set-help-after-num
   #\) 'habuki-forward-char
   #\% 'habuki-backward-char
   #\` 'habuki-next-virtual-line
   #\M 'habuki-previous-virtual-line
   #\# 'habuki-newline
   #\$ 'habuki-delete-backward-char-or-selection
   #\T 'habuki-delete-char
   #\D 'habuki-undo
   #\S 'habuki-redo
   #\F 'habuki-write-fullsize-space
   #\I 'habuki-write-glass
   #\G 'habuki-help-set-default
   #\+ 'habuki-coerce-output
   #\Y 'habuki-coerce-show
   #\* 'habuki-set-abbrev-rule
   #\~ 'habuki-show-memo
   #\J 'habuki-show-abbrev
   #\U 'habuki-count-toggle
   #\L 'habuki-test-region
   #\C-2 'habuki-mode))
(pushnew '(*habuki-mode* . "省") *minor-mode-alist* :key #'car)

;●●mode functions●●

(defun habuki-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*habuki-mode* arg sv)
  (update-mode-line t)
  (if *habuki-mode*
      (progn
	(or *habuki-rule-table*
	    (habuki-set-rule))
	(or *habuki-abbrev-rule-list*
	    (habuki-read-abbrev-rule-file *habuki-abbrev-rule*))
	(setq *habuki-cur-root-name* "" *habuki-input* "")
	(set-minor-mode-map *habuki-mode-map*)
	(when *habuki-help-on*
	  (habuki-help-activate)
	  (habuki-help))
	(run-hooks '*habuki-mode-hook*))
    (progn
      (unset-minor-mode-map *habuki-mode-map*)
      (habuki-help-kill)
      (when *habuki-count-on* (habuki-count-off))))
  t)
(unless *habuki-convert-table*
  (setq *habuki-convert-table* (make-hash-table :size 41 :test 'equal))
  (map nil #'(lambda (x y)
	       (setf (gethash x *habuki-convert-table*) y)
	       (setf (gethash y *habuki-convert-table*) x))
       (strings "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,-!':"
		"ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ．，－！’："
	       "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΠΡΣΥΦΧΨΩ")
       (strings "abcdefghijklmnopqrstuvwxyz*=+?`;"
		"ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ＊＝＋？‘；"
	       "αβγδεζηθικλμνξοπρστυφχψω")))

(defun habuki-set-rule ()
  (long-operation
    (setq *habuki-rule-table* (make-hash-table :size 1999 :test 'equal)
	  *habuki-anti-rule-table* (make-hash-table :size 1999 :test 'equal))
    (map nil #'habuki-read-rule-file *habuki-normal-rule*)
    (message "規則を読み込んだ。")))

(defun habuki-read-rule-file (file)
  (when (and file
	     (file-exist-p file))
    (with-open-file (in file :direction :input)
      (message "~A を読み込んでるところ。" file)
      (let (buff from to)
	(while (setq buff (read-line in nil))
	  (setq buff (string-trim " \t" buff))
	  (or (string-match "^%" buff)
	      (and (string-match "^#s" buff)
		   (setq from (1+ (string-match "\"" buff)))
		   (setq to (string-match "\"" buff from))
		   (setq *habuki-cur-root-name* (substring buff from to)))
	      (and (setq to (string-match ">" buff))
		   (habuki-push-word (substring buff 0 to) (substring buff (1+ to)) *habuki-cur-root-name*))
	      ))))))

(defun habuki-read-abbrev-rule-file (file)
  (when (and file
	     (file-exist-p file))
    (with-open-file (in file :direction :input)
      (message "~A を読み込んでるところ。" file)
      (let (buff (deal (map 'list 'cons "0123456789" '(0 1 2 3 4 5 6 7 8 9))))
	(while (setq buff (read-line in nil))
	  (push (cons (dassoc (char buff 0) deal) (substring buff 1)) *habuki-abbrev-rule-list*))))
    (message "規則を読み込んだ。")))

(defun habuki-push-word (key word root-name)
  (and (> (length key) 0)
       (> (length word) 0)
       (setf (gethash (list root-name key) *habuki-rule-table*) word)
       (setf (gethash (char word 0) *habuki-anti-rule-table*) (list root-name key))))

(defun habuki-input ()
  (interactive "*")
  (and *habuki-count-on* *habuki-count-start* (habuki-count-appeal))
  (let ((s (habuki-input-sub *last-command-char*)))
    (if (stringp s)
	(habuki-output s)))
    (habuki-help))

(defun habuki-output (s)
  (when *habuki-count-on*
    (setq *habuki-count* (+ *habuki-count* (length s)))
    (unless *habuki-count-start*
      (setq *habuki-count-start* (get-internal-real-time))))
  (if overwrite-mode
      (mapcar #'overwrite-char (coerce s 'list))
    (insert s))
  (if (not (equal *habuki-help-word* ""))
      (setq *habuki-help-word*
	    (if (< (length s) (length *habuki-help-word*))
		(substring *habuki-help-word* (length s))
	      ""))))

;#p:prefix #s "":switch to "" ##:insert # #c convert
(defun habuki-input-sub (c)
  (or (and (find c *habuki-lone-char*)
	   (setq c (string c)))
      (setq c (concat *habuki-input* (string c))))
  (setq *habuki-input* "")
  (let ((word (gethash (list *habuki-cur-root-name* c) *habuki-rule-table*)))
    (cond ((null word) nil)
	  ((string-match "^#p" word) (setq *habuki-input* c) t)
	  ((string-match "^#c" word) (habuki-convert) t)
	  ((string-match "^##" word) "#")
	  ((string-match "^#s" word)
	   (let* ((from (1+ (string-match "\"" word)))
		  (to (string-match "\"" word from)))
	     (setq *habuki-cur-root-name* (substring word from to))
	     t))
	  (t word))))

(comp-in dassoc cdr assoc item lst)

;●help function●

(defun habuki-help ()
  (if (not (equal *habuki-help-word* ""))
      (with-clear-help-buffer
       (if *habuki-help-keyboard-on*
	   (habuki-help-push (habuki-help-keyboard *habuki-input*)))
       (dolist (c (coerce *habuki-help-word* 'list))
	 (habuki-help-push (habuki-help-char c))))
    (if *habuki-help-on*
	(let ((s (buffer-substring (- (point) *habuki-help-before-num*)
				   (+ (point) *habuki-help-after-num*))))
	  (with-clear-help-buffer
	   (when *habuki-help-keyboard-on*
	     (habuki-help-push (habuki-help-keyboard *habuki-input*)))
	   (dolist (c (coerce s 'list))
	     (habuki-help-push (habuki-help-char c)))))))
  (and (not *habuki-help-on*)
       (equal *habuki-help-word* "")
       (habuki-help-kill))
  (if (not *habuki-count-on*) (message *habuki-input*)))

(defun habuki-help-on ()
  (setq *habuki-help-on* t)
  (habuki-help-activate)
  (habuki-help))

(defun habuki-help-off ()
  (setq *habuki-help-on* nil)
  (habuki-help-kill))

(defun habuki-help-kill (&aux buff)
  (when (setq buff (find-buffer habuki-help-buff-name))
    (save-excursion
      (and (> (count-windows) 1)
	   (if (get-buffer-window buff)
	       (set-window (get-buffer-window buff)))
	   (delete-window))
      (delete-buffer buff))))

(defun habuki-help-activate ()
  (with-selected-window
    (pop-to-buffer (get-buffer-create habuki-help-buff-name) -3)
    (kill-all-local-variables)
    (set-buffer-fold-width nil)
    (setup-temp-buffer (selected-buffer))
    (set-local-window-flags (selected-buffer)
     (+
      *window-flag-line-number*
      *window-flag-ruler*
      *window-flag-newline*
      *window-flag-full-width-space*
      *window-flag-vscroll-bar*
      *window-flag-eof*
      *window-flag-hscroll-bar*
      *window-flag-mode-line*
      *window-flag-fold-mark*
      *window-flag-cursor-line*
      *window-flag-half-width-space*) nil)
    (run-hooks '*habuki-help-activate-hook*)))

(defun habuki-help-toggle ()
  (interactive)
  (if *habuki-help-on*
      (habuki-help-off)
    (habuki-help-on)))

(defun habuki-help-keyboard-toggle ()
  (interactive)
  (setq *habuki-help-keyboard-on* (not *habuki-help-keyboard-on*))
  (habuki-help))

(let ((help-convert-map
       (map 'list
	    #'cons
	    (strings "abcdefghijklmnopqrstuvwxyz"
		     "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		     "1234567890 !\"#$%&'()=~|`{+"
		     "\n*}<>?_-^\\@[;:],./")
	    (strings "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ"
		     "ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ"
		     "１２３４５６７８９０□！”★＄％＆’（）＝～｜‘｛＋"
		     "　＊｝＜＞？＿－＾＼＠［；：］，．／"))))
  (defun help-appearance (c)
    (or (dassoc c help-convert-map)
	c)))

(defun habuki-help-push (str)
  (goto-char 0)
  (end-of-line)
  (dolist (s str)
    (insert s)
    (next-line)))

(defun habuki-help-once (alts)
  (let ((l (list (copy-string "|　　　‐　♯　‐　　　| |")
		 (copy-string "　‐‐‐　　　　‐‐‐　||")
		 (copy-string "┃　　　＞　　＜．　　┃ |")
		 (copy-string " ━━━　　Δ　　━━━　|"))))
    (dolist (x alts)
      (setf (elt (elt l (car x)) (cadr x)) (caddr x)))
    l))

(let ((help-position-map
       (map 'list
	    #'cons
	    "23456890-^qwertyuiop@[sdfghjkl;:vbm,"
	    '((1 0) (2 0) (3 0) (4 0) (5 0)        (7 0) (8 0) (9 0) (10 0) (11 0)
	      (0 1) (1 1) (2 1) (3 1) (4 1) (5 1)  (6 1) (7 1) (8 1) (9 1) (10 1) (11 1)
	      (1 2) (2 2) (3 2) (4 2) (5 2)        (6 2) (7 2) (8 2) (9 2) (10 2)
	      (4 3) (5 3)  (7 3) (8 3)))))
  (defun habuki-help-alt (pos dispc &aux p)
    (setq p (if (listp pos) pos (dassoc pos help-position-map)))
    (list (cadr p) (car p) dispc)))

(defun habuki-help-char (c)
  (let* ((arg (gethash c *habuki-anti-rule-table*))
	 (root-name (car arg))
	 (key (coerce (cadr arg) 'list))
	 stack)
    (push-habuki-help-alt stack '(6 0) (help-appearance c))
    (if (equal *habuki-help-word* "") nil (push-habuki-help-alt stack '(6 3) #\∇))
    (if (> (length root-name) 0)
	(push-habuki-help-alt stack '(12 2) (char root-name 0)))
    (case (length key)
      (1 (push-habuki-help-alt stack (car key) #\●))
      (2 (if (eq (car key) (cadr key))
	     (push-habuki-help-alt stack (car key) #\◆)
	   (series 2 (push-habuki-help-alt stack)
		   (car key) #\●
		   (cadr key) #\○)))
      (3 (if (eq (car key) (cadr key))
	     (if (eq (car key) (caddr key))
		 (push-habuki-help-alt stack (car key) #\★)
	       (series 2 (push-habuki-help-alt stack)
		       (car key) #\◆
		       (caddr key) #\△))
	   (if (eq (car key) (caddr key))
	       (series 2 (push-habuki-help-alt stack)
		       (car key) #\▼
		       (cadr key) #\○)
	     (if (eq (cadr key 1) (caddr key 2))
		 (series 2 (push-habuki-help-alt stack)
			 (car key) #\●
			 (cadr key) #\◇)
	       (series 2 (push-habuki-help-alt stack)
		       (car key) #\●
		       (cadr key) #\○
		       (caddr key) #\△))))))
    (habuki-help-once stack)))

(defun habuki-help-keyboard (input &aux stack)
  (and (> (length *habuki-cur-root-name*) 0)
       (push-habuki-help-alt stack '(12 2) (char *habuki-cur-root-name* 0)))
  (dolist (posc habuki-char)
    (let ((word (gethash (list *habuki-cur-root-name* (concat input (string posc))) *habuki-rule-table*)))
      (push-habuki-help-alt
       stack  posc
       (cond ((null word) #\　)
	     ((string-match "^#p" word) #\□)
	     ((string-match "^#c" word) #\△)
	     ((string-match "^##" word) #\＃)
	     ((string-match "^#s" word) #\☆)
	     (t (help-appearance (char word 0)))))))
  (habuki-help-once stack))

;●intaractive functions●

(defun habuki-convert (&aux s)
  (and (setq s (gethash (char (buffer-substring (1- (point)) (point)) 0) *habuki-convert-table*))
       (backward-char)
       (overwrite-char s)))

(defun habuki-coerce-show ()
  (interactive)
  (setq *habuki-abbrev-output-method* #\?)
  (message "表示する"))

(defun habuki-coerce-output ()
  (interactive)
  (setq *habuki-abbrev-output-method* #\^)
  (message "出力する"))

(defun habuki-safe-input-num (&optional (start 0) (end 10) &aux x)
  (while (and (not (eq (peek-char *standard-input* ed:*keyboard*) #\C-g))
	      (not (and (setq x (dassoc (read-char ed:*keyboard*) habuki-num))
			(>= x start)
			(< x end)))))
  x)

(defun habuki-set-help-after-num ()
  (interactive)
  (when *habuki-help-on* (message "後の文字数？"))
  (let ((n (habuki-safe-input-num)))
    (and n
	 (setq *habuki-help-after-num* n)))
  (habuki-help))

(defun habuki-set-help-before-num ()
  (interactive)
  (when *habuki-help-on* (message "前の文字数？"))
  (let ((n (habuki-safe-input-num)))
    (and n
	 (setq *habuki-help-before-num* n)))
  (habuki-help))

(defun habuki-input-abbrev ()
  (interactive "*")
  (let ((s (dassoc (dassoc *last-command-char* habuki-num) *habuki-abbrev-rule-list*)))
    (if (stringp s)
	(if (or (eq *habuki-abbrev-output-method* #\?)
		(and (eq *habuki-abbrev-output-method* nil)
		     (eq (char s 0) #\?)))
	    (habuki-show-help-word (substring s 1))
	  (habuki-output (substring s 1)))
      (message "ないよ"))
  (setq *habuki-input* "")
    (habuki-help)))

(defun habuki-show-help-word (s)
  (setq *habuki-help-word* s)
  (unless *habuki-help-on*
    (habuki-help-activate)))

(defun habuki-set-abbrev-rule ()
  (let* ((n (progn (message "何文字？") (habuki-safe-input-num)))
	 (sw (let ()
	       (message "~A -> S-^:出力する S-?:表示する" n)
	       (while (and (not (eq (peek-char *standard-input* ed:*keyboard*) #\C-g))
			   (not (or (eq (peek-char *standard-input* ed:*keyboard*) #\+)
				    (eq (peek-char *standard-input* ed:*keyboard*) #\Y))))
		 (read-char ed:*keyboard*))
	       (or (and (eq (peek-char *standard-input* ed:*keyboard*) #\+) #\^)
		   (and (eq (peek-char *standard-input* ed:*keyboard*) #\Y) #\?)
		   " ")))
	 (num (progn (message "~A -> どのキー？" sw) (habuki-safe-input-num 1 8)))
	 (s (when n (concat (string sw) (buffer-substring (- (point) n) (point))))))
    (interactive)
    (when (and n sw num)
      (push (cons num s) *habuki-abbrev-rule-list*)
      (when *habuki-abbrev-rule*
	(with-open-file (to *habuki-abbrev-rule* :direction :output
			    :if-exists :append :if-does-not-exist :create)
	  (format to "~D~A~%" num s)))
      (message "\"~A\"を~A番に登録した。" s num))))

(defun habuki-help-set-default ()
  (interactive)
  (setq *habuki-abbrev-output-method* nil
	*habuki-help-word* ""
	*habuki-input* "")
  (habuki-help)
  (message "デフォルト"))

(ihabuki nil habuki-forward-char (forward-char))
(ihabuki nil habuki-next-virtual-line (next-virtual-line))
(ihabuki nil habuki-previous-virtual-line (previous-virtual-line))
(ihabuki nil habuki-backward-char (backward-char))
(ihabuki nil habuki-newline
	 (and *habuki-count-on* (setq *habuki-count* (1+ *habuki-count*))
	      *habuki-count-start* (habuki-count-appeal))
	 (newline))
(ihabuki "*" habuki-delete-backward-char-or-selection (delete-backward-char-or-selection))
(ihabuki "*" habuki-delete-char (delete-char)) 
(ihabuki "*" habuki-undo (undo))
(ihabuki "*" habuki-redo
	 (and *habuki-count-on* *habuki-count-start* (habuki-count-appeal))
	 (redo))
(ihabuki "*" habuki-write-fullsize-space
	 (and *habuki-count-on* *habuki-count-start* (habuki-count-appeal))
	 (habuki-output "　"))
(ihabuki "*" habuki-write-glass
	 (and *habuki-count-on* *habuki-count-start* (habuki-count-appeal))
	 (habuki-output "ｗ"))
(defun habuki-show-memo ()
  (interactive)
  (unless *habuki-help-on*
    (habuki-help-on))
  (with-clear-help-buffer
   (habuki-help-push *habuki-memo*)))

(defun habuki-show-abbrev ()
  (interactive)
  (unless *habuki-help-on*
    (habuki-help-activate))
  (with-clear-help-buffer
    (habuki-help-push
     (list (concat "1 " (dassoc 1 *habuki-abbrev-rule-list*)
		   "  2 " (dassoc 2 *habuki-abbrev-rule-list*))
	   (concat "3 " (dassoc 3 *habuki-abbrev-rule-list*)
		   "  4 " (dassoc 4 *habuki-abbrev-rule-list*))
	   (concat "5 " (dassoc 5 *habuki-abbrev-rule-list*)
		   "  6 " (dassoc 6 *habuki-abbrev-rule-list*))
	   (concat "7 " (dassoc 7 *habuki-abbrev-rule-list*)
		   "  ^:出力  ?:表示")))))

(defun habuki-count-toggle ()
  (interactive)
  (defun on ()
    (setq *habuki-count-on* (message "カウント、入力待ち..")
	  *habuki-count-start* nil
	  *habuki-count* 0)
    (set-mark (point))
    (start-timer 1.0 'habuki-count-appeal))
  (if *habuki-count-on*
      (habuki-count-off)
    (on)))

(defun habuki-count-off ()
  (stop-timer 'habuki-count-appeal)
  (when *habuki-count-start*(habuki-count-appeal))
  (setq *habuki-count-on* nil))

(defun habuki-count-appeal (&aux sec)
  (message "~D 字 / ~D 秒 (~4F)"
	   *habuki-count*
	   (round (setq sec (/ (- (get-internal-real-time) *habuki-count-start*) internal-time-units-per-second)))
	   (/ *habuki-count* sec)))

(defun habuki-test-region (from to)
  (interactive "r")
  (if (> from to) (rotatef from to))
  (let ((str (buffer-substring from to))
	(valid-strlen 0) (stroke 0) (left 0) (right 0) (alternate 0) (home 0) (root-change -1) l r)
    (when (< 0 (length str))
      (long-operation
	(dolist (x (coerce str 'list))
	  (let* ((arg (gethash x *habuki-anti-rule-table*))
		 (root-name (first arg))
		 (key (second arg)))
	    (when arg
	      (setq valid-strlen (1+ valid-strlen))
	      (unless (eq r root-name)
		(setq r root-name
		      root-change (1+ root-change)))
	      (map nil #'(lambda (c) (push c l)) key))))
	(when (< 0 (setq stroke (length (setq l (reverse l)))))
	  (map nil #'(lambda (x y)
		       (if (find x *habuki-test-home-char*)
			 (setq home (1+ home)))
		       (or (and (find x *habuki-test-left-char*) (setq left (1+ left))
				(find y *habuki-test-left-char*))
			   (and (not (find x *habuki-test-left-char*)) (setq right (1+ right))
				(not (find y *habuki-test-left-char*)))
			   (setq alternate (1+ alternate))))
	       l (cdr l))
	  (let ((x (car (reverse l))))
	    (message "~A" x)
	    (if (find x *habuki-test-left-char*)
		(incf left)
	      (incf right))
	    (if (find x *habuki-test-home-char*)
		(incf home)))
	  (unless *habuki-help-on*
	    (habuki-help-activate))
	  (with-clear-help-buffer
	      (habuki-help-push
	       (list
		(format nil "有効文字数: ~5D 字 ／ 総合打鍵数: ~5D (~5D) 打"
			valid-strlen stroke (+ stroke root-change))
		(format nil "左打鍵数: ~7D 打  ルート変更: ~5D 回  交互打鍵比率: ~6,1,2F%"
			left root-change (/ alternate (1- stroke)))
		(format nil "右打鍵数: ~7D 打  リージョン: ~5D 字  ホーム使用比率: ~4,1,2F%"
			right (length str) (/ home stroke))
		(format nil "左右比率 ~4,1,2F% / ~4,1,2F% 1字当たり平均打鍵数 ~4,2F(~4,2F) 打"
			(/ left stroke) (/ right stroke)
			(/ stroke valid-strlen 1.0) (/ (+ stroke root-change)
						       valid-strlen 1.0))))))))))

);\e