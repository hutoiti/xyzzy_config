;;
;;
;; ◆ hateda-mode ◆
;;  -- はてなダイアリー用のメジャーモードとはてダラとの連携ツール
;;
;;
;; ++++++++++++++++++++++++++++
;; ●注意事項
;;      無保証です。
;;
;; ++++++++++++++++++++++++++++
;; ●必要なもの
;;      はてダラと連携する場合にははてダラ（＝はてなダイアリーライター）
;;      （結城浩さんによる：要Perl：http://www.hyuki.com/techinfo/hatena_diary_writer.html）
;;
;; ++++++++++++++++++++++++++++
;; ●インストール方法
;;      hateda-mode を ~/site-lisp/ において、
;;      以下を .xyzzy か siteinit.l に記述し、xyzzy を再起動する
;;      -------------------
;;      (require "hateda-mode")
;;      ;; 以下ははてダラと連携する場合のみ。設定しない場合には毎回訊いてきます
;;      (setf hw::*hatedara-multi-accounts*
;;            '(("userA" nil "~/etc" "-t")
;;              ("userB" nil "c:/data/userB/" nil)
;;              ("userC" nil "c:/" nil)
;;              ;("ユーザ名" "パスワード" "ディレクトリ" "はてダラに毎回渡す引数")
;;              ))
;;
;;      以下のように g:グループ名:ユーザ名 と書くとグループに投稿されます。
;;      （miyamukoさんによるパッチをとりこみました）
;;      (setf hw::*hatedara-multi-accounts*
;;            '(("userA" nil "~/hatena/userA" "-t")
;;              ("g:groupA:userA" nil "~/hatena/groupA" "-t")))

;;      ---------------------
;;
;; ++++++++++++++++++++++++++++
;; ●使い方
;;      M-x hw::hw                   今日の日付のはてダラファイルを開きます
;;      M-x hw::hateda-mode          はてダモードを実行します
;;      M-x hw::hws                  タイトル一覧
;;
;;  ○ はてダモードのキーバインド
;;      C-*     選択範囲か、なければ現在行を見出しにします
;;      C--     選択範囲か、なければ現在行をリストにします
;;      C-+     選択範囲か、なければ現在行を数字つきリストにします
;;      C->     選択範囲か、なければ現在行を引用にします（>> .. <<)
;;      C-|     選択範囲か、なければ現在行をPre記法でくくります（>| .. |<)
;;      C-M-|   選択範囲か、なければ現在行をスーパーPre記法でくくります（>|| .. ||<)
;;      C-c c   はてダラを使って投稿します
;;      C-c u   はてダラを使って現在編集中のファイルを投稿します
;;
;; ★Shift-JISで日記を書いていて、グループへ投稿する場合の注意
;;     グループフォルダに以下の２行を記入した config.txt ファイルを配置してください。
;;         client_encoding:Shift_JIS
;;         server_encoding:UTF-8
;;     詳細は以下を参照してください。
;;     http://www.hyuki.com/techinfo/hatena_diary_writer.html#faq_groupdiary
;;
;; ++++++++++++++++++++++++++++
;; ●謝辞
;;      このプログラムを書くにあたって wiki-mode.l を参考にさせていただきました。
;;      （http://www5d.biglobe.ne.jp/~lostland/xyzzy/）
;;
;; ++++++++++++++++++++++++++++
;; ●ライセンス
;;      このソースコードには NYSL Version 0.9982 が適用されます。
;;      条文はファイルの末尾に付与されています。
;; 2007/09/10   ver.0.3.1   グループへの投稿についての注意を追加しました。
;; 2007/07/18   ver.0.3	    amefura さんによる煮込まれ hateda-mode を取り込みました。
;;                          miyamuko さんによるグループへの投稿パッチを取り込みました。
;; 2006/09/19   ver.0.2.2   不具合対応・Netinstaller対応
;; 2006/05/24   ver.0.2.1   不具合対応
;; 2006/05/23   ver.0.2     マルチアカウント対応、編集関数を追加
;; 2006/05/16   ver.0.1     公開

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "hatena")
	(defpackage "hatena"
	  (:use "lisp" "editor" "user")
	  (:nicknames "hw"))
	))

(provide "hateda-mode")
(in-package "hatena")

