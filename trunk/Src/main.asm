.486
ideal
include "globals.inc"

stack 256


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


LEVEL_COUNT	EQU	9
RABBITS_PER_LEVEL EQU	16
GROWTH_PER_RABBIT	1

RABBIT_SYMBOL	EQU	0cfh
RABBIT_ATTR	EQU	7

HEAD_SYMBOL	EQU	'@'
HEAD_ATTR	EQU	7
BODY_SYMBOL	EQU	'O'
BODY_ATTR	EQU	7

EMPTY_SYMBOL	EQU	' '
EMPTY_ATTR	EQU	7

START_X		EQU	screenWidth / 2
START_Y		EQU	screenHeight - 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


dataseg

currentLevel	db	0		; Contains current game level
rabitsRemainder	db	0		; Contains number of rabbits to be eaten until level increment
growthRemainder	db	0		; Contains how many steps python has to grow yet

headIndex	dw	0		; Index of head in array
tailIndex	dw	0		; Index of tail in array

motionDelta	ScreenCoord <0, -1>	; Direction of motion


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

udataseg

rabbitCoords	ScreenCoord ?

pythonCoords	ScreenCoord screenWidth * screenHeight dup (?)

; Contents of screen with attributes
screenBuffer	db	2 * screenWidth * screenHeight dup (?)


levelDelays	dw	LEVEL_COUNT dup (?)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

codeseg

include "utils.inc"

