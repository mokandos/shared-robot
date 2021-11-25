*** Settings ***
Documentation       Ключевые слова для Suite
Library             RPA.HTTP
Library             String
Library             Collections
Library             RPA.FileSystem
Library             OperatingSystem
Resource            auth.robot

*** Variables ***
${RED}       "\\033[91m"
${YELLOW}    "\\033[93m"
${BLUE}      "\\033[94m"
${PURPLE}    "\\033[95m"
${DEF}       "\\033[0m"

*** Keywords ***
:>>Suite Setup
    ${purple}=      Evaluate  ${PURPLE}
    ${def}=         Evaluate  ${DEF}
    Log To Console      \n${purple}Старт тестов: ${SUITE DOCUMENTATION}${def}\n


:>>Suite Teardown
    #Переносим логи из корня
    ${is_not_output}=   Evaluate   "output" not in """${OUTPUT DIR}"""
    
    #Если логирование не идет в каталог output
    IF    ${is_not_output}
        
        ${dir_not_exist}=       Does Directory Not Exist    ./output
        
        # Создаем каталог output если он не существует
        IF    ${dir_not_exist}     
            Create Directory    ./output    exist_ok=true
        END

        ${output_exist}=     Does File Exist    ${OUTPUT FILE}
        ${log_exist}=        Does File Exist    ${LOG FILE}
        ${report_exist}=     Does File Exist    ${REPORT FILE}

        IF    ${output_exist}
            RPA.FileSystem.Copy File     ${OUTPUT FILE}   ./output/output.xml
        END
        IF    ${log_exist}
            RPA.FileSystem.Copy File     ${LOG FILE}      ./output/log.html
        END
        IF    ${report_exist}
            RPA.FileSystem.Copy File     ${REPORT FILE}   ./output/report.html
        END
    END


:>>Test Teardown
  
    #Раскрашиваем файлы
    ${red}=         Evaluate  ${RED}
    ${yellow}=      Evaluate  ${YELLOW}
    ${blue}=        Evaluate  ${BLUE}
    ${def}=         Evaluate  ${DEF}

    @{bug_lst}=     Create List

    FOR    ${tag}    IN    @{TEST TAGS}
        ${contains}=   Evaluate   "Bug" in """${tag}"""

        IF   ${contains}
            ${bug_tag}=       Replace String    ${tag}    Bug${SPACE}    ${EMPTY}
            Append To List    ${bug_lst}    ${bug_tag}
        END
    END


    IF    "@{bug_lst}" != "@{EMPTY}"
        
        IF    "${TEST STATUS}" == "FAIL"
            Log To Console    \nТест не прошел но так и толжно быть из за:
        END

        IF    "${TEST STATUS}" == "PASS"      
            Log To Console    \nТест прошел но есть инциденты которые нужно закрыть:
        END            
        
        FOR    ${bug}    IN    @{bug_lst}
            ${jira_lnk}=   Set Variable    ${blue}${JIRA_URL}/browse/${bug}${def}

            IF    "${TEST STATUS}" == "FAIL"
                Log To Console    • ${red}${bug}${def} ► ${jira_lnk}
            ELSE
                Log To Console    • ${yellow}${bug}${def} ► ${jira_lnk}
            END

        END

    END