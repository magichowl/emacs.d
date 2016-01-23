(require-package 'dired+)
(require-package 'dired-sort)
(setq-default diredp-hide-details-initially-flag t
              dired-dwim-target t)

;; Prefer g-prefixed coreutils version of standard utilities when available
(let ((gls (executable-find "gls")))
  (when gls (setq insert-directory-program gls)))

(defun xah-open-in-external-app (&optional file)
  "Open the current file or dired marked files in external app.

The app is chosen from your OS's preference."
  (interactive)
  (let ( doIt
         (myFileList
          (cond
           ((string-equal major-mode "dired-mode") (dired-get-marked-files))
           ((not file) (list (buffer-file-name)))
           (file (list file)))))

    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files? ") ) )

    (when doIt
      (cond
       (*windows*
        (mapc (lambda (fPath) (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t)) ) myFileList))
       (*is-a-mac*
        (mapc (lambda (fPath) (shell-command (format "open \"%s\"" fPath)) )  myFileList) )
       (*linux*
        (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath)) ) myFileList) ) ) ) ) )

(global-set-key (kbd "C-S-o") 'xah-open-in-external-app)

(defun xah-open-in-desktop ()
  "Show current file in desktop (OS's file manager).
URL `http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html'
Version 2015-06-12"
  (interactive)
  (cond
   (*windows*
    (w32-shell-execute "explore" (replace-regexp-in-string "/" "\\" default-directory t t)))
   (*is-a-mac*
    (shell-command "open ."))
   (*linux*
    (let ((process-connection-type nil)) (start-process "" nil "xdg-open" "."))
    ;; (shell-command "xdg-open .") ;; 2013-02-10 this sometimes froze emacs till the folder is closed. ⁖ with nautilus
    )))

(global-set-key (kbd "C-S-d") 'xah-open-in-desktop)

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
