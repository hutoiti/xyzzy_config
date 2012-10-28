;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: lirs.l 561 2006-01-26 12:37:50Z torihat $
;
; rss/filters/lirs.l
;
; by HATTORI Masashi
;;
;; ��  LIRS�`����rss������t�B���^
;;
;;    �E�ݒ�iconfig.l�Q�Ɓj
;;      - �K�v��URL�̐����� rss-filter-regist ����
;;        �i�f�t�H���g�ł́A"lirs.txt" "lirs.txt.gz" "lirs.gz"�Ƀ}�b�`�j
;;      - *lirs-url-max* �ɍő�\���������w��i��������ƒx���j
;;    �E�o�^
;;      �o�^���Ƀ^�C�g������͂���K�v������

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/main"))

(provide "rss/filter/lirs")

(in-package "rss")

;; "lirs.txt" "lirs.txt.gz" "lirs.gz" �Ƀ}�b�`
(defvar *lirs-url-regexp* "lirs\\(\.txt\\|\.txt.gz\\|\.gz\\)$")
(defvar *lirs-items-max* 30)

#|
Last modified Information Relaying Specification
 <http://aniki.haun.org/natsu/LIRS.html>

LIRS���R�[�h�w�b�_
�X�V����(Last-Modified�FGMT)
�X�V�������擾��������(Last-Detected�FGMT)
�ΏۃT�C�g��GMT�Ƃ̌덷(�b)
�ΏۃT�C�g�̗e��(Content-Length�F�o�C�g)
�ΏۃT�C�g��URL
�ΏۃT�C�g�̃^�C�g��
�ΏۃT�C�g�̊Ǘ��Җ�
���擾���T�C�g��URL,(�g����...)
(\015)\012
|#

(defvar *lirs-time-diference* (ed::parse-date-string "1970/01/01 09:00:00"))

(defmacro lirs-last-modified (line)
  `(nth 1 ,line))

(defmacro lirs-site-url (line)
  `(nth 5 ,line))

(defmacro lirs-site-title (line)
  `(nth 6 ,line))

(defun lirs-last-modified-parse (last-modified)
  (if (and (stringp last-modified)
	   (string-match "^[0-9]+$" last-modified))
      (parse-integer last-modified)
    0))

(defun lirs-last-modified-format (time)
  (format-date-string "%Y/%m/%d %H:%M:%S" (+ time *lirs-time-diference*)))

(defun lirs-parse-line ()
  (split-string (buffer-substring (progn (goto-bol) (point))
				  (progn (goto-eol) (point)))
		""
		t))

(defun lirs-parse-buffer ()
  (let (items)
    (save-excursion
      (message "parsing LIRS format ...")
      (goto-char (point-min))
      ;; ��؂蕶�������炩���ߏ����Ă��� ("" => "")
      (replace-buffer "" "")
      (goto-char (point-min))
      ;; �G�X�P�[�v����Ă��Ȃ� "," ��u�� ("," => "")
      (replace-buffer "\\([^\\]\\)," "\\1" :regexp t)
      (goto-char (point-min))
      (replace-buffer "," "")
      ;; �G�X�P�[�v���ꂽ "," ��߂� ("\," => ",")
      (goto-char (point-min))
      (replace-buffer "\\," ",")
      ;; �G�X�P�[�v��߂� ("\\" => "\")
      (goto-char (point-min))
      (replace-buffer "\\\\" "\\")
      (goto-char (point-min))
      (while (looking-for "LIRS")
	(let ((line (lirs-parse-line)))
	  (setf (lirs-last-modified line)
		(lirs-last-modified-parse (lirs-last-modified line)))
	  (push line items))
	(or (forward-line 1) (return)))
      (message "parsing LIRS format ... done."))
    ;; �X�V�����~���Ń\�[�g
    (setq items (sort items #'> :key #'(lambda (x)
					 (lirs-last-modified x))))
    ;; �ő匏���ȉ��؂�̂�
    (when (and *lirs-items-max*
	       (< *lirs-items-max* (list-length items)))
      (setq items (butlast items (- (list-length items) *lirs-items-max*))))
    (mapcar #'(lambda (x)
		(rss-create-item (format nil "~@[~A~] ~@[~A~]"
					 (lirs-last-modified-format (lirs-last-modified x))
					 (lirs-site-title x))
				 (lirs-site-url x)))
	    items)))

(defun lirs-filter (channel file)
  (let ((url (rss-link channel))
	(title (or (and (rss-title channel)
			(not (equal (rss-title channel) *rss-menu-temp-buffer-suffix*))
			(rss-title channel))
		   (read-string "Site Title: ")))
	items)
    (save-excursion
      (set-buffer (get-buffer-create *rss-buffer-temp*))
      (erase-buffer (selected-buffer))
      (insert-file-contents file)
      (setq items (lirs-parse-buffer))
      (delete-buffer (selected-buffer)))
    ; ���̃t�@�C�����㏑��
    (convert-to-rss (rss-create title url nil items)
		    file)))

;; �t�B���^�̓o�^
;; (URL���}�b�`�������Ƀt�B���^���Ă΂��j
(rss-filter-regist *lirs-url-regexp* 'lirs-filter)