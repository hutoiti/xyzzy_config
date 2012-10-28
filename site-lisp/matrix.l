;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                  ;;;
;;;                          matrix.lisp                             ;;;
;;;                  utilities for matrix calculations               ;;;
;;;                           by T.Shido                             ;;;
;;;                         July 20, 2004                            ;;;
;;;                                                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
;;; matrix.l for xyzzy by Kuubo (Kongmu), 2005-11-13, 2012-05-12

See html/matrix.html for details.

How to install:
1. Copy matrix.l and matrix.lc to ~/site-lisp
2. Add this code to .xyzzy or siteinit.l:
    (require "matrix")
    (use-package "matrix")
    (setq *read-default-float-format* 'double-float)
The last line is optional, but recommended when calculating an inverse matrix (especially when the matrix is almost-singular) for good accuracy.
If you add this code to siteinit.l, don't forget to byte-compile siteinit.l and to create xyzzy dump file again.

Changes:
#\Newline => #\RET
#\Space => #\SPC
(ext:cd) => (default-directory)
(format nil "A~A=" op) => (format nil "a~A=" op) ; a=name
(without-floating-point-underflow ...) => created
(setq *WARN-ON-FLOATING-POINT-CONTAGION* nil) => omitted
gnuplot => omitted
package => added
docstring => added

without-floating-point-underflow:
    The macro without-floating-point-underflow: (without-floating-point-underflow {form}*) executes the forms, with errors of type floating-point-underflow inhibited. Floating point operations will silently return zero instead of signalling an error of type floating-point-underflow.
quoted from http://ftp2.de.freebsd.org/pub/gnu2/clisp/impnotes.html
|#

;;; package, added by Kuubo
(provide "matrix")
(defpackage "matrix"
  (:external-size 7)
  (:internal-size 17)
  (:use "lisp" "editor"))
(in-package "matrix")
(export '(v-ip aset a+= a-= a*= a/= m+ m- m* umat det m-1 m-t m-eql jacob eigen a=op l-ip))

;;; set value of *WARN-ON-FLOATING-POINT-CONTAGION* for floating point calculation
;(setq *WARN-ON-FLOATING-POINT-CONTAGION* nil)

#|
;;; variables for gunplot
(defvar *gnuplot* "C:\\bin\\gnuplot\\bin\\pgnuplot.exe")
(defvar *plot-file* "plot.plt")
(defvar *png-font-type* "Times New Roman")                        
(defvar *png-font-size* 14)                                       
|#

;;; functions to be evaluated at compile time.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun group (source n)
    (if (zerop n) (error "zero length"))
    (labels ((rec (source acc)
	       (let ((rest (nthcdr n source)))
		 (if (consp rest)
		     (rec rest (cons (subseq source 0 n) acc))
		   (nreverse (cons source acc))))))
      (if source (rec source nil) nil)))

;;; make `(aref ....) used in v-ip
  (defun v-ip-fn (v0 k)
    (if (consp v0)
	(let ((p (position '_ v0)))
	  `(aref ,@(subseq v0 0 p) ,k ,@(subseq v0 (1+ p))))
      `(aref ,v0 ,k)))

;;;make macro names + => A+=, used in a=op
  (defun a=name (op)
    (intern (format nil "a~A=" op))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; macros

(defmacro _with-gensyms (syms &body body)
  `(let ,(mapcar #'(lambda (s)
                     `(,s (gensym)))
                 syms)
     ,@body))

(defmacro for ((var start stop) &body body)
  (let ((gstop (gensym)))
    `(do ((,var ,start (1+ ,var))
          (,gstop ,stop))
         ((>= ,var ,gstop))
       ,@body)))

(defmacro awhile (expr &body body)
  `(do ((it ,expr ,expr))
       ((not it))
     ,@body))

;;; without-floating-point-underflow for xyzzy, added by Kuubo
(defmacro without-floating-point-underflow (&rest body)
  "Catch floating-point-underflow error and return 0.0 immediately."
  `(handler-case
       (progn
         ,@body)
     (floating-point-underflow () 0.0)))

