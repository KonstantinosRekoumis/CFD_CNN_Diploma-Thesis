#!/bin/bash

# rm -r ~/DiplomaThesisData/log
rm -r ~/DiplomaThesisData/error

touch ~/DiplomaThesisData/error
if ! [ -s ~/DiplomaThesisData/log ]
then
  touch ~/DiplomaThesisData/log
  cd ~/DiplomaThesisData/RAE_2822_baseline
  mpirun -np 7 ~/MaPFlow/MaPFlow
  ~/2dcp cp.bin #cpxxx.bin
  x=`python ~/Dropbox/DTC/Code/sort.py ~/DiplomaThesisData/RAE_2822_baseline/node.geom`
  python ~/Dropbox/DTC/Code/Airfoil_DataSet_Generator_Randomizer.py $x ~/DiplomaThesisData/
  python ~/Dropbox/DTC/Code/CP_export.py `pwd`/cp.dat
  echo "Airfoils' SDF images were created" >> ~/DiplomaThesisData/log
fi

echo "Airfoils' SDF images were created"
DIRS=`cat ~/DiplomaThesisData/DIRS`
LOG=`cat ~/DiplomaThesisData/log`

x=""

echo "Proceeding to the numerical simulations:"
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
    mpirun -np 7 ~/MaPFlow_deform/MaPFlow 2>> ~/DiplomaThesisData/error
    if [ -s ~/DiplomaThesisData/error ]
    then
      cat ~/DiplomaThesisData/error
      break
    fi
    ~/2dcp cp.bin
    python ~/Dropbox/DTC/Code/CP_export.py `pwd`/cp.dat
    echo $i >> ~/DiplomaThesisData/log
  fi
done
