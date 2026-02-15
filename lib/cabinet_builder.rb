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
      setup_cokols(config)
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
          [@front_technological_gap, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + front_width, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + front_width, -@front_thickness, @front_technological_gap + front_height],
          [@front_technological_gap, -@front_thickness, @front_technological_gap + front_height]
        ]

        draw_named_panel(name: 'Front', points: points, thickness: @front_thickness, extrusion: -@front_thickness)
        draw_front_opening_marker(points, @front_opening_direction)
      elsif @front_quantity == 2
        half_width = (front_width - @front_technological_gap) / 2
        left_front_width = half_width
        right_front_width = half_width

        left_points = [
          [@front_technological_gap, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width, -@front_thickness, @front_technological_gap + front_height],
          [@front_technological_gap, -@front_thickness, @front_technological_gap + front_height]
        ]

        draw_named_panel(name: 'Front Lewy', points: left_points, thickness: @front_thickness, extrusion: -@front_thickness)
        draw_front_opening_marker(left_points, 'lewo')

        right_points = [
          [@front_technological_gap + left_front_width + @front_technological_gap, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@front_thickness, @front_technological_gap + front_height],
          [@front_technological_gap + left_front_width + @front_technological_gap, -@front_thickness, @front_technological_gap + front_height]
        ]

        draw_named_panel(name: 'Front Prawy', points: right_points, thickness: @front_thickness, extrusion: -@front_thickness)
        draw_front_opening_marker(right_points, 'prawo')
      end
    end

    def draw_front_opening_marker(front_points, opening_direction)
      marker_segments = front_opening_marker_segments(front_points, opening_direction)
      return if marker_segments.empty?

      marker_group = @cabinet_entities.add_group
      marker_group.name = "[L]#{@nazwa_szafki}_kierunek-otwarcia"
      marker_group.layer = opening_direction_tag

      marker_segments.each do |start_point, end_point|
        marker_group.entities.add_line(start_point, end_point)
      end
    end

    def opening_direction_tag
      tag_name = "[L]#{@nazwa_szafki}_kierunek-otwarcia"
      @model.layers[tag_name] || @model.layers.add(tag_name)
    end

    def front_opening_marker_segments(front_points, opening_direction)
      left_x = front_points.map { |point| point[0] }.min
      right_x = front_points.map { |point| point[0] }.max
      bottom_z = front_points.map { |point| point[2] }.min
      top_z = front_points.map { |point| point[2] }.max
      y = front_points[0][1]
      middle_x = (left_x + right_x) / 2.0
      middle_z = (bottom_z + top_z) / 2.0

      case opening_direction
      when 'prawo'
        [
          [[right_x, y, top_z], [left_x, y, middle_z]],
          [[left_x, y, middle_z], [right_x, y, bottom_z]]
        ]
      when 'lewo'
        [
          [[left_x, y, top_z], [right_x, y, middle_z]],
          [[right_x, y, middle_z], [left_x, y, bottom_z]]
        ]
      when 'góra'
        [
          [[left_x, y, top_z], [middle_x, y, bottom_z]],
          [[right_x, y, top_z], [middle_x, y, bottom_z]]
        ]
      when 'dół'
        [
          [[left_x, y, bottom_z], [middle_x, y, top_z]],
          [[right_x, y, bottom_z], [middle_x, y, top_z]]
        ]
      when 'wysów'
        [
          [[left_x, y, top_z], [right_x, y, bottom_z]],
          [[right_x, y, top_z], [left_x, y, bottom_z]]
        ]
      else
        []
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

  max_depth = @blend_left_depth_value > 0 ? @blend_left_depth_value : @depth - @back_thickness + (@front_enabled ? @front_thickness : 0)
  y_offset = @front_enabled ? -@front_thickness : 0
  points = [
    [0, y_offset, 0],
    [0, y_offset, @height],
    [0, max_depth + y_offset, @height],
    [0, max_depth + y_offset, 0]
  ]

  draw_named_panel(name: 'Blend Left', points: points, thickness: @blend_left_value, extrusion: @blend_left_value)
end

def draw_blend_right
  return unless @blend_right_value > 0

  y_offset = @front_enabled ? -@front_thickness : 0
  x = @width + @blend_right_value
  max_depth = @blend_right_depth_value > 0 ? @blend_right_depth_value : @depth - @back_thickness + (@front_enabled ? @front_thickness : 0)
  points = [
    [x, y_offset, 0],
    [x, y_offset, @height],
    [x, max_depth + y_offset, @height],
    [x, max_depth + y_offset, 0]
  ]

  draw_named_panel(name: 'Blend Right', points: points, thickness: @blend_right_value, extrusion: @blend_right_value)
end

    def draw_cokol_dolny
      return unless @cokol_dolny_value > 0

      y_offset = @cokol_dolny_offset_value
      points = [
        [0, y_offset, -@cokol_dolny_value],
        [@width, y_offset, -@cokol_dolny_value],
        [@width, y_offset, 0],
        [0, y_offset, 0]
      ]

      draw_named_panel(name: 'Cokol Dolny', points: points, thickness: @panel_thickness, extrusion: -@panel_thickness)
    end

    def draw_cokol_gorny
      return unless @cokol_gorny_value > 0

      y_offset = (@front_enabled ? -@front_thickness : 0) + @cokol_gorny_offset_value
      cokol_gorny_thickness = @front_enabled ? @front_thickness : @panel_thickness
      points = [
        [0, y_offset, @height],
        [@width, y_offset, @height],
        [@width, y_offset, @height + @cokol_gorny_value],
        [0, y_offset, @height + @cokol_gorny_value]
      ]

      draw_named_panel(name: 'Cokol Gorny', points: points, thickness: cokol_gorny_thickness, extrusion: -cokol_gorny_thickness)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_cokol_dolny
      draw_top_panel
      draw_cokol_gorny
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
