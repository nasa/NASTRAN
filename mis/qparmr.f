      SUBROUTINE QPARMR        
C        
C     MODULE PARAMR PERFORMS THE FOLLOW OP ON PARAMETERS IN SINGLE      
C     PRECISION        
C     (COMPANION MODULE PARAMD AND SUBROUTINE QPARMD)        
C        
C     DMAP        
C     PARAMR  / /C,N,OP/ V,N,OUTR/V,N,IN1R/V,N,IN2R/        
C                        V,N,OUTC/V,N,IN1C/V,N,IN2C/V,N,FLAG $        
C        
C         OP        COMPUTE        
C         --        -------------------------------------------        
C      BY DEFAULT   FLAG = 0        
C      1  ADD       OUTR = IN1R + IN2R        
C      2  SUB       OUTR = IN1R - IN2R        
C      3  MPY       OUTR = IN1R * IN2R        
C      4  DIV       OUTR = IN1R / IN2R (IF IN2R = 0, FLAG IS SET TO +1) 
C      5  NOP       RETURN        
C      6  SQRT      OUTR = SQRT(IN1R)        
C      7  SIN       OUTR = SIN(IN1R) WHERE IN1R IS IN RADIANS        
C      8  COS       OUTR = COS(IN1R) WHERE IN1R IS IN RADIANS        
C      9  ABS       OUTR = ABS(IN1R)        
C     10  EXP       OUTR = EXP(IN1R)        
C     11  TAN       OUTR = TAN(IN1R) WHERE IN1R IS IN RADIANS        
C     12  ADDC      OUTC = IN1C + IN2C        
C     13  SUBC      OUTC = IN1C - IN2C        
C     14  MPYC      OUTC = IN1C * IN2C        
C     15  DIVC      OUTC = IN1C / IN2C (IF IN2C = 0, FLAG IS SET TO +1) 
C     16  COMPLEX   OUTC = (IN1R,IN2R)        
C     17  CSQRT     OUTC = CSQRT(IN1C)        
C     18  NORM      OUTR = SQRT(OUTC(1)**2 + OUTC(2)**2)        
C     19  REAL      IN1R = OUTC(1),   IN2R = OUTC(2)        
C     20  POWER     OUTR = IN1R**IN2R        
C     21  CONJ      OUTC = CONJG(IN1C)        
C     22  EQ        FLAG =-1 IF IN1R COMPARES WITH IN2R        
C     23  GT        FLAG =-1 IF IN1R IS GT IN2R        
C     24  GE        FLAG =-1 IF IN1R IS GE IN2R        
C     25  LT        FLAG =-1 IF IN1R IS LT IN2R        
C     26  LE        FLAG =-1 IF IN1R IS LE IN2R        
C     27  NE        FLAG =-1 IF IN1R IS NE IN2R        
C     28  LOG       OUTR = ALOG10(IN1R)        
C     29  LN        OUTR = ALOG(IN1R)        
C     30  FIX       FLAG = OUTR        
C     31  FLOAT     OUTR = FLOAT(FLAG)        
C        
C     NEW OP CODE ADDED IN THIS NEW VERSION, 12/1988 -        
C        
C     32  ERR       IF FLAG IS 0, SYSTEM NOGO FLAG IS SET TO ZERO       
C                   IF FLAG IS NON-ZERO, JOB TERMINATED IF ANY PREVIOUS 
C                      PARAMR (OR PARAMD) CONTAINS NON-FATAL ERROR(S)   
C        
      LOGICAL          PRT        
      INTEGER          OP,OPCODE(50),FLAG,IVPS(1),NAME(2),IL(8),ILX(8), 
     1                 NAM(2),BLNK        
      REAL             IN1R,IN2R,IN1C,IN2C        
      CHARACTER        UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /BLANK /  OP(2),OUTR,IN1R,IN2R,OUTC(2),IN1C(2),IN2C(2),FLAG
      COMMON /XVPS  /  VPS(1)        
      COMMON /ILXXR /  IL1,IL2,IL3,IL4,IL5,IL6,IL7,IL8        
      COMMON /SYSTEM/  IBUF,NOUT,NOGO,DUMMY(33),KSYS37        
      EQUIVALENCE      (VPS(1),IVPS(1)), (IL,IL1)        
      DATA NAME     /  4HQPAR,4HMR  /      ,IFIRST / 15  /        
      DATA OPCODE   /  4HADD ,4HSUB ,4HMPY ,4HDIV ,4HNOP ,        
     1                 4HSQRT,4HSIN ,4HCOS ,4HABS ,4HEXP ,        
     2                 4HTAN ,4HADDC,4HSUBC,4HMPYC,4HDIVC,        
     3                 4HCOMP,4HCSQR,4HNORM,4HREAL,4HPOWE,        
     4                 4HCONJ,4HEQ  ,4HGT  ,4HGE  ,4HLT  ,        
     5                 4HLE  ,4HNE  ,4HLOG ,4HLN  ,4HFIX ,        
     6                 4HFLOA,4HERR ,4H    ,4H    ,4H    ,        
     7                 4H    ,4H    ,4H    ,4H    ,4H    ,        
     8                 4H    ,4H    ,4H    ,4H    ,4H    ,        
     9                 4H    ,4H    ,4H    ,4H    ,4H    /        
      DATA ILX      /  4H1ST ,4H2ND ,4H3RD ,4H4TH ,4H5TH ,        
     1                 4H6TH ,4H7TH ,4H8TH               /        
      DATA PARM,NAM /  4HPARM,4H/PAR,3HAMR/,BLNK  /4H    /        
