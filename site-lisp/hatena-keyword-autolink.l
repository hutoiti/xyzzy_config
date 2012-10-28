;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: hatena-keyword-autolink.l,v 1.8 2006/02/15 15:14:13 torihat Exp $
;
; hatena-keyword-autolink.l
;
; by HATTORI Masashi
;
;■ hatena-keyword-autolink.l とは？
;
;	・任意のテキストのはてなキーワード部分をはてなダイアリーキーワード自動リンクAPIを
;	　利用して自動的にリンクに変換します。
;
;		▼はてなダイアリーキーワード自動リンクAPI
;		http://d.hatena.ne.jp/keyword/%a4%cf%a4%c6%a4%ca%a5%c0%a5%a4%a5%a2%a5%ea%a1%bc%a5%ad%a1%bc%a5%ef%a1%bc%a5%c9%bc%ab%c6%b0%a5%ea%a5%f3%a5%afAPI
;
;	・任意のキーワードのはてなダイアリーの関連キーワードを返します。
;
;		▼はてなダイアリーキーワード連想語API
;		http://d.hatena.ne.jp/keyword/%a4%cf%a4%c6%a4%ca%a5%c0%a5%a4%a5%a2%a5%ea%a1%bc%a5%ad%a1%bc%a5%ef%a1%bc%a5%c9%cf%a2%c1%db%b8%ecAPI
;
;■ 動作環境
;
;	xyzzy-0.2.2.235 以降のみ動作確認しています。
;
;	以下の拡張が必要です。別途インストールしてください。
;		- xml-rpc-modoki
;
;■ インストール
;
;    1. ファイルの展開
;
;	配布アーカイブを system-root 以下に展開してください。
;
;    2. ~/.xyzzy などに設定
;
;	(autoload 'hatena-keyword-autolink "hatena-keyword-autolink" t)
;	(autoload 'hatena-keyword-autolink-selection "hatena-keyword-autolink" t)
;	NetInstaller経由でインストールして ni-autoload を利用している場合には必要ありません。
;
;    3. 動かし方
;
;	M-x hatena-keyword-autolink		リージョンのテキストを変換
;	M-x hatena-keyword-autolink-selection	セレクションのテキストを変換
;
;■ オプション設定
;
;	ed::*hatena-keyword-autolink-score*		scoreの指定
;	ed::*hatena-keyword-autolink-cname*		cnameの指定
;	ed::*hatena-keyword-autolink-a_target*		Aタグのtarget属性値指定
;	ed::*hatena-keyword-autolink-a_class*		Aタグのclass属性値指定
;
;■ その他関数
;
;	ed::hatena-keyword-autolink-convert		テキストを変換して返す
;	ed::hatena-get-similar-word			関連キーワードリストを返す
;
;■ Changelog
;
;	[2006/02/16]	「はてなダイアリーキーワード連想語API」を実装。
;
;	[2006/01/17]	オプション設定方法を変更
;
;	[2006/01/11] 	初版
;
;■ License
;
; hatena-keyword-autolink.l
;
; Copyright (C) 2006 Masashi Hattori
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in
;    the documentation and/or other materials provided with the
;    distribution.
; 
; 3. The name of the author may not be used to endorse or promote
;    products derived from this software without specific prior
;    written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE!
; POSSIBILITY OF SUCH DAMAGE.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "hatena-keyword-autolink")

(in-package "editor")

(defvar *hatena-keyword-autolink-endpoint* "http://d.hatena.ne.jp/xmlrpc")
(defvar *hatena-keyword-autolink-score* nil)    ; 0-50
(defvar *hatena-keyword-autolink-cname* nil)    ; 
(defvar *hatena-keyword-autolink-a_target* nil) ; 
(defvar *hatena-keyword-autolink-a_class* nil)  ; 

(defun hatena-setKeywordLink (endpoint body &key score cname a_target a_class)
  (let (req
	(parameters (list (list "body" body 'xmlrpcm::string)))
	response)
    (when score
      (push (list "score" score 'xmlrpcm::int) parameters))
    (when cname
      (push (list "cname" cname 'xmlrpcm::array) parameters))
    (when a_target
      (push (list "a_target" a_target 'xmlrpcm::string) parameters))
    (when a_class
      (push (list "a_class" a_class 'xmlrpcm::string) parameters))
    (setq req (list "hatena.setKeywordLink "
		    (list nil parameters 'xmlrpcm::struct)
		    ))
    (setq response (xmlrpcm::xmlrpcm-send-request endpoint req))
    (xmlrpcm::xmlrpcm-param-value (car response))))

(defun hatena-getSimilarWord (endpoint wordlist)
  (let ((req (list "hatena.getSimilarWord"
		   (list nil
			 (list (list "wordlist"
				     (mapcar #'(lambda (x)
						 (list nil x 'xmlrpcm::string))
					     wordlist)
				     'xmlrpcm::array))
			 'xmlrpcm::struct)))
	response
	array)
    (setq response (xmlrpcm::xmlrpcm-send-request endpoint req))
    (setq array (xmlrpcm::xmlrpcm-param-value (car (xmlrpcm::xmlrpcm-param-value (car response)))))
    (mapcar #'(lambda (x)
		(xmlrpcm::xmlrpcm-param-value (car (xmlrpcm::xmlrpcm-param-value x))))
	    array)))

(defun hatena-get-similar-word (wordlist)
  (hatena-getSimilarWord *hatena-keyword-autolink-endpoint*
			 wordlist))

(defun hatena-keyword-autolink-convert (str &key score cname a_target a_class)
  (hatena-setKeywordLink *hatena-keyword-autolink-endpoint*
			 str
			 :score    score
			 :cname    cname
			 :a_target a_target
			 :a_class  a_class))

(defun user::hatena-keyword-autolink (beg end &key score cname a_target a_class)
  (interactive "r")
  (let ((before (buffer-substring beg end))
	after)
    (when (and (< 0 (length before))
	       (setq after
		     (hatena-keyword-autolink-convert before
						      :score (or score *hatena-keyword-autolink-score*)
						      :cname (or cname *hatena-keyword-autolink-cname*)
						      :a_target (or a_target *hatena-keyword-autolink-a_target*)
						      :a_class  (or a_class  *hatena-keyword-autolink-a_class*)
						      )))
      (save-excursion
	(goto-char beg)
	(delete-region beg end)
	(insert after)))))

(defun user::hatena-keyword-autolink-selection (&key score cname a_target a_class)
  (interactive)
  (selection-start-end (beg end)
    (user::hatena-keyword-autolink beg
				   end
				   :score    (or score *hatena-keyword-autolink-score*)
				   :cname    (or cname *hatena-keyword-autolink-cname*)
				   :a_target (or a_target *hatena-keyword-autolink-a_target*)
				   :a_class  (or a_class  *hatena-keyword-autolink-a_class*)
				   )))
