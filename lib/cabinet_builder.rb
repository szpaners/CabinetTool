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
      @group.name = 'Bottom Panel'
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
      @group.name = 'Top Panel'
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
      @group.name = 'Left Panel'
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
      @group.name = 'Right Panel'
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
      @group.name = 'Back Panel'
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
    CABINET_DICT = 'cabinet_tool'.freeze

    attr_reader :group, :entities

    def initialize(width, height, depth, panel_thickness, back_thickness, color = CabinetDimensions::DEFAULT_COLOR, filling = 'none', shelf_count = 0, blend_left_value = 0, blend_right_value = 0, blend_left_depth_value = 0, blend_right_depth_value = 0)
      @model = Sketchup.active_model
      @entities = @model.active_entities
      @group = @entities.add_group
      @cabinet_entities = @group.entities
      @width = width.to_f
      @height = height.to_f
      @depth = depth.to_f
      @panel_thickness = panel_thickness.to_f
      @back_thickness = back_thickness.to_f
      @color = color
      @material_color = Sketchup::Color.new(color)
      @filling = filling
      @shelf_count = shelf_count
      @blend_left_value = blend_left_value.to_f
      @blend_right_value = blend_right_value.to_f
      @blend_left_depth_value = blend_left_depth_value.to_f
      @blend_right_depth_value = blend_right_depth_value.to_f
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

      bottom_rectangle = [
        [bottom_x1, bottom_y1, bottom_z1],
        [bottom_x2, bottom_y2, bottom_z2],
        [bottom_x3, bottom_y3, bottom_z3],
        [bottom_x4, bottom_y4, bottom_z4]
      ]

      bottom_panel = BottomPanel.new(@cabinet_entities, @material_color, @panel_thickness)
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

      top_rectangle = [
        [top_x1, top_y1, top_z1],
        [top_x2, top_y2, top_z2],
        [top_x3, top_y3, top_z3],
        [top_x4, top_y4, top_z4]
      ]

      top_panel = TopPanel.new(@cabinet_entities, @material_color, @panel_thickness)
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

      left_rectangle = [
        [left_x1, left_y1, left_z1],
        [left_x2, left_y2, left_z2],
        [left_x3, left_y3, left_z3],
        [left_x4, left_y4, left_z4]
      ]

      left_panel = LeftPanel.new(@cabinet_entities, @material_color, @panel_thickness)
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

      right_rectangle = [
        [right_x1, right_y1, right_z1],
        [right_x2, right_y2, right_z2],
        [right_x3, right_y3, right_z3],
        [right_x4, right_y4, right_z4]
      ]

      right_panel = RightPanel.new(@cabinet_entities, @material_color, @panel_thickness)
      right_panel.create_face(right_rectangle)
      right_panel.pushpull(@panel_thickness)
    end

    def draw_back_panel
      back_x1 = 0
      back_x2 = @width
      back_y = @depth
      back_z1 = 0
      back_z2 = @height

      back_rectangle = [
        [back_x1, back_y, back_z1],
        [back_x2, back_y, back_z1],
        [back_x2, back_y, back_z2],
        [back_x1, back_y, back_z2]
      ]

      back_panel = BackPanel.new(@cabinet_entities, @material_color, @back_thickness)
      back_panel.create_face(back_rectangle)
      back_panel.pushpull(@back_thickness)
    end

    def draw_shelves
      return if @shelf_count <= 0

      internal_height = @height - (2 * @panel_thickness)
      total_shelves_thickness = @shelf_count * @panel_thickness
      free_openings_height = internal_height - total_shelves_thickness
      opening_height = free_openings_height / (@shelf_count + 1)

      return if opening_height < 0

      (@shelf_count).times do |i|
        shelf_z = @panel_thickness + ((i + 1) * opening_height) + (i * @panel_thickness)

        shelf_x1 = @panel_thickness
        shelf_y1 = 0
        shelf_z1 = shelf_z
        shelf_x2 = @width - @panel_thickness
        shelf_y2 = 0
        shelf_z2 = shelf_z
        shelf_x3 = @width - @panel_thickness
        shelf_y3 = @depth - @back_thickness
        shelf_z3 = shelf_z
        shelf_x4 = @panel_thickness
        shelf_y4 = @depth - @back_thickness
        shelf_z4 = shelf_z

        shelf_rectangle = [
          [shelf_x1, shelf_y1, shelf_z1],
          [shelf_x2, shelf_y2, shelf_z2],
          [shelf_x3, shelf_y3, shelf_z3],
          [shelf_x4, shelf_y4, shelf_z4]
        ]

        shelf_panel = Panel.new(@cabinet_entities, "Shelf #{i + 1}", @material_color, @panel_thickness)
        shelf_panel.create_face(shelf_rectangle)
        shelf_panel.pushpull(@panel_thickness)
      end
    end

    def draw_blend_left
      return unless @blend_left_value > 0

      blend_x1 = 0
      blend_y1 = 0
      blend_z1 = 0
      blend_x2 = 0
      blend_y2 = 0
      blend_z2 = @height
      blend_x3 = 0
      blend_y3 = @blend_left_depth_value > 0 ? @blend_left_depth_value : @depth - @back_thickness
      blend_z3 = @height
      blend_x4 = 0
      blend_y4 = @blend_left_depth_value > 0 ? @blend_left_depth_value : @depth - @back_thickness
      blend_z4 = 0

      blend_rectangle = [
        [blend_x1, blend_y1, blend_z1],
        [blend_x2, blend_y2, blend_z2],
        [blend_x3, blend_y3, blend_z3],
        [blend_x4, blend_y4, blend_z4]
      ]

      blend_panel = Panel.new(@cabinet_entities, "Blend Left", @material_color, @blend_left_value)
      blend_panel.create_face(blend_rectangle)
      blend_panel.pushpull(@blend_left_value)
    end

    def draw_blend_right
      return unless @blend_right_value > 0
      blend_x1 = @width + @blend_right_value
      blend_y1 = 0
      blend_z1 = 0
      blend_x2 = @width + @blend_right_value
      blend_y2 = 0
      blend_z2 = @height
      blend_x3 = @width + @blend_right_value
      blend_y3 = @blend_right_depth_value > 0 ? @blend_right_depth_value : @depth - @back_thickness
      blend_z3 = @height
      blend_x4 = @width + @blend_right_value
      blend_y4 = @blend_right_depth_value > 0 ? @blend_right_depth_value : @depth - @back_thickness
      blend_z4 = 0

      blend_rectangle = [
        [blend_x1, blend_y1, blend_z1],
        [blend_x2, blend_y2, blend_z2],
        [blend_x3, blend_y3, blend_z3],
        [blend_x4, blend_y4, blend_z4]
      ]

      blend_panel = Panel.new(@cabinet_entities, "Blend Right", @material_color, @blend_right_value)
      blend_panel.create_face(blend_rectangle)
      blend_panel.pushpull(@blend_right_value)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_top_panel
      draw_left_panel
      draw_right_panel
      draw_back_panel
      draw_shelves
      draw_blend_left
      draw_blend_right
      save_metadata

      @group
    end

    def self.draw_cabinet(params = {})
      width = params['width'] || CabinetDimensions::CABINET_WIDTH
      height = params['height'] || CabinetDimensions::CABINET_HEIGHT
      depth = params['depth'] || CabinetDimensions::CABINET_DEPTH
      panel_thickness = params['panel_thickness'] || CabinetDimensions::PANEL_THICKNESS
      back_thickness = params['back_thickness'] || CabinetDimensions::PANEL_THICKNESS_BACK
      color = params['color'] || CabinetDimensions::DEFAULT_COLOR
      filling = params['filling'] || 'none'
      shelf_count = params['shelf_count'] || 0
      blend_left_value = params['blend_left_value'] || 0
      blend_right_value = params['blend_right_value'] || 0
      blend_left_depth_value = params['blend_left_depth_value'] || 0
      blend_right_depth_value = params['blend_right_depth_value'] || 0

      cabinet = Cabinet.new(width, height, depth, panel_thickness, back_thickness, color, filling, shelf_count, blend_left_value, blend_right_value, blend_left_depth_value, blend_right_depth_value)
      cabinet.draw_cabinet
    end

    def self.read_params_from_group(group)
      return nil unless group

      {
        'width' => group.get_attribute(CABINET_DICT, 'width_mm', CabinetDimensions::CABINET_WIDTH.to_mm),
        'height' => group.get_attribute(CABINET_DICT, 'height_mm', CabinetDimensions::CABINET_HEIGHT.to_mm),
        'depth' => group.get_attribute(CABINET_DICT, 'depth_mm', CabinetDimensions::CABINET_DEPTH.to_mm),
        'panel_thickness' => group.get_attribute(CABINET_DICT, 'panel_thickness_mm', CabinetDimensions::PANEL_THICKNESS.to_mm),
        'back_thickness' => group.get_attribute(CABINET_DICT, 'back_thickness_mm', CabinetDimensions::PANEL_THICKNESS_BACK.to_mm),
        'color' => group.get_attribute(CABINET_DICT, 'color', CabinetDimensions::DEFAULT_COLOR),
        'filling' => group.get_attribute(CABINET_DICT, 'filling', 'none'),
        'shelf_count' => group.get_attribute(CABINET_DICT, 'shelf_count', 0),
        'blend_left_value' => group.get_attribute(CABINET_DICT, 'blend_left_value', 0),
        'blend_right_value' => group.get_attribute(CABINET_DICT, 'blend_right_value', 0),
        'blend_left_depth_value' => group.get_attribute(CABINET_DICT, 'blend_left_depth_value', 0),
        'blend_right_depth_value' => group.get_attribute(CABINET_DICT, 'blend_right_depth_value', 0)
      }
    end

    def self.find_selected_cabinet_group
      model = Sketchup.active_model
      return nil unless model

      model.selection.each do |entity|
        group = find_cabinet_group_for_entity(entity)
        return group if group
      end

      nil
    end

    def self.find_cabinet_group_for_entity(entity)
      current = entity
      until current.nil?
        if current.is_a?(Sketchup::Group) && current.get_attribute(CABINET_DICT, 'is_cabinet', false)
          return current
        end

        current = current.respond_to?(:parent) ? current.parent : nil
      end

      nil
    end

    private

    def save_metadata
      @group.set_attribute(CABINET_DICT, 'is_cabinet', true)
      @group.set_attribute(CABINET_DICT, 'width_mm', @width.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'height_mm', @height.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'depth_mm', @depth.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'panel_thickness_mm', @panel_thickness.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'back_thickness_mm', @back_thickness.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'color', @color)
      @group.set_attribute(CABINET_DICT, 'filling', @filling)
      @group.set_attribute(CABINET_DICT, 'shelf_count', @shelf_count)
      @group.set_attribute(CABINET_DICT, 'blend_left_value', @blend_left_value)
      @group.set_attribute(CABINET_DICT, 'blend_right_value', @blend_right_value)
      @group.set_attribute(CABINET_DICT, 'blend_left_depth_value', @blend_left_depth_value)
      @group.set_attribute(CABINET_DICT, 'blend_right_depth_value', @blend_right_depth_value)
    end
  end
end
