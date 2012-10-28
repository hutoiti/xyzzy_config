;;; trace.l

; (trace function1 function2 ...) makes the functions `traced'.
; (trace) returns `traced' functions.
; (untrace function1 function2 ...) makes the functions `untraced'. 
; (untrace) makes all `traced' functions `untraced'.

(require "encap")

(defvar *trace-function-list* nil)
(defvar *trace-depth* 0)

(defun trace-encap (func)
  (unless (encapsulated-p func 'traced-function)
    (encapsulate func 'traced-function
                 `((ed::setup-trace-output-buffer)
                   (setq *trace-depth* (1+ *trace-depth*))
                   (format *error-output* "~ACalling ~S~%" (make-sequence 'string *trace-depth* :initial-element #\SPC) (cons ',func argument-list))
                   (let ((#1=#:result (multiple-value-list (apply basic-definition argument-list))))
                     (format *error-output* "~A~S returned~{ ~A~}~%" (make-sequence 'string *trace-depth* :initial-element #\SPC) ',func #1#)
                     (setq *trace-depth* (1- *trace-depth*))
                     (values-list #1#))))
    (push func *trace-function-list*)
    func))

(defun trace-unencap (func)
  (when (encapsulated-p func 'traced-function)
    (unencapsulate func 'traced-function)
    (setq *trace-function-list* (remove func *trace-function-list* :test #'eq))
    func))

(defmacro trace (&rest args)
  (if (null args)
      '*trace-function-list*
    `(let (lst)
       (dolist (func ',args (reverse lst))
         (when (trace-encap func)
           (setq lst (cons func lst)))))))

(defmacro untrace (&rest args)
  (if (null args)
      '(let (lst)
        (dolist (func *trace-function-list* lst)
          (when (trace-unencap func)
            (setq lst (cons func lst)))))
    `(let (lst)
       (dolist (func ',args (reverse lst))
         (when (trace-unencap func)
           (setq lst (cons func lst)))))))

;;; trace.l ends here.