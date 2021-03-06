!  SVN:$Id: ice_restart.F90 741 2013-09-26 18:55:02Z dbailey $
!=======================================================================

! Read and write ice model restart files using netCDF or binary
! interfaces.

! authors David A Bailey, NCAR

      module ice_restart

      use ice_broadcast
      use ice_exit, only: abort_ice
      use ice_fileunits
      use ice_kinds_mod
      use ice_restart_shared, only: &
          restart, restart_ext, restart_dir, restart_file, pointer_file, &
          runid, runtype, use_restart_time, restart_format, lenstr
      use ice_state, only: tr_iage, tr_aero, tr_lvl, tr_FY, tr_brine, &
                           tr_pond_cesm, tr_pond_lvl, tr_pond_topo
      use ice_zbgc_shared, only: tr_bgc_N_sk, tr_bgc_C_sk, tr_bgc_Nit_sk, &
                           tr_bgc_Sil_sk, tr_bgc_DMSPp_sk, tr_bgc_DMS_sk, &
                           tr_bgc_chl_sk, tr_bgc_DMSPd_sk, tr_bgc_Am_sk, &
                           skl_bgc

      implicit none
      private
      public :: init_restart_write, init_restart_read, &
                read_restart_field, write_restart_field, final_restart
      save

!=======================================================================

      contains

!=======================================================================

! Sets up restart file for reading.
! author David A Bailey, NCAR

      subroutine init_restart_read(ice_ic)

      use ice_calendar, only: istep0, istep1, time, time_forc, npt
      use ice_communicate, only: my_task, master_task
      use ice_dyn_shared, only: kdyn
      use ice_read_write, only: ice_open

      character(len=char_len_long), intent(in), optional :: ice_ic

      ! local variables

      character(len=char_len_long) :: &
         filename, filename0

      integer (kind=int_kind) :: &
         n, &                    ! loop indices
         iignore                 ! dummy variable

      real (kind=real_kind) :: &
         rignore                 ! dummy variable

      character(len=char_len_long) :: &
         string1, string2

      if (present(ice_ic)) then 
         filename = trim(ice_ic)
      else
         if (my_task == master_task) then
            open(nu_rst_pointer,file=pointer_file)
            read(nu_rst_pointer,'(a)') filename0
            filename = trim(filename0)
            close(nu_rst_pointer)
            write(nu_diag,*) 'Read ',pointer_file(1:lenstr(pointer_file))
         endif
         call broadcast_scalar(filename, master_task)
      endif

      if (my_task == master_task) then
         write(nu_diag,*) 'Using restart dump=', trim(filename)
         call ice_open(nu_restart,trim(filename),0)
         if (use_restart_time) then
            read (nu_restart) istep0,time,time_forc
         else
            read (nu_restart) iignore,rignore,rignore ! use namelist values
         endif
         write(nu_diag,*) 'Restart read at istep=',istep0,time,time_forc
      endif

      call broadcast_scalar(istep0,master_task)
      call broadcast_scalar(time,master_task)
      call broadcast_scalar(time_forc,master_task)
      
      istep1 = istep0

      ! Supplemental restart files

      if (kdyn == 2) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('eap restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.eap', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_eap,filename,0)

         if (my_task == master_task) then
            read (nu_restart_eap) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_iage) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('iage restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.iage', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_age,filename,0)

         if (my_task == master_task) then
            read (nu_restart_age) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_FY) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('FY restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.FY', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_FY,filename,0)

         if (my_task == master_task) then
            read (nu_restart_FY) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_lvl) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('lvl restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.lvl', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_lvl,filename,0)

         if (my_task == master_task) then
            read (nu_restart_lvl) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_pond_cesm) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('pond_cesm restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.pond_cesm', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_pond,filename,0)

         if (my_task == master_task) then
            read (nu_restart_pond) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_pond_lvl) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('pond_lvl restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.pond_lvl', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_pond,filename,0)

         if (my_task == master_task) then
            read (nu_restart_pond) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_pond_topo) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('pond_topo restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.pond_topo', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_pond,filename,0)

         if (my_task == master_task) then
            read (nu_restart_pond) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_brine) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('brine restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.brine', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_hbrine,filename,0)

         if (my_task == master_task) then
            read (nu_restart_hbrine) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (skl_bgc) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('bgc restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.bgc', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_bgc,filename,0)

         if (my_task == master_task) then
            read (nu_restart_bgc) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      if (tr_aero) then
         if (my_task == master_task) then
            n = index(filename0,trim(restart_file))
            if (n == 0) call abort_ice('aero restart: filename discrepancy')
            string1 = trim(filename0(1:n-1))
            string2 = trim(filename0(n+lenstr(restart_file):lenstr(filename0)))
            write(filename,'(a,a,a,a)') &
               string1(1:lenstr(string1)), &
               restart_file(1:lenstr(restart_file)),'.aero', &
               string2(1:lenstr(string2))
         endif

         if (restart_format == 'bin') &
            call ice_open(nu_restart_aero,filename,0)

         if (my_task == master_task) then
            read (nu_restart_aero) iignore,rignore,rignore
            write(nu_diag,*) 'Reading ',filename(1:lenstr(filename))
         endif
      endif

      ! if runid is bering then need to correct npt for istep0
      if (trim(runid) == 'bering') then
         npt = npt - istep0
      endif

      end subroutine init_restart_read

