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

    data: lt_neptadir type /neptune/if_artifact_type=>ty_t_lcl_tadir,
          ls_neptadir like line of lt_neptadir.

    field-symbols <fs_tadir> like line of ct_tadir.

**********************************************************************
*    break andrec.

    try.

*          raise exception type cx_sy_dyn_call_illegal_method.
*          raise exception type CX_SY_DYN_CALL_ILLEGAL_CLASS.

        " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        call method ('/NEPTUNE/CL_TADIR')=>('GET_TADIR_FOR_DEVCLASS') ##CALLED
*          call method  /neptune/cl_tadir=>get_tadir_for_devclass
          exporting
            iv_devclass = iv_package
          importing
            et_tadir    = lt_neptadir.

      catch cx_sy_dyn_call_illegal_method.
      catch cx_sy_dyn_call_illegal_class.

        " From DXP 21 < 23 we only support applications and apis
*          select applid FROM t


    endtry.

    loop at lt_neptadir into ls_neptadir.
      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
        <fs_tadir>-pgmid     = 'R3TR'.
        <fs_tadir>-object    = ls_neptadir-object_type.
        <fs_tadir>-obj_name  = ls_neptadir-key1.
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
