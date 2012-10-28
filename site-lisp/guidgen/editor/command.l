; -*- mode: lisp; package: editor -*-

;; guidgen/editor/command.l
;;
;;   Copyright (c) 2006,2008 MIYAMUKO Katsuyuki.
;;
;;   See guidgen/docs/MIT-LICENSE for full license.
;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "guidgen/guidgen"))

(in-package :editor)
(use-package :guidgen)

(export '(guidgen-copy-to-kill-ring
          guidgen-copy-to-clipboard

          guidgen-toggle-use-last-guid
          guidgen-use-last-guid-p

          guidgen-replace-history-clear
          guidgen-replace-history-show

          guidgen-replace-or-insert
          guidgen-replace
          guidgen-replace-all-buffer
          guidgen-replace-buffer
          guidgen-replace-selection
          guidgen-replace-region

          guidgen-insert
          guidgen-insert-urn
          guidgen-insert-implement-olecreate
          guidgen-insert-define-guid
          guidgen-insert-static-const-guid
          guidgen-insert-registry
          ))

(defvar *guidgen-guid-regexp*
  guidgen::*guid-regexp-strict*)

(defparameter *guidgen-use-last-guid* nil)
(defparameter *guidgen-replace-history* nil)

(defun guidgen-toggle-use-last-guid ()
  (interactive)
  (setf *guidgen-use-last-guid*
        (not *guidgen-use-last-guid*)))

(defun guidgen-use-last-guid-p ()
  *guidgen-use-last-guid*)

(defun next-guid ()
  (if (and (guidgen-use-last-guid-p)
           (guidgen-last-guid))
      (guidgen-last-guid)
    (guidgen)))


