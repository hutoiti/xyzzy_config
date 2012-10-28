;;;
;;;  lleee.l : 漢直連習用コマンド
;;;
;;;  written by sugi <y_sugi@anet.ne.jp> (November 16, 2004)

(provide "lleee")

(in-package "editor")

(export '(lleee *lleee-file-name* *lleee-line-num* *lleee-char-num* *lleee-default-tag*))

; 読み込むファイル名
(defvar *lleee-file-name* "~/lleee.txt")

; 表示する行数
(defvar *lleee-line-num* 3)

; 1 行あたりの文字数
(defvar *lleee-char-num* 10)

; 先頭にこの文字列がある行だけ読み込む
(defvar *lleee-default-tag* "LR")

; この文字が先頭にある行はコメントとみなす
(defvar *lleee-comment-char* #\#)

; ファイルを読み込み、漢字を string として返す
; filename:  読み込むファイル名
; read-tag: この文字が先頭にある行だけ読み込む
(defun read-kanji (filename read-tag)
  ; filename をオープン(読み込み)
  (with-open-file (input_file filename :direction :input)
	; buff: 一行分のバッファ
	; line_list: 今まで読み込んだ内容
	; read-regexp: マッチさせる正規表現
	(let (buff line-list read-regexp)
	  ; 正規表現を生成(スペースまでが \1, スペース後が \2 に入る)
	  (setq read-regexp (concat "^\\(.*" read-tag ".*\\) \\(.*\\)"))
	  ; EOF まで一行ずつ読み込む
	  (while (setq buff (read-line input_file nil))
		; read-regexp にマッチする行のみ読み込む(コメント行は読まない)
		(if (and (string-match read-regexp buff) (not (eq (char buff 0) *lleee-comment-char*))) 
			;(and 
			; 読み込んだデータを連結する(head-str は削除する)
			(setq line-list	(concat line-list (string-replace-match buff "\\2")))))
	  ; 空白とタブを削除する
	  (setq line-list
			(remove-if #'(lambda (char) (find char '(#\SPC #\TAB #\　))) line-list))
	  line-list)))

; リストから、ランダムに pickup-num 個の漢字を抽出する
; リストに入ってる個数が pickup-num より少ない時は全部抽出する
; kanji-list: この文字列から読み込む
; pickup-num: この数だけ抽出する
(defun get-rand-list (kanji-list pickup-num)
  ; リストがなくなるか、もう抽出しなくてもよい時 nil を返す
  (if (or (eq (length kanji-list) 0) (eq pickup-num 0))
	  nil
	; selected-char: リストからランダムに選んだ文字
	(let (selected-char)
	  ; リストからランダムに 1 文字抽出
	  (setq selected-char (char kanji-list (random (length kanji-list))))
	  ; リストから抽出した文字を削除
	  (setq kanji-list (delete selected-char kanji-list))
	  ; 抽出した文字と残ったリストからランダムに pickup-num - 1 個抽出したのをつなげて返す
	  (concat (list selected-char) (get-rand-list  kanji-list (1- pickup-num))))))

; 文字列を整形してバッファに書き込む
; rand-list: 書き込む文字列
; line-num: この行数書き込む
; char-num: 一行当たりの文字数
(defun write-kanji (rand-list line-num char-num)
  ; 1 行ずつバッファに書き込む
  (dotimes (i line-num)
	(let (current-line start end)
	  ; 1 行分の開始位置と終了位置を計算する
	  (setq start (* i char-num))
	  ; 終了位置は start から char-num 後ろ(リストの終端は超えない)
	  (setq end (min (+ start char-num)	(length rand-list)))
	  ; 1 行分を作成する
	  (setq current-line (subseq rand-list start end))
	  ; 1 行バッファに書き込み
	  (insert (format nil "~A~%~%" current-line))
	  ; リストの最後まで書いたら終了
	  (if (eq end (length rand-list))
		  (return)))))

; 漢直練習用コマンド
; head-str: 先頭がこの文字列の行のみ読み込む
; filename: 読み込むファイル名
; line-num: 何行出力するか
; char-num: 1 行あたり何文字出力するか
(defun lleee (read-tag &optional (filename *lleee-file-name*) (line-num *lleee-line-num*) (char-num *lleee-char-num*))
  ; コマンドとして定義
  (interactive "sread-tag:" :default0 *lleee-default-tag*)
  ; kanji-list: 使用する漢字を入れる
  (let (kanji-list rand-list)
	; ファイルを読み込み、漢字リストを取得
	(setq kanji-list (read-kanji filename read-tag))
	;read-tag に何も入ってなければ、全ての行を取る
	(if (equal (length read-tag) 0)
		(setq read-tag ".*"))
	; 乱数のシードを設定
	(setq *random-state* (make-random-state t))
	; ランダムな漢字リストを取得
	(setq rand-list (get-rand-list kanji-list (* line-num char-num)))
	; 新しいバッファを作成する
	(with-output-to-temp-buffer ("*lleee*")
	  ; バッファに書き込む
	  (write-kanji rand-list line-num char-num)))
  ; カーソルをバッファの先頭に
  (goto-char (point-min))
  ; 一行下にカーソル移動
  (forward-line))
