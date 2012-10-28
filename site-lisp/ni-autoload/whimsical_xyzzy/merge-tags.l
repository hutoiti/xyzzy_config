;(if (find "merge-tags" *modules* :test #'equal)
;    (setf (symbol-function 'ed::make-tags-file) nil))
;(autoload 'ed::make-tags-file "merge-tags" t)
(require "merge-tags")
