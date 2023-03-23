class ZCL_ABAPGIT_USER_EXIT definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_EXIT .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.


  METHOD ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_COMMIT_URL.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_FILENAME.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~ALLOW_SAP_OBJECTS.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~CHANGE_LOCAL_HOST.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~CHANGE_PROXY_AUTHENTICATION.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~CHANGE_PROXY_PORT.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~CHANGE_PROXY_URL.
    RETURN. " todo, implement method
  ENDMETHOD.


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


  METHOD ZIF_ABAPGIT_EXIT~CREATE_HTTP_CLIENT.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~CUSTOM_SERIALIZE_ABAP_CLIF.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~DESERIALIZE_POSTPROCESS.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~DETERMINE_TRANSPORT_REQUEST.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~GET_CI_TESTS.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~GET_SSL_ID.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~HTTP_CLIENT.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~ON_EVENT.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~PRE_CALCULATE_REPO_STATUS.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~SERIALIZE_POSTPROCESS.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~VALIDATE_BEFORE_PUSH.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~WALL_MESSAGE_LIST.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_EXIT~WALL_MESSAGE_REPO.
    RETURN. " todo, implement method
  ENDMETHOD.
ENDCLASS.
