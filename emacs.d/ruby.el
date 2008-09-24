;; loads ruby mode when a .rb file is opened.
(load-file "~/.emacs.d/modes/inf-ruby.el")
(load-file "~/.emacs.d/modes/ruby-mode.el")

(autoload 'ruby-mode "ruby-mode" "Major mode for editing ruby scripts." t)
(setq auto-mode-alist  (cons '(".rb$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '(".erb$" . html-mode) auto-mode-alist))

