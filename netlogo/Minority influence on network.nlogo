;; breed for initial spacial network
undirected-link-breed [spacial-links spacial-link]
;; breed for cultural links
undirected-link-breed [social-links social-link]

turtles-own
[
  current-opinion
  baseline-opinion
  final-opinion
  opinion-threshold
  influence
  group
]
;; influence weight reflects strength of link - treated as symetrical ie. same in both directions in current model.
;; used to weight influence of neighbours opinion

;;
;; Link weight used in voting model as placeholder defaulted to 1 - doesn't currently have input sliders
;;
links-own
[
  weight
]
;;
;; create baseline network with prescribed number of people
;;
;;
to setup-baseline-network
  clear-all
  setup-people
  setup-links
  reset-ticks
end

;; create population with input size, set default influence and opinion threshold and initial position (used by link generation)

to setup-people
  set-default-shape turtles "person"
  create-turtles total-population
  [
    ; for visual reasons, we don't put any people *too* close to the edges
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    set opinion-threshold default-opinion-threshold
    set influence default-influence
    set color white
    set group 0]
end

;;
;; random network generation and layout approach taken fron "Virus on Network" sample Netlogo model
;;


to setup-links
  let num-links (average-connections * total-population) / 2
  while [count spacial-links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not spacial-link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-spacial-link-with choice ]
    ]
  ]
  ; make the network look a little prettier
  repeat 10
  [
    layout-spring turtles spacial-links 0.3 (world-width / (sqrt total-population)) 1
  ]
  ask spacial-links [set weight default-influence
                     set color white]

end

;;
;; randomly assign opinions to people with prescribed seed opinion percent
;;


to setup-baseline-opinion
  let baseline-yes seed-opinion-percent * total-population / 100
ask turtles
  [decide-no]
 ask n-of baseline-yes turtles
[
 decide-yes
]
  tick
end


;;
;; run voting model to equilibrium for initial spacial network

to set-baseline-equilibrium
  find-equilibrium
  ask turtles [set baseline-opinion current-opinion]
end

;;
;; run voting model to equilibrium for revised network with group links


to set-new-equilibrium
  find-equilibrium
  ask turtles [set final-opinion current-opinion]

end

;;
;; run voting model to equilibrium ie. opinion stabilises
;;

to find-equilibrium
  let old-total 0
  let new-total 1000
  while [new-total != old-total]
  [
       set old-total count turtles with [current-opinion = "yes"]
        repeat 5
    [spread-opinion]
        set new-total count turtles with [current-opinion = "yes"]
        show new-total
    tick
  ]

end

;;
;; create group based on group size and required group opinion distribution
;; generate links between group members
;;


to setup-group-network


 let group-size total-population * group-percent / 100

 let yes-num (initial-group-opinion-percent * group-size) / 100
 let no-num ((100 - initial-group-opinion-percent) * group-size) / 100



  ask n-of yes-num turtles with [current-opinion = "yes"]
  [set group 1]


  ask n-of no-num turtles with [current-opinion = "no"]
  [set group 1]

  ask turtles with [group = 1]
  [
       set opinion-threshold group-opinion-threshold
       set influence group-influence
  ]


 let group-links (average-connections * group-size) / 2
 while [count social-links < group-links ]

 [
  ask turtles

    [
      if group = 1 [
         let choice (one-of (other turtles with [group = 1]))
         if choice != nobody [ create-social-link-with choice ]
      ]
    ]

  ]

  ask social-links [
    set color green
   set weight 1
  ]


end


;;
;; run model end to end through
;; network creation and initial equilibrium
;; grop creation and final equilibrium
;;

to go
 setup-baseline-network
 setup-baseline-opinion
 set-baseline-equilibrium
 setup-group-network
 set-new-equilibrium
 stop
end

to decide-yes  ;; turtle procedure
  set current-opinion "yes"
  set color blue
end

to decide-no  ;; turtle procedure
  set current-opinion "no"
  set color red
end


to spread-opinion
;;  opinion of person is determined from weighted average of opinions of connections and likelihood of person to change opinion
;;  ie sum of link weights/influnce of neighbours with opinion yes is compared to sum of link weights/influence with opinion of no to determine winning opinion
;;  then opinion-threshold is used to determine if person will adopt that opinion
;;
  let yes-weight 0
  let no-weight 0

  ask turtles [
               set yes-weight 0
               set no-weight 0
               ask my-links [
                             if [current-opinion] of other-end = "yes"
                                [set yes-weight  yes-weight + ([weight] of self) * ([influence] of other-end)]
                             if [current-opinion] of other-end = "no"
                                 [set no-weight  no-weight + ([weight] of self) * ([influence] of other-end)]
                            ]
              if  yes-weight > no-weight and random 10 > opinion-threshold * 10
                   [ decide-yes ]
              if  yes-weight < no-weight and random 10 > opinion-threshold * 10
                   [ decide-no ]

  ]
