#!/bin/bash

INK=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
IMAGEW=imagew

if [[ -z "$1" ]] 
then
	echo "SVG file needed."
	exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"
MYPWD=`pwd`

# need to use absolute paths in OSX

$INK -z -D -e "$MYPWD/$BASE-20.png" -f 		$MYPWD/$SVG -w 20 -h 20
$INK -z -D -e "$MYPWD/$BASE-20@2x.png" -f 	$MYPWD/$SVG -w 40 -h 40
$INK -z -D -e "$MYPWD/$BASE-20@3x.png" -f 	$MYPWD/$SVG -w 60 -h 60
$INK -z -D -e "$MYPWD/$BASE-24@2x.png" -f 	$MYPWD/$SVG -w 48 -h 48
$INK -z -D -e "$MYPWD/$BASE-27-5@2x.png" -f 	$MYPWD/$SVG -w 55 -h 55
$INK -z -D -e "$MYPWD/$BASE-29.png" -f 		$MYPWD/$SVG -w 29 -h 29
$INK -z -D -e "$MYPWD/$BASE-29@2x.png" -f 	$MYPWD/$SVG -w 58 -h 58
$INK -z -D -e "$MYPWD/$BASE-29@3x.png" -f 	$MYPWD/$SVG -w 87 -h 87
$INK -z -D -e "$MYPWD/$BASE-33.png" -f 		$MYPWD/$SVG -w 33 -h 33
$INK -z -D -e "$MYPWD/$BASE-33@2x.png" -f 	$MYPWD/$SVG -w 66 -h 66
$INK -z -D -e "$MYPWD/$BASE-33@3x.png" -f	$MYPWD/$SVG -w 99 -h 99
$INK -z -D -e "$MYPWD/$BASE-40.png" -f 		$MYPWD/$SVG -w 40 -h 40
$INK -z -D -e "$MYPWD/$BASE-40@2x.png" -f 	$MYPWD/$SVG -w 80 -h 80
$INK -z -D -e "$MYPWD/$BASE-40@3x.png" -f 	$MYPWD/$SVG -w 120 -h 120
$INK -z -D -e "$MYPWD/$BASE-44@2x.png" -f 	$MYPWD/$SVG -w 88 -h 88
$INK -z -D -e "$MYPWD/$BASE-50.png" -f 		$MYPWD/$SVG -w 50 -h 50
$INK -z -D -e "$MYPWD/$BASE-50@2x.png" -f 	$MYPWD/$SVG -w 100 -h 100
$INK -z -D -e "$MYPWD/$BASE-57.png" -f 		$MYPWD/$SVG -w 57 -h 57
$INK -z -D -e "$MYPWD/$BASE-57@2x.png" -f 	$MYPWD/$SVG -w 114 -h 114
$INK -z -D -e "$MYPWD/$BASE-60@2x.png" -f 	$MYPWD/$SVG -w 120 -h 120
$INK -z -D -e "$MYPWD/$BASE-60@3x.png" -f 	$MYPWD/$SVG -w 180 -h 180
$INK -z -D -e "$MYPWD/$BASE-64.png" -f 		$MYPWD/$SVG -w 64 -h 64
$INK -z -D -e "$MYPWD/$BASE-72.png" -f 		$MYPWD/$SVG -w 72 -h 72
$INK -z -D -e "$MYPWD/$BASE-72@2x.png" -f 	$MYPWD/$SVG -w 144 -h 144
$INK -z -D -e "$MYPWD/$BASE-76.png" -f 		$MYPWD/$SVG -w 76 -h 76 
$INK -z -D -e "$MYPWD/$BASE-76@2x.png" -f 	$MYPWD/$SVG -w 152 -h 152
$INK -z -D -e "$MYPWD/$BASE-83-5@2x.png" -f 	$MYPWD/$SVG -w 167 -h 167
$INK -z -D -e "$MYPWD/$BASE-86@2x.png" -f 	$MYPWD/$SVG -w 172 -h 172
$INK -z -D -e "$MYPWD/$BASE-98@2x.png" -f 	$MYPWD/$SVG -w 196 -h 196
$INK -z -D -e "$MYPWD/$BASE-192.png" -f 	$MYPWD/$SVG -w 192 -h 192
$INK -z -D -e "$MYPWD/$BASE-320.png" -f 	$MYPWD/$SVG -w 320 -h 320 
$INK -z -D -e "$MYPWD/$BASE-512.png" -f 	$MYPWD/$SVG -w 512 -h 512
$INK -z -D -e "$MYPWD/$BASE-1024.png" -f 	$MYPWD/$SVG -w 1024 -h 1024
$IMAGEW "$MYPWD/$BASE-512.png" "$MYPWD/$BASE-512-noalpha.png"
$IMAGEW "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-1024-noalpha.png"
$IMAGEW "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-1024-noalpha.png"

# Launch Screens for iOS < 8.0
$IMAGEW -crop 0,128,1024,768 "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-1024x768.png"
$IMAGEW -crop 128,0,768,1024 "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-768x1024.png"
$INK -z -D -e "$MYPWD/$BASE-960.png" -f 	$MYPWD/$SVG -w 960 -h 960
$IMAGEW -crop 160,0,640,960 "$MYPWD/$BASE-960.png" "$MYPWD/$BASE-640x960.png"
$INK -z -D -e "$MYPWD/$BASE-1136.png" -f 	$MYPWD/$SVG -w 1136 -h 1136
$IMAGEW -crop 248,0,640,1136 "$MYPWD/$BASE-1136.png" "$MYPWD/$BASE-640x1136.png"
$INK -z -D -e "$MYPWD/$BASE-1334.png" -f 	$MYPWD/$SVG -w 1334 -h 1334
$IMAGEW -crop 292,0,750,1334 "$MYPWD/$BASE-1334.png" "$MYPWD/$BASE-750x1334.png"
$INK -z -D -e "$MYPWD/$BASE-2048.png" -f 	$MYPWD/$SVG -w 2048 -h 2048
$IMAGEW -crop 0,256,2048,1536 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-2048x1536.png"
$IMAGEW -crop 256,0,1536,2048 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-1536x2048.png"
$INK -z -D -e "$MYPWD/$BASE-2208.png" -f 	$MYPWD/$SVG -w 2208 -h 2208
$IMAGEW -crop 0,483,2208,1242 "$MYPWD/$BASE-2208.png" "$MYPWD/$BASE-2208x1242.png"
$IMAGEW -crop 483,0,1242,2208 "$MYPWD/$BASE-2208.png" "$MYPWD/$BASE-1242x2208.png"
