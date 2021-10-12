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

Components.Texture = {
  name = "texture",
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
    path = ""
  }
}

Components.Shape = {
  name = "shape",
  template = {
    type = "circle",
    color = 0,
    x = 0,
    y = 0,
    radius = 0,
    width = 0,
    height = 0,
    scrollX = 1,
    scrollY = 1,
    isFilled = true
  }
}

return Components