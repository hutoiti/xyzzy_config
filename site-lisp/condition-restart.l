;;; -*- mode: lisp; package: condition-restart -*-
;;;
;;; condition-restart.l --- Restart system from Common Lisp.
;;;
;;; This file is part of xyzzy extension 'condition-restart'.
;;;
;;; Author:    bowbow99 <bowbow99@gmail.com>
;;; Version:   0.01.03
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
;; Common Lisp �̃R���f�B�V�����V�X�e���ɂ���ċN�� (Restart) �ł��B
;;
;; �X�̊֐���}�N���ɂ��ẮA�t���̂ւȂ��傱���t�@�����X�`���̃��t
;; �@�����X���Q�Ƃ��Ă��������B
;;
;;   - File: reference/condition-restart.xml
;;
;;   �Q�l�����N:
;;   - [CLHS: 9.1.4.2 Restarts] http://www.lispworks.com/documentation/HyperSpec/Body/09_adb.htm
;;
;; ���܂�: �ċN�����g���� assert �� check-type ���������Ă܂��B
;;

;; �C���X�g�[��
;; ============
;; netinstaller �ŃC���X�g�[�������l�͂��̂܂܂ł����ł��B
;; �蓮�ŃC���X�g�[������ꍇ�́A�A�[�J�C�u�� xyzzy �̃f�B���N�g���ɂ܂�
;; ���Ɖ𓚂���΂����Ȃ͂��ł��B
;;

;; �ݒ�H
;; ======
;; *scratch* �Ƃ��ŕ]�����ăG���[�����Ƃ��ɍċN����I�����ċN��������@��
;; ���Ă� condition-restart-support.l ���Q�Ƃ��Ă��������B
;;


;; �g���� for �J����
;; =================
;; �ċN�����g�������g�� lisp �� require ���ĉ������B�K�v�Ȋ֐���}�N����
;; lisp �p�b�P�[�W���� export ���Ă���̂ŁA�ʏ�͂��ꂾ���Ŏg����悤��
;; �Ȃ�܂��B
;;
;;     (require :condition-restart)
;;
;; ���ꂼ��̃}�N����֐��ɂ��Ă̓��t�@�����X���Q�Ƃ��Ă��������B
;; - reference/condition-restart.xml
;;

;; �Ƃ肠�������������l�����T���v��
;; --------------------------------
;; lisp-mode �� C-x C-e �� lisp-interaction-mode �� C-j �ŏォ�珇�ɕ]��
;; ���Ă݂Ă��������B
#|
(require "condition-restart")
(require "condition-restart-support")

(restart:setup-key-bindings)

(cerror "�m�邩����" "��٧!!!")

(restart-case
    (/ 3 2 1 0)
  (zero () :report "0 ��Ԃ��B" 0)
  (one () :report "1 ��Ԃ��B" 1)
  (use-value (value)
    :report "�Ԃ��l����͂���B"
    :interactive (lambda ()
                   (list (eval (read-sexp ">> "))))
    value))

(let ((name :fred)
      (age -3))
  (assert (and (stringp name) (< (length name) 64)) (name)
          "���O���ςł�: ~S" name)
  (assert (and (numberp age) (<= 0 age 120)) (age)
          "�g�V���ςł�: ~S" age)
  (list name age))

|#

;; �㏑�����ӕ�
;; ============
;; - �W���̊֐� warn ���㏑�����Ă��܂��B
;;   �ċN����p�ӂ���悤�ɂ����ȊO�͕W���̂��̂Ɠ��������ɂ�������
;;   �ł����A���������Ȃ��Ă��邩���m��܂���B
;;

;;; ChangeLog:
#|
* 2010-08-06 - version 0.01.03
   - assert �̃��b�Z�[�W�������}�V�ɂ����B
   - �S�~���������Ă��̂ō폜 (thx to @southly)
* 2010-06-13 - version 0.01.02
   - ���t�@�����X�� file ���Ԉ���Ă��̂��C�������B
   - select-restart-interactively ���ċA�I�ɌĂ΂ꂽ�Ƃ��ɃE�B���h�E��
     �T�C�Y�����������Ȃ��Ă��̂��C����������B
   - assert �� PLACES �� nil �̂Ƃ��̃��b�Z�[�W��ύX�����B
* 2010-06-10 - version 0.01.01
   - �ċN����I�����J��Ԃ����Ƃ��̉�ʕ����̃o�O�ɑΏ������B
* 2010-06-10 - version 0.01.00
   - ������B���J�Ȃ��B
|#

;;; Code:

(provide "condition-restart")

;;;;
;;;; * Package

(when (find-package :elisp)
  (shadow :abort :elisp))

;;; exporting from lisp package
(in-package :lisp)

(export '(;; Macros establishes restarts
          restart-case
          restart-bind
          with-simple-restart
          with-condition-restarts
          ;; Functions deals with restarts
          restart-name
          compute-restarts
          find-restart
          invoke-restart
          invoke-restart-interactively
          ;; Signallers
          cerror
          ;; standard restart interface
          abort
          continue
          muffle-warning
          use-value
          store-value
          ;; assertions
          assert
          +check-type-error-symbols+
          )
        :lisp)

(defpackage :condition-restart
  (:use :lisp)
  (:nicknames "restart"))

(in-package :condition-restart)

(defconstant *version* "0.01.03")

;;;;
;;;; * Utilities

(defmacro with-ca/dr ((cons &optional (car-name 'car) (cdr-name 'cdr)) &body body)
  `(let ((#1=#:obj ,cons))
     (let ((,car-name (car #1#))
           (,cdr-name (cdr #1#)))
       ,@body)))

#+xyzzy
(setf (get 'with-ca/dr 'ed:lisp-indent-hook) 1)

(defun %add-key/value (key datum alist)
  (cons (cons key (union datum (cdr (assoc key alist))))
        (remove key alist :key #'car)))

;;;;
;;;; * Restart Object

(eval-when (:load-toplevel :compile-toplevel :execute)
  (defun print-restart (restart stream #:what?)
    (format stream "#<restart: ~A>"
            (or (restart-name restart)
                "(anonymous)"))))

(defstruct (restart
            (:print-function print-restart))
  name
  function
  interactive-function
  report-function
  (test-function (lambda (&optional condition) t)))

(defparameter *active-restarts* nil
  "List of active restart.")

(defparameter *condition/restart-association* nil
  "List of condition and associated restarts.")

(defun restart-active-p (restart)
  (find restart *active-restarts*))

(defun restart-associated-p (restart condition)
  "Return true if RESTART is associated with CONDITION, or RESTART isn't
 associated with any condition."
  (or (find restart (cdr (assoc condition *condition/restart-association*)))
      (notany (lambda (assoc)
                (member restart (cdr assoc)))
        *condition/restart-association*)))

;;;; * Restart Establishing Macros

;;; - Macro restart-bind

(defmacro restart-bind ((&rest restarts) &body body)
  "Evaluate the BODY in a dynamic environment where RESTARTS are in effect."
  `(let ((*active-restarts*
          (append (list ,@(mapcar (lambda (restart)
                                    `(make-restart :name ',(car restart)
                                                   :function #',(cadr restart)
                                                   ,@(cddr restart)))
                            restarts))
                  *active-restarts*)))
     ,@body))

#+xyzzy
(setf (get 'restart-bind 'ed:lisp-indent-hook) 1)

;;; - Macro with-condition-restarts

(defmacro with-condition-restarts (condition restarts &body body)
  "Evaluate BODY with associating RESTARTS with CONDITION."
  `(let ((*condition/restart-association*
          (%add-key/value ,condition ,restarts
                          *condition/restart-association*)))
     ,@body))

#+xyzzy
(setf (get 'with-condition-restarts 'ed:lisp-indent-hook) 2)

;;; - Macro restart-case
(eval-when (:load-toplevel :compile-toplevel :execute)
  (defun transform-keyword-option-report (form)
    (list :report-function
          (case (type-of form)
            (simple-string
             `(lambda (#1=#:stream) (format #1# ,form)))
            (symbol
             (if form
                 `',form
               (error "Invalid function for :report option: ~S" form)))
            (cons ; lambda form
             (if (eql 'lambda (car form))
                 form
               (error "Invalid function for :report option: ~S" form)))
            (t (error "Invalid function for :report option: ~S" form)))))

  (defun transform-keyword-option-test (form)
    (list :test-function `#',form))

  (defun transform-keyword-option-interactive (form)
    (list :interactive-function `#',form))

  (defun transform-keyword-option (keyword/form)
    (let ((keyword (car keyword/form))
          (form (cadr keyword/form)))
      (funcall (case keyword
                 (:report 'transform-keyword-option-report)
                 (:interactive 'transform-keyword-option-interactive)
                 (:test 'transform-keyword-option-test)
                 (t (error "Invalid keyword option for restart-case clause: ~S"
                           keyword)))
               form)))
  )

(defmacro %with-tag/clause ((tag/clause) &body body)
  `(let ((tag (first ,tag/clause))
         (name (second ,tag/clause))
         (args (third ,tag/clause))
         (options nil)
         (body (cdddr ,tag/clause)))
     (while (and (keywordp (car body))
                 (member (car body) '(:report :interactive :test)))
       (setf options (cons (subseq body 0 2) options)
             body (cddr body)))
     (setf options (nreverse options))
     ,@body))

#+xyzzy
(setf (get '%with-tag/clause 'ed:lisp-indent-hook) 'defun)

(defun %make-condition (datum args default)
  (case (type-of datum)
    ((simple-string string)
     (make-condition default :format-string datum :format-arguments args))
    (symbol
     (apply #'make-condition datum args))
    (t
     (if (and (typep datum 'condition) (null args))
         datum
       (error 'type-error
              :datum datum
              :expected-type '(or condition symbol string))))))

(defmacro restart-case (form &rest clauses)
  "Evaluate the FORM in a environment where clauses establishes restarts."
  (let ((tags/clauses (mapcar (lambda (clause)
                                (cons (gensym) clause))
                        clauses)))
    `(block #1=#:restart-case
       (let ((#2=#:args nil))
         (tagbody
           (restart-bind
               (,@(mapcar (lambda (tag/clause)
                            (%with-tag/clause (tag/clause)
                              `(,name (lambda (&rest #3=#:temp)
                                        (setq #2# #3#)
                                        (go ,tag))
                                ,@(mapcan #'transform-keyword-option options))))
                    tags/clauses))
             (return-from #1#
               ,(let ((form (macroexpand form)))
                  (if (and (consp form)
                           (member (car form) '(signal warn error cerror)))
                      (let ((operator (car form))
                            (datum (cadr form))
                            (args (cddr form)))
                        `(let ((#4=#:condition
                                (%make-condition ,datum (list ,@args)
                                                 ',(case operator
                                                     ((error cerror) 'simple-error)
                                                     (signal 'simple-condition)
                                                     (warn 'simple-warning)))))
                           (with-condition-restarts #4#
                               (list ,@(mapcar (lambda (tag/clause)
                                                 (%with-tag/clause (tag/clause)
                                                   `(find-restart ',name)))
                                         tags/clauses))
                             (,operator #4#))))
                    form))))
           ,@(mapcan (lambda (tag/clause)
                       (%with-tag/clause (tag/clause)
                         `(,tag (return-from #1#
                                  (apply #'(lambda ,args ,@body)
                                         #2#)))))
               tags/clauses))))))

#+xyzzy
(setf (get 'restart-case 'ed:lisp-indent-hook) 1)

(defmacro with-simple-restart ((name fmt-control &rest fmt-arguments)
                               &body forms)
  "Evaluate FORMS with a retart NAME which simply returns nil and t."
  `(restart-case
       (progn ,@forms)
     (,name ()
      :report (lambda (stream)
                (format stream ,fmt-control ,@fmt-arguments))
      (values nil t))))

;;;;
;;;; * Functions Use Active Restarts

(defun restart-test (restart condition)
  (or (null condition)
      (null (restart-test-function restart))
      (funcall (restart-test-function restart) condition)))

(defun compute-restarts (&optional condition)
  "Return a list of restarts which are currently active and applicable."
  (remove-if-not (lambda (restart)
                   (and (restart-test restart condition)
                        (restart-associated-p restart condition)))
    *active-restarts*))

(defun find-restart (identifier &optional condition)
  "Return a particular restart from current dynamic environment."
  (cond
   ((symbolp identifier)
    (find-if (lambda (restart)
               (and (eql (restart-name restart) identifier)
                    (restart-test restart condition)
                    (restart-associated-p restart condition)))
      *active-restarts*))
   ((restart-p identifier)
    (when (and (typep identifier 'restart)
               (member identifier *active-restarts*))
      identifier))
   (t (error "invalid restart designator: ~S" identifier))))

(define-condition restart-not-found (control-error)
  (designator condition)
  (:report (lambda (condition stream)
             (format stream "Could not find active restart ~S~@[ for condition ~S~]"
                     (restart-not-found-designator condition)
                     (restart-not-found-condition condition)))))
#+xyzzy
(setf (get 'restart-not-found 'ed::lisp-indent-handler) t)

(defun invoke-restart (identifier &rest arguments)
  "Call the function associated with RESTART with ARGUMENTS."
  (apply (restart-function (or (find-restart identifier)
                               (error 'restart-not-found
                                      :designator identifier)))
         arguments))

(defun invoke-restart-interactively (identifier)
  (let ((restart (or (find-restart identifier)
                     (error 'restart-not-found
                            :designator identifier))))
    (apply #'invoke-restart
           restart
           (let ((it (restart-interactive-function restart)))
             (when it (funcall it))))))


;;; - Interface Functions for Standard Restart

(defun abort (&optional condition)
  (invoke-restart (find-restart 'abort condition)))

(defun continue (&optional condition)
  (let ((restart (find-restart 'continue condition)))
    (when restart
      (invoke-restart restart))))

(defun muffle-warning (&optional warning)
  (invoke-restart 'muffle-warning))

(defun use-value (value &optional condition)
  (let ((r (find-restart 'use-value condition)))
    (when r (invoke-restart r value))))

(defun store-value (new-value &optional condition)
  (let ((r (find-restart 'store-value condition)))
    (when r (invoke-restart r new-value))))


;;;;
;;;; * Signaling Condition with Restarts

(defun warn (datum &rest args)
  (let ((warning (%make-condition datum args 'simple-warning)))
    (restart-case
        (with-condition-restarts warning (find-restart 'muffle-warning)
          (si:*throw-error warning))
      (muffle-warning ()
        :report "���̌x���͖����������ƂɁB"
        nil))))

(defun cerror (fmt-control datum &rest args)
  (let ((error (%make-condition datum args 'simple-error)))
    (restart-case
        (with-condition-restarts error (list (find-restart 'continue))
          (si:*throw-error error))
      (continue ()
        :report (lambda (stream)
                  (apply #'format stream fmt-control args))))))

;;;;
;;;; * Assertions

(defconstant +check-type-error-symbols+
  '(si::check-type-error
    si::check-type-error-datum
    si::check-type-error-expected-type
    si::check-type-error-place
    si::check-type-error-string
    ))

(defun read-value-for (place)
  (restart-case
      (eval (ed:read-sexp (format nil "`~S' �̒l: " place)))
    (re-enter ()
      :report (lambda (stream)
                (format stream "`~S' �̒l����͂������B" place))
      (read-value-for place))))

(defmacro assert (test-form &optional places
                  (datum t datum-supplied-p) &rest args)
  "Ensure TEST-FORM evaluates to non-nil."
  `(tagbody
     #1=#:assertion-root
     (unless ,test-form
       (restart-case
           (error ,@(if datum-supplied-p
                        (list* datum args)
                      `("assert �Ɏ��s���܂���: ~S" ',test-form)))
         (continue (&rest new-values)
           :report (lambda (stream)
                     (format stream "~:[��蒼���B~;~@*�l��ύX���Ă�蒼���B(~{~S~^ ~})~]"
                             ',places))
           :interactive (lambda ()
                          (mapcar #'read-value-for ',places))
           (setf ,@(let ((i -1))
                     (mapcan (lambda (place)
                               `(,place (nth ,(incf i) new-values)))
                       places)))
           (go #1#))))))

(defmacro check-type (place typespec &optional string)
  "Ensure value of PLACE is type of TYPESPEC."
  `(tagbody
     #1=#:check-type-root
     (let ((#2=#:datum ,place))
       (unless (typep #2# ',typespec)
         (restart-case
             (error 'si::check-type-error
                    :place ',place
                    :datum #2#
                    :expected-type ',typespec
                    :string ,string)
           (store-value (new-value)
             :report (lambda (stream)
                       (format stream "`~S' �̒l��ύX���Ă�蒼���B" ',place))
             :interactive (lambda ()
                            (list (read-value-for ',place)))
             (setf ,place new-value)
             (go #1#)))))))

;;;; condition-restart.l ends here