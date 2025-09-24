(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_CASE_NOT_FOUND (err u1002))
(define-constant ERR_CASE_NOT_ACTIVE (err u1003))
(define-constant ERR_INSUFFICIENT_FUNDS (err u1004))
(define-constant ERR_ALREADY_CONTRIBUTED (err u1005))
(define-constant ERR_CASE_ALREADY_EXISTS (err u1006))
(define-constant ERR_INVALID_AMOUNT (err u1007))
(define-constant ERR_CASE_EXPIRED (err u1008))
(define-constant ERR_WITHDRAWAL_FAILED (err u1009))

(define-data-var case-counter uint u0)

(define-map cases
  { case-id: uint }
  {
    title: (string-ascii 128),
    description: (string-ascii 512),
    target-amount: uint,
    current-amount: uint,
    creator: principal,
    beneficiary: principal,
    deadline: uint,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map contributions
  { case-id: uint, contributor: principal }
  { amount: uint, timestamp: uint }
)

(define-map case-contributors
  { case-id: uint }
  { contributors: (list 500 principal) }
)

(define-map user-contributions
  { user: principal }
  { total-contributed: uint, cases-supported: uint }
)

(define-read-only (get-case (case-id uint))
  (map-get? cases { case-id: case-id })
)

(define-read-only (get-contribution (case-id uint) (contributor principal))
  (map-get? contributions { case-id: case-id, contributor: contributor })
)

(define-read-only (get-case-contributors (case-id uint))
  (default-to { contributors: (list) } (map-get? case-contributors { case-id: case-id }))
)

(define-read-only (get-user-stats (user principal))
  (default-to { total-contributed: u0, cases-supported: u0 } (map-get? user-contributions { user: user }))
)

(define-read-only (get-case-count)
  (var-get case-counter)
)

(define-read-only (is-case-active (case-id uint))
  (match (get-case case-id)
    case-data 
      (and 
        (is-eq (get status case-data) "active")
        (< block-height (get deadline case-data))
      )
    false
  )
)

(define-read-only (calculate-funding-progress (case-id uint))
  (match (get-case case-id)
    case-data
      (let 
        (
          (current (get current-amount case-data))
          (target (get target-amount case-data))
        )
        (if (is-eq target u0)
          u0
          (/ (* current u100) target)
        )
      )
    u0
  )
)

(define-public (create-case (title (string-ascii 128)) (description (string-ascii 512)) (target-amount uint) (beneficiary principal) (duration-blocks uint))
  (let 
    (
      (case-id (+ (var-get case-counter) u1))
      (deadline (+ block-height duration-blocks))
    )
    (asserts! (> target-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> duration-blocks u0) ERR_INVALID_AMOUNT)
    
    (map-set cases
      { case-id: case-id }
      {
        title: title,
        description: description,
        target-amount: target-amount,
        current-amount: u0,
        creator: tx-sender,
        beneficiary: beneficiary,
        deadline: deadline,
        status: "active",
        created-at: block-height
      }
    )
    
    (map-set case-contributors
      { case-id: case-id }
      { contributors: (list) }
    )
    
    (var-set case-counter case-id)
    (ok case-id)
  )
)

(define-public (contribute-to-case (case-id uint) (amount uint))
  (let 
    (
      (case-data (unwrap! (get-case case-id) ERR_CASE_NOT_FOUND))
      (existing-contribution (get-contribution case-id tx-sender))
      (current-contributors (get contributors (get-case-contributors case-id)))
      (user-stats (get-user-stats tx-sender))
    )
    (asserts! (is-case-active case-id) ERR_CASE_NOT_ACTIVE)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (is-none existing-contribution) ERR_ALREADY_CONTRIBUTED)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set contributions
      { case-id: case-id, contributor: tx-sender }
      { amount: amount, timestamp: block-height }
    )
    
    (map-set cases
      { case-id: case-id }
      (merge case-data { current-amount: (+ (get current-amount case-data) amount) })
    )
    
    (map-set case-contributors
      { case-id: case-id }
      { contributors: (unwrap! (as-max-len? (append current-contributors tx-sender) u500) ERR_INVALID_AMOUNT) }
    )
    
    (map-set user-contributions
      { user: tx-sender }
      {
        total-contributed: (+ (get total-contributed user-stats) amount),
        cases-supported: (+ (get cases-supported user-stats) u1)
      }
    )
    
    (ok amount)
  )
)

(define-public (withdraw-funds (case-id uint))
  (let 
    (
      (case-data (unwrap! (get-case case-id) ERR_CASE_NOT_FOUND))
      (current-amount (get current-amount case-data))
      (beneficiary (get beneficiary case-data))
    )
    (asserts! (or (is-eq tx-sender beneficiary) (is-eq tx-sender (get creator case-data))) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status case-data) "active") ERR_CASE_NOT_ACTIVE)
    (asserts! (>= block-height (get deadline case-data)) ERR_CASE_EXPIRED)
    (asserts! (> current-amount u0) ERR_INSUFFICIENT_FUNDS)
    
    (try! (as-contract (stx-transfer? current-amount tx-sender beneficiary)))
    
    (map-set cases
      { case-id: case-id }
      (merge case-data { status: "completed", current-amount: u0 })
    )
    
    (ok current-amount)
  )
)

(define-public (close-case (case-id uint))
  (let 
    (
      (case-data (unwrap! (get-case case-id) ERR_CASE_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get creator case-data)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status case-data) "active") ERR_CASE_NOT_ACTIVE)
    
    (map-set cases
      { case-id: case-id }
      (merge case-data { status: "closed" })
    )
    
    (ok true)
  )
)

(define-public (emergency-refund (case-id uint))
  (let 
    (
      (case-data (unwrap! (get-case case-id) ERR_CASE_NOT_FOUND))
      (contribution (unwrap! (get-contribution case-id tx-sender) ERR_INSUFFICIENT_FUNDS))
      (refund-amount (get amount contribution))
    )
    (asserts! (is-eq (get status case-data) "active") ERR_CASE_NOT_ACTIVE)
    (asserts! (>= block-height (get deadline case-data)) ERR_CASE_EXPIRED)
    (asserts! (< (get current-amount case-data) (/ (get target-amount case-data) u2)) ERR_NOT_AUTHORIZED)
    
    (try! (as-contract (stx-transfer? refund-amount tx-sender tx-sender)))
    
    (map-delete contributions { case-id: case-id, contributor: tx-sender })
    
    (map-set cases
      { case-id: case-id }
      (merge case-data { current-amount: (- (get current-amount case-data) refund-amount) })
    )
    
    (ok refund-amount)
  )
)