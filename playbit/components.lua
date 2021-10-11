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
    texturePath = ""
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
    isFilled = true
  }
}

return Components