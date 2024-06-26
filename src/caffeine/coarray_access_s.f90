! Copyright (c), The Regents of the University of California
! Terms of use are as specified in LICENSE.txt
submodule(prif:prif_private_s) coarray_access_s
  use iso_c_binding, only: c_loc

  implicit none

contains

  module procedure prif_put
    integer(c_int) :: image
    integer(c_intptr_t) :: remote_base, remote_ptr

    call prif_image_index(coarray_handle, cosubscripts, image_index=image)
    call prif_base_pointer(coarray_handle, image, remote_base)
    remote_ptr = &
        remote_base &
        + (caf_as_int(first_element_addr) &
        - caf_as_int(coarray_handle%info%coarray_data))
    call prif_put_raw( &
        image_num = image, &
        current_image_buffer = c_loc(value), &
        remote_ptr = remote_ptr, &
        size = size(value) * coarray_handle%info%element_length)
  end procedure

  module procedure prif_put_raw
    call caf_put( &
        image = image_num, &
        dest = remote_ptr, &
        src = current_image_buffer, &
        size = size)
  end procedure

  module procedure prif_put_raw_strided
    call unimplemented("prif_put_raw_strided")
  end procedure

  module procedure prif_get
    integer(c_int) :: image
    integer(c_intptr_t) :: remote_base, remote_ptr

    call prif_image_index(coarray_handle, cosubscripts, image_index=image)
    call prif_base_pointer(coarray_handle, image, remote_base)
    remote_ptr = &
        remote_base &
        + (caf_as_int(first_element_addr) &
        - caf_as_int(coarray_handle%info%coarray_data))
    call prif_get_raw( &
        image_num = image, &
        current_image_buffer = c_loc(value), &
        remote_ptr = remote_ptr, &
        size = size(value) * coarray_handle%info%element_length)
  end procedure

  module procedure prif_get_raw
    call caf_get( &
        image = image_num, &
        dest = current_image_buffer, &
        src = remote_ptr, &
        size = size)
  end procedure

  module procedure prif_get_raw_strided
    call unimplemented("prif_get_raw_strided")
  end procedure

end submodule coarray_access_s
