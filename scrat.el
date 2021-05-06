(setq skip-start-chapters '("Cover" "Title Page" "Copyright"
							"Dedication" "About The Author"
							"Foreword" "Preface" "Contents"))

(setq skip-end-chapters '("References" "Index"))

;; default do máximo que ele vai pra dentro no índice
(setq max-depth 1)

(defun get-total-pages ()
  (interactive)
  (progn (define-pdf-cache-function number-of-pages)
		 (setq number-of-pages (pdf-cache-number-of-pages))))

(defun get-outline ()
  (interactive)
  (progn (define-pdf-cache-function outline)
		 (setq outline (pdf-cache-outline))))

(defun teste (outline)
  "função que pega uma entrada do outline e retorna o nome e o número da página"
  ;; TODO checar se está de acordo com o default em depth
  (if (<= (cdr (assoc 'depth outline)) max-depth)
	  ;; check membership in chapters
	  ;; TODO tirar os end chapters e analisar só até a primeira entrada
	  (if (not (member (cdr (assoc 'title outline))
					   (append skip-start-chapters skip-end-chapters)))
		  ;; return values
		  (list (cdr (assoc 'title outline))
				(cdr (assoc 'page outline)))
		;; TODO arrumar isso daqui e pensar num jeito melhor pra ver isso
		;; acho que chegar o end chapters seria uma boa
		"fim")))

;; TODO get pages and subtract get the total per chapter
(defun get-total-per-chapter (outl acc)
  "get pages and subtract to get the total per chapter"
  (if (= 0 (length outl))
	  acc
	(get-total-per-chapter (cdr-safe outl)
						   (cons (list (car (car outl))
									   (- (if (cdr-safe outl)
											  (car (cdr (car (cdr outl)))) ;; next element page number
															number-of-pages)
										  (car (cdr (car outl))))) ;; first element page number
								 acc))))

(setq outlinedois (reverse (get-total-per-chapter outlineum '())))

;TODO: colocar um hook pra quando abrir o arquivo pdf ele pegar o tempo
(add-hook 'pdf-view-mode-hook #'set-pdf-time-before)

(defun set-pdf-time-before ()
  (setq pdf-time-before (current-time)))

(setq threshold 6)

(setq total-time 0)

(setq pdf-time-pages '())

(setq page-rate 1)

(length pdf-time-pages)

(defun pdf-check-page-advance ()
  (interactive)
  "checks if we are going forward on non-read pages"
;;  TODO vai bugar, depois preciso ver alguma solução melhor pra isso
  (add-to-list 'pdf-time-pages (1- (pdf-view-current-page))))

(defun testesss ()
  (let ((seconds-in-previous-page (time-to-seconds (time-subtract (current-time) pdf-time-before))))
	(progn (if (> seconds-in-previous-page threshold)
			   (progn (pdf-check-page-advance)
					  (setq total-time (+ total-time seconds-in-previous-page)
							page-rate (/ total-time (length pdf-time-pages)))
					  (message (format "%f total time and %f average page time" total-time page-rate))))
		   (setq pdf-time-before (current-time)))))

(add-hook 'pdf-view-after-change-page-hook #'testesss)

;; TODO uma função que checa se avançamos nas páginas

;; TODO uma outra função que estima o tempo final
;; TODO uma função que pega a última página como algo arbitrário para remover índices no final

(defun get-chapters-time (outline)
  "Function that gets the OUTLINE rate and apply it to the time."
  (list (car outline)
		(* page-rate (car (cdr outline)))))

(mapcar #'get-chapters-time outlinedois)
