module CabinetBuilder
  class TopPanel
    attr_reader :group, :face

    def initialize(entities, material, thickness)
      @group = entities.add_group
      @group.name = "Top Panel"
      @group.material = material
      @thickness = thickness
    end

    def create_face(points)
      @face = @group.entities.add_face(points)
    end

    def pushpull(distance)
      @face.pushpull(distance)
    end
  end
end