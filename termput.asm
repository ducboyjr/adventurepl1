**********************************************************************
* TERMPUT -                                                          *
* THE PURPOSE OF THIS MODULE IS TO SIMULATE THE I/O ROUTINES TREAD   *
* AND TWRITE USED BY THE ADVENTURE GAME.                             *
**********************************************************************
TERMPUT  CSECT
*
         ENTRY TREAD
         ENTRY TWRITE
*
**********************************************************************
*                                                                    *
* TREAD -                                                            *
*                                                                    *
* FIRST WE WILL DO A TPUT FOR THE PROMPT MESSAGE (IF IT EXISTS),     *
* THEN ASK FOR INPUT.                                                *
*                                                                    *
* TREAD (PROMPT_MESSAGE,PROMPT_LENGTH,MESSAGE_AREA,LENGTH,RTN_CODE)  *
*                                                                    *
**********************************************************************
*
TREAD    DS    0D
*        SAVE  (14,12),,TREAD
         B     10(0,15)                     BRANCH AROUND ID
         DC    AL1(5)                       ID LENGTH
         DC    CL5'TREAD'                   ID
         STM   14,12,12(13)                 SAVE REGISTERS
         USING TREAD,15
         L     12,=A(TERMPUT)
         USING TERMPUT,12
         DROP  15
*
*        LA    2,SAVEAREA
         ST    2,8(,13)
         ST    13,4(2)
         LR    13,2
*
         LR    5,1                    SAVE INPUT PARM ADDR
*
         CLI   FIRSTIME,0             CHECK FOR FIRST TIME
         BNE   NOT1READ
         MVI   FIRSTIME,255
*
*        GTSIZE ,                     GET THE TERMINAL SIZE
         SR    1,1                        PREPARE PARM
         LA    0,11                       LOAD ENTRY CODE
         SLL   0,24                       PUT ENTRY CODE IN LEFTMOST
         SVC   94                         ISSUE SVC
         LTR   0,0                        CHECK FOR CRT
         BZ    *+8
         MVI   SCREEN,255                 SET CRT FLAG
*
NOT1READ L     1,0(,5)                GET PTR TO MSG TEXT
         L     2,4(,5)                GET THE LENGTH
         L     0,0(,2)
         LTR   0,0                    NO PROMPT?
         BZ    TRE0                   SKIP TPUT IF SO
*
         BAL   8,DOTHEIO
*
TRE0     DS    0H
         L     1,8(,5)                GET ADDRESS OF INPUT
*
         LR    3,1                    SAVE BUFFER ADDRESS
         LA    0,133                  MAXIMUM LENGTH
         ICM   1,B'1000',TGETFLAG     SHOW PROPER TGET ARG
         BAL   8,DOTHEIO
*
         OC    0(133,3),BLANKS        UPPER CASE THE BUFFER
         L     2,16(,5)               SET RETURN CODE ADDR
         LA    15,1                   SET SUPER RETURN CODE
         ST    15,0(,2)               STORE IT
*
         L     2,12(,5)               GET HOW MUCH TGET READ
         ST    1,0(,2)                GIVE IT TO PL/1
*
         L     13,4(,13)
*        RETURN (14,12),RC=0
         LM    14,12,12(13)           RESTORE REGISTERS
         LA    15,0(0,0)              LOAD RETURN CODE
         BR    14                     RETURN
*
**********************************************************************
*                                                                    *
* TWRITE -                                                           *
*                                                                    *
* ISSUE A TPUT FOR THE CALLING PROGRAM                               *
*                                                                    *
* TWRITE(MESSAGE,MESSAGE_LENGTH,RETURN_CODE)                         *
*                                                                    *
**********************************************************************
*
TWRITE   DS    0D
*        SAVE  (14,12),,TWRITE
         B     12(0,15)                BRANCH AROUND ID
         DC    AL1(6)                  ID LENGTH
         DC    CL6'TWRITE'             ID
         STM   14,12,12(13)            SAVE REGISTERS
         USING TWRITE,15
         L     12,=A(TERMPUT)
         USING TERMPUT,12
         DROP  15
*
         LA    2,SAVEAREA
         ST    2,8(,13)
         ST    13,4(,2)
         LR    13,2
*
         LA    5,1                     SAVE ADDR OF INPUT 
*
         CLI   FIRSTIME,0              CHECK FOR FIRST TIME
         BNE   NOT1WRIT
         MVI   FIRSTIME,255
*
*        GTSIZE ,                      GET THE TERMINAL SIZE
         SR    1,1                         PREPARE PARM
         LA    0,11                        LOAD ENTRY CODE
         SLL   0,24                        PUT ENTRY CODE IN LEFTMOST
         SVC   94                          ISSUE SVC
         LTR   0,0                     CHECK FOR CRT
         BZ    *+8
         MVI   SCREEN,255              SET CRT FLAG
*
NOT1WRIT L     1,0(,5)                 OUTPUT TEXT ADDR
         L     2,4(,5)                 OUTPUT LENGTH
         L     0,0(,2)
*
         BAL   8,DOTHEIO
*
         LA    15,1                    SET CRAZY RETURN CODE
         L     1,8(,15)                GET CCODE ADDR
         ST    15,0(,1)                SAVE IT
*
         L     13,4(,13)
*        RETURN (14,12),RC=0
         LM    14,12,12(13)            RESTORE REGISTERS
         LA    15,0(0,0)               LOAD RETURN CODE
         BR    14                      RETURN
*
DOTHEIO  CLI   SCREEN,0                CHECK FOR CRT OUTPUT
         BNE   DOTHECRT
*
*        TPUT  (1),(0),R               THIS MAY EVEN BE A TGET
         SVC   93                      ISSUE TGET/TPUT SVC
         BR    8                       RETURN
*
DOTHECRT L     15,=V(SCRNPUT)          THE CRT INTERFACE
         LR    4,8                     RETURN ADDRESS
         BR    15                      CALL THE CRT PROCESSOR
*
SAVEAREA DC    9D'0'
*
FIRSTIME DC    X'00'
SCREEN   DC    X'00'
*
TGETFLAG DC    X'80'
BLANKS   DC    CL133' '
*
         LTORG ,
*
         END
