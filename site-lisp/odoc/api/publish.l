;;; -*- Mode: Lisp -*-
;;  publish:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       publish is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(export '(publish))

(defun publish-directory(file)
  (if file (directory-namestring file)      ; no use?
    (default-directory)))

(defun publish()
  (interactive)
  (config)
  (let*((file (get-buffer-file-name))
        (dir  (publish-directory file))
        (title (page-title))
        (pub (concat title ".html"))
        (list (study))
        (xml-contents (xml-contents list))
        (p-member (let(r str i)
                    (dolist(x list
                              (setq i
                                    (length
                                     (setq str
                                           (substitute-string
                                           (format nil "~{~A~}" (nreverse r))
                                            "<[^>]+?>" "")
                                           ))))
                      (if(eq :p (car x))(push (apply #'concat (cdr x)) r)))
                    (convert-encoding-from-internal
                     *encoding-utf8n*
                     (subseq str 0 (if(< 500 i) 500 i)))
                    )
                  ))
    (unless(equal *md5* (md5-read-check))
      (md5-write)
      (atom-create)
      (atom-push xml-contents p-member)
      (rss-create)
      (rss-push xml-contents p-member)
      (setq *heading-link* 0)
      (with-open-file(out (merge-pathnames pub dir)
                          :direction :output
                          :if-does-not-exist  :create
                          :if-exists :overwrite)
        (contents list dir title out))
      (setq *heading-link* 0)
      (multiple-value-bind(a b)
          (index-study dir)
        (setq *heading-link* 0)
        (with-open-file(out (merge-pathnames "index.html" dir)
                            :direction :output
                            :if-does-not-exist  :create
                            :if-exists :overwrite)
          (contents b dir :index out)))
      (setq *heading-link* 0)
      (with-open-file(out (merge-pathnames "recent.html" dir)
                          :direction :output
                          :if-does-not-exist  :create
                          :if-exists :overwrite)
        (contents (re-study dir) dir :recent out))
      (setq *heading-link* 0))
    (find-file (merge-pathnames pub dir))
    (run-hooks '*odoc-publish-hook*)
    ))

(provide :odoc/api/publish)

;; end