;;; (aset (a i j) val1 (b i j) val2) 
;;; == (setf (aref a i j) val1 (aref b i j) val2)
;;; set the value of array
(defmacro aset(&rest argvs)
  "(aset (a i j) val1 (b i j) val2) == (setf (aref a i j) val1 (aref b i j) val2)" ; added by Kuubo
  `(setf
     ,@(mapcan #'(lambda (x)
		   `((aref ,@(first x)) ,(second x)))
	       (group argvs 2))))
		      
;;; defining macros a(op)=,  like a[i][j](op)=val, in C.
(defmacro a=op (&rest oplist)
  "Defining macros a(op)=, like a[i][j](op)=val, in C.
e.g. (a=op + -) defines a+= and a-=." ; added by Kuubo
  `(progn
    ,@(mapcar #'(lambda (op)
		  `(defmacro ,(a=name op) (arry &optional val)
             ,(format nil "(a~A= (m i j) val) == (setf (aref m i j) (~A (aref m i j) val))" op op) ; added by Kuubo
		    (multiple-value-bind (vs fs v s a)
		      (get-setf-method (cons 'aref arry))
		      `(let* (,@(mapcar #'list vs fs)
			      (,(car v) ,(if val `(,',op ,a ,val) `(,',op ,a))))
			 ,s))))
	      oplist)))
			    
