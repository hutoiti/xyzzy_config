;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: xml-parser-modoki.l 819 2009-05-14 03:23:27Z torihat $
;
; xml-parser-modoki.l
;
; ■ ChangeLog
;
;	[2009/05/13]
;	・xmlpm-write-xmlのデフォルトを*encoding-utf8*から*encoding-utf8n*に変更
;
;	[2009/03/01]
;	・yamamotoさんから頂いた16進表記の文字参照に対応するパッチを取り込み (__)
;
;	[2008/02/04]
;	・xmlpm-decode-special-charsで落ちる場合があったのを修正
;
;	[2006/01/15]
;	・XML出力時にアポストロフィを変換しないように
;	・XML出力時のencoding設定
;
;	[2006/01/12]
;	・XML出力
;
; ■ License
;
; Copyright (C) 2003-2006 Masashi Hattori
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

(require "encoding")

(provide "xml-parser-modoki")

(setf (get 'xmlpm-interval-message 'lisp-indent-hook) 1)

(in-package "editor")

(export '(*xmlpm-tag-options-regexp*
	  *xmlpm-special-chars-alist*
	  *xmlpm-show-status-message*
	  xmlpm-parse
	  xmlpm-parse-file))

(defvar *xmlpm-tag-options-regexp*
  (compile-regexp
   "\\([^ \t\n\r=]*\\)[ \t\n\r]*=[ \t\n\r]*\\(\\(\"\\([^\"]*\\)\"\\)\\|\\('\\([^']*\\)'\\)\\)"))

(defvar *xmlpm-special-chars-alist*
  '(
    ("&lt;" . "<")
    ("&gt;" . ">")
    ;("&apos;" . "'")
    ("&quot;" . "\"")
    ("&amp;" . "&")
    ))

