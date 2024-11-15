import sys
import os

def first_step():
    with open('generatedInstances/' + sys.argv[1] + '/' + sys.argv[1] + '_results.lp') as file:
        index = 1
        for _, line in enumerate(file.readlines()[3:-6]):          
            if 'Answer' not in line:
                answer = map(lambda x: x+'.', line.strip().split(' '))            
                with open('generatedInstances/' +sys.argv[1] + '/' + str(index).zfill(3) + '.lp', 'w') as f:
                    f.writelines("%s\n" % l for l in answer)
                index += 1
                
def rewrite_step():
    with open('generatedInstances/' + sys.argv[1] + '/' + sys.argv[2] + '/' + sys.argv[1] + '_' + sys.argv[3] + '.lp', 'r+') as file:
        old_path = 'generatedInstances/' + sys.argv[1] + '/' + sys.argv[2] + '/' + sys.argv[1] + '_' + sys.argv[3] + '.lp'
        new_path = 'generatedInstances/' + sys.argv[1] + '/' + sys.argv[2] + '/' + sys.argv[1] + '_' + sys.argv[3] + '_viz.lp'
        line = file.readlines()[4]
        answer = map(lambda x: x+'.', line.strip().split(' ')) 
        file.seek(0)
        file.writelines("%s\n" % l for l in answer)
        file.truncate()
        if sys.argv[2] == 'results_viz':
            os.rename(old_path,new_path)
    