
;;; Commentary:

;; This package provides embark actions for consult-gh.
;; (see URL `https://github.com/armindarvish/consult-gh' for more info).

;;; Code:

;;; Requirements
(require 'consult-gh)
(require 'embark-consult)

;;; Define Embark Action Functions
(defun consult-gh-embark-add-repo-to-known-repos (cand)
  "Add CAND repo to `consult-gh--known-repos-list'."
  (let* ((repo (get-text-property 5 :repo cand)))
    (add-to-list 'consult-gh--known-repos-list repo)))

(defun consult-gh-embark-remove-repo-from-known-repos (cand)
  "Remove CAND repo from `consult-gh--known-repos-list'."
  (let* ((repo (get-text-property 2 :repo cand)))
    (setq consult-gh--known-repos-list (delete repo consult-gh--known-repos-list))))

(defun consult-gh-embark-add-org-to-known-orgs (cand)
  "Add CAND org to `consult-gh--known-orgs-list'."
  (let* ((org (get-text-property 0 :user cand)))
    (add-to-list 'consult-gh--known-orgs-list (format "%s" org))))

(defun consult-gh-embark-remove-org-from-known-orgs (cand)
  "Remove CAND org from `consult-gh--known-orgs-list'."
  (let* ((org (get-text-property 0 :user cand)))
    (setq consult-gh--known-orgs-list (delete org consult-gh--known-orgs-list))))

(defun consult-gh-embark-add-org-to-default-list (cand)
  "Add CAND org to `consult-gh--known-orgs-list'."
  (let* ((org (get-text-property 0 :user cand)))
    (add-to-list 'consult-gh-default-orgs-list (format "%f" org))))

(defun consult-gh-embark-remove-org-from-default-list (cand)
  "Remove CAND org from `consult-gh--known-orgs-list'."
  (let* ((org (get-text-property 0 :user cand)))
    (setq consult-gh-default-orgs-list (delete org consult-gh-default-orgs-list))))

(defun consult-gh-embark-open-in-browser (cand)
  "Open CAND link in browser."
  (let* ((repo (get-text-property 0 :repo cand))
         (class (or (get-text-property 0 :class cand) nil))
         (number (or (get-text-property 0 :number cand) nil))
         (path (or (get-text-property 0 :path cand) nil)))
    (pcase class
      ("issue"
       (consult-gh--call-process "issue" "view" "--web" "--repo" (substring-no-properties repo) (substring-no-properties number)))
      ("file"
       (funcall (or consult-gh-browse-url-func #'browse-url) (concat (string-trim (consult-gh--command-to-string "browse" "--repo" repo "--no-browser")) "/blob/HEAD/" path)))
      ("pr"
       (consult-gh--call-process "pr" "view" "--repo" (substring-no-properties repo) (substring-no-properties number)))
      (_
       (consult-gh--call-process "repo" "view" "--web" (substring repo))))))


(defun consult-gh-embark-add-repo-to-known-repos (cand)
  "Add CAND repo to `consult-gh--known-repos-list'."
  (let* ((repo (get-text-property 0 :repo cand)))
    (add-to-list 'consult-gh--known-repos-list repo)))

(defun consult-gh-embark-default-action (cand)
  "Open CAND link in an Emacs buffer."
  (let* ((class (get-text-property 10 :class cand)))
    (pcase class
      ("code"
       (funcall consult-gh-code-action cand))
      ("issue"
       (funcall consult-gh-issue-action cand))
      ("pr"
       (funcall consult-gh-pr-action cand))
      ("file"
       (funcall consult-gh-file-action cand))
      ("notification"
       (funcall consult-gh-notifications-action cand))
      ("dashboard"
       (funcall consult-gh-dashboard-action cand))
      (_
       (funcall consult-gh-repo-action cand)))))


(defun consult-gh-embark-get-ssh-link (cand)
  "Copy CAND ssh link to `kill-ring'."
  (kill-new (concat "git@github.com:" (string-trim  (get-text-property 0 :repo cand))) ".git"))

(defun consult-gh-embark-get-https-link (cand)
  "Copy CAND http link to `kill-ring'."
  (kill-new (concat "https://www.github.com/" (string-trim (get-text-property 0 :repo cand)) ".git")))

(defun consult-gh-embark-get-url-link (cand)
  "Copy CAND url link to `kill-ring'.

The candidate can be a repo, issue, PR, file path, or a branch."
  (let* ((repo (get-text-property 0 :repo cand))
         (class (or (get-text-property 0 :class cand) nil))
         (number (or (get-text-property 0 :number cand) nil))
         (path (or (get-text-property 0 :path cand) nil))
         (branch (or (get-text-property 0 :branch cand) nil)))
    (pcase class
      ("issue"
       (kill-new (concat (string-trim (consult-gh--command-to-string "browse" "--repo" (string-trim repo) "--no-browser")) (format "/issues/%s" number))))
      ("file"
       (kill-new (concat (string-trim (consult-gh--command-to-string "browse" "--repo" repo "--no-browser")) (format "/blob/%s/%s" (or branch "HEAD") path))))
      ("pr"
       (kill-new (concat (string-trim (consult-gh--command-to-string "browse" "--repo" (string-trim repo) "--no-browser")) (format "/pull/%s" number))))
      (_
       (kill-new (string-trim (consult-gh--command-to-string "browse" "--repo" (string-trim repo) "--no-browser")))))))

(defun consult-gh-embark-get-org-link (cand)
  "Copy the org style link for the CAND url to `kill-ring'."
  (let* ((repo (get-text-property 0 :repo cand))
         (url  (string-trim (consult-gh--command-to-string "browse" "--repo" (string-trim repo) "--no-browser")))
         (package (car (last (split-string repo "\/")))))
    (kill-new (concat "[[" url "][" package "]]"))))

(defun consult-gh-embark-get-straight-usepackage-link (cand)
  "Copy a drop-in straight use package setup of CAND to `kill-ring'."
  (let* ((repo (get-text-property 0 :repo cand))
         (package (car (last (split-string repo "\/")))))
    (kill-new (concat "(use-package " package "\n\t:straight (" package " :type git :host github :repo \"" repo "\")\n)"))))


(defun consult-gh-embark-get-straight-usepackage-link (cand)
  "Copy a drop-in straight use package setup of CAND to `kill-ring'."
  (let* ((repo (get-text-property 0 :repo cand))
         (package (car (last (split-string repo "\/")))))))

(defun consult-gh-embark-get-other-repos-by-same-user (cand)
  "List other repos by the same user/organization as CAND at point."
  (let* ((repo (get-text-property 0 :repo cand))
         (user (car (split-string repo "\/"))))
    (consult-gh-repo-list user)))

(defun consult-gh-embark-view-issues-of-repo (cand)
  "Browse issues of CAND repo at point."
  (let ((repo (or (get-text-property 0 :repo cand))))
    (consult-gh-issue-list repo)))

(defun consult-gh-embark-view-prs-of-repo (cand)
  "Browse PRs of CAND repo at point."
  (let ((repo (or (get-text-property 0 :repo cand))))
    (consult-gh-pr-list repo)))

(defun consult-gh-embark-view-files-of-repo (cand)
  "Browse files of CAND at point."
  (let ((repo (or (get-text-property 0 :repo cand) (consult-gh--nonutf-cleanup cand))))
    (consult-gh-find-file repo)))

;;; Donec hendrerit tempor tellus.  Phasellus purus.  Curabitur vulputate vestibulum lorem.


;;; Define Embark Keymaps

(defvar-keymap consult-gh-embark-general-actions-map
  :doc "Keymap for consult-gh-embark"
  :parent embark-general-map
  "b r r" #'consult-gh-embark-add-repo-to-known-repos
  "b r k" #'consult-gh-embark-remove-repo-from-known-repos
  "b o o" #'consult-gh-embark-add-org-to-known-orgs
  "b o k" #'consult-gh-embark-remove-org-from-known-orgs
  "b o d" #'consult-gh-embark-add-org-to-default-list
  "b o D" #'consult-gh-embark-remove-org-from-default-list
  "f f" #'consult-gh-embark-view-files-of-repo
  "l h" #'consult-gh-embark-get-https-link
  "l s" #'consult-gh-embark-get-ssh-link
  "l l" #'consult-gh-embark-get-url-link
  "l O" #'consult-gh-embark-get-org-link
  "l U" #'consult-gh-embark-get-straight-usepackage-link
  "r C" #'consult-gh-embark-clone-repo
  "r F" #'consult-gh-embark-fork-repo
  "r m" #'consult-gh-embark-get-other-repos-by-same-user
  "r n" #'consult-gh-embark-view-issues-of-repo
  "r t" #'consult-gh-embark-view-prs-of-repo
  "o" #'consult-gh-embark-open-in-browser)

(defvar-keymap consult-gh-embark-orgs-actions-map
  :doc "Keymap for consult-gh-embark-orgs"
  :parent consult-gh-embark-general-actions-map)

(defvar-keymap consult-gh-embark-repos-actions-map
  :doc "Keymap for consult-gh-embark-repos"
  :parent consult-gh-embark-general-actions-map)

(defvar-keymap consult-gh-embark-files-actions-map
  :doc "Keymap for consult-gh-embark-files"
  :parent consult-gh-embark-general-actions-map
  "s" #'consult-gh-embark-save-file)

(defvar-keymap consult-gh-embark-issues-actions-map
  :doc "Keymap for consult-gh-embark-repos"
  :parent consult-gh-embark-general-actions-map)

(defvar-keymap consult-gh-embark-prs-actions-map
  :doc "Keymap for consult-gh-embark-repos"
  :parent consult-gh-embark-general-actions-map)

(defvar-keymap consult-gh-embark-codes-actions-map
  :doc "Keymap for consult-gh-embark-codes"
  :parent consult-gh-embark-general-actions-map)


(defvar-keymap consult-gh-embark-notifications-actions-map
  :doc "Keymap for consult-gh-embark-notifications"
  :parent consult-gh-embark-general-actions-map)

;;; Define consult-gh-embark minor-mode

(defun consult-gh-embark--mode-on ()
  "Enable `consult-gh-embark-mode'."
  (add-to-list 'embark-keymap-alist '(consult-gh . consult-gh-embark-general-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-orgs . consult-gh-embark-orgs-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-repos . consult-gh-embark-repos-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-files . consult-gh-embark-files-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-issues . consult-gh-embark-issues-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-prs . consult-gh-embark-prs-actions-map))
  (add-to-list 'embark-keymap-alist '(consult-gh-codes . consult-gh-embark-codes-actions-map))
  (add-to-list 'embark-default-action-overrides '(consult-gh-repos . consult-gh-embark-default-action))
  (add-to-list 'embark-default-action-overrides '(consult-gh-issues . consult-gh-embark-default-action))
  (add-to-list 'embark-default-action-overrides '(consult-gh-prs . consult-gh-embark-default-action))
  (add-to-list 'embark-default-action-overrides '(consult-gh-files . consult-gh-embark-default-action))
  (add-to-list 'embark-default-action-overrides '(consult-gh-codes . consult-gh-embark-default-action))
  (add-to-list 'embark-default-action-overrides '(consult-gh-notifications . consult-gh-embark-default-action)))
