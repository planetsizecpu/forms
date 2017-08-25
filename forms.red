Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
	File: 	 %forms.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use for form scripts generation
	}
	History: [
		0.1.0 "22-08-2017"	"Start of work."
		0.1.1 "25-08-2017"  "Help of @rebolek to add some response to resizing"
	]
]

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 768
WindowDefSize: as-pair WindowDefXsize WindowDefYsize

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 200
ToolboxDefSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxWidgetList: ["Area" "Base" "Box" "Drop-Down" "Drop-List" "Field" "Image" "Panel" "Tab-Panel" "Text" "Text-List"]
ToolboxDefFont: "Consolas"
ToolboxMaxFontSize: 25

; Form sheet default values
FormDefOrigin: 145x10
FormDefXsize: WindowDefXsize - 150
FormDefYsize: WindowDefYsize - 20
FormDefSize: as-pair FormDefXsize FormDefYsize

; Form sheet update function
FormSheetUpdate: function [ClickPoint] [prin "CLICK POINT: " print ClickPoint]

; Main screen layout
mainScreen: layout [

	title "RED FORMS PRATICE" 
	size WindowDefSize
	below
	
	; Toolbox info
	InfoGroup: group-box ToolboxDefSize "Form Info" [
		across
		text 30x25 left bold "Size" 
		InfoFormSize: text 60x25 left bold data FormDefSize
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxDefSize "Widgets" [		
		WidgetTList: text-list data ToolboxWidgetList select 1
	]
	
	; Toolbox Font controls
	FontGroup: group-box ToolboxDefSize "Font" [ 
		below
		Font01: radio bold "Console" data on on-down [ToolboxDefFont: "Consolas"] 
		Font02: radio bold "Terminal" on-down [ToolboxDefFont: "Terminal"] 
		Font03: radio bold "Fixed" on-down [ToolboxDefFont: "Fixedsys"] 
		across
		text bold 30x20 "Size" 
		FontSize: text bold 30x20 data to-integer ToolboxMaxFontSize / 2
		return
		below
		FontSizesli: slider 90x25 50% on-change [FontSize/data: to-integer (to-float FontSizesli/data) * ToolboxMaxFontSize /100 ]
	]

	; Save button
	button 125x120 center blue white "FUTURE USE"
	
	; Form default design area
	at FormDefOrigin
	FormSheet: panel FormDefSize white blue cursor cross

	
	on-resize [mainScreenSizeAdjust]	
	
]

; Create actor for on-resize
;mainScreen/actors: context [on-resize: func [f e][foreach-face f [if all [face select face 'actors select face/actors 'on-resize][face/actors/on-resize face e]]]]
mainScreen/actors: context [on-resize: func [f e][foreach-face f [if select face/actors 'on-resize [face/actors/on-resize face e]]]]

; Window size adjust
mainScreenSizeAdjust: does [

	; Check new form minimal size and restore last window size if needed
	if FormSheet/parent/size < 200x200 [FormSheet/parent/size: WindowDefSize]
	
	; Get new window size
	WindowDefXsize: FormSheet/parent/size/x
	WindowDefYsize: FormSheet/parent/size/y 
	WindowDefSize: as-pair WindowDefXsize WindowDefYsize
	prin "WINDOW SIZE: "
	prin WindowDefSize
	
	; Compute new form size
	FormDefXsize: WindowDefXsize - 150
	FormDefYsize: WindowDefYsize - 20
	FormDefSize: as-pair FormDefXsize FormDefYsize
	prin " - FORM SIZE: "
	print FormDefSize

	; Set new form size
	FormSheet/size: FormDefSize
	InfoFormSize/text: to-string FormDefSize

]

;
; RUN CODE
;
view mainScreen
