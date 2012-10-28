;;; -*- Mode: Lisp -*-
;;  contents:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       contents is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun contents(list dir title+ stream)
  (format stream "~A"
          (convert-encoding-from-internal
           (encode)
           (concat
            (header title+)
            (main-contents list)
            (menu list dir)
            (footer))))
  )

(defun page-title()(pathname-name(buffer-name(selected-buffer))))

(defun header(&optional title+)
  (let*((title (car (conf-member :title)))
        (h (conf-member :host))
        (sub  (conf-member :sub))
        (host (if h (append-trail-slash(car h)) "")))
    (format
     nil
     (concat
      *doctype->html*
      "<head>
<meta name=\"Author\" content=\"~{~A~}\" />
<meta name=\"Description\" content=\"~{~A~}\" />
<link rel=\"alternate\" type=\"application/atom+xml\" title=\"~A ATOM 1.0\" href=\"~A~A\" />
<link rel=\"alternate\" type=\"application/rss+xml\" title=\"~A RSS 2.0\" href=\"~A~A\" />
"
      *doc-generator*
      "~{~A~%~}
</head>
<title>~A</title>
<body>
<!-- title -->
<div class=\"title\">
<h1><a href=\"./\">~A</a></h1>
<div class=\"sub\">~{~A~}</div>
</div>~%"
      )
     (conf-member :author)
     sub
     title host *atom-xml*
     title host *rss-xml*
     (conf-member :header)
     (cond((eq title+ :index) title)
          ((eq title+ :recent) "Recent")
          (t (concat title " - " (page-title)
                     " - "
                     (save-excursion(goto-char(point-min))
                       (substitute-string
                        (buffer-substring(point)
                                         (progn(goto-eol)(point)))
                        "^=+" "")))))
     title
     sub
     )))
(defvar *insert-h* ())
(defun main-contents(list)
  (format
   nil
   "~&<!-- main contents start -->
<div class=\"mc\">
~{~A~}
~A</div>
<!-- main contents end -->
"
   ;h=[cp, cc]
   (mapcar
    #'(lambda(x)
        (cond
         ((eq :ol  (car x))(ol (cdr x)))
         ((eq :ul  (car x))(ul (cdr x)))
         ((eq :h   (car x))(setq *insert-h* t)(h (cadr x)))
         ((eq :hr  (car x))(hr))
         ((eq :pre (car x))(pre (cdr x)))
         ((eq :table (car x))(table (cdr x)))
         ((eq :dl (car x))(dl (cdr x)))
         ((eq :bkq (car x))(blockquote (cdr x)))
         ((eq :p   (car x))(p (cdr x))))
        )
    list)
   (if *insert-h* (progn (setq *insert-h* ())"</div>\n</div>\n") "")
   ))

(defun menu(list dir)
  (cond((string= "on"(car (conf-member :menu)))
        (concat
         "<!-- menu -->
<div class=\"menu\">"
         (toc list)
         (recent dir)
         (format nil "<div class=\"mpl\">~%~{~A~%~}</div>~%"
                 (conf-member :menu-plugins))
         "</div>"
         ))
       ((string= "off" (car (conf-member :menu)))
        "")
       (t "")))

(defun toc(list)
  (let((str))
    (format
     nil
     (concat
      "~&<!-- table of contents -->~%<div class=\"toc\">~%"
      *table-of-contents-title*
      "~A~%</div>~%"
      )
     (list-judge
      (remove
       nil
       (mapcar
        #'(lambda(a)
            (if(eq :h (car a))
                (let*((s (cadr a))
                      (n (position-if-not
                          #'(lambda(x)(eq #\= x)) s)))
                  (concat
                   (make-sequence 'string (*(+ n 1)2)
                                  :initial-element #\SPC)
                   "-";
                   (concat
                    "<a href=\"#"
                    (setq str
                          (string-left-trim
                           " "
                           (substitute-string
                            (subseq s n)
                            "\\[\\(.*?\\)\\]"
                            "\\1")))
                    "\">" str "</a>")
                   ))))
        list))
      ))))

(defun recent(dir)
  (let*((list
         (sort
          (delete-if #'(lambda(x)
                         (or(string-match "recent.html$" x)
                            (string-match "index.html$" x)))
                     (directory (default-directory)
                                :wild '("*.html")))
          #'(lambda(a b)
              (file-newer-than-file-p a b)))) ; sort save time
        (rl
         (subseq
          (mapcar #'(lambda(x)(list (si:www-url-encode x) (pathname-name x))) list)
          0
          (if (< (length list) *odoc-recent-views*)
              (length list) *odoc-recent-views*))))
    (if(> 2 (length list)) ""
      (format
       nil
       (concat
        "~&<!-- recent -->~%<div class=\"recent\">~%"
        *recent-title*
        (and list
             "<ul>~{~%<li><a href=\"~{~A\" target=\"_blank\">~A~}</a></li>~}~%</ul>")
        "~&</div>~%")
       rl rl)
      )))

(defun footer()
  (format
   nil
   (concat
    *footer-from*
    "~&<!-- footer -->~%<div class=\"footer\">
~{~A~%~}
</div>
<!-- date -->~%<div class=\"date\">~A</div>
</body>~%</html>
")
   (conf-member :footer)
   (format-date-string (car (conf-member :date)))))



(provide :odoc/api/contents)

;; end
