;;; Gnus-config
;;;
(setq gnus-asynchronous t)
;(setq mail-user-agent 'gnus-user-agent)
;(setq read-mail-command 'gnus)
;(setq send-mail-command 'gnus-msg-mail)
(setq gnus-init-file "~/.emacs.d/lisp/.gnus.el")

(defvar tv-gnus-loaded-p nil)
(defun tv-load-gnus-init-may-be ()
  (unless tv-gnus-loaded-p
    (load gnus-init-file)
    (setq tv-gnus-loaded-p t)))

(add-hook 'message-mode-hook 'tv-load-gnus-init-may-be)
(add-hook 'gnus-before-startup-hook 'tv-load-gnus-init-may-be)

(defun quickping (host)
  "Return non--nil when host is reachable."
  (= 0 (call-process "ping" nil nil nil "-c1" "-W10" "-q" host)))

(defun tv-gnus (arg)
  "Start Gnus.
If Gnus have been started and a *Group* buffer exists,
switch to it, otherwise check if a connection is available and
in this cl-case start Gnus plugged, otherwise start it unplugged."
  (interactive "P")
  (let ((buf (get-buffer "*Group*")))
    (if (buffer-live-p buf)
        (switch-to-buffer buf)
        (if (or arg (not (quickping "imap.aliyun.com")))
            (gnus-unplugged)
            (gnus)))))

;; Borred C-g'ing all the time and hanging emacs
;; while in gnus (while tethering or not).
;; Kill all nnimap/nntpd processes when exiting summary.
(defun tv-gnus-kill-all-procs ()
  (cl-loop for proc in (process-list)
        when (string-match "\\*?\\(nnimap\\|nntpd\\)" (process-name proc))
        do (delete-process proc)))
(add-hook 'gnus-exit-group-hook 'tv-gnus-kill-all-procs)
(add-hook 'gnus-group-catchup-group-hook 'tv-gnus-kill-all-procs)

(autoload 'gnus-dired-attach "gnus-dired.el")
(declare-function 'gnus-dired-attach "gnus-dired.el" (files-to-attach))
(define-key dired-mode-map (kbd "C-c C-a") 'gnus-dired-attach)

;; Auth-source
(setq auth-sources '((:source "~/.authinfo.gpg" :host t :protocol t)))

(if (and *linux* (file-exists-p "/usr/local/share/emacs/site-lisp/mu4e/mu4e.el"))
    (progn (add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
           (require 'mu4e-config))
  (message "Warning: mu4e is not installed!...fail"))

(provide 'gnus-mu4e)
