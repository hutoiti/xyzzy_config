;;; funsig.l - lisp���[�h�ŁA�J�[�\���ʒu�t�߂̊֐��Ăяo���̃V�O�l�`����\������B
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
;; �C���X�g�[��
;; ============
;;
;; funsig.l�����[�h�p�X�ɔz�u�������ƁA~/.xyzzy�Ɏ��̂悤�ɐݒ肵�܂��B
;;
;;     (autoload 'funsig-show-signature "funsig" t)
;;     (define-key ed::*lisp-mode-map* #\C-\; 'funsig-show-signature)
;;
;; ���ۂɃo�C���h����L�[�͓K���ɑI��ł��������B
;;
;;
;; funsig.lst�t�@�C���͕s�v�ɂȂ�܂���
;; ------------------------------------
;;
;; �ȑO�̔łŕK�v�������V�O�l�`���̃��X�g�ł���funsig.lst�t�@�C���͕K�{�ł�
;; �Ȃ��Ȃ�܂����B�V�O�l�`�����X�g�t�@�C��������ΗD�悵�ĎQ�Ƃ��܂����A��
;; ���Ă����삵�܂��B�s�v�ł���΍폜���Ă��������B
;;
;; �܂��V�O�l�`�����X�g�t�@�C���̈ʒu�Ɩ��O�������ϐ�
;; *funsig-signature-list*�̃f�t�H���g�l��ύX���܂����B�ȑO�̔łł́Axyzzy
;; �̃C���X�g�[���f�B���N�g������etc�f�B���N�g����funsig.lst�t�@�C���̃f�t
;; �H���g�̈ʒu�ƂȂ��Ă��܂����B�폜����ꍇ�͒��ӂ��Ă��������B
;;
;; �Ƃ��Ȃ��āA�V�O�l�`�����X�g���쐬���邽�߂ɓ������Ă����t�@�C����
;; funsigmk.l��funsigmk.lc�Afunsig.xsl�͖����Ȃ�܂����B���[�h�p�X��xyzzy��
;; �C���X�g�[���f�B���N�g���Ɏc���Ă���ꍇ�͍폜���Ă��������B
;;
;;
;; �g����
;; ======
;;
;; lisp-mode�ȂǂŎg���܂��Bfunsig-show-signature �R�}���h�ŁA�J�[�\���ʒu
;; �t�߂̊֐�����T���A���̊֐��ɑΉ�����V�O�l�`����\�����܂��B�J�[�\����
;; �֐����̏�ɂ���K�v�͂���܂���B�J�[�\���ʒu���O���œK���Ȋ֐�����T
;; ���܂��B
;;
;; �V�O�l�`���̕\���̓|�b�v�A�b�v�ɂ��邩�X�e�[�^�X�G���A�ɂ��邩�I�ׂ܂��B
;; (*funsig-popup-signature*)
;;
;; funsig-add-signature�R�}���h���g����*funsig-signature-list*�ϐ��������t
;; �@�C���ɐV�����V�O�l�`����ǉ����܂��B�Ǝ��̕\�����s�������Ƃ��Ɏg���Ă�
;; �������B
;;
;;
;; �A����
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
;�p�~
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