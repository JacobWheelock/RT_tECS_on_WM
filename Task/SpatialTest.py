# Jack Link -- Modified by Jacob Wheelock
# Created for the Brain Dynamics and Control Research Group at Washington University in St. Louis
# Last edited 6/6/22
# This program is an adaptation of the Corsi Block-Tapping Test for visuospatial working memory, designed to be adaptable to
# experimenter requirements. Display can be scaled to specifications of the testing device, number of blocks can be changed to alter
# difficulty of tasks, initial Corsi span can be changed to alter difficulty, delay between taps can be changed, and criteria for success
# and failure can be changed to alter scoring. Alternatively, test can be set to run the same trial continuously and/or reverse the order
# the sequence must be recalled in. Placement of blocks changes between sequences to counteract proactive interference. Auditory clues to
# indicate the start of test, success, and failure are included by default, but can be deactivated.

import random
import tkinter as tk
import time
from PIL import Image, ImageTk
import simpleaudio
import matlab.engine
import sys

#CONFIGS
audio = False #toggles auditory clues that indicate start of test, success, and failure
scale = 1 #scales the display
blocks = 9 #number of blocks (traditional number of blocks is 9)
span = 3 #number of blocks that light up (average human capability is 5-7)
currTrial = 0
speed = 1 #number of seconds each block lights up for (no standard traditional speed, but most studies that specify use 1 sec/block)
successCriteria = 1 #number of successes needed to graduate to next level when continuous==False
score = 0

if span > blocks:
    print("span can not be greater than number of blocks") #blocks can only be clicked once, so span cannot exceed number of blocks
    span = blocks
blockSize = int(50*scale)
position = []
for i in range(0,blocks):
    position.append([None,None])
button = [None]*blocks
startColorTk = [None]*blocks #individual images necessary for all buttons to work concurrently, idiosyncrasy of tkinter
clickColorTk = [None]*blocks
correctColorTk = [None]*blocks
incorrectColorTk = [None]*blocks
startColorPIL = Image.new(mode="RGBA",size=(blockSize,blockSize),color='blue') #sets colors for buttons
clickColorPIL = Image.new(mode="RGB",size=(blockSize,blockSize),color=(255, 0, 0))
correctColorPIL = Image.new(mode="RGBA",size=(blockSize,blockSize),color='green')
incorrectColorPIL = Image.new(mode="RGBA",size=(blockSize,blockSize),color='red')
if audio:
    beginSound = simpleaudio.WaveObject.from_wave_file("beep.wav") #from thisusernameis on Freesound, free use (Creative Commons 0 License)
    successSound = simpleaudio.WaveObject.from_wave_file("success.wav") #from Sjonas88 on Freesound, free use (Creative Commons 0 License)
    failureSound = simpleaudio.WaveObject.from_wave_file("failure.wav") #from Leszek_Szary on Freesound, free use (Creative Commons 0 License)

blockWidth = int(500*scale)
blockHeight = int(200*scale)

ready = False
frame = None
blockIter = 0
window = tk.Tk()
window.title("")
window.focus_force()
width = window.winfo_screenwidth()
height = window.winfo_screenheight()
window.state('zoomed')
window.attributes('-fullscreen', True)
successes = 0
failures = 0

def circShift(array):
    arrSize = len(array)
    temp = array[arrSize - 1]
    array[1:arrSize] = array[0:arrSize-1]
    array[0] = temp
    return array

def blockClicked(selection): #triggers whenever a block is clicked
    global blockIter
    global successes
    global failures
    global span
    global numTrials
    global currTrial
    global score
    button[selection]["state"]="disabled"
    button[selection]["image"]=clickColorTk[selection]
    answer[blockIter] = selection
    blockIter+=1
    if blockIter == span:
        time.sleep(0.2)
        for i in range(0,blocks):
            button[i].config(state="disabled")
            button[i].destroy()
        window.update()
        tempAns = answer
        score = 0
        maxScore = 0
        for i in range(0,span):
            for j in range(0,span):
                score += (solution[j] == tempAns[j])
            tempAns = circShift(tempAns)
            maxScore = max(score, maxScore)
            score = 0

        score = maxScore 
        
        report = tk.Label(frame,text="Score: " + str(score) + "/" + str(span),font=("Arial",int(scale*20)))
        report.place(relx=0.5,rely=0.5,anchor=tk.CENTER)
        window.update()
        time.sleep(1)
        endTest()

