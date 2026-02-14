require_relative 'cabinet_builder/configuration'
require_relative 'cabinet_builder/geometry'
require_relative 'cabinet_builder/panel_drawing'
require_relative 'cabinet_builder/metadata'

# Klasa do budowania szafki
module CabinetBuilder
  class Cabinet
    include CabinetConfiguration
    include CabinetGeometry
    include CabinetPanelDrawing
    include CabinetMetadata

    CABINET_DICT = 'cabinet_tool'.freeze

    attr_reader :group, :entities

    def initialize(config = {})
      setup_context
      setup_dimensions(config)
      setup_appearance(config)
      setup_front(config)
      setup_blends(config)
    end

    def draw_bottom_panel
      points = horizontal_rectangle(x_min: 0, x_max: @width, y_min: 0, y_max: @depth - @back_thickness, z: 0)
      draw_panel(panel_klass: BottomPanel, points: points, thickness: @panel_thickness, extrusion: -@panel_thickness)
    end

    def draw_top_panel
      top_z = @height - @panel_thickness
      points = horizontal_rectangle(x_min: 0, x_max: @width, y_min: 0, y_max: @depth - @back_thickness, z: top_z)
      draw_panel(panel_klass: TopPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_left_panel
      points = vertical_side_rectangle(x: @panel_thickness)
      draw_panel(panel_klass: LeftPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_right_panel
      points = vertical_side_rectangle(x: @width)
      draw_panel(panel_klass: RightPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_back_panel
      points = [
        [0, @depth, 0],
        [@width, @depth, 0],
        [@width, @depth, @height],
        [0, @depth, @height]
      ]
      draw_panel(panel_klass: BackPanel, points: points, thickness: @back_thickness, extrusion: @back_thickness)
    end

def draw_front
  return unless @front_enabled

  front_width = @width - (2 * @front_technological_gap)
  front_height = @height - (2 * @front_technological_gap)
  return if front_width <= 0 || front_height <= 0

  if @front_quantity == 1
    points = [
      [@front_technological_gap, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + front_width, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + front_width, -@panel_thickness, @front_technological_gap + front_height],
      [@front_technological_gap, -@panel_thickness, @front_technological_gap + front_height]
    ]

    draw_named_panel(name: 'Front', points: points, thickness: @panel_thickness, extrusion: -@panel_thickness)
  elsif @front_quantity == 2
    half_width = (front_width - @front_technological_gap) / 2
    left_front_width = half_width
    right_front_width = half_width

    # Lewy front
    left_points = [
      [@front_technological_gap, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + left_front_width, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + left_front_width, -@panel_thickness, @front_technological_gap + front_height],
      [@front_technological_gap, -@panel_thickness, @front_technological_gap + front_height]
    ]

    draw_named_panel(name: 'Front Lewy', points: left_points, thickness: @panel_thickness, extrusion: -@panel_thickness)

    # Prawy front
    right_points = [
      [@front_technological_gap + left_front_width + @front_technological_gap, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@panel_thickness, @front_technological_gap],
      [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@panel_thickness, @front_technological_gap + front_height],
      [@front_technological_gap + left_front_width + @front_technological_gap, -@panel_thickness, @front_technological_gap + front_height]
    ]

    draw_named_panel(name: 'Front Prawy', points: right_points, thickness: @panel_thickness, extrusion: -@panel_thickness)
  end
end

    def draw_shelves
      return if @shelf_count <= 0

      internal_height = @height - (2 * @panel_thickness)
      total_shelves_thickness = @shelf_count * @panel_thickness
      free_openings_height = internal_height - total_shelves_thickness
      opening_height = free_openings_height / (@shelf_count + 1)

      return if opening_height < 0

      @shelf_count.times do |i|
        shelf_z = @panel_thickness + ((i + 1) * opening_height) + (i * @panel_thickness)
        points = horizontal_rectangle(
          x_min: @panel_thickness,
          x_max: @width - @panel_thickness,
          y_min: 0,
          y_max: @depth - @back_thickness,
          z: shelf_z
        )

        draw_named_panel(name: "Shelf #{i + 1}", points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
      end
    end

    def draw_blend_left
      return unless @blend_left_value > 0

      max_depth = @blend_left_depth_value > 0 ? @blend_left_depth_value : @depth - @back_thickness
      points = [
        [0, 0, 0],
        [0, 0, @height],
        [0, max_depth, @height],
        [0, max_depth, 0]
      ]

      draw_named_panel(name: 'Blend Left', points: points, thickness: @blend_left_value, extrusion: @blend_left_value)
    end

    def draw_blend_right
      return unless @blend_right_value > 0

      x = @width + @blend_right_value
      max_depth = @blend_right_depth_value > 0 ? @blend_right_depth_value : @depth - @back_thickness
      points = [
        [x, 0, 0],
        [x, 0, @height],
        [x, max_depth, @height],
        [x, max_depth, 0]
      ]

      draw_named_panel(name: 'Blend Right', points: points, thickness: @blend_right_value, extrusion: @blend_right_value)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_top_panel
      draw_left_panel
      draw_right_panel
      draw_back_panel
      draw_front
      draw_shelves
      draw_blend_left
      draw_blend_right
      save_metadata

      @group
    end

    def self.draw_cabinet(params = {})
      Cabinet.new(params).draw_cabinet
    end
  end
end