!=======================================================================

! Sets up restart file for writing.
! author David A Bailey, NCAR

      subroutine init_restart_write(filename_spec)

      use ice_calendar, only: sec, month, mday, nyr, istep1, &
                              time, time_forc, year_init
      use ice_communicate, only: my_task, master_task
      use ice_dyn_shared, only: kdyn
      use ice_read_write, only: ice_open

      character(len=char_len_long), intent(in), optional :: filename_spec

      ! local variables

      integer (kind=int_kind) :: &
          iyear, imonth, iday     ! year, month, day

      character(len=char_len_long) :: filename

      ! construct path/file
      if (present(filename_spec)) then
         filename = trim(filename_spec)
      else
         iyear = nyr + year_init - 1
         imonth = month
         iday = mday
      
         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.', &
              iyear,'-',month,'-',mday,'-',sec
      end if
        
      ! write pointer (path/file)
      if (my_task == master_task) then
         open(nu_rst_pointer,file=pointer_file)
         write(nu_rst_pointer,'(a)') filename
         close(nu_rst_pointer)
      endif

      if (restart_format == 'bin') then

         call ice_open(nu_dump,filename,0)

         if (my_task == master_task) then
            write(nu_dump) istep1,time,time_forc
         endif

      endif

      if (my_task == master_task) then
         write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
      endif

      if (kdyn == 2) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.eap.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_eap,filename,0)

         if (my_task == master_task) then
           write(nu_dump_eap) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_FY) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.FY.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_FY,filename,0)

         if (my_task == master_task) then
           write(nu_dump_FY) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_iage) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.iage.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_age,filename,0)

         if (my_task == master_task) then
           write(nu_dump_age) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_lvl) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.lvl.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_lvl,filename,0)

         if (my_task == master_task) then
           write(nu_dump_lvl) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_pond_cesm) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.pond_cesm.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_pond,filename,0)

         if (my_task == master_task) then
           write(nu_dump_pond) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_pond_lvl) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.pond_lvl.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_pond,filename,0)

         if (my_task == master_task) then
           write(nu_dump_pond) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_pond_topo) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.pond_topo.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_pond,filename,0)

         if (my_task == master_task) then
           write(nu_dump_pond) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_brine) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.brine.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_hbrine,filename,0)

         if (my_task == master_task) then
           write(nu_dump_hbrine) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (skl_bgc) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.bgc.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_bgc,filename,0)

         if (my_task == master_task) then
           write(nu_dump_bgc) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      if (tr_aero) then

         write(filename,'(a,a,a,i4.4,a,i2.2,a,i2.2,a,i5.5)') &
              restart_dir(1:lenstr(restart_dir)), &
              restart_file(1:lenstr(restart_file)),'.aero.', &
              iyear,'-',month,'-',mday,'-',sec

         ! begin writing restart data

         if (restart_format == 'bin') &
            call ice_open(nu_dump_aero,filename,0)

         if (my_task == master_task) then
           write(nu_dump_aero) istep1,time,time_forc
           write(nu_diag,*) 'Writing ',filename(1:lenstr(filename))
         endif

      endif

      end subroutine init_restart_write

!=======================================================================

