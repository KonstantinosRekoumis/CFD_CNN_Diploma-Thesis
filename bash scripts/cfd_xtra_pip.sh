#!/bin/bash
PATH = "~/DiplomaThesisData/r_-50_50/"
cd $PATH

if ! [ -s ./LOG.dat ]
then 
    touch ./LOG.dat
fi

DIRS=`cat ./DIRS.dat`
LOG=`cat ./LOG.dat`

x=""

for i in $DIRS
do 
    x=""
    for j in $LOG
    do
        if [ $i = $j ]
        then
            x="done"
        fi
    done
    if ! [ $x = "done" ]
    then
    cd $i
    cp ~/DiplomaThesisData/RAE_2822_baseline/simulation.input $i
    cp ~/DiplomaThesisData/RAE_2822_baseline/grid.ascii $i
    cp ~/DiplomaThesisData/RAE_2822_baseline/RAE_2822.geom $i
    mpirun -np 7 ~/MaPFlow_deform/MaPFlow 2>> $PATH/error
    if [ -s ./error ]
    then
        cat ~/DiplomaThesisData/error
        break
    fi
    ~/2dcp cp.bin
    python ~/Dropbox/DTC/Code/CFD_CNN_Thesis/Airfoil Generation/CP_export.py `pwd`/cp.dat
    echo $i >> ./LOG.dat
    fi
done