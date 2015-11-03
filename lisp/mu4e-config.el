;;; mu4e-config.el --- Config for mu4e.

;;; Code:

(setq gnus-init-file "~/.emacs.d/lisp/.gnus.el")
(load-file gnus-init-file)
(require 'mu4e)
(require 'mu4e-contrib)
;; (el-get 'sync 'helm)
;; (require 'helm-config)
;; (el-get 'sync 'helm-mu)
;; (require 'helm-mu)
(require 'org-mu4e)
;; (require 'config-w3m)
(require-package 'mu4e-maildirs-extension)
(mu4e-maildirs-extension)

;; default
(setq mu4e-maildir "~/Maildir")
(setq mu4e-compose-complete-addresses nil)
(setq mu4e-completing-read-function 'completing-read)
(setq mu4e-view-show-addresses t)

;;; Html rendering
(setq mu4e-view-prefer-html t)
(setq mu4e-html2text-command (cond ((fboundp 'w3m)
                                    (lambda ()          ; Use emacs-w3m
                                      (w3m-region (point-min) (point-max))))
                                   ((executable-find "w3m")
                                    "w3m -T text/html") ; Use w3m shell-command
                                   (t (lambda ()        ; Use shr (slow)
                                        (let ((shr-color-visible-luminance-min 75)
                                              shr-width)
                                          (shr-render-region (point-min) (point-max)))))))

(setq mail-user-agent 'mu4e-user-agent)
(setq read-mail-command 'mu4e)

;; when mail is sent, automatically convert org body to HTML
(setq org-mu4e-convert-to-html t)
;; (org-export-preserve-breaks nil)

(define-key mu4e-main-mode-map "q" 'quit-window)
(define-key mu4e-main-mode-map "Q" 'mu4e-quit)

;; save message to Sent Messages
(setq mu4e-sent-messages-behavior 'sent)

(setq mu4e-headers-skip-duplicates t)

;; signature
(setq
 message-signature-file (expand-file-name "~/.signature")
 mu4e-compose-signature message-signature
 mu4e-compose-signature-auto-include nil)

(defun djcb-mu4e-choose-signature ()
  "Insert one of a number of sigs"
  (interactive)
  (let ((message-signature
          (mu4e-read-option "Signature:"
                            '(
                              ("full" .
                               (get-string-from-file (expand-file-name "~/.signature")))
                              ("en" .
                               (get-string-from-file (expand-file-name "~/.signature-en")))
                              ("zh" .
                               (get-string-from-file (expand-file-name "~/.signature-zh")))
                              ("private" .
                "致

礼!

潘森杉")
               ))))
    (message-insert-signature)))
(define-key message-mode-map "\C-c\C-w" 'djcb-mu4e-choose-signature)

;; encryption
(define-key mu4e-view-mode-map [remap mu4e-view-verify-msg-popup] 'epa-mail-verify)

;; setup some handy shortcuts
;; you can quickly switch to your Inbox -- press ``ji''
;; then, when you want archive some messages, move them to
;; the 'All Mail' folder by pressing ``ma''.

(setq mu4e-maildir-shortcuts
      '(("/aliyun/Inbox"               . ?i)
        ("/163/INBOX"                 . ?1)
        ("/163/&V4NXPpCuTvY-"         . ?2) ; Spam of 163
        ("/sent"   . ?s)
        ("/trash"       . ?t)
        ("/aliyun/Spam"        . ?!)
        ;; ("/aliyun/All Mail"    . ?a)
        ))

(setq mu4e-bookmarks
      '(("date:1w..now helm AND NOT flag:trashed" "Last 7 days helm messages"                                                                           ?h)
        ("flag:unread AND NOT flag:trashed AND NOT maildir:/aliyun/Spam AND NOT maildir:/163/&V4NXPpCuTvY-" "Unread messages"               ?u)
        ("date:today..now AND NOT flag:trashed AND NOT maildir:/aliyun/Spam AND NOT maildir:/163/&V4NXPpCuTvY-" "Today's messages"          ?t)
        ("date:1d..now AND NOT flag:trashed AND NOT maildir:/aliyun/Spam AND NOT maildir:/163/&V4NXPpCuTvY-" "Yesterday and today messages" ?y)
        ("date:7d..now AND NOT flag:trashed AND NOT maildir:/aliyun/Spam AND NOT maildir:/163/&V4NXPpCuTvY-" "Last 7 days"                  ?w)
        ("mime:image/* AND NOT flag:trashed AND NOT maildir:/aliyun/Spam AND NOT maildir:/163/&V4NXPpCuTvY-" "Messages with images"         ?p)))

(add-hook 'mu4e-compose-mode-hook 'tv/message-mode-setup) ; loaded from .gnus.el
(global-set-key (kbd "s-o") 'org-mu4e-compose-org-mode)
;; use 'fancy' non-ascii characters in various places in mu4e
(setq mu4e-use-fancy-chars t)

;; save attachment (this can also be a function)
(setq mu4e-attachment-dir "~/Downloads")

;;; Updating
;;
;;
;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "offlineimap -q -u Basic")

;; Make a full update all the
;; `tv/mu4e-max-number-update-before-toggling' mail retrievals.
(defvar tv/mu4e-counter 10) ; Ensure a full update on startup.
(defvar tv/mu4e-max-number-update-before-toggling 10)
(defvar tv/mu4e-get-mail-command-full "offlineimap -u Basic")
(defvar tv/mu4e-get-mail-command-quick "offlineimap -q -u Basic")
(defun tv/mu4e-update-mail-quick-or-full ()
  (if (>= tv/mu4e-counter
          tv/mu4e-max-number-update-before-toggling)
      (progn
        (setq mu4e-get-mail-command tv/mu4e-get-mail-command-full)
        (setq tv/mu4e-counter 0))
      (setq mu4e-get-mail-command tv/mu4e-get-mail-command-quick)
      (incf tv/mu4e-counter)))
(add-hook 'mu4e-update-pre-hook #'tv/mu4e-update-mail-quick-or-full)

;; attempt to show images when viewing messages
(setq mu4e-view-show-images t
      mu4e-view-image-max-width 800)

;; Allow queuing mails
(setq smtpmail-queue-mail  nil  ;; start in non-queuing mode
      smtpmail-queue-dir   "~/Maildir/queue/")

;; View html message in firefox (type aV)
(add-to-list 'mu4e-view-actions
            '("ViewInBrowser" . mu4e-action-view-in-browser) t)

;; Decorate mu main view
(defun mu4e-main-mode-font-lock-rules ()
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\[\\([a-zA-Z]\\{1,2\\}\\)\\]" nil t)
      (add-text-properties (match-beginning 1) (match-end 1) '(face font-lock-variable-name-face)))))
(add-hook 'mu4e-main-mode-hook 'mu4e-main-mode-font-lock-rules)

;; Handle quoted text added with `message-mark-inserted-region' (`C-c M-m')
(add-hook 'mu4e-view-mode-hook 'mu4e-mark-region-code)

(defun tv/mu4e-browse-url ()
  (interactive)
  (browse-url (w3m-active-region-or-url-at-point)))
(define-key mu4e-view-mode-map (kbd "C-c C-c") 'tv/mu4e-browse-url)

(defadvice w3m-goto-next-anchor (before go-to-end-of-anchor activate)
  (when (w3m-anchor-sequence)
    (goto-char (next-single-property-change
                (point) 'w3m-anchor-sequence))))

(defadvice w3m-goto-previous-anchor (before go-to-end-of-anchor activate)
  (when (w3m-anchor-sequence)
    (goto-char (previous-single-property-change
                (point) 'w3m-anchor-sequence))))

(define-key mu4e-view-mode-map (kbd "C-i") 'w3m-next-anchor)
(define-key mu4e-view-mode-map (kbd "M-<tab>") 'w3m-previous-anchor)

;; A simplified and more efficient version of `article-translate-strings'.
;; Transform also in headers.
(defun mu4e~view-translate-strings (map)
  "Translate all string in the the article according to MAP.
MAP is an alist where the elements are on the form (\"from\" \"to\")."
  (save-excursion
    (goto-char (point-min))
    (let ((inhibit-read-only t))
      (dolist (elem map)
        (let* ((key  (car elem))
               (from (if (characterp key) (string key) key))
               (to   (cdr elem)))
          (save-excursion
            (while (search-forward from nil t)
              (replace-match to))))))))

(defun mu4e-view-treat-dumbquotes ()
    "Translate M****s*** sm*rtq**t*s and other symbols into proper text.
Note that this function guesses whether a character is a sm*rtq**t* or
not, so it should only be used interactively.

Sm*rtq**t*s are M****s***'s unilateral extension to the
iso-8859-1 character map in an attempt to provide more quoting
characters.  If you see something like \\222 or \\264 where
you're expecting some kind of apostrophe or quotation mark, then
try this wash."
  (interactive)
  (with-current-buffer mu4e~view-buffer
    (mu4e~view-translate-strings
     '((128 . "EUR") (130 . ",") (131 . "f") (132 . ",,")
       (133 . "...") (139 . "<") (140 . "OE") (145 . "`")
       (146 . "'") (147 . "``") (148 . "\"") (149 . "*")
       (150 . "-") (151 . "--") (152 . "~") (153 . "(TM)")
       (155 . ">") (156 . "oe") (180 . "'")))))

;; Same as `article-remove-cr' (W-c) but simplified and more efficient.
;; Not sure it is needed in mu4e though.
(defun mu4e-view-remove-cr ()
  "Remove trailing CRs and then translate remaining CRs into LFs."
  (interactive)
  (save-excursion
    (let ((inhibit-read-only t))
      (goto-char (point-min))
      (while (re-search-forward "\r" nil t)
        (if (eolp)
            (replace-match "" t t)
            (replace-match "\n" t t))))))

;; Show Smileys
(add-hook 'mu4e-view-mode-hook 'smiley-buffer)

;; Fix bug when gnus-agent is offline.
(add-hook 'mu4e-compose-mode-hook
          (lambda ()
            (set (make-local-variable 'message-send-mail-real-function) nil)))

;; Automatic updates.
(setq mu4e-update-interval (* 60 60))

;; notify unread mails within 10 day (864000 sec)
;; @bug: notification is invoked twice if there are new mails
(defadvice mu4e-info-handler (after pss/growl-notification activate)
  "Notify unread mails by todochiku."
  (let
      ((newMail                        (string-to-number (replace-regexp-in-string
                                                          "![0-9]" "" (shell-command-to-string (concat (expand-file-name "./lisp/youve_got_mail" user-emacs-directory) " "
                                                                                                       (number-to-string (* 240 mu4e-update-interval))))))))
    (if (>= newMail 1)
        (growl-mail (concat (number-to-string newMail) " new mail(s)!") ""))
    )
  )

(provide 'mu4e-config)

;;; mu4e-config.el ends here
