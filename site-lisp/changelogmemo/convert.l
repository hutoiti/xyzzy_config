;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/convert.l
;;;
;;; Last updated: "2006-02-12"
;;;

(provide "changelogmemo/convert")

(in-package "changelogmemo")

;;; �j��(��, �L)�A[�J�e�S��]:(�J�e�S��:)�A�^�u(��, �L)�̌`���ɕϊ�����
(defun cl-convert (file)
  (interactive "fCL File: " :default0 *cl-file*)
  (let (f1 f2 f3 (s1 "") (s2 "") (s3 ""))
    (message "0: ���̂܂� 1: �j����  2: �j���L")
    (setq f1 (0-or-1-or-2-p "�j�������܂���?"))
    (message "0: ���̂܂�  1: �^�C�g�� [�J�e�S��]:  2: �J�e�S��: �^�C�g��:")
    (setq f2 (0-or-1-or-2-p "�ǂ̏����ɂ��܂���?"))
    (message "0: ���̂܂�  1: �^�u��  2: �^�u�L")
    (setq f3 (0-or-1-or-2-p "�^�u�����܂���?"))
    (long-operation
      (message "�ϊ���...")
      (set-buffer (ed::find-file-internal file nil nil nil t))
      (goto-char (point-min))
      (case f1
	(1 (convert-with-noweekday) (setq s1 "�j����"))
	(2 (convert-with-weekday) (setq s1 "�j���L")))
      (case f2
	(1
	 (convert-new-format)
	 (if (= f1 0)
	     (setq s2 "�^�C�g�� [�J�e�S��]:")
	   (setq s2 " + �^�C�g�� [�J�e�S��]:")))
	(2
	 (convert-old-format)
	 (if (= f1 0)
	     (setq s2 "�J�e�S��: �^�C�g��:")
	   (setq s2 " + �J�e�S��: �^�C�g��:"))))
      (case f3
	(1
	 (convert-with-notab)
	 (if (and (= f1 0) (= f2 0))
	     (setq s3 "�^�u��")
	   (setq s3 " + �^�u��")))
	(2
	 (convert-with-tab)
	 (if (and (= f1 0) (= f2 0))
	     (setq s3 "�^�u�L")
	   (setq s3 " + �^�u�L"))))
      (save-buffer)
      (message "~A~A~A �̌`���ɕϊ����܂���" s1 s2 s3))
    ))

(defun 0-or-1-or-2-p (fmt &rest args)
  (ed:minibuffer-prompt "~? (0 or 1 or 2) " fmt args)
  (loop
    (case (read-char ed:*keyboard*)
      ((#\0)
       (return 0))
      ((#\1)
       (return 1))
      ((#\2)
       (return 2))
      (#\C-g
       (quit)))))

;;; �j��(��, �L)�̌`���ɕϊ�����
(defun convert-with-noweekday ()
  (save-excursion
    (replace-buffer
     "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\) ([A-Z][a-z][a-z])"
     "\\1"
     :regexp t)))

(defun convert-with-weekday ()
  (save-excursion
    (let ((no-dup nil))
      (while (scan-buffer (compile-regexp "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\)\\( ([A-Z][a-z][a-z])\\|\\)")
			  :no-dup no-dup)
	(replace-match (format nil "~A (~A)"
			       (match-string 1)
			       (get-weekday (match-string 1))))
	(setq no-dup t))
      )))

;;; [�J�e�S��]:(�J�e�S��:)�̌`���ɕϊ�����
(defun convert-new-format ()
  (save-excursion
    (let ((no-dup nil))
      (while (scan-buffer (compile-regexp "\t\\* \\(p:\\|\\)\\(.*\\):")
			  :no-dup no-dup)
	(let* ((list (mapcar #'(lambda (x) (string-trim '(#\SPC) x))
			     (split-string (match-string 2) ":")))
	       (s1 (match-string 1))
	       (s2 (if list
		       (car (reverse list))
		     ""))
	       (s3 (if (< 1 (list-length list))
		       (format nil " [~{~A~^] [~}]" (butlast list 1))
		     "")))
	  (replace-match (format nil "\t\\* ~A~A~A:" s1 s2 s3))
	  (setq no-dup t)))
      )))

(defun convert-old-format ()
  (save-excursion
    (let ((no-dup nil))
      (while (scan-buffer (compile-regexp "\t\\* \\(p:\\|\\)\\([^][\n]*\\)\\( ?\\[.*\\]\\|\\):")
			  :no-dup no-dup)
	(let* ((list (mapcar #'(lambda (x) (string-left-trim "[ " x))
			     (split-string (match-string 3) "]")))
	       (s1 (match-string 1))
	       (s2 (if list
		       (format nil "~{~A~^: ~}: " list)
		     ""))
	       (s3 (string-trim '(#\SPC) (match-string 2))))
	  (replace-match (format nil "\t\\* ~A~A~A:" s1 s2 s3))
	  (setq no-dup t)))
      )))

;;; �^�u(��, �L)�̌`���ɕϊ�����
(defun convert-with-notab ()
  (save-excursion
    (replace-buffer "^\t\\(.*\\)$" "\\1" :regexp t)))

(defun convert-with-tab ()
  (save-excursion
    (let ((no-dup nil))
      (while (scan-buffer (compile-regexp "^.+$") :no-dup no-dup)
	(let ((s (match-string 0)))
	  (unless (ed::protect-match-data
		    (string-match (compile-regexp "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
				  s))
	    (replace-match (format nil "\t~A" s))))
	(setq no-dup t))
      )))

;;; chalow �ŕϊ�
(defun convert-chalow ()
  (interactive)
  (when (yes-or-no-p "chalow �� html �ɕϊ����܂���?")
    (long-operation
      (message "�ϊ���...")
      (execute-shell-command *chalow-command*)
      (message "html �ɕϊ����܂���"))))