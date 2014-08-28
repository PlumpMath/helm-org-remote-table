;;; helm-org-remote-table.el --- helm module for helping to refer to remote tables

;; Copyright (C) 2014 Derek Feichtinger
 
;; Author: Derek Feichtinger <derek.feichtinger@psi.ch>
;; Keywords: convenience
;; Homepage: https://github.com/dfeich/helm-org-remote-table
;; Version: 0.1.20140828

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'helm)

(defvar helm-org-remote-table-loc-cache
  (make-hash-table :test 'eql) "location lookup table")

(defvar helm-source-org-remote-table
  '((name . "Named Org Tables")
    (multiline)
    (candidates . helm-org-remote-table-search)
    (action . (("return table name " . (lambda (candidate) candidate))))
    (persistent-action . helm-org-remote-table-persistent-action)
    (persistent-help . "Show table")
    (follow . 1)
    )
  "Source definition for the `helm-org-remote-table' utility."
  )

(defun helm-org-remote-table-search ()
  "Search function producing table candidates for the
`helm-org-remote-table' utility. The search function will note
whether the invoking buffer is an Edit Formulas buffer and search
the associated source org document."
  (clrhash helm-org-remote-table-loc-cache)
  (let ((tblbuffer
	 (if (equal (buffer-name helm-current-buffer) "*Edit Formulas*")
	     (with-current-buffer helm-current-buffer
	       (marker-buffer org-pos))
	     helm-current-buffer
	   )))
    (with-current-buffer tblbuffer
      (beginning-of-buffer)
      (let ((case-fold-search nil)
	    reslst)
	(while (re-search-forward
		"^ *\\#\\+NAME: *\\(.*\\)\n\\(^ *#.*\n\\)* *|.*|"
		nil t)
	  (let ((tblname (substring-no-properties (match-string 1))))
	    (push (cons
		   (replace-regexp-in-string "  +" " " (match-string 0))
		   tblname)
		  reslst)
	    ;;(push (match-string 0) reslst)
	    (puthash tblname (match-beginning 0) helm-org-remote-table-loc-cache)
	    ))
	reslst)))
  )

(defun helm-org-remote-table-persistent-action (candidate)
  (let ((pos (gethash candidate helm-org-remote-table-loc-cache)))
    (goto-char pos)
    )
  )

;;;###autoload
(defun helm-org-remote-table ()
  "Preconfigured `helm' module helping to refer to remote tables
while writing formulas in org mode. Allows choosing the correct
table from the Org Formula Editor and inserts its name."
  (interactive)
  (let ((tblname  (helm :sources '(helm-source-org-remote-table))))
    (when tblname
      (insert tblname))))

(provide 'helm-org-remote-table)

;;; helm-org-remote-table.el ends here
