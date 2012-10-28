; nippo-mode
; programed by yo-sugi

(provide "nippo")
(in-package "editor")

(export '(nippo-mode *nippo-mode-map* *nippo-mode-hook*
		  *nippo-save-with-mail* *nippo-default-category*
		  *nippo-log-separate-format* *nippo-directory*
		  *nippo-smtp-server* *nippo-smtp-port*))

; TODO: 作る変数
; *nippo-replace-alist*
(defvar *nippo-mode-version* "0.2.0" "バージョン")
(defvar *nippo-mode-name* "nippo" "このモードの名前")
(defvar *nippo-pframe-name* *nippo-mode-name* "フレームの名前")

(defvar *nippo-mode-hook* nil "nippo-mode フック")
(defvar *nippo-save-with-mail* nil "メール送信時に保存するか")

(defvar *nippo-directory* "~/.nippo" "日報置き場")
(defvar *nippo-default-category* "nippo" "最初に出てくるカテゴリ")

(defvar *nippo-smtp-server* nil "smtp サーバ")
(defvar *nippo-smtp-port* "25" "smtp ポート")

; 各ファイル名
(defvar *nippo-recent-filename* "recent.txt" "最後に書いた日報")
(defvar *nippo-log-filename* "log.txt" "日報のログ")
(defvar *nippo-template-filename* "template.txt" "メールのテンプレート")

; 各ファイルへのパス
(defvar *nippo-recent-filepath* nil "最後に書いた日報")
(defvar *nippo-log-filepath* nil "日報のログ")
(defvar *nippo-template-filepath* nil "メールのテンプレート")

; 日報本文を置換する時のタグ
(defvar *nippo-contents-tag* "$CONTENTS" "本文置換用タグ")

; ログの区切り行
(defvar *nippo-log-separate-format* nil "ログの区切り行")

;; キーマップの定義
(defvar *nippo-mode-map* nil "nippo-mode キーマップ")
(unless *nippo-mode-map*
  (setq *nippo-mode-map* (make-sparse-keymap))
  ; セーブ & メール送信
  (define-key *nippo-mode-map* '(#\C-c #\C-c) 'send-nippo-mail)
  ; セーブ
  (define-key *nippo-mode-map* '(#\C-x #\C-s) 'save-nippo-files))

; カレントバッファを置換する
; replace-alist は キーが置換するタグ(文字列)で、
; 値が置換後の文字列又は文字列を返す S 式
(defun replace-buffer-tag (replace-alist)
  "カレントバッファを置換する"

  ; ハッシュを一個ずつ見て置換
  (mapcar
   #'(lambda (replace-element)
	   (let ((tag (car replace-element))
			 (replacement (cdr replace-element)))
		 (beginning-of-buffer)
		 (replace-buffer tag
						 (eval replacement)
						 :regexp nil)))
   replace-alist))

; header-string: 追加する文字列
; 戻り値: nil 失敗, t 成功
(defun nippo-add-header (header-string)
  "ヘッダ追加"
  (beginning-of-buffer)

  ; バッファを一行ずつ見ていく(空行が来たらヘッダは終わり)
  (while (progn
		   (setq current-line (buffer-substring (progn (goto-bol) (point))
												(progn (goto-eol) (point))))
		   (> (length current-line) 0))

	; 空行が来る前にファイルが終わったらエラー
	(if (null (forward-line)) (return-from nippo-add-header)))

  ; ヘッダが終了したら、空行の前に文字列を入れる
  (insert header-string))

;TODO: 作る関数
;(nippo-add-replacement)

