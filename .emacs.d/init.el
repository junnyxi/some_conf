(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

(column-number-mode 1)
(show-paren-mode t)
(setq initial-scratch-message nil)
(setq inhibit-startup-screen t)

(electric-pair-mode t)
(setq-default indent-tabs-mode nil)
(setq kill-whole-line t)

(setq default-tab-width 4)

(setq inhibit-startup-message 1)
(fset 'yes-or-no-p 'y-or-n-p)
(setq make-backup-files nil)

(require 'ido)
(ido-mode 1)

;;(require 'whitespace)
;;(setq whitespace-style '(face trailing))
;;(global-whitespace-mode t)
;;

(add-hook 'post-command-hook 'fci-mode-current-column)

(load "~/.emacs.d/init-package.el")

;; ample
(load-theme 'afternoon t)

(setq-default fill-column 160)

(setq fci-rule-color "#0087ff")
(setq fci-rule-width 1)
(defun fci-mode-current-column ()
  (setq fill-column (current-column))
  (setq cursor-type '(hbar . 2))
  (fci-mode t)
)


(global-linum-mode t)

(require 'modeline-posn)
(size-indication-mode 1)

(require 'helm)

(require 'go-mode)
(require 'go-autocomplete)
(require 'auto-complete-config)
(global-set-key (kbd "C-c C-c") 'auto-complete)
(global-auto-complete-mode t)
(ac-config-default)

(require 'web-beautify) ;; Not necessary if using ELPA package
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))
(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))

(global-set-key (kbd "C-x C-[") 'enlarge-window)
(global-set-key (kbd "C-x C-]") 'enlarge-window-horizontally)

(require 'php-mode)

(autoload 'dirtree "dirtree" "add directory to tree view" t)

(require 'window-numbering)
(window-numbering-mode 1)

(require 'session)
(add-hook 'after-init-hook 'session-initialize)

(require 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(require 'sr-speedbar)
(global-set-key (kbd "C-c s") 'sr-speedbar-toggle)
(setq speedbar-show-unknown-files t)
(setq speedbar-use-images nil)
(setq sr-speedbar-right-side nil)
(setq sr-speedbar-max-width 50)

(global-set-key (kbd "C-c p s") 'helm-projectile-ack)

(require 'hl-line)
(global-hl-line-mode 1)
(set-face-background 'hl-line "#3e33333")

(add-hook 'find-file-hook 'flymake-find-file-hook)
(delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)

(require 'smooth-scrolling)
(smooth-scrolling-mode 1)

(defun my-new-line-and-indent (arg)
  (interactive "^p")
  (or arg (setq arg 1))
  (let (done)
    (while (not done)
      (let ((newpos
             (save-excursion
               (let ((goal-column 0)
                     (line-move-visual nil))
                 (and (line-move arg t)
                      (not (bobp))
                      (progn
                        (while (and (not (bobp)) (invisible-p (1- (point))))
                          (goto-char (previous-single-char-property-change
                                      (point) 'invisible)))
                        (backward-char 1)))
                 (point)))))
        (goto-char newpos)
        (if (and (> (point) newpos)
                 (eq (preceding-char) ?\n))
            (backward-char 1)
          (if (and (> (point) newpos) (not (eobp))
                   (not (eq (following-char) ?\n)))
              ;; If we skipped something intangible and now we're not
              ;; really at eol, keep going.
              (setq arg 1)
            (setq done t))))))
  (newline-and-indent))

(global-set-key (kbd "C-j") 'my-new-line-and-indent)

;; speedbar
;; (speedbar 1)
(speedbar-add-supported-extension ".go")
(add-hook
 'go-mode-hook
 '(lambda ()
    ;; gocode
    (auto-complete-mode 1)
    (setq ac-sources '(ac-source-go))
    ;; Imenu & Speedbar
    (setq imenu-generic-expression
          '(("type" "^type *\\([^ \t\n\r\f]*\\)" 1)
            ("func" "^func *\\(.*\\) {" 1)))
    (imenu-add-to-menubar "Index")
    ;; Outline mode
    (make-local-variable 'outline-regexp)
    (setq outline-regexp "//\\.\\|//[^\r\n\f][^\r\n\f]\\|pack\\|func\\|impo\\|cons\\|var.\\|type\\|\t\t*....")
    (outline-minor-mode 1)
    (local-set-key "\M-a" 'outline-previous-visible-heading)
    (local-set-key "\M-e" 'outline-next-visible-heading)
    ;; Menu bar
    (require 'easymenu)
    (defconst go-hooked-menu
      '("Go tools"
        ["Go run buffer" go t]
        ["Go reformat buffer" go-fmt-buffer t]
        ["Go check buffer" go-fix-buffer t]))
    (easy-menu-define
      go-added-menu
      (current-local-map)
      "Go tools"
      go-hooked-menu)
    ;; Other
    (setq show-trailing-whitespace t)
    ))
;; helper function
(defun go ()
  "run current buffer"
  (interactive)
  (compile (concat "go run " (buffer-file-name))))
;; helper function
(defun go-fmt-buffer ()
  "run gofmt on current buffer"
  (interactive)
  (if buffer-read-only
      (progn
        (ding)
        (message "Buffer is read only"))
    (let ((p (line-number-at-pos))
          (filename (buffer-file-name))
          (old-max-mini-window-height max-mini-window-height))
      (show-all)
      (if (get-buffer "*Go Reformat Errors*")
          (progn
            (delete-windows-on "*Go Reformat Errors*")
            (kill-buffer "*Go Reformat Errors*")))
      (setq max-mini-window-height 1)
      (if (= 0 (shell-command-on-region (point-min) (point-max) "gofmt" "*Go Reformat Output*" nil "*Go Reformat Errors*" t))
          (progn
            (erase-buffer)
            (insert-buffer-substring "*Go Reformat Output*")
            (goto-char (point-min))
            (forward-line (1- p)))
        (with-current-buffer "*Go Reformat Errors*"
          (progn
            (goto-char (point-min))
            (while (re-search-forward "<standard input>" nil t)
              (replace-match filename))
            (goto-char (point-min))
            (compilation-mode))))
      (setq max-mini-window-height old-max-mini-window-height)
      (delete-windows-on "*Go Reformat Output*")
      (kill-buffer "*Go Reformat Output*"))))
;; helper function
(defun go-fix-buffer ()
  "run gofix on current buffer"
  (interactive)
  (show-all)
  (shell-command-on-region (point-min) (point-max) "go tool fix -diff"))

(require 'gtags)

;; Enable helm-gtags-mode
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)
(add-hook 'php-mode-hook 'helm-gtags-mode)
(add-hook 'go-mode-hook 'helm-gtags-mode)

;; Set key bindings
(eval-after-load "helm-gtags"
  '(progn
     (define-key helm-gtags-mode-map (kbd "M-t") 'helm-gtags-find-tag)
     (define-key helm-gtags-mode-map (kbd "M-r") 'helm-gtags-find-rtag)
     (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
     (define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
     (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
     (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
     (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

(autoload 'svn-status "dsvn" "Run `svn status'." t)
(autoload 'svn-update "dsvn" "Run `svn update'." t)

(require 'vc-svn)
