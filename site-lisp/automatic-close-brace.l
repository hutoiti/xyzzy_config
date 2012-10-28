
#|

�Ή����銇�ʂȂǂ������I�ɑ}������ Lisp �ł��

��
*

������->

(*)

if(true)
{
������->

if(true)
{
*
}

*�J�[�\���ʒu
���Ƃ���(�Ɋ��蓖�ĂĂ���̂�(���������Ƃ��ɔ������܂��B))

�@�\

�Ή����銇�ʂ������I�ɓ��ꂽ��A����Ȃ������肵�܂��B
�i�܂�������Ɛl�Ԃ̈Ӑ}�����ݎ��؂�܂��񂪂����ԃI�[�g�ŏo����悤�ɂȂ����Ǝv���܂��B�j
����� �C���f���g���܂��B

�g�ݍ��ݕ�

����Lisp�\�[�X(automatic-close-barace.l)��ǂݍ��ނ����ł��

��
(xyzzy�t�H���_)/site-lisp/�Ƀ\�[�X�����
(load-library "automatic-close-barace.l")
��
.xyzzy�ɏ���
�Ȃ�

�g����

c�̏ꍇ�̗�������܂��B

(defun my-setting-c ()

  (setq c-brace-offset -2)
  (setq c-label-offset 0)
  (abbrev-mode t)

  (define-key ed::*c-mode-map* #\{ 'electric-brace-insert)
  (define-key ed::*c-mode-map* #\( 'electric-brace-insert)
  (define-key ed::*c-mode-map* #\[ 'electric-brace-insert)

  (define-key ed::*c-mode-map* #\TAB 'c-indent-line)
  )
(add-hook 'ed::*c-mode-hook* 'my-setting-c)

���̂ق��̐ݒ���@

�Ȃ�

����

���J

()�ȊO�ɑΉ�
{}���������ɃA�����W
()�����Ƃ��l���ĕ���K�v�����f����B

2005/01/27
�R�����g�̑O���󔒂̏ꍇ���l��

2005/01/11
���傱���� ���P�i�J�[�\���s�̊��ʂ̐����ȒP�Ƀ`�F�b�N�j

2004/12/29
c-indent-level ���ԐړI�ɌĂ�ł����Ƃ�����C��

2003/11/29
�\�[�X����̃t�@�C���ɂ܂Ƃ߂��




TKI
start@afis.To
http://www.Afis.To/~start/


|#
(defun electric-brace-insert ()
  (interactive)

  ;(c-electric-insert)
  (unless (prog1
              (parse-point-syntax)
            (self-insert-command)
            )
    ;    (c-indent-line)
    (funcall mode-specific-indent-command)
    )

  (cond ((equal #\( *last-command-char* )
         (insert-char-at-value-with-check-move #\))
         )
        ((equal #\[ *last-command-char*)
         (insert-char-at-value-with-check-move #\])
         )
        ((equal #\< *last-command-char*)
         (insert-char-at-value-with-move #\>)
         )
        ((equal #\{ *last-command-char*)
         (insert-char-at-value-with-check-move #\})
         (insert "\n")
         (funcall mode-specific-indent-command)
         (insert "\n")
         (funcall mode-specific-indent-command)
         (backward-line)
         (funcall mode-specific-indent-command);(c-indent-line)
         )
        ((string-match "[])}]" (format nil "~A" *last-command-char*)) (insert-char-at-value-with-check-move *last-command-char* 1))
        (t (insert-char-at-value-with-check-move *last-command-char*))
        )
  (clear-message)
  (sit-for .05)
  )
#|
(equal #\{ *last-command-char*)
;(insert "}")
(let ((np)(dof))
  (setq np (point))
  (sit-for 1)
  (beginning-of-line)
  (setq *last-command-char* #\TAB)
  (c-indent-line)
  ;(setq dof (= np (1+(point))))
  (setq dof nil)
  (goto-char np)
  (when dof
    (forward-char)
    (setq *last-command-char* #\RET)
    (c-newline-and-indent)
    )
  (setq *last-command-char* #\})
  (c-electric-close)
  (when dof
    ;(backward-line)
    (previous-virtual-line)
    (forward-char)
    (setq *last-command-char* #\RET)
    (c-newline-and-indent)
    (previous-virtual-line)
    (setq *last-command-char* #\TAB)
    (c-indent-line)
    )
  (unless dof
    (backward-char))
  ;(msgbox "insert }");
  |#

(defun insert-char-at-value-with-check-move (ch &optional dir)
  (let ((np)(ddf)(midp)(ip))

    (backward-char)
    (setq np (point))
    (setq ip (buffer-substring np (+ np 1)))

    (if (check-pair-paren)
        ;���ʂ��Ή�����
      ;
      (progn
        ; �����ꂽ���ʂ������Ă݂Ă� �Ή����銇�ʂ����邩�`�F�b�N -> ddf
        (ignore-errors
         (goto-matched-parenthesis)
         )
        (setq midp (point))

        (goto-char np)
        (delete-char)
        (goto-char (1- midp)) ; �폜����������
        (setq ddf (check-pair-paren))
        (goto-char np)
        (insert ip)


        ; �����ꂽ���ʂ��e�����Ȃ��悤�Ȃ� �Ή����ʂ��}��
        (when ddf
          (goto-char (+ np 1))
          ;1�s���� �Ή� ���ʐ��`�F�b�N
          ; �������Ȃ� �}�����Ȃ�
          ;         (msgbox "~A ~A \n ~A ~A "
          ;                ch (count-char-line ch (+ np 1))
          ;                ip(count-char-line ip(+ np 1)) ip)
          (if (not (= (count-char-line ch (+ np 1))
                      (count-char-line ip(+ np 1)) ))

              (progn
                (goto-char (+ np 1))
                (setq np (1+ np))
                (unless dir(check-first-char-in-the-line ip)
                  (if (= np (point)) (setq np nil) (setq np (+ 1 np)))
                  )
                (insert-char-at-value-with-move ch dir np)
                )
            );if
          );when
        );progn

      ;���̍����ꂽ���ʂɑΉ����銇�ʂ��Ȃ�  -> �������ɑΉ����ʑ}��
      (progn
        (goto-char (+ np 1))
        (setq np (1+ np))
        (unless dir(check-first-char-in-the-line ip)
          (if (= np (point)) (setq np nil) (setq np (+ 1 np)))
          )
        (insert-char-at-value-with-move ch dir np)
        )


      );if
    ;	(message "~d ~d (~a : ~a)" np midp ip ddf)
    );let
  );defun

;for debug
(defun char-wait (ch)
  (insert ch)
  (backward-char)
  (sit-for 1.2)
  (delete-char)
  )

(defun check-pair-paren()
  (let ((nowp)(afterp)(midp))
    (setq nowp (point))

    (ignore-errors
     (goto-matched-parenthesis)
     (setq midp (point))

     (goto-matched-parenthesis)
     (setq afterp (point))
     )

    (goto-char nowp)
    #|    (msgbox "~A ~A \n ~A ~A \n ~A ~A"
nowp (buffer-substring nowp (1+ nowp))
midp (buffer-substring midp (1+ midp))
afterp (buffer-substring afterp (1+ afterp))
)
|#
    (and (= afterp nowp)
         (not(= nowp midp)))
    )
  )

(defun insert-char-at-value-with-move (ch &optional dir pt)
  ;  (c-electric-insert)
  ;  (insert ch)
  (setq *last-command-char* ch)
  (c-electric-close)

  (when pt (goto-char pt)
    )
  (if dir
      (forward-char dir)
    (backward-char))
  (funcall mode-specific-indent-command)
  )

;( { [ �̎� �����Ă�
(defun check-first-char-in-the-line (ch)
  (let ((fp)(cp))
    (setq cp (point))

    ;�ŏ��̊��ʂ������� �s���� �}��
    (goto-bol)(setq fp (point))
    (if (and (scan-buffer (format nil "~A" ch) :left-bound fp :right-bound cp)
             (= (+ 1 (point)) cp))
        (progn
          (goto-char cp)
          (delete-horizontal-spaces)
          (goto-eol)

          (while (and (or (equal (parse-point-syntax) :comment)
                            (looking-back " ")
                            (looking-back "\t"))
                      (> (point) cp))
            (backward-char)
          )
          )
      (progn
        (goto-char cp)
        ;���ʑ}�����オ ����
        ;     (if (looking-at "[({[]") (goto-matched-parenthesis)
        ;���ʑ}�����オ �󔒂łȂ��ꍇ �P����Ƃ΂�
        (if (looking-at "[^]}) 	\n({[]") (forward-sexp))
        ;       )
        )
      )
    )
  )


(defun execute-region (func from to)
  (if (> from to)
      (rotatef from to))
  (save-excursion
    (save-restriction
      (narrow-to-region from to)
      (goto-char from)
      (funcall func)
      ))
  )

(defun count-char-region (ch from to)
  (save-excursion
    (let ((count 0) (k))
      (if (characterp ch) (setq ch (format nil "~A" ch)))
      (setq k (- to from))
      (dotimes (i k)
        (if (equal ch (buffer-substring (+ from i) (+ from i 1))) (setq count (+ count 1)))
        )
      count
      )
    )
  )

(defun count-char-line (ch &optional pt)
  (save-excursion
    (goto-char pt)
    (count-char-region ch
                       (progn (goto-bol)(point))
                       (progn (goto-eol)(point)))
    )
  )
