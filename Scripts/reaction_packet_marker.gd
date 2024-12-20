extends GenericPrompt

func setVisible(visible: bool):
	$DebugSprite2D.visible=visible

func setIndex(index):
	$Label.text = str(index)
	$DebugSprite2D.modulate = Color.LIME
