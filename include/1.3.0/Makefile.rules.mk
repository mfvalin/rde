## ====================================================================
## File: RDEINC/Makefile.rules.mk
##

ifeq (,$(CONST_BUILD))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/include Makefile.const.$(RDE_BASE_ARCH).mk)
   endif
   include $(ROOT)/Makefile.const.$(RDE_BASE_ARCH).mk
endif

INCSUFFIXES = $(CONST_RDESUFFIXINC)
SRCSUFFIXES = $(CONST_RDESUFFIXSRC)

.SUFFIXES :
.SUFFIXES : $(INCSUFFIXES) $(SRCSUFFIXES) .o 

## ==== compilation / load macros

RDEFTN2F = rde.ftn2f $(VERBOSE2) $(OMP)
RDEFTN902F90 = rde.ftn2f -f90 $(VERBOSE2) $(OMP)
RDEF77 = rde.f77 $(VERBOSE2)
RDEF90 = rde.f90 $(VERBOSE2)
RDEF90_LD = rde.f90_ld $(VERBOSE2)
RDEFTN77 = rde.ftn77 $(VERBOSE2)
RDEFTN90 = rde.ftn90 $(VERBOSE2)
RDECC = rde.cc $(VERBOSE2)

FTNC77 = export EC_LD_LIBRARY_PATH="" ; $(RDEFTN2F) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) -src
FTNC90 = export EC_LD_LIBRARY_PATH="" ; $(RDEFTN902F90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) -src
FC77 = export EC_LD_LIBRARY_PATH="" ; $(RDEF77) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FC90a = $(RDEF90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FC90 = export EC_LD_LIBRARY_PATH="" ; $(FC90a)
FC95 = $(FC90)
FC03 = $(FC90)

FTNC77FC77 = $(RDEFTN77) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FTNC90FC90 = $(RDEFTN90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src

CC = $(RDECC) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_CFLAGS) -c -src

# PTNC = sed 's/^[[:blank:]].*PROGRAM /      SUBROUTINE /' | sed 's/^[[:blank:]].*program /      subroutine /'  > $*.f


BUILDFC = export EC_INCLUDE_PATH="" ; $(RDEF90_LD) $(RDEALL_LFLAGS) $(RDEALL_LIBPATH)
BUILDCC = export EC_INCLUDE_PATH="" ; $(RDECC)  $(RDEALL_LFLAGS) $(RDEALL_LIBPATH)
BUILDFC_NOMPI = export EC_INCLUDE_PATH="" ; $(RDEF90_LD) $(RDEALL_LFLAGS_NOMPI) $(RDEALL_LIBPATH)
BUILDCC_NOMPI = export EC_INCLUDE_PATH="" ; $(RDECC)  $(RDEALL_LFLAGS_NOMPI) $(RDEALL_LIBPATH)

DORBUILD4BIDONF = \
	mkdir .bidon 2>/dev/null ; cd .bidon ;\
	.rdemakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ;\
	$(FC90a) bidon_$${MAINSUBNAME}.f90 >/dev/null || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	cd ..
DORBUILD4BIDONC = \
	mkdir .bidon 2>/dev/null ; cd .bidon ;\
	.rdemakemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.c ;\
	$(CC) bidon_$${MAINSUBNAME}.c >/dev/null || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.c ;\
	cd ..
DORBUILD4EXTRAOBJ = \
	RBUILD_EXTRA_OBJ1="`ls $${RBUILD_EXTRA_OBJ:-_RDEBUILDNOOBJ_} 2>/dev/null`"
DORBUILD4COMMSTUBS = \
	lRBUILD_COMM_STUBS="" ;\
	if [[ x"$${RBUILD_COMM_STUBS}" != x"" ]] ; then \
	   lRBUILD_COMM_STUBS="-l$${RBUILD_COMM_STUBS}";\
	fi
DORBUILDEXTRALIBS = \
	lRBUILD_EXTRA_LIB="" ;\
	if [[ x"$${RBUILD_EXTRA_LIB}" != x"" ]] ; then \
		for mylib in $${RBUILD_EXTRA_LIB} ; do \
	   	lRBUILD_EXTRA_LIB="$${RBUILD_EXTRA_LIB} -l$${mylib}";\
		done ;\
	fi
DORBUILD4FINALIZE = \
	rm -f .bidon/bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD_EXTRA_OBJ0 = *.o

RBUILD4objMPI = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4MPI)
RBUILD4MPI = \
	status=0 ;\
	$(DORBUILD4BIDONF) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILDEXTRALIBS) ;\
	$(BUILDFC) -mpi -o $@ $${lRBUILD_EXTRA_LIB} $(RDEALL_LIBS) \
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objNOMPI = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4NOMPI)
RBUILD4NOMPI = \
	status=0 ;\
	$(DORBUILD4BIDONF) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILD4COMMSTUBS) ;\
	$(DORBUILDEXTRALIBS) ;\
	$(BUILDFC_NOMPI) -o $@ $${lRBUILD_EXTRA_LIB} $(RDEALL_LIBS) $${lRBUILD_COMM_STUBS}\
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objMPI_C = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4MPI_C)
RBUILD4MPI_C = \
	status=0 ;\
	$(DORBUILD4BIDONC) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILDEXTRALIBS) ;\
	$(BUILDCC)  -mpi -o $@ $${lRBUILD_EXTRA_LIB} $(RDEALL_LIBS) \
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objNOMPI_C = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4NOMPI_C)
RBUILD4NOMPI_C = \
	status=0 ;\
	$(DORBUILD4BIDONC) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILD4COMMSTUBS) ;\
	$(DORBUILDEXTRALIBS) ;\
	$(BUILDCC_NOMPI) -o $@ $${lRBUILD_EXTRA_LIB} $(RDEALL_LIBS) $${lRBUILD_COMM_STUBS}\
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

