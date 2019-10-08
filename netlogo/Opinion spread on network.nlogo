undirected-link-breed [spacial-links spacial-link]
undirected-link-breed [cultural-links cultural-link]

turtles-own
[
  current-opinion
  baseline-opinion
  final-opinion
  opinion-threshold
  group
]

links-own
[
  influence
]
to setup
  clear-all
  setup-spacial-network
  setup-background-opinion
end

to setup-spacial-network
  clear-all
  setup-people
  setup-spatially-clustered-network
  ask turtles [set color white
               set group 0]
  ask spacial-links [ set color white ]

  reset-ticks
end

to setup-people
  set-default-shape turtles "person"
  create-turtles total-population
  [
    ; for visual reasons, we don't put any people *too* close to the edges
    setxy (random-xcor * 0.95) (random-ycor * 0.95)

    set group (random 5) + 1
  ]
  ask turtles
      [set opinion-threshold default-opinion-threshold]
end

to setup-spatially-clustered-network
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
  ask spacial-links [set influence default-influence]

end

to setup-background-opinion
ask turtles
  [decide-no]
 ask n-of initial-opinion-size turtles
[
 decide-yes
]
end



to setup-cultural-networks
  let mygroup ""


  foreach [1] [this-group ->




 let yes-num (initial-group-opinion-percent * group-size) / 100
 let no-num ((100 - initial-group-opinion-percent) * group-size) / 100


;;  ask n-of yes-num turtles with [current-opinion = "yes"]
;;  [ set group this-group
;;    set opinion-threshold 1]

;;  ask n-of no-num turtles with [current-opinion = "no"]
;;  [ set group this-group
;;    set opinion-threshold group-opinion-threshold ]


    ask n-of yes-num turtles with [group = 0]
  [
     set group this-group
     set opinion-threshold group-opinion-threshold
      decide-yes
  ]

    ask n-of no-num turtles with [group = 0]
  [
     set group this-group
     set opinion-threshold group-opinion-threshold
      decide-no
  ]

 let group-links (average-connections * group-size) / 2
 while [count cultural-links < group-links ]

 [
  ask one-of turtles

    [
      if group != 0 [
         set mygroup group
         let choice (one-of (other turtles with [group = mygroup]))
         if choice != nobody [ create-cultural-link-with choice ]
      ]
    ]

  ]
 ask cultural-links [
    set color green
   set influence group-influence
  ]
  ]

end




to go


  spread-opinion

  tick


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
  let yes-weight 0
  let no-weight 0

  ask one-of turtles [
               set yes-weight 0
               set no-weight 0
               ask my-links [
                             if [current-opinion] of other-end = "yes"
                                [set yes-weight  yes-weight + ([influence] of self)]
                             if [current-opinion] of other-end = "no"
                                [set no-weight  no-weight + ([influence] of self)]
                            ]
              if  yes-weight > no-weight and random 10 > opinion-threshold * 10
                   [ decide-yes ]
              if  yes-weight < no-weight and random 10 > opinion-threshold * 10
                   [ decide-no ]


  ]
end

to show-group
 show-all
 ask turtles with [group = 1]
    [set size 3]

  ask turtles with [group != 1]
  [ hide-turtle
    ask my-links [hide-link]
   ]
end

to show-spacial-network
  show-all
  ask cultural-links [hide-link]
end

to show-all

  ask turtles [
    set size 1
    show-turtle]

  ask links [show-link]
end


to set-baseline-opinion
  ask turtles
     [set baseline-opinion current-opinion]
end

to reset-opinion-threshold
  ask turtles [set opinion-threshold default-opinion-threshold]
end




; Copyright 2008 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
435
20
894
480
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
1
1
1
ticks
30.0

BUTTON
236
27
405
67
Set up spacial network
setup-spacial-network
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
596
531
691
571
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1017
12
1365
253
Opinion %
time
% of nodes
0.0
52.0
0.0
100.0
true
true
"" ""
PENS
"yes" 1.0 0 -13345367 true "" "plot (count turtles with [current-opinion = \"yes\"]) / (count turtles) * 100"
"no" 1.0 0 -2674135 true "" "plot (count turtles with [current-opinion = \"no\"]) / (count turtles) * 100"