C        
C     SUPPRESSED ALL INPUT/OUTPUT CHECK MESSAGES IF DIAG 37 IS ON       
C        
      CALL SSWTCH (37,I)        
      PRT = I .EQ. 0        
      IF (PRT) NAM(1) = BLNK        
      IF (PRT) NAM(2) = BLNK        
C        
C     COMPUTE VPS INDEXES AND PARAMETER NAMES        
C        
      DO 2 I = 2,8        
      CALL FNDPAR (-I,IL(I))        
    2 CONTINUE        
      IF (.NOT.PRT) GO TO 4        
      CALL PAGE2 (IFIRST)        
      IFIRST = 6        
      WRITE  (NOUT,3) UIM,OP        
    3 FORMAT (A29,' FROM PARAMR MODULE - OP CODE = ',2A4, /5X,        
     1        '(ALL PARAMR MESSAGES CAN BE SUPPRESED BY DIAG 37)')      
C        
C     BRANCH ON OPERATION CODE        
C        
    4 IFLAG = FLAG        
      FLAG  = 0        
      IERR  = 0        
C        
      DO 5 IOP = 1,32        
      IF (OP(1) .EQ. OPCODE(IOP)) GO TO        
     1   (  10,  20,  30,  40,  50,  60,  70,  80,  90, 100,        
     2     110, 120, 130, 140, 150, 160, 170, 180, 190, 200,        
     3     210, 220, 230, 240, 250, 260, 270, 280, 290, 300,        
     4     310, 320    ), IOP        
    5 CONTINUE        
      WRITE  (NOUT,6) OP(1),NAM        
    6 FORMAT (22X,'UNRECOGNIZABLE OP CODE = ',A4,'  (INPUT ERROR) ',2A4)
      CALL MESAGE (-7,0,NAME)        
C        
C *******        
C     REAL NUMBER FUNCTIONS        
C *******        
C        
C     ADD        
C        
   10 OUTR = IN1R + IN2R        
      GO TO 600        
C        
C     SUBTRACT        
C        
   20 OUTR = IN1R - IN2R        
      GO TO 600        
C        
C     MULTIPLY        
C        
   30 OUTR = IN1R*IN2R        
      GO TO 600        
C        
C     DIVIDE        
C        
   40 OUTR = 0.0        
      IF (IN2R .EQ. 0.D0) GO TO 45        
      OUTR = IN1R/IN2R        
      GO TO 600        
   45 WRITE  (NOUT,47) NAM        
   47 FORMAT (5X,'ERROR - DIVIDED BY ZERO  ',2A4)        
      IERR = 1        
      FLAG =+1        
      IF (IL8 .LE. 0) GO TO 730        
      IVPS(IL8) = FLAG        
      I = IL8 - 3        
      WRITE  (NOUT,48) IVPS(I),IVPS(I+1),FLAG,NAM        
   48 FORMAT (22X,2A4,2H =,I10,'   (OUTPUT)  ',2A4)        
      GO TO 730        
C        
C     NOP        
C        
   50 RETURN        
