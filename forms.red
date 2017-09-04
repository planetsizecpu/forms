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
		0.1.4 "01-08-2017"  "Widget insertion process start"
		0.1.5 "04-08-2017"  "Added random color to widgets while wait for request-colour dialog"
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
ToolboxBigSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxMidSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 1.5)
ToolboxLowSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 2)
ToolboxWidgetList: ["area" "base" "box" "drop-down" "drop-list" "field" "image" "panel" "tab-panel" "text" "text-list"]

; Font default values
FontSel: ["Consolas" "normal" 10]
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
FormSheetWidgetColour: 255.255.255

; Content screen layout
contentScreen: layout [ title "Content" ContentList: text-list data FormSheetContent]

;
; Main screen layout
;
mainScreen: layout [

	title "RED FORMS PRATICE" 
	size WindowDefSize
	below
	style btn: button 100x20 red black bold
	
	; Toolbox info
	InfoGroup: group-box ToolboxLowSize "Form Info" [
		across
		text 30x25 left bold "Size" 
		InfoGroupFormSize: text 60x25 left bold data FormDefSize
		return
		below
		ContentList: btn "Content" [view contentScreen]
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxBigSize "Widgets" [
		below
		WidgetGroupList: text-list data ToolboxWidgetList select 1
		WidgetGroupInsbtn: btn bold "Insert" [FormSheetInsertWidget]
	]
	
	; Toolbox Font controls
	FontGroup: group-box ToolboxMidSize "Font" [ 
		below
		FontGroupFontName: text bold 90x15 FontDefName
		FontGroupFontStyl: text bold 90x15 FontDefStyl
		across
		text bold 30x15 "Size:"
		FontGroupFontSize: text bold 30x15 FontDefSize
		return
		below
		FontGroupFontBtn: btn bold "Font" [FormFontChange]
		return
	]

	; Save button
	button 125x30 center blue white "FUTURE USE"
	
	; Form default design area
	at FormDefOrigin
	FormSheet: panel FormDefSize white blue cursor cross []
	
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
	FormSheetStr: null
	FormSheetWidgetType: null
	FormSheetWidgetName: null
	FormSheetCounter: add FormSheetCounter 1
	FormSheetStr: to-string ToolboxWidgetList/(WidgetGroupList/selected)
	FormSheetWidgetType: to-word copy FormSheetStr
	append FormSheetStr to-string FormSheetCounter
	append FormSheetStr ":"
	FormSheetWidgetName: to-word FormSheetStr
	
	; By now we use random colours whie wait for request-colour dialog
	FormSheetWidgetBackground: random (FormSheetWidgetColour)
	FormSheetWidgetForeground: random (FormSheetWidgetColour)
	
	; Add widget to content list
	append FormSheetContent FormSheetStr

	; Create widget layout (WE ARE WORKING HERE)
	
	; Make a dummy face to copy the pane from, and append to form sheet. Don't found other documented method
	ly: layout reduce [(FormSheetWidgetType) 100x100 'font FontSel (FormSheetWidgetBackground) (FormSheetWidgetForeground) [] 'loose] 
	
	; Create new widget into sheet by copying pane from dummy layout
	append FormSheet/pane ly/pane
]

;
; Run code
;
view/flags mainScreen [resize]
