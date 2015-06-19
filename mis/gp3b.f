      SUBROUTINE GP3B        
C        
C     GP3B BUILDS THE GRID POINT TEMPERATURE TABLE (GPTT).        
C     TEMPD AND TEMP CARDS ARE READ.        
C     THE GPTT HEADER CONTAINS THE FILE NAME PLUS 3 WORDS FOR EACH      
C     TEMPERATURE SET.        
C       WORD 1 = TEMP SET ID.        
C       WORD 2 = DEFAULT TEMP OR -1 IF NO DEFAULT TEMP.        
C       WORD 3 = RECORD NO. (AFTER HEADER RECORD) OF TEMPERATURE DATA   
C                FOR THE SET, OR        
C                ZERO IF ONLY A DEFAULT TEMP IS DEFINED FOR THE SET.    
C     DATA RECORDS OF THE GPTT CONSIST OF PAIRS OF EXTERNAL INDEX AND   
C     TEMPERATURE. EACH DATA RECORD IS SORTED ON EXTERNAL INDEX.        
C        
C     AN IDENTICAL SET OF RECORDS WITH INTERNAL INDICES IS APPENDED AT  
C     THE END OF THE GPTT.        
C        
C        
      LOGICAL         INTERN        
      INTEGER         GEOMP ,EQEXIN,SLT   ,GPTT  ,SCR1  ,BUF1  ,BUF2  , 
     1                BUF   ,TEMP  ,TEMPD ,FILE  ,FLAG  ,Z     ,RD    , 
     2                RDREW ,WRTREW,WRT   ,CLSREW,NAM(2),GEOM3 ,ETT   , 
     3                TEMPP1,TEMPP2,TEMPP3,TEMPRB,BUF3  ,TEMPG ,TEMPP4  
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / NOGRAV,NOLOAD,NOTEMP        
      COMMON /GP3COM/ GEOM3 ,EQEXIN,GEOM2 ,SLT   ,ETT   ,SCR1  ,SCR2  , 
     1                BUF1  ,BUF2  ,BUF(50)      ,CARDID(60)   ,IDNO(30)
     2,               CARDDT(60)   ,MASK(60)     ,STATUS(60)   ,NTYPES, 
     3                IPLOAD,IGRAV ,PLOAD2(2)    ,LOAD(2)      ,NOPLD2, 
     4                TEMP(2)      ,TEMPD(2)     ,TEMPP1(2)           , 
     5                TEMPP2(2)    ,TEMPP3(2)    ,TEMPRB(2)    ,BUF3  , 
     6                PLOAD3(2)    ,IPLD3        ,TEMPG(2)            , 
     7                TEMPP4(2)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
CZZ   COMMON /ZZGP3X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      EQUIVALENCE     (GEOM3,GEOMP),(GPTT,SCR1)        
      DATA    NAM   / 4HGP3B,4H    /        
C        
C     TURN NODEF FLAG ON        
C        
      ID    = 0        
      NODEF = 0        
C        
C     READ EQEXIN INTO CORE        
C        
      FILE = EQEXIN        
      CALL OPEN (*400,EQEXIN,Z(BUF2),RDREW)        
      CALL FWDREC (*410,EQEXIN)        
      CALL READ (*410,*10,EQEXIN,Z,BUF3,1,NEQX)        
      CALL MESAGE (-8,0,NAM)        
   10 CALL CLOSE (EQEXIN,CLSREW)        
      KN = NEQX/2        
      ITEMPD = NEQX + 1        
      ITABL  = ITEMPD        
C        
C     READ TEMPERATURE DEFAULT CARDS (IF PRESENT)        
C        
      FILE = GEOMP        
      CALL PRELOC (*460,Z(BUF1),GEOMP)        
      CALL LOCATE (*40,Z(BUF1),TEMPD,FLAG)        
      I = ITEMPD        
      NODEF  = 1        
      NOTEMP = 1        
   20 CALL READ (*410,*30,GEOMP,Z(I),2,0,FLAG)        
      I = I + 2        
      GO TO 20        
   30 ITABL  = I        
      NTEMPD = I - 2        
      N = ITABL - ITEMPD        
      CALL SORT (0,0,2,1,Z(ITEMPD),N)        
