#|
 ibuki for xyzzy-0.2.2.235 or over version
 lapse 004 of 2009-11-08

漢字直接入力「息吹」

マイナーモードで漢字直接入力を行えるようにします。

■導入
・netinstallerでインストールした場合
(ni-autoload)で有効にし、(global-set-key #\C-\] 'ibuki-mode)など
お好みのキーに呼び出し関数を関連付けます。

■使い方
(ibuki-mode)でON/OFFします。
ONするとヘルプ盤面が表示されます。これはキーボードに対応しています。
通常色の文字は、打つとそのまま入力できます。
青や緑になっている文字は、打つと対応する盤面に飛びます。
盤面を飛んだ場合、文字を入力した段階で元の盤面(ホーム)に戻ります。
黄になっている文字は、打つと文字の種類や幅が変更されます。もう一度押すと戻ります。
文字の種類の変更は、打ちたい文字のある盤面で行って下さい。

また、最初の盤面で@キーを打つと、「副」の盤面に移ります。
この状態で文字を入力すると、「副」の盤面に戻ってきます。
「副」の盤面で@キーを打つと、最初の盤面に戻ります。
それ以外の盤面で@キーを打つと、その盤面がホームの盤面になります。
帰ってくる盤面が変更された状態で@キーを打つと、ホームの盤面を元に戻します。

\[キーを押すと変換モードに切り替わります。
変換モードでは、漢字を読みで絞り込んで入力が行えます。
読みは前方部分一致の頭出し方式で反映されます。
読みを「、」で区切ると複数指定できます。
読みに「。」を加えると完全一致で検索できます。
あるいは、画数でも調べることができます。
一部の文字はホームに表示されますが、そこで見つからない場合は、スペースを
押すことで続きの候補を表示させることができます。
変換を中止するには\[キーか改行キーを使います。

SHIFTキーを押しながら文字を入力することでも変換モードに入れます。
この場合は、漢字を入力すると即座に元の状態に戻ります。

■ヒント
%XYZZYHOME%/dict/ibuki-jis-x-208.txtは漢字の配置に対応しています。
検索をかけると、入力したい漢字がどの漢字の近くにあるか把握できるでしょう。

「多」の面の下部にある a 9 で半角英数に切り替えられます。

今のところ、フックや設定ファイルに対応していません。
配列の変更がしたい方は、作者に連絡するか、自力で解読して書き換えてください。

■ライセンス
ibuki.lの内容について、MITライセンスに準拠します。

 Copyright (C) 2009 knenet All rights reserved.
 <kneneglect_std|^o^|yahoo.co.jp>

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

ibuki-jis-x-208.txtの内容はほぼJIS X 208ですので、自由に利用できると思います。
何か問題があれば連絡を下さい。
ibuki-yomi.txtの内容は、主に百相鍵盤『き』のkiMapを基に作成しています。
漢字の読みと角数のみのファイルなので、特に私が権利を主張できる箇所はないと思います。

■履歴
001 2009-11-05 15:16 できた。
002 2009-11-08 10:18 変換機能をつけた。その他色々調整。
003 2009-11-08 19:25 半角英数への切替機能を追加した。
004 2009-11-08 20:47 挙動調整。

■TODO
・記号配置の検討。
・設定ファイルへの対応。
|#

(provide "ibuki")

(eval-when (:compile-toplevel :load-toplevel)
(defpackage "ibuki" (:use "lisp" "editor"))
(use-package "ibuki")
(in-package "ibuki")
(export '(ibuki-mode)))

(defvar-local ibuki-mode nil)
(defvar show-buffer " *ibuki*")
(defvar yomi-buffer " *ibuki-yomi*")
(defvar jisho-file (merge-pathnames "dict/ibuki-jis-x-208.txt" (si:system-root)))
(defvar yomi-file (merge-pathnames "dict/ibuki-yomi.txt" (si:system-root)))

;キーの内部コード
(setq input/inner
	  (let ((table (make-hash-table :size 17)) (c 0))
		(mapcar
		 (lambda (x) (setf (gethash x table) (incf c)))
		 (coerce "qwertyuiopasdfghjkl;:]zxcvbnm,./" 'list))
		(setq c 0)
		(mapcar
		 (lambda (x) (setf (gethash x table) (incf c)))
		 (coerce "QWERTYUIOPASDFGHJKL+*}ZXCVBNM<>?" 'list))
		table))

;変換確定に使うキー
(setq convert-keys
	  '(((16 0) (17 1) (18 2) (19 3) (20 4))
		((16 0) (17 1) (18 2) (19 3) (20 4)))
	  convert-key-num 5
	  convert-show-column 5)

(pushnew '(ibuki-mode . "息吹") *minor-mode-alist* :key #'car)

;関連の表示色。
(setq attribute (make-hash-table :size 7))

(setq recent-output nil recent-count 0)
(defvar recent-output-max 5)

(defun define-attribute (name attr)
  (setf (gethash name attribute) attr))

(defun init-attribute ()
  (define-attribute 'convert '(:foreground 7 :background 12))
  (define-attribute 'link '(:foreground 4))
  (define-attribute 'link2 '(:foreground 2))
  (define-attribute 'toggle '(:foreground 3 :background 12))
  (define-attribute 'home '(:background 6))
  (define-attribute 'candidate '(:background 1)))

(defmacro set-txt-attr (from to &optional attr)
  `(apply 'set-text-attribute ,from ,to ,attr (gethash ,attr attribute)))

(defun version nil
  (interactive)
  (and (interactive-p)
       (message "息吹 lapse ~A of 2009-11-08" (version)))
  "003")

(defun make-board (&optional entries)
  (let ((board (make-hash-table :size 17)))
	(mapcar (lambda (x) (setf (gethash (car x) board) (cadr x))) entries)
	board))

(defun define-board (name board)
  (setf (gethash name boardmap) board))

;tool
(defun homologize (str &optional (start 1) (skip '((21 23))))
  (decf start)
  (mapcar (lambda (x) (list (if (eq (incf start) (caar skip))
								  (setq start (cadr (pop skip)))
								start) x))
		  (coerce str 'list)))

(defun board-append-go (table lst)
  (mapcar (lambda (x) (setf (gethash (car x) table) (list 'go (cadr x))))
		  lst) table)

(defun board-append-toggle (table lst)
  (mapcar (lambda (x) (setf (gethash (car x) table) (list 'toggle (cadr x))))
		  lst) table)

(defun board-append-temp (table lst)
  (mapcar (lambda (x) (setf (gethash (car x) table) (list 'temp-state (cadr x))))
		  lst) table)

(defun board-home-position (board)
  (let ((a (gethash 'text-attribute board)))
	(setf (gethash 'text-attribute board)
		  (append a '((14 14 home) (17 17 home)))))
  board)

(defun attribute (brd lst)
  (let ((a (gethash 'text-attribute brd)))
	(setf (gethash 'text-attribute brd) (append a lst)))
  brd)

(defun name (brd name)
  (setf (gethash 'name brd) name)
  brd)

(defun set-filter (table flag keys data)
  (mapcar (lambda (x y) (setf (gethash x table) (list y flag)))
		  keys data))

(defun init-filter ()
  (setq char-width-filter (make-hash-table :size 31)
		char-alt-filter (make-hash-table :size 31)
		flag-policies (make-hash-table :size 7)
		flags (make-hash-table :size 7))
  (set-filter char-width-filter 'kana/w
	(coerce
	 (concat
	  "。「」、・をぁぃぅぇぉゃゅょっーあいうえおかきくけこ"
	  "さしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわん゛゜"
	  "がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ") 'list)
	(append
	 (coerce "｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ" 'list)
	 (mapcar (lambda (x) (coerce (list x #\ﾞ) 'string))
			 (coerce "ｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾊﾋﾌﾍﾎ" 'list))
	 '("ﾊﾟ" "ﾋﾟ" "ﾌﾟ" "ﾍﾟ" "ﾎﾟ")))

  (set-filter char-width-filter 'alphabet/w
	(coerce "ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ" 'list)
	(coerce "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 'list))

  (set-filter char-width-filter 'digit/w
	(coerce "０１２３４５６７８９" 'list)
	(coerce "0123456789" 'list))

  (set-filter char-width-filter 'symbol/w
	(coerce "‐＾＄：；＿，．＋－×÷＝＜＞＠％＆＃！？＊｜￥～［］（）｛｝‘’＼／｀≠≦≧“”→←" 'list)
	(append (coerce "-^$:;_,.+-*/=<>@%&#!?*|\\~[](){}`'\\/`" 'list)
			'("!=" "<=" ">=" #\" #\" "->" "<-")))

  (set-filter char-alt-filter 'kana/a
	(coerce
	 (concat "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとど"
			 "なにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん") 'list)
	(coerce
	 (concat "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトド"
			 "ナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲン") 'list))

  (set-filter char-alt-filter 'greek/a
	(coerce "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ" 'list)
	(coerce "αβγδεζηθικλμνξοπρστυφχψω" 'list))

  (set-filter char-alt-filter 'alphabet/a
	(coerce "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 'list)
	(coerce "abcdefghijklmnopqrstuvwxyz" 'list))

  (set-filter char-alt-filter 'alphabet/a
	(coerce "ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ" 'list)
	(coerce "ａｂｃｄｅｆｇｈｊｉｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ" 'list))

  (set-filter char-alt-filter 'cyril/a
	(coerce "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" 'list)
	(coerce "абвгдеёжзийклмнопрстуфхцчшщъыьэюя" 'list))

  (setf (gethash 'alt flag-policies) t)
  (setf (gethash 'width flag-policies) t)
  (setf (gethash 'cyril/a flag-policies) 'priority)
  (setf (gethash 'greek/a flag-policies) 'priority)
  (setf (gethash 'alphabet/a flag-policies) 'priority)

  (setq flag-names (make-hash-table :size 7))
  (mapcar (lambda (x) (setf (gethash (car x) flag-names) (cadr x)))
		  '((width "幅") (kana/w "幅") (digit/w "幅") (alphabet/w "幅") (symbol/w "幅")
			(alt "種") (kana/a "種") (alphabet/a "種") (cyril/a "種") (greek/a "種")))


  (setq flag-depends (make-hash-table :size 7))
  (mapcar (lambda (x) (setf (gethash x flag-depends) 'width))
		  '(kana/w digit/w alphabet/w symbol/w))
  (mapcar (lambda (x) (setf (gethash x flag-depends) 'alt))
		  '(kana/a alphabet/a cyril/a greek/a))
  (setq comma #\､ period #\｡))

(defun order-list (start length)
  (let (l)
	(dotimes (a length (reverse l))
	  (push (+ start a) l))))

(defun init-styles (start num)
  (dotimes (a num)
	(let ((b (gethash (+ start a) boardmap)))
	  (when b
		(board-home-position b)
		(set-style b)))))

(defun set-style (board)
  (setf (gethash 'show board)
		(let (ll)
		  (dolist (code '((1 10) (11 12) (23 10)) (reverse ll))
			(push (let (l)
					(dotimes (c (cadr code) (reverse l))
					  (let ((p (key-name (gethash (+ c (car code)) board))))
						(push (if p p "") l))))
				  ll)))))

(defun init-board ()
  (setq boardmap (make-hash-table :size 149))
  (with-open-file (fp jisho-file :direction :input
					  :if-does-not-exist :error)
	(let (l (n 100))
	  (while (setq l (read-line fp nil))
		(define-board (incf n)
		  (make-board (homologize l 1 nil))))))

  (define-board 0
	(name
	 (attribute
	  (board-append-go (make-board (append
									(homologize "たでとしなうのいてす" 1)
									(homologize "はにるかがっん、。ー" 23)))
					   '((11 1) (12 2) (13 3) (14 4) (15 5) (16 6) (17 7) (18 8) (19 9) (20 10)))
	  '((11 15 link) (16 20 link2)))
	 "主"))

  (define-board 1
	(name
	 (attribute
	  (board-append-go (make-board (homologize "っん、。ー" 28))
					   '((16 6) (17 7) (18 8) (19 9) (20 10)
						 (6 29) (7 32) (8 31) (9 30) (10 33)
						 (1 27) (2 24) (3 25) (4 26) (5 28)
						 (11 15) (12 16) (13 17) (14 18) (15 19)
						 (23 20) (24 21) (25 22) (26 23) (27 38)))
	  '((1 15 link) (16 20 link2) (23 27 link)))
	 "副"))

  (define-board 2
	(make-board (homologize "・？！～…（）「」ぁあぃぇえぉおきぎくぐけげこごさざじずせぜ")))

  (define-board 3
	(make-board (homologize "そぞだちつどぬねばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅ")))

  (define-board 4
	(make-board (homologize "ゆょよらりれろわを意違下外楽近空結月後好高仕持社終女場数性先")))

  (define-board 5
	(attribute
	 (board-append-temp
	  (make-board (homologize "多体知通定電度当同読年部物聞味名面用理良"))
	  '((28 half-small-alphabet) (29 half-digit)))
	 '((28 29 link2))))

  (define-board 6
	(attribute
	 (board-append-go (make-board (homologize "一何画会回学感間帰気" 23))
					  (homologize (order-list 101 20)))
	 '((1 20 link))))

  (define-board 7
	(attribute
	 (board-append-go (make-board (homologize "見言行合今最作使子思" 23))
					  (homologize (order-list 121 20)))
	 '((1 20 link))))

  (define-board 8
	(attribute
	 (board-append-go (make-board (homologize "事時自実手出書上食新" 23))
					  (homologize (order-list 141 20)))
	 '((1 20 link))))

  (define-board 9
	(attribute
	 (board-append-go (make-board (homologize "人生前全大中的動日入" 23))
					  (homologize (order-list 161 20)))
	 '((1 20 link))))

  (define-board 10
	(attribute
	 (board-append-go (make-board (homologize "買発分変方本無明目来話" 20))
					  (homologize (append (order-list 181 15) '(11 12 13 14))))
	 '((1 15 link) (16 19 link2))))

  (define-board 11
	(attribute
	 (board-append-go (make-board) (homologize (order-list 196 30)))
	 '((1 20 link) (23 32 link))))

  (define-board 12
	(attribute
	 (board-append-go (make-board) (homologize (order-list 226 30)))
	 '((1 20 link) (23 32 link))))

  (define-board 13
	(attribute
	 (board-append-go (make-board) (homologize (order-list 256 30)))
	 '((1 20 link) (23 32 link))))

  (define-board 14
	(attribute
	 (board-append-go (make-board) (homologize (order-list 286 19)))
	 '((1 19 link) )))

  (define-board 15
	(name
	 (make-board (append (homologize "おえういあ" 16)
						 (homologize "ぉぇぅぃぁ" 28)
						 '((7 #\ょ) (8 #\ゅ) (10 #\ゃ))))
	 "あ"))

  (define-board 16
	(name
	 (make-board (append (homologize "こけくきか" 16)
						 '((7 "きょ") (8 "きゅ") (10 "きゃ") (29 #\ヶ) (32 #\ヵ))))
	 "か"))

  (define-board 17
	(name
	 (make-board (append (homologize "そせすしさ" 16)
						 '((7 "しょ") (8 "しゅ") (10 "しゃ") (9 "しぇ"))))
	 "さ"))

  (define-board 18
	(name
	 (make-board (append (homologize "とてつちた" 16)
						 '((7 "ちょ") (8 "ちゅ") (10 "ちゃ") (9 "ちぇ")
						   (30 "てゅ") (31 "てぃ"))))
	 "た"))

  (define-board 19
	(name
	 (make-board (append (homologize "のねぬにな" 16)
						 '((7 "にょ") (8 "にゅ") (10 "にゃ"))))
	 "な"))

  (define-board 20
	(name
	 (make-board (append (homologize "ほへふひは" 16)
						 '((7 "ひょ") (8 "ひゅ") (10 "ひゃ")
						   (28 "ふぉ") (29 "ふぇ") (30 "ふゅ") (31 "ふぃ") (32 "ふぁ"))))
	 "は"))

  (define-board 21
	(name
	 (make-board (append (homologize "もめむみま" 16)
						 '((7 "みょ") (8 "みゅ") (10 "みゃ"))))
	 "ま"))

  (define-board 22
	(name
	 (make-board (append (homologize "ろれるりら" 16)
						 '((7 "りょ") (8 "りゅ") (10 "りゃ")
						   (28 "よ") (29 "れぅ") (30 "ゆ") (32 "や"))))
	 "ら"))

  (define-board 23
	(name
	 (make-board (append  '((6 "ヴぉ") (7 "ヴぇ") (8 "ヴ") (9 "ヴぃ") (10 "ヴぁ")
							(16 "を") (17 "ゑ") (19 "ゐ") (20 "わ")
							(28 "うぉ") (29 "うぇ") (31 "うぃ") (32 "うぁ"))))
	 "わ"))

  (define-board 24
	(name
	 (make-board (append (homologize "ごげぐぎが" 16)
						 '((7 "ぎょ") (8 "ぎゅ") (10 "ぎゃ"))))
	 "が"))

  (define-board 25
	(name
	 (make-board (append (homologize "ぞぜずじざ" 16)
						 '((7 "じょ") (8 "じゅ") (10 "じゃ"))))
	 "ざ"))

  (define-board 26
	(name
	 (make-board (append (homologize "どでづぢだ" 16)
						 '((30 "でゅ") (31 "でぃ"))))
	 "だ"))

  (define-board 27
	(name
	 (make-board (append (homologize "ぼべぶびば" 16)
						 '((7 "びょ") (8 "びゅ") (10 "びゃ"))))
	 "ば"))

  (define-board 28
	(name
	 (make-board (append (homologize "ぽぺぷぴぱ" 16)
						 '((7 "ぴょ") (8 "ぴゅ") (10 "ぴゃ"))))
	 "ぱ"))

  (define-board 29
	(name
	 (attribute
	 (board-append-go (make-board (homologize "ＱＷＥＲＴＹＵＩＯＰＡＳＤＦＧＨＪＫＬ　ＺＸＣＶＢＮＭ，．"))
					  '((20 31) (32 1)))
	 '((20 20 link)(32 32 link)))
	 "Ａ"))

  (define-board 30
	(name
	 (attribute
	  (board-append-go (make-board (homologize "＋－±×÷≠＝＜＞　０１２３４５６７８９≦≧℃°′″，．"))
					   '((10 35) (31 31) (32 1)))
	  '((10 10 link) (31 32 link)))
	 "数字"))

  (define-board 31
	(name
	 (attribute
	  (board-append-go (make-board (homologize "”＃＄％＆’～｜´｀＊＿＠！？‐＾￥；：・／＼￣＿々"))
					   '((29 39) (30 36) (31 37) (32 34)))
					   '((29 32 link)))
	 "記号"))

  (define-board 32
	(name
	 (make-board (homologize "〔〕…‥゛゜‘’“”（）【】「」｛｝〈〉《》『』∥｜［］〆―"))
	 "括弧"))

  (define-board 33
	(name
	 (make-board (homologize "♂♀☆★○●◎◇◆□■△▲▽▼←↓↑→※¨ヽヾゝゞ〃仝〇∞　"))
	 "●→"))

  (define-board 34
	(make-board (homologize "〒〓￠￡§♯♭♪†‡¶◯Å‰￥∴∵")))

  (define-board 35
	(make-board (homologize "∈∋⊆⊇⊂⊃∪∩∧∨￢⇒⇔∀∃∠⊥⌒∂∇≡≒≪≫√∽∝∫∬")))

  (define-board 36
	(name
	 (attribute
	  (board-append-go (make-board (homologize "АБВГДЕЁЖЗИЙКЛМНОПРС"))
					   '((20 37)))
	  '((20 20 link)))
	 "Д"))

  (define-board 37
	(name
	 (attribute
	  (board-append-go (make-board (homologize "ТУФХЦЧШЩЪЫЬЭЮЯ"))
					   '((20 36)))
	  '((20 20 link)))
	 "Я"))

  (define-board 38
	(name
	 (make-board (homologize "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ"))
	 "Ω"))

  (define-board 39
	(name
	 (make-board (homologize "─│┌┐┘└├┬┤┴┼━┃┏┓┛┗┣┳┫┻╋┠┯┨┷┿┝┰┥┸╂" 1 nil))
	 "罫線"))

  ;スイッチ
  (mapcar (lambda (x)
			(attribute
			 (board-append-toggle (gethash (car x) boardmap) (cdr x))
			 '((21 22 toggle))))
		  (append
		   (mapcar (lambda (x) (list x '(21 alt) '(22 width))) (order-list 0 5))
		   (mapcar (lambda (x) (list x '(21 alt) '(22 width))) (order-list 15 14))
		   '((29 (21 alphabet/a) (22 alphabet/w))
			 (30 (22 digit/w))
			 (31 (22 symbol/w))
			 (32 (22 symbol/w))
			 (33 (22 symbol/w))
			 (34 (22 symbol/w))
			 (35 (22 symbol/w))
			 (36 (21 cyril/a))
			 (37 (21 cyril/a))
			 (38 (21 greek/a)))))
  (init-styles 0 310)
  (setq root (list (gethash 0 boardmap) (gethash 1 boardmap)))
  (setq root-n 0)
  (setq home (elt root root-n))
  (setboard home))

(defun setboard (name)
  (setq board (gethash name boardmap))
  (if (null board) (setq board home)))

(defun init-key ()
  (if (not (boundp 'keymap)) (setq keymap (make-sparse-keymap)))
  (mapcar (lambda (c) (define-key keymap c 'input-key))
	(coerce "qwertyuiopasdfghjkl;:]zxcvbnm,./" 'list))
  (mapcar (lambda (c) (define-key keymap c 'input-with-convert-key))
	(coerce "QWERTYUIOPASDFGHJKL+*}ZXCVBNM<>?" 'list))
  (define-key keymap #\@ 'home-lock)
  (define-key keymap #\RET 'ret-or-kakutei)
  (define-key keymap #\SPC 'space-or-convert)
  (define-key keymap #\[ 'toggle-convert-command)
  (define-key keymap #\C-h 'del-back-char)
  (define-key keymap #\` 'help-char)
  (define-key keymap #\{ 'toggle-help))

(defun toggle-help ()
  (interactive)
  (if (setf #1=(gethash 'show flags) (not #1#))
	  (show)
	(terminate-show)))

(defun ibuki-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode 'ibuki-mode arg sv)
  (update-mode-line t)
  (if ibuki-mode
	  (progn
		(set-minor-mode-map keymap)
		(run-hooks 'ibuki-mode-hook)
		(show))
	(progn
	  (unset-minor-mode-map keymap)
	  (terminate-show))))

(defun input-key ()
  (interactive)
  (main-process (input-to-inner-code *last-command-char*)))

(defun input-with-convert-key ()
  (interactive)
  (if (not (gethash 'convert flags))
	  (toggle-convert))
  (setf (gethash 'temp-convert flags) t)
  (main-process (input-to-inner-code *last-command-char*)))

(defun input-to-inner-code (char)
  (gethash char input/inner))

(defun main-process (code)
  (let ((data (gethash code board)))
	(cond
	 ((stringp data)
	  (mapcar 'do-insert-normal (coerce data 'list))
	  (setboard home)
	  (if (gethash 'convert flags)
		  (update-convert convert-key-num t)
		(push-recent-output data)))
	 ((characterp data)
	  (do-insert-normal data)
	  (setboard home)
	  (if (gethash 'convert flags)
		  (update-convert convert-key-num t)
		(push-recent-output (string data))))
	 ((eq (car data) 'go) (setboard (cadr data)))
	 ((eq (car data) 'toggle) (toggleflag (cadr data)) )
	 ((eq (car data) 'convert) (output-convert (cadr data)))
	 ((eq (car data) 'temp-state) (temp-state (cadr data)))
	 (t nil))
	(show)))

(defun do-insert-normal (data)
  (if (gethash 'convert flags)
	  (progn
		(push data memory-raw)
		(push (char-filter data) memory)
		(let ((pos (point)))
		  (do-insert (char-filter data))
		  (set-txt-attr pos (point) 'convert)))
	  (do-insert (char-filter data))))

(defun do-insert (d)
  (if overwrite-mode
	  (if (stringp d)
		  (mapcar 'overwrite-char (coerce d 'list))
		(overwrite-char d))
	(insert d)))

(defun char-filter (chr)
  (let* ((c (gethash chr char-width-filter))
		 (c (if (and c
					 (case (gethash (cadr c) flag-policies)
					   (priority #1=(gethash (cadr c) flags))
					   (invert (if #1# (not #2=(gethash 'width flags)) #2#))
					   (t #2#)))
				(car c)
			  chr))
		 (ca (gethash c char-alt-filter)))
	(if (and ca
			 (case (gethash (cadr ca) flag-policies)
			   (priority #3=(gethash (cadr ca) flags))
			   (invert (if #3# (not #4=(gethash 'alt flags)) #4#))
			   (t #4#)))
		(car ca)
	  c)))

(defun key-name (data)
  (cond
   ((stringp data) data)
   ((characterp data) (coerce (list data) 'string))
   ((eq (car data) 'go)
	(let ((b (gethash (cadr data) boardmap)))
	  (key-name
	   (or (gethash 'name b)
		   (gethash 1 b)
		   ""))))
   ((eq (car data) 'toggle) (or (gethash (cadr data) flag-names) ""))
   ((eq (car data) 'convert) (convert-show-string (elt convert-list (cadr data))))
   ((eq (car data) 'temp-state) (cadr (gethash (cadr data) temp-states)))
   (t "")))

(defun toggleflag (name)
  (if (gethash name flag-policies)
	(setf (gethash name flags) (not (gethash name flags)))
	(let ((depend (gethash name flag-depends)))
	  (if depend (setf (gethash depend flags) (not (gethash depend flags)))))))

(defun show-string (board)
  (let ((ind (list 0)))
	(labels
		((/fill (str width)
		   (concat " " str (coerce (make-list (- width (count-column str))
											  :initial-element #\SPC) 'string) " "))
		 (/line (lst)
		   (concat (apply 'concat lst) "\n"))
		 (/count (lst)
		   (let ((l (reverse (mapcar 'length lst))))
			 (incf (car l))
			 (setq ind (append l ind)))
		   lst)
		 (/index (lst)
		   (let (l (i 0))
			 (dolist (a lst (reverse l))
			   (push (incf i a) l)))))
	  (let* ((l (gethash 'show board))
			 (l2 (mapcar (lambda (x)
						   (mapcar (lambda (y)
									 (format nil "~{~A~}" (mapcar 'char-filter (coerce y 'list))))
								   x)) l))
			 (l3 (apply 'append l2))
			 (width (if l3 (apply 'max (mapcar 'count-column l3))))
			 (l4 (apply 'concat
						(mapcar (lambda (m) (/line (/count (mapcar (lambda (x) (/fill x width)) m))))
								l2))))
		(values l4 (/index (reverse ind)))))))

(defun show ()
  (interactive)
  (if (interactive-p)
	  (setf (gethash 'show flags) t))
  (when (gethash 'show flags)
	(if (gethash 'convert flags) (update-convert-show))
	(multiple-value-bind (s ind)
		(show-string board)
	  (when s
		(unless (find-buffer show-buffer)
		  (setup-show-buffer))
		(let ((buff (find-buffer show-buffer)))
		  (save-excursion
			(set-buffer buff)
			(delete-region 0 (point-max))
			(clear-all-text-attributes)
			(insert s)
			(goto-char (point-min))
			(dolist (a (gethash 'text-attribute board))
			  (set-txt-attr (elt ind (1- (car a))) (elt ind (cadr a)) (caddr a))))
		  (unless (get-buffer-window buff)
			(let ((w (selected-window)))
			  (split-window -4 nil)
			  (set-buffer buff)
			  (set-window w))))))))

(defun setup-show-buffer ()
  (setup-temp-buffer (get-buffer-create show-buffer)))

(defun terminate-show ()
  (let ((buff (find-buffer show-buffer))
		wnd)
	(when buff
	  (while (setq wnd (get-buffer-window buff))
		(set-window wnd)
		(delete-window))
	  (delete-buffer buff))))

(defun home-lock ()
  (interactive)
  (if (gethash 'temp-state flags)
	  (switch-state)
	(home-lock-sub))
  (show))

(defun home-lock-sub ()
  (if (eq board home)
	  (progn
		(if (eq home (elt root root-n))
			(setq root-n (rem (1+ root-n) (length root))))
		(setq home (elt root root-n)))
	(setq home board))
  (setboard home))

;変換動作部

(defun toggle-convert-command ()
  (interactive)
  (if memory (memory-reset)
	(toggle-convert)))

(defun output-memory ()
  (output-with-memory (apply 'concat (mapcar 'string (reverse memory)))))

(defun space-or-convert ()
  (interactive)
  (if memory
	  (progn
		(if (gethash 'index flags)
		  (progn
			(update-convert 30)
			(if (>= (incf index 30) (length convert-list))
				(setq index 0)))
		  (update-convert (- 30 convert-key-num)))
		(setq board (make-convert-board))
		(show)
		(setf (gethash 'index flags) t))
	(do-insert
	 (if (or (gethash 'width flags)
			 (gethash 'always-half-space flags)) #\SPC #\　))))

(defun del-back-char ()
  (interactive)
  (if (eq board home)
	  (if memory
		  (let ((pos (set-marker (make-marker))))
			(setq memory (cdr memory)
				  memory-raw (cdr memory-raw))
			(if (null memory) (setq board home))
			(delete-before-convert)
			(goto-marker pos)
			(mapcar 'do-insert (reverse memory))
			(set-txt-attr (marker-point pos) (point) 'convert)
			(update-convert convert-key-num t))
		(call-interactively 'delete-backward-char))
	(setq board home))
  (show))

(defun ret-or-kakutei ()
  (interactive)
  (if memory (output-memory)
	(progn
	  (let ((f (unset-minor-mode-map keymap))
			(c (lookup-key-command #\RET)))
		(if (not (eq c 'ret-or-kakutei))
			(call-interactively c)
		  (newline))
		(if f (set-minor-mode-map keymap))))))


(defun toggle-convert ()
  (setf (gethash 'temp-convert flags) nil)
  (when (setf (gethash 'convert flags) (not (gethash 'convert flags)))
	  (update-convert convert-key-num t)
	(setq index 0))
  (psetq root root-convert
		 root-convert root)
  (setq home (elt root root-n))
  (if (member board root-convert)
	  (setq board home))
  (show))

(defun init-convert ()
  (setq memory nil memory-raw nil) ;検索文字、無変換出力文字
  (if (gethash 'convert flags)
	  (toggle-convert)) ;root-convertが使われている場合は戻す。
  (setq root-convert
		(let (l)
		  (dolist (b root (reverse l))
			(push (copy-hash-table b) l))))
  (mapcar (lambda (b l)
			(mapcar (lambda (x)
					  (setf (gethash (car x) b) (list 'convert (cadr x)))
					  (attribute b (list (list (car x) (car x) 'candidate))))
			  l)
			(setf (gethash 'convert b) l))
	root-convert convert-keys) ;convert用のキーを設定
  (setq convert-show-map (make-hash-table :size 7)) ;show用のキー配置の指定。
  (mapcar (lambda (x) (setf (gethash (car x) convert-show-map) (cdr x)))
	(append
	 (mapcar (lambda (x y) (list x 0 y)) (order-list 1 10) (order-list 0 10))
	 (mapcar (lambda (x y) (list x 1 y)) (order-list 11 12) (order-list 0 12))
	 (mapcar (lambda (x y) (list x 2 y)) (order-list 23 10) (order-list 0 10))))
  (update-convert convert-key-num t))

(defun update-convert (num &optional renew)
  (if renew
	  (setq convert-list #1=(convert-search num renew))
	(setq convert-list (append convert-list #1#))))

(defun init-yomi-buffer ()
  (save-excursion
	(let ((buff (get-buffer-create yomi-buffer)))
	  (setup-temp-buffer buff)
	  (set-buffer buff)
	  (if (ignore-errors (progn (insert-file-contents yomi-file nil) t))
		  t (message "読み辞書 ~A がありません。" yomi-file))
	  buff)))

(defun convert-search (num renew)
  (if (plusp (length memory-raw))
	  (save-excursion
		(set-buffer (or (find-buffer yomi-buffer)
						(init-yomi-buffer)))
		(if renew (goto-char (point-min)))
		(let (l (s (memory-raw)))
		  (while (plusp num)
			(if (and s (scan-buffer (car s)))
				(let ((end (point-eol)))
				  (when (dolist (a (cdr s) t)
						  (goto-bol)
						  (if (not (scan-buffer a :limit end))
							  (return nil)))
					(push (buffer-substring (point-bol) (progn (scan-buffer " " :limit end) (point)))
						  l)
					(decf num))
				  (next-line)
				  (goto-bol))
			  (return)))
		  (reverse l)))
	(subseq recent-output 0 (min recent-count num))))

(defun memory-raw ()
  (mapcar (lambda (x) (concat " " (substitute-string x (string period) " ")))
	(split-string (apply 'concat (mapcar 'half-char (reverse memory-raw))) comma)))

(defun point-bol ()
  (goto-bol) (point))

(defun point-eol ()
  (goto-eol) (point))

(defun update-convert-show ()
  (let ((show (copy-tree (gethash 'show home))))
	(mapcar (lambda (x)
			  (let ((p (gethash (car x) convert-show-map)))
				(setf (elt (elt show (car p)) (cadr p))
					  (convert-show-string (elt convert-list (cadr x))))))
	  (gethash 'convert home))
	(setf (gethash 'show home) show)))

(defun convert-show-string (str)
  (if str
	  (if (> (count-column str) convert-show-column)
		  (let (l)
			(dolist (a (coerce str 'list))
			  (if (>= (count-column (coerce (push a l) 'string)) convert-show-column)
				  (return (coerce (append (reverse (cdr l)) (list #\~)) 'string)))))
		str) ""))

(defun copy-hash-table (table)
  (let ((b (make-hash-table :size (hash-table-size table) :test (hash-table-test table)
							:rehash-size (hash-table-rehash-size table))))
	(maphash (lambda (x y)
			   (setf (gethash x b) y))
			 table)
	b))

(defun output-convert (num)
  (output-with-memory (elt convert-list num)))

(defun output-with-memory (str)
  (when (plusp (length str))
	(memory-reset)
	(push-recent-output str)
	(mapcar 'do-insert (coerce str 'list))
	   (if (gethash 'temp-convert flags) (toggle-convert)
		 (if (gethash 'keep-convert flags)
			 t (toggle-convert)))
	(show)))

(defun memory-reset ()
  (setq memory nil memory-raw nil board home)
  (setf (gethash 'index flags) nil)
  (delete-before-convert)
  (update-convert convert-key-num t))

(defun delete-before-convert ()
  (save-excursion
	(let ((pos 0))
	  (loop
		(multiple-value-bind (from to) (find-text-attribute 'convert :start pos)
		  (if from (progn (setq pos (if (zerop (- from to)) (1+ from) from))
					 (delete-region from to))
			(return))))
	  (delete-text-attributes 'convert))))

(defun push-recent-output (str)
  (when (and (plusp (length str))
			 (not (member str (subseq recent-output 0 (min recent-count convert-key-num))
						  :test 'equal)))
	(setq recent-output
		  (append (list str) (subseq recent-output 0 recent-count)))
	(if (< recent-count recent-output-max) (incf recent-count))))

(defun half-char (chr)
  (let* ((c (gethash chr char-width-filter))
		 (c (if c (car c) chr)))
	(if (characterp c) (string c) c)))

(defun make-convert-board ()
  (let* ((b (make-hash-table :size 7))
		 l (l (dotimes (a 30 (reverse l)) (push (if (< 19 a) (+ a 3) (+ a 1)) l)))
		 (c (1- index)))
	(mapcar (lambda (x)
			  (setf (gethash x b) (list 'convert (incf c)))) l)
	(set-style b) (board-home-position b)))

(defun help-char ()
  (interactive)
  (let ((c (string (char-before (point)))))
	(save-excursion
	  (set-buffer (or (find-buffer yomi-buffer)
					  (init-yomi-buffer)))
	  (save-excursion
		(goto-char (point-min))
		(if (scan-buffer c)
			(message "~A" (buffer-substring (point-bol) (point-eol))))))))

;一時モード切替

(defun init-temp-state ()
  (setq temp-states (make-hash-table))
  (setf (gethash 'half-small-alphabet temp-states)
		'(:name "a" :/flag ((width t) (alphabet/a t)) :/home 29))
  (setf (gethash 'half-digit temp-states)
		'(:name "9" :/flag ((width t)) :/home 30))
  (setq temp-state nil))

(defun temp-state (state)
  (let ((s (gethash state temp-states)))
	(if s (apply 'switch-state s))))

(defun switch-state (&key name /flag /home)
  (if (null name)
	  (apply 'switch-state :name t temp-state)
	(progn
	  (setf (gethash 'temp-state flags)
			(if (eq name t) nil t))
	  (setq temp-state
			(list :/flag (list (list 'width (gethash 'width flags))
							   (list 'alt (gethash 'alt flags)))
				  :/home home))
	  (mapcar (lambda (x) (setf (gethash (car x) flags) (cadr x))) /flag)
	  (if (hash-table-p /home)
		  (setq home /home)
		(if (numberp /home)
			(setq home (gethash /home boardmap))))
	  (setboard home))))

(init-temp-state)
(init-attribute)
(init-filter)
(init-key)
(init-board)
(init-convert)
(setf (gethash 'show flags) t)
(setf (gethash 'keep-convert flags) t)