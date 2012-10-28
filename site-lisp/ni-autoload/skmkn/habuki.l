(in-package "user")
(defpackage "habuki" (:use "lisp" "editor"))
(use-package "habuki")
(in-package "habuki")
(export
 '(habuki-mode
   *habuki-mode-hook* *habuki-help-activate-hook* *habuki-memo*
   *habuki-normal-rule* *habuki-abbrev-rule*
   *habuki-help-on* *habuki-help-after-num* *habuki-help-before-num*
   *habuki-help-keyboard-on* *habuki-help-word* *habuki-abbrev-output-method*
   *habuki-cur-root-name* *habuki-num-convert* *habuki-lone-char* 
   *habuki-test-left-char* *habuki-test-home-char* *habuki-mode-map*))
(autoload 'habuki-mode "habuki" t)