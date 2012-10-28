(export 'ed::ttl-mode "ed")
(autoload 'ttl-mode "ttl-mode" t)
(pushnew '("\\.ttl$" . ttl-mode) *auto-mode-alist* :test 'equal)