(defmacro guidgen-define-insert (name (&rest lambda-list) &body body)
  `(defun ,name (&rest args)
     ,(when (eq (safe-caar body) 'interactive)
        (car body))
     (let ((n (if *prefix-args* *prefix-value* 1))
           (fn #'(lambda (,@lambda-list)
                   ,@body)))
       (do ((i 0 (1+ i)))
           ((not (< i n)))
         (if (and (interactive-p) (not args))
             (call-interactively fn)
           (apply fn args))
         (when *prefix-args*
           (insert "\n"))))))
(setf (get 'guidgen-define-insert 'ed:lisp-indent-hook) 'defun)


(defun guidgen-copy-to-kill-ring ()
  (interactive)
  (ed::kill-new (next-guid)))

(defun guidgen-copy-to-clipboard ()
  (interactive)
  (copy-to-clipboard (next-guid)))

(defun guidgen-replace-or-insert ()
  (interactive "*")
  (or (guidgen-replace)
      (guidgen-insert)))

(defun guidgen-replace ()
  (interactive "*")
  (guidgen-replace1 (next-guid)))

(defun guidgen-replace-all-buffer ()
  (interactive "*")
  (save-window-excursion
    (dolist (b (buffer-list :buffer-bar-order t))
      (set-buffer b)
      (guidgen-replace-region (point-min) (point-max)))))

(defun guidgen-replace-buffer ()
  (interactive "*")
  (guidgen-replace-region (point-min) (point-max)))

(defun guidgen-replace-selection ()
  (interactive "*")
  (or (selection-start-end (s e)
        (guidgen-replace-region s e))
      (message "セレクションがありません")))

(defun guidgen-replace-region (s e)
  (interactive "*r")
  (if (< e s) (rotatef s e))
  (save-excursion
    (save-restriction
      (narrow-to-region s e)
      (goto-char s)
      (let ((n 0))
        (while (scan-buffer *guidgen-guid-regexp* :regexp t)
          (guidgen-replace1 (next-guid))
          (goto-char (match-end 0))
          (incf n))
        (message "~D 個置換しました。" n)))))


(defun guidgen-replace1 (guid)
  (let ((opoint (point)))
    (prog1
        (when (and (scan-buffer *guidgen-guid-regexp* :regexp t :reverse t)
                   (<= (match-beginning 0) opoint (match-end 0)))
          (let* ((old-guid (match-string 0))
                 (upper (count-if #'upper-case-p old-guid))
                 (lower (count-if #'lower-case-p old-guid)))
            (setf guid (or (guidgen-replace-history-get old-guid)
                           guid))
            (setf guid (if (< upper lower)
                           (string-downcase guid)
                         (string-upcase guid)))
            (replace-match guid)
            (guidgen-replace-history-put guid old-guid)
            (list guid old-guid)))
      (goto-char opoint))))


(defun guidgen-replace-history-clear ()
  (interactive)
  (setf *guidgen-replace-history* nil))

(defun guidgen-replace-history-show ()
  (interactive)
  (if (not *guidgen-replace-history*)
      (message "更新履歴はありません")
    (with-output-to-temp-buffer ("*GUID replace*")
      (dolist (old->new (reverse *guidgen-replace-history*))
        (format t "~A => ~A~%" (car old->new) (cdr old->new))))))

(defun guidgen-replace-history-put (new-guid old-guid)
  (when (string/= new-guid old-guid)
    (pushnew (cons old-guid new-guid)
             *guidgen-replace-history*
             :test #'equalp :key #'car)))

(defun guidgen-replace-history-get (old-guid)
  (cdr (assoc old-guid *guidgen-replace-history*
              :test #'equalp)))


(guidgen-define-insert guidgen-insert ()
  (interactive "*")
  (insert (next-guid)))

(guidgen-define-insert guidgen-insert-urn ()
  (interactive "*")
  (insert "urn:uuid:" (next-guid)))

;; // {6BE050B4-C19D-4e64-97EA-6C27B7AEB91E}
;; IMPLEMENT_OLECREATE(<<class>>, <<external_name>>,
;; 0x6be050b4, 0xc19d, 0x4e64, 0x97, 0xea, 0x6c, 0x27, 0xb7, 0xae, 0xb9, 0x1e);
(defvar *guidgen-implement-olecreate-format*
  (concat "// {~A}~%"
          "IMPLEMENT_OLECREATE(<<class>>, <<external_name>>,~%"
          (substitute-string "~8, ~4, ~4, ~@{~2~^, ~}" "~[0-9]" "0x\\0,'0X")
          ");~%"))

(guidgen-define-insert guidgen-insert-implement-olecreate (&optional class external-name)
  (interactive "*")
  (guidgen-insert-template *guidgen-implement-olecreate-format*
                           :replacement (list (cons "<<class>>" class)
                                              (cons "<<external_name>>" external-name))
                           :cursor (if (interactive-p) '("<<class>>" "<<external_name>>"))))

;; // {6BE050B4-C19D-4e64-97EA-6C27B7AEB91E}
;; DEFINE_GUID(<<name>>,
;; 0x6be050b4, 0xc19d, 0x4e64, 0x97, 0xea, 0x6c, 0x27, 0xb7, 0xae, 0xb9, 0x1e);
(defvar *guidgen-define-guid-format*
  (concat "// {~A}~%"
          "DEFINE_GUID(<<name>>,~%"
          (substitute-string "~8, ~4, ~4, ~@{~2~^, ~}" "~[0-9]" "0x\\0,'0X")
          ");~%"))

(guidgen-define-insert guidgen-insert-define-guid (&optional name)
  (interactive "*")
  (guidgen-insert-template *guidgen-define-guid-format*
                           :replacement (list (cons "<<name>>" name))
                           :cursor (if (interactive-p) "<<name>>")))

;; // {2E00421E-3154-4641-AB6B-C8BC93815EC0}
;; static const GUID <<name>> = {
;;     0x2e00421e, 0x3154, 0x4641, { 0xab, 0x6b, 0xc8, 0xbc, 0x93, 0x81, 0x5e, 0xc0 }
;; };
(defvar *guidgen-static-const-guid-format*
  (concat "// {~A}~%"
          "static const GUID <<name>> = {~%"
          "    " (substitute-string "~8, ~4, ~4, { ~@{~2~^, ~} }" "~[0-9]" "0x\\0,'0X")
          "~%"
          "};~%"))

(guidgen-define-insert guidgen-insert-static-const-guid (&optional name)
  (interactive "*")
  (guidgen-insert-template *guidgen-static-const-guid-format*
                           :replacement (list (cons "<<name>>" name))
                           :cursor (if (interactive-p) "<<name>>")))


;; {2E00421E-3154-4641-AB6B-C8BC93815EC0}
(defvar *guidgen-registry-format*
  "{~A}")

(guidgen-define-insert guidgen-insert-registry ()
  (interactive "*")
  (guidgen-insert-template *guidgen-registry-format*))


(defun guidgen-insert-template (template &key replacement cursor)
  (flet ((x-point (p &rest functions)
           (save-excursion
             (goto-char p)
             (dolist (fn functions)
               (funcall fn))
             (point))))
    (let ((opoint (point))
          (epoint))
      (multiple-value-bind (guid guid-list)
          (next-guid)
        (insert (apply #'format nil template guid guid-list))
        (setf epoint (point)))
      (when replacement
        (save-restriction
          (narrow-to-region opoint epoint)
          (dolist (rep replacement)
            (when (cdr rep)
              (save-excursion
                (goto-char (point-min))
                (replace-buffer (car rep) (cdr rep)))))))
      (when mode-specific-indent-command
        (indent-region (x-point opoint 'previous-line 'goto-eol)
                       (x-point epoint 'next-line 'goto-bol)))
      (when (and cursor (not *prefix-args*))
        (dolist (anchor (if (listp cursor) cursor (list cursor)))
          (when (scan-buffer anchor :limit opoint :reverse t)
            (goto-char (match-end 0))
            (start-selection 2 t)
            (goto-char (match-beginning 0))
            (return)))))))


(provide "guidgen/editor/command")

;; End