end

to show-group
;; displays only the focal minority group with its connections

 show-all
 ask turtles with [group = 1]
    [set size 3]

<<<<<<< Updated upstream
  ask turtles with [group != 1]
  [ hide-turtle
    ask my-links [hide-link]
   ]
=======
to show-movement
;; displays only the focal minority movement with its connections
  set display-mode "movement"

  ask minority-movement [
;;    set size 3
    show-turtle
    ask my-links [ show-link ]
  ]

  ask outside-movement [
    hide-turtle
    ask my-links [ hide-link ]
  ]
>>>>>>> Stashed changes
end

to show-spacial-network
;; shows the initial spacial network
  show-all
  ask social-links [hide-link]
end

to show-all
;; shows all people and connections

  ask turtles [
<<<<<<< Updated upstream
    set size 1
    show-turtle]
=======
;;    set size 1
    show-turtle
  ]
>>>>>>> Stashed changes

  ask links [show-link]
end


<<<<<<< Updated upstream
to set-baseline-opinion
;; used to set baseline opinion for comparison before changing settings and running to new equilibrium
  ask turtles
     [set baseline-opinion current-opinion]
=======
to opinion-colour-mode
;; shows peoples' opinions
  set colour-mode "opinion"
  update-colour
end

to opinion-change-colour-mode
;; shows how peoples' opinions changed
  set colour-mode "opinion change"
  update-colour
end

to update-colour
;; updates the colours of the agents
  ask turtles [
    if colour-mode = "opinion" [
      if current-opinion = "majority" [ set color red]
      if current-opinion = "minority" [ set color blue]
    ]
    if colour-mode = "opinion change" [
      set color grey
      if current-opinion = "majority" and baseline-opinion = "minority" [ set color red]
      if current-opinion = "minority" and baseline-opinion = "majority" [ set color blue]
    ]
  ]
end


;;
;; Reporters
;;

to-report equilibrium
  report repeat-totals >= 5
end

;; Population groups

to-report minority-movement
  report turtles with [movement = 1]
end

to-report outside-movement
  report turtles with [movement != 1]
end

to-report current-minority-opinion []
  report turtles with [current-opinion = "minority"]
end

to-report current-majority-opinion []
  report turtles with [current-opinion = "majority"]
end

to-report current-minority-movement
  report minority-movement with [current-opinion = "minority"]
end

to-report baseline-minority-opinion []
  report turtles with [baseline-opinion = "minority"]
end

to-report baseline-majority-opinion []
  report turtles with [baseline-opinion = "majority"]
end

to-report baseline-minority-movement
  report minority-movement with [baseline-opinion = "minority"]
end

;; Population counts

to-report minority-movement-count []
  report count minority-movement
end

to-report current-minority-opinion-count []
  report count current-minority-opinion
end

to-report current-majority-opinion-count []
  report count current-majority-opinion
end

to-report current-minority-movement-opinion-count []
  report count current-minority-movement
end

to-report baseline-minority-opinion-count []
  report count baseline-minority-opinion
end

to-report baseline-majority-opinion-count []
  report count baseline-majority-opinion
end

to-report baseline-minority-movement-opinion-count []
  report count baseline-minority-movement
end

;; Population percents

to-report current-minority-opinion-percent []
  report (current-minority-opinion-count / total-population) * 100
end

to-report current-majority-opinion-percent []
  report (current-majority-opinion-count / total-population) * 100
end

to-report current-minority-movement-opinion-percent []
  report (current-minority-movement-opinion-count / minority-movement-count) * 100
end

to-report baseline-minority-opinion-percent []
  report (baseline-minority-opinion-count / total-population) * 100
end

to-report baseline-majority-opinion-percent []
  report (baseline-majority-opinion-count / total-population) * 100
end

to-report baseline-minority-movement-opinion-percent []
  report (baseline-minority-movement-opinion-count / minority-movement-count) * 100
end

;; Other metrics

to-report minority-movement-opinion-change-count []
  report current-minority-movement-opinion-count - baseline-minority-movement-opinion-count
end

to-report total-opinion-change-count []
  report current-minority-opinion-count - baseline-minority-opinion-count
end

