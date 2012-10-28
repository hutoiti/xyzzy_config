;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; quote-menu.l
;;;

;;;
;;; $HeadURL: file:///g:/repo/xyzzy/site-lisp/quote-menu/tags/release/0.0.0.2/quote-menu.l $
;;;
;;; $LastChangedDate: 2004-05-23 13:05:29 +0900 (Sun, 23 May 2004) $
;;;
;;; $LastChangedRevision: 16 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; Install and Settings
;;;
;;;   NetInstaller 以外でインストールした場合
;;;
;;;     ~/.xyzzy もしくは siteinit.l に
;;;
;;;       (require "quote-menu/quote-menu")
;;;
;;;     と追加して保存、xyzzy も再起動させる。
;;;     siteinit.l に追加した場合は、ダンプファイルを
;;;     作り直す。
;;;

;;;
;;; Options
;;;
;;;   *quote-string-list*
;;;     引用符のリスト。リストの先頭にある文字列が
;;;     デフォルトで使われます
;;;
;;;   *quote-use-customize-menu*
;;;     メニューの「編集(E)」を拡張して、項目を追加するかどうか。
;;;     デフォルトで使われます
;;;
;;;   *quote-use-customize-icon*
;;;     標準メニューのツールバーを拡張するかどうか。
;;;     デフォルトでは使いません。使う場合は、自分で
;;;     アイコンファイルを準備しなければなりません
;;;
;;;   *quote-tool-bar-icon-file*
;;;     ツールバーを拡張した場合のアイコンファイルの名前。
;;;     自分で作ったアイコンファイルは(etc-path)のディレクトリ
;;;     以下に置いてください。
;;;
;;;   これらの設定は、(require "quote-menu")の前に設定してください。
;;;
;;;   例
;;;     (setq ed::*quote-use-customize-icon* t)
;;;     (setq ed::*quote-tool-bar-icon-file* "toolbar_test.bmp")
;;;     (require "quote-menu")
;;;     ;; これはrequireの後でも可
;;;     (setq ed::*quote-use-customize-menu* t)
;;;     ;; 文字列の設定が1つの場合でもリストにしてください
;;;     (setq ed::*quote-string-list* '(">> " "| "))
;;;

;;;
;;; 標準メニューのアイコンファイルの作り方
;;;
;;;   01. (etc-path)にある、"toolbar.bmp"を別名でコピーする。
;;;   02. 画像編集ソフトでコピーしたファイルを開く。
;;;   03. 画像のサイズを変更する。toolbar.bmpの横幅が
;;;       1264ピクセルなので、追加するアイコンの数に
;;;       16を掛けた数だけ幅を広げる。
;;;   04. 広げた場所にアイコンを作成する。アイコンのサイズは
;;;       16x16ピクセル以内に収まるように作成する。
;;;   05. 16色のBMPファイルとして保存する。
;;;
;;;   GIMPを使った簡単な作り方が
;;;     http://www5d.biglobe.ne.jp/~lostland/ndiary/topics/200405_2.html#d22_t3
;;;   にありますので、分からなかった場合はそちらを参照してください。
;;;

;;;
;;; code
;;;

(provide "quote-menu")

(in-package "editor")

(export '(insert-quote-string-to-selection
          delete-quote-string-from-selection
          add-quote-string-to-clipboard-data
          copy-to-clipboard-with-quote-string
          ))
          
