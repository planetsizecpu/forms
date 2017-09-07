Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
	File: 	 %forms.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use for form scripts generation, save result then copy&paste code
	}
	History: [
		0.1.0 "22-08-2017"	"Start of work."
		0.1.1 "25-08-2017"  "Help of @rebolek to add form behavior on window resizing"
		0.1.2 "28-08-2017"  "FontGroup upgrade to request-font, added resize flag"
		0.1.3 "29-08-2017"  "Insert widget button, recode list button & actions"
		0.1.4 "01-08-2017"  "Widget insertion process start"
		0.1.5 "04-08-2017"  "Added color to widgets while wait for request-colour dialog"
		0.1.6 "06-09-2017"  "Added recode routine & save button, help of @rebolek on get values"
		0.1.7 "07-09-2017"  "Added some widgets to list, save function enhanced with 'at' "
	]
]

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 768
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
WindowMinSize: 200x200

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 300
ToolboxBigSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxMidSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 1.5)
ToolboxLowSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 2)
ToolboxWidgetList: ["area" "base" "box" "button" "camera" "check" "drop-down" "drop-list" "field" "group-box" "image" "panel" "progress" "radio" "slider" "tab-panel" "text" "text-list"]

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
FormSheetRecodeBlock: []
FormSheetWidgetSize: 100x25
FormSheetWidgetBackground: blue
FormSheetWidgetForeground: white

; Widget recode screen layout
recodeScreen: layout [ 
	title "Widget Recode Screen" 
	size 500x300
	below
	text 480x15 left brick white "name: type: offset: size: color: "
	RecodeList: text-list 480x250 data FormSheetRecodeBlock
]

;
; Main screen layout
;
mainScreen: layout [

	title "RED FORMS" 
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
		ContentButton: btn "Content/Recode" [Recode view recodeScreen]
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxBigSize "Widgets" [
		across
		text 30x25 bold "Size"
		WidgetGroupSize: field 70x20 data FormSheetWidgetSize
		return
		across
		box 25x25 FormSheetWidgetForeground
		box 25x25 FormSheetWidgetBackground
		return
		below
		WidgetGroupList: text-list data ToolboxWidgetList select 1
		WidgetGroupAddbtn: btn bold "Add" [FormSheetAddWidget]
	]
	
	; Toolbox Font controls
	FontGroup: group-box ToolboxLowSize "Font" [ 
		below
		FontGroupFontName: text bold 90x15 FontDefName
		FontGroupFontStyl: text bold 90x15 FontDefStyl
		across
		text 30x25 bold "Size:"
		FontGroupFontSize: text bold 30x15 FontDefSize
		return
		below
		FontGroupFontBtn: btn bold "Font" [FormFontChange]
		return
	]
	
	; Save button
	button 120x20 red black bold "SAVE" [Recode write/lines request-file FormSheetRecodeBlock]
	
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
	
	; Compute new form size
	FormDefXsize: WindowDefXsize - 150
	FormDefYsize: WindowDefYsize - 20
	FormDefSize: as-pair FormDefXsize FormDefYsize

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

; Form Sheet widget adition process
FormSheetAddWidget: does [
	
	; Compute widget name 
	FormSheetStr: null
	FormSheetWidgetName: null
	FormSheetWidgetType: null
	FormSheetCounter: add FormSheetCounter 1
	FormSheetStr: to-string ToolboxWidgetList/(WidgetGroupList/selected)
	FormSheetWidgetType: to-word copy FormSheetStr
	append FormSheetStr to-string FormSheetCounter
	append FormSheetStr ":"
	FormSheetWidgetName: to-set-word FormSheetStr
	
	; Add widget to content list
	append FormSheetContent FormSheetStr
	
	; Make a dummy face to copy the pane from, and append to form sheet. Can't find other documented method
	Dly: layout reduce [(FormSheetWidgetName) (FormSheetWidgetType) (WidgetGroupSize/data) 'font FontSel (FormSheetWidgetBackground) (FormSheetWidgetForeground) [] 'loose ] 
	
	; Create new widget into sheet by copying pane from dummy layout
	append FormSheet/pane Dly/pane
	
	; Recode all widgets
	do Recode
]

; Compute code block for save
Recode: does [
	
	; Init recode block
	clear FormSheetRecodeBlock
	
	; Compute each widget on content list
	foreach Wgt FormSheetContent [
		; Get widget values as word
		Wgw: get to word! Wgt
		; Set location
		Widget: copy "at "
		; Set offset
		Woffset: Wgw/offset
		append Widget Woffset
		append Widget " "
		; Set name
		append Widget Wgt
		append Widget " "
		; Set type
		Wtype: Wgw/type
		append Widget Wtype
		append Widget " "
		; Set size
		Wsize: Wgw/size
		append Widget Wsize
		append Widget " "
		; Set color
		Wcolor: Wgw/color
		append Widget Wcolor
		append Widget " "
		; Append widget to code block
		append FormSheetRecodeBlock Widget
	]
]

;
; Run code
;
view/flags mainScreen [resize]