(defvar *xmlpm-character-entity-alist*
  '(
    ("&quot;" . 34)
    ("&amp;" . 38)
    ("&apos;" . 39)
    ("&lt;" . 60)
    ("&gt;" . 62)
    ("&nbsp;" . 160)
    ("&iexcl;" . 161)
    ("&cent;" . 162)
    ("&pound;" . 163)
    ("&curren;" . 164)
    ("&yen;" . 165)
    ("&brvbar;" . 166)
    ("&sect;" . 167)
    ("&uml;" . 168)
    ("&copy;" . 169)
    ("&ordf;" . 170)
    ("&laquo;" . 171)
    ("&not;" . 172)
    ("&shy;" . 173)
    ("&reg;" . 174)
    ("&macr;" . 175)
    ("&deg;" . 176)
    ("&plusmn;" . 177)
    ("&sup2;" . 178)
    ("&sup3;" . 179)
    ("&acute;" . 180)
    ("&micro;" . 181)
    ("&para;" . 182)
    ("&middot;" . 183)
    ("&cedil;" . 184)
    ("&sup1;" . 185)
    ("&ordm;" . 186)
    ("&raquo;" . 187)
    ("&frac14;" . 188)
    ("&frac12;" . 189)
    ("&frac34;" . 190)
    ("&iquest;" . 191)
    ("&Agrave;" . 192)
    ("&Aacute;" . 193)
    ("&Acirc;" . 194)
    ("&Atilde;" . 195)
    ("&Auml;" . 196)
    ("&Aring;" . 197)
    ("&AElig;" . 198)
    ("&Ccedil;" . 199)
    ("&Egrave;" . 200)
    ("&Eacute;" . 201)
    ("&Ecirc;" . 202)
    ("&Euml;" . 203)
    ("&Igrave;" . 204)
    ("&Iacute;" . 205)
    ("&Icirc;" . 206)
    ("&Iuml;" . 207)
    ("&ETH;" . 208)
    ("&Ntilde;" . 209)
    ("&Ograve;" . 210)
    ("&Oacute;" . 211)
    ("&Ocirc;" . 212)
    ("&Otilde;" . 213)
    ("&Ouml;" . 214)
    ("&times;" . 215)
    ("&Oslash;" . 216)
    ("&Ugrave;" . 217)
    ("&Uacute;" . 218)
    ("&Ucirc;" . 219)
    ("&Uuml;" . 220)
    ("&Yacute;" . 221)
    ("&THORN;" . 222)
    ("&szlig;" . 223)
    ("&agrave;" . 224)
    ("&aacute;" . 225)
    ("&acirc;" . 226)
    ("&atilde;" . 227)
    ("&auml;" . 228)
    ("&aring;" . 229)
    ("&aelig;" . 230)
    ("&ccedil;" . 231)
    ("&egrave;" . 232)
    ("&eacute;" . 233)
    ("&ecirc;" . 234)
    ("&euml;" . 235)
    ("&igrave;" . 236)
    ("&iacute;" . 237)
    ("&icirc;" . 238)
    ("&iuml;" . 239)
    ("&eth;" . 240)
    ("&ntilde;" . 241)
    ("&ograve;" . 242)
    ("&oacute;" . 243)
    ("&ocirc;" . 244)
    ("&otilde;" . 245)
    ("&ouml;" . 246)
    ("&divide;" . 247)
    ("&oslash;" . 248)
    ("&ugrave;" . 249)
    ("&uacute;" . 250)
    ("&ucirc;" . 251)
    ("&uuml;" . 252)
    ("&yacute;" . 253)
    ("&thorn;" . 254)
    ("&yuml;" . 255)
    ("&OElig;" . 338)
    ("&oelig;" . 339)
    ("&Scaron;" . 352)
    ("&scaron;" . 353)
    ("&Yuml;" . 376)
    ("&circ;" . 710)
    ("&tilde;" . 732)
    ("&fnof;" . 402)
    ("&Alpha;" . 913)
    ("&Beta;" . 914)
    ("&Gamma;" . 915)
    ("&Delta;" . 916)
    ("&Epsilon;" . 917)
    ("&Zeta;" . 918)
    ("&Eta;" . 919)
    ("&Theta;" . 920)
    ("&Iota;" . 921)
    ("&Kappa;" . 922)
    ("&Lambda;" . 923)
    ("&Mu;" . 924)
    ("&Nu;" . 925)
    ("&Xi;" . 926)
    ("&Omicron;" . 927)
    ("&Pi;" . 928)
    ("&Rho;" . 929)
    ("&Sigma;" . 931)
    ("&Tau;" . 932)
    ("&Upsilon;" . 933)
    ("&Phi;" . 934)
    ("&Chi;" . 935)
    ("&Psi;" . 936)
    ("&Omega;" . 937)
    ("&alpha;" . 945)
    ("&beta;" . 946)
    ("&gamma;" . 947)
    ("&delta;" . 948)
    ("&epsilon;" . 949)
    ("&zeta;" . 950)
    ("&eta;" . 951)
    ("&theta;" . 952)
    ("&iota;" . 953)
    ("&kappa;" . 954)
    ("&lambda;" . 955)
    ("&mu;" . 956)
    ("&nu;" . 957)
    ("&xi;" . 958)
    ("&omicron;" . 959)
    ("&pi;" . 960)
    ("&rho;" . 961)
    ("&sigmaf;" . 962)
    ("&sigma;" . 963)
    ("&tau;" . 964)
    ("&upsilon;" . 965)
    ("&phi;" . 966)
    ("&chi;" . 967)
    ("&psi;" . 968)
    ("&omega;" . 969)
    ("&thetasym;" . 977)
    ("&upsih;" . 978)
    ("&piv;" . 982)
    ("&ensp;" . 8194)
    ("&emsp;" . 8195)
    ("&thinsp;" . 8201)
    ("&zwnj;" . 8204)
    ("&zwj;" . 8205)
    ("&lrm;" . 8206)
    ("&rlm;" . 8207)
    ("&ndash;" . 8211)
    ("&mdash;" . 8212)
    ("&lsquo;" . 8216)
    ("&rsquo;" . 8217)
    ("&sbquo;" . 8218)
    ("&ldquo;" . 8220)
    ("&rdquo;" . 8221)
    ("&bdquo;" . 8222)
    ("&dagger;" . 8224)
    ("&Dagger;" . 8225)
    ("&bull;" . 8226)
    ("&hellip;" . 8230)
    ("&permil;" . 8240)
    ("&prime;" . 8242)
    ("&Prime;" . 8243)
    ("&lsaquo;" . 8249)
    ("&rsaquo;" . 8250)
    ("&oline;" . 8254)
    ("&frasl;" . 8260)
    ("&euro;" . 8364)
    ("&image;" . 8465)
    ("&ewierp;" . 8472)
    ("&real;" . 8476)
    ("&trade;" . 8482)
    ("&alefsym;" . 8501)
    ("&larr;" . 8592)
    ("&uarr;" . 8593)
    ("&rarr;" . 8594)
    ("&darr;" . 8595)
    ("&harr;" . 8596)
    ("&crarr;" . 8629)
    ("&lArr;" . 8656)
    ("&uArr;" . 8657)
    ("&rArr;" . 8658)
    ("&dArr;" . 8659)
    ("&hArr;" . 8660)
    ("&forall;" . 8704)
    ("&part;" . 8706)
    ("&exist;" . 8707)
    ("&empty;" . 8709)
    ("&nabla;" . 8711)
    ("&isin;" . 8712)
    ("&notin;" . 8713)
    ("&ni;" . 8715)
    ("&prod;" . 8719)
    ("&sum;" . 8721)
    ("&minus;" . 8722)
    ("&lowast;" . 8727)
    ("&radic;" . 8730)
    ("&prop;" . 8733)
    ("&infin;" . 8734)
    ("&ang;" . 8736)
    ("&and;" . 8743)
    ("&or;" . 8744)
    ("&cap;" . 8745)
    ("&cup;" . 8746)
    ("&int;" . 8747)
    ("&there4;" . 8756)
    ("&sim;" . 8764)
    ("&cong;" . 8773)
    ("&asymp;" . 8776)
    ("&ne;" . 8800)
    ("&equiv;" . 8801)
    ("&le;" . 8804)
    ("&ge;" . 8805)
    ("&sub;" . 8834)
    ("&sup;" . 8835)
    ("&nsub;" . 8836)
    ("&sube;" . 8838)
    ("&supe;" . 8839)
    ("&oplus;" . 8853)
    ("&otimes;" . 8855)
    ("&perp;" . 8869)
    ("&sdot;" . 8901)
    ("&lceil;" . 8968)
    ("&rceil;" . 8969)
    ("&lfloor;" . 8970)
    ("&rfloor;" . 8971)
    ("&lang;" . 9001)
    ("&rang;" . 9002)
    ("&loz;" . 9674)
    ("&spades;" . 9824)
    ("&clubs;" . 9827)
    ("&hearts;" . 9829)
    ("&diams;" . 9830)
    ))