C        
C     READ TEMP CARDS.  DETERMINE NO. OF TEMP SETS        
C     FOR EACH SET ID, LOOK UP THE DEFAULT TEMPERATURE        
C     WRITE SET ID, DEFAULT TEMP (OR -1) AND RECORD NUMBER        
C     OF THE TEMPERATURE DATA (OR 0) IN THE GPTT HEADER        
C        
   40 J = 0        
      K = ITEMPD        
      I = ITABL        
      L = 1        
      FILE = GEOMP        
      CALL LOCATE (*270,Z(BUF1),TEMP,FLAG)        
      NOTEMP = 1        
      FILE   = GPTT        
      CALL OPEN  (*400,GPTT,Z(BUF2),WRTREW)        
      CALL FNAME (GPTT,BUF)        
      CALL WRITE (GPTT,BUF,2,0)        
C        
C     OPEN ETT AS TEMPORARY SCRATCH TO FORM IDENTICAL FILE WITH        
C     INTERNAL NOTATION        
C        
      FILE = ETT        
      CALL OPEN  (*400,ETT,Z(BUF3),WRTREW)        
      CALL FNAME (ETT,BUF)        
      CALL WRITE (ETT,BUF,2,0)        
      FILE = GEOMP        
   50 CALL READ (*410,*110,GEOMP,BUF,3,0,FLAG)        
      J = J + 1        
      IF (ID .EQ. BUF(1)) GO TO 50        
      ID = BUF(1)        
      Z(I) = J        
      I = I + 1        
      IF (NODEF .EQ.  0) GO TO 80        
   60 IF (K .GT. NTEMPD) GO TO 80        
      IF (ID-Z(K)) 80,90,70        
   70 BUF(1) = Z(K  )        
      BUF(2) = Z(K+1)        
      BUF(3) = 0        
      CALL WRITE (GPTT,BUF,3,0)        
      CALL WRITE (ETT ,BUF,3,0)        
      K = K + 2        
      GO TO 60        
   80 BUF(2) = -1        
      GO TO 100        
   90 BUF(2) = Z(K+1)        
      K = K + 2        
  100 BUF(3) = L        
      BUF(1) = ID        
      L = L + 1        
      CALL WRITE (GPTT,BUF,3,0)        
      CALL WRITE (ETT ,BUF,3,0)        
      J = 0        
      GO TO 50        
  110 IF (NODEF .EQ.  0) GO TO 130        
      IF (K .GT. NTEMPD) GO TO 130        
      BUF(3) = 0        
      DO 120 L = K,NTEMPD,2        
      BUF(1) = Z(L  )        
      BUF(2) = Z(L+1)        
      CALL WRITE (ETT ,BUF,3,0)        
  120 CALL WRITE (GPTT,BUF,3,0)        
  130 CALL WRITE (GPTT,0,0,1)        
      CALL WRITE (ETT ,0,0,1)        
      CALL BCKREC (GEOMP)        
      N = I        
      Z(N) = J + 1        
      I = ITABL + 1        
C        
C     READ EACH TEMP SET        
C     SORT ON EXTERNAL INDEX AND WRITE ON GPTT        
C        
      IFILE  = GPTT        
      INTERN = .FALSE.        
      ISAVE  = I        
      NOGO   = 0        
  140 CALL READ (*410,*420,GEOMP,0,-3,0,FLAG)        
      N1 = N + 1        
  150 J  = N1        
      NX = Z(I)        
      NI = 1        
  160 CALL READ (*410,*420,GEOMP,BUF,3,0,FLAG)        
      IF (INTERN) GO TO 300        
  170 Z(J  ) = BUF(2)        
      Z(J+1) = BUF(3)        
      J  = J + 2        
      IF (J .GE. BUF3) GO TO 430        
      NI = NI + 1        
      IF (NI .LE. NX) GO TO 160        
      NX = J - N1        
      CALL SORT (0,0,2,1,Z(N1),NX)        
C        
C     TEST FOR UNIQUENESS OF POINT AND TEMPERATURE        
C        
      KHI = J  - 1        
      KLO = N1 + 2        
      K   = J        
      IF (KLO .GE. KHI) GO TO 210        
      K   = KLO        
      DO 200 J = KLO,KHI,2        
      IF (Z(J) .NE. Z(J-2)) GO TO 190        
