;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: php-misc.l 432 2005-11-24 17:57:10Z torihat $
;
; php-misc.l
;
;   PHP用マクロとか
;

(require "php-mode")

(in-package "editor")

(export '(*php-doc-base-path*
	  *php-html-help-path*
	  php-doc-function
	  php-unit-create-skelton))

;;;
;;; php-doc-function
;;;
;;; F1 で関数マニュアルを開く
;;;

(defvar *php-doc-base-path* "http://www.php.net/manual/ja/")
; ローカルにある場合
;(setq *php-doc-base-path* "C:/path/to/html/manual/")

(defun php-doc-function-file (func)
  (format nil "function.~A.php" (substitute-string func "_" "-")))

(defun php-doc-function-open (func)
  (let ((path (concat *php-doc-base-path*
		      (php-doc-function-file func)))
	(navigate (or (find-symbol "navigate" "user")
		      (and (find-package "bx")
			   (find-symbol "navigate" "bx")))))
    (if (and navigate
	     (fboundp navigate))
	(funcall navigate path)
      (shell-execute path t))))

(defun php-doc-function ()
  (interactive)
  (let (func)
    (save-excursion
      (skip-chars-backward "a-zA-Z0-9_")
      (when (looking-at "[a-zA-Z_][a-zA-Z0-9_]+")
	(setq func (match-string 0))
	(php-doc-function-open func)))))

(define-key *php-mode-map* #\F1 'php-doc-function)

;;;
;;; php-html-help
;;;
;;; S-F1 でHTML Helpを開く
;;;

; HTML Helpファイルへのパス
(defvar *php-html-help-path* "C:/xyzzy/etc/php_manual_ja.chm")

(defun php-show-html-help ()
  (interactive)
  (html-help *php-html-help-path* (get-winhelp-topic)))

(define-key *php-mode-map* #\S-F1 'php-show-html-help)

;;;
;;; php-unit-create-skelton
;;;
;;; PHPUnitのスケルトンを生成する [C-c s]
;;;

(defvar *php-unit-skelton*
  "<?php
require_once 'phpunit.php';
//require_once '~A.php';

class ~ATest extends TestCase{

  function ~ATest($name) {
    $this->TestCase($name);
  }

  function setUp(){
  }

  function tearDown(){
  }
  
}

$suite = new TestSuite('~ATest');

$runner = new TestRunner;
$runner->run($suite);
?>
")

(defun php-unit-create-skelton ()
  (interactive)
  (let (classname)
    (save-excursion
      (goto-char (point-min))
      (when (scan-buffer "^class +\\([^ \n]+\\)" :regexp t :case-fold t)
	(setq classname (match-string 1))))
    (when (setq classname (read-string "Class Name: " :default classname))
      (set-buffer (get-buffer-create " *PHP-Unit*"))
      (erase-buffer (selected-buffer))
      (php-mode)
      (insert (php-unit-format classname)))))

(defun php-unit-format (classname)
  (format nil *php-unit-skelton*
	  classname
	  classname
	  classname
	  classname))

(define-key *php-mode-map* '(#\C-c #\s) 'php-unit-create-skelton)
