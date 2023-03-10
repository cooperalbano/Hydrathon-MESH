!-------------------------------------- LICENCE BEGIN ------------------------------------
!Environment Canada - Atmospheric Science and Technology License/Disclaimer,
!                     version 3; Last Modified: May 7, 2008.
!This is free but copyrighted software; you can use/redistribute/modify it under the terms
!of the Environment Canada - Atmospheric Science and Technology License/Disclaimer
!version 3 or (at your option) any later version that should be found at:
!http://collaboration.cmc.ec.gc.ca/science/rpn.comm/license.html
!
!This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
!without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!See the above mentioned License/Disclaimer for more details.
!You should have received a copy of the License/Disclaimer along with this software;
!if not, you can write to: EC-RPN COMM Group, 2121 TransCanada, suite 500, Dorval (Quebec),
!CANADA, H9P 1J3; or send e-mail to service.rpn@ec.gc.ca
!-------------------------------------- LICENCE END --------------------------------------

!/@*
function sfc_nml2(F_namelist) result(F_istat)
   use str_mod, only: str_concat
   use sfc_options
   use sfcbus_mod
   use cpl_itf, only: cpl_nml
   use sfclayer_mod, only: sl_put, SL_OK
   implicit none
#include <arch_specific.hf>
   !@objective Set defaults values and read surface namelist
   !@Arguments
   ! F_namelist    File name containing the namelists to read
   character(len=*), intent(in) :: F_namelist
   !@return
   integer :: F_istat
   !*@/

#include <msg.h>
#include <rmnlib_basics.hf>
#include <WhiteBoard.hf>
#include <clib_interface_mu.hf>
   include "tebcst.cdk"

   integer, external :: msg_getUnit

   integer, parameter :: SFC_NML_ERR = RMN_ERR
   integer, parameter :: SFC_NML_OK  = RMN_OK + 1
   integer, parameter :: CPL_NML_OK  = 1

   logical :: offline
   integer :: err, unout
   !-------------------------------------------------------------------
   F_istat = SFC_NML_ERR

   err = sfc_options_init()
   if (.not.RMN_IS_OK(err)) return
   err = sfc_nml_read(F_namelist)
   if (.not.RMN_IS_OK(err)) return
   err = sfc_nml_check()
   if (.not.RMN_IS_OK(err)) return
   call sfc_nml_print()
   err = sfc_nml_post_init()
   if (.not.RMN_IS_OK(err)) return

   unout = msg_getUnit(MSG_INFO)
   err   = cpl_nml(F_namelist, unout)
   if (.not.RMN_IS_OK(err)) then
      call msg(MSG_ERROR,'(sfc_nml) Probleme in cpl_nml')
      return
   endif
   cplocn = (err ==  CPL_NML_OK)
   if (cplocn) err = cpl_nml('print', unout)

   F_istat = SFC_NML_OK
   !-------------------------------------------------------------------
   return


