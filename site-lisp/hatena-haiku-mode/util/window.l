;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/window.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util/package")
  )

(in-package :hatena-haiku.util)

(export '(setup-local-window-flags
          split-window-left
          split-window-right
          split-window-top
          split-window-bottom
          split-window-and-set-buffer
          show-buffer
          delete-buffer-window
          one-window-p
          find-buffer-window-from
          all-buffer-has-window-p
          buffer-has-window-p
          frame-width
          frame-height
          left-windows
          right-windows
          ))

(defun setup-local-window-flags (flags-alist &optional (window-or-buffer (selected-window)))
  (dolist (kv flags-alist)
    (set-local-window-flags window-or-buffer (car kv) (cdr kv))))


(defun split-window-left (buffer &optional (size 0.2))
  (split-window-to :left buffer size))

(defun split-window-right (buffer &optional (size 0.2))
  (split-window-to :right buffer size))

(defun split-window-top (buffer &optional (size 0.2))
  (split-window-to :top buffer size))

(defun split-window-bottom (buffer &optional (size 0.2))
  (split-window-to :bottom buffer size))

(defun split-window-to (direction buffer &optional (size 0.2))
  (let ((candidates (neighbour-windows direction (selected-window))))
    (if candidates
        (aif (find-buffer-window-from candidates buffer)
            _it_
          (let ((win (car candidates)))
            (show-buffer buffer win)
            win))
      (split-window-and-set-buffer buffer size direction))))

(defun split-window-and-set-buffer (buffer ratio direction &optional w h)
  (let ((base-width (or w (frame-width)))
        (base-height (or h (frame-height))))
    (let* ((vertical (member direction '(:left :right)))
           (flag (if (member direction '(:top :left)) '+ '-))
           (base (if vertical base-width base-height))
           (size (ceiling (* ratio base))))
      (when (split-window (funcall flag size) vertical)
        (let* ((new (selected-window))
               (org (if (eq flag '+)
                        (next-window new)
                      (previous-window new))))
          (prog1
              (values new org)
            (show-buffer buffer)
            (set-window org)))))))

(defun show-buffer (buffer &optional window)
  (with-selected-window
    (when window
      (set-window window))
    (with-set-buffer
      (set-buffer
       (if (and (bufferp buffer)
                (not (deleted-buffer-p buffer)))
           buffer
         (find-buffer buffer))))))

(defun delete-buffer-window (buffer)
  (unless (one-window-p)
    (awhen (get-buffer-window buffer)
      (with-selected-window
        (set-window _it_)
        (delete-window)))))

(defun one-window-p ()
  (= (count-windows) 1))

(defun find-buffer-window-from (windows buffer)
  (find-if #'(lambda (w)
               (equal (window-buffer w) buffer))
           windows))

(defun all-buffer-has-window-p (buffers)
  (every #'buffer-has-window-p buffers))

(defun buffer-has-window-p (buffer)
  (not (null (get-buffer-window buffer))))


(defun list-windows (&optional minibuf)
  (let ((current (selected-window))
        result
        next)
    (and minibuf
         (minibuffer-window-p current)
         (setq current (next-window current)))
    (do ((result (list current) (push next result))
         (next (next-window current minibuf) (next-window next minibuf)))
        ((eq next current)
         (reverse result)))))

(defun window-info (w)
  (append (window-coordinate w)
          (list (window-width w)
                (window-height w))))

(defun list-window-info ()
  (mapcar 'window-info (list-windows)))

(defun frame-width ()
  (let ((curr 0)
        (result 0)
        (margin 5)
        (count 0))
    (dolist (win (sort (list-window-info) #'< :key #'car))
      (multiple-value-bind (x1 y1 x2 y2 w h)
          (values-list win)
        (when (= curr x1)
          (setf curr x2)
          (incf result w)
          (incf count))))
    (+ result (* margin (- count 1)))))

(defun frame-height ()
  (let ((curr 0)
        (result 0)
        (margin 3)
        (count 0))
    (dolist (win (sort (list-window-info) #'< :key #'cadr))
      (multiple-value-bind (x1 y1 x2 y2 w h)
          (values-list win)
        (when (= curr y1)
          (setf curr y2)
          (incf result h)
          (incf count))))
    (+ result (* margin (- count 1)))))


(defun neighbour-windows (direction w)
  (case direction
    (:left (left-windows w))
    (:right (right-windows w))
    (:top (top-windows w))
    (:bottom (bottom-windows w))
    (t
     (plain-error "Invalid direction `~S'" direction))))

(defun left-windows (w)
  (find-neighbour-windows w
                          #'(lambda (x1 y1 x2 y2 cx1 cy1 cx2 cy2)
                              (= x1 cx2))
                          'window-left-center
                          'window-right-center))

(defun right-windows (w)
  (find-neighbour-windows w
                          #'(lambda (x1 y1 x2 y2 cx1 cy1 cx2 cy2)
                              (= x2 cx1))
                          'window-right-center
                          'window-left-center))

(defun top-windows (w)
  (find-neighbour-windows w
                          #'(lambda (x1 y1 x2 y2 cx1 cy1 cx2 cy2)
                              (= y1 cy2))
                          'window-top-center
                          'window-bottom-center))

(defun bottom-windows (w)
  (find-neighbour-windows w
                          #'(lambda (x1 y1 x2 y2 cx1 cy1 cx2 cy2)
                              (= y2 cy1))
                          'window-bottom-center
                          'window-top-center))

(defun find-neighbour-windows (w predicate pt1-fn pt2-fn)
  (sort-by-window-distance
   (funcall pt1-fn w)
   (select-windows w predicate)
   pt2-fn))

(defun select-windows (w predicate)
  (let ((c (window-coordinate w)))
    (remove-if-not #'(lambda (w)
                       (apply predicate (append c (window-coordinate w))))
                   (remove w (list-windows)))))

(defun sort-by-window-distance (p1 lst fn)
  (mapcar #'cadr
          (sort (mapcar #'(lambda (w)
                            (list (euclid-distance p1 (funcall fn w)) w))
                        lst)
                '< :key #'car)))

(defun euclid-distance (p1 p2)
  (sqrt (apply '+ (mapcar #'(lambda (a b)
                              (expt (- a b) 2))
                          p1 p2))))

(defun calc-center (v1 v2)
  (+ v1 (/ (- v2 v1) 2)))


(defmacro with-window-coodinate ((w) &body body)
  `(multiple-value-bind (x1 y1 x2 y2)
       (values-list (window-coordinate ,w))
     ,@body))
(setf (get 'with-window-coodinate 'ed:lisp-indent-hook) 'with-open-file)

(defun window-top-center (w)
  (with-window-coodinate (w)
    (list (calc-center x1 x2) y1)))

(defun window-bottom-center (w)
  (with-window-coodinate (w)
    (list (calc-center x1 x2) y2)))

(defun window-left-center (w)
  (with-window-coodinate (w)
    (list x1 (calc-center y1 y2))))

(defun window-right-center (w)
  (with-window-coodinate (w)
    (list x2 (calc-center y1 y2))))


(provide "hatena-haiku-mode/util/window")

;;;; End
