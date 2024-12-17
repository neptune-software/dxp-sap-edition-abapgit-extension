class ZCL_ABAPGIT_OBJECT_ZN25 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
  protected section.
private section.

  constants:
    mc_name_separator(1) type c value '@', "#EC NOTEXT
    mc_msg_datatype type string value '/NEPTUNE/CL_ARTIFACT_TYPE_THM=>TT_MESSAGES'.. "#EC NOTEXT
  data MV_ARTIFACT_TYPE type /NEPTUNE/ARTIFACT_TYPE .
  data MS_THEME type /NEPTUNE/LIB_UTH .
  data mr_generic_data type ref to data.

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
  methods DESERIALIZE_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA
      !IV_TABNAME type TADIR-OBJ_NAME
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_VALUES_FROM_FILENAME
    importing
      !IS_FILENAME type STRING
    exporting
      !EV_TABNAME type TADIR-OBJ_NAME
      !EV_NAME type /NEPTUNE/ARTIFACT_NAME .
  methods INSERT_TO_TRANSPORT
    importing
      !IO_ARTIFACT type ref to /NEPTUNE/IF_ARTIFACT_TYPE
      !IV_TRANSPORT type TRKORR
      !IV_PACKAGE type DEVCLASS
      !IV_KEY1 type ANY
      !IV_ARTIFACT_TYPE type /NEPTUNE/ATY-ARTIFACT_TYPE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN25 IMPLEMENTATION.


  method DESERIALIZE_TABLE.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    field-symbols <lt_tab> type any table.
    field-symbols <lt_standard_table> type standard table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    create data lt_table_content type standard table of (iv_tabname) with non-unique default key.
    assign lt_table_content->* to <lt_standard_table>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

        lo_ajson->zif_abapgit_ajson~to_abap( exporting iv_corresponding = abap_true
                                             importing ev_container     = <lt_standard_table> ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    <lt_tab> = <lt_standard_table>.

  endmethod.


  method GET_VALUES_FROM_FILENAME.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.
    data lv_key type /neptune/artifact_key.
    data lv_name type string.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
      split ls_comp at mc_name_separator into lv_name lv_key.
      translate lv_name to upper case.
      ev_name = lv_name.
    endif.

    read table lt_comp into ls_comp index 3.
    if sy-subrc = 0.
      replace all occurrences of '#' in ls_comp with '/'.
      translate ls_comp to upper case.
      ev_tabname = ls_comp.
    endif.

  endmethod.


  method INSERT_TO_TRANSPORT.

    data ls_message type /neptune/message.
    data lv_task type trkorr.

    /neptune/cl_nad_transport=>transport_task_find(
      exporting
        transport = iv_transport
      importing
        task      = lv_task ).

    io_artifact->insert_to_transport(
      exporting
        iv_korrnum = lv_task
        iv_key1    = iv_key1
      importing
        ev_message = ls_message ).

    try.
        call method ('/NEPTUNE/CL_TADIR')=>('INSERT_TO_TRANSPORT')
*            call method /neptune/cl_tadir=>insert_to_transport
            exporting
              iv_korrnum       = lv_task
              iv_devclass      = iv_package
              iv_artifact_key  = iv_key1
              iv_artifact_type = iv_artifact_type
            importing
              ev_message      = ls_message.
      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    endtry.

  endmethod.


  method SERIALIZE_TABLE.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data lt_skip_paths type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

    try.
        lo_ajson = zcl_abapgit_ajson=>create_empty( ).
        lo_ajson->keep_item_order( ).
        lo_ajson->set(
          iv_path = '/'
          iv_val  = it_table ).

* Remove fields that have initial value
        lo_ajson = zcl_abapgit_ajson=>create_from(
                      ii_source_json = lo_ajson
                      ii_filter      = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

* Remove unwanted fields
        lt_skip_paths = zcl_neptune_abapgit_utilities=>get_skip_fields_for_artifact(
                                                          iv_artifact_type = mv_artifact_type
                                                          iv_serialize     = abap_true ).
        if lt_skip_paths is not initial.
          lo_ajson = zcl_abapgit_ajson=>create_from(
                        ii_source_json = lo_ajson
                        ii_filter      = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                            it_skip_paths     = lt_skip_paths
                                            iv_pattern_search = abap_true ) ).
        endif.

        lv_json = lo_ajson->stringify( 2 ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    ls_file-path = '/'.
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->add
        exporting
          is_file = ls_file.
    else.
      concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name iv_tabname into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

  endmethod.


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data: lv_crenam type /neptune/create_user,
          lv_credat type /neptune/create_date,
          lv_cretim type /neptune/create_time,
          lv_updnam type /neptune/update_user,
          lv_upddat type /neptune/update_date,
          lv_updtim type /neptune/update_time.

    field-symbols <lt_standard_table> type standard table.
    field-symbols <ls_any> type any.
    field-symbols <la_user> type any.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    try.
        call method lo_artifact->('GET_METADATA')
          exporting
            iv_key1   = lv_key
          importing
            ev_crenam = lv_crenam
            ev_credat = lv_credat
            ev_cretim = lv_cretim
            ev_updnam = lv_updnam
            ev_upddat = lv_upddat
            ev_updtim = lv_updtim.

        if lv_upddat is not initial.
          rv_user = lv_updnam.
        else.
          rv_user = lv_crenam.
        endif.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        lo_artifact->get_table_content(
          exporting iv_key1                 = lv_key
                    iv_only_sys_independent = abap_true
          importing et_table_content        = lt_table_content ).

        read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/LIB_UTH'.
        if sy-subrc = 0.
          assign ls_table_content-table_content->* to <lt_standard_table>.
          check sy-subrc = 0.
          read table <lt_standard_table> assigning <ls_any> index 1.
          if sy-subrc = 0.
            unassign <la_user>.
            assign component 'UPDNAM' of structure <ls_any> to <la_user>.
            if sy-subrc = 0 and <la_user> is not initial.
              rv_user = <la_user>.
            else.
              assign component 'CRENAM' of structure <la_user> to <la_user>.
              if sy-subrc = 0.
                rv_user = <la_user>.
              endif.
            endif.
          endif.
        endif.

    endtry.

  endmethod.


  method zif_abapgit_object~delete.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          ls_settings type /neptune/aty,
          lv_key1     type /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    ls_settings = lo_artifact->get_settings( ).

    lv_key1 = ms_item-obj_name.
    try.
        call method lo_artifact->('DELETE_ARTIFACT')
          exporting
            iv_key1      = lv_key1
            iv_devclass  = iv_package
            iv_transport = iv_transport.
      catch cx_sy_dyn_call_error.
    endtry.

    lo_artifact->delete_tadir_entry( iv_key1 = lv_key1 ).

    if ls_settings-transportable is not initial and iv_transport is not initial.

      insert_to_transport(
        io_artifact      = lo_artifact
        iv_transport     = iv_transport
        iv_package       = iv_package
        iv_key1          = lv_key1
        iv_artifact_type = ls_settings-artifact_type ).

    endif.

  endmethod.


  method zif_abapgit_object~deserialize.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data lo_artifact type ref to /neptune/if_artifact_type.
    data lo_artifact_thm type ref to object.
    data ls_settings type /neptune/aty.

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lt_system_field_values type /neptune/if_artifact_type=>ty_t_system_field_values.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.
    data lv_name    type /neptune/artifact_name.
    data lv_message type string.

    data lv_file_name type string.

    field-symbols <lt_standard_table> type standard table.
    field-symbols <lt_messages> type standard table.
    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols: <fs_cons_value> type any.

    try.
        io_xml->read(
          exporting
            iv_name = 'key'
          changing
            cg_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->GET_FILES does not work anymore
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->get_files
        receiving
          rt_files = lt_files.
    else.
      concatenate 'Error deserializing' ms_item-obj_type  ms_item-obj_name lv_key into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

    loop at lt_files into ls_files where filename cp '*.json'.

      get_values_from_filename(
        exporting
          is_filename = ls_files-filename
        importing
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      deserialize_table(
        is_file    = ls_files
        iv_tabname = lv_tabname
        ir_data    = lr_data ).

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      append ls_table_content to lt_table_content.
      clear ls_table_content.

    endloop.

    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
      ls_settings = lo_artifact->get_settings( ).

      lo_artifact_thm = lo_artifact.

      lo_artifact->delete_artifact(
        exporting
          iv_key1                = lv_key
          iv_devclass            = iv_package
        importing
          et_system_field_values = lt_system_field_values ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content
        it_system_fields_values = lt_system_field_values ).

      lo_artifact->update_tadir_entry(
          iv_key1          = lv_key
          iv_devclass      = iv_package
          iv_artifact_name = lv_name ).

    else.
      return.
    endif.

    if ls_settings-transportable is not initial and iv_transport is not initial.

      insert_to_transport(
        io_artifact      = lo_artifact
        iv_transport     = iv_transport
        iv_package       = iv_package
        iv_key1          = lv_key
        iv_artifact_type = ls_settings-artifact_type ).

    endif.

    try.
        create data mr_generic_data type (mc_msg_datatype).
        assign mr_generic_data->* to <lt_messages>.
      catch cx_sy_create_data_error
            cx_sy_assign_cast_illegal_cast.
        concatenate 'Error deserializing' ms_item-obj_type ms_item-obj_name 'Dynamic assignment' into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

    concatenate ms_item-obj_name ms_item-obj_type 'zip' into lv_file_name separated by '.'.
    translate lv_file_name to lower case.

    read table lt_files into ls_files with key filename = lv_file_name.
    check sy-subrc eq 0.

    assign lr_data->* to <lt_standard_table>.
    check <lt_standard_table> is assigned.
    read table <lt_standard_table> into ms_theme index 1.
    check sy-subrc eq 0.

    try.

        assign ('/NEPTUNE/CL_ARTIFACT_TYPE_THM=>MC_CUS_MIME_PATH') to <fs_cons_value>.
        if <fs_cons_value> is not assigned.
          concatenate 'Error deserializing' ms_item-obj_type  ms_item-obj_name ' Dynamic assignment of constant' into lv_message separated by space.
          zcx_abapgit_exception=>raise( lv_message ).
        endif.

        call method lo_artifact_thm->('UNPACK_ZIP_FILE')
          exporting
            iv_zip       = ls_files-data
            iv_devclass  = iv_package
            iv_transport = iv_transport
            iv_mime_path = <fs_cons_value>
            is_theme     = ms_theme
          importing
            et_messages  = <lt_messages>.
        if <lt_messages> is not initial.
          concatenate 'Error deserializing' ms_item-obj_type ms_item-obj_name 'Errors occured in method UNPACK_ZIP_FILE' into lv_message separated by space.
          zcx_abapgit_exception=>raise( lv_message ).
        endif.

      catch cx_sy_dyn_call_error.
        concatenate 'Error deserializing' ms_item-obj_type ms_item-obj_name 'No class or method exists' into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.







  endmethod.


  method ZIF_ABAPGIT_OBJECT~EXISTS.
    rv_bool = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_ORDER.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_METADATA.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
    rv_active = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_LOCKED.

    data lo_artifact type ref to /neptune/if_artifact_type.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = ms_item-obj_name ).

  endmethod.


  method ZIF_ABAPGIT_OBJECT~JUMP.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~MAP_FILENAME_TO_OBJECT.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~MAP_OBJECT_TO_FILENAME.
    return.
  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact_thm  type ref to object,
          lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key,
          lv_zip           type xstring.

    data ls_file       type zif_abapgit_git_definitions=>ty_file.
    data lv_message    type string.

    field-symbols <lt_standard_table> type standard table.
    field-symbols <lt_messages> type standard table.
    field-symbols <lr_object_files>   type ref to zcl_abapgit_objects_files.

**********************************************************************

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

    lo_artifact_thm = lo_artifact.

    try.
        io_xml->add(
          iv_name = 'key'
          ig_data = ms_item-obj_name ).
      catch zcx_abapgit_exception.
    endtry.

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).


    clear ms_theme.

* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.

      check sy-subrc = 0 and <lt_standard_table> is not initial.
      read table <lt_standard_table> into ms_theme index 1.
      check sy-subrc eq 0.

      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).

    endloop.

    check ms_theme is not initial.

    try.
        create data mr_generic_data type (mc_msg_datatype).
        assign mr_generic_data->* to <lt_messages>.
      catch cx_sy_create_data_error
            cx_sy_assign_cast_illegal_cast.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name 'Dynamic assignment' into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

    try.
        call method lo_artifact_thm->('GET_ZIP_FILE')
          exporting
            iv_plugin_id  = ms_theme-plugin_id
            iv_theme_root = ms_theme-theme_root
          importing
            ev_zip        = lv_zip
            et_messages   = <lt_messages>.
        if <lt_messages> is not initial.
          concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name 'Errors occured in method GET_ZIP_FILE' into lv_message separated by space.
          zcx_abapgit_exception=>raise( lv_message ).
        endif.
      catch cx_sy_dyn_call_error.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name 'No class or method exists' into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

    concatenate ms_item-obj_name
                ms_item-obj_type
                'zip' into ls_file-filename separated by '.'.

    translate ls_file-filename to lower case.

    ls_file-path = '/'.
    ls_file-data = lv_zip.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->add
        exporting
          is_file = ls_file.
    else.
      concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name '<lr_object_files> not assigned' into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

  endmethod.
ENDCLASS.
