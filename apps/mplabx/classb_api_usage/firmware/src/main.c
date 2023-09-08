/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
 *******************************************************************************/

/*******************************************************************************
 * Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
 *
 * Subject to your compliance with these terms, you may use Microchip software
 * and any derivatives exclusively with Microchip products. It is your
 * responsibility to comply with third party license terms applicable to your
 * use of third party software (including open source software) that may
 * accompany Microchip software.
 *
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
 * EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
 * WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
 * PARTICULAR PURPOSE.
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
 * INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
 * WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
 * BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
 * FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
 * ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
 * THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include "definitions.h"                // SYS function prototypes

#define SRAM_START_ADDRESS      0x20000000U
#define SRAM_TEST_SIZE          (8 * 1024U) // SRAM Test size is 8k
#define FLASH_START_ADDRESS     0x0U
#define FLASH_TEST_SIZE         (16 * 1024U) // Flash Test size is 16k 

#define RX_BUFFER_SIZE          256U
#define CPU_CLOCK_FREQ          48000000U
#define CPU_CLOCK_ERROR         5U
#define CPU_CLOCK_TEST_CYCLES   164U

static uint32_t data_read [NVMCTRL_PAGE_SIZE] = {0};

char test_status_str[4][25] = {"CLASSB_TEST_NOT_EXECUTED",
    "CLASSB_TEST_PASSED",
    "CLASSB_TEST_FAILED",
    "CLASSB_TEST_INPROGRESS"
};
char console_message[] = "\r\n Type a line of characters and press the Enter key. \r\n\
 \r\n Entered line will be echoed back, and the LED0 is toggled on the reception of each character. \r\n";
char newline[] = "\r\n ";
char error_message[] = "\r\n!!!!! USART error has occurred !!!!!r\n";
char receive_buffer[RX_BUFFER_SIZE] = {};
char data = 0;

void runtimeClassBRamCallback (uint32_t status, uintptr_t context)
{
    if (status & MCRAMC_INTSTA_SERR_Msk)
    {
        __builtin_software_breakpoint();
        // The application decides what to do next.
    }
}

void runtimeClassBFlashCallback(uint32_t status, uintptr_t context)
{
    if (status & NVMCTRL_INTFLAG_SERR_Msk)
    {
        __builtin_software_breakpoint();
        // The application decides what to do next.
    }
}

/*============================================================================
void runtimeClassBChecks(void)
------------------------------------------------------------------------------
Purpose: Execute periodic run-time self-tests
Input  : None.
Output : None.
Notes  : Insert the required self-tests into this function.
============================================================================*/
bool runtimeClassBChecks(void)
{
    bool ret_val = false;
    CLASSB_TEST_STATUS classb_rst_status = CLASSB_TEST_NOT_EXECUTED;
    
    classb_rst_status = CLASSB_CPU_RegistersTest(true);
    
    if (classb_rst_status == CLASSB_TEST_PASSED)
    {
        ret_val = true;
    }
    
    return ret_val;
}

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************

int main(void) {           
    uint16_t rx_counter = 0U;
    bool rst_status = false;

    /* Initialize all modules */
    SYS_Initialize(NULL);
    
    printf("\r\n\r\n        Class B API Usage Demo      \r\n");
    CLASSB_TEST_STATUS classb_test_status = CLASSB_TEST_NOT_EXECUTED;
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_CPU);
    printf("\r\n Result of CPU SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_PC);
    printf("\r\n Result of PC SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_CLOCK);
    printf("\r\n Result of Clock SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_INTERRUPT);
    printf("\r\n Result of Interrupt SST is %s\r\n", test_status_str[classb_test_status]);

    WDT_Clear();

    printf("\r\n\r\n Class B run-time self-tests \r\n");
    classb_test_status = CLASSB_TEST_FAILED;
    classb_test_status = CLASSB_CPU_RegistersTest(true);
    printf("\r\n Result of CPU RST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_TEST_FAILED;
    classb_test_status = CLASSB_CPU_PCTest(true);
    printf("\r\n Result of PC RST is %s\r\n", test_status_str[classb_test_status]);

    // Enable SERR and DERR interrupts for RAM
    CLASSB_SRAM_EccInit (runtimeClassBRamCallback, 0);
    WDT_Clear();
    // Check RAM  for errors
    register uint32_t *pRam;
    volatile uint32_t ram_read;
    for (pRam = (uint32_t*)(SRAM_START_ADDRESS);
        pRam < (uint32_t*)(SRAM_START_ADDRESS + SRAM_TEST_SIZE) ; pRam++)
    {
        // Upon detection of single bit error, the callback function registered
        // with "CLASSB_SRAM_EccInit" function will be called by SRAM ECC Interrupt Handler
        ram_read = *pRam;
        (void) ram_read;
    }

    // Enable SERR and DERR interrupts for RAM
    CLASSB_FLASH_EccInit(runtimeClassBFlashCallback, 0);
    WDT_Clear();
    // Check Flash for errors
    uint32_t address;
    for (address=FLASH_START_ADDRESS; address<FLASH_TEST_SIZE; ){
        // Read physical value contained in Flash memory at defined address.
        // For single bit error this value is corrected on the fly as ECC feature is enabled.
        *((uint64_t*) &data_read) = *(uint64_t*) address;
        address = address + NVMCTRL_PAGE_SIZE;
    }

    WDT_Clear();
    __disable_irq();
    classb_test_status = CLASSB_ClockTest(CPU_CLOCK_FREQ, CPU_CLOCK_ERROR, CPU_CLOCK_TEST_CYCLES, true);
    __enable_irq();
    printf("\r\n Result of CPU Clock RST is %s\r\n", test_status_str[classb_test_status]);

    // Drive HIGH on the pin to be tested.
    LED_Set();

    CLASSB_IO_InputSamplingEnable(PORTC, PIN5);
    classb_test_status = CLASSB_RST_IOTest(PORTC, PIN5, PORT_PIN_HIGH);
    printf("\r\n Result of PC05 HIGH is %s\r\n", test_status_str[classb_test_status]);

    // Check HIGH on SW0 (PB19)
    classb_test_status = CLASSB_RST_IOTest(PORTB, PIN19, PORT_PIN_HIGH);
    printf("\r\n Result of PB19 HIGH is %s\r\n", test_status_str[classb_test_status]);

    printf("%s", console_message);
    while (true) {
        /* Maintain state machines of all polled MPLAB Harmony modules. */
        SYS_Tasks();
        WDT_Clear();
        /* Check if there is a received character */
        if (SERCOM4_USART_ReceiverIsReady() == true) {
            if (SERCOM4_USART_ErrorGet() == USART_ERROR_NONE) {
                SERCOM4_USART_Read(&data, 1);
                LED_Toggle();
                if ((data == '\n') || (data == '\r')) {
                    printf("\r\n Received : ");
                    SERCOM4_USART_Write(&receive_buffer[0], rx_counter);
                    printf("\r\n");
                    rx_counter = 0;
                    printf("\r\n Executing periodic run-time tests : ");
                        rst_status = runtimeClassBChecks();
                        if (rst_status == true)
                        {
                            printf(" All periodic tests passed \r\n");
                        }
                        else
                        {
                            printf(" Periodic test failure \r\n");
                        }
                } else {
                    receive_buffer[rx_counter++] = data;
                }
            } else {
                SERCOM4_USART_Write(&error_message[0], sizeof (error_message));
            }
        }
    }

    /* Execution should not come here during normal operation */

    return ( EXIT_FAILURE);
}


/*******************************************************************************
 End of File
 */

