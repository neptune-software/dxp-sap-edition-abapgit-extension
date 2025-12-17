class zcl_abapgit_object_zn18 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
  protected section.
private section.

  types:
    begin of ty_mapping,
                        key type tadir-obj_name,
                        name type string,
                       end of ty_mapping .
  types:
    ty_mapping_tt type standard table of ty_mapping with key key .
  types:
    ty_t_mime_t type standard table of /neptune/mime_t with non-unique default key .
  types:
    begin of ty_lcl_mime.
            include type /neptune/mime.
    types: file_name      type string,
      end of ty_lcl_mime .
  types:
    ty_tt_lcl_mime type standard table of ty_lcl_mime with non-unique default key .

  constants GC_MIME_TABLE type TABNAME value '/NEPTUNE/MIME'. "#EC NOTEXT
  constants GC_MIME_T_TABLE type TABNAME value '/NEPTUNE/MIME_T'. "#EC NOTEXT
  class ZCL_NEPTUNE_ABAPGIT_UTILITIES definition load .
  class-data GT_MAPPING type ZCL_NEPTUNE_ABAPGIT_UTILITIES=>TY_MAPPING_TT .
  data MV_ARTIFACT_TYPE type /NEPTUNE/ARTIFACT_TYPE .

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
  methods DESERIALIZE_MIME_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
    raising
      ZCX_ABAPGIT_EXCEPTION .
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
  methods GET_FULL_FILE_PATH
    importing
      !IV_PARENT type /NEPTUNE/MIME_T-PARENT
      !IT_MIME_T type TY_T_MIME_T
    returning
      value(RV_PATH) type STRING .
  interface /NEPTUNE/IF_ARTIFACT_TYPE load .
  methods SERIALIZE_MIME_TABLE
    importing
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT
      !IT_MIME_T type TY_T_MIME_T optional
    raising
      ZCX_ABAPGIT_EXCEPTION .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN18 IMPLEMENTATION.


  method deserialize_mime_table.

    data lt_lcl_mime type ty_tt_lcl_mime.
    data ls_lcl_mime like line of lt_lcl_mime.

    data lt_mime type standard table of /neptune/mime with default key.
    data ls_mime like line of lt_mime.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_mime ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_mime into ls_lcl_mime.

      move-corresponding ls_lcl_mime to ls_mime.

      read table it_files into ls_file with key filename = ls_lcl_mime-file_name.
      if sy-subrc = 0.

        ls_mime-data = ls_file-data.

      endif.
      append ls_mime to lt_mime.
    endloop.
