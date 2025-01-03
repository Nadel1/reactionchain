extends GenericPrompt

func setVisible(visible: bool):
	$Label.visible=visible
	$DebugSprite2D.visible=visible

func setIndex(index):
	$Label.text = str(index)
	$DebugSprite2D.modulate = Color.LIME