C        
C     NOT FATAL IF SAME TEMPERATURE        
C        
      IF (Z(J+1) .NE. Z(J-1)) NOGO = NOGO + 1        
      IF (INTERN) GO TO 200        
      CALL PAGE2 (2)        
      WRITE  (NOUT,180) UFM,Z(J-1),Z(J+1),Z(J)        
  180 FORMAT (A23,' 2100, TEMPERATURE SPECIFIED HAS ',1P,E10.3,4H AND,  
     1        1P,E10.3,' FOR GRID',I9)        
      GO TO 200        
C        
C     VALID TEMPERATURE        
C        
  190 Z(K  ) = Z(J  )        
      Z(K+1) = Z(J+1)        
      K  = K + 2        
  200 CONTINUE        
C        
  210 NX = K - N1        
      CALL WRITE (IFILE,Z(N1),NX,1)        
      I  = I + 1        
      IF (I .LE. N) GO TO 150        
C        
C     NOW DO SAME AS ABOVE WITH OUTPUT IN INTERNAL INDEX NOTATION.      
C        
      IF (NOGO .NE. 0) CALL MESAGE (-61,NOGO,0)        
      IF (INTERN) GO TO 220        
      CALL BCKREC (GEOMP)        
      INTERN = .TRUE.        
      IFILE  = ETT        
      I = ISAVE        
      GO TO 140        
C        
C     NOW APPEND ENTIRE ETT FILE TO GPTT FILE        
C        
  220 FILE = ETT        
      CALL CLOSE (ETT,CLSREW)        
      CALL OPEN  (*400,ETT,Z(BUF3),RDREW)        
  230 CALL READ  (*250,*240,ETT,Z,BUF3-1,0,FLAG)        
      CALL WRITE (GPTT,Z,BUF3-1,0)        
      GO TO 230        
  240 CALL WRITE (GPTT,Z,FLAG,1)        
      GO TO 230        
  250 CALL CLOSE (GPTT,CLSREW)        
      CALL CLOSE (ETT,CLSREW)        
  260 CALL CLOSE (GEOMP,CLSREW)        
      GO TO 460        
C        
C     NO TEMP CARDS PRESENT. IF NO DEFAULT CARDS, NO GPTT.        
C     OTHERWISE, GPTT IS COMPRISED ONLY OF DEFAULT TEMPERATURES.        
C     WRITE THE SET IDS AND DEFAULT TEMPS IN THE HEADER RECORD.        
C        
  270 IF (NODEF .EQ. 0) GO TO 260        
      FILE = GPTT        
      CALL OPEN  (*400,GPTT,Z(BUF2),WRTREW)        
      CALL FNAME (GPTT,BUF)        
      CALL WRITE (GPTT,BUF,2,0)        
      FILE = ETT        
      CALL OPEN  (*400,ETT,Z(BUF3),WRTREW)        
      CALL FNAME (ETT,BUF)        
      CALL WRITE (ETT,BUF,2,0)        
      BUF(3) =  0        
      DO 280 K = ITEMPD,NTEMPD,2        
      BUF(1) = Z(K  )        
      BUF(2) = Z(K+1)        
  280 CALL WRITE (GPTT,BUF,3,0)        
      CALL WRITE (ETT ,BUF,3,0)        
      CALL WRITE (GPTT,0,0,1)        
      CALL WRITE (ETT ,0,0,1)        
      GO TO 220        
C        
C     INTERNAL BINARY SEARCH ROUTINE.        
C        
  300 KLO = 1        
      KHI = KN        
  310 K = (KLO+KHI+1)/2        
  320 IF (BUF(2)-Z(2*K-1)) 330,390,340        
  330 KHI = K        
      GO TO 350        
  340 KLO = K        
  350 IF (KHI -KLO-1) 440,360,310        
  360 IF (K .EQ. KLO) GO TO 370        
      K = KLO        
      GO TO 380        
  370 K = KHI        
  380 KLO = KHI        
      GO TO 320        
  390 BUF(2) = Z(2*K)        
      GO TO 170        
C        
C     FATAL ERROR MESAGES        
C        
  400 J = -1        
      GO TO 450        
  410 J = -2        
      GO TO 450        
  420 J = -3        
      GO TO 450        
  430 J = -8        
      GO TO 450        
  440 CALL MESAGE (-30,9,BUF)        
  450 CALL MESAGE (J,FILE,NAM)        
C        
  460 RETURN        
      END        