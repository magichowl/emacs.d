(require-package 'diff-hl)
(add-hook 'prog-mode-hook 'turn-on-diff-hl-mode)
(add-hook 'vc-dir-mode-hook 'turn-on-diff-hl-mode)

(global-set-key (kbd "<C-M-next>") 'diff-hl-next-hunk)
(global-set-key (kbd "<C-M-prior>") 'diff-hl-previous-hunk)

(provide 'init-vc)
