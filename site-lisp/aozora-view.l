(provide "aozora-view")
(in-package "editor")

(defun bfmc-version nil
  (interactive)
  (and (interactive-p)
       (message "bfmc lapse ~A on 2009-01-16 19:45" (bfmc-version)))
  "004")

#| aozora-view for xyzzy-0.2.2.235

Copyright (c) 2008-2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

MIT���C�Z���X�ł��B����҂𖾂炩�ɂ���ΓK���Ɏg���ėǂ��ł��B
���̃\�t�g�̎g�p�ɂ���Đ��������v�ɂ��āA����҂͈�ؐӔC�������܂���B

���T�v

�󕶌ɂ̃e�L�X�g�`���𑽏��ǂ݂₷�����܂��B
���r�ƒ��߂��B���āA���r�͓K���ɕ\�����܂��B

������

(require "bfmc")

��.xyzzy�ɏ����Ȃǂ��ēǂݍ��݂܂��B
netinstaller��p���ăC���X�g�[�������ꍇ�͕s�v�ł��B

�A���C���X�g�[���͂��̃t�@�C�����폜���ď�L�ݒ蓙�������΂����ł��B

���g�p���@

�󕶌ɂ̃t�@�C�����J���Aaozora-view�ŌĂяo���܂��B
�����Ǎ��Ȃ�Ēm��܂����B

���X�V����
001 2009-01-16 19:49 �ł����B

���������|#
(export '(*aozora-mode-hook* *aozora-mode-map* aozora-view))

(defvar *aozora-mode-hook* nil)

(defvar *aozora-mode-map* nil)
(unless *aozora-mode-map*
  (setq *aozora-mode-map* (make-sparse-keymap))
  (define-key *aozora-mode-map* #\f 'next-page)
  (define-key *aozora-mode-map* #\s 'previous-page)
  (define-key *aozora-mode-map* #\q 'quit-aozora-view)
  (define-key *aozora-mode-map* #\r 'toggle-aozora-ruby)
  (define-key *aozora-mode-map* #\d 'aozora-next-ruby))

(defun aozora-view ()
  (interactive)
  (let* ((p (progn (goto-char (point-min)) (point)))
		 (name (progn (goto-eol) (buffer-substring p (point))))
		 (buff (selected-buffer))
		 pch *post-command-hook*)
	(set-buffer (get-buffer-create name))
	(kill-all-local-variables)
	(erase-buffer (selected-buffer))
	(setq buffer-mode 'aozora-mode)
	(setq mode-name "��")
	(setq buffer-read-only nil)
	(use-keymap *aozora-mode-map*)
	(make-local-variable 'aozora-buff)
	(make-local-variable '*post-command-hook*)
	(setq *post-command-hook* pch)
	(add-hook '*post-command-hook* 'aozora-ruby)
	(setq aozora-buff buff))
  (let ((buff (selected-buffer)))
	(save-excursion
	  (let ((fp (make-buffer-stream (selected-buffer) 0))
			(from (progn (set-buffer aozora-buff) (goto-char (point-min)) (point))))
		(while (scan-buffer "�s\\|�m��" :regexp t :no-dup t)
		  (format fp "~A" (buffer-substring from (point)))
		  (when (equal (match-string 0) "�s")
			(let ((r (progn (forward-char) (scan-buffer "\\([^�t]*\\)�t" :regexp t) (match-string 1))))
			  (save-excursion (set-buffer buff)
				(set-text-attribute (1- (buffer-stream-point fp)) (buffer-stream-point fp) (cons 'ruby r)))))
		  (scan-buffer "�t\\|�n" :regexp t :tail t)
		  (setq from (point)))
		(format fp "~A" (buffer-substring from (point-max))))))
  (setup-temp-buffer (selected-buffer))
  (setq buffer-read-only t
		need-not-save t)
  (run-hooks '*aozora-view-hook*))

(defun quit-aozora-view ()
  (interactive)
  (kill-buffer aozora-buff)
  (kill-buffer (selected-buffer)))

(defun aozora-ruby ()
  (refresh-screen)
  (multiple-value-bind (from to tag)
		  (find-text-attribute 'ruby :start (1- (point)) :key 'car)
	(if from
		(popup-string (cdr tag) to))))

(defun toggle-aozora-ruby (&optional (sw nil g))
  (interactive)
  (if g
	  (if sw
		  (add-hook '*post-command-hook* 'aozora-ruby)
		(delete-hook '*post-command-hook* 'aozora-ruby))
	(if (find 'aozora-ruby *post-command-hook*)
		(toggle-aozora-ruby nil)
	  (toggle-aozora-ruby t))))

(defun aozora-next-ruby ()
  (interactive)
  (multiple-value-bind (from to tag)
		  (find-text-attribute 'ruby :start (point) :key 'car)
	(if from
		(goto-char to))))

; end of file aozora-view.l