def demonstrate(): #demonstrates sequence
    global solution
    for selected in solution:
        button[selected].config(image=clickColorTk[selected], state = 'normal')
        window.update()
        time.sleep(speed)
        button[selected].config(image=startColorTk[selected], state = 'disabled')
        window.update()
    if audio:
        playBeginSound = beginSound.play()
        playBeginSound.wait_done()
    for i in range(0,blocks):
        button[i].config(state="normal")
def generate(): #generates new trial
    global frame
    for i in range(0,blocks): #places blocks randomly, retries placement of block if it overlaps with existing blocks
        placed = False
        while not placed:
            testPositionX = random.randint(blockWidth, width - blockWidth)
            testPositionY = random.randint(blockHeight, height - blockHeight)
            placed = True
            for j in range(0,i):
                if testPositionX > position[j][0]-int(scale*10) and testPositionX < position[j][0]+blockSize+int(scale*10):
                    if testPositionY > position[j][1]-int(scale*10) and testPositionY < position[j][1]+blockSize+int(scale*10):
                        placed = False
                        break
                if testPositionX+blockSize > position[j][0]-int(scale*10) and testPositionX+blockSize < position[j][0]+blockSize+int(scale*10):
                    if testPositionY > position[j][1]-int(scale*10) and testPositionY < position[j][1]+blockSize+int(scale*10):
                        placed = False
                        break
                if testPositionX > position[j][0]-int(scale*10) and testPositionX < position[j][0]+blockSize+int(scale*10):
                    if testPositionY+blockSize > position[j][1]-int(scale*10) and testPositionY+blockSize < position[j][1]+blockSize+int(scale*10):
                        placed = False
                        break
                if testPositionX+blockSize > position[j][0]-int(scale*10) and testPositionX+blockSize < position[j][0]+blockSize+int(scale*10):
                    if testPositionY+blockSize > position[j][1]-int(scale*10) and testPositionY+blockSize < position[j][1]+blockSize+int(scale*10):
                        placed = False
                        break
        position[i][0] = testPositionX
        position[i][1] = testPositionY
        
    frame = tk.Frame(master=window,width=width,height=height,bg='black')
    frame.pack()
    for i in range(0,blocks): #initializes blocks
        startColorTk[i] = ImageTk.PhotoImage(startColorPIL)
        clickColorTk[i] = ImageTk.PhotoImage(clickColorPIL)
        correctColorTk[i] = ImageTk.PhotoImage(correctColorPIL)
        incorrectColorTk[i] = ImageTk.PhotoImage(incorrectColorPIL)
        button[i] = tk.Button(master=frame,image=startColorTk[i],width=blockSize,height=blockSize,state="disabled",command=lambda i=i:blockClicked(i))
        button[i].place(x=position[i][0],y=position[i][1])
    possibilities = list(range(0,blocks))
    for i in range(0,span): #generates solution
        chosen = random.choice(possibilities)
        solution[i] = chosen
        possibilities.remove(chosen)
def beginTest(event): #event in response to keypress
    global ready
    ready = True
def test(span0, currTrial0): #main testing function
    global blockIter
    global frame
    global ready
    global solution
    global answer
    global numTrials
    global currTrial
    global eng
    global span
    global currTrial
    
    span = int(span0)
    currTrial = int(currTrial0)

    if (currTrial == 0): #shows startup instructions
        frame = tk.Frame(master=window,width=width,height=height,bg='black')
        frame.pack()
        instructions = tk.Label(frame,text="You will see "+str(blocks)+" blocks. \n "+str(span)+" blocks will turn yellow"\
                                        + " in a sequence. \n After this, you need to click the same blocks in the same"\
                                        + " sequence. \n \n Press any"\
                                        + " key when ready.",font=("Arial",int(scale*9)))
        instructions.place(relx=0.5,rely=0.5,anchor=tk.CENTER)
        window.update()
        window.bind('<Key>',beginTest)
        while not ready:
            window.update()
        window.unbind('<Key>')
        frame.pack_forget()
        frame.destroy()

    blockIter = 0
    solution = [None]*span
    answer = [None]*span
    generate()
    window.update()
    time.sleep(2)
    demonstrate()
def endTest():
    window.destroy()

test(span0, currTrial0)
window.mainloop()
data = [span, score]