to-report outside-opinion-change-count []
  report total-opinion-change-count - minority-movement-opinion-change-count
>>>>>>> Stashed changes
end


to reset-opinion-threshold
  ask turtles [set opinion-threshold default-opinion-threshold]
end



to-report minority-movement-outside-links []
  report  sum [count my-spacial-links] of turtles with [movement = 1 and current-opinion = "majority"]
end

to-report group-centrality []
  report sum [nw:betweenness-centrality] of turtles with [movement = 1]
end




; Copyright 2008 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
456
19
915
479
-1
-1
11.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
<<<<<<< Updated upstream
21
55
213
95
1. Set up baseline network
=======
84
94
464
127
1. Create agents and network links
>>>>>>> Stashed changes
setup-baseline-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
<<<<<<< Updated upstream
29
492
124
532
=======
8
221
64
619
>>>>>>> Stashed changes
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1014
10
1319
207
Opinion %
time
% of nodes
1.0
10.0
0.0
100.0
false
true
"" ""
PENS
"yes" 1.0 0 -13345367 true "" "plot (count turtles with [current-opinion = \"yes\"] / total-population) * 100"
"no" 1.0 0 -2674135 true "" "plot (count turtles with [current-opinion = \"no\"] / total-population) * 100"

SLIDER
<<<<<<< Updated upstream
20
10
225
43
=======
84
19
464
52
>>>>>>> Stashed changes
total-population
total-population
10
1000
100.0
5
1
NIL
HORIZONTAL

SLIDER
<<<<<<< Updated upstream
23
115
235
148
seed-opinion-percent
seed-opinion-percent
1
100
47.0
=======
83
140
463
173
minority-opinion-percent
minority-opinion-percent
1
50
45.0
>>>>>>> Stashed changes
1
1
NIL
HORIZONTAL

SLIDER
<<<<<<< Updated upstream
231
10
436
43
=======
85
58
464
91
>>>>>>> Stashed changes
average-connections
average-connections
1
25
<<<<<<< Updated upstream
6.0
=======
2.0
>>>>>>> Stashed changes
1
1
NIL
HORIZONTAL

