(in-package "editor")
(require "key-chord")
(add-hook '*pre-command-hook* 'key-chord)