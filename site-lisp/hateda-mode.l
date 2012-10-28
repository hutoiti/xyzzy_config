;;
;;
;; �� hateda-mode ��
;;  -- �͂Ăȃ_�C�A���[�p�̃��W���[���[�h�Ƃ͂ă_���Ƃ̘A�g�c�[��
;;
;;
;; ++++++++++++++++++++++++++++
;; �����ӎ���
;;      ���ۏ؂ł��B
;;
;; ++++++++++++++++++++++++++++
;; ���K�v�Ȃ���
;;      �͂ă_���ƘA�g����ꍇ�ɂ͂͂ă_���i���͂Ăȃ_�C�A���[���C�^�[�j
;;      �i����_����ɂ��F�vPerl�Fhttp://www.hyuki.com/techinfo/hatena_diary_writer.html�j
;;
;; ++++++++++++++++++++++++++++
;; ���C���X�g�[�����@
;;      hateda-mode �� ~/site-lisp/ �ɂ����āA
;;      �ȉ��� .xyzzy �� siteinit.l �ɋL�q���Axyzzy ���ċN������
;;      -------------------
;;      (require "hateda-mode")
;;      ;; �ȉ��͂͂ă_���ƘA�g����ꍇ�̂݁B�ݒ肵�Ȃ��ꍇ�ɂ͖���u���Ă��܂�
;;      (setf hw::*hatedara-multi-accounts*
;;            '(("userA" nil "~/etc" "-t")
;;              ("userB" nil "c:/data/userB/" nil)
;;              ("userC" nil "c:/" nil)
;;              ;("���[�U��" "�p�X���[�h" "�f�B���N�g��" "�͂ă_���ɖ���n������")
;;              ))
;;
;;      �ȉ��̂悤�� g:�O���[�v��:���[�U�� �Ə����ƃO���[�v�ɓ��e����܂��B
;;      �imiyamuko����ɂ��p�b�`���Ƃ肱�݂܂����j
;;      (setf hw::*hatedara-multi-accounts*
;;            '(("userA" nil "~/hatena/userA" "-t")
;;              ("g:groupA:userA" nil "~/hatena/groupA" "-t")))

;;      ---------------------
;;
;; ++++++++++++++++++++++++++++
;; ���g����
;;      M-x hw::hw                   �����̓��t�̂͂ă_���t�@�C�����J���܂�
;;      M-x hw::hateda-mode          �͂ă_���[�h�����s���܂�
;;      M-x hw::hws                  �^�C�g���ꗗ
;;
;;  �� �͂ă_���[�h�̃L�[�o�C���h
;;      C-*     �I��͈͂��A�Ȃ���Ό��ݍs�����o���ɂ��܂�
;;      C--     �I��͈͂��A�Ȃ���Ό��ݍs�����X�g�ɂ��܂�
;;      C-+     �I��͈͂��A�Ȃ���Ό��ݍs�𐔎������X�g�ɂ��܂�
;;      C->     �I��͈͂��A�Ȃ���Ό��ݍs�����p�ɂ��܂��i>> .. <<)
;;      C-|     �I��͈͂��A�Ȃ���Ό��ݍs��Pre�L�@�ł�����܂��i>| .. |<)
;;      C-M-|   �I��͈͂��A�Ȃ���Ό��ݍs���X�[�p�[Pre�L�@�ł�����܂��i>|| .. ||<)
;;      C-c c   �͂ă_�����g���ē��e���܂�
;;      C-c u   �͂ă_�����g���Č��ݕҏW���̃t�@�C���𓊍e���܂�
;;
;; ��Shift-JIS�œ��L�������Ă��āA�O���[�v�֓��e����ꍇ�̒���
;;     �O���[�v�t�H���_�Ɉȉ��̂Q�s���L������ config.txt �t�@�C����z�u���Ă��������B
;;         client_encoding:Shift_JIS
;;         server_encoding:UTF-8
;;     �ڍׂ͈ȉ����Q�Ƃ��Ă��������B
;;     http://www.hyuki.com/techinfo/hatena_diary_writer.html#faq_groupdiary
;;
;; ++++++++++++++++++++++++++++
;; ���ӎ�
;;      ���̃v���O�����������ɂ������� wiki-mode.l ���Q�l�ɂ����Ă��������܂����B
;;      �ihttp://www5d.biglobe.ne.jp/~lostland/xyzzy/�j
;;
;; ++++++++++++++++++++++++++++
;; �����C�Z���X
;;      ���̃\�[�X�R�[�h�ɂ� NYSL Version 0.9982 ���K�p����܂��B
;;      �𕶂̓t�@�C���̖����ɕt�^����Ă��܂��B
;; 2007/09/10   ver.0.3.1   �O���[�v�ւ̓��e�ɂ��Ă̒��ӂ�ǉ����܂����B
;; 2007/07/18   ver.0.3	    amefura ����ɂ��ύ��܂� hateda-mode ����荞�݂܂����B
;;                          miyamuko ����ɂ��O���[�v�ւ̓��e�p�b�`����荞�݂܂����B
;; 2006/09/19   ver.0.2.2   �s��Ή��ENetinstaller�Ή�
;; 2006/05/24   ver.0.2.1   �s��Ή�
;; 2006/05/23   ver.0.2     �}���`�A�J�E���g�Ή��A�ҏW�֐���ǉ�
;; 2006/05/16   ver.0.1     ���J

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "hatena")
	(defpackage "hatena"
	  (:use "lisp" "editor" "user")
	  (:nicknames "hw"))
	))

(provide "hateda-mode")
(in-package "hatena")

;; hateda-mode
(defvar *hateda-mode-hook* nil)
(defvar *hateda-edit-with-region* nil)
(defvar *hateda-edit-with-line* t)

;; hatedara
(defvar *hatedara-submit-hook* nil)
(defvar *hatedara-after-submit-hook* nil)
(defvar *hatedara-multi-accounts* nil)
;;

(export '(*hateda-mode-hook*
          *hateda-mode-map*
          hateda-mode
          ))

(export '(*hatedara-submit-hook*
		  *hatedara-after-submit-hook*
		  *hatedara-multi-accounts*
		  hw hws hwv))

(export '(
          *hateda-headline-color*
          *hateda-readnext-color*
          *hateda-footnote-color*
          *hateda-entity-color*
          *hateda-comment-color*
          *hateda-list-color*
          *hateda-table-color*
          *hateda-quote-color*
          *hateda-pre-color*
          *hateda-autolink-color*
          *hateda-stoptag-color*
          *hateda-bold-color*
          ))

(defvar *hateda-local-variable-list*
  '(hateda-mode
    hateda-regexp-keyword-list
    ))

(defvar *hateda-headline-color* '(:color 9 12 :line :bold))
(defvar *hateda-readnext-color* '(:color 2 3 :line))
(defvar *hateda-footnote-color* '(:color 4 5))
(defvar *hateda-entity-color* '(:keyword 2 :bold))
(defvar *hateda-comment-color* '(:keyword :comment))
(defvar *hateda-list-color* '(:color 2 0 :bold))
(defvar *hateda-table-color* '(:color 3 0 :bold))
(defvar *hateda-quote-color* '(:color 6 0 :line))
(defvar *hateda-pre-color* '(:color 5 0 :line))
(defvar *hateda-autolink-color* '(:color 7 0))
(defvar *hateda-stoptag-color* '(:color 8 7))
(defvar *hateda-bold-color* '(:color 0 0 :bold))

(defvar *hateda-mode-map* nil)
(unless *hateda-mode-map*
  (setq *hateda-mode-map* (make-sparse-keymap))
  (define-key *hateda-mode-map* '(#\C-c #\c) 'hatedara-submit)
  (define-key *hateda-mode-map* '(#\C-c #\u) 'hatedara-submit-this)
  (define-key *hateda-mode-map* '#\C-+ 'hateda-num-list)
  (define-key *hateda-mode-map* '#\C-- 'hateda-list)
  (define-key *hateda-mode-map* '#\C-* 'hateda-heading)
  (define-key *hateda-mode-map* '#\C-> 'hateda-quote)
  (define-key *hateda-mode-map* '#\C-\| 'hateda-pre)
  (define-key *hateda-mode-map* '#\C-M-\| 'hateda-super-pre)
  )

(defun hateda-mode (&optional (arg nil sv))
  "hateda-mode"
  (interactive)
  (kill-all-local-variables)
  (mapc 'make-local-variable *hateda-local-variable-list*)
  (setq mode-name "hateda")
  (setq buffer-mode 'hateda-mode)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'hateda-build-summary-of-documents)
  (make-local-variable 'regexp-keyword-list)
  (setq hateda-regexp-keyword-list
        (compile-regexp-keyword-list
  `(
      ("^\\*\\{1,3\\}.+$" nil ((0 . ,*hateda-headline-color*)))
      ("^=====?$" nil ((0 . ,*hateda-readnext-color*)))
      ("^\\(\\+\\{1,3\\}\\|-\\{1,3\\}\\).*$" nil ((1 . ,*hateda-list-color*)))
      ("^\\(:\\)[^:]+\\(:\\).*$" nil ((1 . ,*hateda-list-color*) (2 . ,*hateda-list-color*)))
      ("^\\(|\\).+\\(|\\)$" nil ((1 . ,*hateda-table-color*) (2 . ,*hateda-table-color*)))
      ("((\\(.+\\)))" nil ((1 . ,*hateda-footnote-color*)))
      ("&#x?[0-9a-f]\\{5\\};" nil ((0 . ,*hateda-entity-color*)))
      ("^\\(>>\\|<<\\)$" nil ((0 . ,*hateda-quote-color*)))
      ("^\\(>|\\||<\\|>||\\|||<\\)$" nil ((0 . ,*hateda-pre-color*)))
      ("^\\(><.*\\|.*><\\)$" nil ((0 . ,*hateda-stoptag-color*)))
      ("s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+" nil ((0 . ,*hateda-autolink-color*)))
      ("\\(id\\|question\\|a\\|b\\|d\\|f\\|g\\|idea\\|i\\|r\\|graph\\|map\\|isbn\\|asin\\|jan\\|ean\\):\\([^\"' \t]+\\)"
       nil ((1 . ,*hateda-bold-color*)
            (2 . ,*hateda-autolink-color*)))
      ("\\[\\[\\(.+\\)\\]\\]" nil ((1 . ,*hateda-autolink-color*)))
      ("\\[\\(keyword\\|d\\|b\\|search\\):\\(.+\\)\\]"  nil ((1 . ,*hateda-bold-color*)
                                                                     (2 . ,*hateda-autolink-color*)))
      )))
  (setq regexp-keyword-list hateda-regexp-keyword-list)
  (setq comment-start "<!--")
  (setq comment-end "-->")
  (setq comment-start-skip "<!--[ \t]*")
  (use-keymap *hateda-mode-map*)
  (run-hooks '*hateda-mode-hook*))



(defun hateda-build-summary-of-documents ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "^\\*\\{1,3\\}.+$" :regexp t :tail t)
        (push (list (current-line-number) (match-string 0)) result)))
      (sort result #'< :key #'car)))


(defun hateda-list ()
  (interactive)
  (hateda-add-prefix "-"))

(defun hateda-num-list ()
  (interactive)
  (hateda-add-prefix "+"))

(defun hateda-heading ()
  (interactive)
  (hateda-add-prefix "*"))

(defun hateda-add-prefix (prefix)
  (cond ((pre-selection-p)
         (hateda-add-prefix-selection prefix))
        (*hateda-edit-with-region*
           (hateda-add-prefix-region prefix))
        (*hateda-edit-with-line*
           (hateda-add-prefix-line prefix))))

(defun hateda-add-prefix-region (prefix)
  (let ((start (mark))
        (end (point)))
    (when (and (numberp start) (numberp end))
      (rotatef *quotation-prefix* prefix)
      (quote-region start end)
      (rotatef *quotation-prefix* prefix))
    ))

(defun hateda-add-prefix-selection (prefix)
    (selection-start-end (start end)
      (save-excursion
        (rotatef *quotation-prefix* prefix)
        (quote-region start end)
        (rotatef *quotation-prefix* prefix))))

(defun hateda-add-prefix-line (prefix)
  (save-excursion (goto-bol) (insert prefix)))

(defun hateda-quote ()
  (interactive)
  (hateda-box-in ">>" "<<"))

(defun hateda-pre ()
  (interactive)
  (hateda-box-in ">|" "|<"))

(defun hateda-super-pre ()
  (interactive)
  (hateda-box-in ">||" "||<"))

(defun hateda-box-in (st ed)
  (cond ((pre-selection-p)
         (hateda-box-in-selection st ed))
        (*hateda-edit-with-region*
           (hateda-box-in-region st ed))
        (*hateda-edit-with-line*
           (hateda-box-in-line st ed))))

(defun hateda-box-in-selection (st ed)
  (selection-start-end (from to)
    (save-excursion
      (when (> from to) (rotatef from to))
      (goto-char from) (hateda-insert-bol st)
      (goto-char to) (hateda-insert-eol ed)
      )))

(defun hateda-box-in-region (st ed)
  (let ((start (mark))
        (end (point)))
    (when (and (numberp start) (numberp end))
      (goto-char from) (hateda-insert-bol st)
      (goto-char to) (hateda-insert-eol ed)
      )))

(defun hateda-box-in-line (st ed)
  (save-excursion
     (hateda-insert-bol st) (hateda-insert-eol ed)
    ))

(defun hateda-insert-bol (str)
  (unless (bolp) (goto-bol))
  (insert str)
  (newline))

(defun hateda-insert-eol (str)
  (unless (eolp) (goto-eol))
  (newline)
  (insert str))





(defun hw ()
  "Make Today's Hateda File"
  (interactive)
  (let (fname dir usr)
	(if (and (or (and *hatedara-multi-accounts*
					  (setf dir (setq usr(hatedara-get-dir-by-usr
								 (completing-read "���[�U��: " (mapcar 'car *hatedara-multi-accounts*)
												  :default (caar *hatedara-multi-accounts*)
												  ))))
					  dir)
				 (setf dir (read-directory-name "�͂ă_���t�H���_: ")))
			 (file-exist-p dir))
		(progn(hatedara-make-file dir)(hatedaro-data-read usr))
	  (message "�͂ă_���t�H���_��ݒ肵�Ă�������"))))


;; (defun hatedara-get-dir-by-usr (usr)
;;   (dolist (item *hatedara-multi-accounts*)
;;     (if (equal usr (car item))
;;         (return (third item)))))
(defun hatedara-get-dir-by-usr (usr)
  (caddar(member usr *hatedara-multi-accounts* :test 'equal :key 'car)))

(defun hatedara-make-file (dir)
  (let ((fname (merge-pathnames (format-date-string "%Y-%m-%d.txt") dir)))
	(find-file fname)
	(hateda-mode)))


(defun hatedara-submit ()
  "Exec Hatena Diary Writer"
  (interactive)
  (let* ((nowdir (directory-namestring (get-buffer-file-name)))
         (id (hatedara-get-account nowdir)))
    (unless id (error "�A�J�E���g���s���ł�"))
    (if (yes-or-no-p (concat "id:" (first (car id)) " �ł͂ă_�������s���܂�\n" nowdir))
        (let* ((lst (car id))
              (user (first lst))
              (pass (second lst))
              (dir (third lst))
			   (arg (fourth lst)))
          (call-hatedara dir user pass arg)
          (message "�͂ă_�������s���܂���"))
      (message (concat "�͂ă_���͎��s����܂���ł���" (first (car id)))))
    ))

(defun hatedara-submit-this (&optional chottosita)
  (interactive)
  (let* ((dir (directory-namestring (get-buffer-file-name)))
         (id (hatedara-get-account dir))
         (unless id (error "�A�J�E���g���s���ł�"))
         (send (concat " -f " (get-buffer-file-name)
                       (and chottosita " -t"))))
    (unless id (error "�A�J�E���g���s���ł�"))
    (if (yes-or-no-p (concat "id:" (first (car id)) " �Ō��݂̃t�@�C���𓊍e���܂�\n" dir))
        (let* ((lst (car id))
               (user (first lst))
               (pass (second lst))
               (dir (third lst))
			   (arg (concat (fourth lst) send)))
          (call-hatedara dir user pass arg)
		  (message "���݂̃t�@�C���𓊍e���܂���"))
      (message "�͂ă_���͎��s����܂���ł���"))
	))

;;(defun call-hatedara (dir user pass arg)
(defun call-hatedara (dir account pass arg)
  (let ((encoding (buffer-fileio-encoding))
        (win (selected-window)) group user)
    (set-buffer-fileio-encoding *encoding-utf8*)
    (set-buffer-modified-p t)
    (hatedara-save-data t)
    (run-hooks *hatedara-submit-hook*)
    (multiple-value-bind (group user)
        (hatedara-parse-account account)
      (execute-subprocess
         (concat
            "perl" " " (merge-pathnames "hw.pl" dir)
            (if group (concat " -g " group) "")
            " -u " user " -p " pass " " arg)))
    (run-hooks *hatedara-after-submit-hook*)
    (if win (set-window win))
    (set-buffer-fileio-encoding encoding)
;    (set-buffer-modified-p t)
    (save-buffer)))

(defun hatedara-get-account (&optional dir)
  (let ((id (hatedara-get-account-by-dir dir)))
    (unless (hatedara-check-account id)
      (setf id (hatedara-account-config dir)))
    (setf *debug* id)
    (unless id (error "�A�J�E���g���擾�ł��܂���"))
    (unless (hatedara-check-account id)
      (error "�A�J�E���g���s���ł�"))
    id))


(defun hatedara-account-config (&optional dir)
  (setf dir  (read-directory-name "directory: " :default dir))
  (let ((id (hatedara-get-account-by-dir dir))
		user pass lst)
	(when id
	  (setf user (first (car id))
			pass (second (car id))
			dir  (third (car id))))
	(unless (file-exist-p dir)
	  (error "���݂��Ȃ��f�B���N�g���ł�")
	  ;;(return nil)
	  (quit)
	  )
	(setf user (read-string "username: " :default user))
	(setf pass (read-string "password: " :default pass))
	(if id
		(progn (pop (car id)) (push user (car id))
		  (pop (cdar id)) (push pass (cdar id))
		  (pop (cddar id)) (push dir (cddar id)))
	  (progn
		(pushnew (list user pass dir nil) *hatedara-multi-accounts*)))
	(hatedara-get-account-by-dir dir)))

(defun hatedara-check-account (id)
  (let ((lst (car id)))
    (and (listp lst) (>= (length lst) 3)
         (stringp (first lst)) (stringp (second lst)) (file-exist-p (third lst)) lst)))


;; (defun hatedara-get-account-by-dir (dir)
;;   (let ((pt *hatedara-multi-accounts*))
;;     (while pt
;;       (if (path-equal dir (caddar pt))
;;           (return pt))
;;   (setf pt (cdr pt)) nil)
;;   ))
(defun hatedara-get-account-by-dir (dir)
  (member dir *hatedara-multi-accounts* :test 'path-equal :key 'caddr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �{���p�̃��[�h
(defun hatedara-now-buffer-data(&optional post)
  (save-excursion
	(goto-char(point-min))
	(let*((fp (get-buffer-file-name))
		  (fwt (file-write-time fp))
		  (pn (pathname-name fp))
		  (pnl (split-string pn #\-))
		  (y (parse-integer(car pnl)))
		  (m (parse-integer(cadr pnl)))
		  (d (parse-integer(caddr pnl)))
		  (unvt (encode-universal-time 0 0 0 d m y))
		  (data (list
				 (list(buffer-substring
					   (progn(goto-bol)(point))
					   (progn(goto-eol)(point)))
					  unvt fwt fp pn post(point)
					  ))))
	  (while(scan-buffer "^\\(\\*.*\\)" :regexp t :no-dup t)
		(push
		 (list (match-string 0)
			   unvt fwt fp pn post
			   (match-beginning 0))
		 data))
	  data)))


(defvar *hatedara-data* nil)
(defvar *hw-data-file* ".hatedara" )
(defvar *hw-summary-buffer* "*hwS*")
(defvar *hw-view-buffer* "*hwV*")


;save
(defun hatedara-save-data(&optional post)
  (let(r (now (hatedara-now-buffer-data post)))
	(dolist (x *hatedara-data*(setq *hatedara-data* r))
	  (unless(equal(nth 3 (car now)) (nth 3 (car x)) )
		(push x r)))
	(with-open-file (f (merge-pathnames *hw-data-file*
										(directory-namestring
										 (get-buffer-file-name)))
					   :direction :output
					   :if-exists :overwrite
					   :if-does-not-exist :create)
	  (format f "~S" (push now hw::*hatedara-data*)
			  ))
	))

(defun hatedara-no-submit-save-data()
  (and(eq buffer-mode 'hateda-mode)(hatedara-save-data)))

(add-hook '*after-save-buffer-hook* 'hw::hatedara-no-submit-save-data)
;hw-summary
(defun hatedaro-data-read(usr)
  (let(a b)
	(with-open-file (f (merge-pathnames *hw-data-file*
										(hatedara-get-dir-by-usr usr))
					   :direction :input
					   :if-exists :overwrite
					   :if-does-not-exist :create)
	  (cond((setq a (read f nil))
			(setq *hatedara-data* a))
		   (t (setq *hatedara-data* '(nil)))))
	a))

(setq *hw-file*(make-hash-table :test 'equal))
(defun hws()
  (interactive)
  (let((dt(hatedaro-data-read
		   (completing-read "User: "
							(mapcar 'car *hatedara-multi-accounts*)
							:default (caar *hatedara-multi-accounts*)
							)))
	   (current (selected-buffer))
	   buf re r)
	(dolist (x dt re)
	  (dolist(y x r)
		(push (list(if (nth 5 y) 0 1)
				   (format-date-string "%Y-%m-%d (%a)"(nth 1 y))
				   (nth 0 y)
				   (format-date-string "%y-%m-%d (%a)%H:%M:%S"(nth 2 y))) r)))
	(and(find-buffer *hw-summary-buffer*)(delete-buffer *hw-summary-buffer*))
	(setq buf (get-buffer-create *hw-summary-buffer*))
	(set-buffer buf)
	(insert
	 (format nil "~{~{~&~[@~:;~~~] ~@20,,,' A~@80,,,' A(Last Modified:~A)~%~}~}" r))
	(goto-char(point-min))
	(hw-summary-mode)
	(set-buffer current)
	(pop-to-buffer buf t)
	;;(other-window)
	(dolist(x *hatedara-data*)
	  (dolist (y x )
		(setf (gethash(nth 4 y) *hw-file*)(nth 3 y) )))
	))

(defun hw-summary-mode()
  (setq mode-name "hws")
  (setq buffer-mode 'hw-summary-mode)
  (make-local-variable 'need-not-save)
  (make-local-variable 'auto-save)
  (make-local-variable 'buffer-read-only)
  (set-buffer-modified-p nil)
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq auto-save nil)
  (use-keymap *hw-summary-mode-map*)
  (set-local-window-flags
   (selected-buffer)
   (+ *window-flag-line-number*
	  *window-flag-tab* *window-flag-newline*
	  *window-flag-hscroll-bar* *window-flag-eof*
	  *window-flag-fold-line* *window-flag-fold-mark*
	  ) nil)
  (set-buffer-fold-type-none))

(defun hwv(&optional file)
  (interactive "P")
  (when(eq(buffer-name(selected-buffer)) *hw-summary-buffer*)
	(let((line (save-excursion
				 (buffer-substring
				  (progn(goto-bol)(point))
				  (progn(goto-eol)(point)))))
		 (current (selected-buffer))
		 day buf path)
	  (setq day(nth 1(split-string line #\SPC)))
	  (setq path (gethash day *hw-file*))
	  (cond(file (other-window)(find-file path)(hateda-mode))
		   (t(and(find-buffer *hw-view-buffer*)(delete-buffer *hw-view-buffer*))
			 (setq buf (get-buffer-create *hw-view-buffer*))
			 ;;(other-window)
			 (set-buffer buf)
			 (and path (insert-file-contents path))
			 (hw-summary-mode)
			 (set-buffer current)
			 (pop-to-buffer buf t)
			 (other-window)
			 )))))

(defun hwv-next-line()
  (interactive)
  (forward-line 1)(hwv))

(defun hwv-previous-line()
  (interactive)
  (forward-line -1)(hwv))
(defun hw-close()
  (interactive)
  (and
   (find-buffer *hw-summary-buffer*)(delete-buffer *hw-summary-buffer*)
   (find-buffer *hw-view-buffer*)(delete-buffer *hw-view-buffer*))
  (delete-other-windows))
(defun hwv-scroll-up()
  (interactive)
  (scroll-other-window (window-height)))
(defun hwv-scroll-down()
  (interactive)
  (scroll-up-other-window (window-height)))

(defvar *hw-summary-mode-map* nil)
(unless *hw-summary-mode-map*
  (setq *hw-summary-mode-map* (make-sparse-keymap))
  (define-key *hw-summary-mode-map* #\RET 'hwv)
  (define-key *hw-summary-mode-map* #\SPC 'hwv-scroll-down)
  (define-key *hw-summary-mode-map* #\C-h 'hwv-scroll-up)
  (define-key *hw-summary-mode-map* #\q 'hw-close)
  (define-key *hw-summary-mode-map* #\C-p 'hwv-previous-line)
  (define-key *hw-summary-mode-map* #\Up 'hwv-previous-line)
  (define-key *hw-summary-mode-map* #\C-n 'hwv-next-line)
  (define-key *hw-summary-mode-map* #\Down 'hwv-next-line)
  )

(defun hatedara-parse-account (account)
  (if (string-matchp "g:\\([a-zA-Z0-9_]+\\):\\([a-zA-Z0-9_]+\\)" account)
      (values (match-string 1) (match-string 2))
    (values nil account)))




;; NYSL Version 0.9982
;;
;; A. �{�\�t�g�E�F�A�� Everyone'sWare �ł��B���̃\�t�g����ɂ�����l��l���A
;;    �������̍�������̂������̂Ɠ����悤�ɁA���R�ɗ��p���邱�Ƃ��o���܂��B
;;
;;   A-1. �t���[�E�F�A�ł��B��҂���͎g�p������v�����܂���B
;;   A-2. �L��������}�̂̔@�����킸�A���R�ɓ]�ځE�Ĕz�z�ł��܂��B
;;   A-3. �����Ȃ��ނ� ���ρE���v���O�����ł̗��p ���s���Ă��\���܂���B
;;   A-4. �ύX�������̂╔���I�Ɏg�p�������̂́A���Ȃ��̂��̂ɂȂ�܂��B
;;        ���J����ꍇ�́A���Ȃ��̖��O�̉��ōs���ĉ������B
;;
;; B. ���̃\�t�g�𗘗p���邱�Ƃɂ���Đ��������Q���ɂ��āA��҂�
;;    �ӔC�𕉂�Ȃ����̂Ƃ��܂��B�e���̐ӔC�ɂ����Ă����p�������B
;;
;; C. ����Ґl�i����oosawa�ɋA�����܂��B���쌠�͕������܂��B
;;
;; D. �ȏ�̂R���́A�\�[�X�E���s�o�C�i���̑o���ɓK�p����܂��B