;;; -*- mode: lisp -*-
;;; name:     ac-mode-html+
;;; version:  2007.03.05
;;; author:   shiro

;; Copyright (C) 2006-2007 shiro
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; 概要:
;; 
;; ac-mode + html+-mode 用の設定を行う
;; 
;; html+-mode が必要です

;; 設定:
;; 
;; http://openlab.ring.gr.jp/k16/htmllint/
;; からルールファイルをダウンロードさせてもらって、
;; html401-strict.rul等をetcに置いてください。
;; デフォルトでhtml401-strict.rulを使うようになっているので、
;; それ以外を使いたい場合はac-mode-html+-rule-fileを変更してください。
;; 
;; ac-mode側からは設定しないので、
;; 初期化ファイルに以下を追加してください。
;; 
;; (require "ac-mode-html+")

;; 内容:
;; 
;; - ある要素が取り得る属性を補完
;; - ある要素の子要素になり得る要素を補完
;; - URIを取り得る場所でURIを補完
;; - 属性が取り得る値を補完
;; - LinkTypes
;; - ContentType
;; - ContentTypes (ContentTypeをコンマ区切りで複数指定)
;; - Tabindex
;; - Class
;; - Id
;; - abbrevで定義されているタグ/属性は補完後に展開
;;   (snippetが導入されていればsnippetの展開)
;; 
;; # 厳密じゃないです
;; 

;; 設定
;; 
;; XHTML
;;   XHTML なタグを補完したい方は
;;   (setq-default ac-mode-html+-xhtml t)
;;   などしてください。
;;   <img /> とスラッシュが付いたり、
;;   checked="checked" とHTMLでは値を持たない属性に値を挿入します。
;;   
;; abbrev/snippet
;;   要素のabbrev/snippetと誤爆するので(titleとか)、属性用のabbrev/snippetは末尾に
;;   =を付けた名前で定義してください。
;;   
;;   e.g.
;;   ("class=" "class=\"${1:name}\"$0" nil 0)

;; 履歴:
;; 
;; 2007.03.02
;; - 属性が取り得る値を補完
;; - LinkTypes
;; - ContentType
;; - ContentTypes
;; - Tabindex
;; - Class
;; - Id
;; - 閉じタグのないタグは/を入れるようにした
;; - abbrevで定義されているタグ/属性は補完後に展開するようにした
;;   (snippetが導入されていればsnippetの展開)
;; - 属性が2重に補完できないようにした
;; - 値を持たない属性を考慮するようにした

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "ac-mode")
  )

(require "html+-mode")

(provide "ac-mode-html+")

(in-package "editor")

(defvar-local ac-mode-html+-xhtml nil)
(defvar-local ac-mode-html+-element-hash nil)
(defvar-local ac-mode-html+-attribute-hash nil)
(defvar-local ac-mode-html+-empty-elements nil)
(defvar-local ac-mode-html+-empty-attributes nil)
(defvar-local ac-mode-html+-rule-file
  (merge-pathnames "html401-strict.rul" (etc-path)))

