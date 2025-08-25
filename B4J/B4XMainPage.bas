B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#Macro: Title, Export, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip
#Macro: Title, GitHub, ide://run?file=%WINDIR%\System32\cmd.exe&Args=/c&Args=github&Args=..\..\
#Macro: Title, Sync Files, ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
'#Macro: Title, JsonLayouts folder, ide://run?File=%WINDIR%\explorer.exe&Args=%PROJECT%\JsonLayouts
'#Macro: After Save, Sync Layouts, ide://run?File=%ADDITIONAL%\..\B4X\JsonLayouts.jar&Args=%PROJECT%&Args=%PROJECT_NAME%
'#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
#End Region

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private fx As JFX
	Private Pane1 As Pane
	Private ScrollPane1 As ScrollPane
	Private CustomListView1 As CustomListView
	Private DragSceneY As Double
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	
	Dim pnMain As Pane
	pnMain.Initialize("")
	pnMain.RemoveAllNodes
	
	For i = 0 To 3
		Dim pn As B4XView = xui.CreatePanel("")
		pn.LoadLayout("ListItem1")
		pnMain.AddNode(pn, 0, i * 400, 280, 400)
	Next
	pnMain.PrefHeight = 4 * 400
	ScrollPane1.InnerNode = pnMain

	For i = 0 To 3
		CustomListView1.Add(CreateListItem(CustomListView1.AsView.Width, 400dip), i)
	Next
	EnableDragScroll(CustomListView1)
End Sub

Private Sub CreateListItem (Width As Int, Height As Int) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.LoadLayout("ListItem1")
	p.SetLayoutAnimated(0, 0, 0, Width, Height)
	Return p
End Sub

' Enable click-and-drag scrolling for a CustomListView
Private Sub EnableDragScroll (clv As CustomListView)
	Dim spJO As JavaObject = clv.sv
	'Attach all event filters in one go
    AddEventFilter(spJO, "MOUSE_PRESSED", "SPPressed")
    AddEventFilter(spJO, "MOUSE_RELEASED", "SPReleased")
    AddEventFilter(spJO, "MOUSE_DRAGGED", "SPDragged")
End Sub

' Utility to attach JavaFX event filters
Private Sub AddEventFilter (target As JavaObject, eventName As String, handlerName As String)
    Dim EventHandler As Object = target.CreateEvent("javafx.event.EventHandler", handlerName, Null)
    Dim MouseEvent As JavaObject
    MouseEvent.InitializeStatic("javafx.scene.input.MouseEvent")
    target.RunMethod("addEventFilter", Array(MouseEvent.GetField(eventName), EventHandler))
End Sub

' Utility to get a ScrollBar JavaObject
Public Sub GetScrollBar (Node As JavaObject, Orientation As String) As JavaObject
    Dim SBSet As JavaObject = Node.RunMethod("lookupAll", Array(".scroll-bar"))
    Dim Iterator As JavaObject = SBSet.RunMethod("iterator", Null)
    Do While Iterator.RunMethod("hasNext", Null)
        Dim SB As JavaObject = Iterator.RunMethod("next", Null)
        Dim SBOrientation As String = SB.RunMethodJO("getOrientation", Null).RunMethod("toString", Null)
        If SBOrientation = Orientation.ToUpperCase Then Return SB
    Loop
    Return SB
End Sub

' Event Handlers
Private Sub SPPressed_Event (MethodName As String, Args() As Object)
    Dim Event As JavaObject = Args(0)
    DragSceneY = Event.RunMethod("getY", Null)
End Sub

Private Sub SPReleased_Event (MethodName As String, Args() As Object)
    Dim SP As ScrollPane = Sender
    'SP.MouseCursor = fx.Cursors.DEFAULT
    If Initialized(SP.MouseCursor) And SP.MouseCursor = fx.Cursors.MOVE Then SP.MouseCursor = fx.Cursors.DEFAULT
End Sub

Private Sub SPDragged_Event (MethodName As String, Args() As Object)
    Dim SP As ScrollPane = Sender
    SP.MouseCursor = fx.Cursors.MOVE
    Dim Event As JavaObject = Args(0)
    Dim ThisY As Double = Event.RunMethod("getY", Null)
    Dim contentHeight As Double = SP.InnerNode.PrefHeight
    Dim visibleHeight As Double = GetScrollBar(CustomListView1.sv, "VERTICAL").RunMethod("getVisibleAmount", Null) * contentHeight
    SP.VPosition = SP.VPosition + (DragSceneY - ThisY) / (contentHeight - visibleHeight)
    DragSceneY = ThisY
End Sub