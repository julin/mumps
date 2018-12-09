#!/bin/bash

# attempt to detect CentOS, default to Ubuntu otherwise
# builds libraries for Intel Fortran

set -e

# if MKLROOT is not defined, try a default value
[[ -v MKLROOT ]] || export MKLROOT=$HOME/intel/compilers_and_libraries/linux/bin/

. $MKLROOT/../bin/compilervars.sh intel64
. $MKLROOT/bin/mklvars.sh intel64 lp64

export FC=mpif90 CC=mpicc CXX=icpc

[[ $1 == -k ]] && CLEAN=0 || CLEAN=1 

BUILDLAPACK95=0
BUILDMETIS=1
BUILDSCOTCH=1


## LAPACK95   (N.B. included in Intel MKL)
(
[[ $BUILDLAPACK95 != 1 ]] && exit

cd LAPACK95/


[[ $CLEAN == 1 ]] && make clean -C SRC

make double -C SRC FC=mpif90 OPTS0="-O3 -fPIC -fno-trapping-math"
)

## METIS
(
[[ $BUILDMETIS != 1 ]] && exit

cd metis

if [[ $CLEAN == 1 ]]
then
rm -rf build/*
make clean
make config FC=mpif90 CC=icc CXX=icpc
fi

make -j -l4 FC=mpif90

)

## Scotch
(

[[ $BUILDSCOTCH != 1 ]] && exit

cd scotch/src

[[ $CLEAN == 1 ]] && { make clean; cd esmumps; make clean; cd ..; }

make FC=mpif90 CC=icc CCS=icc CCD=icc CCP=mpiicc CXX=icpc

cd esmumps
make -j -l4 FC=mpif90 CC=icc CCS=icc CCD=icc CCP=mpiicc CXX=icpc
)

## Scalapack is included with Intel Fortran

## MUMPS
SCALAP='-L$(SCALAPDIR) -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -lmkl_blacs_intelmpi_lp64 -liomp5 -lpthread -ldl -lm'
(cd MUMPS

[[ $CLEAN == 1 ]] && make clean

if [[ -f /etc/redhat-release ]]; then

  make s d FC=mpif90 CC=icc CXX=icpc \
     LSCOTCHDIR=../../scotch/lib ISCOTCH=-I../../scotch/include \
     INCPAR=-I/share/pkg/openmpi/3.0.0_intel-2018/install1/include/ \
     LMETISDIR=/share/pkg/metis/5.1.0/install/lib IMETIS=-I/share/pkg/metis/5.1.0/install/include \
     SCALAPDIR=$MKLROOT \
     SCALAP=$SCALAP

else

  make s d FC=mpif90 CC=icc CXX=icpc \
     LSCOTCHDIR=../../scotch/lib ISCOTCH=-I../../scotch/include \
     INCPAR=-I$MKLROOT/../mpi/intel64/include/ \
     LMETISDIR=../../metis/libmetis IMETIS=-I../../metis/include \
     SCALAPDIR=$MKLROOT \
     SCALAP=$SCALAP

fi
)