C        
C     SQUARE ROOT        
C        
   60 IF (IN1R .LT. 0.0) GO TO 65        
      OUTR = SQRT(IN1R)        
      GO TO 650        
   65 WRITE  (NOUT,67) NAM        
   67 FORMAT (5X,'ERROR - OPERATING ON A NEGATIVE NUMBER  ',2A4)        
      OUTR = 0.0        
      IERR = 1        
      GO TO 650        
C        
C     SINE        
C        
   70 OUTR = SIN(IN1R)        
      GO TO 650        
C        
C     COSINE        
C        
   80 OUTR = COS(IN1R)        
      GO TO 650        
C        
C     ABSOLUTE VALUE        
C        
   90 OUTR = ABS(IN1R)        
      GO TO 650        
C        
C     EXPONENTIAL        
C        
  100 OUTR = EXP(IN1R)        
      GO TO 650        
C        
C     TANGENT        
C        
  110 OUTR = TAN(IN1R)        
      GO TO 650        
C        
C     NORM        
C        
  180 OUTR = SQRT(OUTC(1)**2 + OUTC(2)**2)        
      GO TO 690        
C        
C     POWER        
C        
  200 OUTR  = IN1R**IN2R        
      GO TO 600        
C        
C     LOG        
C        
  280 IF (IN1R .LT. 0.0) GO TO 65        
      OUTR = ALOG10(IN1R)        
      GO TO 650        
C        
C     NATURAL LOG        
C        
  290 IF (IN1R .LT. 0.0) GO TO 65        
      OUTR = ALOG(IN1R)        
      GO TO 650        
C        
C     FLOAT        
C        
  310 OUTR = IFLAG        
      GO TO 670        
C        
C     ERR        
C        
  320 IF (IFLAG.NE.0 .AND. KSYS37.NE.0) GO TO 970        
      KSYS37 = 0        
      NOGO   = 0        
      IF (PRT) WRITE (NOUT,325)        
  325 FORMAT (5X,'SYSTEM NOGO FLAG IS RESET TO INTEGER ZERO',/)        
      GO TO 990        
C        
C *******        
C     COMPLEX FUNCTIONS        
C *******        
C        
C     ADD COMPLEX        
C        
  120 OUTC(1) = IN1C(1) + IN2C(1)        
      OUTC(2) = IN1C(2) + IN2C(2)        
      GO TO 730        
C        
C     SUBTRACT COMPLEX        
C        
  130 OUTC(1) = IN1C(1) - IN2C(1)        
      OUTC(2) = IN1C(2) - IN2C(2)        
      GO TO 730        
C        
C     MULTIPLY COMPLEX        
C        
  140 OUTC(1) = IN1C(1)*IN2C(1) - IN1C(2)*IN2C(2)        
      OUTC(2) = IN1C(1)*IN2C(2) + IN1C(2)*IN2C(1)        
      GO TO 730        
C        
C     DIVIDE COMPLEX        
C        
  150 DENOM = IN2C(1)**2 + IN2C(2)**2        
      IF (DENOM .EQ. 0.0) GO TO 155        
      OUTC(1) = (IN1C(1)*IN2C(1) + IN1C(2)*IN2C(2))/DENOM        
      OUTC(2) = (IN1C(2)*IN2C(1) - IN1C(1)*IN2C(2))/DENOM        
      GO TO 730        
  155 OUTC(1) = 0.0        
      OUTC(2) = 0.0        
      GO TO 45        
C        
C     COMPLEX        
C        
  160 OUTC(1) = IN1R        
      OUTC(2) = IN2R        
      GO TO 710        
C        
C     COMPLEX SQUARE ROOT        
C        
  170 OUTC(1) = (IN1C(1)**2 + IN1C(2)**2)**0.25        
     1          *COS(0.5*ATAN2(IN1C(2),IN1C(1)))        
      OUTC(2) = (IN1C(1)**2 + IN1C(2)**2)**0.25        
     1          *SIN(0.5*ATAN2(IN1C(2),IN1C(1)))        
      GO TO 760        
C        
C     CONJUGATE        
C        
  210 OUTC(1) = IN1C(1)        
      OUTC(2) =-IN1C(2)        
      GO TO 760        
C        
C     REAL        
C        
  190 IN1R = OUTC(1)        
      IN2R = OUTC(2)        
      GO TO 770        
C        
C     EQUAL        
C        
  220 IF (IN1R .EQ. IN2R) FLAG = -1        
      GO TO 660        
