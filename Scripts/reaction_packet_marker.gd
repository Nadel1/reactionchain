extends GenericPrompt

func setVisible(visibleVar: bool):
	$Label.visible=visibleVar
	$DebugSprite2D.visible=visibleVar

func setIndex(index):
	$Label.text = str(index)
	$DebugSprite2D.modulate = Color.LIME

func setStart(start):
	$DebugSprite2D.modulate = Color.LIME if start else Color.RED