(defun send-nippo-mail ()
  "日報メールを送信"
  (interactive)

  ; 一応確認を入れとく
  (if (not (yes-or-no-p "メールを送信しますか"))
	  (return-from send-nippo-mail))

  ; recent-buffer: 現在のバッファ(*nippo-recent-filename* のパッファである事を仮定)
  ; template-buffer: テンポラリバッファ
  (let ((recent-buffer (selected-buffer)) template-buffer)

	; テンポラリバッファを作る
	(set-buffer (get-buffer-create "*nippo-send-mail*"))
	(setq template-buffer (selected-buffer))

	;; テンポラリバッファの各種設定
	(erase-buffer (selected-buffer))
	(kill-all-local-variables)
	(make-local-variable 'need-not-save)
	(setq need-not-save t)						; セーブする必要なし
	(set-buffer-modified-p nil)					; 変更されたか覚えなくてよし
	(change-fileio-encoding *encoding-jis*)		; メールなので入出力を jis に

	;; あればメール用テンプレートファイル読み込み
	(if (file-exist-p *nippo-template-filepath*)
		(with-open-file (fp *nippo-template-filepath* :direction :input)
		  (let (line)
			(while (setq line (read-line fp nil))
			  (insert (format nil "~A~%" line)))))

	  ; なければ終了
	  (progn
		(message-box "テンプレートファイルがありません")
		(return-from send-nippo-mail)))

	;; ヘッダ追加処理
	(nippo-add-header
	 (concat
	  (format nil "Date: ~A~%" (format-date-string "%a, %d %b %Y %H:%M:%S %Z"))
	  (format nil "Content-Type: text/plain; charset=ISO-2022-JP~%")
	  (format nil "Mime-Version: 1.0~%")
	  (format nil "X-Mailer: nippo-mode ~A on xyzzy-~A~%"
			  *nippo-mode-version* (software-version))
	  (format nil "X-Yzzy-Version: ~A~%" (software-version))))

	;; 日報本文を置換
	(beginning-of-buffer)
	(when (scan-buffer *nippo-contents-tag*)
	  (delete-char (length *nippo-contents-tag*))

	  ; 現在位置から書き込み開始
	  (with-output-to-buffer (template-buffer (point))
		(with-input-from-buffer (recent-buffer)
		  (let (line)
			(while (setq line (read-line *standard-input* nil))
			  (map-internal-to-jis (format nil "~A~%" line) *standard-output*))))))

	;; alist を作って置換
	(let ((replace-alist))
	  (macrolet ((pushnew-alist (replace-element); replace-alist)
				   `(pushnew ,replace-element replace-alist :key #'car)))
		(pushnew-alist '("$DATE" . (format-date-string "%Y\/%m\/%d")))
		(pushnew-alist '("$YEAR" . (format-date-string "%Y")))
		(pushnew-alist '("$MONTH" . (format-date-string "%m")))
		(pushnew-alist '("$HOGE" . "hoge"))
		(pushnew-alist '("$DAY" . (format-date-string "%d"))))
	  (replace-buffer-tag replace-alist))

	; ヘッダから mail from と 送信先を取得
	(let ((recipients (get-mail-header template-buffer '("to" "cc" "bcc")))
		  (mail-from (get-mail-header template-buffer '("from"))))

	  ; from と to が両方なければエラー
	  (unless (and recipients mail-from)
		(message-box "ヘッダに from か to がありません")
		(return-from send-nippo-mail))

	  ; メールアドレスを抽出
	  (let* ((get-address
			  #'(lambda (str)
				  (string-match "\\([a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\\)" (cdr str))
				  (match-string 1)))

			 ; from は一個だけなので car しておく
			 (from (car (mapcar get-address mail-from)))
			 (to-list (mapcar get-address recipients)))

		;; バッファのヘッダ部分を base64 エンコードする
		(encode-mail-header template-buffer)

		;; メールを送信
		(long-operation
		  (message "~A" "sending...")
		  (unless (send-mail *nippo-smtp-server* *nippo-smtp-port*
							 (buffer-substring (point-min) (point-max))
							 from
							 to-list)

			; 送信に失敗したらメッセージを表示して終了
			(message "~A" "sending...failed")
			(message-box "送信できませんでした")
			(return-from send-nippo-mail))

		  ; 送れました
		  (message "~A" "sending...done"))))

	; 元のバッファに戻して、送信用バッファは削除
	(set-buffer recent-buffer)
	(delete-buffer template-buffer)

	; 送信時にログを保存
	(if *nippo-save-with-mail*
		(save-nippo-files))))

(defun save-nippo-files ()
  "日報ファイルをセーブ"
  (interactive)

  ; 現在のバッファの内容を nippo-recent.txt に保存
  (save-buffer *encoding-jis* *eol-crlf*)

  ; 対話的に呼ばれた時のみ確認ダイアログを出す
  (if (and (interactive-p)
		   (not (yes-or-no-p "ログを保存しますか")))
	  (return-from save-nippo-files))

  ; nippo-log.txt にセパレータ・ヘッダを書き込み
  (with-open-file (fp *nippo-log-filename*
					  :direction :output
					  :if-exists :append
					  :if-does-not-exist :create)

	(format fp "~%~A~%"
			(format-date-string (or *nippo-log-separate-format*
									"= 日報: %y年%m月%d日(%v)"))))

  ; 現在のバッファの内容を log.txt に追加書き込み
  (append-file *nippo-log-filename* t *encoding-sjis* *eol-crlf*)
  (message "~A~%" "save complete"))

(defun chop (str)
  "文字列を受け取って、最後の一文字を消したものを返す"
  (if (stringp str)
	  (substring str 0 (- (length str) 1))))

(defun nippo-mode ()
  "nippo-template を読み込んで新しいフレームで表示"
  (interactive)
  ; 各種ファイルを読み込むディレクトリを決定
  ; nippo-category-dir: カテゴリのディレクトリ名
  (let (nippo-category-dir)
	(let (category)

	  ; ~/.nippo 以下にあるディレクトリ名を取得
	  (setq category
			(completing-read "category: "

							 ; ディレクトリリストから "/" を消した物が補完対象
							 (mapcar #'(lambda (dir) (chop dir))
									 ; *nippo-directory* 以下のディレクトリを取得
									 (directory *nippo-directory* :directory-only t))
							 :case-fold t
							 :default *nippo-default-category*))

	  ; ディレクトリ名を設定
	  (setq nippo-category-dir (merge-pathnames category *nippo-directory*)))

	; 各ファイル名の設定
	(setq *nippo-recent-filepath*
		  (merge-pathnames *nippo-recent-filename* nippo-category-dir))
	(setq *nippo-log-filepath*
		  (merge-pathnames *nippo-log-filename* nippo-category-dir))
	(setq *nippo-template-filepath*
		  (merge-pathnames *nippo-template-filename* nippo-category-dir)))

  ; 新しいフレームを作って名前を付ける
  (new-pseudo-frame *nippo-pframe-name*)

  ; 直前に書いたファイルを読み込む
  (find-file *nippo-recent-filepath*)
  (kill-all-local-variables)

  ; モード用の設定
  (setq mode-name "nippo")
  (setq buffer-mode 'nippo-mode)
  (use-keymap *nippo-mode-map*)
  (run-hooks '*nippo-mode-hook*))

; host: MTA
; port: ポート
; send-str: 送信する文字列
; mail-from: mail from
; recipients : 送信先(たち)
(defun send-mail (host port send-str mail-from recipients)
  "メールを送信する"
  ; ポート番号がなければデフォルト値を入れる
  (if (null port) (setq port 25))
  (with-open-stream (stream (connect host port))

	; command を送信して期待する応答コードか見る
	(flet ((send-cmd (command expect-code)
			 (let (ret-code)
			   
			   ; nil でなければ command を送信
			   (unless (null command)
				 (format stream "~A" command))

			   ; 応答を受け取る
			   (let ((reply (read-line stream nil)))
				 (with-open-file (fp "~/log.txt"
									 :direction :output
									 :if-exists :append
									 :if-does-not-exist :create)
				   (format fp "send: ~A~%" command)
				   (format fp "recv: ~A~%" reply))

				 ; 応答が期待するコードでなければエラー
				 (if (equal (substring reply 0 3) (format nil "~3,'0D" expect-code))
					 reply
				   (return-from send-mail))))))

	  ; メールを送信する
	  (send-cmd nil 220)	; 接続した時の応答を見る
	  (send-cmd (format nil "HELO ~A\n" (socket-stream-local-name stream)) 250)
	  (send-cmd (format nil "MAIL FROM: <~A>\n" mail-from) 250)

	  ; rcpt to を送る
	  (mapcar #'(lambda (recipient)
				  (send-cmd (format nil "RCPT TO: <~A>\n" recipient) 250))

			  ; 文字列ならリストにし、リストならそのまま渡す
			  (if (stringp recipients)
				  (list recipients)
				recipients))

	  ; ドットスタッフィングして本文を送信
	  (send-cmd (format nil "DATA\r\n") 354)
	  (with-input-from-string (instr send-str)
		(let (line)

		  ; 文字列がある限り一行ずつ読み込む
		  (while (setq line (read-line instr nil))

			; ドットスタッフィングをする
			(if (equal "." line)
				(format stream "..~%")
			  (format stream "~A~%" line)))))
	  
	  ; 最後の . を送信して終了
	  (send-cmd ".\n" 250)
	  (send-cmd "QUIT\n" 221))))

;; ヘッダに ascii 以外の文字があれば base64 で mime エンコードする
;; 指定されたバッファを読み込んで、そこの内容を書き換える
;; 文字コードが JIS である事を仮定
;; folding などは考慮していない
(defun encode-mail-header (buffer)
  "メールヘッダのエンコード"

  ; 今のバッファを保存しとく
  (let ((old-buffer (selected-buffer)))
	(set-buffer buffer)
	(goto-char (point-min))

	; 最初の一行分を取得
	(let ((current-line (buffer-substring (progn (goto-bol) (point))
										  (progn (goto-eol) (point)))))

	  ; バッファを一行ずつ見ていく(空行が来たらヘッダは終わり)
	  (while (> (length current-line) 0)

		; ヘッダの書式にマッチしなかったら次へ
		(when (string-match
			   (concat "[" ed::*ascii-chars-range* "]+:[ \t]*\\(.*\\)$")
			   current-line)

		  ; field-body: ヘッダの内容(':' の後)
		  ; begin-body: ヘッダボディの先頭ポイント
		  (let ((field-body (match-string 1))
				(begin-body (match-beginning 1)))

			; ascii 以外のものが入っていればエンコードして書き換える
			(unless (string-match
					 (concat "^[" ed::*ascii-chars-range* " \t]+$")
					 field-body)

			  ; ヘッダボディの位置に移動して、現在位置を保存
			  (goto-bol) (forward-char begin-body)
			  (let ((begin-body-buffer (point)))

				; ヘッダ body を削除
				(delete-region begin-body-buffer (progn (goto-eol) (point)))
				(goto-char begin-body-buffer)

				; base64 & mime エンコードしたものを挿入
				(insert (concat "=?ISO-2022-JP?B?"

								; 最後に改行が入るので trim しとく
								(string-trim "\n" (si::base64-encode field-body))
								"?="))))))

		; 1 行下に移動(最終行だったらそこで終了)
		(if (null (forward-line)) (return))

		; 次の行を取得
		(setq current-line (buffer-substring (progn (goto-bol) (point))
											 (progn (goto-eol) (point))))
		(goto-bol)))

	; 元のバッファに戻す
	(set-buffer old-buffer)))

; buffer: 取ってくるバッファ
; headers: 取ってくるヘッダ名のリスト(nil なら全部取ってくる)
(defun get-mail-header (buffer headers)
  "メールのヘッダを取得"
  ; 今のバッファを保存しとく
  (let ((old-buffer (selected-buffer)))
	(set-buffer buffer)
	(goto-char (point-min))

	; 最初の一行分を取得
	(let ((current-line (buffer-substring (progn (goto-bol) (point))
										  (progn (goto-eol) (point))))
		  (header-alist nil))

	  ; バッファを一行ずつ見ていく(空行が来たらヘッダは終わり)
	  (while (> (length current-line) 0)
		; ヘッダの書式にマッチしなかったら次へ
		(when (string-match
			   (concat "\\([" ed::*ascii-chars-range* "]+\\):[ \t]*\\(.*\\)$")
			   current-line)

		  ; ヘッダ名と値を組にした連想リストを作る
		  (push (cons (match-string 1) (match-string 2)) header-alist))

		; 1 行下に移動(最終行だったらそこで終了)
		(if (null (forward-line)) (return))
		; 次の行を取得
		(setq current-line (buffer-substring (progn (goto-bol) (point))
											 (progn (goto-eol) (point)))))

	  ; リクエストがあったヘッダのみ返す
	  (if headers
		  (intersection header-alist headers :test #'(lambda (x y)
													   (equalp (car x) y)))
		header-alist))))

