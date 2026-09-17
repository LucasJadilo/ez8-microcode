/**
 * @file main.c
 * @brief Main source file of the EZ8 Microcode.
 * @author Lucas Jadilo
 */

/**************************************************************************************************/
/*  Private Includes                                                                              */
/**************************************************************************************************/

#include "ez8.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**************************************************************************************************/
/*  Private Macros                                                                                */
/**************************************************************************************************/

#if !defined(APP_VERSION_MAJOR) || !defined(APP_VERSION_MINOR) || !defined(APP_VERSION_PATCH)
#define APP_VERSION_MAJOR 0
#define APP_VERSION_MINOR 0
#define APP_VERSION_PATCH 0
#error Macros APP_VERSION_MAJOR, APP_VERSION_MINOR, APP_VERSION_PATCH must be defined via command line (makefile)
#endif

#define STRINGFY_(x) #x
#define STRINGFY(x)  STRINGFY_(x)

#define APP_VERSION_BASE                                                                           \
    STRINGFY(APP_VERSION_MAJOR) "." STRINGFY(APP_VERSION_MINOR) "." STRINGFY(APP_VERSION_PATCH)

#ifdef APP_VERSION_PRE
#define APP_VERSION_PRE_ "-" APP_VERSION_PRE
#else
#define APP_VERSION_PRE_ ""
#endif

#ifdef APP_VERSION_META
#define APP_VERSION_META_ "+" APP_VERSION_META
#else
#define APP_VERSION_META_ ""
#endif

#define APP_VERSION APP_VERSION_BASE APP_VERSION_PRE_ APP_VERSION_META_

#define EZ8_FONT_CYAN_BOLD "\x1B[1;36m"
#define EZ8_FONT_RESET     "\x1B[0m"

#if defined(_WIN32) || defined(_WIN64)
#define PLATFORM "Windows"
#elif defined(__linux__)
#define PLATFORM "Linux"
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM "Mac OS"
#else
#define PLATFORM "Unknown Platform"
#endif

/**************************************************************************************************/
/*  Public Function Definitions                                                                   */
/**************************************************************************************************/

int main(int argc, char *argv[])
{
    printf(EZ8_FONT_CYAN_BOLD
           "\n--------------------------------------------------------------------------------"
           "\n EZ8 Microcode %s"
           "\n--------------------------------------------------------------------------------"
           "\n\n" EZ8_FONT_RESET,
           APP_VERSION);

    if (argc > 1) {
        if (!strcmp(argv[1], "--help")) {
            char *last_slash;
            if ((NULL != (last_slash = strrchr(argv[0], '/'))) ||
                (NULL != (last_slash = strrchr(argv[0], '\\')))) {
                *last_slash = '\0';
            }

            printf("Usage: %s [OPTIONS]"
                   "\nOptions:"
                   "\n  --help      Display this help menu and exit"
                   "\n  --version   Display the complete version of this program and exit"
                   "\n",
                   (last_slash == NULL) ? argv[0] : last_slash + 1);

            return 0;
        }

        if (!strcmp(argv[1], "--version")) {
            const char date_str[] = __DATE__;
            unsigned int month_index = 0;
            const char *month_str[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

            while (strncmp(date_str, month_str[month_index], 3) && (++month_index < 12)) {}

            char time_str[] = __TIME__;
            time_str[2] = time_str[5] = '\0';

            printf("EZ8 Microcode"
                   "\nBuild v%s (%s-%02u-%02ld-%s-%s-%s) for %s"
                   "\nEZ8 Library v%s"
                   "\nCopyright (C) 2020-%s Lucas Jadilo"
                   "\nMIT License <https://spdx.org/licenses/MIT.html>"
                   "\n",
                   APP_VERSION, &date_str[7], month_index + 1, strtol(&date_str[4], NULL, 10),
                   time_str, &time_str[3], &time_str[6], PLATFORM, ez8_version, &date_str[7]);

            return 0;
        }
    }

    char *last_slash;
    if ((NULL != (last_slash = strrchr(argv[0], '/'))) ||
        (NULL != (last_slash = strrchr(argv[0], '\\')))) {
        *last_slash = '\0';
    }

    return ez8_gen_control_logic(argv[0]);
}

/****************************************** END OF FILE *******************************************/
