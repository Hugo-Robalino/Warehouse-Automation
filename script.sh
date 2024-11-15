#! /bin/bash
# HOW TO RUN IT
# Run the following command for creating the solutions to the axamples provided in the generatedInstances directory
# sh script.sh <str, example name> <int, horizon>

mkdir generatedInstances/$1
clingo solver.lp generatedInstances/$1.lp -c h=$2 10 > generatedInstances/$1/$1_results.lp
python -c 'from script import first_step; first_step()' $1
osascript -e "tell application \"Finder\" to delete POSIX file \"${PWD}/generatedInstances/$1/$1_results.lp\""

mkdir generatedInstances/$1/results
mkdir generatedInstances/$1/results_viz

files=(generatedInstances/$1/*.lp)
i=0

for f in "${files[@]}"; do
i=$(( i + 1 ))
num=$(printf "%03d" $i) 
clingo solver_results.lp $f > generatedInstances/$1/results/$1_$num.lp
python -c 'from script import rewrite_step; rewrite_step()' $1 results $num
clingo solver_viz.lp $f > generatedInstances/$1/results_viz/$1_$num.lp
python -c 'from script import rewrite_step; rewrite_step()' $1 results_viz $num
osascript -e "tell application \"Finder\" to delete POSIX file \"${PWD}/$f\""
done 

mv generatedInstances/$1.lp generatedInstances/$1/
