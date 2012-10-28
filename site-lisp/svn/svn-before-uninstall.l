;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; $HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn-before-uninstall.l $
;;;
;;; $LastChangedDate: 2005-07-04 21:59:51 +0900 (Mon, 04 Jul 2005) $
;;;
;;; $LastChangedRevision: 171 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;
;;; svn-mode uninstall script
;;;

(require "svn/svn")

(defun svn-uninstall-before ()
  "Delete history variables before uninstall."
  (unregister-history-variable *svn-src-files-history*)
  (unregister-history-variable *svn-dst-files-history*)
  (unregister-history-variable *svn-rev-history*)
  (unregister-history-variable *svn-msg-history*)
  (unregister-history-variable *svn-keywords-history*)
  (unregister-history-variable *svn-keyvalue-history*)
  )

(svn::svn-uninstall-before)
