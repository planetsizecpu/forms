Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
	File: 	 %forms.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use for form scripts geration
	}
	History: [
		0.1.0 "22-08-2017"	"First version."
	]
]

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 768
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
prin "DEFAULT WINDOW  SIZE: "
print WindowDefSize

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 200
ToolboxDefSize: as-pair ToolboxDefXsize ToolboxDefYsize
prin "DEFAULT TOOLBOX SIZE: "
print ToolboxDefSize
ToolboxWidgetList: ["Area" "Base" "Box" "Drop-Down" "Drop-List" "Field" "Image" "Panel" "Tab-Panel" "Text" "Text-List"]
ToolboxDefFont: "Consolas"
ToolboxMaxSize: 25

; Form sheet default values
FormDefOrigin: 145x10
FormDefXsize: WindowDefXsize - 150
FormDefYsize: WindowDefYsize - 20
FormDefSize: as-pair FormDefXsize FormDefYsize
prin "DEFAULT FORM    SIZE: "
print FormDefSize

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
		text bold "Size"
		across
		FontSizesli: slider 60x25 50% on-change [FontSize/data: to-integer (to-float FontSizesli/data) * ToolboxMaxSize /100 ]
		FontSize: text bold 30x25 data to-integer ToolboxMaxSize / 2
	]
		
	; Form default design area
	at FormDefOrigin
	FormSheet: panel FormDefSize white blue cursor cross
	
	on-resize [mainScreenSizeAdjust]	
	
]

; Create actor for on-resize
mainScreen/actors: context [on-resize: func [f e][foreach-face f [if all [face select face 'actors select face/actors 'on-resize][face/actors/on-resize face e]]]]

; Window size adjust
mainScreenSizeAdjust: does [
	; Get new window size
	WindowDefXsize: FormSheet/parent/size/x
	WindowDefYsize: FormSheet/parent/size/y 
	WindowDefSize: as-pair WindowDefXsize WindowDefYsize
	prin "DEFAULT WINDOW  SIZE: "
	print WindowDefSize

	; Compute new form size
	FormDefXsize: WindowDefXsize - 150
	FormDefYsize: WindowDefYsize - 20
	FormDefSize: as-pair FormDefXsize FormDefYsize
	prin "DEFAULT FORM    SIZE: "
	print FormDefSize

	; Set new form size
	FormSheet/size: FormDefSize
	InfoFormSize/text: to-string FormDefSize

]

;
; RUN CODE
;
view mainScreen
