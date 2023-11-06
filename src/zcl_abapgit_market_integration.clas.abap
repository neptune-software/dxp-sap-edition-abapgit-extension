CLASS zcl_abapgit_market_integration DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS abap .

    CLASS-METHODS add_abapgit_repo
      IMPORTING
        !iv_parameters TYPE /neptune/market_abapgit_repo
      EXPORTING
        !rt_messages TYPE /neptune/message_tt .
    CLASS-METHODS check_repo_installed
      IMPORTING
        !iv_devclass TYPE devclass
      EXPORTING
        !ev_installed TYPE abap_bool
        !rt_messages TYPE /neptune/message_tt .
    CLASS-METHODS delete_abapgit_repo
      IMPORTING
        !iv_devclass TYPE devclass
      EXPORTING
        !rt_messages TYPE /neptune/message_tt .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_market_integration IMPLEMENTATION.


  METHOD add_abapgit_repo.

    DATA: ls_logon       TYPE /neptune/market_abapgit_repo,
          lv_user        TYPE string,
          lv_password    TYPE string,
          lv_credentials TYPE string,
          lv_found       TYPE i.

    DATA: lo_ex           TYPE REF TO zcx_abapgit_exception,
          lo_ex_not_found TYPE REF TO zcx_abapgit_not_found,
          lo_repo         TYPE REF TO zif_abapgit_repo.

    DATA ls_message LIKE LINE OF rt_messages.

    DATA lo_utility TYPE REF TO cl_http_utility.

    MOVE-CORRESPONDING iv_parameters TO ls_logon.
    IF ls_logon-folder_logic IS INITIAL.
      ls_logon-folder_logic = zif_abapgit_dot_abapgit=>c_folder_logic-prefix.
    ENDIF.

    CREATE OBJECT lo_utility.

    CALL METHOD lo_utility->decode_base64
      EXPORTING
        encoded = ls_logon-credentials
      RECEIVING
        decoded = lv_credentials.
    IF lv_credentials IS NOT INITIAL.
      SPLIT lv_credentials AT ':' INTO lv_user lv_password.
    ENDIF.

* chack pagage exists
    SELECT COUNT( * )
      FROM tdevc
      INTO lv_found
      WHERE devclass = ls_logon-package. "#EC CI_SUBRC
    IF lv_found = 0.

      ls_message-type = 'E'.
      ls_message-message = 'Did not find package: ' && ls_logon-package.
      APPEND ls_message TO rt_messages.

      " Try adding prefix $ which is often used for local packages.
      " Repository name cannot start with $ but ABAP package can.
      ls_logon-package = '$' && ls_logon-package.
      SELECT COUNT( * )
        FROM tdevc
        INTO lv_found
        WHERE devclass = ls_logon-package. "#EC CI_SUBRC

      IF lv_found = 0.
        ls_message-type = 'E'.
        ls_message-message = 'Did not find local package: ' && ls_logon-package.
        APPEND ls_message TO rt_messages.
        RETURN.
      ENDIF.
    ENDIF.

* Add repo to abapGit
    TRY.

        zcl_abapgit_migrations=>run( ).

        zcl_abapgit_login_manager=>set(
          iv_uri      = ls_logon-url
          iv_username = lv_user
          iv_password = lv_password ).

        lo_repo = zcl_abapgit_repo_srv=>get_instance( )->new_online(
          iv_url            = ls_logon-url
          iv_branch_name    = ls_logon-branch_name
          iv_display_name   = ls_logon-display_name
          iv_package        = ls_logon-package
          iv_folder_logic   = ls_logon-folder_logic
          iv_labels         = ls_logon-labels
          iv_ign_subpkg     = ls_logon-ign_subpkg
          iv_main_lang_only = ls_logon-main_lang_only ).

        ls_message-type = 'S'.
        ls_message-message = 'GitHub Repository added to abapGit'.
        APPEND ls_message TO rt_messages.

      CATCH zcx_abapgit_exception INTO lo_ex.
        ls_message-type = 'E'.
        ls_message-message = lo_ex->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

      CATCH zcx_abapgit_not_found INTO lo_ex_not_found.
        ls_message-type = 'E'.
        ls_message-message = lo_ex_not_found->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

    ENDTRY.

  ENDMETHOD.


  METHOD check_repo_installed.

    DATA ls_message LIKE LINE OF rt_messages.

    DATA: lo_ex           TYPE REF TO zcx_abapgit_exception,
          lo_ex_not_found TYPE REF TO zcx_abapgit_not_found,
          lo_repo         TYPE REF TO zif_abapgit_repo.

    CLEAR ev_installed.

    TRY.
        zcl_abapgit_migrations=>run( ).

        zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
          EXPORTING
            iv_package = iv_devclass
          IMPORTING
            ei_repo    = lo_repo ).

        IF lo_repo IS NOT INITIAL.
          ev_installed = abap_true.
        ENDIF.

      CATCH zcx_abapgit_exception INTO lo_ex.
        ls_message-type = 'E'.
        ls_message-message = lo_ex->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

      CATCH zcx_abapgit_not_found INTO lo_ex_not_found.
        ls_message-type = 'E'.
        ls_message-message = lo_ex_not_found->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

    ENDTRY.


  ENDMETHOD.


  METHOD delete_abapgit_repo.

    DATA ls_message LIKE LINE OF rt_messages.

    DATA: lo_ex           TYPE REF TO zcx_abapgit_exception,
          lo_ex_not_found TYPE REF TO zcx_abapgit_not_found,
          lo_repo         TYPE REF TO zif_abapgit_repo,
          lo_repo_srv     TYPE REF TO zif_abapgit_repo_srv.

    TRY.
        zcl_abapgit_migrations=>run( ).
        zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
          EXPORTING
            iv_package = iv_devclass
          IMPORTING
            ei_repo    = lo_repo ).

        IF lo_repo IS INITIAL.
          RETURN.
        ENDIF.

        lo_repo_srv = zcl_abapgit_repo_srv=>get_instance( ).
        lo_repo_srv->delete( lo_repo ).


      CATCH zcx_abapgit_exception INTO lo_ex.
        ls_message-type = 'E'.
        ls_message-message = lo_ex->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

      CATCH zcx_abapgit_not_found INTO lo_ex_not_found.
        ls_message-type = 'E'.
        ls_message-message = lo_ex_not_found->if_message~get_text( ).
        APPEND ls_message TO rt_messages.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
