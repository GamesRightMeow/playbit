local Components = {}

Components.Name = {
  name = "name",
  template = {
    name = ""
  }
}

Components.Transform = {
  name = "transform",
  template = {
    x = 0,
    y = 0,
  }
}

Components.Graphic = {
  name = "graphic",
  template = {
    x = 0,
    y = 0,
    originX = 0,
    originY = 0,
    scaleX = 1,
    scaleY = 1,
    rotation = 0,
    scrollX = 1,
    scrollY = 1,
    layer = 0,
    colorR = 1,
    colorG = 1,
    colorB = 1,
    visible = true,
  }
}

Components.Spritesheet = {
  name = "spritesheet",
  template = {
    path = "",
    index = 0,
    width = 0,
    height = 0,
  }
}

Components.Sprite = {
  name = "sprite",
  template = {
    path = "",
    x = 0,
    y = 0,
    width = 0,
    height = 0,
  }
}

Components.Texture = {
  name = "texture",
  template = {
    path = "",
  }
}

Components.Shape = {
  name = "shape",
  template = {
    type = "circle",
    radius = 0,
    width = 0,
    height = 0,
    isFilled = true
  }
}

return Components