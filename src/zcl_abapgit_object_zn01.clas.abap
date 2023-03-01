class ZCL_ABAPGIT_OBJECT_ZN01 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN01 IMPLEMENTATION.


method ZIF_ABAPGIT_OBJECT~CHANGED_BY.
endmethod.


method ZIF_ABAPGIT_OBJECT~DELETE.
endmethod.


method ZIF_ABAPGIT_OBJECT~DESERIALIZE.
endmethod.


method ZIF_ABAPGIT_OBJECT~EXISTS.
  rv_bool = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_METADATA.
endmethod.


method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
  rv_active = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~IS_LOCKED.
endmethod.


method ZIF_ABAPGIT_OBJECT~JUMP.
endmethod.


method ZIF_ABAPGIT_OBJECT~SERIALIZE.
endmethod.
ENDCLASS.