;;; creating functions m+ and m-
(defmacro m+- ()
  (_with-gensyms
   (mat obj msize i j m1 type)
   `(progn
      ,@(mapcar
	 #'(lambda (x)
	     `(defun ,x (,mat ,obj)
		 ,(format nil (case x (m+ "(m+ mat obj): Add obj to matrix m0. (obj: scalar or matrix)")
				      (m- "(m- mat obj): Substruct obj from matrix m0. (obj: scalar or matrix)"))) ; added by Kuubo
		 (let ((,msize (array-dimensions ,mat))
		       (,type (which-type (aref ,mat 0 0))))
		   (if (arrayp ,obj)
		       (if (equal ,msize (array-dimensions ,obj))
			   (let ((,m1 (make-array ,msize :element-type ,type)))
			     (dotimes (,i (first ,msize))
			       (dotimes (,j (second ,msize))
				 (setf (aref ,m1 ,i ,j)
				       ( ,(case x (m+ '+) (m- '-))
					 (aref ,mat ,i ,j) (aref ,obj ,i ,j)))))
			     ,m1)
			 (error "dimension mismatch"))
		     (let ((,m1 (make-array ,msize)))
		       (dotimes (,i (first ,msize))
			 (dotimes (,j (second ,msize))
			   (setf (aref ,m1 ,i ,j)
				 (,(case x (m+ '+) (m- '-))
				  (aref ,mat ,i ,j) ,obj))))
		       ,m1)))))
	 '(m+ m-)))))

;;; vector inner product, this can be used also for matrix
(defmacro v-ip (v1 v2)
  "Calculate vector inner product. Matrices can be accepted." ; added by Kuubo
  (_with-gensyms (k len1 len2  s)
   `(let ((,len1 ,(if (consp v1) `(array-dimension ,(car v1) ,(1- (position '_ v1))) `(length ,v1)))
	  (,len2 ,(if (consp v2) `(array-dimension ,(car v2) ,(1- (position '_ v2))) `(length ,v2)))
	  (,s    0))
      (or (= ,len1 ,len2) (error "length different"))
      (dotimes (,k ,len1 ,s)
	(incf ,s (* ,(v-ip-fn v1 k) ,(v-ip-fn v2 k)))))))

;;; defining a+=, a-=, a*=, a/=
(a=op + - * /)


#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; functions for gnuplot
;;; send command to gnuplot                                      
(let (gp dir)
  (defun gplot (s)
    (or gp
	(setq gp (make-buffer-stream *gnuplot*)))  ;(mark 3a)
    (or dir                                                         ;(mark 3b)
	(setq dir (default-directory)))
    (let ((dir1 (default-directory)))
      (unless (equal dir dir1)
	(setq dir dir1)
	(format gp "cd \'~A\'~%" (string-right-trim "\\" (format nil "~A" dir)))
	(force-output gp)))
    (when (stringp s)
      (format gp "~A~%" s)                                           ;(mark 3c)
      (force-output gp)
      (when (string-equal s "exit")
	(close gp)
	(setq gp nil)))))

;;; set autoscale
(defun auto ()                                                       ;(mark 3d)
  (gplot "set autoscale")
  (gplot "replot"))

;;; set range                                                        ;(mark 3e)
(defun range (xmin xmax ymin ymax)
  (and (realp xmin) (realp xmax) (gplot (format nil "set xrange [~A:~A]" xmin xmax)))
  (and (realp ymin) (realp ymax) (gplot (format nil "set yrange [~A:~A]" ymin ymax)))
  (gplot "replot"))

;;; output to png format, give fname without extension                (mark 3f)
(defun png (fname)
  (with-open-file (out "2png.plt" :direction :output)
    (if (system::getenv "GDFONTPATH")
	(format out "set terminal png font \"~A\" ~A size 800, 600~%" *png-font-type* *png-font-size*)
      (format out "set terminal png size 800, 600~%"))
    (format out "set output \"~A.png\"~%" fname)
    (format out "replot~%"))
  (gplot "load \"2png.plt\"")
  (end-plot))

;;; end gnuplot                                                        (mark 3g)
(defun end-plot ()
  (gplot "exit"))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;  functions for matrix

;;; defining functions m+ and m- 
(m+-)

;;; making a list of integer (0....n)
(defun ls0n (n)
  (let ((ls1 nil))
    (dotimes (i n (nreverse ls1))
      (push i ls1))))

;;; check which type of number
(defun which-type (obj)
  (if (rationalp obj)
      'rational
    (type-of obj)))

;;; list inner product
(defun l-ip (lx ly)
  "Calculate list inner product." ; added by Kuubo
  (apply '+ (mapcar #'(lambda (x y) (* x y)) lx ly)))

;;; multiplying matrixes
(defun 	m* (m0 obj0)
  "Multiply matrix m0 by obj0. (obj0: scalar, vector or matrix)" ; added by Kuubo
  (let ((msize (array-dimensions m0))
	(type (which-type (aref m0 0 0))))
    (cond
     ((numberp obj0)
      (let ((m1 (make-array msize :element-type type)))
	 (dotimes (i (first msize))
	   (dotimes (j (second msize))
	     (aset (m1 i j) (* obj0 (aref m0 i j)))))
	 m1))
     ((vectorp obj0)
      (let ((vsize (length obj0)))
	(or (= vsize (second msize)) (error "different size"))
	(let ((v1 (make-array (first msize) :element-type type)))
;	  (dolist (i vsize)
	  (dotimes (i vsize)        ; changed by Kuubo
	    (aset (v1 i) (v-ip (m0 i _) obj0)))
	  v1)))
     ((arrayp obj0)
      (let ((osize (array-dimensions obj0)))
	(let ((dmx (first msize))
	      (dmy (second msize))
	      (dox (first osize))
	      (doy (second osize)))
	  (or (= dmy dox) (error "size mismatch"))
	  (let ((m1 (make-array `(,dmx ,doy) :element-type type)))
	    (dotimes (i dmx)
	      (dotimes (j doy)
		(aset (m1 i j) (v-ip (m0 i _) (obj0 _ j)))))
	    m1)))))))

;;; getting an inverse matrix
(defun m-1 (m0)
  "Calculate inverse matrix.
(setq *read-default-float-format* 'double-float) is recommended when calculating an inverse matrix (especially when the matrix is almost-singular) for good accuracy."
   (let ((size (array-dimension m0 0))
	 (type (which-type (aref m0 0 0))))
     (or (= size (array-dimension m0 1))
	 (error "Not square"))
     (and (zerop (det m0)) (error "det ==0"))
     (let ((m1 (adjust-array m0 `( ,size ,(* 2 size)) :element-type type)))
       (for (i size (* 2 size))
	    (for (j 0 size)
		 (aset (m1 j i) (if (= (+ j size) i) 1 0))))
       (for (i 0 size)
	    (catch 'nonzero
	      (if (zerop (aref m1 i i))
		  (for (j (1+ i) size)
		       (for (k i (* 2 size))
			    (let ((pl (plusp (aref m1 i j))))
			      (a+=  (m1 i k) (* (if pl 1 -1) (aref m1 j k)))))
		       (or (zerop (aref m1 i i)) (throw 'nonzero nil)))))
	    (let ((piv (aref m1 i i)))
	      (for (j i (* 2 size))
		   (a/= (m1 i j) piv))
	      (for (j 0 size)
		   (or (= i j)
		       (let ((s (aref m1 j i)))
			 (for (k i (* 2 size))
			      (a-= (m1 j k) (* s (aref m1 i k)))))))))
       (let ((m2 (make-array (list size size))))
	 (for (i 0 size)
	      (for (j 0 size)
		   (aset (m2 i j) (aref m1 i (+ j size)))))
	 m2))))
		     
;;; check if two is the same matrix
(defun m-eql (m1 m2)
  "Check if two matrices are the same." ; added by Kuubo
  (let ((size1 (array-dimensions m1))
	(size2 (array-dimensions m2)))
    (when (equal size1 size2)
      (dotimes (i (first size1))
	(dotimes (j (second size1))
	  (or (= (aref m1 i j) (aref m2 i j))
	      (return-from m-eql nil))))))
  t)
  

;;;transposed matrix 
(defun m-t (m0)
  "Return transposed matrix." ; added by Kuubo
  (let* ((type (which-type (aref m0 0 0)))
	 (dim (array-dimensions m0))
	 (dimx (first dim))
	 (dimy (second dim))
	 (m1 (make-array (if dimy `(,dimy ,dimx) `(,dimx 1)) :element-type type )))
    (for (i 0 dimx)
	 (if dimy
	     (for (j 0 dimy)
		  (aset (m1 j i) (aref m0 i j)))
	   (aset (m1 i 0) (aref m0 i))))
    m1))

;count number of flips to calculate det
(defun flip (ls0 &optional (i 0) (n 0))
  (if ls0
      (let ((p (position i ls0)))
	(if (= p 0)
	    (flip (cdr ls0) (1+ i) n)
	  (flip
	   (append (subseq ls0 1 p) (cons (car ls0) (subseq ls0 (1+ p))))
	   (1+ i)
	   (1+ n))))
    n))

;;; calculate determinant of matrix 
(defun det (m0)
  "Calculate determinant of matrix." ; added by Kuubo
  (let ((size (array-dimension m0 0))
	(s 0))
    (or (= size (array-dimension m0 1))
	(error "Matrix is not square"))
    (labels ((rep (i rls rsol flips)
	       (if (= i size)
		     (if (evenp (flip (reverse flips)))
			 (incf s rsol)
		       (decf s rsol))
		 (dolist (k rls)
		   (rep (1+ i)
			(remove k rls)
			(* rsol (aref m0 i k))
			(cons k flips))))))
      (rep 0 (ls0n size) 1 nil))
    s))

;;; making unit matrix of n dimentions
(defun umat (n)
  "Make unit matrix of n dimensions." ; added by Kuubo
  (let ((m1 (make-array (list n n) :initial-element 0.0 :element-type 'double-float)))
    (dotimes (i n)
      (aset  (m1 i i) 1.0))
    m1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun m*v (n m mat v)
  (let ((mres (make-array n))
        temp)
    (for (i 0 n)
         (setf temp 0)
         (for (j 0 m)
              (incf temp (* (aref mat i j) (aref v j))))
         (aset (mres i) temp))
    mres))

(defun calc_coef (n mat mx ly)
  (let ((mxy (make-array (1+ n))))
    (aset (mxy 0) (apply '+ ly))
    (for (i 1 (1+ n))
         (aset (mxy i) (l-ip ly (aref mx (1- i)))))
    (m*v (1+ n) (1+ n) mat mxy)))

(defun nls (c n)
  (labels ((rec (i ls)
             (if (< i n)
                 (rec (1+ i) (cons c ls))
               ls)))
    (rec 0 nil)))


(defun make-ydiff (n coefs mx ly)
  (labels ((rec (i ly0)
             (if (= i n)
                 ly0
               (rec (1+ i)
                    (mapcar #'(lambda (x1 x2)
                                (+ x1 (* (aref coefs i) x2)))
                            ly0 (aref mx (1- i)))))))
    (mapcar #'- ly (rec 1 (nls (aref coefs 0) (length ly))))))
 

(defun calc_dcoef (n ra sigma0)
  (let ((decoefs (make-array (1+ n))))
    (for (i 0 (1+ n))
         (aset (decoefs i) (* sigma0 (aref ra i i))))
    decoefs))

#|
;;; linear least square fitting for x-y data
(defun lfit (n datfname)
  (multiple-value-bind(lx ly)
    (read-xy datfname)
    (let ((mx   (make-array n ))
	  (mer  (make-array `(,(1+ n) ,(1+ n)) :initial-element 0.0 :element-type 'double-float)))
      (aset (mx 0) lx)
      (for (i 1 n)
	   (aset (mx i) (mapcar #'(lambda (x y) (* x y)) lx (aref mx (1- i)))))
      (aset (mer 0 0) (length lx))
      (for (i 1 (1+ n))
	   (for (j 0 (1+ i))
		(aset (mer j (- i j)) (apply '+ (aref mx (1- i))))))
      (for (i (1+ n) (1+ (* 2 n)))
	   (for (j (- i n) (1+ n))
		(aset (mer j (- i j)) (l-ip (aref mx (1- n)) (aref mx (- i n 1))))))
      (let* ((ra (m-1 mer))
             (coefs (calc_coef n ra mx ly))
             (sigma0 (sqrt (/ (apply '+ (mapcar #'(lambda (x) (* x x)) (make-ydiff n coefs mx ly))) (length ly))))
             (dcoefs (calc_dcoef n ra sigma0)))

	  (with-open-file (out *plot-file* :direction :output)
	    (format out "set title \" ~A order Linear fit for ~A\"~%" (ordinal-form n) datfname)
	    (format out "unset label~%")
	    (format out "set nokey~%")
	    (format out "set xlabel \"X\"~%")
	    (format out "set ylabel \"Y\"~%")
	    (format out "set label \"\\~%")
	    (dotimes (i (1+ n))
              (format out "c[~D] = ~10,5E +/- ~10,5E \\n\\~%" i (aref coefs i) (aref dcoefs i)))
	    (format out "\" at graph 0.65,0.95 ~%")
	    (format out "plot \"~A\" w p 1, \\~%"  datfname)
	    (dotimes (i (1+ n))
	      (case i
                (0 (format out "(~A) \\~%" (aref coefs 0)))
                (1 (format out "+ (~A) * (x) \\~%" (aref coefs 1)))
                (t (format out "+ (~A) * (x**~D) \\~%" (aref coefs i) i))))
            (format out "w l 3"))
        (gplot (format nil "load \"~A\"" *plot-file*))
        (values coefs dcoefs)))))
|#

;;; making a ordinal number
(defun ordinal-form (n)
  (case n
    (1 "1st")
    (2 "2nd")
    (3 "3rd")
    (t (format nil "~Dth" n))))

;;; read data file
;;;create lists of x data and y data
(defun read-xy (datfname)
  (let (lx ly)
    (with-open-file (in datfname :direction :input)
      (awhile (read-line in nil nil)
	      (unless (char= #\# (char it 0))
		(let* ((p1 (position-if #'digit-char-p it))
		       (p2 (position #\SPC it :start p1))
		       (p3 (position-if #'digit-char-p it :start p2))
		       (p4 (position-if
			    #'(lambda (x) (or (char= x #\SPC) (char= x #\RET)))
			    it :start p3)))
		  (push (read-from-string (subseq it 0 p2)) lx)
		  (push (read-from-string (subseq it (1- p3) p4)) ly)))))
    (values (nreverse lx) (nreverse ly))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; jacob method to calculate eigen values and eigen vectors
(defun jacob(m0)
  "Calculate eigen values and eigen vectors of symmetric matrix by jacob method." ; added by Kuubo
  (let ((n (array-dimension m0 0)))
    (or (= n (array-dimension m0 1))
	(error "Matrix is not square"))
    (or (m-eql (m-t m0) m0) (error "not symmetrical"))
    (let ((m00 (adjust-array m0 `(,n ,n) :element-type 'double-float)))
      (jacob-loop n m00 (umat n) 40  (* 1.0e-10 (jacob-fmax n m0))))))    

;;; find max value at non rectangular position
(defun jacob-fmax (n m0)
  (let ((mx 0.0))
    (dotimes (i (1- n))
      (for (j (1+ i) n)
	   (let ((ab (abs (aref m0 i j))))
	     (if (< mx ab)
		 (setq mx ab)))))
    mx))

;;; calculating routine of jacob
(defun jacob-loop (size m0 u imax  eps)
  (without-floating-point-underflow
   (let ((rep 0))
     (loop
       (when (or (< (jacob-fmax size m0) eps) (= imax (incf rep)))
	 (jacob-sr size m0 u)
	 (return-from jacob-loop))
       (dotimes (p (1- size))
	 (for (q (1+ p) size)
	      (let ((apq (aref m0 p q)))
		(when (<  eps (abs apq))
		  (let* ((add        (* 0.5 (+ (aref m0 p p) (aref m0 q q))))
			 (sub        (* 0.5 (- (aref m0 p p) (aref m0 q q))))
			 (denom     (sqrt (+ (* sub sub) (* apq apq))))
			 (sap       (plusp sub))
			 (c         (/ (sqrt (funcall (if sap '+ '-) 1.0 (/ sub denom))) 1.41421356))
			 (s         (* (if sap 1.0 -1.0) (/ apq 2.0 c denom))))
		    (dotimes (j size)
		      (let ((n1 (+ (* c (aref m0 p j)) (* s (aref m0 q j))))
			    (n2 (- (* c (aref m0 q j)) (* s (aref m0 p j)))))
			(aset (m0 p j) n1
			      (m0 j p) n1
			      (m0 j q) n2
			      (m0 q j) n2)))
		    (aset (m0 p p) (funcall (if sap '+ '-) add denom)
			  (m0 q q) (funcall (if sap '- '+) add denom)
			  (m0 p q) 0.0
			  (m0 q p) 0.0)
		    (dotimes (i size)
		      (let ((uip (aref u i p))
			    (uiq (aref u i q)))
			(aset (u i p) (+ (* c uip) (* s uiq))
                  (u i q) (- (* c uiq) (* s uip))))))))))))))
  
;;; show result of jacob method
(defun jacob-sr (size m0 u)
  (format t "eigen value and corresponding eigen vector:~%")
  (dotimes (i size)
    (format t "~12,6E: ~%" (aref m0 i i))
    (format t "[ ")
    (dotimes (j size)
      (format t "~12,6E " (aref u j i)))
    (format t "]~%")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; calculate eigen value using hause-holder method and qr deconvolution
(defun eigen (m0)
  "Calculate eigen values of square matrix by hause-holder method and QR deconvolution." ; added by Kuubo
  (let ((n (array-dimension m0 0)))
    (or (= n (array-dimension m0 1))
      (error "Matrix is not square"))
    (let ((m00 (house-holder n (adjust-array m0 `(,n ,n) :element-type 'double-float))))
      (qr-dec n m00 0 50 1.0e-9))))

;;; show eigen values obtained by household reduction and qr deconvolution
(defun qr-sr (n m0)
  (dotimes (i n)
    (format t "eigen value[~D]: ~12,6E~%" (1+ i) (aref m0 i i))))

;;; check if the residual is small enougth
(defun qr-resid (n m0 resid)
  (dotimes (i (1- n) t)
    (and (< resid (abs (aref m0 i (1+ i)))) (return-from qr-resid nil))))

;;; QR decomposition loop using Gram-Schmit QR deconvolution
(defun qr-dec (n m0 i imax resid)
  (if (or (= i imax) (qr-resid n m0 resid))
      (qr-sr n m0)
    (without-floating-point-underflow
     (let ((q (make-array `(,n ,n) :initial-element 0.0 :element-type 'doulbe-float))
	   (r (make-array `(,n ,n) :initial-element 0.0 :element-type 'double-float))
	   (b (make-array n :initial-element 0.0 :element-type 'double-float)))
       (dotimes (k n)
	 (dotimes (i n)
	   (aset (b i) (aref m0 i k)))
	 (dotimes (j k)
	   (let ((s (v-ip (q _ j) b)))
	     (dotimes (i n)
	       (a-= (b i) (* s (aref q i j))))
	     (aset (r j k) s)))
	 (let ((s (sqrt (v-ip b b))))
	   (dotimes (i n)
	     (aset (q i k) (/ (aref b i) s)))
	   (aset (r k k) s)))
       (qr-dec n (m* r q) (1+ i) imax resid)))))
  
;;;
(defun house-holder (n m0)
  (house-holder-loop n m0 0 50 1.0e-9))

;;; check if hh conversion complete
(defun hh-resid (n a resid)
  (dotimes (i (- n 2) t)
    (for (j (+ i 2) n)
	 (if (< resid (abs (aref a j i))) (return-from hh-resid nil)))))

;;; househoulder routine
(defun house-holder-loop (n a i imax resid)
  (if (or (= i imax) (hh-resid n a resid))
      a
    (without-floating-point-underflow
     (let ((q (umat n))
	   (r (adjust-array a `(,n ,n) :element-type 'double-float))
	   (u (make-array n :initial-element 0.0 :element-type 'double-float))
	   (v (make-array n :initial-element 0.0 :element-type 'double-float)))
       (dotimes (k (1- n))
	 (let ((ss 0.0))
	   (for (i k n)
		(let ((aik (aref r i k)))
		  (aset (u i) aik)
		  (incf ss (* aik aik))))
	   (let ((s (* (sqrt ss) (if (< 0 (aref r k k)) -1.0 1.0))))
	     (a-= (u k) s)
	     (let* ((uu (* 2.0 (- ss (* s (aref r k k)))))
		    (c (/ 2.0 uu)))
	       (for (j k n)
		    (let ((w 0.0))
		      (for (i k n)
			   (incf w (* (aref u i) (aref r i j))))
		      (aset (v j) (* c w))))
	       (for (i k n)
		    (for (j k n)
			 (a-=  (r i j) (* (aref u i) (aref v j)))))
	       (dotimes (i n)
		 (let ((w 0.0))
		   (for (j k n)
			(incf w (* (aref q i j) (aref u j))))
		   (aset (v i) (* c w))))
	       (dotimes (i n)
		 (for (j k n)
		      (a-=  (q i j) (* (aref v i) (aref u j)))))))))
       (dotimes (i n)
	 (dotimes (j n)
	   (aset (a i j) (v-ip (r i _) (q _ j)))))
       (house-holder-loop n a (1+ i) imax resid)))))

      