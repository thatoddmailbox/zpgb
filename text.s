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

; ==================
; ==================
; INTRO
; ==================
; ==================
script_intro_level1_start:
	db 0x05
	ascii "Hello, and welcome"
	asciz "to the Automated  "

	db 0x05
	ascii "Puzzle System. The"
	asciz "System is still"

	db 0x05
	ascii "under heavy       "
	asciz "development, and  "

	db 0x05
	ascii "so should not yet "
	asciz "be used by"

	db 0x05
	ascii "the public. If you"
	asciz "are not authorized"

	db 0x05
	ascii "to access this    "
	asciz "System, please"

	db 0x05
	ascii "go back through   "
	asciz "the one-way door"

	db 0x05
	ascii "that brought you  "
	asciz "here."

	asciz ""

script_intro_level1_sign:
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
	asciz "can there be?"

	asciz ""

script_intro_level2_sign:
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

script_intro_level3_sign:
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

; ==================
; ==================
; MIDDLE PART
; ==================
; ==================
script_middle_level1_start:
	db 0x05
	ascii "This concludes the"
	asciz "introduction to"

	db 0x05
	asciz "DuckLabs puzzles."

	db 0x05
	ascii "From this point   "
	asciz "forwards, all"

	db 0x05
	ascii "dialogue will be  "
	asciz "kept at the"

	db 0x05
	ascii "minimum level     "
	asciz "necessary."

	db 0x05
	ascii "This ensures that "
	asciz "you will fail to  "

	db 0x05
	ascii "complete all the  "
	asciz "puzzles, and so"

	db 0x05
	ascii "we do not need to "
	asciz "deal with where"

	db 0x05
	ascii "to put you at the "
	asciz "end of the puzzle"

	db 0x05
	asciz "course."

	asciz ""

; TODO: some random story fact
script_middle_level2_info:
	db 0x02
	asciz "helloo"

	asciz ""

; ==================
; ==================
; SURFACE PART
; ==================
; ==================
script_surface_level1_start:
	db 0x05
	ascii "Thank you for your"
	asciz "participation in"

	db 0x05
	ascii "our puzzles. This "
	asciz "concludes all of  "

	db 0x05
	ascii "the puzzles that  "
	asciz "are available to  "

	db 0x05
	ascii "you in this       "
	asciz "building. Please  "

	db 0x05
	ascii "wait here. At some"
	asciz "point, you will be"

	db 0x05
	ascii "given further     "
	asciz "instructions."

	db 0x05
	ascii "Under absolutely  "
	asciz "no circumstances"

	db 0x05
	ascii "should you proceed"
	asciz "towards the exit  "

	db 0x05
	ascii "door directly in  "
	asciz "front of you."

	db 0x05
	ascii "Thank you for your"
	asciz "understanding."

	db 0x03
	asciz "...uh."

	db 0x03
	ascii "I guess that means"
	asciz "I should go to the"

	db 0x03
	asciz "exit then."

	asciz ""

script_surface_level2_sign:
	db 0x02
	asciz "hewlo zap"

	db 0x02
	ascii "ef yu reid this yu"
	asciz "hav eskape puzslez"

	db 0x02
	asciz "EY PLEN THIS 100%"

	db 0x02
	asciz "plz gu bak nao"

	db 0x02
	ascii "ey hav souper     "
	asciz "sekurity yu cannot"

	db 0x02
	asciz "get pasd"

	db 0x02
	asciz "- naht duki"

	asciz ""

script_surface_level3_start:
	db 0x05
	ascii "You have entered  "
	asciz "a high-security"

	db 0x05
	ascii "zone. If you are  "
	asciz "authorized to"

	db 0x05
	ascii "continue, please  "
	asciz "solve the DuckPuzz"

	db 0x05
	ascii "on the computer   "
	asciz "terminal."

	asciz ""

script_surface_level3_sign:
	db 0x02
	ascii "The DuckPuzz is   "
	asciz "one of our many"

	db 0x02
	ascii "advanced security "
	asciz "systems. It makes "

	db 0x02
	ascii "sure that only    "
	asciz "someone with the"

	db 0x02
	ascii "correct solution  "
	asciz "to the puzzle can"

	db 0x02
	asciz "proceed."

	db 0x02
	ascii "A DuckPuzz can    "
	asciz "only be completed "

	db 0x02
	ascii "by knowing the    "
	asciz "solution ahead of"

	db 0x02
	ascii "time. This system "
	asciz "has been verified"

	db 0x02
	ascii "to be completely  "
	asciz "unbreakable by"

	db 0x02
	asciz "Ducky himself."

	asciz ""

; ==================
; ==================
; OTHER
; ==================
; ==================
script_msg_duckpuzz_already_done:
	db 0x07
	ascii "You've already    "
	asciz "completed this"

	db 0x07
	asciz "DuckPuzz."

	asciz ""

script_sign_no_entry:
	db 0x02
	asciz "NO ENTRY"

	asciz ""