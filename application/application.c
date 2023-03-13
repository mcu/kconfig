/******************************************************************************
* SPDX-License-Identifier: GPL-3.0-or-later
******************************************************************************/

#include "kconfig.h"
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"

void blink_led_task(void *parameters)
{
  for(;;)
  {
    HAL_GPIO_TogglePin(LED_GPIO_Port, LED_Pin);

    vTaskDelay(pdMS_TO_TICKS(CONFIG_APP_BLINK_LED_DELAY));
  }

  vTaskDelete(NULL);
}

void application()
{
  BaseType_t status = xTaskCreate(blink_led_task, "LED", 256, NULL, 4, NULL);
  if(status == pdFAIL)
  {
    HAL_GPIO_WritePin(LED_GPIO_Port, LED_Pin, GPIO_PIN_SET);
  }

  vTaskStartScheduler();
}

/*****************************************************************************/
