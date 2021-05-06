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

;; (setq outlinedois (reverse (get-total-per-chapter outlineum '())))

;TODO: colocar um hook pra quando abrir o arquivo pdf ele pegar o tempo
(add-hook 'pdf-view-mode-hook
		  (lambda () (progn (setq pdf-time-before (current-time))
					   (setq pdf-time-after 0))))


(defun set-pdf-time-after ()
  (setq pdf-time-after (current-time)))

(defun set-pdf-time-before ()
  (setq pdf-time-before (current-time)))
;; TODO: trocar a função message por alguma outra para mandar para uma base de dados

(defun testesss ()
  (progn (set-pdf-time-after)
		 (message (number-to-string (time-to-seconds (time-subtract (current-time) pdf-time-before))))
		 ;; TODO: adicinar uma mensagem do tempo restante no capítulo ou livro
		 (set-pdf-time-before)))
;; TODO adicionar uma função para chamar isso
(add-hook 'pdf-view-after-change-page-hook
		  'testesss)

(setq pdf-time-pages '())
;; TODO uma função que checa se avançamos nas páginas
(defun pdf-check-page-advance ()
  (interactive)
  "checks if we are going forward on non-read pages"
	  (add-to-list 'pdf-time-pages (pdf-view-current-page)))

(setq page-rate 3)
;; TODO uma função que conta o tempo numa página
;; TODO uma outra função que estima o tempo final
;; TODO uma função que pega a última página como algo arbitrário para remover índices no final

(defun get-chapters-time (outline)
  "Function that gets the OUTLINE rate and apply it to the time."
  (list (car outline)
		(* page-rate (car (cdr outline)))))

;; (mapcar #'get-chapters-time outlinedois)
