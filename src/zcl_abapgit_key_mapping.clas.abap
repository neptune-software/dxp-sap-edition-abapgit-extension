class ZCL_ABAPGIT_KEY_MAPPING definition
  public
  create protected .

public section.

  interfaces ZIF_ABAPGIT_KEY_MAPPING .

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to ZIF_ABAPGIT_KEY_MAPPING .
  class-methods RESET_INSTANCE .
  class-methods SET_INSTANCE
    importing
      !IV_INSTANCE type ref to ZIF_ABAPGIT_KEY_MAPPING .
protected section.

  class-data:
    gt_mapping type standard table of ZIF_ABAPGIT_KEY_MAPPING=>ty_mapping with non-unique default key .
  class-data INSTANCE type ref to ZIF_ABAPGIT_KEY_MAPPING .
  class-data INSTANCE_INT type ref to ZIF_ABAPGIT_KEY_MAPPING .

*  data GV_MAIN_INTERFACE type SEOCLSNAME .
  methods CONSTRUCTOR .
  class-methods GET_INSTANCE_CLSNAME
    returning
      value(RV_CLSNAME) type SEOCLSNAME .
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_KEY_MAPPING IMPLEMENTATION.


method constructor.

  refresh gt_mapping.
*  gv_main_interface = 'ZIF_ABAPGIT_KEY_MAPPING'.

endmethod.


method GET_INSTANCE.
  if instance is initial.
    reset_instance( ).
*    instance->/neptune/if_settings~load( ).
  endif.

  ro_instance = instance.

endmethod.


method GET_INSTANCE_CLSNAME.
  rv_clsname = 'ZCL_ABAPGIT_KEY_MAPPING'.
endmethod.


method RESET_INSTANCE.

  data: lo_object type ref to object,
        l_clsname type seoclsname.

  if instance_int is initial.
    l_clsname = get_instance_clsname( ).
    create object lo_object type (l_clsname).
    instance_int ?= lo_object.
  endif.

  set_instance( iv_instance = instance_int ).

endmethod.


method SET_INSTANCE.

  data: lo_old_instance like instance.

  assert iv_instance is not initial.

  if instance <> iv_instance.
    lo_old_instance = instance.
  endif.

  instance = iv_instance.

  if lo_old_instance is not initial.
    raise event ZIF_ABAPGIT_KEY_MAPPING~instance_changed
      exporting
        eo_old_instance = lo_old_instance
        eo_new_instance = iv_instance.
  endif.

endmethod.


method zif_abapgit_key_mapping~get_key.

  data ls_mapping like line of gt_mapping.

  read table gt_mapping into ls_mapping with key object_type   = iv_object_type
                                                 artifact_name = iv_artifact_name.
  check sy-subrc eq 0.
  rv_key = ls_mapping-key1.

endmethod.


method zif_abapgit_key_mapping~set_key.

  check is_mapping is not initial.
  append is_mapping to gt_mapping.

  sort gt_mapping.
  delete adjacent duplicates from gt_mapping.

endmethod.
ENDCLASS.
