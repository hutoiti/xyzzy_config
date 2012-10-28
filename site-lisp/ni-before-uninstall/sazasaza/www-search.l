(unless (find *this-command*
              '(ni::app-install-current
                ni::app-install-marked))
  (require "www-search")
  (ed::www-search-uninstall))