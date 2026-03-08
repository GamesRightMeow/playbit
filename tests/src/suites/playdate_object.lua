local tests = {}

function tests.ClassIsCreated()
  class("Tree").extends()
  pbAssert.IsNotNil(Tree)
end

function tests.PropertiesAreAdded()
  class("Car", { doors = 4 }).extends()
  pbAssert.AreEqual(Car.doors, 4)
end

function tests.NamespaceIsUsed()
  local Felines = {}
  class("Cat", nil, Felines).extends()
  pbAssert.IsNotNil(Felines.Cat)
end

function tests.ClassIsCreatedWithParent()
  class("Fruit", { color = "red" }).extends()
  class("Apple").extends(Fruit)
  pbAssert.IsNotNil(Fruit)
  pbAssert.IsNotNil(Apple)
  pbAssert.AreEqual(Apple.color, "red")
end

function tests.InstanceIsCreated() 
  class("Dog", { hasTail = true }).extends()
  local instance = Dog()
  pbAssert.IsNotNil(instance)
  pbAssert.IsTrue(instance.hasTail)
end

function tests.ClassNameIsDefined() 
  class("Squid").extends()
  local instance = Squid()
  pbAssert.AreEqual(instance.className, "Squid")
end

function tests.IsA_Works() 
  class("Box").extends()
  local instance = Box()
  pbAssert.IsTrue(instance:isa(Box))
end

return tests