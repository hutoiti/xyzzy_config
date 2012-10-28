;;; funsig.l - lispモードで、カーソル位置付近の関数呼び出しのシグネチャを表示する。
;;
;; $Rev: 224 $
;;
;;
;; License
;; =======
;;
;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2005-2006 kia
;;
;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without
;; limitation the rights to use, copy, modify, merge, publish, distribute,
;; sublicense, and/or sell copies of the Software, and to permit persons to
;; whom the Software is furnished to do so, subject to the following
;; conditions:
;;
;; The above copyright notice and this permission notice shall be included
;; in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;;
;; インストール
;; ============
;;
;; funsig.lをロードパスに配置したあと、~/.xyzzyに次のように設定します。
;;
;;     (autoload 'funsig-show-signature "funsig" t)
;;     (define-key ed::*lisp-mode-map* #\C-\; 'funsig-show-signature)
;;
;; 実際にバインドするキーは適当に選んでください。
;;
;;
;; funsig.lstファイルは不要になりました
;; ------------------------------------
;;
;; 以前の版で必要だったシグネチャのリストであるfunsig.lstファイルは必須では
;; なくなりました。シグネチャリストファイルがあれば優先して参照しますが、無
;; くても動作します。不要であれば削除してください。
;;
;; またシグネチャリストファイルの位置と名前を示す変数
;; *funsig-signature-list*のデフォルト値を変更しました。以前の版では、xyzzy
;; のインストールディレクトリ内のetcディレクトリがfunsig.lstファイルのデフ
;; ォルトの位置となっていました。削除する場合は注意してください。
;;
;; ともなって、シグネチャリストを作成するために同梱していたファイルの
;; funsigmk.lとfunsigmk.lc、funsig.xslは無くなりました。ロードパスやxyzzyの
;; インストールディレクトリに残っている場合は削除してください。
;;
;;
;; 使い方
;; ======
;;
;; lisp-modeなどで使います。funsig-show-signature コマンドで、カーソル位置
;; 付近の関数名を探し、その関数に対応するシグネチャを表示します。カーソルは
;; 関数名の上にある必要はありません。カーソル位置より前方で適当な関数名を探
;; します。
;;
;; シグネチャの表示はポップアップにするかステータスエリアにするか選べます。
;; (*funsig-popup-signature*)
;;
;; funsig-add-signatureコマンドを使うと*funsig-signature-list*変数が示すフ
;; ァイルに新しいシグネチャを追加します。独自の表示を行いたいときに使ってく
;; ださい。
;;
;;
;; 連絡先
;; ======
;;
;; kia <meshinsha@yahoo.co.jp>
;; http://www.geocities.jp/kiaswebsite/

(provide "funsig")
(in-package "user")

(defvar *funsig-signature-list* "~/.funsig-list"
  "Path to the signature list file.")
(defvar *funsig-master-signature-list* (merge-pathnames "funsig.lst" (etc-path))
  "Path to the master signature list file.")
(defvar *funsig-buffer-name* " *funsig*"
  "Name of the working buffer for the signature list.")
(defvar *funsig-popup-signature* t
  "Non-nil means a message pops up around the cursor.")
(defvar *funsig-target-picker* 'funsig-picker
  "Function to pick up the target symbol.")
;廃止
;(defvar *funsig-picker-packages* '("lisp" "editor" "ed"))

(defun funsig-open-signature-list ()
  "Read the signature list file and return the buffer."
  (let ((buf (get-buffer-create *funsig-buffer-name*)))
      (erase-buffer buf)
      (setup-temp-buffer buf)
      (save-excursion
        (set-buffer buf)
        (and (file-exist-p *funsig-signature-list*)
             (insert-file-contents *funsig-signature-list*)))
    buf))

(defun funsig-add-signature (sig)
  "Add a new signature to the signature list file."
  (interactive (list (read-string "Signature: " :default (let* ((sym (funsig-picker))
                                                                (s (or (funsig-search-signature sym)
                                                                       (funsig-search-signature-from-system sym))))
                                                           (and s (string-trim "()" s))))))
  (let ((sig (string-trim " \t" (substitute-string sig "\n" " ")))
        (buf (funsig-open-signature-list)))
    (save-excursion
      (set-buffer buf)
      (goto-char (point-min))
      (insert sig #\LFD)
      (write-region (point-min) (point-max) *funsig-signature-list*))))

(defun funsig-symbol-names (symbol &optional (base-package "user"))
  (flet ((package-names (package) (cons (package-name package) (package-nicknames package))))
    (let* ((base-package (find-package base-package))
           (package (symbol-package symbol))
           (name (symbol-name symbol))
           (external (eq :external (cadr (multiple-value-list (find-symbol name package)))))
           (marker (if  external ":" "::"))
           (lst (mapcar #'(lambda (p) (format nil "~A~A~A" p marker name)) (package-names package))))
      (if (and external
               (some #'(lambda (p) (eq package p))
                     (cons base-package (package-use-list base-package))))
          (cons name lst)
        lst))))

(defun funsig-search-signature (symbol)
  (let ((names (funsig-symbol-names symbol))
        (buf (find-buffer *funsig-buffer-name*)))
    (unless buf
      (setq buf (funsig-open-signature-list)))
    (when buf
      (save-excursion
        (set-buffer buf)
        (goto-char (point-min))
        (when (scan-buffer (format nil "^\\(:?~{~A~^\\|~}\\)\\(:? \\|$\\)" (mapcar #'regexp-quote names)) :regexp t)
          (let ((pos (point)))
            (goto-eol)
            (format nil "(~A)" (buffer-substring pos (point)))))))))

(defun funsig-get-function-argument (symbol)
  (let ((def (symbol-function symbol)))
    (if (si:*builtin-function-p def)
        (get symbol 'si::builtin-function-argument)
      (let* ((def (if (si:*closurep def) (si:closure-body def) def))
             (head (safe-car def)))
        (when (or (eq head 'lambda) (eq head 'macro))
          (safe-cadr def))))))

(defun funsig-search-signature-from-system (symbol)
  (when (fboundp symbol)
    (let* ((args (funsig-get-function-argument symbol))
           (package (symbol-package symbol))
           (*package* package))
      (if (stringp args)
          (if (zerop (length args))
              (format nil "(~s)" symbol)
            (format nil "(~s ~a)" symbol args))
        (with-output-to-string (out)
          (format out "(~s" symbol)
          (labels ((print-sexp (sexp)
                     (cond ((null sexp)
                            (princ "()" out))
                           ((listp sexp)
                            (cond ((eq (car sexp) 'quote)
                                   (princ "'" out)
                                   (print-sexp (cadr sexp)))
                                  ((eq (car sexp) 'function)
                                   (princ "#'" out)
                                   (print-sexp (cadr sexp)))
                                  (t
                                   (print-list sexp "(")
                                   (princ ")" out))))
                           ((member sexp lambda-list-keywords)
                            (format out "~a" sexp))
                           ((keywordp sexp)
                            (format out ":~a" sexp))
                           (t
                            (format out "~:@(~a~)" sexp))))
                   (print-list (args prefix)
                     (dolist (arg args)
                       (princ prefix out)
                       (print-sexp arg)
                       (setq prefix " "))))
            (print-list args " ")
            (princ ")" out)))))))

(defun funsig-message-signature (symbol)
  (let ((sig (or (funsig-search-signature symbol)
                 (funsig-search-signature-from-system symbol))))
    (when sig
      (if *funsig-popup-signature*
          (popup-string sig (point))
        (message sig)))))

(defun funsig-scan-open-paren ()
  (while (scan-buffer "(" :reverse t)
    (or (parse-point-syntax) (return t))
    (and (<= (point) (point-min)) (return))
    (forward-char -1)))

(defun funsig-point-matched-paren ()
  (save-excursion
    (when (goto-matched-parenthesis)
      (point))))

(defun funsig-picker-start ()
  (let ((p (point)))
    (save-excursion
      (while (funsig-scan-open-paren)
        (when (<= p (or (funsig-point-matched-paren) (point-max)))
          (goto-char (1+ (point)))
          (return (if (looking-at "\\([A-Za-z0-9\-]+\\)::?") ; "\\([^:\\_S\n]+\\)::?"
                      (values (match-end 0) (match-string 1))
                    (values (point) nil))))
        (and (<= (point) (point-min)) (return))
        (forward-char -1)))))

(defun funsig-picker ()
  (multiple-value-bind (start package) (funsig-picker-start)
    (let ((name (when start
                  (let ((end (save-excursion
                               (goto-char start)
                               (skip-syntax-spec-forward "w_")
                               (point))))
                    (when (< start end)
                      (buffer-substring start end))))))
      (when name
        (find-symbol name (or package *buffer-package* "user"))))))

(defun funsig-apply (fn)
  (let ((target (funcall *funsig-target-picker*)))
    (and target
         (funcall fn target))))

(defun funsig-show-signature ()
  "Show the signature of the function around the cursor."
  (interactive)
  (funsig-apply #'funsig-message-signature))

;; funsig.l ends here.
