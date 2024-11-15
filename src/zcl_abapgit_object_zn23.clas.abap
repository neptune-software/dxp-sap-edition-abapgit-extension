class zcl_abapgit_object_zn23 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.
    interfaces zif_abapgit_object .

    methods constructor
      importing
        !is_item        type zif_abapgit_definitions=>ty_item
        !iv_language    type spras
*        !io_files       type ref to zcl_abapgit_objects_files optional
*        !io_i18n_params type ref to zcl_abapgit_i18n_params optional
      raising
        zcx_abapgit_exception.

  protected section.
  private section.

    constants:
      mc_name_separator(1) type c value '@'.                "#EC NOTEXT

    data mv_artifact_type type /neptune/artifact_type.
    data mv_neptune_i18n_supported type abap_bool.

    methods serialize_table
      importing
        !iv_tabname type tabname
        !it_table   type any
      raising
        zcx_abapgit_exception.

    methods get_values_from_filename
      importing
        !is_filename type string
      exporting
        !ev_tabname  type tadir-obj_name
        !ev_name     type /neptune/artifact_name .

    methods deserialize_table
      importing
        !is_file    type zif_abapgit_git_definitions=>ty_file
        !ir_data    type ref to data
        !iv_tabname type tadir-obj_name
      raising
        zcx_abapgit_exception .

    methods insert_to_transport
      importing
        !io_artifact      type ref to /neptune/if_artifact_type
        !iv_transport     type trkorr
        !iv_package       type devclass
        !iv_key1          type any
        !iv_artifact_type type /neptune/aty-artifact_type.

    methods serialize_i18n
      importing
        it_table_content type /neptune/if_artifact_type=>ty_t_table_content
      raising
        zcx_abapgit_exception.

ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN23 IMPLEMENTATION.


  method constructor.

    super->constructor(
      is_item        = is_item
      iv_language    = iv_language ).
*      io_files       = io_files
*      io_i18n_params = io_i18n_params ).

    try.
        call method ('/NEPTUNE/CL_I18N')=>('ABAPGIT_I18N_AVAILABLE')
          importing
            ev_available = mv_neptune_i18n_supported.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        zcx_abapgit_exception=>raise( 'Neptune i18n not supported' ).
    endtry.

  endmethod.


  method deserialize_table.

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


  method get_values_from_filename.

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


  method insert_to_transport.

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


  method serialize_i18n.

    types:
      begin of ty_abapgit_file,
        filename type string,
        contents type string,
      end of ty_abapgit_file.
    types ty_abapgit_files type standard table of ty_abapgit_file with default key.

    data lt_abapgit_files type ty_abapgit_files.
    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_stripped_filename type string.
    data lv_message type string.

    field-symbols <ls_abapgit_file> like line of lt_abapgit_files.
    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

    try.
        call method ('/NEPTUNE/CL_I18N')=>('ABAPGIT_SERIALIZE_ZN23')
          exporting
            it_table_content = it_table_content
          importing
            et_files         = lt_abapgit_files.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    endtry.

    lv_stripped_filename = zcl_abapgit_filename_logic=>object_to_file(
                               is_item = ms_item
                               iv_ext  = '' ).

    loop at lt_abapgit_files assigning <ls_abapgit_file>.

      " Change newline sequence for git
      replace all occurrences of cl_abap_char_utilities=>cr_lf in <ls_abapgit_file>-contents with cl_abap_char_utilities=>newline.

      ls_file-path = '/'.
      ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <ls_abapgit_file>-contents ).

      " i18n languages are case sensitive, for example i18n_zh_CN.properties...
      concatenate lv_stripped_filename '.' <ls_abapgit_file>-filename into ls_file-filename.


* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
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
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
      endif.

    endloop.

  endmethod.


  method serialize_table.

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
*    zif_abapgit_object~mo_files->add( ls_file ).
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

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_menu type /neptune/menu.

    data: lv_crenam type /neptune/create_user,
          lv_credat type /neptune/create_date,
          lv_cretim type /neptune/create_time,
          lv_updnam type /neptune/update_user,
          lv_upddat type /neptune/update_date,
          lv_updtim type /neptune/update_time.

    field-symbols <lt_standard_table> type standard table.

