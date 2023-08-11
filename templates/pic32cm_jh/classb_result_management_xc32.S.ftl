;/*******************************************************************************
;  Class B Library ${REL_VER} Release
;
;  Company:
;    Microchip Technology Inc.
;
;  File Name:
;    classb_cpu_pc_test.c
;
;  Summary:
;    Class B Library source file for Program Counter test
;
;  Description:
;    This file provides general functions for the Class B library.
;
;*******************************************************************************/
;
;/*******************************************************************************
;* Copyright (C) ${REL_YEAR} Microchip Technology Inc. and its subsidiaries.
;*
;* Subject to your compliance with these terms, you may use Microchip software
;* and any derivatives exclusively with Microchip products. It is your
;* responsibility to comply with third party license terms applicable to your
;* use of third party software (including open source software) that may
;* accompany Microchip software.
;*
;* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
;* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
;* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
;* PARTICULAR PURPOSE.
;*
;* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
;* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
;* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
;* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
;* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
;* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
;* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
;*******************************************************************************/

; /* CLASSB_TEST_STATUS CLASSB_GetTestResult(CLASSB_TEST_TYPE test_type,
;       CLASSB_TEST_ID test_id) */
.global CLASSB_GetTestResult

; /* void CLASSB_ClearTestResults(CLASSB_TEST_TYPE test_type) */
.global CLASSB_ClearTestResults

; /* void _CLASSB_UpdateTestResult(CLASSB_TEST_TYPE test_type,
;       CLASSB_TEST_ID test_id, CLASSB_TEST_STATUS value) */
.global _CLASSB_UpdateTestResult

; /* SRAM address for SST results */
.equ SST_RES_ADDRESS, 0x20000000
; /* SRAM address for RST results */
.equ RST_RES_ADDRESS, 0x20000004
; /* Result mask is 0x03 (2-bit results) */
.equ RESULT_BIT_MASK, 0x03
; /* CLASSB_TEST_STATUS */
.equ CLASSB_TEST_NOT_EXECUTED, 0x0

; /* Load to clear*/
.equ REG_CLEAR_VAL, 0x00000000

CLASSB_GetTestResult:
; /* Input arguments are test_type and test_id */
; /* test_type in r0, test_id in r1 */
    ; /* push used registers */
    push    {r4-r7}
    ldr     r4, =SST_RES_ADDRESS
    cmp	    r0, #0
    beq     GetResTestTypeSST
    ldr     r4, =RST_RES_ADDRESS
GetResTestTypeSST:
    ldr	    r6, =RESULT_BIT_MASK
    ; /* Load test result into r5 */
    ldrh    r5, [r4]
    ; /* Extract the test result and return via r0 */
    mov	    r0, r5
    ror	    r0, r0, r1
    and	    r0, r0, r6
    ; /* Load 1s complement result into r7 */
    ldrh    r7, [r4, #8]
    ; /* Check whether the read results are 1s complements */
    eor	    r5, r7, r5
    asr	    r5, r1
    and	    r5, r5, r6
    cmp	    r5, #3
    beq	    TestResultValid
    ; /* Result mismatch. Return CLASSB_TEST_NOT_EXECUTED */
    ldr	    r0, =CLASSB_TEST_NOT_EXECUTED
TestResultValid:
    pop     {r4-r7}
    bx	    r14

_CLASSB_UpdateTestResult:
; /* Input arguments are test_type, test_id and value */
; /* test_type in r0, test_id in r1, value in r2 */
    ; /* push used registers */
    push    {r4-r7}
    ldr     r4, =SST_RES_ADDRESS
    cmp	    r0, #0
    beq     UpdateResTestTypeSST
    ldr     r4, =RST_RES_ADDRESS
UpdateResTestTypeSST:
    ;/* read the existing result */
    ldrh    r5, [r4]
    ldrh    r6, =RESULT_BIT_MASK
    lsl	    r6, r6, r1
    mvn	    r6, r6
    ; /* Now r6 has ((~RESULT_BIT_MASK) << test_id) */
    and	    r5, r5, r6
    mov     r7, r2
    lsl	    r7, r7, r1
    orr	    r5, r5, r7
    str	    r5, [r4]
    ; /* Load the 1s complement of the result */
    ; /* For SSTs, this address is 0x20000004 */
    ; /* For RSTs, this address is 0x20000006 */
    ; /* Take 1s complement of the value */
    mvn	    r2, r5
    str	    r2, [r4, #8]

    pop     {r4-r7}
    bx	    r14

CLASSB_ClearTestResults:
; /* Input arguments are test_type and test_id */
; /* test_type in r0 */
    ; /* push used registers */
    push    {r4-r7}
    ldr     r4, =SST_RES_ADDRESS
    cmp	    r0, #0
    beq     ClearResTestTypeSST
    ldr     r4, =RST_RES_ADDRESS
ClearResTestTypeSST:
    ldr	    r5, =REG_CLEAR_VAL
    strh    r5, [r4]
    ; /* Store 1s complement of the result */
    mvn	    r5, r5
    ; /* Add 4 to get the address of 1s complement result */
    add	    r4, #8
    strh    r5, [r4]
    pop     {r4-r7}
    bx	    r14

