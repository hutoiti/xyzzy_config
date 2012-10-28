;; -*- Mode: Lisp; Package: EDITOR -*-
#|

Description:

・カーソル直下の単語を色づけします。
・highlight-regexp.el や hi-lock.el に似た機能
・カレントバッファに関係ありそうなバッファも色づけします。


Installation:
~/.xyzzy または $XYZZY/site-lisp/siteinit.l に
以下のコードを追加します。

(require "highlight")
;;キーバインドはお好みで
;(global-set-key '(#\C-c #\h #\w) 'highlight-current-word)
;(global-set-key '(#\C-c #\h #\r) 'highlight-regexp)
;(global-set-key '(#\C-c #\h #\c) 'highlight-clear)


Changes:

- 2008.05.28
	* delete-text-attributes に変更

- 2008.05.24 リファクタリング
	* highlight-get-current-word を変更
	 skip-syntax-spec-forward, skip-syntax-spec-backward
	 looking-at-backwardの削除

- 2008.05.02 リファクタリング

- 2007.12.28 looking-at-backward忘れ。バグ修正。

- 2007.12.27 α版リリース


License:

    highlight.l は修正BSDライセンスに基づいて利用可能です。
    <http://www.opensource.org/licenses/bsd-license.php>


    Copyright (C) 2007, 2008  bulb.  All rights reserved.

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


Author:
  bulb (ttomise at gmail dot com)

|#

(provide "highlight")

(in-package "editor")

(export '(highlight-current-word
          highlight-regexp
          highlight-clear
          ))

(defvar *highlight-pickup-foreground-color* 7)
(defvar *highlight-pickup-background-color* 5)
(defvar *highlight-pickup-underline* nil)
(defvar *highlight-pickup-bold* nil)

(defvar *highlight-tag* 'hl)

(defun highlight-current-word ()
  (interactive)
  (let ((str (highlight-get-current-word)))
    (when str
      (highlight-pickup str))))

(defun highlight-regexp (regexp)
  (interactive "sRegexp: \np")
  (highlight-pickup regexp))

(defun highlight-get-current-word ()
  (save-excursion
    (buffer-substring
     (progn
       (skip-syntax-spec-forward "w_") (point))
     (progn
       (skip-syntax-spec-backward "w_") (point)))))


(defun highlight-pickup (regexp)
  (let ((selbuf (selected-buffer))
        (buf-ext (pathname-type (buffer-name (selected-buffer)))))
    (save-excursion
      (dolist (buf (buffer-list))
        (when (equal buf-ext (pathname-type (buffer-name buf)))
          (set-buffer buf)
          (goto-char (point-min))
          (delete-text-attributes *highlight-tag*)
           (while (scan-buffer regexp
                              :regexp t
                              :case-fold nil)
            (if (match-beginning 0)
                (progn
                  (set-text-attribute (match-beginning 0) (match-end 0)
                                      *highlight-tag*
                                      :foreground *highlight-pickup-foreground-color*
                                      :background *highlight-pickup-background-color*
                                      :underline *highlight-pickup-underline*
                                      :bold *highlight-pickup-bold*))
              (message "nil"))
            (goto-char (match-end 0))))
        ))
    (set-buffer selbuf)))


(defun highlight-clear ()
  (interactive)
  (let ((buf-ext (pathname-type (buffer-name (selected-buffer)))))
    (save-excursion
      (dolist (buf (buffer-list))
        (when (equal buf-ext (pathname-type (buffer-name buf)))
          (set-buffer buf)
          (delete-text-attributes *highlight-tag*))))))

;;; highlight.l ends here
