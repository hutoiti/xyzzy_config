;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/types/star.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api/package")
  (require "hatena-star/api/util")
  )

(in-package :hatena-star.api)

(export '(hatena-star-star-values
          hatena-star-star-name
          hatena-star-star-quote
          hatena-star-star-count

          hatena-star-stars-inner-count-p
          hatena-star-stars-by-user-p
          hatena-star-stars-all-p

          hatena-star-stars-inner-count-values
          hatena-star-stars-by-user
          hatena-star-stars-count
          ))

(defmacro make-star (name quote count)
  (if (numberp count)
      `(list ,name ,quote ,count)
    `(chomp! (list ,name ,quote ,count))))
(defmacro star-name (star) `(car ,star))
(defmacro star-quote (star) `(cadr ,star))
(defmacro star-count (star) `(caddr ,star))

(defun starp (star)
  (macrolet ((nullable (predicate v)
               `(or (null ,v)
                    (,predicate ,v))))
    (and star
         (listp star)
         (<= 1 (length star) 3)
         (every #'atom star)
         (stringp (star-name star))
         (nullable stringp (star-quote star))
         (nullable integerp (star-count star))
         )))


(defun hatena-star-star-values (star)
  (values-list star))

(defun hatena-star-star-name (star)
  (star-name star))

(defun hatena-star-star-quote (star)
  (star-quote star))

(defun hatena-star-star-count (star)
  (star-count star))


(defun star-json->lisp-value (json)
  (if (atom json) ;; inner count
      (if (numberp json) json (parse-integer json))
    (make-star ($ json "name") ($ json "quote") ($N json "count"))))

(defun stars-json->lisp-value (json)
  (mapcar #'star-json->lisp-value json))


;; (("name" "quote") 10 ("name2" "quote2"))
;; (10 ("name2" "quote2")) ‚Æ‚¢‚¤‚Ì‚à‚ ‚é‚İ‚½‚¢
(defun hatena-star-stars-inner-count-p (entry-or-stars)
  (some #'numberp (to-stars entry-or-stars)))

;; (("name" "quote" 10) ("name2" "quote2" 9) ...)
(defun hatena-star-stars-by-user-p (entry-or-stars)
  (numberp (star-count (first (to-stars entry-or-stars)))))

;; (("name" "quote") ("name2" "quote2") ...)
(defun hatena-star-stars-all-p (entry-or-stars)
  (let ((stars (to-stars entry-or-stars)))
    (and stars
         (not (hatena-star-stars-by-user-p stars))
         (not (hatena-star-stars-inner-count-p stars)))))

(defun hatena-star-stars-inner-count-values (entry-or-stars)
  (let ((stars (to-stars entry-or-stars)))
    (if (hatena-star-stars-inner-count-p stars)
        (let ((pos (position-if #'numberp stars)))
          (when pos
            (values
             (car (subseq stars 0 pos))
             (nth pos stars)
             (last1 (subseq stars (1+ pos))))))
      (let ((n (hatena-star-stars-count stars)))
        (values (first stars)
                (if (< n 2) 0 (- n 2))
                (last1 stars))))))

(defun hatena-star-stars-by-user (entry-or-stars &key list-quote)
  (macrolet ((mapquote (fn stars)
               `(mapcar #'(lambda (star)
                            (make-star (star-name star)
                                       (,fn (star-quote star))
                                       (star-count star)))
                        ,stars)))
    (let ((stars (to-stars entry-or-stars)))
      (cond ((hatena-star-stars-inner-count-p stars)
             (type-error entry-or-stars "inner count not supported"))
            ((hatena-star-stars-by-user-p stars)
             (if list-quote
                 (mapquote list-if stars)
               stars))
            (t
             (let ((r (hatena-star-stars-by-user0 stars)))
               (if list-quote
                   r
                 (mapquote car r))))))))

(defun hatena-star-stars-by-user0 (stars)
  (flet ((accumulate (acc e)
           (let ((exist (assoc (star-name e) acc :test 'string=)))
             (if (not exist)
                 (push (make-star (star-name e) (list-if (star-quote e)) 1) acc)
               (progn
                 (incf (star-count exist))
                 (when (star-quote e)
                   (setf (star-quote exist)
                         (append1 (star-quote exist) (star-quote e))))
                 acc)))))
    (stable-sort (nreverse (reduce #'accumulate stars :initial-value nil))
                 #'> :key 'hatena-star-star-count)))

(defun hatena-star-stars-count (entry-or-stars)
  (let ((stars (to-stars entry-or-stars)))
    (cond ((hatena-star-stars-inner-count-p stars)
           (multiple-value-bind (count star)
               (partition-if #'numberp stars)
             (+ (apply #'+ count) (length star))))
          ((hatena-star-stars-by-user-p stars)
           (reduce #'(lambda (acc star) (+ acc (star-count star)))
                   stars
                   :initial-value 0))
          (t
           (length stars)))))

(defun to-stars (entry-or-stars)
  (cond ((hatena-star-entry-p entry-or-stars)
         (hatena-star-entry-stars entry-or-stars))
        ((listp entry-or-stars)
         entry-or-stars)
        (t
         (type-error entry-or-stars '(or hatena-star-entry list)))))


(provide "hatena-star/api/types/star")

;;;; End