;; hateda-mode
(defvar *hateda-mode-hook* nil)
(defvar *hateda-edit-with-region* nil)
(defvar *hateda-edit-with-line* t)

;; hatedara
(defvar *hatedara-submit-hook* nil)
(defvar *hatedara-after-submit-hook* nil)
(defvar *hatedara-multi-accounts* nil)
;;

(export '(*hateda-mode-hook*
          *hateda-mode-map*
          hateda-mode
          ))

(export '(*hatedara-submit-hook*
		  *hatedara-after-submit-hook*
		  *hatedara-multi-accounts*
		  hw hws hwv))

(export '(
          *hateda-headline-color*
          *hateda-readnext-color*
          *hateda-footnote-color*
          *hateda-entity-color*
          *hateda-comment-color*
          *hateda-list-color*
          *hateda-table-color*
          *hateda-quote-color*
          *hateda-pre-color*
          *hateda-autolink-color*
          *hateda-stoptag-color*
          *hateda-bold-color*
          ))

(defvar *hateda-local-variable-list*
  '(hateda-mode
    hateda-regexp-keyword-list
    ))

(defvar *hateda-headline-color* '(:color 9 12 :line :bold))
(defvar *hateda-readnext-color* '(:color 2 3 :line))
(defvar *hateda-footnote-color* '(:color 4 5))
(defvar *hateda-entity-color* '(:keyword 2 :bold))
(defvar *hateda-comment-color* '(:keyword :comment))
(defvar *hateda-list-color* '(:color 2 0 :bold))
(defvar *hateda-table-color* '(:color 3 0 :bold))
(defvar *hateda-quote-color* '(:color 6 0 :line))
(defvar *hateda-pre-color* '(:color 5 0 :line))
(defvar *hateda-autolink-color* '(:color 7 0))
(defvar *hateda-stoptag-color* '(:color 8 7))
(defvar *hateda-bold-color* '(:color 0 0 :bold))

(defvar *hateda-mode-map* nil)
(unless *hateda-mode-map*
  (setq *hateda-mode-map* (make-sparse-keymap))
  (define-key *hateda-mode-map* '(#\C-c #\c) 'hatedara-submit)
  (define-key *hateda-mode-map* '(#\C-c #\u) 'hatedara-submit-this)
  (define-key *hateda-mode-map* '#\C-+ 'hateda-num-list)
  (define-key *hateda-mode-map* '#\C-- 'hateda-list)
  (define-key *hateda-mode-map* '#\C-* 'hateda-heading)
  (define-key *hateda-mode-map* '#\C-> 'hateda-quote)
  (define-key *hateda-mode-map* '#\C-\| 'hateda-pre)
  (define-key *hateda-mode-map* '#\C-M-\| 'hateda-super-pre)
  )

(defun hateda-mode (&optional (arg nil sv))
  "hateda-mode"
  (interactive)
  (kill-all-local-variables)
  (mapc 'make-local-variable *hateda-local-variable-list*)
  (setq mode-name "hateda")
  (setq buffer-mode 'hateda-mode)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'hateda-build-summary-of-documents)
  (make-local-variable 'regexp-keyword-list)
  (setq hateda-regexp-keyword-list
        (compile-regexp-keyword-list
  `(
      ("^\\*\\{1,3\\}.+$" nil ((0 . ,*hateda-headline-color*)))
      ("^=====?$" nil ((0 . ,*hateda-readnext-color*)))
      ("^\\(\\+\\{1,3\\}\\|-\\{1,3\\}\\).*$" nil ((1 . ,*hateda-list-color*)))
      ("^\\(:\\)[^:]+\\(:\\).*$" nil ((1 . ,*hateda-list-color*) (2 . ,*hateda-list-color*)))
      ("^\\(|\\).+\\(|\\)$" nil ((1 . ,*hateda-table-color*) (2 . ,*hateda-table-color*)))
      ("((\\(.+\\)))" nil ((1 . ,*hateda-footnote-color*)))
      ("&#x?[0-9a-f]\\{5\\};" nil ((0 . ,*hateda-entity-color*)))
      ("^\\(>>\\|<<\\)$" nil ((0 . ,*hateda-quote-color*)))
      ("^\\(>|\\||<\\|>||\\|||<\\)$" nil ((0 . ,*hateda-pre-color*)))
      ("^\\(><.*\\|.*><\\)$" nil ((0 . ,*hateda-stoptag-color*)))
      ("s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+" nil ((0 . ,*hateda-autolink-color*)))
      ("\\(id\\|question\\|a\\|b\\|d\\|f\\|g\\|idea\\|i\\|r\\|graph\\|map\\|isbn\\|asin\\|jan\\|ean\\):\\([^\"' \t]+\\)"
       nil ((1 . ,*hateda-bold-color*)
            (2 . ,*hateda-autolink-color*)))
      ("\\[\\[\\(.+\\)\\]\\]" nil ((1 . ,*hateda-autolink-color*)))
      ("\\[\\(keyword\\|d\\|b\\|search\\):\\(.+\\)\\]"  nil ((1 . ,*hateda-bold-color*)
                                                                     (2 . ,*hateda-autolink-color*)))
      )))
  (setq regexp-keyword-list hateda-regexp-keyword-list)
  (setq comment-start "<!--")
  (setq comment-end "-->")
  (setq comment-start-skip "<!--[ \t]*")
  (use-keymap *hateda-mode-map*)
  (run-hooks '*hateda-mode-hook*))



(defun hateda-build-summary-of-documents ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "^\\*\\{1,3\\}.+$" :regexp t :tail t)
        (push (list (current-line-number) (match-string 0)) result)))
      (sort result #'< :key #'car)))


(defun hateda-list ()
  (interactive)
  (hateda-add-prefix "-"))

(defun hateda-num-list ()
  (interactive)
  (hateda-add-prefix "+"))

(defun hateda-heading ()
  (interactive)
  (hateda-add-prefix "*"))

(defun hateda-add-prefix (prefix)
  (cond ((pre-selection-p)
         (hateda-add-prefix-selection prefix))
        (*hateda-edit-with-region*
           (hateda-add-prefix-region prefix))
        (*hateda-edit-with-line*
           (hateda-add-prefix-line prefix))))

(defun hateda-add-prefix-region (prefix)
  (let ((start (mark))
        (end (point)))
    (when (and (numberp start) (numberp end))
      (rotatef *quotation-prefix* prefix)
      (quote-region start end)
      (rotatef *quotation-prefix* prefix))
    ))

(defun hateda-add-prefix-selection (prefix)
    (selection-start-end (start end)
      (save-excursion
        (rotatef *quotation-prefix* prefix)
        (quote-region start end)
        (rotatef *quotation-prefix* prefix))))

(defun hateda-add-prefix-line (prefix)
  (save-excursion (goto-bol) (insert prefix)))

(defun hateda-quote ()
  (interactive)
  (hateda-box-in ">>" "<<"))

(defun hateda-pre ()
  (interactive)
  (hateda-box-in ">|" "|<"))

(defun hateda-super-pre ()
  (interactive)
  (hateda-box-in ">||" "||<"))

(defun hateda-box-in (st ed)
  (cond ((pre-selection-p)
         (hateda-box-in-selection st ed))
        (*hateda-edit-with-region*
           (hateda-box-in-region st ed))
        (*hateda-edit-with-line*
           (hateda-box-in-line st ed))))

(defun hateda-box-in-selection (st ed)
  (selection-start-end (from to)
    (save-excursion
      (when (> from to) (rotatef from to))
      (goto-char from) (hateda-insert-bol st)
      (goto-char to) (hateda-insert-eol ed)
      )))

(defun hateda-box-in-region (st ed)
  (let ((start (mark))
        (end (point)))
    (when (and (numberp start) (numberp end))
      (goto-char from) (hateda-insert-bol st)
      (goto-char to) (hateda-insert-eol ed)
      )))

(defun hateda-box-in-line (st ed)
  (save-excursion
     (hateda-insert-bol st) (hateda-insert-eol ed)
    ))

(defun hateda-insert-bol (str)
  (unless (bolp) (goto-bol))
  (insert str)
  (newline))

(defun hateda-insert-eol (str)
  (unless (eolp) (goto-eol))
  (newline)
  (insert str))





(defun hw ()
  "Make Today's Hateda File"
  (interactive)
  (let (fname dir usr)
	(if (and (or (and *hatedara-multi-accounts*
					  (setf dir (setq usr(hatedara-get-dir-by-usr
								 (completing-read "ユーザ名: " (mapcar 'car *hatedara-multi-accounts*)
												  :default (caar *hatedara-multi-accounts*)
												  ))))
					  dir)
				 (setf dir (read-directory-name "はてダラフォルダ: ")))
			 (file-exist-p dir))
		(progn(hatedara-make-file dir)(hatedaro-data-read usr))
	  (message "はてダラフォルダを設定してください"))))


;; (defun hatedara-get-dir-by-usr (usr)
;;   (dolist (item *hatedara-multi-accounts*)
;;     (if (equal usr (car item))
;;         (return (third item)))))
(defun hatedara-get-dir-by-usr (usr)
  (caddar(member usr *hatedara-multi-accounts* :test 'equal :key 'car)))

(defun hatedara-make-file (dir)
  (let ((fname (merge-pathnames (format-date-string "%Y-%m-%d.txt") dir)))
	(find-file fname)
	(hateda-mode)))


(defun hatedara-submit ()
  "Exec Hatena Diary Writer"
  (interactive)
  (let* ((nowdir (directory-namestring (get-buffer-file-name)))
         (id (hatedara-get-account nowdir)))
    (unless id (error "アカウントが不正です"))
    (if (yes-or-no-p (concat "id:" (first (car id)) " ではてダラを実行します\n" nowdir))
        (let* ((lst (car id))
              (user (first lst))
              (pass (second lst))
              (dir (third lst))
			   (arg (fourth lst)))
          (call-hatedara dir user pass arg)
          (message "はてダラを実行しました"))
      (message (concat "はてダラは実行されませんでした" (first (car id)))))
    ))

(defun hatedara-submit-this (&optional chottosita)
  (interactive)
  (let* ((dir (directory-namestring (get-buffer-file-name)))
         (id (hatedara-get-account dir))
         (unless id (error "アカウントが不正です"))
         (send (concat " -f " (get-buffer-file-name)
                       (and chottosita " -t"))))
    (unless id (error "アカウントが不正です"))
    (if (yes-or-no-p (concat "id:" (first (car id)) " で現在のファイルを投稿します\n" dir))
        (let* ((lst (car id))
               (user (first lst))
               (pass (second lst))
               (dir (third lst))
			   (arg (concat (fourth lst) send)))
          (call-hatedara dir user pass arg)
		  (message "現在のファイルを投稿しました"))
      (message "はてダラは実行されませんでした"))
	))

;;(defun call-hatedara (dir user pass arg)
(defun call-hatedara (dir account pass arg)
  (let ((encoding (buffer-fileio-encoding))
        (win (selected-window)) group user)
    (set-buffer-fileio-encoding *encoding-utf8*)
    (set-buffer-modified-p t)
    (hatedara-save-data t)
    (run-hooks *hatedara-submit-hook*)
    (multiple-value-bind (group user)
        (hatedara-parse-account account)
      (execute-subprocess
         (concat
            "perl" " " (merge-pathnames "hw.pl" dir)
            (if group (concat " -g " group) "")
            " -u " user " -p " pass " " arg)))
    (run-hooks *hatedara-after-submit-hook*)
    (if win (set-window win))
    (set-buffer-fileio-encoding encoding)
;    (set-buffer-modified-p t)
    (save-buffer)))

(defun hatedara-get-account (&optional dir)
  (let ((id (hatedara-get-account-by-dir dir)))
    (unless (hatedara-check-account id)
      (setf id (hatedara-account-config dir)))
    (setf *debug* id)
    (unless id (error "アカウントが取得できません"))
    (unless (hatedara-check-account id)
      (error "アカウントが不正です"))
    id))


(defun hatedara-account-config (&optional dir)
  (setf dir  (read-directory-name "directory: " :default dir))
  (let ((id (hatedara-get-account-by-dir dir))
		user pass lst)
	(when id
	  (setf user (first (car id))
			pass (second (car id))
			dir  (third (car id))))
	(unless (file-exist-p dir)
	  (error "存在しないディレクトリです")
	  ;;(return nil)
	  (quit)
	  )
	(setf user (read-string "username: " :default user))
	(setf pass (read-string "password: " :default pass))
	(if id
		(progn (pop (car id)) (push user (car id))
		  (pop (cdar id)) (push pass (cdar id))
		  (pop (cddar id)) (push dir (cddar id)))
	  (progn
		(pushnew (list user pass dir nil) *hatedara-multi-accounts*)))
	(hatedara-get-account-by-dir dir)))

(defun hatedara-check-account (id)
  (let ((lst (car id)))
    (and (listp lst) (>= (length lst) 3)
         (stringp (first lst)) (stringp (second lst)) (file-exist-p (third lst)) lst)))


;; (defun hatedara-get-account-by-dir (dir)
;;   (let ((pt *hatedara-multi-accounts*))
;;     (while pt
;;       (if (path-equal dir (caddar pt))
;;           (return pt))
;;   (setf pt (cdr pt)) nil)
;;   ))
(defun hatedara-get-account-by-dir (dir)
  (member dir *hatedara-multi-accounts* :test 'path-equal :key 'caddr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 閲覧用のモード
(defun hatedara-now-buffer-data(&optional post)
  (save-excursion
	(goto-char(point-min))
	(let*((fp (get-buffer-file-name))
		  (fwt (file-write-time fp))
		  (pn (pathname-name fp))
		  (pnl (split-string pn #\-))
		  (y (parse-integer(car pnl)))
		  (m (parse-integer(cadr pnl)))
		  (d (parse-integer(caddr pnl)))
		  (unvt (encode-universal-time 0 0 0 d m y))
		  (data (list
				 (list(buffer-substring
					   (progn(goto-bol)(point))
					   (progn(goto-eol)(point)))
					  unvt fwt fp pn post(point)
					  ))))
	  (while(scan-buffer "^\\(\\*.*\\)" :regexp t :no-dup t)
		(push
		 (list (match-string 0)
			   unvt fwt fp pn post
			   (match-beginning 0))
		 data))
	  data)))


(defvar *hatedara-data* nil)
(defvar *hw-data-file* ".hatedara" )
(defvar *hw-summary-buffer* "*hwS*")
(defvar *hw-view-buffer* "*hwV*")


;save
(defun hatedara-save-data(&optional post)
  (let(r (now (hatedara-now-buffer-data post)))
	(dolist (x *hatedara-data*(setq *hatedara-data* r))
	  (unless(equal(nth 3 (car now)) (nth 3 (car x)) )
		(push x r)))
	(with-open-file (f (merge-pathnames *hw-data-file*
										(directory-namestring
										 (get-buffer-file-name)))
					   :direction :output
					   :if-exists :overwrite
					   :if-does-not-exist :create)
	  (format f "~S" (push now hw::*hatedara-data*)
			  ))
	))

(defun hatedara-no-submit-save-data()
  (and(eq buffer-mode 'hateda-mode)(hatedara-save-data)))

(add-hook '*after-save-buffer-hook* 'hw::hatedara-no-submit-save-data)
;hw-summary
(defun hatedaro-data-read(usr)
  (let(a b)
	(with-open-file (f (merge-pathnames *hw-data-file*
										(hatedara-get-dir-by-usr usr))
					   :direction :input
					   :if-exists :overwrite
					   :if-does-not-exist :create)
	  (cond((setq a (read f nil))
			(setq *hatedara-data* a))
		   (t (setq *hatedara-data* '(nil)))))
	a))

(setq *hw-file*(make-hash-table :test 'equal))
(defun hws()
  (interactive)
  (let((dt(hatedaro-data-read
		   (completing-read "User: "
							(mapcar 'car *hatedara-multi-accounts*)
							:default (caar *hatedara-multi-accounts*)
							)))
	   (current (selected-buffer))
	   buf re r)
	(dolist (x dt re)
	  (dolist(y x r)
		(push (list(if (nth 5 y) 0 1)
				   (format-date-string "%Y-%m-%d (%a)"(nth 1 y))
				   (nth 0 y)
				   (format-date-string "%y-%m-%d (%a)%H:%M:%S"(nth 2 y))) r)))
	(and(find-buffer *hw-summary-buffer*)(delete-buffer *hw-summary-buffer*))
	(setq buf (get-buffer-create *hw-summary-buffer*))
	(set-buffer buf)
	(insert
	 (format nil "~{~{~&~[@~:;~~~] ~@20,,,' A~@80,,,' A(Last Modified:~A)~%~}~}" r))
	(goto-char(point-min))
	(hw-summary-mode)
	(set-buffer current)
	(pop-to-buffer buf t)
	;;(other-window)
	(dolist(x *hatedara-data*)
	  (dolist (y x )
		(setf (gethash(nth 4 y) *hw-file*)(nth 3 y) )))
	))

(defun hw-summary-mode()
  (setq mode-name "hws")
  (setq buffer-mode 'hw-summary-mode)
  (make-local-variable 'need-not-save)
  (make-local-variable 'auto-save)
  (make-local-variable 'buffer-read-only)
  (set-buffer-modified-p nil)
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq auto-save nil)
  (use-keymap *hw-summary-mode-map*)
  (set-local-window-flags
   (selected-buffer)
   (+ *window-flag-line-number*
	  *window-flag-tab* *window-flag-newline*
	  *window-flag-hscroll-bar* *window-flag-eof*
	  *window-flag-fold-line* *window-flag-fold-mark*
	  ) nil)
  (set-buffer-fold-type-none))

(defun hwv(&optional file)
  (interactive "P")
  (when(eq(buffer-name(selected-buffer)) *hw-summary-buffer*)
	(let((line (save-excursion
				 (buffer-substring
				  (progn(goto-bol)(point))
				  (progn(goto-eol)(point)))))
		 (current (selected-buffer))
		 day buf path)
	  (setq day(nth 1(split-string line #\SPC)))
	  (setq path (gethash day *hw-file*))
	  (cond(file (other-window)(find-file path)(hateda-mode))
		   (t(and(find-buffer *hw-view-buffer*)(delete-buffer *hw-view-buffer*))
			 (setq buf (get-buffer-create *hw-view-buffer*))
			 ;;(other-window)
			 (set-buffer buf)
			 (and path (insert-file-contents path))
			 (hw-summary-mode)
			 (set-buffer current)
			 (pop-to-buffer buf t)
			 (other-window)
			 )))))

(defun hwv-next-line()
  (interactive)
  (forward-line 1)(hwv))

(defun hwv-previous-line()
  (interactive)
  (forward-line -1)(hwv))
(defun hw-close()
  (interactive)
  (and
   (find-buffer *hw-summary-buffer*)(delete-buffer *hw-summary-buffer*)
   (find-buffer *hw-view-buffer*)(delete-buffer *hw-view-buffer*))
  (delete-other-windows))
(defun hwv-scroll-up()
  (interactive)
  (scroll-other-window (window-height)))
(defun hwv-scroll-down()
  (interactive)
  (scroll-up-other-window (window-height)))

(defvar *hw-summary-mode-map* nil)
(unless *hw-summary-mode-map*
  (setq *hw-summary-mode-map* (make-sparse-keymap))
  (define-key *hw-summary-mode-map* #\RET 'hwv)
  (define-key *hw-summary-mode-map* #\SPC 'hwv-scroll-down)
  (define-key *hw-summary-mode-map* #\C-h 'hwv-scroll-up)
  (define-key *hw-summary-mode-map* #\q 'hw-close)
  (define-key *hw-summary-mode-map* #\C-p 'hwv-previous-line)
  (define-key *hw-summary-mode-map* #\Up 'hwv-previous-line)
  (define-key *hw-summary-mode-map* #\C-n 'hwv-next-line)
  (define-key *hw-summary-mode-map* #\Down 'hwv-next-line)
  )

(defun hatedara-parse-account (account)
  (if (string-matchp "g:\\([a-zA-Z0-9_]+\\):\\([a-zA-Z0-9_]+\\)" account)
      (values (match-string 1) (match-string 2))
    (values nil account)))




;; NYSL Version 0.9982
;;
;; A. 本ソフトウェアは Everyone'sWare です。このソフトを手にした一人一人が、
;;    ご自分の作ったものを扱うのと同じように、自由に利用することが出来ます。
;;
;;   A-1. フリーウェアです。作者からは使用料等を要求しません。
;;   A-2. 有料無料や媒体の如何を問わず、自由に転載・再配布できます。
;;   A-3. いかなる種類の 改変・他プログラムでの利用 を行っても構いません。
;;   A-4. 変更したものや部分的に使用したものは、あなたのものになります。
;;        公開する場合は、あなたの名前の下で行って下さい。
;;
;; B. このソフトを利用することによって生じた損害等について、作者は
;;    責任を負わないものとします。各自の責任においてご利用下さい。
;;
;; C. 著作者人格権はoosawaに帰属します。著作権は放棄します。
;;
;; D. 以上の３項は、ソース・実行バイナリの双方に適用されます。