contains
   

   function sfc_nml_read(m_namelist) result(m_istat)
      implicit none
      character(len=*), intent(in) :: m_namelist
      integer :: m_istat
      character(len=256) :: msg_S, namelist_S, name_S
      integer :: istat, unf
      !----------------------------------------------------------------
      m_istat = RMN_ERR
      name_S = '(sfc_nml)'
      namelist_S = '&surface_cfgs'

      unf = 0
      istat = clib_isreadok(m_namelist)
      if (RMN_IS_OK(istat)) istat = fnom(unf, m_namelist, 'SEQ+OLD', 0)
      if (.not.RMN_IS_OK(istat)) then
         write(msg_S,'(a,a,a,a)') trim(name_S), &
              ' Using default config, ', &
              'Namelist file Not found/readable: ', trim(m_namelist)
         call msg(MSG_INFO, msg_S)
         m_istat = RMN_OK
         return
      endif

      read(unf, nml=surface_cfgs, iostat=istat)
      if (istat == 0) then     !# Read ok
         m_istat = RMN_OK + 1
      else if (istat < 0) then !# EOF, nml not found
         write(msg_S,'(a,a,a,a,a)') trim(name_S), &
              ' Using default config, Namelist ',&
              trim(namelist_S), ' not available in file: ', trim(m_namelist)
         call msg(MSG_INFO, msg_S)
         m_istat = RMN_OK
      else !# Error
         write(msg_S,'(a,a,a,a,a)') trim(name_S), &
              ' Namelist', trim(namelist_S), &
              ' invalid in file: ', trim(m_namelist)
         call msg(MSG_ERROR, msg_S)
      endif
      istat = fclos(unf)
      !----------------------------------------------------------------
      return
   end function sfc_nml_read


   subroutine sfc_nml_print()
      implicit none
      integer, external :: msg_getUnit
      integer :: unout
      !----------------------------------------------------------------
      unout = msg_getUnit(MSG_INFO)
      if (unout > 0) then
         write(unout, nml=surface_cfgs)
      endif
      !----------------------------------------------------------------
      return
   end subroutine sfc_nml_print


   function sfc_nml_check() result(m_istat)
      use sfc_options, only : nl_svs_default, dp_svs_default
      use svs_configs, only : nl_svs,dl_svs
      implicit none
      integer :: m_istat

      integer :: istat,k,nk
      character(len=512) :: str512
      !----------------------------------------------------------------
      m_istat = RMN_ERR

      istat = clib_toupper(schmsol)
      istat = clib_toupper(schmurb)
      istat = clib_toupper(soiltext)
      istat = clib_toupper(diusst)
      istat = clib_toupper(z0mtype)

      if (.not.any(schmsol == SCHMSOL_OPT)) then
         call str_concat(str512, SCHMSOL_OPT,', ')
         call msg(MSG_ERROR,'(sfc_nml_check) schmsol = '//trim(schmsol)//' : Should be one of: '//trim(str512))
         return
      endif

      if (.not.any(schmurb == SCHMURB_OPT)) then
         call str_concat(str512, SCHMURB_OPT,', ')
         call msg(MSG_ERROR,'(sfc_nml_check) schmurb = '//trim(schmurb)//' : Should be one of: '//trim(str512))
         return
      endif

      if (.not.any(diusst == DIUSST_OPT)) then
         call str_concat(str512, DIUSST_OPT,', ')
         call msg(MSG_ERROR,'(sfc_nml_check) diusst = '//trim(diusst)//' : Should be one of: '//trim(str512))
         return
      endif

      if (.not.any(z0mtype == Z0MTYPE_OPT)) then
         call str_concat(str512, Z0MTYPE_OPT,', ')
         call msg(MSG_ERROR,'(sfc_nml_check) z0mtype = '//trim(z0mtype)//' : Should be one of: '//trim(str512))
         return
      endif

      if ( (min(z0tlat(1), z0tlat(2)) <  0.0)    .or. &
           (max(z0tlat(1), z0tlat(2)) > 90.0)    .or. &
           (z0tlat(1) > z0tlat(2))         )    then
         write(str512,*) z0tlat(1), z0tlat(2)
         call msg(MSG_ERROR, '(sfc_nml_check) zz0tlat = '//trim(str512)//' : should be in 0. to 90. and z0tlat(1) < z0tlat(2)')
         return
      endif

      ! ------ CHECK SVS OPTIONS --------------
      if( schmsol == 'SVS') then
         ! check number of SOIL LEVELS 
         nk=0
         do k=1,size(dp_svs)
            if (dp_svs(k)< 0.) exit
            nk=nk+1
         enddo

         ! USE DEFAULT NUMBER & DEPTH of LAYERS if NOT SPECIFIED
         ! FOR KHYD: the "last soil layer considered during the accumulation of lateral flow and drainage"
         ! (1) if using default layers, and khyd not specified then:
         ! set khyd = last SVS layer
         ! (2) if using default layer and khyd specified, use khyd
         ! (3) if users specifies soil layers, then forced user to specify khyd also.
         if (nk == 0) then
            call msg(MSG_INFO,'(sfc_nml_check) SVS soil layer depth dp_svs NOT SPECIFIED by user, will use DEFAULT VALUE')
            ! default number of soil layers
            nk=nl_svs_default
            ! By default "last soil layer for accumulation of lateral flow and drainage" LEVEL = nk, 
            if ( khyd .le. 1 ) then
                call msg(MSG_INFO,'(sfc_nml_check) Using default SVS configuration with "last hydro drainage/lateral flow layer" level KHYD = last soil layer')
                khyd=nl_svs_default
            else
               call msg(MSG_INFO,'(sfc_nml_check) Using default SVS configuration for soil layer but NOT for "last hydro drainage/lateral flow layer" KHYD')
            endif
            ! default values for depth of SVS values [in meters]
            do k=1,nk
               dp_svs(k) = dp_svs_default(k)
            enddo
         else if ( nk < 3 ) then
            write(str512,*) ' (sfc_nml_check) SVS requires a minimum of 3 soil layers. Only ',nk, ' depths were specified in dp_svs=' , dp_svs(1:nk)
            call msg(MSG_ERROR, str512)
            return
         else if ( nk >= 3 .and. khyd .le. 1 ) then
              write(str512,*) ' (sfc_nml_check)  Last hydro drainage/lateral flow layer level: KHYD needs to be specified by USER because not using DEFAULT SVS set-up'
            call msg(MSG_ERROR, str512)
            return
         endif

         ! CHECK THAT DEPTH IS INCREASING and SAVE NUMBER OF LAYERS
         do k=1,nk-1
            if ( dp_svs(k) >= dp_svs(k+1) ) then 
               write(str512,*) ' (sfc_nml_check) SVS layer depths badly specified: dp_svs(k)=',dp_svs(k),' (k=',k,') should be shallower than dl_svs(k+1)=',dp_svs(k+1),' (k+1=',k+1,')'
               call msg(MSG_ERROR, str512)
               return
            endif
         enddo
         ! Save depth in dl_svs ... to be used by svs
         nl_svs=nk
         if ( .not. allocated(dl_svs) ) allocate( dl_svs(nl_svs) )
         do k=1,nl_svs
            dl_svs(k)=dp_svs(k)
         enddo
         
         if ( khyd > nl_svs ) then
            write(str512, '(a,i3,a,i3)') '(sfc_nml_check) Last hydro drainage/lateral flow layer in SVS khyd=',khyd,' cannot exceed number of SVS soil layers =', nl_svs
            call msg(MSG_ERROR, str512)
            return
         endif

         if (.not.any(soiltext == SOILTEXT_OPT)) then
            call str_concat(str512, SOILTEXT_OPT,', ')
            call msg(MSG_ERROR,'(sfc_nml_check) soiltext = '//trim(soiltext)//' : Should be one of: '//trim(str512))
            return
         endif

      endif


      m_istat = RMN_OK
      !----------------------------------------------------------------
      return
   end function sfc_nml_check


   function sfc_nml_post_init() result(m_istat)
      implicit none
      integer :: m_istat

   include "thermoconsts.inc"

      integer, external :: msg_getUnit
      integer :: istat, unout, options, iverb, idxmax
      character(len=512) :: str512
      !----------------------------------------------------------------
      m_istat = RMN_ERR
      
      !# nsurf nb of surface types (schemes)
      !# phybusinit / gesdict defines nrow = nagg = nsurf+1
      idxmax = max(indx_soil, indx_glacier, indx_water, indx_ice, indx_agrege)
      if (schmurb /= 'NIL') idxmax = max(idxmax, indx_urb)
      nsurf = idxmax - 1

      !# Z0tlat to radians
      z0tlat(:) = z0tlat(:) * PI/180.

      !# Put some sfc options value on th WB for the main physic to access
      options = WB_REWRITE_NONE+WB_IS_LOCAL
      iverb   = wb_verbosity(WB_MSG_INFO)
      istat = WB_OK
      istat = min(wb_put('sfc/icelac', icelac, options), istat)
      istat = min(wb_put('sfc/nclass', nclass, options), istat)
      istat = min(wb_put('sfc/nicelvl', nl, options), istat)
      istat = min(wb_put('sfc/nsurf', nsurf, options), istat)
      istat = min(wb_put('sfc/schmsol', schmsol, options), istat)
      istat = min(wb_put('sfc/schmurb', schmurb, options), istat)
      istat = min(wb_put('sfc/snoalb_anl', snoalb_anl, options), istat)
      iverb = wb_verbosity(iverb)
      if (istat /= WB_OK) then
         call msg(MSG_ERROR, '(sfc_nml) Problem in wb_put')
         return
      endif

      !# Offline special case
      iverb = wb_verbosity(WB_MSG_FATAL)
      istat = wb_get('itf_phy/OFFLINE', offline)
      if (istat /= WB_OK) offline = .false.
      istat = wb_verbosity(iverb)
      if (offline) then
         isba_i1_minval = .false.
         call msg(MSG_INFO,'(sfc_nml_post_init) Offline - forcing isba_i1_minval = .false.')
      endif

      !# Surface Layer module init
      unout = msg_getUnit(MSG_INFO)
      istat = sl_put('stderr', unout)
      if (istat == SL_OK) istat = sl_put('beta', beta)
      if (istat == SL_OK) istat = sl_put('tdiaglim',tdiaglim)
      if (istat /= SL_OK) then
         call msg(MSG_ERROR,'(sfc_nml) Problem initializing the surface layer module')
         return
      endif

      m_istat = RMN_OK
      !----------------------------------------------------------------
      return
   end function sfc_nml_post_init

end function sfc_nml2
