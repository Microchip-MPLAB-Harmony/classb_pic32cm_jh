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

.thumb
.syntax unified
.global CLASSB_CPU_RegistersTest
.extern _CLASSB_UpdateTestResult

; /* Test bit patterns for R0 */
.equ CPU_TEST_PATTERN_A, 0xAA000000
.equ CPU_TEST_PATTERN_B, 0x00AA0000
.equ CPU_TEST_PATTERN_C, 0x0000AA00
.equ CPU_TEST_PATTERN_D, 0x000000AA
.equ CPU_TEST_PATTERN_E, 0x55000000
.equ CPU_TEST_PATTERN_F, 0x00550000
.equ CPU_TEST_PATTERN_G, 0x00005500
.equ CPU_TEST_PATTERN_H, 0x00000055

; /* Test bit patterns for r1 to r12 */
.equ CPU_TEST_PATTERN_I, 0xAAAAAAAA
.equ CPU_TEST_PATTERN_J, 0x55555555

; /* Test bit patterns for MSP and PSP must be multiple of 4 */
.equ CPU_TEST_PATTERN_K, 0xAAAAAAA8
.equ CPU_TEST_PATTERN_L, 0x55555558

; /* Common test bit patterns */
.equ CPU_TEST_PATTERN_APSR_A, 0xf0000000

;/* CLASSB_TEST_TYPE defined in classb_common.h */
.equ CLASSB_TEST_TYPE_SST, 0x00
.equ CLASSB_TEST_TYPE_RST, 0x01

; /* CLASSB_TEST_ID defined in classb_common.h */
.equ CLASSB_TEST_CPU, 0x00

; /* CLASSB_TEST_STATUS defined in classb_common.h */
.equ CLASSB_TEST_PASSED, 0x1
.equ CLASSB_TEST_INPROGRESS, 0x3

; /* Function Protoype
; CLASSB_TEST_STATUS CLASSB_CPU_RegistersTest(bool running_context) */

CLASSB_CPU_RegistersTest:
    push    {r14}
    push    {r4-r7}
    ; /* Copy input argument */
    mov	    r7, r0
    ; /* Call _CLASSB_UpdateTestResult after loading arguments into registers */
    ldr	    r0, =CLASSB_TEST_TYPE_SST
    cmp	    r7, #0
    beq     progress_test_type_sst
    ldr	    r0, =CLASSB_TEST_TYPE_RST
progress_test_type_sst:
    ldr	    r1, =CLASSB_TEST_CPU
    ldr	    r2, =CLASSB_TEST_INPROGRESS
    bl	    _CLASSB_UpdateTestResult
    bl	    CLASSB_CPU_GPR_Test
update_result_return:
    ; /* Code reaches here if none of the above tests are failed */
    bl	    cpu_test_passed
    ; /* Return CLASSB_TEST_PASSED */
    ldr	    r0, =CLASSB_TEST_PASSED
    pop	    {r4-r7}
    ; /* retun by POP-ing LR into PC */
    pop	    {r15}

CLASSB_CPU_GPR_Test:
    push    {r14}
    bl	    cpu_test_r0
    bl	    cpu_test_r1_r12
    bl      cpu_test_special_regs
    pop	    {r15}

cpu_test_r0:
    push    {lr}
    push    {r0}
    ; /* Immediate value for CMP operation is limited to 8-bits */
    ldr     r0, =CPU_TEST_PATTERN_A
    ; /* Shift the patten to right and compare */
    lsrs     r0, r0, #24
    cmp	    r0, #0xAA
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_B
    lsrs     r0, r0, #16
    cmp	    r0, #0xAA
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_C
    lsrs     r0, r0, #8
    cmp	    r0, #0xAA
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_D
    cmp	    r0, #0xAA
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_E
    lsrs     r0, r0, #24
    cmp	    r0, #0x55
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_F
    lsrs     r0, r0, #16
    cmp	    r0, #0x55
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_G
    lsrs     r0, r0, #8
    cmp	    r0, #0x55
    bne	    cpu_test_failed
    ldr     r0, =CPU_TEST_PATTERN_H
    cmp	    r0, #0x55
    bne	    cpu_test_failed
    pop     {r0}
    pop	    {r15}

cpu_test_passed:
    push    {lr}
    ldr	    r0, =CLASSB_TEST_TYPE_SST
    cmp	    r7, #0
    beq     pass_test_type_sst
    ldr	    r0, =CLASSB_TEST_TYPE_RST
pass_test_type_sst:
    ldr	    r1, =CLASSB_TEST_CPU
    ldr	    r2, =CLASSB_TEST_PASSED
    bl	    _CLASSB_UpdateTestResult
    pop	    {r15}

; /* Remain in infinite loop if a register test is failed */
cpu_test_failed:
    b cpu_test_failed

