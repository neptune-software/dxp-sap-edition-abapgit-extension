class zcl_abapgit_user_exit definition
  public
  final
  create public .

  public section.

    interfaces zif_abapgit_exit .

    types: begin of ty_mapping,
            object_type	  type /neptune/tadir_obj_type,
            key1          type  /neptune/artifact_key,
            artifact_name type /neptune/artifact_name,
           end of ty_mapping.

    class-data gt_mapping type standard table of ty_mapping with non-unique default key.
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.


  method ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_COMMIT_URL.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_FILENAME.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~ALLOW_SAP_OBJECTS.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_LOCAL_HOST.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_AUTHENTICATION.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_PORT.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_URL.
    return. " todo, implement method
  endmethod.


method ZIF_ABAPGIT_EXIT~CHANGE_SUPPORTED_DATA_OBJECTS.
endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_SUPPORTED_OBJECT_TYPES.

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

    field-symbols <fs_mapping> like line of gt_mapping.

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
            if sy-subrc eq 0.
              <fs_neptadir>-artifact_type = 'API'.
              <fs_neptadir>-key_mandt     = '000'.
              <fs_neptadir>-key1          = ls_api-name.
*            <fs_neptadir>-key1          = ls_api-apiid.
              <fs_neptadir>-devclass      = ls_api-devclass.
              <fs_neptadir>-artifact_name = ls_api-name.
              <fs_neptadir>-object_type   = 'ZN02'. " API
            endif.
            append initial line to gt_mapping assigning <fs_mapping>.
            if sy-subrc eq 0.
              <fs_mapping>-artifact_name = ls_api-name.
              <fs_mapping>-key1 = ls_api-apiid.
              <fs_mapping>-object_type = 'ZN02'.
            endif.
          endloop.
        endif.

        select *
          from /neptune/_app
          into corresponding fields of table lt_app
          where devclass eq iv_package.
        if sy-subrc eq 0.
          loop at lt_app into ls_app.
            append initial line to lt_neptadir assigning <fs_neptadir>.
            if sy-subrc eq 0.
              <fs_neptadir>-artifact_type = 'APP'.
              <fs_neptadir>-key_mandt     = '000'.
              <fs_neptadir>-key1          = ls_app-applid.
              <fs_neptadir>-devclass      = ls_app-devclass.
              <fs_neptadir>-artifact_name = ls_app-applid.
              <fs_neptadir>-object_type   = 'ZN01'. " APP
            endif.
          endloop.
        endif.

    endtry.

    loop at lt_neptadir assigning <fs_neptadir>.
      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
        <fs_tadir>-pgmid     = 'R3TR'.
        <fs_tadir>-object    = <fs_neptadir>-object_type.
*        <fs_tadir>-obj_name  = <fs_neptadir>-key1.
        <fs_tadir>-obj_name  = <fs_neptadir>-artifact_name.
        <fs_tadir>-devclass  = iv_package.
        <fs_tadir>-path      = '/src/' .
        <fs_tadir>-srcsystem = sy-sysid.
      endif.

      append initial line to gt_mapping assigning <fs_mapping>.
      if sy-subrc eq 0.
        <fs_mapping>-artifact_name = <fs_neptadir>-artifact_name.
        <fs_mapping>-key1 = <fs_neptadir>-key1.
        <fs_mapping>-object_type = <fs_neptadir>-object_type.
      endif.

    endloop.

  endmethod.


  method ZIF_ABAPGIT_EXIT~CREATE_HTTP_CLIENT.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~CUSTOM_SERIALIZE_ABAP_CLIF.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~DESERIALIZE_POSTPROCESS.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~DETERMINE_TRANSPORT_REQUEST.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~GET_CI_TESTS.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~GET_SSL_ID.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~HTTP_CLIENT.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~ON_EVENT.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~PRE_CALCULATE_REPO_STATUS.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~SERIALIZE_POSTPROCESS.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~VALIDATE_BEFORE_PUSH.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~WALL_MESSAGE_LIST.
    return. " todo, implement method
  endmethod.


  method ZIF_ABAPGIT_EXIT~WALL_MESSAGE_REPO.
    return. " todo, implement method
  endmethod.
ENDCLASS.
