(setq bbdb-file "~/BBDB/.bbdb")
(require-package 'bbdb)
(require-package 'bbdb-vcard)
(require-package 'bbdb-android)
(require 'bbdb-android)
(require-package 'bbdb-china)
(require 'bbdb-china)
;; (el-get 'sync 'bbdb)
;; (require 'bbdb-loaddefs "/usr/local/share/emacs/site-lisp/bbdb-loaddefs.el")
;; (require 'bbdb-loaddefs "~/.emacs.d/el-get/bbdb/lisp/bbdb-loaddefs.el")
(setq bbdb-file-coding-system 'utf-8)

(require 'bbdb) ;; (3)
(require 'bbdb-com)

(add-hook 'message-mode-hook
          '(lambda ()
             (flyspell-mode t)
             (bbdb-initialize 'gnus 'message)
             ))

(add-hook 'bbdb-initialize-hook
          '(lambda ()
             ;; @see http://emacs-fu.blogspot.com.au/2009/08/managing-e-mail-addresses-with-bbdb.html
             (setq
               bbdb-offer-save 1                        ;; 1 means save-without-asking
               bbdb-use-pop-up t                        ;; allow popups for addresses
               bbdb-electric-p t                        ;; be disposable with SPC
               bbdb-popup-target-lines  1               ;; very small

               bbdb-dwim-net-address-allow-redundancy t ;; always use full name
               bbdb-quiet-about-name-mismatches 2       ;; show name-mismatches 2 secs

               bbdb-always-add-address t                ;; add new addresses to existing...
               ;; ...contacts automatically
               bbdb-canonicalize-redundant-nets-p t     ;; x@foo.bar.cx => x@bar.cx

               bbdb-completion-type nil                 ;; complete on anything

               bbdb-complete-name-allow-cycling t       ;; cycle through matches
               ;; this only works partially

               bbbd-message-caching-enabled t           ;; be fast
               bbdb-use-alternate-names t               ;; use AKA
               bbdb-display-layout 'multi-line         ;; My screen is not that wide, so I need information displayed on multiple lines
               bbdb-elided-display t                    ;; single-line addresses
               ;; auto-create addresses from mail
               bbdb/mail-auto-create-p 'bbdb-ignore-some-messages-hook
               bbdb-ignore-some-messages-alist ;; don't ask about fake addresses
               ;; NOTE: there can be only one entry per header (such as To, From)
               ;; http://flex.ee.uec.ac.jp/texi/bbdb/bbdb_11.html

               '(( "From" . "no.?reply\\|DAEMON\\|daemon\\|facebookmail\\|twitter\\|notifications")))

             ;; just remove some warning since bbdb package hook the mail-mode
             (setq compose-mail-user-agent-warnings nil)
             ))
(put 'subjects 'field-separator "\n")

(defun sacha/bbdb-canonicalize-net-hook (addr)
  "Do not notice member@orkut.com or noreplyaddresses."
  (cond ((null addr) addr)
        ((string-match "member@orkut\\.com" addr) nil)
        ((string-match "noreply" addr) nil)
        ((string-match "info@evite.com" addr) nil)
        ((string-match "NO-REPLY" addr) nil)
        (t addr)))
(setq bbdb-canonicalize-net-hook 'sacha/bbdb-canonicalize-net-hook)

(setq bbdb-auto-notes-alist
      (quote (("Organization" (".*" company 0 nil))
              ("To"
               ("w3o" . "w3o")
               ("plug" . "plug")
               ("linux" . "linux")
               ("emacs-commit" . "emacs commit")
               ("emacs" . "emacs")
               ("emacs-wiki-discuss" . "planner")
               ("pinoyjug" . "pinoyjug")
               ("digitalfilipino" . "digitalfilipino")
               ("sacha" . "personal mail")
               ("handhelds" . "handhelds")
               ("debian-edu" . "debian-edu")
               ("sigcse" . "sigcse")
               ("debian" . "debian"))
              ("Cc"
               ("w3o" . "w3o")
               ("plug" . "plug")
               ("linux" . "linux")
               ("emacs-commit" . "emacs commit")
               ("emacs" . "emacs")
               ("sigcse" . "sigcse")
               ("pinoyjug" . "pinoyjug")
               ("digitalfilipino" . "digitalfilipino")
               ("sacha" . "personal mail")
               ("debian-edu" . "debian-edu")
               ("debian" . "debian")
               ("handhelds" . "handhelds"))
              ("From"
               ("admu" company "Ateneo de Manila University")
               ("orkut" . "orkut")))))

(setq bbdb-auto-notes-ignore '((("Organization" . "^Gatewayed from\\\\|^Source only")
                                ("Path" . "main\\.gmane\\.org")
                                ("From" . "NO-REPLY"))))
(setq bbdb-auto-notes-ignore '((("Organization" . "^Gatewayed from\\\\|^Source only")
                                ("Path" . "main\\.gmane\\.org")
                                ("From" . "NO-REPLY"))))
(setq bbdb-phone-style nil) ;; use free-style numbering plan
(setq bbdb-auto-notes-ignore-all nil)
(setq bbdb-check-zip-codes-p nil)
(setq bbdb-default-area-code nil)
(setq bbdb-default-country "China")
(add-hook 'bbdb-notice-hook 'bbdb-auto-notes-hook)
(setq bbdb-quiet-about-name-mismatches 0)
(setq bbdb/mail-auto-create-p 'bbdb-ignore-most-messages)
(setq bbdb/news-auto-create-p nil)
(put 'notes 'field-separator "; ")

(add-to-list 'bbdb-auto-notes-alist
             (list "x-face"
                   (list (concat "[ \t\n]*\\([^ \t\n]*\\)"
                                 "\\([ \t\n]+\\([^ \t\n]+\\)\\)?"
                                 "\\([ \t\n]+\\([^ \t\n]+\\)\\)?"
                                 "\\([ \t\n]+\\([^ \t\n]+\\)\\)?")
                         'face
                         "\\1\\3\\5\\7")))

(defun sacha/bbdb-create-factoid (title &optional text)
  "Store a factoid named TITLE with associated TEXT into my BBDB.
If PREFIX is non-nil, get TEXT from the buffer instead."
  (interactive (list (read-string "Title: ") (read-string "Text:")))
  (unless text
    (setq text (read-string "Text: ")))
  (bbdb-create-internal title "factoid" nil nil nil text))

;; Stolen from http://www.esperi.demon.co.uk/nix/xemacs/personal/dot-gnus-bbdb.html
(defadvice bbdb/gnus-update-records (around nix-bbdb-use-summary-buffer-news-auto-create-p activate preactivate)
  "Propagate the value of news-auto-create-p from the Summary buffer.
This allows it to be buffer-local there, so that we can have different values of
this variable in different simultaneously active Summary buffers."
  (let ((bbdb/news-auto-create-p
         (with-current-buffer gnus-summary-buffer
           bbdb/news-auto-create-p))
        (bbdb/mail-auto-create-p
         (with-current-buffer gnus-summary-buffer
           bbdb/mail-auto-create-p)))
     ad-do-it))

(defun sacha/bbdb-should-not-truncate ()
  "Do not truncate lines in BBDB buffers."
  (setq truncate-lines nil))
(add-hook 'bbdb-list-hook 'sacha/bbdb-should-not-truncate)

(defalias 'bbdb-vcard-export-record-insert-vcard 'sacha/bbdb-vcard-export-record-insert-vcard)
(defun sacha/bbdb-vcard-export-record-insert-vcard (record)
  "Insert a vcard formatted version of RECORD into the current buffer"
  (let ((name (bbdb-record-name record))
        (first-name (bbdb-record-firstname record))
        (last-name (bbdb-record-lastname record))
        (aka (bbdb-record-aka record))
        (company (bbdb-record-company record))
        (notes (bbdb-record-notes record))
        (phones (bbdb-record-phones record))
        (addresses (bbdb-record-addresses record))
        (blog (bbdb-record-getprop record 'blog))
        (web (bbdb-record-getprop record 'web))
        (net (bbdb-record-net record))
        (categories (bbdb-record-getprop
                     record
                     bbdb-define-all-aliases-field)))
    (insert "begin:vcard\n"
            "version:3.0\n")
    ;; Specify the formatted text corresponding to the name of the
    ;; object the vCard represents.  The property MUST be present in
    ;; the vCard object.
    (insert "fn:" (bbdb-vcard-export-escape name) "\n")
    ;; Family Name, Given Name, Additional Names, Honorific
    ;; Prefixes, and Honorific Suffixes
    (when (or last-name first-name)
      (insert "n:"
              (bbdb-vcard-export-escape last-name) ";"
              (bbdb-vcard-export-escape first-name) ";;;\n"))
    ;; Nickname of the object the vCard represents.  One or more text
    ;; values separated by a COMMA character (ASCII decimal 44).
    (when aka
      (insert "nickname:" (bbdb-vcard-export-several aka) "\n"))
    ;; FIXME: use face attribute for this one.
    ;; PHOTO;ENCODING=b;TYPE=JPEG:MIICajCCAdOgAwIBAgICBEUwDQYJKoZIhvcN
    ;; AQEEBQAwdzELMAkGA1UEBhMCVVMxLDAqBgNVBAoTI05ldHNjYXBlIENvbW11bm
    ;; ljYXRpb25zIENvcnBvcmF0aW9uMRwwGgYDVQQLExNJbmZvcm1hdGlvbiBTeXN0

    ;; FIXME: use birthday attribute if there is one.
    ;; BDAY:1996-04-15
    ;; BDAY:1953-10-15T23:10:00Z
    ;; BDAY:1987-09-27T08:30:00-06:00

    ;; A single structured text value consisting of components
    ;; separated the SEMI-COLON character (ASCII decimal 59).  But
    ;; BBDB doesn't use this.  So there's just one level:
    (when company
      (insert "org:" (bbdb-vcard-export-escape company) "\n"))
    (when blog
      (insert "URL:" blog "\n"))
    (when web
      (insert "URL:" web "\n"))
    (when notes
      (insert "note:" (bbdb-vcard-export-escape notes) "\n"))
    (dolist (phone phones)
      (insert "tel;type=" (bbdb-vcard-export-escape (bbdb-phone-location phone)) ":"
              (bbdb-vcard-export-escape (bbdb-phone-string phone)) "\n"))
    (dolist (address addresses)
      (insert (bbdb-vcard-export-address-string address) "\n"))
    (dolist (mail net)
      (insert "email;type=internet:" (bbdb-vcard-export-escape mail) "\n"))
    ;; Use CATEGORIES based on mail-alias.  One or more text values
    ;; separated by a COMMA character (ASCII decimal 44).
    (when categories
      (insert "categories:"
              (bbdb-join (mapcar 'bbdb-vcard-export-escape
                                 (bbdb-split categories ",")) ",") "\n"))
    (insert "end:vcard\n")))

(defun sacha/bbdb-records-postal ()
  (sort
   (delq nil
         (mapcar
          (lambda (item)
            (and (car (bbdb-record-addresses item)) item))
          (bbdb-records)))
   (lambda (a b)
     (string< (bbdb-address-country (car (bbdb-record-addresses a)))
              (bbdb-address-country (car (bbdb-record-addresses b)))))))

;(setq sacha/contact-list (sacha/bbdb-records-postal))

;  (bbdb-display-records sacha/contact-list)

(defun sacha/bbdb-ping ()
  (interactive)
  (cond
   ((eq major-mode 'bbdb-mode) (call-interactively 'sacha/bbdb-ping-bbdb-record))
   ((eq major-mode 'gnus-article-mode) (call-interactively 'sacha/bbdb-gnus-ping))
   ((eq major-mode 'message-mode) (call-interactively 'sacha/bbdb-gnus-ping))))
(global-set-key "\C-c\C-p" 'sacha/bbdb-ping)

(defun sacha/bbdb-ping-bbdb-record (bbdb-record text &optional date regrind)
  "Adds a note for today to the current BBDB record.
Call with a prefix to specify date."
  (interactive (list (bbdb-current-record t)
                     (read-string "Notes: ")
                     (if current-prefix-arg (planner-read-date) (planner-today))
                     t))
  (bbdb-record-putprop bbdb-record
                       'contact
                       (concat date ": " text "\n"
                               (or (bbdb-record-getprop bbdb-record 'contact))))
  (if regrind
      (save-excursion
        (set-buffer bbdb-buffer-name)
        (bbdb-redisplay-one-record bbdb-record)))
  nil)

(defun sacha/bbdb-gnus-ping (text)
  "Add a ping for authors/recipients of this message.
Call with a prefix to specify a manual note."
  (interactive (list (if current-prefix-arg (read-string "Notes: "))))
  (let* ((from-me-p
          (string-match gnus-ignored-from-addresses
                        (message-fetch-field "From")))
         (bbdb-get-only-first-address-p nil)
         (bbdb-get-addresses-headers
          (list (assoc (if from-me-p 'recipients 'authors) bbdb-get-addresses-headers)))
         (bbdb/gnus-update-records-mode 'annotating)
         (bbdb-message-cache nil)
         (bbdb-user-mail-names nil)
         (gnus-ignored-from-addresses nil)
         records)
    (setq records (bbdb/gnus-update-records t))
    (if records
        (bbdb-display-records records)
      (bbdb-undisplay-records))
    (while records
      (sacha/bbdb-ping-bbdb-record
       (car records)
       (concat
        (if from-me-p "-> " "<- ")
        (or text (message-fetch-field "Subject")))
       (planner-date-to-filename
        (date-to-time (message-fetch-field "Date"))))
      (setq records (cdr records)))
    (setq records (bbdb/gnus-update-records t))
    (if records
        (bbdb-display-records records)
      (bbdb-undisplay-records))))


;; import Gmail contacts in vcard format into bbdb
(autoload 'bbdb-vcard-import-file "bbdb-vcard" nil t)


;; email address chooser
(require-package 'bbdb-handy)
(require 'bbdb-handy)
(bbdb-handy-enable)

(provide 'init-bbdb)
