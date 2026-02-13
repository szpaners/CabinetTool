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

  class BottomPanel
    attr_reader :group, :face

    def initialize(entities, material, thickness)
      @group = entities.add_group
      @group.name = "Bottom Panel"
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

  class LeftPanel
    attr_reader :group, :face

    def initialize(entities, material, thickness)
      @group = entities.add_group
      @group.name = "Left Panel"
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

  class RightPanel
    attr_reader :group, :face

    def initialize(entities, material, thickness)
      @group = entities.add_group
      @group.name = "Right Panel"
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

  class BackPanel
    attr_reader :group, :face

    def initialize(entities, material, thickness)
      @group = entities.add_group
      @group.name = "Back Panel"
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

    def initialize(width, height, depth, panel_thickness, back_thickness)
      @model = Sketchup.active_model
      @entities = @model.active_entities
      @group = @entities.add_group
      @cabinet_entities = @group.entities
      @width = width
      @height = height
      @depth = depth
      @panel_thickness = panel_thickness
      @back_thickness = back_thickness
    end

    def draw_bottom_panel
      bottom_x1 = 0
      bottom_y1 = 0
      bottom_z1 = 0
      bottom_x2 = @width
      bottom_y2 = 0
      bottom_z2 = 0
      bottom_x3 = @width
      bottom_y3 = @depth - @back_thickness
      bottom_z3 = 0
      bottom_x4 = 0
      bottom_y4 = @depth - @back_thickness
      bottom_z4 = 0

      bottom_point = [bottom_x1, bottom_y1, bottom_z1]
      bottom_rectangle = [
        bottom_point,
        [bottom_x2, bottom_y2, bottom_z2],
        [bottom_x3, bottom_y3, bottom_z3],
        [bottom_x4, bottom_y4, bottom_z4]
      ]

      bottom_panel = BottomPanel.new(@cabinet_entities, Sketchup::Color.new(139, 90, 43), @panel_thickness)
      bottom_panel.create_face(bottom_rectangle)
      bottom_panel.pushpull(-@panel_thickness)
    end

def draw_top_panel
      top_x1 = 0
      top_y1 = 0
      top_z1 = @height - @panel_thickness
      top_x2 = @width
      top_y2 = 0
      top_z2 = @height - @panel_thickness
      top_x3 = @width
      top_y3 = @depth - @back_thickness
      top_z3 = @height - @panel_thickness
      top_x4 = 0
      top_y4 = @depth - @back_thickness
      top_z4 = @height - @panel_thickness

      top_point = [top_x1, top_y1, top_z1]
      top_rectangle = [
        top_point,
        [top_x2, top_y2, top_z2],
        [top_x3, top_y3, top_z3],
        [top_x4, top_y4, top_z4]
      ]

      top_panel = TopPanel.new(@cabinet_entities, Sketchup::Color.new(139, 90, 43), @panel_thickness)
      top_panel.create_face(top_rectangle)
      top_panel.pushpull(@panel_thickness)
    end

def draw_left_panel
      left_x1 = @panel_thickness
      left_y1 = 0
      left_z1 = @panel_thickness
      left_x2 = @panel_thickness
      left_y2 = 0
      left_z2 = @height - @panel_thickness
      left_x3 = @panel_thickness
      left_y3 = @depth - @back_thickness
      left_z3 = @height - @panel_thickness
      left_x4 = @panel_thickness
      left_y4 = @depth - @back_thickness
      left_z4 = @panel_thickness

      left_point = [left_x1, left_y1, left_z1]
      left_rectangle = [
        left_point,
        [left_x2, left_y2, left_z2],
        [left_x3, left_y3, left_z3],
        [left_x4, left_y4, left_z4]
      ]

      left_panel = LeftPanel.new(@cabinet_entities, Sketchup::Color.new(139, 90, 43), @panel_thickness)
      left_panel.create_face(left_rectangle)
      left_panel.pushpull(@panel_thickness)
    end

def draw_right_panel
      right_x1 = @width
      right_y1 = 0
      right_z1 = @panel_thickness
      right_x2 = @width
      right_y2 = 0
      right_z2 = @height - @panel_thickness
      right_x3 = @width
      right_y3 = @depth - @back_thickness
      right_z3 = @height - @panel_thickness
      right_x4 = @width
      right_y4 = @depth - @back_thickness
      right_z4 = @panel_thickness

      right_point = [right_x1, right_y1, right_z1]
      right_rectangle = [
        right_point,
        [right_x2, right_y2, right_z2],
        [right_x3, right_y3, right_z3],
        [right_x4, right_y4, right_z4]
      ]

      right_panel = RightPanel.new(@cabinet_entities, Sketchup::Color.new(139, 90, 43), @panel_thickness)
      right_panel.create_face(right_rectangle)
      right_panel.pushpull(@panel_thickness)
    end

def draw_back_panel
      back_x1 = 0
      back_x2 = @width
      back_y = @depth
      back_z1 = 0
      back_z2 = @height

      back_point = [back_x1, back_y, back_z1]
      back_rectangle = [
        back_point,
        [back_x2, back_y, back_z1],
        [back_x2, back_y, back_z2],
        [back_x1, back_y, back_z2]
      ]

      back_panel = BackPanel.new(@cabinet_entities, Sketchup::Color.new(139, 90, 43), @back_thickness)
      back_panel.create_face(back_rectangle)
      back_panel.pushpull(@back_thickness)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_top_panel
      draw_left_panel
      draw_right_panel
      draw_back_panel

      puts "Kitchen cabinet created successfully!"
    end

def self.draw_cabinet
      width = UI.inputbox(["Podaj szerokość szafki (mm):"], ["600"]).first.to_f.mm
      height = UI.inputbox(["Podaj wysokość szafki (mm):"], ["800"]).first.to_f.mm
      depth = UI.inputbox(["Podaj głębokość szafki (mm):"], ["300"]).first.to_f.mm
      panel_thickness = UI.inputbox(["Podaj grubość paneli (mm):"], ["18"]).first.to_f.mm
      back_thickness = UI.inputbox(["Podaj grubość tylnej ścianki (mm):"], ["3"]).first.to_f.mm

      cabinet = Cabinet.new(width, height, depth, panel_thickness, back_thickness)
      cabinet.draw_cabinet
    end
  end
end
