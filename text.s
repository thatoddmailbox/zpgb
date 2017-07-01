; story start
script_story_start:
	db 0x03
	ascii "This is a pretty  "
	asciz "bad waiting room."

	db 0x03
	ascii "Apparently paying "
	asciz "for electricity"

	db 0x03
	asciz "was 'unneeded'..."

	db 0x03
	asciz "Except..."

	db 0x03
	ascii "...this place uses"
	asciz "electric doors..."

	db 0x03
	ascii "...that, when not "
	asciz "powered, open..."

	db 0x03
	ascii "...and I think I  "
	asciz "see a door right"

	db 0x03
	asciz "here..."

	db 0x03
	ascii "I guess I should  "
	asciz "go through."

	db 0x03
	ascii "What's the worst  "
	asciz "that could happen?"

	db 0x00

; level 1 dialogue
script_level1_welcome:
	db 0x02
	ascii "Welcome to puzzle "
	asciz "course 47."

	db 0x02
	ascii "This part of the  "
	asciz "course will help"

	db 0x02
	ascii "you understand the"
	asciz "basics of our"

	db 0x02
	ascii "puzzles and their "
	asciz "components."

	db 0x02
	ascii "Please proceed to "
	asciz "the exit door."

	db 0x03
	asciz "More puzzles?"

	db 0x03
	ascii "How many puzzles  "
	asciz "can there possibly"

	db 0x03
	ascii "be?"

	asciz ""

; level 2 dialogue
script_level2_start:
	db 0x02
	ascii "Regulations demand"
	asciz "that we inform you"

	db 0x02
	ascii "about a recent    "
	asciz "study which has"

	db 0x02
	ascii "proven over 83% of"
	asciz "our lasers to be  "

	db 0x02
	asciz "harmless."

	db 0x02
	ascii "(results may vary "
	asciz "based on how you"

	db 0x02
	ascii "define the word   "
	asciz "'harmless')"

	db 0x02
	ascii "We call this      "
	asciz "technology NoHurt."

	db 0x02
	ascii "(trademark is     "
	asciz "pending, please do"

	db 0x02
	ascii "steal our amazing "
	ascii "name. "
	db 0x04
	asciz ")"

	asciz ""

; level 3 dialogue
script_level3_start:
	db 0x02
	ascii "Some things can be"
	asciz "rotated."

	db 0x02
	ascii "To do so, walk up "
	asciz "to something and  "

	db 0x02
	ascii "press B. Use the  "
	asciz "d-pad to select a "

	db 0x02
	ascii "target, and press "
	asciz "A to rotate the"

	db 0x02
	ascii "currently selected"
	asciz "target. When you  "

	db 0x02
	ascii "are done, press B "
	asciz "again to exit the "

	db 0x02
	asciz "rotation mode."

	asciz ""

script_test:
	db 0x01
	ascii "Hello! This is    "
	asciz "text! Yay words!!!"

	db 0x03
	ascii "This is a test of "
	asciz "dialogue!"

	db 0x02
	asciz "I am a sign."

	db 0x04
	asciz "Yay it works!"

	db 0x03
	ascii "There's no more   "
	asciz "dialogue now..."

	asciz ""