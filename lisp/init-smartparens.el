(require-package 'smartparens)
;; (require 'smartparens-latex)

;;  the smartparens-config.el file will auto-load all the mode-speceific customizations
(require 'smartparens-config)
(smartparens-global-mode t)

;; highlights matching pairs
(show-smartparens-global-mode t)

;; keybinding management
(define-key sp-keymap (kbd "C-M-<right>") 'sp-forward-sexp)
(define-key sp-keymap (kbd "C-M-<left>") 'sp-backward-sexp)
(define-key sp-keymap (kbd "C-S-a") 'sp-down-sexp)
(define-key sp-keymap (kbd "C-S-d") 'sp-backward-down-sexp)
;; (define-key sp-keymap (kbd "C-S-a") 'sp-beginning-of-sexp)
;; (define-key sp-keymap (kbd "C-S-d") 'sp-end-of-sexp)

(define-key sp-keymap (kbd "C-M-<down>") 'sp-up-sexp)
(define-key sp-keymap (kbd "C-M-<up>") 'sp-backward-up-sexp)
(define-key sp-keymap (kbd "C-M-t") 'sp-transpose-sexp)

(define-key sp-keymap (kbd "C-M-n") 'sp-next-sexp)
(define-key sp-keymap (kbd "C-M-p") 'sp-previous-sexp)

(define-key sp-keymap (kbd "M-d") 'sp-kill-sexp)
(define-key sp-keymap (kbd "C-M-w") 'sp-copy-sexp)
(define-key sp-keymap (kbd "M-<backspace>") 'sp-backward-kill-sexp)

;; (define-key sp-keymap (kbd "M-D") 'sp-splice-sexp)
;; (define-key sp-keymap (kbd "C-<right>") 'sp-forward-slurp-sexp)
;; (define-key sp-keymap (kbd "C-<left>") 'sp-forward-barf-sexp)
(setq sp-navigate-consider-symbols t)

;; local pair defs
;; it is wiser to use org-emphasize, but the following symbols are too common to emphasize
;; (sp-local-pair 'org-mode "*" "*")
;; (sp-local-pair 'org-mode "_" "_")
;; (sp-local-pair 'org-mode "/" "/")
;; (sp-local-pair 'org-mode "~" "~")
;; (sp-local-pair 'org-mode "=" "=")
;; (sp-local-pair 'org-mode "+" "+")

(sp-local-pair 'org-mode "$" "$")
(sp-local-pair 'LaTeX-mode "(" ")")
(sp-pair "`" nil :actions :rem) ; conflict with cdlatex call for math symbols
(sp-pair "'" nil :actions :rem)

(setq sp-ignore-modes-list
      (delete 'minibuffer-inactive-mode sp-ignore-modes-list))

(provide 'init-smartparens)
