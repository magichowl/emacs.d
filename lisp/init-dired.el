(require-package 'dired+)
(require-package 'dired-sort)
(setq-default diredp-hide-details-initially-flag t
              dired-dwim-target t)

;; add packing and unpacking for dired
(load-file "~/.emacs.d/package/dired-pack/dired-pack.el")
(require 'dired-pack)

;; run asynchronously for copying, renaming and symlinking
(require-package 'async)
(when (require 'dired-aux)
  (require 'dired-async))

(after-load 'dired
  (require 'dired+)
  (require 'dired-sort)
  (when (fboundp 'global-dired-hide-details-mode)
    (global-dired-hide-details-mode -1))
  (setq dired-recursive-deletes 'top)
  (define-key dired-mode-map [mouse-2] 'dired-find-file)
  ;; no corresponding functions
  (if *linux*
      (define-key dired-mode-map (kbd "A") 'gnus-dired-attach))
  (define-key dired-mode-map (kbd "<M-up>") (kbd "^"))
  (define-key dired-mode-map (kbd "F") 'find-name-dired)
  (define-key dired-mode-map (kbd "D") '(lambda () (interactive) (setq delete-by-moving-to-trash (not delete-by-moving-to-trash))))
  (add-hook 'dired-mode-hook
            (lambda () (guide-key/add-local-guide-key-sequence "%"))))

(when (maybe-require-package 'diff-hl)
  (after-load 'dired
    (add-hook 'dired-mode-hook 'diff-hl-dired-mode)))

(provide 'init-dired)