cpu_test_r1_r12:
    push    {lr}
    push    {r4-r7}
    ; /* Test r1 to r12 with 0xAAAAAAAA */
    ldr	    r0, =CPU_TEST_PATTERN_I
    mov	    r1, r0
    cmp	    r1, r0
    bne	    cpu_test_failed
    mov	    r2, r0
    cmp	    r2, r0
    bne	    cpu_test_failed
    mov	    r3, r0
    cmp	    r3, r0
    bne	    cpu_test_failed
    mov	    r4, r0
    cmp	    r4, r0
    bne	    cpu_test_failed
    mov	    r5, r0
    cmp	    r5, r0
    bne	    cpu_test_failed
    mov	    r6, r0
    cmp	    r6, r0
    bne	    cpu_test_failed
    mov	    r7, r0
    cmp	    r7, r0
    bne	    cpu_test_failed
    mov	    r8, r0
    cmp	    r8, r0
    bne	    cpu_test_failed
    mov	    r9, r0
    cmp	    r9, r0
    bne	    cpu_test_failed
    mov	    r10, r0
    cmp	    r10, r0
    bne	    cpu_test_failed
    mov	    r11, r0
    cmp	    r11, r0
    bne	    cpu_test_failed
    mov	    r12, r0
    cmp	    r12, r0
    bne	    cpu_test_failed
    ; /* Test r1 to r12 with 0x55555555 */
    ldr	    r0, =CPU_TEST_PATTERN_J
    mov	    r1, r0
    cmp	    r1, r0
    bne	    cpu_test_failed
    mov	    r2, r0
    cmp	    r2, r0
    bne	    cpu_test_failed
    mov	    r3, r0
    cmp	    r3, r0
    bne	    cpu_test_failed
    mov	    r4, r0
    cmp	    r4, r0
    bne	    cpu_test_failed
    mov	    r5, r0
    cmp	    r5, r0
    bne	    cpu_test_failed
    mov	    r6, r0
    cmp	    r6, r0
    bne	    cpu_test_failed
    mov	    r7, r0
    cmp	    r7, r0
    bne	    cpu_test_failed
    mov	    r8, r0
    cmp	    r8, r0
    bne	    cpu_test_failed
    mov	    r9, r0
    cmp	    r9, r0
    bne	    cpu_test_failed
    mov	    r10, r0
    cmp	    r10, r0
    bne	    cpu_test_failed
    mov	    r11, r0
    cmp	    r11, r0
    bne	    cpu_test_failed
    mov	    r12, r0
    cmp	    r12, r0
    bne	    cpu_test_failed
    ; /* Code reaches here if none of the above tests are failed */
    pop     {r4-r7}
    pop	    {r15}

    
cpu_test_sfr_failed:
    b cpu_test_failed    
    
cpu_test_special_regs:
    push    {lr}
    push    {r4-r7}
    ; /* Save MSP and test it */
    mrs	    r4, MSP
    ldr	    r5, =CPU_TEST_PATTERN_K
    msr	    MSP, r5
    mrs	    r6, MSP
    cmp	    r6, r5
    bne	    cpu_test_sfr_failed
    ldr	    r5, =CPU_TEST_PATTERN_L
    msr	    MSP, r5
    mrs	    r6, MSP
    cmp	    r6, r5
    bne	    cpu_test_sfr_failed
    ; /* Restore MSP */
    msr	    MSP, r4
    ; /* Save PSP and test it */
    mrs	    r4, PSP
    ldr	    r5, =CPU_TEST_PATTERN_K
    msr	    PSP, r5
    mrs	    r6, PSP
    cmp	    r6, r5
    bne	    cpu_test_sfr_failed
    ldr	    r5, =CPU_TEST_PATTERN_L
    msr	    PSP, r5
    mrs	    r6, PSP
    cmp	    r6, r5
    bne	    cpu_test_sfr_failed
    ; /* Restore PSP */
    msr	    PSP, r4

    ; /* Test LR */
    ldr	    r4, =CPU_TEST_PATTERN_I
    mov	    LR, r4
    cmp	    LR, r4
    bne	    cpu_test_sfr_failed
    ldr	    r4, =CPU_TEST_PATTERN_J
    mov	    LR, r4
    cmp	    LR, r4
    bne	    cpu_test_sfr_failed

    ; /* Test APSR */
    ; /* Copy the value of APSR_nzcvq and restore after test */
    mrs     r6, PSR
    ldr     r4, =CPU_TEST_PATTERN_APSR_A
    msr     APSR_nzcvq, r4
    mrs     r5, APSR
    cmp     r5, r4
    bne     cpu_test_sfr_failed
    ;/* Load zero and read it back */
    movs     r4, #0
    msr     APSR_nzcvq, r4
    mrs     r5, APSR
    cmp     r5, r4
    bne     cpu_test_sfr_failed

    ; /* Test PRIMASK */
    mrs     r6, PRIMASK
    movs    r4, #1
    msr	    PRIMASK, r4
    mrs     r5, PRIMASK
    cmp     r5, r4
    bne     cpu_test_sfr_failed
    movs     r4, #0
    msr	    PRIMASK, r4
    mrs     r5, PRIMASK
    cmp     r5, r4
    bne     cpu_test_sfr_failed
    msr     PRIMASK, r6

    ; /* Test CONTROL. Do not modify nPRIV bit */
    mrs     r6, CONTROL
    movs     r4, #0x0
    msr	    CONTROL, r4
    mrs     r5, CONTROL
    cmp     r5, r4
    bne     cpu_test_sfr_ctrl_failed
    movs    r4, #0x2
    msr	    CONTROL, r4
    mrs     r5, CONTROL
    cmp     r5, r4
    bne     cpu_test_sfr_ctrl_failed
    msr     CONTROL, r6
    pop     {r4-r7}
    pop	    {r15}

cpu_test_sfr_ctrl_failed:
    b cpu_test_failed
    