C        
C     GREATER THAN        
C        
  230 IF (IN1R .GT. IN2R) FLAG = -1        
      GO TO 660        
C        
C     GREATER THAN OR EQUAL        
C        
  240 IF (IN1R .GE. IN2R) FLAG = -1        
      GO TO 660        
C        
C     LESS THAN        
C        
  250 IF (IN1R .LT. IN2R) FLAG = -1        
      GO TO 660        
C        
C     LESS THAN OR EQUAL        
C        
  260 IF (IN1R .LE. IN2R) FLAG = -1        
      GO TO 660        
C        
C     NOT EQUAL        
C        
  270 IF (IN1R .NE. IN2R) FLAG = -1        
      GO TO 660        
C        
C     FIX        
C        
  300 FLAG = OUTR        
      GO TO 720        
C        
C ---------------------------------------------------        
C        
C     INPUT PARAMETER ECHO        
C        
  600 ASSIGN 620 TO IRTN3        
      ASSIGN 800 TO IRTN4        
  610 IF (.NOT.PRT) GO TO 615        
      I = IL3 - 3        
      IF (IL3 .LE. 0) WRITE (NOUT,640) ILX(3),PARM,IN1R        
      IF (IL3 .GT. 0) WRITE (NOUT,640) IVPS(I),IVPS(I+1),IN1R        
  615 IF (IL3 .EQ. 0) IERR = 1        
      GO TO IRTN3, (620,800)        
  620 IF (.NOT.PRT) GO TO 645        
      J = IL4 - 3        
      IF (IL4 .LE. 0) WRITE (NOUT,640) ILX(4),PARM,IN2R        
      IF (IL4 .GT. 0) WRITE (NOUT,640) IVPS(J),IVPS(J+1),IN2R        
  640 FORMAT (22X,2A4,3H = ,E13.6,'  (INPUT)')        
  645 IF (IL4 .EQ. 0) IERR = 1        
      GO TO IRTN4, (800,880,910)        
C        
  650 ASSIGN 800 TO IRTN3        
      GO TO 610        
C        
  660 ASSIGN 620 TO IRTN3        
      ASSIGN 910 TO IRTN4        
      GO TO 610        
C        
  670 IF (.NOT.PRT) GO TO 685        
      I = IL8 - 3        
      IF (IL8 .LE. 0) WRITE (NOUT,680) ILX(8),PARM,IFLAG        
      IF (IL8 .GT. 0) WRITE (NOUT,680) IVPS(I),IVPS(I+1),IFLAG        
  680 FORMAT (22X,2A4,2H =,I10,'   (INPUT)')        
  685 IF (IL8 .EQ. 0) IERR = 1        
      GO TO 800        
