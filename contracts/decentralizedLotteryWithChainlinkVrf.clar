;; Define a map to store participants by index
(define-map participants
  {index: uint}
  {user: principal})

;; Global state variables
(define-data-var ticket-count uint u0)
(define-data-var winner (optional principal) none)

;; Error constants
(define-constant err-no-participants (err u100))
(define-constant err-not-admin (err u101))

;; Replace with your actual admin address
(define-constant admin 'ST2S0E3KV3ED7HZQFD4B1EBHWSB6FC5ZK7PYWABQE)

;; Users can enter the lottery by sending 10 STX
(define-public (enter-lottery)
  (begin
    (try! (stx-transfer? u10 tx-sender (as-contract tx-sender)))
    (map-set participants {index: (var-get ticket-count)} {user: tx-sender})
    (var-set ticket-count (+ (var-get ticket-count) u1))
    (ok true)))

;; Admin submits a random number to pick a winner
(define-public (submit-random (random uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-not-admin)
    (asserts! (> (var-get ticket-count) u0) err-no-participants)
    (let (
          (winner-index (mod random (var-get ticket-count)))
          (entry (map-get? participants {index: winner-index}))
         )
      (match entry winner-data
        (begin
          (var-set winner (some (get user winner-data)))
          (ok (get user winner-data)))
        (err u100))))) ;; Direct use of error expression

;; Read-only function to check the current winner
(define-read-only (get-winner)
  (ok (var-get winner)))
