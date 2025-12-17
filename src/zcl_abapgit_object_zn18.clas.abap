CLASS zcl_abapgit_object_zn18 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_t_mime_t TYPE STANDARD TABLE OF /neptune/mime_t WITH NON-UNIQUE DEFAULT KEY .
    TYPES:
      BEGIN OF ty_lcl_mime.
            INCLUDE TYPE /neptune/mime.
    TYPES: file_name      TYPE string,
      END OF ty_lcl_mime .
    TYPES:
      ty_tt_lcl_mime TYPE STANDARD TABLE OF ty_lcl_mime WITH NON-UNIQUE DEFAULT KEY .

    CONSTANTS gc_mime_table TYPE tabname VALUE '/NEPTUNE/MIME'. "#EC NOTEXT
    CONSTANTS gc_mime_t_table TYPE tabname VALUE '/NEPTUNE/MIME_T'. "#EC NOTEXT
    CLASS zcl_neptune_abapgit_utilities DEFINITION LOAD .
    CLASS-DATA gt_mapping TYPE zcl_neptune_abapgit_utilities=>ty_mapping_tt .
    DATA mv_artifact_type TYPE /neptune/artifact_type .

    METHODS serialize_table
      IMPORTING
      !iv_tabname TYPE tabname
      !it_table TYPE any
      RAISING
      zcx_abapgit_exception .
    INTERFACE zif_abapgit_git_definitions LOAD .
    METHODS deserialize_mime_table
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !ir_data TYPE REF TO data
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      RAISING
      zcx_abapgit_exception .
    METHODS deserialize_table
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !ir_data TYPE REF TO data
      !iv_tabname TYPE tadir-obj_name
      RAISING
      zcx_abapgit_exception .
    METHODS get_values_from_filename
      IMPORTING
      !is_filename TYPE string
      EXPORTING
      !ev_tabname TYPE tadir-obj_name
      !ev_name TYPE /neptune/artifact_name .
    METHODS get_full_file_path
      IMPORTING
      !iv_parent TYPE /neptune/mime_t-parent
      !it_mime_t TYPE ty_t_mime_t
      RETURNING
      VALUE(rv_path) TYPE string .
    INTERFACE /neptune/if_artifact_type LOAD .
    METHODS serialize_mime_table
      IMPORTING
      !iv_key TYPE /neptune/artifact_key
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content
      !it_mime_t TYPE ty_t_mime_t OPTIONAL
      RAISING
      zcx_abapgit_exception .
ENDCLASS.



CLASS zcl_abapgit_object_zn18 IMPLEMENTATION.


  METHOD deserialize_mime_table.

    DATA lt_lcl_mime TYPE ty_tt_lcl_mime.
    DATA ls_lcl_mime LIKE LINE OF lt_lcl_mime.

    DATA lt_mime TYPE STANDARD TABLE OF /neptune/mime WITH DEFAULT KEY.
    DATA ls_mime LIKE LINE OF lt_mime.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_mime ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_mime INTO ls_lcl_mime.

      MOVE-CORRESPONDING ls_lcl_mime TO ls_mime.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_mime-file_name.
      IF sy-subrc = 0.

        ls_mime-data = ls_file-data.

      ENDIF.
      APPEND ls_mime TO lt_mime.
    ENDLOOP.