SLIDER
27
27
232
60
total-population
total-population
10
1000
500.0
5
1
NIL
HORIZONTAL

SLIDER
29
125
234
158
initial-opinion-size
initial-opinion-size
1
total-population
240.0
1
1
NIL
HORIZONTAL

SLIDER
26
62
231
95
average-connections
average-connections
1
total-population - 1
10.0
1
1
NIL
HORIZONTAL

MONITOR
1220
390
1363
435
Current total opinion
count turtles with [current-opinion = \"yes\"]
17
1
11

BUTTON
104
545
240
578
Setup subculture
setup-cultural-networks
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
83
369
255
402
group-size
group-size
0
total-population
51.0
1
1
NIL
HORIZONTAL

MONITOR
1180
445
1314
490
Group total opinion
count turtles with [current-opinion = \"yes\" and group = 1]
17
1
11

BUTTON
242
126
362
159
setup  opinion
setup-background-opinion
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
435
489
591
522
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
779
491
860
524
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
1021
281
1114
326
opinion seed
initial-opinion-size
17
1
11

MONITOR
1020
339
1208
384
baseline opinion %
(count turtles with [baseline-opinion = \"yes\"] / total-population) * 100
17
1
11

TEXTBOX
174
10
324
28
Set up spacial network
11
0.0
1

TEXTBOX
159
102
309
120
Set up opinion
11
0.0
1

MONITOR
1222
339
1343
384
current opinion %
(count turtles with [current-opinion = \"yes\"] / total-population) * 100
17
1
11

TEXTBOX
73
346
290
374
2. SET UP SUBCULTURE NETWORK
11
0.0
1

SLIDER
44
413
284
446
initial-group-opinion-percent
initial-group-opinion-percent
0
100
60.0
1
1
NIL
HORIZONTAL

MONITOR
1020
394
1134
439
baseline opinion
count turtles with [baseline-opinion = \"yes\"]
17
1
11

MONITOR
1014
448
1170
493
group baseline opinion
count turtles with [baseline-opinion = \"yes\" and group = 1]
17
1
11

MONITOR
1020
538
1160
583
total opinion change
(count turtles with [current-opinion = \"yes\"]) -\n(count turtles with [baseline-opinion = \"yes\"])
17
1
11

MONITOR
1022
595
1181
640
group opinion change
(count turtles with [current-opinion = \"yes\"and group = 1]) -\n(count turtles with [baseline-opinion = \"yes\" and group = 1])
17
1
11

TEXTBOX
1233
561
1383
603
Trying to find small group change with large total change
11
0.0
1

BUTTON
595
490
765
523
show spacial network
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

BUTTON
911
374
1014
407
reset baseline
set-baseline-opinion
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
29
163
246
196
default-opinion-threshold
default-opinion-threshold
0
1
0.5
0.1
1
NIL
HORIZONTAL

BUTTON
258
163
321
196
reset
reset-opinion-threshold
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
41
209
213
242
default-influence
default-influence
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
74
493
246
526
group-influence
group-influence
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
61
454
269
487
group-opinion-threshold
group-opinion-threshold
0
1
0.8
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
Kenni - have had a go at a slightly different model based on explict links rether than the group links.

Rationale was trying to find structure where initial majority opinion does not dominate.

Looked for some models on netlogo and found the "Virus on a Network" model and used its intial network set up approach.

Otherwise changed its propagation model to a simple voter model and then tried adding further netowrk links for sub-cultures.

Method - assign a sub-culture attribute to person
Generate additional links between people with same sub-culture attribute (different link breed).

Then try and use this subculture to tip opinion through things like:
- level of commitment ie higher opinion threshold
- level influence - higher opinion weight
- number of connections
- heterogeneity (are they just in their own echo chamber or able to influnce opinion outside their group) -  multiple attributes could maybe model higher level of social mixing.


Started to generate some more interesting results.

Impact of number of conections is interesting.

Too many and majority always dominates
Too few and minority cannot spread


CHANGES
Combined spread opinion routines into single routine voting across all links.



## WHAT IS IT?

This model demonstrates the spread of opinion through a network with minority group influence. 

It uses the network creation approach of the "Virus on a Network" model [1] to create an initial spacial network.

With an initial opinion distribution set, the model determines a baseline equilibrium opinion distribution for the special network.

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