# ## ==== Legacy

# RBUILD  = s.compile
# RBUILD3MPI = \
# 	status=0 ;\
# 	.rdemakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
# 	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
# 	rm -f bidon_$${MAINSUBNAME}.f90 ;\
# 	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) $(MPI) \
# 		-libpath $(LIBPATH) \
# 		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
# 		-librmn $(RMN_VERSION) \
# 		-libsys $(LIBSYS) \
# 		-codebeta $(CODEBETA) \
# 		-optf "=$(RDE_LFLAGS) $(LFLAGS)"  || status=1 ;\
# 	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
# 	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

# RBUILD3NOMPI = \
# 	status=0 ;\
# 	.rdemakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
# 	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
# 	rm -f bidon_$${MAINSUBNAME}.f90 ;\
# 	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) \
# 		-libpath $(LIBPATH) \
# 		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
# 		-librmn $(RMN_VERSION) \
# 		-libsys $${COMM_stubs1} $(LIBSYS) \
# 		-codebeta $(CODEBETA) \
# 		-optf "=$(RDE_LFLAGS) $(LFLAGS)"  || status=1 ;\
# 	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
# 	if [[ x$${status} == x1 ]] ; then exit 1 ; fi


# RBUILD3NOMPI_C = \
# 	status=0 ;\
# 	.rdemakemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}_c.c ; \
# 	$(MAKE) bidon_$${MAINSUBNAME}_c.o >/dev/null || status=1 ; \
# 	rm -f bidon_$${MAINSUBNAME}_c.c ;\
# 	$(RBUILD) -obj bidon_$${MAINSUBNAME}_c.o -o $@ $(OMP) -conly \
# 		-libpath $(LIBPATH) \
# 		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
# 		-librmn $(RMN_VERSION) \
# 		-libsys $${COMM_stubs1} $(LIBSYS) \
# 		-codebeta $(CODEBETA) \
# 		-optc "=$(RDE_LCFLAGS) $(LCFLAGS)"  || status=1 ;\
# 	rm -f bidon_$${MAINSUBNAME}_c.o 2>/dev/null || true ;\
# 	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

## ==== Implicit Rules

# .ptn.o:
# 	#.ptn.o:
# 	rm -f $*.f
# 	$(FC77) $< && touch $*.f

# .ptn.f:
# 	#.ptn.f:
# 	rm -f $*.f
# 	$(FTNC77) $<

#TODO: .FOR.o
#TODO: .tmpl90.o

.ftn.o:
	#.ftn.o:
	rm -f $*.f
	$(FTNC77FC77) $< && touch $*.f
.ftn.f:
	#.ftn.f:
	rm -f $*.f
	$(FTNC77) $<
.f90.o:
	#.f90.o:
	$(FC90) $<
.F90.o:
	#.F90.o:
	$(FC90) $<
.F95.o:
	#.F95.o:
	$(FC95) $<
.F03.o:
	#.F03.o:
	$(FC03) $<
.f.o:
	#.f.o:
	$(FC77) $<
.ftn90.o:
	#.ftn90.o:
	rm -f $*.f90
	$(FTNC90FC90) $< && touch $*.f90
.cdk90.o:
	#.cdk90.o:
	$(FTNC90FC90) $< && touch $*.f90
.cdk90.f90:
	#.cdk90.f90:
	rm -f $*.f90
	$(FTNC90) $<
.ftn90.f90:
	#.ftn90.f90:
	rm -f $*.f90
	$(FTNC90) $<

.c.o:
	#.c.o:
	$(CC) $<

# .s.o:
# 	#.s.o:
# 	$(AS) -c $(CPPFLAGS) $(ASFLAGS) $<

## ====================================================================