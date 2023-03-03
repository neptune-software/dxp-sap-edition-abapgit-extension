class zcl_abapgit_user_exit definition
  public
  final
  create public .

  public section.

    interfaces zif_abapgit_exit .

    types: begin of ty_tadir,
            artifact_type type  /neptune/artifact_type,
            key_mandt     type  mandt,
            key1          type  /neptune/artifact_key,
            devclass      type char30,
            artifact_name type /neptune/artifact_name,
            object_type	  type /neptune/tadir_obj_type,
           end of ty_tadir.
    types ty_tadir_tt type standard table of ty_tadir.
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.


  METHOD zif_abapgit_exit~adjust_display_commit_url.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~adjust_display_filename.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~allow_sap_objects.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_local_host.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_authentication.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_port.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_url.
    RETURN. " todo, implement method
  ENDMETHOD.


  method zif_abapgit_exit~change_tadir.

    data: lt_tadir type ty_tadir_tt.

    data: lt_neptadir type ty_tadir_tt,
          ls_neptadir like line of lt_neptadir.
*    data: lt_neptadir type standard table of /neptune/tadir,
*          ls_neptadir like line of lt_neptadir.

*    data: lo_tadir type ref to /neptune/if_tadir,
*          lv_object_type type /neptune/tadir_obj_type.

    field-symbols <fs_tadir> like line of ct_tadir.

**********************************************************************
    break andrec.

    try.

*          raise exception type cx_sy_dyn_call_illegal_method.
*          raise exception type CX_SY_DYN_CALL_ILLEGAL_CLASS.

        " Ongoing ffrom DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        call method ('/NEPTUNE/CL_TADIR')=>('GET_TADIR_FOR_DEVCLASS')
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

*      lo_tadir = /neptune/cl_tadir=>get_instance( iv_devclass = iv_package ).
*      lt_neptadir = lo_tadir->get_tadir( ).

    loop at lt_neptadir into ls_neptadir.
      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
*          lv_object_type = lo_tadir->get_object_type( iv_artifact_type = ls_neptadir-artifact_type ).
        <fs_tadir>-pgmid     = 'R3TR'.
        <fs_tadir>-object    = ls_neptadir-object_type.
        <fs_tadir>-obj_name  = ls_neptadir-key1.
        <fs_tadir>-devclass  = iv_package.
        <fs_tadir>-path      = '/src/' .
        <fs_tadir>-srcsystem = sy-sysid.
      endif.

    endloop.


  endmethod.


  METHOD zif_abapgit_exit~create_http_client.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~custom_serialize_abap_clif.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~deserialize_postprocess.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~determine_transport_request.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~get_ci_tests.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~get_ssl_id.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~http_client.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~on_event.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~pre_calculate_repo_status.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~serialize_postprocess.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~validate_before_push.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~wall_message_list.
    RETURN. " todo, implement method
  ENDMETHOD.


  METHOD zif_abapgit_exit~wall_message_repo.
    RETURN. " todo, implement method
  ENDMETHOD.
ENDCLASS.
