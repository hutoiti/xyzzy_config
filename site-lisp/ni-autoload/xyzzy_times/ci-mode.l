(export 'ed::ci-mode "ed")
(autoload 'ci-mode "ci-mode" t)
(pushnew '("\\.Å[$" . ci-mode) *auto-mode-alist* :test 'equal)
