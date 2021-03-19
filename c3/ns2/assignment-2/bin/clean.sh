#! /bin/bash

for siml in 1 2 3 4 5
do
  if [ "$(ls -A sim-$siml/out)" ]; then rm sim-$siml/out/*; fi
  if [ $1 == "--include-data" ] && [ "$(ls -A sim-$siml/scene)" ]; then rm sim-$siml/scene/*; fi
done
