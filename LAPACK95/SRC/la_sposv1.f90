 SUBROUTINE SPOSV1_F95( A, B, UPLO, INFO )
!
!  -- LAPACK95 interface driver routine (version 3.0) --
!     UNI-C, Denmark; Univ. of Tennessee, USA; NAG Ltd., UK
!     September, 2000
!
!   .. USE STATEMENTS ..
    USE LA_PRECISION, ONLY: WP => SP
    USE LA_AUXMOD, ONLY: ERINFO, LSAME
    USE F77_LAPACK, ONLY: POSV_F77 => LA_POSV
!   .. IMPLICIT STATEMENT ..
    IMPLICIT NONE
!   .. SCALAR ARGUMENTS ..
    CHARACTER(LEN=1), INTENT(IN), OPTIONAL :: UPLO
    INTEGER, INTENT(OUT), OPTIONAL :: INFO
!   .. ARRAY ARGUMENTS ..
    REAL(WP), INTENT(INOUT) :: A(:,:), B(:)
!   .. PARAMETERS ..
    CHARACTER(LEN=7), PARAMETER :: SRNAME = 'LA_POSV'
!   .. LOCAL SCALARS ..
    CHARACTER(LEN=1) :: LUPLO
    INTEGER :: LINFO, N
!   .. INTRINSIC FUNCTIONS ..
    INTRINSIC SIZE, PRESENT
!   .. EXECUTABLE STATEMENTS ..
    LINFO = 0; N = SIZE(A,1)
    IF( PRESENT(UPLO) )THEN; LUPLO = UPLO; ELSE; LUPLO = 'U'; END IF
!   .. TEST THE ARGUMENTS
    IF( SIZE( A, 2 ) /= N .OR. N < 0 ) THEN; LINFO = -1
    ELSE IF( SIZE( B ) /= N ) THEN; LINFO = -2
    ELSE IF( .NOT.LSAME(LUPLO,'U') .AND. .NOT.LSAME(LUPLO,'L') )THEN; LINFO = -3
    ELSE IF ( N > 0 ) THEN
       CALL POSV_F77( LUPLO, N, 1, A, N, B, N, LINFO )
    END IF
    CALL ERINFO( LINFO, SRNAME, INFO )
 END SUBROUTINE SPOSV1_F95
