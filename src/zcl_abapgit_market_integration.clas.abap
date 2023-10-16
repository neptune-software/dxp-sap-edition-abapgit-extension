class ZCL_ABAPGIT_MARKET_INTEGRATION definition
  public
  final
  create public .

public section.

  class-methods ADD_ABAPGIT_REPO
    importing
      !IV_PARAMETERS type /NEPTUNE/MARKET_ABAPGIT_REPO
    exporting
      !RT_MESSAGES type /NEPTUNE/MESSAGE_TT .
  type-pools ABAP .
  class-methods CHECK_REPO_INSTALLED
    importing
      !IV_DEVCLASS type DEVCLASS
    exporting
      !EV_INSTALLED type ABAP_BOOL
      !RT_MESSAGES type /NEPTUNE/MESSAGE_TT .
  class-methods DELETE_ABAPGIT_REPO
    importing
      !IV_DEVCLASS type DEVCLASS
    exporting
      !RT_MESSAGES type /NEPTUNE/MESSAGE_TT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_MARKET_INTEGRATION IMPLEMENTATION.


method add_abapgit_repo.

  data: ls_logon       type /neptune/market_abapgit_repo,
        lv_user        type string,
        lv_password    type string,
        lv_credentials type string,
        lv_found       type i.

  data: lo_ex   type ref to zcx_abapgit_exception,
        lo_repo type ref to zif_abapgit_repo.

  data ls_message like line of rt_messages.

  data lo_utility type ref to cl_http_utility.

  move-corresponding iv_parameters to ls_logon.
  if ls_logon-folder_logic is initial.
    ls_logon-folder_logic = zif_abapgit_dot_abapgit=>c_folder_logic-prefix.
  endif.

  create object lo_utility.

  call method lo_utility->decode_base64
    exporting
      encoded = ls_logon-credentials
    receiving
      decoded = lv_credentials.
  if lv_credentials is not initial.
    split lv_credentials at ':' into lv_user lv_password.
  endif.

* chack pagage exists
  select count( * )
    from tdevc
    into lv_found
    where devclass = ls_logon-package.
  if lv_found = 0.

    ls_message-type = 'E'.
    ls_message-message = 'Did not find package: ' && ls_logon-package.
    append ls_message to rt_messages.

    " Try adding prefix $ which is often used for local packages.
    " Repository name cannot start with $ but ABAP package can.
    ls_logon-package = '$' && ls_logon-package.
    select count( * )
      from tdevc
      into lv_found
      where devclass = ls_logon-package.

    if lv_found = 0.
      ls_message-type = 'E'.
      ls_message-message = 'Did not find local package: ' && ls_logon-package.
      append ls_message to rt_messages.
      return.
    endif.
  endif.

* Add repo to abapGit
  try.

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
      append ls_message to rt_messages.

    catch zcx_abapgit_exception into lo_ex.
      ls_message-type = 'E'.
      ls_message-message = lo_ex->if_message~get_text( ).
      append ls_message to rt_messages.
  endtry.

endmethod.


method check_repo_installed.

  data ls_message like line of rt_messages.

  data: lo_ex   type ref to zcx_abapgit_exception,
        lo_repo type ref to zif_abapgit_repo.

  clear ev_installed.

  try.
      zcl_abapgit_migrations=>run( ).

      zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
        exporting
          iv_package = iv_devclass
        importing
          ei_repo    = lo_repo ).

      if lo_repo is not initial.
        ev_installed = abap_true.
      endif.

    catch zcx_abapgit_exception into lo_ex.
      ls_message-type = 'E'.
      ls_message-message = lo_ex->if_message~get_text( ).
      append ls_message to rt_messages.
  endtry.


endmethod.


method delete_abapgit_repo.

  data ls_message like line of rt_messages.

  data: lo_ex       type ref to zcx_abapgit_exception,
        lo_repo     type ref to zif_abapgit_repo,
        lo_repo_srv type ref to zif_abapgit_repo_srv.

  try.
      zcl_abapgit_migrations=>run( ).
      zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
        exporting
          iv_package = iv_devclass
        importing
          ei_repo = lo_repo ).

      if lo_repo is initial.
        return.
      endif.

      lo_repo_srv = zcl_abapgit_repo_srv=>get_instance( ).
      lo_repo_srv->delete( lo_repo ).


    catch zcx_abapgit_exception into lo_ex.
      ls_message-type = 'E'.
      ls_message-message = lo_ex->if_message~get_text( ).
      append ls_message to rt_messages.
  endtry.

endmethod.
ENDCLASS.