C        
  690 IF (.NOT.PRT) GO TO 705        
      I = IL5 - 3        
      IF (IL5 .LE. 0) WRITE (NOUT,700) ILX(5),PARM,OUTC        
      IF (IL5 .GT. 0) WRITE (NOUT,700) IVPS(I),IVPS(I+1),OUTC        
  700 FORMAT (22X,2A4,4H = (,E13.6,1H,,E13.6,')   (INPUT)')        
  705 IF (IL5 .EQ. 0) IERR = 1        
      GO TO 800        
C        
  710 ASSIGN 620 TO IRTN3        
      ASSIGN 880 TO IRTN4        
      GO TO 610        
C        
  720 IF (.NOT.PRT) GO TO 725        
      I = IL2 - 3        
      IF (IL2 .LE. 0) WRITE (NOUT,640) ILX(2),PARM,OUTR        
      IF (IL2 .GT. 0) WRITE (NOUT,640) IVPS(I),IVPS(I+1),OUTR        
  725 IF (IL2 .EQ. 0) IERR = 1        
      GO TO 910        
C        
  730 ASSIGN 750 TO IRTN6        
  740 IF (.NOT.PRT) GO TO 745        
      I = IL6 - 3        
      IF (IL6 .LE. 0) WRITE (NOUT,700) ILX(6),PARM,IN1C        
      IF (IL6 .GT. 0) WRITE (NOUT,700) IVPS(I),IVPS(I+1),IN1C        
  745 IF (IL6 .EQ. 0) IERR = 1        
      GO TO IRTN6, (750,880)        
  750 IF (.NOT.PRT) GO TO 755        
      J = IL7 - 3        
      IF (IL7 .LE. 0) WRITE (NOUT,700) ILX(7),PARM,IN2C        
      IF (IL7 .GT. 0) WRITE (NOUT,700) IVPS(J),IVPS(J+1),IN2C        
  755 IF (IL7 .EQ. 0) IERR = 1        
      GO TO 880        
C        
  760 ASSIGN 880 TO IRTN6        
      GO TO 740        
C        
  770 IF (.NOT.PRT) GO TO 775        
      I = IL5 - 3        
      IF (IL5 .LE. 0) WRITE (NOUT,700) ILX(5),PARM,OUTC        
      IF (IL5 .GT. 0) WRITE (NOUT,700) IVPS(I),IVPS(I+1),OUTC        
  775 IF (IL5 .EQ. 0) IERR = 1        
      GO TO 840        
C        
C     OUTPUT PARAMETER CHECK        
C        
C     SECOND PARAMETER - OUTR        
C        
  800 IF (IL2 .GT. 0) GO TO 820        
      WRITE  (NOUT,810) ILX(2),NAM        
  810 FORMAT (22X,A4,'PARAMETER IS MISSING  (OUTPUT ERROR)  ',2A4)      
      IERR = 1        
      GO TO 950        
  820 IF (IERR .EQ. 0) VPS(IL2) = OUTR        
      I = IL2 - 3        
      IF (PRT) WRITE (NOUT,830) IVPS(I),IVPS(I+1),VPS(IL2)        
  830 FORMAT (22X,2A4,3H = ,E13.6,'  (OUTPUT)')        
      GO TO 950        
C        
C     THIRD AND FOURTH PARAMETERS - INR1, INR2        
C        
  840 IF (IL3 .GT. 0) GO TO 850        
      WRITE (NOUT,810) ILX(3),NAM        
      IERR = 1        
      GO TO 860        
  850 IF (IERR .EQ. 0) VPS(IL3) = IN1R        
      I = IL3 - 3        
      IF (PRT) WRITE (NOUT,830) IVPS(I),IVPS(I+1),VPS(IL3)        
  860 IF (IL4 .GT. 0) GO TO 870        
      WRITE (NOUT,810) ILX(4),NAM        
      IERR = 1        
      GO TO 950        
  870 IF (IERR .EQ. 0) VPS(IL4) = IN2R        
      J = IL4 - 3        
      IF (PRT) WRITE (NOUT,830) IVPS(J),IVPS(J+1),VPS(IL4)        
      GO TO 950        
C        
C     FIFTH PARAMETER - OUTC        
C        
  880 IF (IL5 .GT. 0) GO TO 890        
      WRITE (NOUT,810) ILX(5),NAM        
      IERR = 1        
      GO TO 950        
  890 IF (IERR .EQ. 1) GO TO 895        
      VPS(IL5  ) = OUTC(1)        
      VPS(IL5+1) = OUTC(2)        
  895 I = IL5 - 3        
      IF (PRT) WRITE (NOUT,900) IVPS(I),IVPS(I+1),VPS(IL5),VPS(IL5+1)   
  900 FORMAT (22X,2A4,4H = (,E13.6,1H,,E13.6,')   (OUTPUT)')        
      GO TO 950        
C        
C     EIGHTH PARAMETER - FLAG        
C        
  910 IF (IL8 .GT.  0) GO TO 920        
      WRITE (NOUT,810) ILX(8),NAM        
      IERR = 1        
      GO TO 950        
  920 IF (IERR .EQ. 0) IVPS(IL8) = FLAG        
      I = IL8 - 3        
      IF (PRT) WRITE (NOUT,930) IVPS(I),IVPS(I+1),IVPS(IL8)        
  930 FORMAT (22X,2A4,2H =,I10,6X,'(OUTPUT)')        
C        
  950 IF (IERR  .EQ. 0) GO TO 990        
      WRITE  (NOUT,960) UWM,NAM        
  960 FORMAT (A25,' - I/O ERROR, OUTPUT NOT SAVED. OUTPUT DEFAULT ',    
     1       'VALUE REMAINS ',2A4,/)        
      GO TO 990        
  970 WRITE  (NOUT,980)        
  980 FORMAT (5X,'JOB TERMINATED DUE TO PREVIOUS ERROR(S)',/)        
      CALL PEXIT        
  990 IF (KSYS37 .EQ. 0) KSYS37 = IERR        
      RETURN        
C        
      END        