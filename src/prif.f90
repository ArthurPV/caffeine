! Copyright (c), The Regents of the University of California
! Terms of use are as specified in LICENSE.txt
module prif

  use iso_c_binding, only: c_int, c_bool, c_intptr_t, c_intmax_t, c_ptr, c_funptr, c_size_t, c_ptrdiff_t
  use iso_fortran_env, only: atomic_int_kind, atomic_logical_kind

  implicit none

  private
  public :: prif_init
  public :: prif_stop, prif_error_stop, prif_fail_image
  public :: prif_allocate_coarray, prif_allocate, prif_deallocate_coarray, prif_deallocate
  public :: prif_put, prif_put_raw, prif_put_raw_strided, prif_get, prif_get_raw, prif_get_raw_strided
  public :: prif_alias_create, prif_alias_destroy
  public :: prif_lcobound, prif_ucobound, prif_coshape, prif_image_index
  public :: prif_this_image, prif_num_images, prif_failed_images, prif_stopped_images, prif_image_status
  public :: prif_set_context_data, prif_get_context_data, prif_base_pointer, prif_size_bytes
  public :: prif_co_sum, prif_co_max, prif_co_min, prif_co_reduce, prif_co_broadcast
  public :: prif_form_team, prif_change_team, prif_end_team, prif_get_team, prif_team_number
  public :: prif_sync_all, prif_sync_images, prif_sync_team, prif_sync_memory
  public :: prif_lock, prif_unlock
  public :: prif_critical, prif_end_critical
  public :: prif_event_post, prif_event_wait, prif_event_query
  public :: prif_notify_wait
  public :: prif_atomic_add, prif_atomic_and, prif_atomic_or, prif_atomic_xor, prif_atomic_cas, prif_atomic_fetch_add
  public :: prif_atomic_fetch_and, prif_atomic_fetch_or, prif_atomic_fetch_xor, prif_atomic_define, prif_atomic_ref

  type, public :: prif_lock_type
  end type

  type, public :: prif_critical_type
  end type

  type, public :: prif_notify_type
  end type

  type, public :: prif_coarray_handle
    private
    type(handle_data), pointer :: info
  end type

  type, public :: prif_team_type
    private
    type(c_ptr) :: gex_team
    type(c_ptr) :: heap_mspace
    integer(c_intptr_t) :: heap_start
    type(prif_team_type), pointer :: parent_team
    type(handle_data), pointer :: coarrays
  end type

  interface prif_atomic_cas
     module procedure prif_atomic_cas_int
     module procedure prif_atomic_cas_logical
  end interface

  interface prif_atomic_define
     module procedure prif_atomic_define_int
     module procedure prif_atomic_define_logical
  end interface

  interface prif_atomic_ref
     module procedure prif_atomic_ref_int
     module procedure prif_atomic_ref_logical
  end interface

  interface prif_lcobound
     module procedure prif_lcobound_with_dim
     module procedure prif_lcobound_no_dim
  end interface

  interface prif_ucobound
     module procedure prif_ucobound_with_dim
     module procedure prif_ucobound_no_dim
  end interface

  interface prif_this_image

    module subroutine prif_this_image_no_coarray(team, image_index)
      implicit none
      type(prif_team_type), intent(in), optional :: team
      integer(c_int), intent(out) :: image_index
    end subroutine

    module subroutine prif_this_image_with_coarray(coarray_handle, team, cosubscripts)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      type(prif_team_type), intent(in), optional :: team
      integer(c_intmax_t), intent(out) :: cosubscripts(:)
    end subroutine

    module subroutine prif_this_image_with_dim(coarray_handle, dim, team, cosubscript)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_int), intent(in) :: dim
      type(prif_team_type), intent(in), optional :: team
      integer(c_intmax_t), intent(out) :: cosubscript
    end subroutine

  end interface

  interface

    module subroutine prif_init(exit_code)
      implicit none
      integer(c_int), intent(out) :: exit_code
    end subroutine

    module subroutine prif_stop(quiet, stop_code_int, stop_code_char)
      implicit none
      logical(c_bool), intent(in) :: quiet
      integer(c_int), intent(in), optional :: stop_code_int
      character(len=*), intent(in), optional :: stop_code_char
    end subroutine

    module pure subroutine prif_error_stop(quiet, stop_code_int, stop_code_char)
      implicit none
      logical(c_bool), intent(in) :: quiet
      integer(c_int), intent(in), optional :: stop_code_int
      character(len=*), intent(in), optional :: stop_code_char
    end subroutine

    module subroutine prif_fail_image()
      implicit none
    end subroutine

    module subroutine prif_allocate_coarray( &
        lcobounds, ucobounds, lbounds, ubounds, element_length, final_func, coarray_handle, &
        allocated_memory, stat, errmsg, errmsg_alloc)
      implicit none
      integer(kind=c_intmax_t), dimension(:), intent(in) :: lcobounds, ucobounds
      integer(kind=c_intmax_t), dimension(:), intent(in) :: lbounds, ubounds
      integer(kind=c_size_t), intent(in) :: element_length
      type(c_funptr), intent(in) :: final_func
      type(prif_coarray_handle), intent(out) :: coarray_handle
      type(c_ptr), intent(out) :: allocated_memory
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_allocate(size_in_bytes, allocated_memory, stat, errmsg, errmsg_alloc)
      implicit none
      integer(kind=c_size_t) :: size_in_bytes
      type(c_ptr), intent(out) :: allocated_memory
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_deallocate_coarray(coarray_handles, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_coarray_handle), target, intent(in) :: coarray_handles(:)
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_deallocate(mem, stat, errmsg, errmsg_alloc)
      implicit none
      type(c_ptr), intent(in) :: mem
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_put( &
        coarray_handle, cosubscripts, value, first_element_addr, team, team_number, notify_ptr, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_intmax_t), intent(in) :: cosubscripts(:)
      type(*), intent(in), contiguous, target :: value(..)
      type(c_ptr), intent(in) :: first_element_addr
      type(prif_team_type), optional, intent(in) :: team
      integer(c_intmax_t), optional, intent(in) :: team_number
      integer(c_intptr_t), optional, intent(in) :: notify_ptr
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_put_raw(image_num, current_image_buffer, remote_ptr, notify_ptr, size, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      type(c_ptr), intent(in) :: current_image_buffer
      integer(c_intptr_t), intent(in) :: remote_ptr
      integer(c_intptr_t), optional, intent(in) :: notify_ptr
      integer(c_size_t), intent(in) :: size
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_put_raw_strided( &
        image_num, current_image_buffer, remote_ptr, element_size, extent, remote_ptr_stride, &
        current_image_buffer_stride, notify_ptr, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      type(c_ptr), intent(in) :: current_image_buffer
      integer(c_intptr_t), intent(in) :: remote_ptr
      integer(c_size_t), intent(in) :: element_size
      integer(c_size_t), intent(in) :: extent(:)
      integer(c_ptrdiff_t), intent(in) :: remote_ptr_stride(:)
      integer(c_ptrdiff_t), intent(in) :: current_image_buffer_stride(:)
      integer(c_intptr_t), optional, intent(in) :: notify_ptr
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_get( &
        coarray_handle, cosubscripts, first_element_addr, value, team, team_number, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_intmax_t), intent(in) :: cosubscripts(:)
      type(c_ptr), intent(in) :: first_element_addr
      type(*), intent(inout), contiguous, target :: value(..)
      type(prif_team_type), optional, intent(in) :: team
      integer(c_intmax_t), optional, intent(in) :: team_number
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_get_raw(image_num, current_image_buffer, remote_ptr, size, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      type(c_ptr), intent(in) :: current_image_buffer
      integer(c_intptr_t), intent(in) :: remote_ptr
      integer(c_size_t), intent(in) :: size
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_get_raw_strided( &
        image_num, current_image_buffer, remote_ptr, element_size, extent, remote_ptr_stride, current_image_buffer_stride, &
        stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      type(c_ptr), intent(in) :: current_image_buffer
      integer(c_intptr_t), intent(in) :: remote_ptr
      integer(c_size_t), intent(in) :: element_size
      integer(c_size_t), intent(in) :: extent(:)
      integer(c_ptrdiff_t), intent(in) :: remote_ptr_stride(:)
      integer(c_ptrdiff_t), intent(in) :: current_image_buffer_stride(:)
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_alias_create(source_handle, alias_co_lbounds, alias_co_ubounds, alias_handle)
      implicit none
      type(prif_coarray_handle), intent(in) :: source_handle
      integer(c_intmax_t), intent(in) :: alias_co_lbounds(:)
      integer(c_intmax_t), intent(in) :: alias_co_ubounds(:)
      type(prif_coarray_handle), intent(out) :: alias_handle
    end subroutine

    module subroutine prif_alias_destroy(alias_handle)
      implicit none
      type(prif_coarray_handle), intent(in) :: alias_handle
    end subroutine

    module subroutine prif_lcobound_with_dim(coarray_handle, dim, lcobound)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(kind=c_int), intent(in) :: dim
      integer(kind=c_intmax_t), intent(out) :: lcobound
    end subroutine

    module subroutine prif_lcobound_no_dim(coarray_handle, lcobounds)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(kind=c_intmax_t), intent(out) :: lcobounds(:)
    end subroutine

    module subroutine prif_ucobound_with_dim(coarray_handle, dim, ucobound)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(kind=c_int), intent(in) :: dim
      integer(kind=c_intmax_t), intent(out) :: ucobound
    end subroutine

    module subroutine prif_ucobound_no_dim(coarray_handle, ucobounds)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(kind=c_intmax_t), intent(out) :: ucobounds(:)
    end subroutine

    module subroutine prif_coshape(coarray_handle, sizes)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_size_t), intent(out) :: sizes(:)
    end subroutine

    module subroutine prif_image_index(coarray_handle, sub, team, team_number, image_index)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_intmax_t), intent(in) :: sub(:)
      type(prif_team_type), intent(in), optional :: team
      integer(c_int), intent(in), optional :: team_number
      integer(c_int), intent(out) :: image_index
    end subroutine

    module subroutine prif_num_images(team, team_number, image_count)
      implicit none
      type(prif_team_type), intent(in), optional :: team
      integer(c_intmax_t), intent(in), optional :: team_number
      integer(c_int), intent(out) :: image_count
    end subroutine

    module subroutine prif_failed_images(team, failed_images)
      implicit none
      type(prif_team_type), intent(in), optional :: team
      integer(c_int), allocatable, intent(out) :: failed_images(:)
    end subroutine

    module subroutine prif_stopped_images(team, stopped_images)
      implicit none
      type(prif_team_type), intent(in), optional :: team
      integer(c_int), allocatable, intent(out) :: stopped_images(:)
    end subroutine

    module impure elemental subroutine prif_image_status(image, team, image_status)
      implicit none
      integer(c_int), intent(in) :: image
      type(prif_team_type), intent(in), optional :: team
      integer(c_int), intent(out) :: image_status
    end subroutine

    module subroutine prif_set_context_data(coarray_handle, context_data)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      type(c_ptr), intent(in) :: context_data
    end subroutine

    module subroutine prif_get_context_data(coarray_handle, context_data)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      type(c_ptr), intent(out) :: context_data
    end subroutine

    module subroutine prif_base_pointer(coarray_handle, image_num, ptr)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_int), intent(in) :: image_num
      integer(c_intptr_t), intent(out) :: ptr
    end subroutine

    module subroutine prif_size_bytes(coarray_handle, data_size)
      implicit none
      type(prif_coarray_handle), intent(in) :: coarray_handle
      integer(c_size_t), intent(out) :: data_size
    end subroutine

    module subroutine prif_co_sum(a, result_image, stat, errmsg, errmsg_alloc)
      implicit none
      type(*), intent(inout), contiguous, target :: a(..)
      integer(c_int), intent(in), optional :: result_image
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_co_max(a, result_image, stat, errmsg, errmsg_alloc)
      implicit none
      type(*), intent(inout), contiguous, target :: a(..)
      integer(c_int), intent(in), optional :: result_image
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_co_min(a, result_image, stat, errmsg, errmsg_alloc)
      implicit none
      type(*), intent(inout), contiguous, target :: a(..)
      integer(c_int), intent(in), optional :: result_image
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_co_reduce(a, operation, result_image, stat, errmsg, errmsg_alloc)
      implicit none
      type(*), intent(inout), contiguous, target :: a(..)
      type(c_funptr), value :: operation
      integer(c_int), intent(in), optional :: result_image
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_co_broadcast(a, source_image, stat, errmsg, errmsg_alloc)
      implicit none
      type(*), intent(inout), contiguous, target :: a(..)
      integer(c_int), intent(in) :: source_image
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_form_team(team_number, team, new_index, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_intmax_t), intent(in) :: team_number
      type(prif_team_type), intent(out) :: team
      integer(c_int), intent(in), optional :: new_index
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_change_team(team, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_team_type), intent(in) :: team
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_end_team(stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_get_team(level, team)
      implicit none
      integer(c_int), intent(in), optional :: level
      type(prif_team_type), intent(out) :: team
    end subroutine

    module subroutine prif_team_number(team, team_number)
      implicit none
      type(prif_team_type), intent(in), optional :: team
      integer(c_intmax_t), intent(out) :: team_number
    end subroutine

    module subroutine prif_sync_all(stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_sync_images(image_set, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in), optional :: image_set(:)
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_sync_team(team, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_team_type), intent(in) :: team
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_sync_memory(stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_lock(image_num, lock_var_ptr, acquired_lock, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      integer(c_intptr_t), intent(in) :: lock_var_ptr
      logical(c_bool), intent(out), optional :: acquired_lock
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_unlock(image_num, lock_var_ptr, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      integer(c_intptr_t), intent(in) :: lock_var_ptr
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_critical(critical_coarray, stat, errmsg, errmsg_alloc)
      implicit none
      type(prif_coarray_handle), intent(in) :: critical_coarray
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_end_critical(critical_coarray)
      implicit none
      type(prif_coarray_handle), intent(in) :: critical_coarray
    end subroutine

    module subroutine prif_event_post(image_num, event_var_ptr, stat, errmsg, errmsg_alloc)
      implicit none
      integer(c_int), intent(in) :: image_num
      integer(c_intptr_t), intent(in) :: event_var_ptr
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_event_wait(event_var_ptr, until_count, stat, errmsg, errmsg_alloc)
      implicit none
      type(c_ptr), intent(in) :: event_var_ptr
      integer(c_intmax_t), intent(in), optional :: until_count
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_event_query(event_var_ptr, count, stat)
      implicit none
      type(c_ptr), intent(in) :: event_var_ptr
      integer(c_intmax_t), intent(out) :: count
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_notify_wait(notify_var_ptr, until_count, stat, errmsg, errmsg_alloc)
      implicit none
      type(c_ptr), intent(in) :: notify_var_ptr
      integer(c_intmax_t), intent(in), optional :: until_count
      integer(c_int), intent(out), optional :: stat
      character(len=*), intent(inout), optional :: errmsg
      character(len=:), intent(inout), allocatable, optional :: errmsg_alloc
    end subroutine

    module subroutine prif_atomic_add(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_and(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_or(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_xor(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_cas_int(atom_remote_ptr, image_num, old, compare, new, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(out) :: old
      integer(atomic_int_kind), intent(in) :: compare
      integer(atomic_int_kind), intent(in) :: new
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_cas_logical(atom_remote_ptr, image_num, old, compare, new, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      logical(atomic_logical_kind), intent(out) :: old
      logical(atomic_logical_kind), intent(in) :: compare
      logical(atomic_logical_kind), intent(in) :: new
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_fetch_add(atom_remote_ptr, image_num, value, old, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(atomic_int_kind), intent(out) :: old
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_fetch_and(atom_remote_ptr, image_num, value, old, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(atomic_int_kind), intent(out) :: old
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_fetch_or(atom_remote_ptr, image_num, value, old, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(atomic_int_kind), intent(out) :: old
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_fetch_xor(atom_remote_ptr, image_num, value, old, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(atomic_int_kind), intent(out) :: old
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_define_int(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(atomic_int_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_define_logical(atom_remote_ptr, image_num, value, stat)
      implicit none
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      logical(atomic_logical_kind), intent(in) :: value
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_ref_int(value, atom_remote_ptr, image_num, stat)
      implicit none
      integer(atomic_int_kind), intent(out) :: value
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(c_int), intent(out), optional :: stat
    end subroutine

    module subroutine prif_atomic_ref_logical(value, atom_remote_ptr, image_num, stat)
      implicit none
      logical(atomic_logical_kind), intent(out) :: value
      integer(c_intptr_t), intent(in) :: atom_remote_ptr
      integer(c_int), intent(in) :: image_num
      integer(c_int), intent(out), optional :: stat
    end subroutine

  end interface

! Type definitions only relevant to Caffeine internals

  type, private, bind(C) :: handle_data
    private
    type(c_ptr) :: coarray_data
    integer(c_int) :: corank
    integer(c_size_t) :: coarray_size
    integer(c_size_t) :: element_length
    type(c_funptr) :: final_func
    type(c_ptr) :: previous_handle, next_handle
    integer(c_intmax_t) :: lcobounds(15), ucobounds(15)
  end type

end module prif
