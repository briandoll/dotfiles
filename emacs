(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/modes")

;; theme support, defauls to twilight for everything
(global-font-lock-mode 1)
(load-file "~/.emacs.d/theme.el")

;; ruby support for syntax highlighting
(load-file "~/.emacs.d/ruby.el")

;; load ecb support and configuration
(load-file "~/.emacs.d/ecb.el")