! Reads a single restart field
! author David A Bailey, NCAR

      subroutine read_restart_field(nu,nrec,work,atype,vname,ndim3, &
                                    diag, field_loc, field_type)

      use ice_blocks, only: nx_block, ny_block
      use ice_domain_size, only: max_blocks
      use ice_read_write, only: ice_read, ice_read_ext

      integer (kind=int_kind), intent(in) :: &
           nu            , & ! unit number
           ndim3         , & ! third dimension
           nrec              ! record number (0 for sequential access)

      real (kind=dbl_kind), dimension(nx_block,ny_block,ndim3,max_blocks), &
           intent(inout) :: &
           work              ! input array (real, 8-byte)

      character (len=4), intent(in) :: &
           atype             ! format for output array
                             ! (real/integer, 4-byte/8-byte)

      logical (kind=log_kind), intent(in) :: &
           diag              ! if true, write diagnostic output

      character (len=*), intent(in) :: vname

      integer (kind=int_kind), optional, intent(in) :: &
           field_loc, &      ! location of field on staggered grid
           field_type        ! type of field (scalar, vector, angle)

      ! local variables

      integer (kind=int_kind) :: &
        n,     &      ! number of dimensions for variable
        varid, &      ! variable id
        status        ! status variable from netCDF routine

      real (kind=dbl_kind), dimension(nx_block,ny_block,max_blocks) :: &
           work2              ! input array (real, 8-byte)

      if (restart_format == 'bin') then
         write(nu_diag,*) 'vname ',trim(vname)
         if (present(field_loc)) then
            do n=1,ndim3
               if (restart_ext) then
                  call ice_read_ext(nu,nrec,work2,atype,diag,field_loc,field_type)
               else
                  call ice_read(nu,nrec,work2,atype,diag,field_loc,field_type)
               endif
               work(:,:,n,:) = work2(:,:,:)
            enddo
         else
            do n=1,ndim3
               if (restart_ext) then
                  call ice_read_ext(nu,nrec,work2,atype,diag)
               else
                  call ice_read(nu,nrec,work2,atype,diag)
               endif
               work(:,:,n,:) = work2(:,:,:)
            enddo
         endif
      else
         call abort_ice('Invalid restart_format: '//restart_format)
      endif

      end subroutine read_restart_field
      
!=======================================================================

! Writes a single restart field.
! author David A Bailey, NCAR

      subroutine write_restart_field(nu,nrec,work,atype,vname,ndim3,diag)

      use ice_blocks, only: nx_block, ny_block
      use ice_domain_size, only: max_blocks
      use ice_read_write, only: ice_write, ice_write_ext

      integer (kind=int_kind), intent(in) :: &
           nu            , & ! unit number
           ndim3         , & ! third dimension
           nrec              ! record number (0 for sequential access)

      real (kind=dbl_kind), dimension(nx_block,ny_block,ndim3,max_blocks), &
           intent(in) :: &
           work              ! input array (real, 8-byte)

      character (len=4), intent(in) :: &
           atype             ! format for output array
                             ! (real/integer, 4-byte/8-byte)

      logical (kind=log_kind), intent(in) :: &
           diag              ! if true, write diagnostic output

      character (len=*), intent(in)  :: vname

      ! local variables

      integer (kind=int_kind) :: &
        n,     &      ! dimension counter
        varid, &      ! variable id
        status        ! status variable from netCDF routine

      real (kind=dbl_kind), dimension(nx_block,ny_block,max_blocks) :: &
           work2              ! input array (real, 8-byte)

      if (restart_format == 'bin') then
         do n=1,ndim3
            work2(:,:,:) = work(:,:,n,:)
            if (restart_ext) then
               call ice_write_ext(nu,nrec,work2,atype,diag)
            else
               call ice_write(nu,nrec,work2,atype,diag)
            endif
         enddo
      else
         call abort_ice('Invalid restart_format: '//restart_format)
      endif

      end subroutine write_restart_field

!=======================================================================

! Finalize the restart file.
! author David A Bailey, NCAR

      subroutine final_restart()

      use ice_calendar, only: istep1, time, time_forc
      use ice_communicate, only: my_task, master_task

      integer (kind=int_kind) :: status

      if (restart_format == 'bin') then
         if (my_task == master_task) close(nu_dump)
         if (my_task == master_task .and. tr_aero) close(nu_dump_aero)
         if (my_task == master_task .and. tr_iage) close(nu_dump_age)
         if (my_task == master_task .and. tr_FY) close(nu_dump_FY)
         if (my_task == master_task .and. tr_lvl) close(nu_dump_lvl)
         if (my_task == master_task .and. tr_pond_cesm) close(nu_dump_pond)
         if (my_task == master_task .and. tr_pond_lvl) close(nu_dump_pond)
         if (my_task == master_task .and. tr_pond_topo) close(nu_dump_pond)
      endif

      if (my_task == master_task) &
         write(nu_diag,*) 'Restart read/written ',istep1,time,time_forc

      end subroutine final_restart

!=======================================================================

      end module ice_restart

!=======================================================================
