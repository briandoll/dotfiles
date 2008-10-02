;;; semantic-ia.el --- Interactive Analysis functions

;;; Copyright (C) 2000, 2001, 2002 Eric M. Ludlam

;; Author: Eric M. Ludlam <zappo@gnu.org>
;; Keywords: syntax
;; X-RCS: $Id: semantic-ia.el,v 1.2 2002/03/23 03:08:01 zappo Exp $

;; This file is not part of GNU Emacs.

;; Semantic is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;;
;; Interactive access to `semantic-analyze'.
;;

(require 'semantic-analyze)

;;; Code:
(defcustom semantic-ia-completion-token->text
  'semantic-prototype-nonterminal
  "*Function used to convert a token to a string during completion."
  :group 'semantic
  :type semantic-token->text-custom-list)

(defvar semantic-ia-cache nil
  "Cache of the last completion request.
Of the form ( POINT . COMPLETIONS ) where POINT is a location in the
buffer where the completion was requested.  COMPLETONS is the list
of semantic token names that provide logical completions from that
location.")
(make-variable-buffer-local 'semantic-ia-cache)

(defun semantic-ia-get-completions (context point)
  "Fetch the completion of CONTEXT at POINT.
Supports caching."
  (let ((symbols
	 (if (and semantic-ia-cache
		  (= point (car semantic-ia-cache)))
	     (cdr semantic-ia-cache)
	   (semantic-analyze-possible-completions context))))
    ;; Set the cache
    (setq semantic-ia-cache (cons point symbols))
    symbols))

(defun semantic-ia-complete-symbol (point)
  "Complete the current symbol at POINT.
Completion options are calculated with `semantic-analyze-possible-completions'."
  (interactive "d")
  (let* ((a (semantic-analyze-current-context point))
	 (syms (semantic-ia-get-completions a point))
	 (pre (car (reverse (oref a prefix))))
	 )
    ;; Complete this symbol.
    (if (null syms)
	(message "No smart completions found.")
      ;; Use try completion to seek a common substring.
      (let ((tc (try-completion pre syms)))
	(if (and (stringp tc) (not (string= tc pre)))
	    (let ((tok (semantic-find-nonterminal-by-name
			tc syms)))
	      ;; We have some new text.  Stick it in.
	      (delete-region (car (oref a bounds))
			     (cdr (oref a bounds)))
	      (goto-char (car (oref a bounds)))
	      (if tok
		  (semantic-ia-insert-token tok)
		(insert tc)))
	  ;; We don't have new text.  Show all completions.
	  (goto-char (cdr (oref a bounds)))
	  (with-output-to-temp-buffer "*Completions*"
	    (display-completion-list
	     (mapcar semantic-ia-completion-token->text syms))
	    ))))))

(defcustom semantic-ia-completion-token->text
  'semantic-uml-concise-prototype-nonterminal
  "*Function used to convert a token to a string during completion."
  :group 'semantic
  :type semantic-token->text-custom-list)

(defun semantic-ia-complete-symbol-menu (point)
  "Complete the current symbol via a menu based at POINT.
Completion options are calculated with `semantic-analyze-possible-completions'."
  (interactive "d")
  (let* ((a (semantic-analyze-current-context point))
	 (syms (semantic-ia-get-completions a point))
	 (pre (car (reverse (oref a prefix))))
	 )
    ;; Complete this symbol.
    (if (not syms)
	(error "No completions available"))
    (let ((ans
	   (imenu--mouse-menu
	    (mapcar (lambda (tok)
		      (cons (funcall semantic-ia-completion-token->text tok)
			    (vector tok)))
		    syms)
	    (senator-completion-menu-point-as-event)
	    "Completions")))
      (when ans
	(setq ans (aref (cdr ans) 0))
	(delete-region (car (oref a bounds)) (cdr (oref a bounds)))
	(semantic-ia-insert-token ans))
      )))

(defun semantic-ia-insert-token (token)
  "Insert TOKEN into the current buffer based on completion."
  ;; I need to convert this into an override method!
  (insert (semantic-token-name token))
  (let ((tt (semantic-token-token token)))
    (cond ((eq tt 'function)
	   (insert "("))
	  (t nil))))

(defun semantic-ia-complete-tip (point)
  "Pop up a tooltip for completion at POINT."
  (interactive "d")
  (let* ((a (semantic-analyze-current-context point))
	 (syms (semantic-ia-get-completions a point))
	 (w (get-buffer-window (current-buffer)))
         (x (mod (- (current-column) (window-hscroll))
                 (window-width)))
         (y (save-excursion
              (save-restriction
                (widen)
                (narrow-to-region (window-start) (point))
                (goto-char (point-min))
                (1+ (vertical-motion (buffer-size))))))
	 (str (mapconcat #'semantic-token-name
			 syms
			 "\n"))
	 )
    (cond ((fboundp 'x-show-tip)
	   (x-show-tip str
		       (selected-frame)
		       nil
		       nil
		       x y)
	   )
	  (t (message str))
	  )))

(provide 'semantic-ia)

;;; semantic-ia.el ends here
