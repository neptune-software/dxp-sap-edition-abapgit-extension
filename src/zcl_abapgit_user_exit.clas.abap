class zcl_abapgit_user_exit definition
  public
  final
  create public .

  public section.

    interfaces zif_abapgit_exit .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.


  method zif_abapgit_exit~adjust_display_commit_url.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~adjust_display_filename.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~allow_sap_objects.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~change_local_host.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~change_proxy_authentication.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~change_proxy_port.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~change_proxy_url.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~change_supported_object_types.

    constants lc_tabname type c length 30 value '/NEPTUNE/ATY' ##no_text.
    constants lc_fieldname type c length 30 value 'OBJECT_TYPE' ##no_text.

    data lv_tabname type dd02l-tabname.
    data lt_ref type ref to data.

    field-symbols: <lt_standard_table> type standard table.
    field-symbols: <ls_line> type any.
    field-symbols: <lv_field> type any.

    select single tabname from dd02l into lv_tabname
      where tabname = lc_tabname.
    check sy-subrc = 0.

    create data lt_ref type standard table of (lc_tabname) with non-unique default key.
    assign lt_ref->* to <lt_standard_table>.

    select *
      from (lc_tabname)
      into table <lt_standard_table>.

    check sy-subrc eq 0 and <lt_standard_table> is not initial.

    loop at <lt_standard_table> assigning <ls_line>.
      assign component lc_fieldname of structure <ls_line> to <lv_field> casting type tadir-object.
      if sy-subrc eq 0.
        append <lv_field> to ct_types.
      endif.
    endloop.

  endmethod.


  method zif_abapgit_exit~change_tadir.

    data: lt_neptadir type /neptune/if_artifact_type=>ty_t_lcl_tadir.

    data lt_api type standard table of /neptune/api.
    data ls_api like line of lt_api.
    data lt_app type standard table of /neptune/_app.
    data ls_app like line of lt_app.

    field-symbols <fs_tadir> like line of ct_tadir.
    field-symbols <fs_neptadir> like line of lt_neptadir.

**********************************************************************
*    break andrec.

    check iv_package = '$NEPTUNE_GIT_TESTING'.

    try.
        " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        call method ('/NEPTUNE/CL_TADIR')=>('GET_TADIR_FOR_DEVCLASS') ##CALLED
*          call method  /neptune/cl_tadir=>get_tadir_for_devclass
          exporting
            iv_devclass = iv_package
          importing
            et_tadir    = lt_neptadir.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        refresh lt_neptadir.

        " From version bellow DXP 23 we only support applications and apis
        select *
          from /neptune/api
          into corresponding fields of table lt_api
          where devclass eq iv_package.
        if sy-subrc eq 0.
          loop at lt_api into ls_api.
            append initial line to lt_neptadir assigning <fs_neptadir>.
            <fs_neptadir>-artifact_type = 'API'.
            <fs_neptadir>-key_mandt     = '000'.
            <fs_neptadir>-key1          = ls_api-apiid.
            <fs_neptadir>-devclass      = ls_api-devclass.
            <fs_neptadir>-artifact_name = ls_api-name.
            <fs_neptadir>-object_type   = 'ZN02'. " API
          endloop.
        endif.

        select *
          from /neptune/_app
          into corresponding fields of table lt_app
          where devclass eq iv_package.
        if sy-subrc eq 0.
          loop at lt_app into ls_app.
            append initial line to lt_neptadir assigning <fs_neptadir>.
            <fs_neptadir>-artifact_type = 'APP'.
            <fs_neptadir>-key_mandt     = '000'.
            <fs_neptadir>-key1          = ls_app-applid.
            <fs_neptadir>-devclass      = ls_app-devclass.
            <fs_neptadir>-artifact_name = ls_app-applid.
            <fs_neptadir>-object_type   = 'ZN01'. " APP
          endloop.
        endif.

    endtry.

    loop at lt_neptadir assigning <fs_neptadir>.
      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
        <fs_tadir>-pgmid     = 'R3TR'.
        <fs_tadir>-object    = <fs_neptadir>-object_type.
        <fs_tadir>-obj_name  = <fs_neptadir>-key1.
        <fs_tadir>-devclass  = iv_package.
        <fs_tadir>-path      = '/src/' .
        <fs_tadir>-srcsystem = sy-sysid.
      endif.

    endloop.

  endmethod.


  method zif_abapgit_exit~create_http_client.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~custom_serialize_abap_clif.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~deserialize_postprocess.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~determine_transport_request.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~get_ci_tests.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~get_ssl_id.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~http_client.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~on_event.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~pre_calculate_repo_status.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~serialize_postprocess.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~validate_before_push.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~wall_message_list.
    return. " todo, implement method
  endmethod.


  method zif_abapgit_exit~wall_message_repo.
    return. " todo, implement method
  endmethod.
ENDCLASS.
