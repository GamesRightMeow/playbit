local Components = {}

Components.Name = {
  name = "name",
  template = {
    name = ""
  }
}

Components.Parent = {
  name = "parent",
  template = {
    entity = -1,
    name = "",
    x = 0,
    y = 0,
  }
}

Components.Tags = {
  name = "tags",
  template = {}
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
    visible = true,
    flash = 0.0,
    worldSpace = true,
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
    color = 1,
    isFilled = true,
    lineThickness = 0.5,
  }
}

Components.Text = {
  name = "text",
  template = {
    type = "text",
    text = "",
    align = "left",
    color = 1,
  }
}

Components.ParticleSystem = {
  name = "particle-system",
  template = {
    path = "",
    -- TODO: quads for sprite sheet
    active = true,
    maxParticles = 0,
    lifetimeMin = 0,
    lifetimeMax = 0,
    emissionRate = 0,
    emissionDirection = 0,
    speedMin = 0,
    speedMax = 0,
    sizeStart = 1,
    sizeEnd = 1,
    -- 
    wasActive = true,
  }
}

Components.Collider = {
  name = "collider",
  template = {
    type = "circle",
    layer = 0, -- not implemented yet
    x = 0,
    y = 0,
    radius = 0,
    contacts = {},
    enabled = true,
  }
}

Components.Velocity = {
  name = "velocity",
  template = {
    x = 0,
    y = 0,
  }
}

return Components