**********************************************************************

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

        read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/MENU'.
        if sy-subrc = 0.
          assign ls_table_content-table_content->* to <lt_standard_table>.
          check sy-subrc = 0.
          read table <lt_standard_table> into ls_menu index 1.
          if sy-subrc = 0 and ls_menu-updnam is not initial.
            rv_user = ls_menu-updnam.
          else.
            rv_user = ls_menu-crenam.
          endif.
        endif.

    endtry.

  endmethod.


  method zif_abapgit_object~delete.

    if mv_neptune_i18n_supported = abap_false.
      return.
    endif.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          ls_settings type /neptune/aty,
          lv_key1     type /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    ls_settings = lo_artifact->get_settings( ).

    lv_key1 = ms_item-obj_name.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

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

    types:
      begin of ty_abapgit_file,
        filename type string,
        contents type string,
      end of ty_abapgit_file.
    types ty_abapgit_files type standard table of ty_abapgit_file with default key.

    data lo_artifact            type ref to /neptune/if_artifact_type.
    data lt_files               type zif_abapgit_git_definitions=>ty_files_tt.
    data ls_files               like line of lt_files.
    data lt_table_content       type /neptune/if_artifact_type=>ty_t_table_content.
    data ls_table_content       like line of lt_table_content.
    data lt_system_field_values type /neptune/if_artifact_type=>ty_t_system_field_values.
    data lr_data                type ref to data.
    data lv_tabname             type tadir-obj_name.
    data lv_key                 type /neptune/artifact_key.
    data lv_name                type /neptune/artifact_name.
    data ls_settings            type /neptune/aty.
    data lv_message             type string.
    data lt_abapgit_files       type ty_abapgit_files.

    field-symbols <lr_object_files>   type ref to zcl_abapgit_objects_files.
    field-symbols <ls_abapgit_file>   like line of lt_abapgit_files.

    if mv_neptune_i18n_supported = abap_false.
      return.
    endif.

    try.
        io_xml->read(
          exporting
            iv_name = 'key'
          changing
            cg_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->GET_FILES does not work anymore
*    lt_files = zif_abapgit_object~mo_files->get_files( ).
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

    " Header
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

    " I18n
    loop at lt_files into ls_files where filename cp '*.zn23.i18n*.properties'.

      append initial line to lt_abapgit_files assigning <ls_abapgit_file>.
      <ls_abapgit_file>-filename = ls_files-filename.
      <ls_abapgit_file>-contents = zcl_abapgit_convert=>xstring_to_string_utf8( iv_data = ls_files-data ).

    endloop.

    data lr_i18n_attributes type ref to data.
    data lr_i18n_contents   type ref to data.
    data lr_i18n_locales    type ref to data.

    create data lr_i18n_attributes type ('/NEPTUNE/I18N_GA_TT').
    create data lr_i18n_contents   type ('/NEPTUNE/I18N_GC_TT').
    create data lr_i18n_locales    type ('/NEPTUNE/I18N_GL_TT').

    try.
        call method ('/NEPTUNE/CL_I18N')=>('ABAPGIT_DESERIALIZE_ZN23')
          exporting
            iv_key           = lv_key
            it_files         = lt_abapgit_files
            it_table_content = lt_table_content
            ir_attributes    = lr_i18n_attributes
            ir_contents      = lr_i18n_contents
            ir_locales       = lr_i18n_locales.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    endtry.

    ls_table_content-tabname = '/NEPTUNE/I18N_GA'.
    ls_table_content-table_content = lr_i18n_attributes.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/I18N_GC'.
    ls_table_content-table_content = lr_i18n_contents.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/I18N_GL'.
    ls_table_content-table_content = lr_i18n_locales.
    append ls_table_content to lt_table_content.
    clear ls_table_content.


    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
      ls_settings = lo_artifact->get_settings( ).

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

      if ls_settings-transportable is not initial and iv_transport is not initial.

        insert_to_transport(
          io_artifact      = lo_artifact
          iv_transport     = iv_transport
          iv_package       = iv_package
          iv_key1          = lv_key
          iv_artifact_type = ls_settings-artifact_type ).

      endif.

    endif.

  endmethod.


  method zif_abapgit_object~exists.

    rv_bool = abap_true.

  endmethod.


  method zif_abapgit_object~get_comparator.

    return.

  endmethod.


  method zif_abapgit_object~get_deserialize_order.

    return.

  endmethod.


  method zif_abapgit_object~get_deserialize_steps.

    append zif_abapgit_object=>gc_step_id-late to rt_steps.

  endmethod.


  method zif_abapgit_object~get_metadata.

    return.

  endmethod.


  method zif_abapgit_object~is_active.

    rv_active = abap_true.

  endmethod.


  method zif_abapgit_object~is_locked.

    data lo_artifact type ref to /neptune/if_artifact_type.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = ms_item-obj_name ).

  endmethod.


  method zif_abapgit_object~jump.

    return.

  endmethod.


  method zif_abapgit_object~map_filename_to_object.

    return.

  endmethod.


  method zif_abapgit_object~map_object_to_filename.
    return.
  endmethod.


  method zif_abapgit_object~serialize.

    if mv_neptune_i18n_supported = abap_false.
      return.
    endif.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

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

    " Serialize header table
    read table lt_table_content with key tabname = '/NEPTUNE/I18N_GH' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0 and <lt_standard_table> is not initial.
      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).
    endif.

    " Serialize i18n data
    serialize_i18n( lt_table_content ).

  endmethod.
ENDCLASS.
