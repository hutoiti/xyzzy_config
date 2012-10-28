;;; -*- mode: lisp; package: editor -*-
;;;
;;; condition-restart-support.l --- Select and invoke restart interactively.
;;;
;;; This file is part of xyzzy extension 'condition-restart'.
;;;
;;; Author:    bowbow99 <bowbow99@gmail.com>
;;; License:   MIT Lisence
#|
Copyright (c) 2010 bowbow99

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
|#

;;; Commentary:

;; �T�v
;; ====
;; �G���[���g�b�v���x���܂Ŕ��ł��������ɁA�ċN����I�����ċN���ł���
;; �R�}���h�ilisp ����]������ eval-*** �̗ށj�Ƃ��ł��B
;;

;; �g���� 1: *scratch* �Ƃ���
;; ==========================
;; lisp �������ǂ悭�킩��Ȃ��A���邢�͂Ƃ肠�����������Ă݂����l�����B
#|
;;; eval-*** �ŃG���[������ċN����I������
(require "condition-restart-support")
(restart:setup-key-bindings)
|#
;; ��L�̐ݒ�� .xyzzy �Ƃ��ɏ����Ă����ƁA�������̃L�[�o�C���h��ύX
;; ���āA�ȉ��̃R�}���h���g����悤�ɂȂ�܂��B
;; �ǂ�������̕W���̃R�}���h���A�G���[�����Ƃ��ɍċN����I���ł���悤
;; �ɂ������̂ł��B
;;
;; - restart:eval-print-last-sexp  lisp-interaction-mode �� C-j(LFD)
;; - restart:eval-last-sexp        lisp-mode �Ƃ��� C-x C-e
;; - restart:eval-defun            lisp-mode �Ƃ��� M-C-x
;; - restart:eval-buffer
;; - restart:eval-expression       �O���[�o���� ESC ESC
;;

;; �g���� 2: �C�ӂ̃R�}���h��
;; ==========================
;; �����p�� eval-print-last-sexp �݂����Ȃ��̂��`����悤�Ȑl�����B
;;
;; - �S�ẴR���f�B�V������ select-restart-interactively �ŏ�������悤
;;   �� handler-bind �ŕ�݂܂��B
;; - ��� abort �ċN�����p�ӂ����悤�ɂ��܂��B
#|
    (restart-case
        (handler-bind ((condition 'select-restart-interactively))
          <�C�ӂ̏���>)
      (abort ()
        :report "��������߂�B"
        ;; �������Ȃ���� restart-case ������ nil ���Ԃ�B���ꂶ��}�Y
        ;; ���ꍇ�� return-from �Ƃ� go �œK���ȂƂ���֔�΂��B
        (values)))
|#


;;; TODO:
;; - abort ������������ quit �Ƃ��B
;; - CALL STACK

;;; Code:

(provide "condition-restart-support")

(eval-when (:load-toplevel :compile-toplevel :execute)
  (require "condition-restart"))

(in-package :condition-restart)

(eval-when (:load-toplevel :compile-toplevel :execute)
  (export '(eval-region
            eval-expression
            eval-print-last-sexp
            eval-last-sexp
            eval-defun
            eval-buffer
            setup-key-bindings)
          :restart))

;;;;
;;;; * Package

(in-package :editor)

(export '(select-restart-interactively))

;;;;
;;;; * Utilities

(defun %condition-type (condition)
  (si:*structure-definition-name
   (si:*structure-definition condition)))

(defun %report-condition (condition &optional (stream *standard-output*))
  (format stream "~&~S:~%    ~A"
          (%condition-type condition)
          condition))

(defun %print-restart-options (restarts &optional (stream *standard-output*))
  (let ((i -1))
    (dolist (restart restarts t)
      (format stream "~&~3D [~8A] "
              (incf i)
              (or (restart-name restart) "(����������)"))
      (let ((report-fn (condition-restart::restart-report-function restart)))
        (if report-fn
            (progn (funcall report-fn stream) (fresh-line stream))
          (format stream "~A~&" (or (restart-name restart) "")))))))

;;;;
;;;; * Select and Invoke Restart Interactively

(defun select-restart-interactively (condition)
  (let ((restarts (compute-restarts condition)))
    (unless restarts
      (return-from select-restart-interactively nil))
    (with-output-to-temp-buffer (" *Select Restart*" nil)
      (let ((buffer (buffer-stream-buffer *standard-output*))
            (winconf (current-window-configuration)))
        (unwind-protect
            (with-set-buffer
              ;; prepare window
              (unless (get-buffer-window buffer)
                (if (= 1 (count-windows))
                    (let ((col (window-columns)))
                      (if (> col 140)
                          (split-window (round col -2) t)
                        (split-window (round (window-height) -2))))
                  (other-window))
                (set-buffer buffer))
              ;; print condition and restarts
              ;; TODO: obtain and print CALL STACK
              (%report-condition condition)
              (format t "~&~%")
              (%print-restart-options restarts)
              ;; ask and invoke a restart
              (handler-case
                  (let ((i nil)
                        (prompt (format nil "Restart[0-~S]: "
                                        (1- (length restarts)))))
                    (loop
                      (setq i (read-integer prompt))
                      (if (and (numberp i) (< -1 i (length restarts)))
                          (return)
                        (message "�����Ȕԍ��ł�: ~S" i)))
                    (handler-bind ((condition 'select-restart-interactively))
                      (invoke-restart-interactively (nth i restarts))))
                (quit (q) (abort))))
          (set-window-configuration winconf)
          (refresh-screen))))))


;;;;
;;;; * Restart Supporting `Eval' Commands

;;; Originally defined in lisp/lispmode.l

(defun restart:eval-region (from to &optional stream)
  (interactive "r")
  (let ((result nil))
    (when (> from to)
      (rotatef from to))
    (let ((s (make-buffer-stream (selected-buffer) from to)))
      (handler-case
          (let ((*package* *package*))
            (while (< (buffer-stream-point s) to)
              (let ((form (read s nil '#1=#:eof)))
                (when (eq form '#1#)
                  (return))
                (setq result (multiple-value-list
                              (restart-case
                                  (handler-bind ((condition 'select-restart-interactively))
                                    (eval form))
                                (abort ()
                                  :report "��߂�B"
                                  (return-from restart:eval-region (values)))))))))
        ((or error reader-error quit) (c)
         (when (<= (buffer-stream-point s) to)
           (goto-char (buffer-stream-point s))
           (when stream
             (eval-region-print stream
               (format t "~A~%" c)))
           (let ((si:*trace-on-error* nil))
             (error c))))))
    (eval-region-print stream
      (if (null stream)
          (message "~S" (car result))
        (format t "~{~S~%~}" result)))
    (values-list result)))

(defun restart:eval-buffer (buffer)
  (interactive "bEval Buffer: ")
  (save-excursion
    (set-buffer buffer)
    (restart:eval-region (point-min) (point-max))))

(defun restart:eval-last-sexp (&optional stream)
  (interactive "p")
  (let ((syntab (syntax-table)))
    (let (from to)
      (cond ((selection-start-end (start end)
               (setq from start to end)))
            (t
             (use-syntax-table *lisp-mode-syntax-table*)
             (unwind-protect
                 (let ((opoint (point)))
                   (setq from (progn
                                (backward-sexp)
                                (point))
                         to (progn
                              (forward-sexp)
                              (point)))
                   (goto-char (max opoint to)))
               (use-syntax-table syntab))))
      (save-excursion
        (restart:eval-region from to
                             (cond ((or (streamp stream)
                                        (bufferp stream))
                                    stream)
                                   (stream
                                    (selected-buffer))
                                   (t nil)))))))

(defun restart:eval-print-last-sexp ()
  (interactive "*")
  (with-output-to-selected-buffer
    (let ((*standard-input* *cooked-mode-input-stream*))
      (when (fresh-line)
        (goto-char (buffer-stream-point *standard-output*))
        (refresh-screen))
      (restart:eval-last-sexp *standard-output*))))

(defun restart:eval-defun (&optional (arg nil f))
  (interactive "p")
  (save-excursion
    (let ((opoint (point)))
      (end-of-defun)
      (let ((to (point))
            (from (progn
                    (beginning-of-defun)
                    (point))))
        (end-of-defun)
        (goto-char (if (< (point) opoint) opoint to))
        (restart:eval-region from (point)
                             (if f (selected-buffer) nil))))))

;;; Originally defined in lisp/cmds.l

(defun restart:eval-expression (x)
  (interactive "xEval: ")
  (restart-case
      (message "~S" (handler-bind ((condition 'select-restart-interactively))
                      (eval x)))
    (abort () :report "��߂�B" (values))))


(defun restart:setup-key-bindings ()
  ;; for lisp-interaction-mode
  (define-key ed::*lisp-interaction-mode-map* #\LFD 'restart:eval-print-last-sexp)
  (define-key ed::*lisp-interaction-mode-map* #\C-M-x 'restart:eval-defun)
  (define-key ed::*lisp-interaction-mode-map* '(#\C-x #\C-e) 'restart:eval-last-sexp)
  ;; for lisp-mode
  (define-key ed::*lisp-mode-map* '(#\C-x #\C-e) 'restart:eval-last-sexp)
  (define-key ed::*lisp-mode-map* #\C-M-x 'restart:eval-defun)
  ;; global
  (define-key esc-map #\ESC 'restart:eval-expression)
  t)

;;; restart-support/select-restart-interactively.l ends here