(defpackage "refer-for" (:use "lisp"))
(in-package "refer-for")
(shadow '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-mode-hook*
          *refer-for-mode-map*
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-msxml-prog-id*
          *buffer-name*
          *msxml-prog-id*
          *reference-file*
          *regexp-search*
          *search-history*
          *sort-alphabetically*
          *style-file*
          *style-file-for-search*
          add-interactive-attr-and-result-number
          create-document-object
          if-not-bound
          load-xml-object
          load-searcher-object
          nodes2list
          output
          search
          set-history
          sort-alphabetically
          ))
(export '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-search-history*
          *refer-for-msxml-prog-id*
          *refer-for-mode-hook*
          *refer-for-mode-map*))
(in-package "user")
(use-package "refer-for")
(autoload 'refer-for "refer-for" t nil)
(autoload 'refer-to-titles "refer-for" t nil)
