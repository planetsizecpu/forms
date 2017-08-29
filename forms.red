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
		0.1.1 "25-08-2017"  "Help of @rebolek to add form behavior on window resizing"
		0.1.2 "28-08-2017"  "FontGroup upgrade to request-font, added resize flag"
		0.1.3 "29-08-2017"  "Insert widget button, content list button & actions"
	]
]

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 768
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
WindowMinSize: 200x200

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 200
ToolboxDefSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxWidgetList: ["area" "base" "box" "drop-down" "drop-list" "field" "image" "panel" "tab-panel" "text" "text-list"]

; Font default values
FontDefName: "Consolas"
FontDefStyl: "Normal"
FontDefSize: "12"

; Form sheet default values
FormDefOrigin: 145x10
FormDefXsize: WindowDefXsize - (ToolboxDefXsize + 25)
FormDefYsize: WindowDefYsize - 25
FormDefSize: as-pair FormDefXsize FormDefYsize
FormSheetStr: ""
FormSheetCounter: 0
FormSheetContent: []
FormFile: %formstmp.txt

; Content screen layout
contentScreen: layout [ title "Content" ContentList: text-list data FormSheetContent]

;
; Main screen layout
;
mainScreen: layout [

	title "RED FORMS PRATICE" 
	size WindowDefSize
	below
	
	; Toolbox info
	InfoGroup: group-box ToolboxDefSize "Form Info" [
		across
		text 30x25 left bold "Size" 
		InfoGroupFormSize: text 60x25 left bold data FormDefSize
		return
		below
		ContentList: button bold "Content" on-click [view contentScreen]
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxDefSize "Widgets" [
		below
		WidgetGroupList: text-list data ToolboxWidgetList select 1
		WidgetGroupInsbtn: button bold "Insert" on-click [FormSheetInsertWidget]
	]
	
	; Toolbox Font controls
	FontGroup: group-box ToolboxDefSize "Font" [ 
		below
		FontGroupFontName: text bold 90x20 FontDefName
		FontGroupFontStyl: text bold 90x20 FontDefStyl
		across
		text bold 30x20 "Size:"
		FontGroupFontSize: text bold 30x20 FontDefSize
		return
		below
		FontGroupFontBtn: button bold "Font" on-click [FormFontChange]
		return
	]

	; Save button
	button 125x120 center blue white "FUTURE USE"
	
	; Form default design area
	at FormDefOrigin
	FormSheet: panel FormDefSize white blue cursor cross
	
	; Catch window resizing and adjust form
	on-resize [mainScreenSizeAdjust]	
	
]

; Create actor for window on-resize
mainScreen/actors: context [on-resize: func [f e][foreach-face f [if select face/actors 'on-resize [face/actors/on-resize face e]]]]

;
; Actions routines
;

; Window resizing form adjust
mainScreenSizeAdjust: does [

	; Check new form minimal size and restore last window size if needed
	if FormSheet/parent/size < WindowMinSize [FormSheet/parent/size: WindowDefSize]
	
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
	InfoGroupFormSize/text: to-string FormDefSize
]

; Font change behavior
FormFontChange: does [
	FontSel: request-font 
	FontDefName: FontSel/name 
	either FontSel/style [FontDefStyl: to-string FontSel/style] [print "BAD FONT STYLE"]
	FontDefSize: to-string FontSel/size 
	FontGroupFontName/text: FontDefName
	FontGroupFontStyl/text: FontDefStyl
	FontGroupFontSize/text: FontDefSize
]

; Form Sheet widget insertion process
FormSheetInsertWidget: does [
	
	; Compute widget name 
	FormSheetStr: ""
	FormSheetCounter: add FormSheetCounter 1
	FormSheetStr: to-string ToolboxWidgetList/(WidgetGroupList/selected)
	FormSheetWidgetType: to-word FormSheetStr
	append FormSheetStr to-string FormSheetCounter
	append FormSheetStr ":"
	FormSheetWidgetName: to-word FormSheetStr
	
	; Add widget to content list
	append FormSheetContent FormSheetStr
	print FormSheetContent
	write Formfile FormSheetStr
	
	; Create new widget into sheet
	FormSheet: FormSheet [set reduce [FormSheetWidgetName] reduce [FormSheetWidgetType] 200x200 blue]
]


;
; Run code
;
view/flags mainScreen [resize]