;; ruleファイルのコンバート用関数
(defun ac-mode-html+-get-element-attribute ()
  (when (and (or (not (equal ac-mode-html+-rule-file (default-value 'ac-mode-html+-rule-file)))
				 (not (default-value 'ac-mode-html+-element-hash)))
			 (file-exist-p ac-mode-html+-rule-file))
	(save-excursion
	  (let ((buffer (create-new-buffer " *ac-mode-html+*")))
		(save-excursion
		  (set-buffer buffer)
		  (insert-file ac-mode-html+-rule-file))
		;; empty elements
		(let (elements)
		  (save-excursion
			(set-buffer buffer)
			(goto-char (point-min))
			(scan-buffer "$emptyTags = \\([^;]*\\)" :regexp t)
			(setf elements (split-string (string-trim "'" (match-string 1)) "|")))
		  (when elements
			(if (equal ac-mode-html+-rule-file (default-value 'ac-mode-html+-rule-file))
				(setq-default ac-mode-html+-empty-elements elements)
			  (setf ac-mode-html+-empty-elements elements))))
		;; get elements
		(let (tmp)
		  (save-excursion
			(set-buffer buffer)
			(goto-char (point-min))
			(scan-buffer "%tagsElements = \\([^;]*\\)" :regexp t)
			(let ((elements (mapcar 'string-downcase (split-string (string-trim "()" (substitute-string (match-string 1) "[\n '.]" "")) ","))))
			  (dolist (e elements)
				(let ((res (split-string e "|=>")))
				  (unless (find (first res) '("#000" "#001") :test 'equal)
					(push (remove "#000" (remove "#001" res :test 'equal) :test 'equal) tmp))))))
		  (if (equal ac-mode-html+-rule-file (default-value 'ac-mode-html+-rule-file))
			  (setq-default ac-mode-html+-element-hash (ac-mode-hash tmp :test 'equal))
			(setf ac-mode-html+-element-hash (ac-mode-hash tmp :test 'equal))))
		;; get attributes
		(let (limit attributes noattributes)
		  (save-excursion
			(set-buffer buffer)
			(goto-char (point-min))
			(scan-buffer "%tagsAttributes = \\([^;]*\\)" :regexp t)
			(setf limit (match-end 0))
			(while (save-excursion
					 (scan-buffer "'\\([^']*\\)' *=> *{[^}]*" :regexp t :limit limit))
			  (let (elements limit)
				(push (string-downcase (match-string 1)) elements)
				(setf limit (match-end 0))
				(while (scan-buffer "'\\([^']*\\)' *=> *'\\([^']*\\)'" :regexp t :no-dup t :limit limit)
				  (let ((att (list (string-downcase (match-string 1))))
						(val (match-string 2)))
					(cond ((equalp "%URI" val)
						   (setf val '(:uri)))
						  ((equalp "%LinkTypes" val)
						   (setf val '(:linktypes)))
						  ((equalp "%ContentTypes" val)
						   (setf val '(:contenttypes)))
						  ((equalp "%ContentType" val)
						   (setf val '(:contenttype)))
						  ((equalp "%MediaDesc" val)
						   (setf val '(:mediadesc)))
						  ((equalp "%FrameTarget" val)
						   (setf val '(:frametarget)))
						  ((equalp "IDREF" val)
						   (setf val '(:idref)))
						  ((equalp "IDREFS" val)
						   (setf val '(:idrefs)))
						  ((equalp "%Class" val)
						   (setf val '(:class)))
						  ((and (equalp val (first att))
								(not (find val '("ID" "NAME") :test 'equalp)))
						   (setf val '(:same))
						   (push (first att) noattributes))
						  ((string-match "|" val)
						   (setf val (split-string (string-downcase val) "|")))
						  (t (setf val nil)))
					(push (append att val) elements)))
				(push (reverse elements) attributes)
				(goto-char limit))))
		  (cond ((equal ac-mode-html+-rule-file (default-value 'ac-mode-html+-rule-file))
				 (setq-default ac-mode-html+-attribute-hash (ac-mode-hash attributes :test 'equal))
				 (setq-default ac-mode-html+-empty-attributes noattributes))
				(t
				 (setf ac-mode-html+-attribute-hash (ac-mode-hash attributes :test 'equal)
					   ac-mode-html+-empty-attributes noattributes))))
		(delete-buffer buffer))))
  (and ac-mode-html+-element-hash ac-mode-html+-attribute-hash))

(defvar *ac-mode-html+-doctype-alist*
  '(("-//W3C//DTD HTML 4.01//EN"              . "4.01-strict")
	("-//W3C//DTD HTML 4.01 Transitional//EN" . "4.01-transitional")
	("-//W3C//DTD HTML 4.01 Frameset//EN"     . "4.01-frameset")
	("-//W3C//DTD HTML 4.0//EN"               . "4.0-strict")
	("-//W3C//DTD HTML 4.0 Transitional//EN"  . "4.0-transitional")
	("-//W3C//DTD HTML 4.0 Frameset//EN"      . "4.0-frameset")
	("-//W3C//DTD HTML 3.2//EN"               . "3.2")
	))
(defun ac-mode-html+-get-doctype (&optional type)
  (when (save-excursion
		  (scan-buffer "<!doctype html public *\"\\([^\"]*\\)\""
					   :case-fold t :regexp t :reverse t))
	(let ((match (match-string 1)) res)
	  (when (setf res (cdr (assoc match *ac-mode-html+-doctype-alist* :test 'equalp)))
		(if type (equal type res) res)))))


;; タグの情報を取得
;; (バイトコンパイルしないとものすごく遅いので注意)
;; 
;; <と>の間にいなかったらnil
;; 
;; 多値
;; 1. <の直後を0として、何番目か
;; 2. =や空白以外のリスト
;; 
;; e.g.
;; <a href="./index.html" cla*ss="foo">
;; => 3 ("a" "href" "\"./index.html\"" "class" "\"foo\"")
;; 
(defun ac-mode-html+-get-current-html ()
  (when (find (parse-point-syntax) '(:string :tag))
	(let ((from (save-excursion
				  (do nil
					  ((or (bobp)
						   (and (syntax-open-tag-p (following-char))
								(not (ac-mode-get-syntax ":string"))
								(not (ac-mode-get-syntax ":comment"))))
					   (point))
					(skip-syntax-spec-backward "^{")
					(backward-char))))
		  (to (save-excursion
				(do nil
					((or (eobp)
						 (and (syntax-close-tag-p (following-char))
							  (not (ac-mode-get-syntax ":string"))
							  (not (ac-mode-get-syntax ":comment"))))
					 (forward-char)
					 (point))
				  (forward-char)
				  (skip-syntax-spec-forward "^}"))))
		  lst pos
		  (point (point)))
	  (save-excursion
		(goto-char from)
		(let (lst pos)
		  (while (scan-buffer "\\(\\_s+\\|\"[^\"]*\"\\)" :regexp t :tail t :limit to)
			(unless pos
			  (cond ((or (< point (match-beginning 0))
						 (< (match-beginning 0) point (match-end 0))
						 (= (match-beginning 0) point)
						 (and (= (match-end 0) point)
							  (not (equal "\"" (buffer-substring (1- (match-end 0)) (match-end 0))))))
					 (setf pos (length lst)))
					((and (= (match-end 0) point)
						  (equal "\"" (buffer-substring (1- (match-end 0)) (match-end 0))))
					 (setf pos (1+ (length lst))))))
			(push (match-string 0) lst))
		  (when (and lst (not pos))
			(setf pos (length lst)))
		  (values pos (reverse lst)))))))

(defun ac-mode-html+-uplevel-tag (&optional tag)
  (multiple-value-bind (res pos tag1)
	  (uplevel-tag)
	(when res
	  (cond (tag
			 (equalp tag tag1))
			(t tag1)))))

(defun ac-mode-html+-position-is-value (pos lst)
  (when (< 0 pos)
	(cond (ac-mode-html+-xhtml
		   (evenp pos))
		  (t
		   (let ((newpos (position (nth pos lst)
								   (reverse (set-difference lst ac-mode-html+-empty-attributes :test 'equalp))
							:test 'equalp)))
			 (when newpos
			   (evenp newpos)))))))

;;; -----------------------------------------------------------------
;;; complete
;;; -----------------------------------------------------------------

;;; complete element
(defun ac-mode-html+-after-complete-element ()
  (when (and (find *ac-mode-this-command*
				   '(ac-mode-self-insert
					 ac-mode-return
					 ac-mode-complete-string))
			 (eq *ac-mode-complete-module* 'ac-mode-try-complete-list))
	(let ((str (save-excursion
				 (buffer-substring
				  (progn (skip-syntax-spec-backward "w") (point))
				  (progn (skip-syntax-spec-forward "w") (point))))))
	  (cond ((gethash str *local-abbrev-table*)
			 (cond ((modulep "snippet")
					(let ((fn (intern "snippet-expand" "editor")))
					  (setf *this-command* fn)
					  (funcall fn)))
				   (t (expand-abbrev))))
			(t
			 (let (from)
			   (save-excursion
				 (skip-syntax-spec-backward "w")
				 (skip-chars-backward "#")
				 (insert "<")
				 (setf from (point)))
			   (save-excursion
				 (cond ((and ac-mode-html+-xhtml
							 (find (buffer-substring from (point))
								   ac-mode-html+-empty-elements :test 'equalp))
						(insert " />")
						(backward-char 2))
					   (t
						(insert ">")
						(backward-char)))))))))
  (delete-hook '*ac-mode-complete-hook* 'ac-mode-html+-after-complete-element))
(defun ac-mode-html+-complete-element ()
  (when (and (not (parse-point-syntax))
			 (let ((c (html+-calc-indent)))
			   (when c
				 (save-excursion
				   (skip-syntax-spec-backward "w")
				   (= (current-column) c)))))
	(let ((tag (ac-mode-html+-uplevel-tag))
		  res)
	  (when (and tag
				 (setf res (gethash tag ac-mode-html+-element-hash)))
		(add-hook '*ac-mode-complete-hook* 'ac-mode-html+-after-complete-element)
		(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-complete-list
								  ac-mode-try-abbrev-local
								  ac-mode-try-abbrev-global
								  ac-mode-try-dabbrev-current-buffer)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* res
			  *ac-mode-complete-type-list* "Elements")))))

;;; complete attribute
(defun ac-mode-html+-after-complete-attribute ()
  (when (and (or (not *ac-mode-this-command*)
				 (find *ac-mode-this-command*
					   '(ac-mode-self-insert
						 ac-mode-return
						 ac-mode-complete-string)))
			 (eq *ac-mode-complete-module* 'ac-mode-try-complete-list))
	(let ((str (save-excursion
				 (buffer-substring
				  (progn (skip-syntax-spec-backward "w") (point))
				  (progn (skip-syntax-spec-forward "w") (point)))))
		  pos lst)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (cond ((eq :same
				 (second (find str (gethash (first lst) ac-mode-html+-attribute-hash)
							   :key 'car :test 'equal)))
			 (when ac-mode-html+-xhtml
			   (insert "=\"" str  "\"")))
			((gethash (concat str "=") *local-abbrev-table*)
			 (insert "=")
			 (cond ((modulep "snippet")
					(let ((fn (intern "snippet-expand" "editor")))
					  (setf *this-command* fn)
					  (funcall fn)))
				   (t (expand-abbrev))))
			(t
			 (insert "=\"\"")
			 (backward-char)))))
  (delete-hook '*ac-mode-complete-hook* 'ac-mode-html+-after-complete-attribute))
(defun ac-mode-html+-complete-attribute ()
  (let (pos lst)
	(multiple-value-setq (pos lst)
	  (ac-mode-html+-get-current-html))
	(when (and pos (not (ac-mode-html+-position-is-value pos lst)))
	  (let ((attr (gethash (first lst) ac-mode-html+-attribute-hash)))
		(when attr
		  (add-hook '*ac-mode-complete-hook* 'ac-mode-html+-after-complete-attribute)
		  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		  (setf *ac-mode-start-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-backward "w") (point)))
				*ac-mode-end+1-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-forward "w") (forward-char) (point)))
				*ac-mode-command* '(ac-mode-try-complete-list)
				*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				*ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				*ac-mode-complete-user-list* (set-difference (mapcar 'car attr) lst :test 'equalp)
				*ac-mode-complete-type-list* "Attributes"))))))

;;; complete attribute value
(defun ac-mode-html+-complete-attribute-value ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (when (and pos
				 (ac-mode-html+-position-is-value pos lst))
		(let* ((attr (gethash (first lst) ac-mode-html+-attribute-hash))
			   res)
		  (when (and attr
					 (setf res (cdr (find (nth (1- pos) lst) attr :test 'equal :key 'car)))
					 (consp res))
			(setf *ac-mode-start-marker* (set-marker (make-marker) (1+ (ac-mode-get-beginning-of-string)))
				  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
				  *ac-mode-command* '(ac-mode-try-complete-list)
				  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				  *ac-mode-complete-user-list* res
				  *ac-mode-complete-type-list* "Value")))))))

;;; complete uri
(defun ac-mode-html+-complete-uri ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (when (and pos
				 (ac-mode-html+-position-is-value pos lst))
		(let* ((attr (gethash (first lst) ac-mode-html+-attribute-hash)))
		  (when (and attr
					 (eq :uri (second (find (nth (1- pos) lst) attr :test 'equal :key 'car))))
			(setf *ac-mode-start-marker* (set-marker (make-marker) (1+ (ac-mode-get-beginning-of-string)))
				  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
				  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-URI)
				  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-URI)
				  *ac-mode-command* '(ac-mode-try-complete-file ac-mode-try-complete-URI))))))))

;;; complete LinkType/ContentType
;; 
;; from http://www.iana.org/assignments/media-types/
;; 
;; OpenOfficeはIANAに載ってませんが一応入れときました。
;; 多すぎるのでapplication/vnd.*のms-とmozilla以外コメントアウトしてます。(それでも453個)
(defvar *ac-mode-html+-content-type*
    ;; message
  '("message/CPIM" "message/delivery-status" "message/disposition-notification" "message/example" "message/external-body" "message/http" "message/news" "message/partial" "message/rfc822" "message/s-http" "message/sip" "message/sipfrag" "message/tracking-status"
	;; image
	"image/cgm" "image/example" "image/fits" "image/g3fax" "image/gif" "image/ief" "image/jp2" "image/jpeg" "image/jpm" "image/jpx" "image/naplps" "image/png" "image/prs.btif" "image/prs.pti" "image/t38" "image/tiff" "image/tiff-fx" "image/vnd.adobe.photoshop" "image/vnd.cns.inf2" "image/vnd.djvu" "image/vnd.dwg" "image/vnd.dxf" "image/vnd.fastbidsheet" "image/vnd.fpx" "image/vnd.fst" "image/vnd.fujixerox.edmics-mmr" "image/vnd.fujixerox.edmics-rlc" "image/vnd.globalgraphics.pgb" "image/vnd.microsoft.icon" "image/vnd.mix" "image/vnd.ms-modi" "image/vnd.net-fpx" "image/vnd.sealed.png" "image/vnd.sealedmedia.softseal.gif" "image/vnd.sealedmedia.softseal.jpg" "image/vnd.svf" "image/vnd.wap.wbmp" "image/vnd.xiff"
	;; audio
	"audio/32kadpcm" "audio/3gpp" "audio/3gpp2" "audio/ac3" "audio/AMR" "audio/AMR-WB" "audio/amr-wb+" "audio/asc" "audio/basic" "audio/BV16" "audio/BV32" "audio/clearmode" "audio/CN" "audio/DAT12" "audio/dls" "audio/dsr-es201108" "audio/dsr-es202050" "audio/dsr-es202211" "audio/dsr-es202212" "audio/eac3" "audio/DVI4" "audio/EVRC" "audio/EVRC0" "audio/EVRC1" "audio/EVRCB" "audio/EVRCB0" "audio/EVRCB1" "audio/EVRC-QCP" "audio/example" "audio/G722" "audio/G7221" "audio/G723" "audio/G726-16" "audio/G726-24" "audio/G726-32" "audio/G726-40" "audio/G728" "audio/G729" "audio/G7291" "audio/G729D" "audio/G729E" "audio/GSM" "audio/GSM-EFR" "audio/iLBC" "audio/L8" "audio/L16" "audio/L20" "audio/L24" "audio/LPC" "audio/mobile-xmf" "audio/MPA" "audio/mp4" "audio/MP4A-LATM" "audio/mpa-robust" "audio/mpeg" "audio/mpeg4-generic" "audio/parityfec" "audio/PCMA" "audio/PCMU" "audio/prs.sid" "audio/QCELP" "audio/RED" "audio/rtp-midi" "audio/rtx" "audio/SMV" "audio/SMV0" "audio/SMV-QCP" "audio/sp-midi" "audio/t140c" "audio/t38" "audio/telephone-event" "audio/tone" "audio/VDVI" "audio/VMR-WB" "audio/vnd.3gpp.iufp" "audio/vnd.4SB" "audio/vnd.audiokoz" "audio/vnd.CELP" "audio/vnd.cisco.nse" "audio/vnd.cmles.radio-events" "audio/vnd.cns.anp1" "audio/vnd.cns.inf1" "audio/vnd.digital-winds" "audio/vnd.dlna.adts" "audio/vnd.everad.plj" "audio/vnd.hns.audio" "audio/vnd.lucent.voice" "audio/vnd.nokia.mobile-xmf" "audio/vnd.nortel.vbk" "audio/vnd.nuera.ecelp4800" "audio/vnd.nuera.ecelp7470" "audio/vnd.nuera.ecelp9600" "audio/vnd.octel.sbc" "audio/vnd.qcelp" "audio/vnd.rhetorex.32kadpcm" "audio/vnd.sealedmedia.softseal.mpeg" "audio/vnd.vmx.cvsd"
	;; aplication
	"application/activemessage" "application/andrew-inset" "application/applefile" "application/atom+xml" "application/atomicmail" "application/auth-policy+xml" "application/batch-SMTP" "application/beep+xml" "application/cals-1840" "application/ccxml+xml" "application/cellml+xml" "application/cnrp+xml" "application/commonground" "application/conference-info+xml" "application/cpl+xml" "application/csta+xml" "application/CSTAdata+xml" "application/cybercash" "application/davmount+xml" "application/dca-rft" "application/dec-dx" "application/dialog-info+xml" "application/dicom" "application/dns" "application/dvcs" "application/ecmascript" "application/EDI-Consent" "application/EDIFACT" "application/EDI-X12" "application/epp+xml" "application/eshop" "application/example" "application/fastinfoset" "application/fastsoap" "application/fits" "application/font-tdpfr" "application/H224" "application/http" "application/hyperstudio" "application/iges" "application/im-iscomposing+xml" "application/index" "application/index.cmd" "application/index.obj" "application/index.response" "application/index.vnd" "application/iotp" "application/ipp" "application/isup" "application/javascript" "application/json" "application/kpml-request+xml" "application/kpml-response+xml" "application/mac-binhex40" "application/macwriteii" "application/marc" "application/mathematica" "application/mbox" "application/mediaservercontrol+xml" "application/mikey" "application/mpeg4-generic" "application/mpeg4-iod" "application/mpeg4-iod-xmt" "application/mp4" "application/msword" "application/mxf" "application/nasdata" "application/news-message-id" "application/news-transmission" "application/nss" "application/ocsp-request" "application/ocsp-response" "application/octet-stream" "application/oda" "application/oebps-package+xml" "application/ogg" "application/parityfec" "application/pdf" "application/pgp-encrypted" "application/pgp-keys" "application/pgp-signature" "application/pidf+xml" "application/pkcs10" "application/pkcs7-mime" "application/pkcs7-signature" "application/pkix-cert" "application/pkixcmp" "application/pkix-crl" "application/pkix-pkipath" "application/pls+xml" "application/poc-settings+xml" "application/postscript" "application/prs.alvestrand.titrax-sheet" "application/prs.cww" "application/prs.nprend" "application/prs.plucker" "application/rdf+xml" "application/qsig" "application/reginfo+xml" "application/relax-ng-compact-syntax" "application/remote-printing" "application/resource-lists+xml" "application/riscos" "application/rlmi+xml" "application/rls-services+xml" "application/rtf" "application/rtx" "application/samlassertion+xml" "application/samlmetadata+xml" "application/sbml+xml" "application/sdp" "application/set-payment" "application/set-payment-initiation" "application/set-registration" "application/set-registration-initiation" "application/sgml" "application/sgml-open-catalog" "application/shf+xml" "application/sieve" "application/simple-filter+xml" "application/simple-message-summary" "application/slate" "application/smil" "application/smil+xml" "application/soap+fastinfoset" "application/soap+xml" "application/spirits-event+xml" "application/srgs" "application/srgs+xml" "application/ssml+xml" "application/timestamp-query" "application/timestamp-reply" "application/tve-trigger" "application/vemmi"
	"application/vnd.ms-excel" "application/vnd.ms-fontobject" "application/vnd.ms-htmlhelp" "application/vnd.msign" "application/vnd.ms-ims" "application/vnd.ms-lrm" "application/vnd.ms-powerpoint" "application/vnd.ms-project" "application/vnd.ms-tnef" "application/vnd.ms-wmdrm.lic-chlg-req" "application/vnd.ms-wmdrm.lic-resp" "application/vnd.ms-wmdrm.meter-chlg-req" "application/vnd.ms-wmdrm.meter-resp" "application/vnd.ms-works" "application/vnd.ms-wpl" "application/vnd.ms-xpsdocument" "application/vnd.ms-artgalry" "application/vnd.ms-asf" "application/vnd.ms-cab-compressed"
	"application/vnd.mozilla.xul+xml"
	;"application/vnd.3gpp.bsf+xml" "application/vnd.3gpp.pic-bw-large" "application/vnd.3gpp.pic-bw-small" "application/vnd.3gpp.pic-bw-var" "application/vnd.3gpp.sms" "application/vnd.3gpp2.bcmcsinfo+xml" "application/vnd.3gpp2.sms" "application/vnd.3M.Post-it-Notes" "application/vnd.accpac.simply.aso" "application/vnd.accpac.simply.imp" "application/vnd.acucobol" "application/vnd.acucorp" "application/vnd.adobe.xfdf" "application/vnd.aether.imp" "application/vnd.amiga.ami" "application/vnd.anser-web-certificate-issue-initiation" "application/vnd.apple.installer+xml" "application/vnd.audiograph" "application/vnd.autopackage" "application/vnd.avistar+xml" "application/vnd.blueice.multipass" "application/vnd.bmi" "application/vnd.businessobjects" "application/vnd.cab-jscript" "application/vnd.canon-cpdl" "application/vnd.canon-lips" "application/vnd.chipnuts.karaoke-mmd" "application/vnd.cinderella" "application/vnd.cirpack.isdn-ext" "application/vnd.claymore" "application/vnd.commerce-battelle" "application/vnd.commonspace" "application/vnd.cosmocaller" "application/vnd.contact.cmsg" "application/vnd.crick.clicker" "application/vnd.crick.clicker.keyboard" "application/vnd.crick.clicker.palette" "application/vnd.crick.clicker.template" "application/vnd.crick.clicker.wordbank" "application/vnd.criticaltools.wbs+xml" "application/vnd.ctc-posml" "application/vnd.cups-pdf" "application/vnd.cups-postscript" "application/vnd.cups-ppd" "application/vnd.cups-raster" "application/vnd.cups-raw" "application/vnd.curl" "application/vnd.cybank" "application/vnd.data-vision.rdz" "application/vnd.dna" "application/vnd.dpgraph" "application/vnd.dreamfactory" "application/vnd.dvb.esgcontainer" "application/vnd.dvb.ipdcesgaccess" "application/vnd.dxr" "application/vnd.ecdis-update" "application/vnd.ecowin.chart" "application/vnd.ecowin.filerequest" "application/vnd.ecowin.fileupdate" "application/vnd.ecowin.series" "application/vnd.ecowin.seriesrequest" "application/vnd.ecowin.seriesupdate" "application/vnd.enliven" "application/vnd.epson.esf" "application/vnd.epson.msf" "application/vnd.epson.quickanime" "application/vnd.epson.salt" "application/vnd.epson.ssf" "application/vnd.ericsson.quickcall" "application/vnd.eudora.data" "application/vnd.ezpix-album" "application/vnd.ezpix-package" "application/vnd.fdf" "application/vnd.ffsns" "application/vnd.fints" "application/vnd.FloGraphIt" "application/vnd.fluxtime.clip" "application/vnd.framemaker" "application/vnd.frogans.fnc" "application/vnd.frogans.ltf" "application/vnd.fsc.weblaunch" "application/vnd.fujitsu.oasys" "application/vnd.fujitsu.oasys2" "application/vnd.fujitsu.oasys3" "application/vnd.fujitsu.oasysgp" "application/vnd.fujitsu.oasysprs" "application/vnd.fujixerox.ART4" "application/vnd.fujixerox.ART-EX" "application/vnd.fujixerox.ddd" "application/vnd.fujixerox.docuworks" "application/vnd.fujixerox.docuworks.binder" "application/vnd.fujixerox.HBPL" "application/vnd.fut-misnet" "application/vnd.fuzzysheet" "application/vnd.genomatix.tuxedo" "application/vnd.google-earth.kml+xml" "application/vnd.google-earth.kmz" "application/vnd.grafeq" "application/vnd.gridmp" "application/vnd.groove-account" "application/vnd.groove-help" "application/vnd.groove-identity-message" "application/vnd.groove-injector" "application/vnd.groove-tool-message" "application/vnd.groove-tool-template" "application/vnd.groove-vcard" "application/vnd.HandHeld-Entertainment+xml" "application/vnd.hbci" "application/vnd.hcl-bireports" "application/vnd.hhe.lesson-player" "application/vnd.hp-HPGL" "application/vnd.hp-hpid" "application/vnd.hp-hps" "application/vnd.hp-jlyt" "application/vnd.hp-PCL" "application/vnd.hp-PCLXL" "application/vnd.httphone" "application/vnd.hzn-3d-crossword" "application/vnd.ibm.afplinedata" "application/vnd.ibm.electronic-media" "application/vnd.ibm.MiniPay" "application/vnd.ibm.modcap" "application/vnd.ibm.rights-management" "application/vnd.ibm.secure-container" "application/vnd.igloader" "application/vnd.informedcontrol.rms+xml" "application/vnd.informix-visionary" "application/vnd.intercon.formnet" "application/vnd.intertrust.digibox" "application/vnd.intertrust.nncp" "application/vnd.intu.qbo" "application/vnd.intu.qfx" "application/vnd.ipunplugged.rcprofile" "application/vnd.irepository.package+xml" "application/vnd.is-xpr" "application/vnd.japannet-directory-service" "application/vnd.japannet-jpnstore-wakeup" "application/vnd.japannet-payment-wakeup" "application/vnd.japannet-registration" "application/vnd.japannet-registration-wakeup" "application/vnd.japannet-setstore-wakeup" "application/vnd.japannet-verification" "application/vnd.japannet-verification-wakeup" "application/vnd.jisp" "application/vnd.kahootz" "application/vnd.kde.karbon" "application/vnd.kde.kchart" "application/vnd.kde.kformula" "application/vnd.kde.kivio" "application/vnd.kde.kontour" "application/vnd.kde.kpresenter" "application/vnd.kde.kspread" "application/vnd.kde.kword" "application/vnd.kenameaapp" "application/vnd.kidspiration" "application/vnd.Kinar" "application/vnd.koan" "application/vnd.liberty-request+xml" "application/vnd.llamagraphics.life-balance.desktop" "application/vnd.llamagraphics.life-balance.exchange+xml" "application/vnd.lotus-1-2-3" "application/vnd.lotus-approach" "application/vnd.lotus-freelance" "application/vnd.lotus-notes" "application/vnd.lotus-organizer" "application/vnd.lotus-screencam" "application/vnd.lotus-wordpro" "application/vnd.marlin.drm.actiontoken+xml" "application/vnd.marlin.drm.conftoken+xml" "application/vnd.marlin.drm.mdcf" "application/vnd.mcd" "application/vnd.medcalcdata" "application/vnd.mediastation.cdkey" "application/vnd.meridian-slingshot" "application/vnd.MFER" "application/vnd.mfmp" "application/vnd.micrografx.flo" "application/vnd.micrografx.igx" "application/vnd.mif" "application/vnd.minisoft-hp3000-save" "application/vnd.mitsubishi.misty-guard.trustweb" "application/vnd.Mobius.DAF" "application/vnd.Mobius.DIS" "application/vnd.Mobius.MBK" "application/vnd.Mobius.MQY" "application/vnd.Mobius.MSL" "application/vnd.Mobius.PLC" "application/vnd.Mobius.TXF" "application/vnd.mophun.application" "application/vnd.mophun.certificate" "application/vnd.motorola.flexsuite" "application/vnd.motorola.flexsuite.adsi" "application/vnd.motorola.flexsuite.fis" "application/vnd.motorola.flexsuite.gotap" "application/vnd.motorola.flexsuite.kmr" "application/vnd.motorola.flexsuite.ttc" "application/vnd.motorola.flexsuite.wem" "application/vnd.mseq" "application/vnd.musician" "application/vnd.music-niff" "application/vnd.ncd.control" "application/vnd.nervana" "application/vnd.netfpx" "application/vnd.noblenet-directory" "application/vnd.noblenet-sealer" "application/vnd.noblenet-web" "application/vnd.nokia.catalogs" "application/vnd.nokia.conml+wbxml" "application/vnd.nokia.conml+xml" "application/vnd.nokia.iptv.config+xml" "application/vnd.nokia.landmark+wbxml" "application/vnd.nokia.landmark+xml" "application/vnd.nokia.landmarkcollection+xml" "application/vnd.nokia.pcd+wbxml" "application/vnd.nokia.pcd+xml" "application/vnd.nokia.radio-preset" "application/vnd.nokia.radio-presets" "application/vnd.novadigm.EDM" "application/vnd.novadigm.EDX" "application/vnd.novadigm.EXT" "application/vnd.oasis.opendocument.chart" "application/vnd.oasis.opendocument.chart-template" "application/vnd.oasis.opendocument.formula" "application/vnd.oasis.opendocument.formula-template" "application/vnd.oasis.opendocument.graphics" "application/vnd.oasis.opendocument.graphics-template" "application/vnd.oasis.opendocument.image" "application/vnd.oasis.opendocument.image-template" "application/vnd.oasis.opendocument.presentation" "application/vnd.oasis.opendocument.presentation-template" "application/vnd.oasis.opendocument.spreadsheet" "application/vnd.oasis.opendocument.spreadsheet-template" "application/vnd.oasis.opendocument.text" "application/vnd.oasis.opendocument.text-master" "application/vnd.oasis.opendocument.text-template" "application/vnd.oasis.opendocument.text-web" "application/vnd.obn" "application/vnd.oma.dd2+xml" "application/vnd.oma.group-usage-list+xml" "application/vnd.oma.poc.groups+xml" "application/vnd.oma.xcap-directory+xml" "application/vnd.omads-email+xml" "application/vnd.omads-file+xml" "application/vnd.omads-folder+xml" "application/vnd.omaloc-supl-init" "application/vnd.oma-scws-config" "application/vnd.oma-scws-http-request" "application/vnd.oma-scws-http-response" "application/vnd.openofficeorg.extension" "application/vnd.osa.netdeploy" "application/vnd.osgi.dp" "application/vnd.otps.ct-kip+xml" "application/vnd.palm" "application/vnd.paos.xml" "application/vnd.pg.format" "application/vnd.pg.osasli" "application/vnd.piaccess.application-licence" "application/vnd.picsel" "application/vnd.poc.group-advertisement+xml" "application/vnd.pocketlearn" "application/vnd.powerbuilder6" "application/vnd.powerbuilder6-s" "application/vnd.powerbuilder7" "application/vnd.powerbuilder75" "application/vnd.powerbuilder75-s" "application/vnd.powerbuilder7-s" "application/vnd.preminet" "application/vnd.previewsystems.box" "application/vnd.proteus.magazine" "application/vnd.publishare-delta-tree" "application/vnd.pvi.ptid1" "application/vnd.pwg-multiplexed" "application/vnd.pwg-xhtml-print+xml" "application/vnd.qualcomm.brew-app-res" "application/vnd.Quark.QuarkXPress" "application/vnd.rapid" "application/vnd.RenLearn.rlprint" "application/vnd.ruckus.download" "application/vnd.s3sms" "application/vnd.scribus" "application/vnd.sealed.3df" "application/vnd.sealed.csf" "application/vnd.sealed.doc" "application/vnd.sealed.eml" "application/vnd.sealed.mht" "application/vnd.sealed.net" "application/vnd.sealed.ppt" "application/vnd.sealed.tiff" "application/vnd.sealed.xls" "application/vnd.sealedmedia.softseal.html" "application/vnd.sealedmedia.softseal.pdf" "application/vnd.seemail" "application/vnd.sema" "application/vnd.semd" "application/vnd.semf" "application/vnd.shana.informed.formdata" "application/vnd.shana.informed.formtemplate" "application/vnd.shana.informed.interchange" "application/vnd.shana.informed.package" "application/vnd.SimTech-MindMapper" "application/vnd.smaf" "application/vnd.solent.sdkm+xml" "application/vnd.spotfire.dxp" "application/vnd.spotfire.sfs" "application/vnd.sss-cod" "application/vnd.sss-dtf" "application/vnd.sss-ntf" "application/vnd.street-stream" "application/vnd.sun.wadl+xml" "application/vnd.sus-calendar" "application/vnd.svd" "application/vnd.swiftview-ics" "application/vnd.syncml.dm+wbxml" "application/vnd.syncml.dm+xml" "application/vnd.syncml.ds.notification" "application/vnd.syncml+xml" "application/vnd.tao.intent-module-archive" "application/vnd.tmobile-livetv" "application/vnd.triscape.mxs" "application/vnd.trueapp" "application/vnd.truedoc" "application/vnd.ufdl" "application/vnd.uiq.theme" "application/vnd.umajin" "application/vnd.uoml+xml" "application/vnd.uplanet.alert" "application/vnd.uplanet.alert-wbxml" "application/vnd.uplanet.bearer-choice" "application/vnd.uplanet.bearer-choice-wbxml" "application/vnd.uplanet.cacheop" "application/vnd.uplanet.cacheop-wbxml" "application/vnd.uplanet.channel" "application/vnd.uplanet.channel-wbxml" "application/vnd.uplanet.list" "application/vnd.uplanet.listcmd" "application/vnd.uplanet.listcmd-wbxml" "application/vnd.uplanet.list-wbxml" "application/vnd.uplanet.signal" "application/vnd.vcx" "application/vnd.vectorworks" "application/vnd.vd-study" "application/vnd.vidsoft.vidconference" "application/vnd.visio" "application/vnd.visionary" "application/vnd.vividence.scriptfile" "application/vnd.vsf" "application/vnd.wap.sic" "application/vnd.wap.slc" "application/vnd.wap.wbxml" "application/vnd.wap.wmlc" "application/vnd.wap.wmlscriptc" "application/vnd.webturbo" "application/vnd.wfa.wsc" "application/vnd.wordperfect" "application/vnd.wqd" "application/vnd.wrq-hp3000-labelled" "application/vnd.wt.stf" "application/vnd.wv.csp+xml" "application/vnd.wv.csp+wbxml" "application/vnd.wv.ssp+xml" "application/vnd.xara" "application/vnd.xfdl" "application/vnd.xmpie.ppkg" "application/vnd.yamaha.hv-dic" "application/vnd.yamaha.hv-script" "application/vnd.yamaha.hv-voice" "application/vnd.yamaha.smaf-audio" "application/vnd.yamaha.smaf-phrase" "application/vnd.yellowriver-custom-menu" "application/vnd.zzazz.deck+xml"
	"application/voicexml+xml" "application/watcherinfo+xml" "application/whoispp-query" "application/whoispp-response" "application/wita" "application/wordperfect5.1" "application/x400-bp" "application/xcap-att+xml" "application/xcap-caps+xml" "application/xcap-el+xml" "application/xcap-error+xml" "application/xcap-ns+xml" "application/xenc+xml" "application/xhtml-voice+xml" "application/xhtml+xml" "application/xml" "application/xml-dtd" "application/xml-external-parsed-entity" "application/xmpp+xml" "application/xop+xml" "application/xv+xml" "application/zip"
	;; OpenOffice
	"application/vnd.sun.xml.writer" "application/vnd.sun.xml.writer.template" "application/vnd.sun.xml.calc" "application/vnd.sun.xml.calc.template" "application/vnd.sun.xml.draw" "application/vnd.sun.xml.draw.template" "application/vnd.sun.xml.impress" "application/vnd.sun.xml.impress.template" "application/vnd.sun.xml.writer.global" "application/vnd.sun.xml.math"
	;; model
	"model/example" "model/iges" "model/mesh" "model/vnd.dwf" "model/vnd.flatland.3dml" "model/vnd.gdl" "model/vnd.gs-gdl" "model/vnd.gtw" "model/vnd.moml+xml" "model/vnd.mts" "model/vnd.parasolid.transmit.binary" "model/vnd.parasolid.transmit.text" "model/vnd.vtu" "model/vrml"
	;; multipart
	"multipart/alternative" "multipart/appledouble" "multipart/byteranges" "multipart/digest" "multipart/encrypted" "multipart/example" "multipart/form-data" "multipart/header-set" "multipart/mixed" "multipart/parallel" "multipart/related" "multipart/report" "multipart/signed" "multipart/voice-message"
	;; text
	"text/calendar" "text/css" "text/csv" "text/directory" "text/dns" "text/ecmascript" "text/enriched" "text/example" "text/html" "text/javascript" "text/parityfec" "text/plain" "text/prs.fallenstein.rst" "text/prs.lines.tag" "text/RED" "text/rfc822-headers" "text/richtext" "text/rtf" "text/rtx" "text/sgml" "text/t140" "text/tab-separated-values" "text/troff" "text/uri-list" "text/vnd.abc" "text/vnd.curl" "text/vnd.DMClientScript" "text/vnd.esmertec.theme-descriptor" "text/vnd.fly" "text/vnd.fmi.flexstor" "text/vnd.in3d.3dml" "text/vnd.in3d.spot" "text/vnd.IPTC.NewsML" "text/vnd.IPTC.NITF" "text/vnd.latex-z" "text/vnd.motorola.reflex" "text/vnd.ms-mediapackage" "text/vnd.net2phone.commcenter.command" "text/vnd.sun.j2me.app-descriptor" "text/vnd.trolltech.linguist" "text/vnd.wap.si" "text/vnd.wap.sl" "text/vnd.wap.wml" "text/vnd.wap.wmlscript" "text/xml" "text/xml-external-parsed-entity"
	;; video
	"video/3gpp" "video/3gpp2" "video/3gpp-tt" "video/BMPEG" "video/BT656" "video/CelB" "video/DV" "video/example" "video/H261" "video/H263" "video/H263-1998" "video/H263-2000" "video/H264" "video/JPEG" "video/MJ2" "video/MP1S" "video/MP2P" "video/MP2T" "video/mp4" "video/MP4V-ES" "video/MPV" "video/mpeg" "video/mpeg4-generic" "video/nv" "video/parityfec" "video/pointer" "video/quicktime" "video/raw" "video/rtx" "video/SMPTE292M" "video/vc1" "video/vnd.dlna.mpeg-tts" "video/vnd.fvt" "video/vnd.hns.video" "video/vnd.motorola.video" "video/vnd.motorola.videop" "video/vnd.mpegurl" "video/vnd.nokia.interleaved-multimedia" "video/vnd.nokia.videovoip" "video/vnd.objectvideo" "video/vnd.sealed.mpeg1" "video/vnd.sealed.mpeg4" "video/vnd.sealed.swf" "video/vnd.sealedmedia.softseal.mov" "video/vnd.vivo"
	))
(defvar *ac-mode-html+-complete-any-types*
  `((:linktypes "LinkTypes" (("alternate"  . "リンクが存在する文書の代替文書を指す。")
							 ("stylesheet" . "外部スタイルシートを指す。")
							 ("start"      . "文書群の中の最初の文書を指す。")
							 ("next"       . "続き物とされている文書群の、次の文書を指す。")
							 ("prev"       . "続き物の、前の文書を指す。")
							 ("contents"   . "目次として提供される文書を指す。")
							 ("index"      . "当該文書の索引である文書を指す。")
							 ("glossary"   . "当該文書に関連する用語集である文書を指す。")
							 ("copyright"  . "当該文書の著作権表示を指す。")
							 ("chapter"    . "文書群の中の章である文書を指す。")
							 ("section"    . "文書群の中の節である文書を指す。")
							 ("subsection" . "文書群の中の小節である文書を指す。 ")
							 ("appendix"   . "文書群の中の附属書である文書を指す。 ")
							 ("help"       . "詳説、他リソースへのリンク等の、ヘルプ文書を指す。")
							 ("bookmark"   . "ブックマークを指す。")))
	(:contenttypes "ContentTypes" ,*ac-mode-html+-content-type*)
	(:contenttype "ContentType" ,*ac-mode-html+-content-type*)
	(:mediadesc "MediaDesc" (("screen" . "非ページ型のコンピュータスクリーンを示す。")
							 ("tty" . "固定文字幅での出力、例えばテレタイプ、端末機器、表示能力に制限のある携帯機器、などでの出力を示す。 ")
							 ("tv" . "低解像度で、色やスクロール能力に制限がある、テレビ型機器を示す。 ")
							 ("projection" . "プロジェクターを示す。 ")
							 ("handheld" . "画面が小さく、モノクロ、ビットマップ画像、帯域幅に制限がある、モバイル機器を示す。 ")
							 ("print" . "ページ型の不透明素材での出力、および印刷プレビューモードでのスクリーン出力を示す。 ")
							 ("braille" . "点字出力機器を示す。 ")
							 ("aural" . "音声合成装置を示す。")
							 ("all" . "すべての出力に適合する。")))
	(:frametarget "FrameTarget" ("_blank" "_self" "_parent" "_top"))
	))
(defun ac-mode-html+-complete-any-types ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (when (and pos
				 (ac-mode-html+-position-is-value pos lst))
		(let* ((attr (gethash (first lst) ac-mode-html+-attribute-hash)) res)
		  (when (and attr
					 (setf res (find (second (find (nth (1- pos) lst) attr :test 'equal :key 'car))
									 *ac-mode-html+-complete-any-types*
									 :key 'car)))
			(when (eq :contenttypes (first res))
			  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*))
			(setf *ac-mode-start-marker* (set-marker (make-marker)
													 (max (1+ (ac-mode-get-beginning-of-string))
														  (if (and (eq :contenttypes (first res))
																   (save-excursion
																	 (scan-buffer "," :reverse t)))
															  (match-end 0)
															0)))
				  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
				  *ac-mode-command* '(ac-mode-try-complete-list)
				  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				  *ac-mode-complete-user-list* (third res)
				  *ac-mode-complete-type-list* (second res))))))))

;;; complete tabindex
(defun ac-mode-html+-complete-tab-index-get-number ()
  (let (tmp (max 0) res)
	(save-excursion
	  (goto-char (point-min))
	  (while (scan-buffer "tabindex=\"\\([0-9]+\\)\"" :regexp t :no-dup t)
		(let ((n (parse-integer (match-string 1))))
		  (push n tmp)
		  (when (< max n)
			(setf max n)))))
	(dotimes (n max)
	  (unless (find n tmp)
		(push n res)))
	(push (if (= max 0) 0 (1+ max)) res)
	(reverse res)))
(defun ac-mode-html+-complete-tab-index ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst number comp)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (when (and pos
				 (< 1 pos)
				 (string= "tabindex" (nth (1- pos) lst)))
		(setf *ac-mode-start-marker* (set-marker (make-marker) (1+ (ac-mode-get-beginning-of-string)))
			  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
			  *ac-mode-command* '(ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* (ac-mode-html+-complete-tab-index-get-number)
			  *ac-mode-complete-type-list* "TabIndex")))))

;;; complete id
(defun ac-mode-html+-complete-id-get-id ()
  (let ((limit (point))
		res)
	(save-excursion
	  (multiple-value-bind (flag1 pos1)
		  (uplevel-tag)
		(when flag1
		  (goto-char pos1)
		  (multiple-value-bind (flag pos)
			  (uplevel-tag)
			(if flag
				(goto-char pos)
			  (goto-char (point-min))))))
	  (while (scan-buffer "id *= *\"\\([^\"]+\\)\"" :regexp t :no-dup t :limit limit)
		(push (match-string 1) res))
	  res)))
(defun ac-mode-html+-complete-id ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst)
	  (multiple-value-setq (pos lst)
		(ed::ac-mode-html+-get-current-html))
	  (when (and pos
				 (ed::ac-mode-html+-position-is-value pos lst))
		(let* ((attr (gethash (first lst) ed::ac-mode-html+-attribute-hash))
			   limit res)
		  (when (and attr
					 (setf res (find (second (find (nth (1- pos) lst) attr :test 'equal :key 'car))
									 '(:idref :idrefs))))
			(when (eq :contenttypes res)
			  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*))
			(setf limit (ac-mode-get-beginning-of-string))
			(setf *ac-mode-start-marker* (set-marker (make-marker)
													 (max (1+ limit)
														  (if (and (eq :contenttypes res)
																   (save-excursion
																	 (scan-buffer " " :reverse t :limit limit)))
															  (match-end 0)
															0)))
				  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
				  *ac-mode-command* '(ac-mode-try-complete-list)
				  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				  *ac-mode-complete-user-list* (ac-mode-html+-complete-id-get-id)
				  *ac-mode-complete-type-list* "ID")))))))

;;; complete class
(defun ac-mode-html+-complete-class-get-class ()
  (let (lst)
	(save-excursion
	  (goto-char (point-min))
	  (while (scan-buffer "class *= *\"\\([^\"]*\\)\"" :regexp t :no-dup t)
		(let ((str (string-trim " " (match-string 1))))
		  (unless (equal "" str)
			(setf lst (union lst (split-string str " ") :test 'equal))))))
	lst))
(defun ac-mode-html+-complete-class ()
  (when (ac-mode-get-syntax ":string")
	(let (pos lst)
	  (multiple-value-setq (pos lst)
		(ac-mode-html+-get-current-html))
	  (when (and pos
				 (ac-mode-html+-position-is-value pos lst))
		(let* ((attr (gethash (first lst) ac-mode-html+-attribute-hash))
			   begin end)
		  (when (and attr
					 (eq :class (second (find (nth (1- pos) lst) attr :test 'equal :key 'car))))
			(setf begin (ac-mode-get-beginning-of-string)
				  end (ac-mode-get-end-of-string))
			(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
			(setf *ac-mode-start-marker* (set-marker (make-marker)
													 (max (1+ begin)
														  (if (save-excursion
																(scan-buffer " " :reverse t :limit begin))
															  (match-end 0)
															0)))
				  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ end))
				  *ac-mode-command* '(ac-mode-try-complete-list)
				  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				  *ac-mode-complete-user-list* (set-difference
												(ac-mode-html+-complete-class-get-class)
												(split-string (string-trim "\"" (buffer-substring begin end)) " ")
												:test 'equal)
				  *ac-mode-complete-type-list* "Class")))))))

(defun ac-mode-html+-init ()
  (when (ac-mode-html+-get-element-attribute)
	(dolist (symb '(ac-mode-html+-complete-element
					ac-mode-html+-complete-attribute
					ac-mode-html+-complete-attribute-value
					ac-mode-html+-complete-uri
					ac-mode-html+-complete-any-types
					ac-mode-html+-complete-tab-index
					ac-mode-html+-complete-id
					ac-mode-html+-complete-class))
	  (add-hook 'ac-mode-pre-completion-hook symb))))
(add-hook '*html+-mode-hook* 'ac-mode-html+-init)

;;; ac-mode-html+.l ends here