(defvar *xmlpm-temp-buffer* "*XMLPM TEMP*")

(defvar *xmlpm-show-status-message* t)

(defmacro xmlpm-interval-message ((interval) &body body)
  `(let ((#1=#:last-tick (+ (get-internal-real-time) ,interval))
	 (#2=#:tick))
     (flet ((message (&rest args)
	      (setq #2# (get-internal-real-time))
	      (when (> #2# #1#)
		(setq #1# (+ #2# ,interval))
		(apply #'message args))))
       ,@body)))

(defmacro xmlpm-tag-name (tag)
  `(car ,tag))

(defmacro xmlpm-tag-opts (tag)
  `(cadr ,tag))

(defmacro xmlpm-tag-contents (tag)
  `(cddr ,tag))

(defmacro xmlpm-tag-get-opt (key opts)
  `(cdr (assoc ,key ,opts :test #'equal)))

(defmacro xmlpm-tag-close-p (tag)
  `(xmlpm-tag-get-opt 'close (xmlpm-tag-opts ,tag)))

(defmacro xmlpm-tag-single-p (tag)
  `(xmlpm-tag-get-opt 'single (xmlpm-tag-opts ,tag)))

(defun xmlpm-message (fmt &rest args)
  (apply #'message (concat "xmlpm: " fmt) args))

(defun xmlpm-msgbox (fmt &rest args)
  (message-box (apply #'format nil fmt args) "xmlpm" '(:ok :information)))

(defun xmlpm-parse-tag (beg end)
  (let (name
	opts
	close)
    (goto-char (1+ beg))
    (setq beg (point))
    (cond ((looking-for "!--")
	   (progn
	     (scan-buffer "-->" :tail t)
	     (return-from xmlpm-parse-tag)))
	  ((looking-for "!DOCTYPE")
	   (let ()
	     (unless (scan-buffer "\\(\[\\|\]?>\\)" :regexp t :tail t) ;???
	       (error "DOCTYPE not closed."))
	     (cond ((equal (match-string 1) "[")
		    (scan-buffer "\][ \n]**>" :regexp t :tail t))
		   (t
		    nil))
	     (return-from xmlpm-parse-tag)))
	  ((looking-for "![CDATA[")
	   (progn
	     (goto-char (+ (length "![CDATA[") (point)))
	     (setq beg (point))
	     (scan-buffer "]]>" :tail t)
	     (return-from xmlpm-parse-tag
	       (buffer-substring beg
				 (- (point) (length "]]>"))))))
	  ((looking-for "!")
	   (progn
	     (scan-buffer ">" :tail t)
	     (return-from xmlpm-parse-tag)))
	  ((looking-for "/")
	   (progn
	     (push (cons 'close t) opts)
	     (forward-char 1)))
	  ((looking-for "?")
	   (progn
	     (scan-buffer "?>" :tail t)
	     (return-from xmlpm-parse-tag)))
	  (t
	   (progn
	     (goto-char end)
	     (when (looking-back "/>")
	       (push (cons 'single t) opts))
	     (goto-char beg)))
	  )
    (setq beg (point))
    (skip-chars-forward "^ \t\n\r/>")
    (when (= (point) beg)
      (xmlpm-message "could not find tag name")
      (return-from xmlpm-parse-tag))
    (setq name (buffer-substring beg (point)))
    (setq beg (point))
    (save-restriction
      (narrow-to-region beg end)
      (while (scan-buffer *xmlpm-tag-options-regexp* :regexp t :tail t)
	(let ((key (match-string 1))
	      (val (or (match-string 4)
		       (match-string 6))))
	  (push (cons key (xmlpm-decode-special-chars val)) opts))))
    (goto-char end)
    (list name opts)
    ))

(defun xmlpm-decode-special-chars (str)
  (let ((parsed "")
	(regexp (compile-regexp "&\\(#\\([0-9]+\\)\\|#x\\([0-9a-fA-F]+\\)\\|\\([0-9a-zA-Z]+\\)\\);"))
	(rest str))
    (while (string-match regexp rest)
      (let ((x (match-string 0))
	    (start (match-beginning 0))
	    (stop (match-end 0))
	    chr)
	(cond ((match-beginning 2)
	       (let ((asc (parse-integer (match-string 2))))
		 (setq chr (unicode-char asc))))
	      ((match-beginning 3)
	       (let ((asc (parse-integer (match-string 3) :radix 16)))
		 (setq chr (unicode-char asc))))
	      (t
	       (let ((ent (cdr (assoc x *xmlpm-character-entity-alist* :test #'equal))))
		 (when ent
		   (setq chr (unicode-char ent))))))
	(when (< 0 start)
	  (setq parsed (concat parsed (substring rest 0 start))))
	(if chr
	    (if (stringp chr)
		(setq parsed (format nil "~A~A" parsed chr))
	      (setq parsed (format nil "~A~C" parsed chr)))
	  (setq parsed (concat parsed x)))
	(setq rest (substring rest stop))))
    (setq str (concat parsed rest))))

(defun xmlpm-encode-special-chars (str)
  (dolist (y (reverse *xmlpm-special-chars-alist*))
    (setq str (substitute-string str (cdr y) (car y))))
  str)

(defun xmlpm-study (elements)
  (let (parsed)
    (xmlpm-message "studying ... ")
    (while elements
      (let (next add)
	(setq next (car elements))
	(setq elements (cdr elements))
	(cond ((stringp next)
	       nil)
	      ((xmlpm-tag-close-p next)
	       nil)
	      ((xmlpm-tag-single-p next)
	       (push next parsed))
	      (t
	       (multiple-value-setq (elements add)
		 (xmlpm-study-tag elements next))))
	(when add
	  (push add parsed))))
    (xmlpm-message "studying ... done.")
    (nreverse parsed)))

(defun xmlpm-study-tag (elements open-tag)
  (let (parsed
	element
	(name (xmlpm-tag-name open-tag)))
    (while elements
      (setq element (car elements))
      (setq elements (cdr elements))
      (cond ((stringp element)
	     (setq open-tag (append open-tag (list element))))
	    ((listp element)
	     (cond ((xmlpm-tag-close-p element)
		    (unless (equal name (xmlpm-tag-name element))
		      (xmlpm-msgbox "閉じタグが一致しません: ~S" element))
		    (return))
		   ((xmlpm-tag-single-p element)
		    (setq open-tag (append open-tag (list element))))
		   (t
		    (let (add)
		      (multiple-value-setq (elements add)
			(xmlpm-study-tag elements element))
		      (when add
			(setq open-tag (append open-tag (list add))))))))))
    (values elements (xmlpm-tag-cleanup open-tag))))

(defun xmlpm-tag-cleanup (tag)
  (let* ((old (xmlpm-tag-contents tag))
	 (nest-p (xmlpm-tag-include-tag-p old))
	 new)
    (dolist (c old)
      (cond ((stringp c)
	     (unless nest-p
	       (setq c (string-trim " \t\n" c))
	       (push c new)))
	    (t
	     (push c new))))
    (setf (xmlpm-tag-contents tag) (reverse new))
    tag))

(defun xmlpm-tag-include-tag-p (contents)
  (dolist (content contents)
    (when (listp content)
      (return-from xmlpm-tag-include-tag-p t)))
  nil)

(defun xmlpm-parse-declaration ()
  (save-excursion
    (goto-char (point-min))
    (when (scan-buffer "<\\?xml[^>]*>" :regexp t)
      (let ((beg (+ 1 (match-beginning 0)))
	    (end (match-end 0)))
	(xmlpm-parse-tag beg end)))))

(defun xmlpm-get-encoding (tag)
  (let* ((opts (xmlpm-tag-opts tag))
	 (encoding (xmlpm-tag-get-opt "encoding" opts)))
    (and encoding
	 (gethash encoding *mime-charset-name-hash-table*))))

(defun xmlpm-parse-buffer ()
  (let (parsed
	beg
	end
	(last-percent nil)
       )
    (save-excursion
      (goto-char (point-min))
      (setq beg (point))
      (xmlpm-message "parsing ... ")
      (xmlpm-interval-message (300)
	(while (scan-buffer "<[^>]+>" :regexp t :tail t)
	  (let ((start (match-beginning 0))
		(stop (match-end 0))
		temp)
	    (setq temp (xmlpm-parse-tag start stop))
	    (unless (= beg start)
	      (save-excursion
		(goto-char start)
		(setq parsed
		      (xmlpm-join-or-concat (xmlpm-decode-special-chars (buffer-substring beg (point))) parsed))
		))
	    (when temp
	      (push temp parsed))
	    (setq beg (point))
	    (when *xmlpm-show-status-message*
	      (let ((percent (truncate (* 100 beg) (point-max))))
		(unless (eql percent last-percent)
		  (setq last-percent percent)
		  (xmlpm-message "parsing ... ~3D%" percent))))))
	(unless (= beg (point-max))
	  (setq parsed
		(xmlpm-join-or-concat (xmlpm-decode-special-chars (buffer-substring beg (point-max))) parsed))
	  ))
      (xmlpm-message "parsing ... done"))
    (nreverse parsed)))

(defun xmlpm-join-or-concat (item parsed)
  (if (and (stringp item)
	   (stringp (car parsed)))
      (setf (car parsed) (concat (car parsed) item))
    (push item parsed))
  parsed)

(defun xmlpm-parse (&optional (convert-encoding t))
  (when convert-encoding
    (let ((encoding (xmlpm-get-encoding (xmlpm-parse-declaration))))
      (if encoding
	  (map-char-encoding-region (point-min) (point-max) encoding)
	(map-char-encoding-region (point-min) (point-max) *encoding-utf8*))))
  (xmlpm-study (xmlpm-parse-buffer)))

(defun xmlpm-parse-file (file)
  (let (parsed
	(*expected-fileio-encoding* *encoding-sjis*))
    (declare (special *expected-fileio-encoding*))
    (save-excursion
      (set-buffer (get-buffer-create *xmlpm-temp-buffer*))
      (erase-buffer (selected-buffer))
      (insert-file-contents file)
      (setq parsed (xmlpm-parse))
      (delete-buffer *xmlpm-temp-buffer*))
    parsed))

(defun xmlpm-write-tag (s tag)
  (if (stringp tag)
      (format s "~A" (xmlpm-encode-special-chars tag))
    (let ((name (xmlpm-tag-name tag))
	  (opts (xmlpm-tag-opts tag))
	  (contents (xmlpm-tag-contents tag))
	  (single-p (xmlpm-tag-single-p tag)))
      (format s "<~A" name)
      (when opts
	(dolist (opt opts)
	  (let ((opt-name (car opt))
		(opt-value (cdr opt)))
	    (when (stringp opt-name)
	      (format s " ~A~@[=\"~A\"~]"
		      opt-name
		      (if (stringp opt-value)
			  (xmlpm-encode-special-chars opt-value)))))))
      (when single-p
	(format s " /"))
      (format s ">")
      (when contents
	(dolist (content contents)
	  (xmlpm-write-tag s content)))
      (unless single-p
	(format s "</~A>" name)))))

(defun xmlpm-write-xml (xml &optional (encoding *encoding-utf8n*) (encname "utf-8"))
  (convert-encoding-from-internal
   encoding
   (with-output-to-string (s)
     (format s "<?xml version=\"1.0\" encoding=\"~A\"?>~%" encname)
     (dolist (tag xml)
       (xmlpm-write-tag s tag)))))
