class zcl_abapgit_user_exit definition
  public
  final
  create public .

  public section.

    interfaces zif_abapgit_exit .
  protected section.
  private section.
endclass.



class zcl_abapgit_user_exit implementation.


  method zif_abapgit_exit~adjust_display_commit_url.
    return.
  endmethod.


  method zif_abapgit_exit~adjust_display_filename.
    return.
  endmethod.


  method zif_abapgit_exit~allow_sap_objects.
    return.
  endmethod.


  method zif_abapgit_exit~change_local_host.
    return.
  endmethod.


  method zif_abapgit_exit~change_proxy_authentication.
    return.
  endmethod.


  method zif_abapgit_exit~change_proxy_port.
    return.
  endmethod.


  method zif_abapgit_exit~change_proxy_url.
    return.
  endmethod.


  method zif_abapgit_exit~change_supported_data_objects.
    return.
  endmethod.


  method zif_abapgit_exit~change_supported_object_types.

    data: lt_neptune_types type /neptune/cl_abapgit_user_exit=>ty_object_types_tt,
          ls_neptune_types like line of lt_neptune_types.

    data ls_types like line of ct_types.

    lt_neptune_types = /neptune/cl_abapgit_user_exit=>change_supported_object_types( ).
    loop at lt_neptune_types into ls_neptune_types.
      ls_types = ls_neptune_types.
      append ls_types to ct_types.
    endloop.

  endmethod.


  method zif_abapgit_exit~change_tadir.

    data: lt_neptune_tadir type /neptune/cl_abapgit_user_exit=>ty_tadir_tt,
          ls_neptune_tadir like line of lt_neptune_tadir.

    data ls_tadir like line of ct_tadir.

    lt_neptune_tadir = /neptune/cl_abapgit_user_exit=>change_tadir( iv_package = iv_package ).
    loop at lt_neptune_tadir into ls_neptune_tadir.
      move-corresponding ls_neptune_tadir to ls_tadir.
      append ls_tadir to ct_tadir.
    endloop.


  endmethod.


  method zif_abapgit_exit~create_http_client.
    return.
  endmethod.


  method zif_abapgit_exit~custom_serialize_abap_clif.
    return.
  endmethod.


  method zif_abapgit_exit~deserialize_postprocess.
    return.
  endmethod.


  method zif_abapgit_exit~determine_transport_request.
    return.
  endmethod.


  method zif_abapgit_exit~enhance_repo_toolbar.
    return.
  endmethod.


  method zif_abapgit_exit~get_ci_tests.
    return.
  endmethod.


  method zif_abapgit_exit~get_ssl_id.
    return.
  endmethod.


  method zif_abapgit_exit~http_client.
    return.
  endmethod.


  method zif_abapgit_exit~on_event.
    return.
  endmethod.


  method zif_abapgit_exit~pre_calculate_repo_status.
    return.
  endmethod.


  method zif_abapgit_exit~serialize_postprocess.
    return.
  endmethod.


  method zif_abapgit_exit~validate_before_push.
    return.
  endmethod.


  method zif_abapgit_exit~wall_message_list.
    return.
  endmethod.


  method zif_abapgit_exit~wall_message_repo.
    return.
  endmethod.
endclass.