MONITOR
1180
276
1323
321
current opinion
count turtles with [current-opinion = \"yes\"]
17
1
11

BUTTON
<<<<<<< Updated upstream
27
360
219
393
4. Set up influencer group
setup-group-network
=======
83
450
468
483
4. Activate minority movement
setup-minority-movement\n
>>>>>>> Stashed changes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
<<<<<<< Updated upstream
25
267
197
300
group-percent
group-percent
0
100
10.0
=======
84
375
464
408
movement-percent
movement-percent
0
100
20.0
>>>>>>> Stashed changes
1
1
NIL
HORIZONTAL

MONITOR
1181
327
1332
372
group current opinion
count turtles with [current-opinion = \"yes\" and group = 1]
17
1
11

BUTTON
<<<<<<< Updated upstream
24
153
217
186
2. Set up  baseline opinion
=======
83
176
464
209
2. Assign initial opinion
>>>>>>> Stashed changes
setup-baseline-opinion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
470
500
626
533
show cultural group
show-group
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
814
502
895
535
show all
show-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1080
217
1198
262
baseline opinion %
(count turtles with [baseline-opinion = \"yes\"] / total-population) * 100
2
1
11

MONITOR
1209
215
1330
260
current opinion %
(count turtles with [current-opinion = \"yes\"] / total-population) * 100
2
1
11

SLIDER
<<<<<<< Updated upstream
201
269
409
302
initial-group-opinion-percent
initial-group-opinion-percent
0
100
60.0
=======
83
413
463
446
initial-movement-opinion-percent
initial-movement-opinion-percent
0
100
65.0
>>>>>>> Stashed changes
1
1
NIL
HORIZONTAL

MONITOR
1012
276
1165
321
baseline opinion
count turtles with [baseline-opinion = \"yes\"]
17
1
11

MONITOR
1010
330
1166
375
group baseline opinion
count turtles with [baseline-opinion = \"yes\" and group = 1]
17
1
11

MONITOR
1038
460
1192
<<<<<<< Updated upstream
505
total opinion change
(count turtles with [current-opinion = \"yes\"]) -\n(count turtles with [baseline-opinion = \"yes\"])
=======
649
total opinion change
total-opinion-change-count
>>>>>>> Stashed changes
17
1
11

MONITOR
1036
412
1195
457
group opinion change
(count turtles with [current-opinion = \"yes\"and group = 1]) -\n(count turtles with [baseline-opinion = \"yes\" and group = 1])
17
1
11

TEXTBOX
1203
438
1353
480
Trying to find small group change with large total change
11
0.0
1

BUTTON
<<<<<<< Updated upstream
630
501
800
534
show spacial network
=======
667
485
837
518
show initial network
>>>>>>> Stashed changes
show-spacial-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
<<<<<<< Updated upstream
236
153
427
186
default-opinion-threshold
default-opinion-threshold
0
1
0.5
0.1
=======
84
255
464
288
default-opinion-change-threshold
default-opinion-change-threshold
0
1
0.1
0.01
>>>>>>> Stashed changes
1
NIL
HORIZONTAL

SLIDER
<<<<<<< Updated upstream
239
116
428
149
=======
84
220
464
253
>>>>>>> Stashed changes
default-influence
default-influence
0
1
0.7
0.1
1
NIL
HORIZONTAL

SLIDER
<<<<<<< Updated upstream
212
319
384
352
group-influence
group-influence
0
1
0.7
=======
85
501
468
534
movement-influence
movement-influence
0
1
1.0
>>>>>>> Stashed changes
0.1
1
NIL
HORIZONTAL

SLIDER
<<<<<<< Updated upstream
24
318
206
351
group-opinion-threshold
group-opinion-threshold
0
1
0.7
0.1
=======
84
537
467
570
movement-opinion-change-threshold
movement-opinion-change-threshold
0
1
0.05
0.01
>>>>>>> Stashed changes
1
NIL
HORIZONTAL

BUTTON
<<<<<<< Updated upstream
26
198
219
231
3. Set baseline equilibrium
=======
84
328
464
362
3. Run opinion spread - initial equilibrium
>>>>>>> Stashed changes
set-baseline-equilibrium
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
<<<<<<< Updated upstream
27
418
201
451
5. Find new equilibrium
=======
83
575
469
608
5. Run opinion spread - Find new equilibrium
>>>>>>> Stashed changes
set-new-equilibrium
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

<<<<<<< Updated upstream
TEXTBOX
141
502
376
536
ONE CLICK RUN - RUN ALL STEPS
14
0.0
=======
MONITOR
989
213
1046
258
seed %
minority-opinion-percent
17
1
11

BUTTON
8
18
64
173
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
85
291
465
324
opinion-fluctuation
opinion-fluctuation
0
1
0.0
0.1
>>>>>>> Stashed changes
1

MONITOR
1010
214
1067
259
seed %
seed-opinion-percent
17
1
11

<<<<<<< Updated upstream
=======
PLOT
986
316
1412
497
Change
NIL
NIL
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"movement change" 1.0 0 -13345367 true "" "if minority-movement-added\n  [plot minority-movement-opinion-change-count]"
"outside change" 1.0 0 -1604481 true "" "if minority-movement-added\n  [plot outside-opinion-change-count]"
"" 1.0 0 -16777216 true "" "plot 0"

BUTTON
581
531
697
564
opinion
opinion-colour-mode
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
500
539
589
557
colour mode:
11
0.0
1

BUTTON
581
566
708
599
opinion change
opinion-change-colour-mode
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
844
526
899
559
1
ask turtles [set size 1]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
843
561
898
594
2
ask turtles [set size 2]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
798
534
838
562
agent\nsize:
11
0.0
1

PLOT
1148
328
1348
478
Links
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "histogram [count my-links] of turtles"

MONITOR
1047
384
1139
429
outside links
minority-movement-outside-links
17
1
11

>>>>>>> Stashed changes
@#$#@#$#@
Stuart experiments

Simple scatter plot of seed v. equilibrium opinion for different network degrees.





Method 

1. Create a network of people with prescribed average connections (random network)

Attributes for person

 - Influence - weight given to their opinion by other connected agents in voting model. ie. if 0 their opinion won't be counted

- Opinion threshold - likelihood they will change opinion based on result of voting model ie level of commitment to current opinion
ie. if 1 their opinion won't change

- Current opinion - yes/no

- Baseline opinion - opinion after initial equilibrium found on spacial network

- Final opinion - opinion after equilibrium found with revised network after influencer group set up


2. Randomly assign yes/no opinion to population to prescribed initial opinion percentage




3. Run voting model to initial equilibrium based on above.
Set baseline opinion


4. Create a group with prescribed percentage of total population with prescribed existing opinion distribution

eg. if prescribed distribution os 60% and total population is 100 - randomly select 60 people with current opinion "yes" and 40 with current opinion "no" to add to this group

Randomly add additional connections between group members using same random link generation approach except without proximity condition.

Revise influence and opinion thresholds based on prescribed inputs.



5. Run voting model to new equilibrium


Notes

Try initial experiment with influence group size  0 to determine effect of total-population, seed opinion and number of links on opinion equilibria achieved

eg. too many links - majority opinion dominates
too few links - limited opinion spread

region of interest looks like

6-10 links
initial opinion percent around 45


For influence group, potential tipping behavaiour try

default opinion and influence 0.5 for total population

opinion and influence for group 0.7/0.8 . i.e they are more likely to persuade and less lkely to change than genaral population

set starting group opinion percent say 60 

obviously if too small it will get dominated by genaral population

if too big it will not have enough room to move to influence others within group to influence others outside group ("preaching to the converted")


note that running the same parameters can produce quite different results - it is quite sensitive to the random generation of network topology and opinion distribution - so we will need to average over a number of runs

I had a first go at a simple behavior space run.


Things to do 

Would be good to sanity check overall approach, do some testing, see if any bugs, review code and model for possible improvements

Any ideas on how to better visualise for demo - plots, monitors etc.?

Devlop some experiments in behavior space and start to look at results.

Start drafting presentation - I have a few thoughts which I will start adding.
Probably won't get much more time today but will have some time tomorrow.

Let me know if you want to have another chat over weekend - I'm out tonight (sat) and middle of the day on Sunday. 



## WHAT IS IT?

This model demonstrates the spread of opinion through a network with minority group influence. 

It uses the network creation approach of the "Virus on a Network" model [1] to create an initial spacial network.

With an initial opinion distribution set, the model determines a baseline equilibrium opinion distribution for the spacial network.

A minority group network is then established which promotes the yes opinion.

The model then runs to a new equilibrium opinion with the minority group influence.

In this version a simple voter model is used to update opinion.


## HOW IT WORKS

Set up spacial network

Seed initial opinions

Run voter model

People change opinion based on majority opinion of link neighbours.

With current dynamics equilibrium is quickly reached based on network degree and initial opinions.

Set up minority group (just 1 group in this version)

Assign a number of people to group based on input group size and reuired opinion distribution


Also high change threshold set so they have strong commitment to opinion.

Create network links between group members (culture-link) - in this version based on same degree as spacial network

Run model to new equilibrium.


## HOW TO USE IT

Run set up steps.

Experiment with different intial opinion and network degree to see equilibrium generated.


Add minority group 

Try settings to tip equilibrium opinion through influence outside group rather than just increasng group size.

Desired result

- minority initial opinion
- majority opinion within minority group
- influence overall opinion to tip to majority based on influence outside group



## THINGS TO NOTICE

Spacial set up and initial opinion distribution

Degree too high/too many connections - majority opinion dominates.

Degree too low/not enought connections - opinion cannot spread.

Equilibrium otherwise results in spacial clusters of opinion.





## THINGS TO TRY


## EXTENDING THE MODEL



## RELATED MODELS

Virus, Disease, Preferential Attachment, Diffusion on a Directed Network

## NETLOGO FEATURES

Links are used for modeling the network.  The `layout-spring` primitive is used to position the nodes and links such that the structure of the network is visually clear.


## REFERENCES

[1] Stonedahl, F. and Wilensky, U. (2008).  NetLogo Virus on a Network model.  http://ccl.northwestern.edu/netlogo/models/VirusonaNetwork.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Baseline as function of seed and links" repetitions="1" runMetricsEveryStep="false">
    <go>go</go>
    <metric>count turtles with [baseline-opinion = "yes"]</metric>
    <metric>count turtles with [final-opinion = "yes"]</metric>
    <steppedValueSet variable="average-connections" first="5" step="5" last="10"/>
    <steppedValueSet variable="seed-opinion-percent" first="10" step="10" last="50"/>
    <enumeratedValueSet variable="group-opinion-threshold">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-population">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-group-opinion-percent">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-percent">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-influence">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="default-opinion-threshold">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="default-influence">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Opinion equilibrium by intial opinion and average links" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>current-minority-opinion-count</metric>
    <enumeratedValueSet variable="average-connections">
      <value value="2"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-population">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="default-opinion-change-threshold">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-movement-opinion-percent">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-influence">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-percent">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="default-influence">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="minority-opinion-percent" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="opinion-fluctuation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-opinion-change-threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Effect of minority group influence" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="average-connections">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-population">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="default-opinion-change-threshold">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-movement-opinion-percent">
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="movement-influence" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="movement-percent">
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="default-influence" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="minority-opinion-percent">
      <value value="47"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opinion-fluctuation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-opinion-change-threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
