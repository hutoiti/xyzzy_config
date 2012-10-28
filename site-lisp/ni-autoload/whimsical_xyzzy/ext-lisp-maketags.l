;(if (not (find "ext-lisp-maketags" *modules* :test #'equal))
;    (unintern 'ed::lisp-maketags))
;(autoload 'ed::lisp-maketags "ext-lisp-maketags")
(require "ext-lisp-maketags")
