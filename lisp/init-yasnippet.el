(require-package 'yasnippet)
(require 'yasnippet)
;; my private snippets
(setq my-yasnippets (expand-file-name "~/snippets"))
(if (and  (file-exists-p my-yasnippets) (not (member my-yasnippets yas-snippet-dirs)))
    (add-to-list 'yas-snippet-dirs my-yasnippets))

(add-to-list 'auto-mode-alist '("\\.yasnippet\\'" . snippet-mode))

(defun my-yas-load-directory-hook ()
    (if (eq yas-minor-mode t)
        (yas-load-directory my-yasnippets
                            )))

(add-hook 'yas-minor-mode-hook 'my-yas-load-directory-hook)

(yas-global-mode 0)

;; default TAB key is occupied by auto-complete
;; (global-set-key (kbd "C->") 'yas-expand)
;; default hotkey `C-c C-s` is still valid
;; (global-set-key (kbd "C-c l") 'yas-insert-snippet)
;; give yas/dropdown-prompt in yas/prompt-functions a chance
(require-package 'dropdown-list)
(require 'dropdown-list)
(setq yas-prompt-functions '(yas-dropdown-prompt
                              yas-ido-prompt
                              yas-completing-prompt))
;; use yas/completing-prompt when ONLY when `M-x yas-insert-snippet'
;; thanks to capitaomorte for providing the trick.
(defadvice yas-insert-snippet (around use-completing-prompt activate)
     "Use `yas-completing-prompt' for `yas-prompt-functions' but only here..."
       (let ((yas-prompt-functions '(yas-completing-prompt)))
             ad-do-it))
;; @see http://stackoverflow.com/questions/7619640/emacs-latex-yasnippet-why-are-newlines-inserted-after-a-snippet
(setq-default mode-require-final-newline nil)
(provide 'init-yasnippet)