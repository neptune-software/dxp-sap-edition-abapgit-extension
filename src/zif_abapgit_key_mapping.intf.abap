interface zif_abapgit_key_mapping
  public .


  types:
    begin of ty_mapping,
            object_type	  type /neptune/tadir_obj_type,
            key1          type /neptune/artifact_key,
            artifact_name type /neptune/artifact_name,
           end of ty_mapping .

  class-events instance_changed
    exporting
      value(eo_new_instance) type ref to zif_abapgit_key_mapping
      value(eo_old_instance) type ref to zif_abapgit_key_mapping .

  methods get_key
    importing
      !iv_object_type type /neptune/tadir_obj_type
      !iv_artifact_name type /neptune/artifact_name
    returning
      value(rv_key) type /neptune/artifact_key .
  methods set_key
    importing
      !is_mapping type ty_mapping .
endinterface.
