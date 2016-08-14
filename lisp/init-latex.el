(require-package 'auctex)
(require-package 'cdlatex)
(require-package 'auctex-latexmk)
(auctex-latexmk-setup)
;; 93 is the decimal of "]", 46 ".", 98 "b"
(setq cdlatex-math-symbol-alist (quote ((93 ("\\Rightarrow" "\\Longrightarrow" "\\rightsquigarrow"))
                                        (46 ("\\cdot" "\\ldot"))
                                        (98 ("\\beta" "\\bm" "\\mathbb"))
                                        (99 ("\\mathcal"))
                                        )))

;; electric pairing of cdlatex can't recognize selected region
(eval-after-load 'cdlatex
  '(progn
     (define-key cdlatex-mode-map "$" nil)
     (define-key cdlatex-mode-map "(" nil)
     (define-key cdlatex-mode-map "{" nil)
     (define-key cdlatex-mode-map "[" nil)
     (define-key cdlatex-mode-map "_" nil)
     (define-key cdlatex-mode-map "^" nil)
     (define-key cdlatex-mode-map "\t" nil)
     ))

;; (defalias 'te 'TeX-engine-set)
(setq preview-default-option-list (quote ("displaymath" "floats" "graphics" "textmath" "showlabels")))
; the following must be set first
(setq preview-gs-options (quote ("-q" "-dNOPAUSE" "-DNOPLATFONTS" "-dPrinted" "-dTextAlphaBits=4" "-dGraphicsAlphaBits=4")))

;;; zotelo package for bibliography
;; (el-get 'sync 'zotelo)
;; (add-hook 'TeX-mode-hook 'zotelo-minor-mode)

(setq TeX-view-program-list
      '(("Okular"
         ("okular --unique %u"))
        ("Sumatra PDF" ("\"c:/Program files/SumatraPDF/SumatraPDF.exe\" -reuse-instance"
                        (mode-io-correlate " -forward-search %b %n ") " %o"))
        ;; ("Evince"
        ;;  ("evince %o"))
        ("Emacs"
         ("emacs %o"))
        )) ;; <<-- This is part of the quick-fix.
;; If all is in sync again, one can
;; hopefully use the regular method
;; from the next line again.
;; ("okular --unique %o" (mode-io-correlate "#src:%n%b")))))

(eval-after-load 'tex
  '(progn
     (assq-delete-all 'output-pdf TeX-view-program-selection)
     (add-to-list 'TeX-view-program-selection '(output-pdf "Sumatra PDF"))
     ;; (add-to-list 'TeX-view-program-selection '(output-pdf "Emacs"))
     ;; (add-to-list 'TeX-command-list
     ;;              '("Arara" "arara %s" TeX-run-TeX nil t :help "Run Arara."))
     (add-to-list 'TeX-command-list
                  '("Autolatex" "autolatex" TeX-run-TeX nil t :help "Run Autolatex."))
     ))

(defun my-LaTeX-setup-hook ()
  (setq TeX-auto-untabify t     ; remove all tabs before saving
                                        ; if the following is uncommented, the equation color cannot be in according with the theme, but if the tex file contain Chinese characters xetex must be set
        TeX-engine 'xetex       ; use xelatex default
                                        ;                     TeX-PDF-mode t       ; PDF mode enable, not plain
        TeX-auto-save t
        TeX-parse-self t
        TeX-debug-bad-boxes t
        TeX-debug-warnings t
        reftex-toc-split-windows-horizontally t
        ;; TeX-electric-math (cons "$" "$")
        TeX-electric-sub-and-superscript t
        preview-auto-cache-preamble t
        TeX-save-query nil
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-start-server t
        TeX-source-correlate-mode t
        TeX-show-compilation nil) ; display compilation windows
  )

(mapc (lambda (mode)
         (add-hook 'LaTeX-mode-hook mode))
        (list 'auto-fill-mode
              'TeX-fold-mode
              'turn-on-cdlatex
              ;; 'LaTeX-math-mode  ;; conflict with cdlatex
               'turn-on-reftex
               'turn-on-orgtbl
               ;; 'orgtbl-mode
               'TeX-PDF-mode
               'outline-minor-mode
               ;; 'ac-latex-mode-setup
               ;; 'my-LaTeX-hook
               'my-LaTeX-setup-hook))
(add-hook 'LaTeX-mode-hook
      '(lambda ( )
         (define-key LaTeX-mode-map (kbd "<C-M-return>") 'TeX-complete-symbol)
         (define-key LaTeX-mode-map (kbd "C-c C-g") 'pdf-sync-forward-search)
))

;(add-hook 'LaTeX-mode-hook
;      '(lambda ( )
;        (outline-minor-mode 1)
;        (define-context-key outline-minor-mode-map (kbd "C-=")
;          (when (th-outline-context-p) 'org-cycle))
;))

;(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)


;'(TeX-source-correlate-start-server t)

(provide 'init-latex)
