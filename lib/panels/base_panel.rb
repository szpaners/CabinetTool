module CabinetBuilder
  class BasePanel
    attr_reader :group, :face

    def initialize(config)
      entities = config[:entities]
      name = config[:name]
      material = config[:material]

      @group = entities.add_group
      @group.name = name
      @group.material = material
    end

    def create_face(points)
      @face = @group.entities.add_face(points)
    end

    def pushpull(distance)
      @face.pushpull(distance)
    end
  end
end
