      SUBROUTINE SSG2B (KFS,CDT,PABAR,SR1,T1,IPREC1,IA1,SR2)        
C        
      IMPLICIT INTEGER (A-Z)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
CZZ   COMMON /ZZSSB2/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /SYSTEM/ KSYSTM(55)        
      COMMON /MPYADX/ FILEA(7),FILEB(7),FILEC(7),FILED(7),NZ,T,I1,I2,   
     1                PREC,SCR2        
      EQUIVALENCE     (KSYSTM(55),KPREC1), (KSYSTM(1),SYSBUF),        
     1                (KSYSTM( 2),IOUTPT)        
      DATA    SQUARE, RECT,DIAG,SYMM,IDENT / 1,2,3,6,8 /        
C        
      PREC1 = MIN0(KPREC1,IPREC1)        
      IF (PREC1 .LE. 0) PREC1 = KPREC1        
      NZ = KORSZ(CORE)        
      DO 10 I = 1,21        
   10 FILEA(I) = 0        
      FILEA(1) = KFS        
      SCR2 = SR2        
      IF (IABS(IA1)-1) 40,20,30        
   20 I2 = IA1        
      I1 = IA1        
      GO TO 50        
   30 I2 =-1        
      I1 = 1        
      GO TO 50        
   40 I1 =-1        
      I2 = 1        
   50 CALL RDTRL (FILEA)        
      FILEB(1) = CDT        
      CALL RDTRL (FILEB)        
      IF (FILEB(1) .LE. 0) FILEB(4) = SYMM        
      FILEC(1) = PABAR        
      CALL RDTRL (FILEC)        
      IF (FILEC(1) .LE. 0) GO TO 70        
      IF (FILEC(2).EQ.FILEB(2) .OR. FILEB(1).LE.0) GO TO 80        
      WRITE (IOUTPT,60) SWM,FILEB(1),FILEB(3),FILEB(2),FILEB(3),FILEC(2)
   60 FORMAT (A27,' 2363, SSG2B FORCED MPYAD COMPATIBILITY OF MATRIX ON'
     1,       I5,8H, FROM (,I5,1H,,I5,7H), TO (,I5,1H,,I5,1H))        
      FILEB(2) = FILEC(2)        
      GO TO 80        
   70 FILEC(1) = 0        
      FILEC(4) = DIAG        
   80 FILED(4) = RECT        
      FILED(1) = SR1        
C        
C     COMPUTE TYPE OF OUTPUT        
C        
      IRC = 0        
      IF (FILEA(5).GT.2 .OR. FILEB(5).GT.2 .OR. (FILEC(5).GT.2 .AND.    
     1    FILEC(1).NE.0)) IRC = 2        
      FILED(5) = PREC1 + IRC        
      T = T1        
      PREC = PREC1        
      FILED(3) = FILEA(3)        
      IF (T .NE. 0) FILED(3) = FILEA(2)        
      IF (FILEA(1).LE.0 .OR. FILEB(1).LE.0) FILED(3) = FILEC(3)        
      CALL MPYAD (CORE,CORE,CORE)        
      IF (FILED(2).EQ.FILED(3) .AND. FILED(4).NE.SYMM) FILED(4) = SQUARE
      IF (FILED(4).EQ.SYMM .OR. FILED(4).NE.SQUARE) GO TO 100        
C        
C     IF END RESULT IS A SYMMETRIC MATRIX, MAKE SURE THE FORM IS SET TO 
C     6 (SYMM). IT COULD SAVE CPU TIME LATER AND WORTH ONE FINAL CHECK. 
C        
      K = 0        
      DO 90 I = 1,21,7        
      IF (FILEA(I) .LE. 0) GO TO 90        
      J = FILEA(I+3)        
      IF (J.EQ.DIAG .AND. I.EQ.15   ) GO TO 90        
      IF (J.NE.SYMM .AND. J.NE.IDENT) GO TO 100        
      IF (J .EQ.  SYMM) K = K + 10        
      IF (J .EQ. IDENT) K = K + 1        
   90 CONTINUE        
      IF (K .GT.  0) FILED(4) = IDENT        
      IF (K .GE. 10) FILED(4) = SYMM        
  100 CALL WRTTRL (FILED)        
      RETURN        
      END        