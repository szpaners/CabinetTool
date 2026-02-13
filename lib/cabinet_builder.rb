# Klasa do budowania szafki
module CabinetBuilder
  class Panel
    attr_reader :group, :face

    def initialize(entities, name, material, thickness)
      @group = entities.add_group
      @group.name = name
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

  class Cabinet
    attr_reader :group, :entities

    def initialize
      @model = Sketchup.active_model
      @entities = @model.active_entities
      @group = @entities.add_group
      @cabinet_entities = @group.entities
    end

    def draw_bottom_panel
      bottom_x1 = 0
      bottom_y1 = 0
      bottom_z1 = 0
      bottom_x2 = CabinetDimensions::CABINET_WIDTH
      bottom_y2 = 0
      bottom_z2 = 0
      bottom_x3 = CabinetDimensions::CABINET_WIDTH
      bottom_y3 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      bottom_z3 = 0
      bottom_x4 = 0
      bottom_y4 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      bottom_z4 = 0

      bottom_point = [bottom_x1, bottom_y1, bottom_z1]
      bottom_rectangle = [
        bottom_point,
        [bottom_x2, bottom_y2, bottom_z2],
        [bottom_x3, bottom_y3, bottom_z3],
        [bottom_x4, bottom_y4, bottom_z4]
      ]

      bottom_panel = Panel.new(@cabinet_entities, "Bottom Panel", Sketchup::Color.new(139, 90, 43), CabinetDimensions::PANEL_THICKNESS)
      bottom_panel.create_face(bottom_rectangle)
      bottom_panel.pushpull(-CabinetDimensions::PANEL_THICKNESS)
    end

    def draw_top_panel
      top_x1 = 0
      top_y1 = 0
      top_z1 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      top_x2 = CabinetDimensions::CABINET_WIDTH
      top_y2 = 0
      top_z2 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      top_x3 = CabinetDimensions::CABINET_WIDTH
      top_y3 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      top_z3 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      top_x4 = 0
      top_y4 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      top_z4 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS

      top_point = [top_x1, top_y1, top_z1]
      top_rectangle = [
        top_point,
        [top_x2, top_y2, top_z2],
        [top_x3, top_y3, top_z3],
        [top_x4, top_y4, top_z4]
      ]

      top_panel = Panel.new(@cabinet_entities, "Top Panel", Sketchup::Color.new(139, 90, 43), CabinetDimensions::PANEL_THICKNESS)
      top_panel.create_face(top_rectangle)
      top_panel.pushpull(CabinetDimensions::PANEL_THICKNESS)
    end

    def draw_left_panel
      left_x1 = CabinetDimensions::PANEL_THICKNESS
      left_y1 = 0
      left_z1 = CabinetDimensions::PANEL_THICKNESS
      left_x2 = CabinetDimensions::PANEL_THICKNESS
      left_y2 = 0
      left_z2 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      left_x3 = CabinetDimensions::PANEL_THICKNESS
      left_y3 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      left_z3 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      left_x4 = CabinetDimensions::PANEL_THICKNESS
      left_y4 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      left_z4 = CabinetDimensions::PANEL_THICKNESS

      left_point = [left_x1, left_y1, left_z1]
      left_rectangle = [
        left_point,
        [left_x2, left_y2, left_z2],
        [left_x3, left_y3, left_z3],
        [left_x4, left_y4, left_z4]
      ]

      left_panel = Panel.new(@cabinet_entities, "Left Panel", Sketchup::Color.new(139, 90, 43), CabinetDimensions::PANEL_THICKNESS)
      left_panel.create_face(left_rectangle)
      left_panel.pushpull(CabinetDimensions::PANEL_THICKNESS)
    end

    def draw_right_panel
      right_x1 = CabinetDimensions::CABINET_WIDTH
      right_y1 = 0
      right_z1 = CabinetDimensions::PANEL_THICKNESS
      right_x2 = CabinetDimensions::CABINET_WIDTH
      right_y2 = 0
      right_z2 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      right_x3 = CabinetDimensions::CABINET_WIDTH
      right_y3 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      right_z3 = CabinetDimensions::CABINET_HEIGHT - CabinetDimensions::PANEL_THICKNESS
      right_x4 = CabinetDimensions::CABINET_WIDTH
      right_y4 = CabinetDimensions::CABINET_DEPTH - CabinetDimensions::PANEL_THICKNESS_BACK
      right_z4 = CabinetDimensions::PANEL_THICKNESS

      right_point = [right_x1, right_y1, right_z1]
      right_rectangle = [
        right_point,
        [right_x2, right_y2, right_z2],
        [right_x3, right_y3, right_z3],
        [right_x4, right_y4, right_z4]
      ]

      right_panel = Panel.new(@cabinet_entities, "Right Panel", Sketchup::Color.new(139, 90, 43), CabinetDimensions::PANEL_THICKNESS)
      right_panel.create_face(right_rectangle)
      right_panel.pushpull(CabinetDimensions::PANEL_THICKNESS)
    end

    def draw_back_panel
      back_x1 = 0
      back_x2 = CabinetDimensions::CABINET_WIDTH
      back_y = CabinetDimensions::CABINET_DEPTH
      back_z1 = 0
      back_z2 = CabinetDimensions::CABINET_HEIGHT

      back_point = [back_x1, back_y, back_z1]
      back_rectangle = [
        back_point,
        [back_x2, back_y, back_z1],
        [back_x2, back_y, back_z2],
        [back_x1, back_y, back_z2]
      ]

      back_panel = Panel.new(@cabinet_entities, "Back Panel", Sketchup::Color.new(139, 90, 43), CabinetDimensions::PANEL_THICKNESS_BACK)
      back_panel.create_face(back_rectangle)
      back_panel.pushpull(CabinetDimensions::PANEL_THICKNESS_BACK)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_top_panel
      draw_left_panel
      draw_right_panel
      draw_back_panel

      puts "Kitchen cabinet created successfully!"
    end
  end

  def self.draw_cabinet
    cabinet = Cabinet.new
    cabinet.draw_cabinet
  end
end