#lang racket

(require "src/fpcore.rkt")

(provide evaluate-main)

(define (evaluate-main argv stdin-port stdout-port)
  (define *in-file* (make-parameter "-"))
  (define *out-file* (make-parameter "-"))

  (command-line
   #:program "evaluate.rkt"
   #:argv argv
   #:once-each
   [("-i" "--in-file") in_file_ "Input file to read FPCores from"
                       (*in-file* in_file_)]
   [("-o" "--in-file") out_file_ "Output file to write evaluated results to"
                       (*out-file* out_file_)]
   ;; maybe a way to provide a context?
   ;; context override information?
   #:args args

   (define-values (input-port input-port-name)
     (if (equal? (*in-file*) "-")
         (values stdin-port "stdin")
         (values (open-input-file (*in-file*) #:mode 'text) (*in-file*))))
   (define output-port
     (if (equal? (*out-file*) "-")
         stdout-port
         (open-output-file (*out-file*) #:mode 'text #:exists 'truncate)))

   (port-count-lines! input-port)
   (let ([vals (map (compose real->double-flonum string->number) args)])
     (for ([prog (in-port (curry read-fpcore input-port-name) input-port)])
       (fprintf output-port "~a\n" (racket-run-fpcore prog vals))))))

(module+ main
  (evaluate-main (current-command-line-arguments) (current-input-port) (current-output-port)))