*
    <lt_tab> = lt_mime.

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


  method get_full_file_path.

    data lv_parent type /neptune/mime_t-parent.

    field-symbols <ls_mime_t> like line of it_mime_t.

    lv_parent = iv_parent.

    while lv_parent is not initial.
      read table it_mime_t assigning <ls_mime_t> with key guid = lv_parent.
      if sy-subrc = 0.
        concatenate <ls_mime_t>-name rv_path into rv_path separated by '_'.
        if <ls_mime_t>-parent is initial and <ls_mime_t>-guid <> /neptune/cl_nad_cockpit=>media_folder-media_pack.
          concatenate 'Media Library' rv_path into rv_path separated by '_'.
        endif.
        lv_parent = <ls_mime_t>-parent.
      else.
        clear lv_parent.
      endif.
    endwhile.

  endmethod.


  method get_values_from_filename.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.
    data lv_key type /neptune/artifact_key.
    data lv_name type string.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
      split ls_comp at zcl_neptune_abapgit_utilities=>mc_name_separator into lv_name lv_key.
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


  method serialize_mime_table.

    data lt_lcl_mime type ty_tt_lcl_mime.
    data ls_lcl_mime like line of lt_lcl_mime.

    data lt_mime type standard table of /neptune/mime with default key.
    data ls_mime like line of lt_mime.
    data ls_mime_t like line of it_mime_t.

    data: ls_file type zif_abapgit_git_definitions=>ty_file,
          lv_guid type string.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_mime = <lt_standard_table>.

    read table it_mime_t into ls_mime_t with key guid = iv_key. "#EC CI_SUBRC

    loop at lt_mime into ls_mime.
      move-corresponding ls_mime to ls_lcl_mime.
      " clear the image from this field because the image will be its own file
      clear ls_lcl_mime-data.

      lv_guid = ls_mime-guid.

      concatenate iv_key
                  ms_item-obj_type
                  is_table_content-tabname into ls_file-filename separated by '.'.

      replace all occurrences of '/' in ls_file-filename with '#'.

      concatenate ls_file-filename lv_guid  into ls_file-filename separated by zcl_neptune_abapgit_utilities=>mc_name_separator.
      concatenate ls_file-filename ls_mime-name into ls_file-filename separated by '.'.

      concatenate ls_mime_t-name ls_file-filename into ls_file-filename separated by zcl_neptune_abapgit_utilities=>mc_name_separator.

      translate ls_file-filename to lower case.

      ls_file-path = '/'.
      ls_file-data = ls_mime-data.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*      zif_abapgit_object~mo_files->add( ls_file ).
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
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
      endif.

      ls_lcl_mime-file_name = ls_file-filename.

      append ls_lcl_mime to lt_lcl_mime.
    endloop.

    serialize_table(
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_mime ).


  endmethod.


  method serialize_table.

    data: lo_ajson type ref to zcl_abapgit_ajson,
          lx_ajson type ref to zcx_abapgit_ajson_error,
          lv_json  type string,
          ls_file  type zif_abapgit_git_definitions=>ty_file.

    data lx_ex type ref to zcx_abapgit_exception.

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

        ls_file-path = '/'.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
        ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*        zif_abapgit_object~mo_files->add( ls_file ).
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

      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      catch zcx_abapgit_exception into lx_ex.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

  endmethod.


  method zif_abapgit_object~changed_by.
    return.
  endmethod.


  method zif_abapgit_object~delete.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lv_key1          type /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key1 = ms_item-obj_name.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

  endmethod.


  method zif_abapgit_object~deserialize.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data lo_artifact type ref to /neptune/if_artifact_type.

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.
    data lv_name    type /neptune/artifact_name.
    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

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

    loop at lt_files into ls_files where filename cp '*.json'.

      get_values_from_filename(
        exporting
          is_filename = ls_files-filename
        importing
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      case lv_tabname.
        when gc_mime_table.
          deserialize_mime_table(
            is_file  = ls_files
            ir_data  = lr_data
            it_files = lt_files ).

        when others.
          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            ir_data    = lr_data ).
      endcase.

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      append ls_table_content to lt_table_content.
      clear ls_table_content.

    endloop.

    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

      lo_artifact->delete_artifact(
        iv_key1     = lv_key
        iv_devclass = iv_package ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

      lo_artifact->update_tadir_entry(
          iv_key1          = lv_key
          iv_devclass      = iv_package
          iv_artifact_name = lv_name ).

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

    field-symbols: <iv_filename> type clike.

    assign ('IV_FILENAME') to <iv_filename>.
    if sy-subrc <> 0.
      assign ('IV_ITEM_PART_OF_FILENAME') to <iv_filename>.
    endif.

    zcl_neptune_abapgit_utilities=>map_filename_to_object(
      exporting iv_item_part_of_filename = <iv_filename>
*               iv_path                  = iv_path
*               io_dot                   = io_dot
*               iv_package               = iv_package
      changing cs_item                  = cs_item
               ct_mapping               = gt_mapping ).


  endmethod.


  method zif_abapgit_object~map_object_to_filename.

    data lv_key                type /neptune/artifact_key.
    data lv_modular_file_parts type abap_bool.
    data lv_ext                type string.
    data lv_extra              type string.

    field-symbols: <cv_item_part_of_filename> type clike,
                   <iv_ext>                   type clike,
                   <iv_extra>                 type clike.

    assign ('CV_FILENAME') to <cv_item_part_of_filename>.
    if sy-subrc <> 0.
      " new signature starting with abapGit v1.132.0
      assign ('CV_ITEM_PART_OF_FILENAME') to <cv_item_part_of_filename>.
      assign ('IV_EXT') to <iv_ext>.
      assign ('IV_EXTRA') to <iv_extra>.
      lv_ext = <iv_ext>.
      lv_extra = <iv_extra>.
      lv_modular_file_parts = abap_true.
    endif.

    lv_key = is_item-obj_name.

    zcl_neptune_abapgit_utilities=>map_object_to_filename(
      exporting is_item                  = is_item
                it_mapping               = gt_mapping
                iv_modular_file_parts    = lv_modular_file_parts
                iv_ext                   = lv_ext
                iv_extra                 = lv_extra
                iv_artifact_key          = lv_key
                iv_artifact_type         = /neptune/if_artifact_type=>gc_artifact_type-mime_folder
      changing  cv_item_part_of_filename = <cv_item_part_of_filename> ).

  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    field-symbols: <lt_standard_table> type standard table.

    field-symbols <lt_mime_t> type ty_t_mime_t.

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

* get folders table
    read table lt_table_content into ls_table_content with key tabname = gc_mime_t_table.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_mime_t>.
    endif.

    check <lt_mime_t> is assigned.

* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.

      check sy-subrc = 0 and <lt_standard_table> is not initial.

      case ls_table_content-tabname.
        when gc_mime_table.
          serialize_mime_table(
            iv_key           = lv_key
            is_table_content = ls_table_content
            it_mime_t        = <lt_mime_t> ).

        when others.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      endcase.

    endloop.

  endmethod.
ENDCLASS.