(defvar *quote-string-list* '(">" "| "))
(defvar *quote-use-customize-menu* t)
(defvar *quote-use-customize-icon* nil)
(defvar *quote-tool-bar-icon-file* nil)

(defun insert-quote-string-to-selection (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (save-excursion
      (save-restriction
        (narrow-to-region (selection-mark) (selection-point))
        (goto-char (point-min))
        (loop
          (goto-bol)
          (insert (nth (1- type) *quote-string-list*) arg)
          (when (eql (point-max) (progn (goto-eol) (point)))
            (return))
          (forward-line 1))))))

(defun delete-quote-string-from-selection (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (save-excursion
      (save-restriction
        (narrow-to-region (selection-mark) (selection-point))
        (goto-char (point-min))
        (loop
          (do ((i 0 (1+ i)))
              ((= i arg))
            (goto-bol)
            (when (looking-at (format nil "^~A" (nth (1- type) *quote-string-list*)))
              (delete-char (length (nth (1- type) *quote-string-list*))))
            )
          (when (eql (point-max) (progn (goto-eol) (point)))
            (return))
          (forward-line 1))))))

(defun add-quote-string-to-clipboard-data (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (let ((replace-pattern "\n"))
    (insert
    (substitute-string
       (format nil "~A~A"
         (progn
           (let ((result nil))
             (dolist
              (i
                 (make-sequence 'list arg
                                :initial-element
                                (nth (1- type) *quote-string-list*)) result)
               (setq result (concat result i)))))
               (get-clipboard-data))
       "\n" (dotimes (tmp arg replace-pattern)
              (setq replace-pattern
              (format nil "~A~A"
                      replace-pattern
                      (nth (1- type) *quote-string-list*))))))))

(defun copy-to-clipboard-with-quote-string (&optional (arg 1) (type 1))
  (interactive)
  (when *prefix-args*
    (setq arg *prefix-value*))
  (when (pre-selection-p)
    (let ((replace-pattern "\n"))
      (copy-to-clipboard
         (format nil "~A~A"
         (progn
           (let ((result nil))
             (dolist
              (i
                 (make-sequence 'list arg
                                :initial-element
                                (nth (1- type) *quote-string-list*)) result)
               (setq result (concat result i)))))
         (substitute-string
            (buffer-substring (selection-mark) (selection-point))
            "\n" (dotimes (tmp arg replace-pattern)
            (setq replace-pattern
                  (format nil "~A~A"
                          replace-pattern
                          (nth (1- type) *quote-string-list*))))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun quote-menu-init ()
  (when *quote-use-customize-menu*
    (add-popup-menu *app-popup-menu*
                    (define-popup-menu
                      (:item 'add-quote "選択範囲の行頭に引用を付加"
                       'insert-quote-string-to-selection :selection)
                      (:item nil "選択範囲の行頭にある引用文字の除去"
                       'delete-quote-string-from-selection :selection)
                      ) "拡張めにう")
    (add-menu-separator (get-menu *app-menu* 1 t))
    (add-popup-menu (get-menu *app-menu* 1 t)
                    (define-popup-menu
                      (:item 'add-quote "選択範囲の行頭に引用を付加"
                       'insert-quote-string-to-selection :selection)
                      (:item nil "選択範囲の行頭にある引用文字の除去"
                       'delete-quote-string-from-selection :selection)
                      ) "拡張めにう")
    (unless (get-menu-position (get-menu *app-menu* 1 t) 'ext-copy-1)
      (insert-menu-item
         (get-menu *app-menu* 1 t) 5 'ext-copy-1
         "引用つきコピー" 'copy-to-clipboard-with-quote-string :selection))
    (unless (get-menu-position (get-menu *app-menu* 1 t) 'ext-paste-1)
      (insert-menu-item
         (get-menu *app-menu* 1 t) 8 'ext-paste-1
         "引用つき貼り付け" 'add-quote-string-to-clipboard-data :clipboard))
    (unless (get-menu-position *app-popup-menu* 'quote-copy)
      (insert-menu-item *app-popup-menu* 2 'quote-copy
                        "引用つきコピー"
                        'copy-to-clipboard-with-quote-string :selection))
    (unless (get-menu-position *app-popup-menu* 'quote-paste)
      (insert-menu-item *app-popup-menu* 5 'quote-paste
                        "引用つき貼り付け"
                        'add-quote-string-to-clipboard-data :clipboard))
    )
  )

(if (and *quote-use-customize-menu*
         *app-menu*)
    (quote-menu-init)
  (add-hook '*init-app-menus-hook* 'quote-menu-init))

(when *quote-use-customize-icon*
  (defun std-tool-bar ()
    (create-tool-bar
       'std-tool-bar
       (merge-pathnames *quote-tool-bar-icon-file* (etc-path))
       '(("新規作成" 24 new-file)
         ("開く" 22 open-file-dialog)
         ("上書き保存" 20 save-buffer-dialog :modified)
         ("全て保存" 75 save-all-buffers)
         :sep
         ("印刷" 29 print-selected-buffer-dialog)
         :sep
         ("切り取り" 7 kill-selection-to-clipboard :modify-any-selection)
         ("コピー" 9 copy-selection-to-clipboard :any-selection)
         ("引用つきコピー" 79 copy-to-clipboard-with-quote-string :any-selection)
         ("貼り付け" 2 paste-from-clipboard :clipboard)
         ("引用つき貼付" 80 add-quote-string-to-clipboard-data :clipboard)
         :sep
         ("元に戻す" 0 undo :undo)
         ("やっぱり元に戻さない" 1 redo :redo)
         :sep
         ("検索" 5 search-dialog)
         ("前を検索" 3 repeat-backward-search tool-bar-update-search)
         ("次を検索" 4 repeat-forward-search tool-bar-update-search)
         :sep
         ("grep" 74 grep-dialog)
         :sep
         ("折り返さない" 76
          set-buffer-fold-type-none set-buffer-fold-type-none-update)
         ("指定位置で折り返す" 77
          set-buffer-fold-type-column set-buffer-fold-type-column-update)
         ("ｳｨﾝﾄﾞｳ幅で折り返す" 78
          set-buffer-fold-type-window set-buffer-fold-type-window-update)
         )))
  )
