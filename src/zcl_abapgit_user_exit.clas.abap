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


  method ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_COMMIT_URL.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~ADJUST_DISPLAY_FILENAME.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~ALLOW_SAP_OBJECTS.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_LOCAL_HOST.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_AUTHENTICATION.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_PORT.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~CHANGE_PROXY_URL.
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


  method ZIF_ABAPGIT_EXIT~CREATE_HTTP_CLIENT.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~CUSTOM_SERIALIZE_ABAP_CLIF.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~DESERIALIZE_POSTPROCESS.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~DETERMINE_TRANSPORT_REQUEST.
    return.
  endmethod.


method ZIF_ABAPGIT_EXIT~ENHANCE_REPO_TOOLBAR.
  return.
endmethod.


  method ZIF_ABAPGIT_EXIT~GET_CI_TESTS.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~GET_SSL_ID.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~HTTP_CLIENT.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~ON_EVENT.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~PRE_CALCULATE_REPO_STATUS.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~SERIALIZE_POSTPROCESS.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~VALIDATE_BEFORE_PUSH.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~WALL_MESSAGE_LIST.
    return.
  endmethod.


  method ZIF_ABAPGIT_EXIT~WALL_MESSAGE_REPO.
    return.
  endmethod.
ENDCLASS.
