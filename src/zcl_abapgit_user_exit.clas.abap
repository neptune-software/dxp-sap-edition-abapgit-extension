class ZCL_ABAPGIT_USER_EXIT definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_EXIT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.
  METHOD zif_abapgit_exit~wall_message_repo.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~wall_message_list.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~validate_before_push.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~serialize_postprocess.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~pre_calculate_repo_status.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~on_event.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~http_client.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~get_ssl_id.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~get_ci_tests.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~determine_transport_request.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~deserialize_postprocess.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~custom_serialize_abap_clif.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~create_http_client.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~change_proxy_url.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~change_proxy_port.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~change_proxy_authentication.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~change_local_host.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~allow_sap_objects.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~adjust_display_filename.
    RETURN. " todo, implement method
  ENDMETHOD.
  METHOD zif_abapgit_exit~adjust_display_commit_url.
    RETURN. " todo, implement method
  ENDMETHOD.


method zif_abapgit_exit~change_tadir.

*  data: ls_tadir like line of ct_tadir.
  field-symbols: <fs_tadir> like line of ct_tadir.

  if sy-uname eq 'ANDREC'.
    BREAK-POINT.
    if iv_package cs '$NEPTUNE_GIT_TESTING'.
*      append value #(
*        pgmid    = 'R3TR'
*        object   = 'ZN01'"some_logic( something )
*        obj_name = 'ANDRE_GIT_TESTES' "something-name
*        devclass = iv_package
*        path     = '/src/'
*        ) to ct_tadir.


      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
        <fs_tadir>-pgmid    = 'R3TR'.
        <fs_tadir>-object   = 'ZN01' ."some_logic( something ).
        <fs_tadir>-obj_name = 'ANDRE_GIT_TESTES' . "something-name.
        <fs_tadir>-devclass = iv_package.
        <fs_tadir>-path     = '/src/' .
      endif.
    endif.
  endif.
endmethod.
ENDCLASS.