*
    <lt_tab> = lt_mime.

  ENDMETHOD.


  METHOD deserialize_table.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA lt_table_content TYPE REF TO data.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    CREATE DATA lt_table_content TYPE STANDARD TABLE OF (iv_tabname) WITH NON-UNIQUE DEFAULT KEY.
    ASSIGN lt_table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

        lo_ajson->zif_abapgit_ajson~to_abap( EXPORTING iv_corresponding = abap_true
                                             IMPORTING ev_container     = <lt_standard_table> ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    <lt_tab> = <lt_standard_table>.

  ENDMETHOD.


  METHOD get_full_file_path.

    DATA lv_parent TYPE /neptune/mime_t-parent.

    FIELD-SYMBOLS <ls_mime_t> LIKE LINE OF it_mime_t.

    lv_parent = iv_parent.

    WHILE lv_parent IS NOT INITIAL.
      READ TABLE it_mime_t ASSIGNING <ls_mime_t> WITH KEY guid = lv_parent.
      IF sy-subrc = 0.
        CONCATENATE <ls_mime_t>-name rv_path INTO rv_path SEPARATED BY '_'.
        IF <ls_mime_t>-parent IS INITIAL AND <ls_mime_t>-guid <> /neptune/cl_nad_cockpit=>media_folder-media_pack.
          CONCATENATE 'Media Library' rv_path INTO rv_path SEPARATED BY '_'.
        ENDIF.
        lv_parent = <ls_mime_t>-parent.
      ELSE.
        CLEAR lv_parent.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD get_values_from_filename.

    DATA lt_comp TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA ls_comp LIKE LINE OF lt_comp.
    DATA lv_key TYPE /neptune/artifact_key.
    DATA lv_name TYPE string.

    SPLIT is_filename AT '.' INTO TABLE lt_comp.

    READ TABLE lt_comp INTO ls_comp INDEX 1.
    IF sy-subrc = 0.
      SPLIT ls_comp AT zcl_neptune_abapgit_utilities=>mc_name_separator INTO lv_name lv_key.
      TRANSLATE lv_name TO UPPER CASE.
      ev_name = lv_name.
    ENDIF.

    READ TABLE lt_comp INTO ls_comp INDEX 3.
    IF sy-subrc = 0.
      REPLACE ALL OCCURRENCES OF '#' IN ls_comp WITH '/'.
      TRANSLATE ls_comp TO UPPER CASE.
      ev_tabname = ls_comp.
    ENDIF.

  ENDMETHOD.


  METHOD serialize_mime_table.

    DATA lt_lcl_mime TYPE ty_tt_lcl_mime.
    DATA ls_lcl_mime LIKE LINE OF lt_lcl_mime.

    DATA lt_mime TYPE STANDARD TABLE OF /neptune/mime WITH DEFAULT KEY.
    DATA ls_mime LIKE LINE OF lt_mime.
    DATA ls_mime_t LIKE LINE OF it_mime_t.

    DATA: ls_file TYPE zif_abapgit_git_definitions=>ty_file,
          lv_guid TYPE string.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_mime = <lt_standard_table>.

    READ TABLE it_mime_t INTO ls_mime_t WITH KEY guid = iv_key. "#EC CI_SUBRC

    LOOP AT lt_mime INTO ls_mime.
      MOVE-CORRESPONDING ls_mime TO ls_lcl_mime.
      " clear the image from this field because the image will be its own file
      CLEAR ls_lcl_mime-data.

      lv_guid = ls_mime-guid.

      CONCATENATE iv_key
                  ms_item-obj_type
                  is_table_content-tabname INTO ls_file-filename SEPARATED BY '.'.

      REPLACE ALL OCCURRENCES OF '/' IN ls_file-filename WITH '#'.

      CONCATENATE ls_file-filename lv_guid  INTO ls_file-filename SEPARATED BY zcl_neptune_abapgit_utilities=>mc_name_separator.
      CONCATENATE ls_file-filename ls_mime-name INTO ls_file-filename SEPARATED BY '.'.

      CONCATENATE ls_mime_t-name ls_file-filename INTO ls_file-filename SEPARATED BY zcl_neptune_abapgit_utilities=>mc_name_separator.

      TRANSLATE ls_file-filename TO LOWER CASE.

      ls_file-path = '/'.
      ls_file-data = ls_mime-data.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*      zif_abapgit_object~mo_files->add( ls_file ).
      " for version 1.125.0
      ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
      IF <lr_object_files> IS NOT ASSIGNED.
        " for version 1.126.0
        ASSIGN ('MO_FILES') TO <lr_object_files>.
      ENDIF.

      IF <lr_object_files> IS ASSIGNED.
        CALL METHOD <lr_object_files>->add
          EXPORTING
            is_file = ls_file.
      ELSE.
        CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname INTO lv_message SEPARATED BY space.
        zcx_abapgit_exception=>raise( lv_message ).
      ENDIF.

      ls_lcl_mime-file_name = ls_file-filename.

      APPEND ls_lcl_mime TO lt_lcl_mime.
    ENDLOOP.

    serialize_table(
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_mime ).


  ENDMETHOD.


  METHOD serialize_table.

    DATA: lo_ajson TYPE REF TO zcl_abapgit_ajson,
          lx_ajson TYPE REF TO zcx_abapgit_ajson_error,
          lv_json  TYPE string,
          ls_file  TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lx_ex TYPE REF TO zcx_abapgit_exception.

    DATA lt_skip_paths TYPE string_table.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

    TRY.
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
        IF lt_skip_paths IS NOT INITIAL.
          lo_ajson = zcl_abapgit_ajson=>create_from(
                        ii_source_json = lo_ajson
                        ii_filter      = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                            it_skip_paths     = lt_skip_paths
                                            iv_pattern_search = abap_true ) ).
        ENDIF.

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
        ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
        IF <lr_object_files> IS NOT ASSIGNED.
          " for version 1.126.0
          ASSIGN ('MO_FILES') TO <lr_object_files>.
        ENDIF.

        IF <lr_object_files> IS ASSIGNED.
          CALL METHOD <lr_object_files>->add
            EXPORTING
              is_file = ls_file.
        ELSE.
          CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name iv_tabname INTO lv_message SEPARATED BY space.
          zcx_abapgit_exception=>raise( lv_message ).
        ENDIF.

      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      CATCH zcx_abapgit_exception INTO lx_ex.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~delete.

    DATA: lo_artifact      TYPE REF TO /neptune/if_artifact_type,
          lv_key1          TYPE /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key1 = ms_item-obj_name.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.
    DATA lv_name    TYPE /neptune/artifact_name.
    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

    TRY.
        io_xml->read(
          EXPORTING
            iv_name = 'key'
          CHANGING
            cg_data = lv_key ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->GET_FILES does not work anymore
*    lt_files = zif_abapgit_object~mo_files->get_files( ).
    " for version 1.125.0
    ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
    IF <lr_object_files> IS NOT ASSIGNED.
      " for version 1.126.0
      ASSIGN ('MO_FILES') TO <lr_object_files>.
    ENDIF.

    IF <lr_object_files> IS ASSIGNED.
      CALL METHOD <lr_object_files>->get_files
        RECEIVING
          rt_files = lt_files.
    ELSE.
      CONCATENATE 'Error deserializing' ms_item-obj_type  ms_item-obj_name lv_key INTO lv_message SEPARATED BY space.
      zcx_abapgit_exception=>raise( lv_message ).
    ENDIF.

    LOOP AT lt_files INTO ls_files WHERE filename CP '*.json'.

      get_values_from_filename(
        EXPORTING
          is_filename = ls_files-filename
        IMPORTING
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      CASE lv_tabname.
        WHEN gc_mime_table.
          deserialize_mime_table(
            is_file  = ls_files
            ir_data  = lr_data
            it_files = lt_files ).

        WHEN OTHERS.
          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            ir_data    = lr_data ).
      ENDCASE.

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      APPEND ls_table_content TO lt_table_content.
      CLEAR ls_table_content.

    ENDLOOP.

    IF lt_table_content IS NOT INITIAL.

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

    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~exists.
    rv_bool = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_comparator.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_deserialize_order.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_deserialize_steps.
    APPEND zif_abapgit_object=>gc_step_id-late TO rt_steps.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_metadata.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_active.
    rv_active = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_locked.

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = ms_item-obj_name ).

  ENDMETHOD.


  METHOD zif_abapgit_object~jump.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~map_filename_to_object.

    FIELD-SYMBOLS: <lv_filename> TYPE clike.

    ASSIGN ('IV_FILENAME') TO <lv_filename>.
    IF sy-subrc <> 0.
      " new signature starting with abapGit v1.132.0
      ASSIGN ('IV_ITEM_PART_OF_FILENAME') TO <lv_filename>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_ITEM_PART_OF_FILENAME assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
    ENDIF.

    zcl_neptune_abapgit_utilities=>map_filename_to_object(
      EXPORTING iv_item_part_of_filename = <lv_filename>
*               iv_path                  = iv_path
*               io_dot                   = io_dot
*               iv_package               = iv_package
      CHANGING cs_item                   = cs_item
               ct_mapping                = gt_mapping ).


  ENDMETHOD.


  METHOD zif_abapgit_object~map_object_to_filename.

    DATA lv_key                TYPE /neptune/artifact_key.
    DATA lv_modular_file_parts TYPE abap_bool.
    DATA lv_ext                TYPE string.
    DATA lv_extra              TYPE string.

    FIELD-SYMBOLS: <lv_item_part_of_filename> TYPE clike,
                   <lv_ext>                   TYPE clike,
                   <lv_extra>                 TYPE clike.

    ASSIGN ('CV_FILENAME') TO <lv_item_part_of_filename>.
    IF sy-subrc <> 0.
      " new signature starting with abapGit v1.132.0
      ASSIGN ('CV_ITEM_PART_OF_FILENAME') TO <lv_item_part_of_filename>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'CV_ITEM_PART_OF_FILENAME assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      ASSIGN ('IV_EXT') TO <lv_ext>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_EXT assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      ASSIGN ('IV_EXTRA') TO <lv_extra>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_EXTRA assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      lv_ext = <lv_ext>.
      lv_extra = <lv_extra>.
      lv_modular_file_parts = abap_true.
    ENDIF.

    lv_key = is_item-obj_name.

    zcl_neptune_abapgit_utilities=>map_object_to_filename(
      EXPORTING is_item                  = is_item
                it_mapping               = gt_mapping
                iv_modular_file_parts    = lv_modular_file_parts
                iv_ext                   = lv_ext
                iv_extra                 = lv_extra
                iv_artifact_key          = lv_key
                iv_artifact_type         = /neptune/if_artifact_type=>gc_artifact_type-mime_folder
      CHANGING  cv_item_part_of_filename = <lv_item_part_of_filename> ).

  ENDMETHOD.


  METHOD zif_abapgit_object~serialize.

    DATA: lo_artifact      TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    FIELD-SYMBOLS: <lt_standard_table> TYPE STANDARD TABLE.

    FIELD-SYMBOLS <lt_mime_t> TYPE ty_t_mime_t.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

    TRY.
        io_xml->add(
          iv_name = 'key'
          ig_data = ms_item-obj_name ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      EXPORTING iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      IMPORTING et_table_content        = lt_table_content ).

* get folders table
    READ TABLE lt_table_content INTO ls_table_content WITH KEY tabname = gc_mime_t_table.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_mime_t>.
    ENDIF.

    CHECK <lt_mime_t> IS ASSIGNED.

* serialize
    LOOP AT lt_table_content INTO ls_table_content.

      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.

      CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

      CASE ls_table_content-tabname.
        WHEN gc_mime_table.
          serialize_mime_table(
            iv_key           = lv_key
            is_table_content = ls_table_content
            it_mime_t        = <lt_mime_t> ).

        WHEN OTHERS.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
