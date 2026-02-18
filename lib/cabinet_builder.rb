require_relative 'cabinet_builder/configuration'
require_relative 'cabinet_builder/geometry'
require_relative 'cabinet_builder/panel_drawing'
require_relative 'cabinet_builder/spatial_profile'
require_relative 'cabinet_builder/metadata'
require_relative 'cabinet_builder/interior_sections'

# Klasa do budowania szafki
module CabinetBuilder
  class Cabinet
    include CabinetConfiguration
    include CabinetGeometry
    include CabinetPanelDrawing
    include CabinetSpatialProfile
    include CabinetMetadata
    include CabinetInteriorSections

    CABINET_DICT = 'cabinet_tool'.freeze

    attr_reader :group, :entities

    def initialize(config = {})
      setup_context
      setup_dimensions(config)
      setup_appearance(config)
      setup_front(config)
      refresh_spatial_profile
      setup_blends(config)
      setup_cokols(config)
      setup_interior_sections(config)
    end

    def draw_bottom_panel
      points = horizontal_rectangle(x_min: 0, x_max: @width, y_min: 0, y_max: @internal_depth, z: 0)
      draw_panel(panel_klass: BottomPanel, points: points, thickness: @panel_thickness, extrusion: -@panel_thickness)
    end

    def draw_top_panel
      top_z = @height - @panel_thickness
      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      y_max = @internal_depth
      return if x_max <= x_min

      unless @kitchen_base_enabled
        points = horizontal_rectangle(x_min: x_min, x_max: x_max, y_min: 0, y_max: y_max, z: top_z)
        draw_panel(panel_klass: TopPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
        return
      end

      connector_width = [@connector_width, y_max / 2.0].min
      return if connector_width <= 0

      front_connector_points = horizontal_rectangle(x_min: x_min, x_max: x_max, y_min: 0, y_max: connector_width, z: top_z)
      back_connector_points = horizontal_rectangle(x_min: x_min, x_max: x_max, y_min: y_max - connector_width, y_max: y_max, z: top_z)

      draw_named_panel(name: 'Top Connector Front', points: front_connector_points, thickness: @panel_thickness, extrusion: @panel_thickness)
      draw_named_panel(name: 'Top Connector Back', points: back_connector_points, thickness: @panel_thickness, extrusion: @panel_thickness)
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
        [0, @corpus_depth, 0],
        [@width, @corpus_depth, 0],
        [@width, @corpus_depth, @height],
        [0, @corpus_depth, @height]
      ]
      draw_panel(panel_klass: BackPanel, points: points, thickness: @back_thickness, extrusion: @back_thickness)
    end

    def draw_front
      return if @filling == 'drawers'
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

        front_group = draw_front_leaf(name: 'Front', points: points)
        draw_front_handle(points, front_group: front_group)
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

        left_front_group = draw_front_leaf(name: 'Front Lewy', points: left_points)
        draw_front_handle(left_points, front_group: left_front_group)
        draw_front_opening_marker(left_points, 'lewo')

        right_points = [
          [@front_technological_gap + left_front_width + @front_technological_gap, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@front_thickness, @front_technological_gap],
          [@front_technological_gap + left_front_width + @front_technological_gap + right_front_width, -@front_thickness, @front_technological_gap + front_height],
          [@front_technological_gap + left_front_width + @front_technological_gap, -@front_thickness, @front_technological_gap + front_height]
        ]

        right_front_group = draw_front_leaf(name: 'Front Prawy', points: right_points)
        draw_front_handle(right_points, front_group: right_front_group)
        draw_front_opening_marker(right_points, 'prawo')
      end
    end

    def draw_front_leaf(name:, points:, entities: @cabinet_entities, extrusion: -@front_thickness)
      case @front_type
      when 'frame'
        draw_frame_front_leaf(name: name, points: points, entities: entities, extrusion: extrusion)
      when 'lamella'
        draw_lamella_front_leaf(name: name, points: points, entities: entities, extrusion: extrusion)
      else
        draw_named_panel(name: name, points: points, thickness: @front_thickness, extrusion: extrusion, entities: entities)
      end
    end

    def draw_lamella_front_leaf(name:, points:, entities: @cabinet_entities, extrusion: -@front_thickness)
      front_group = entities.add_group
      front_group.name = name
      front_group.material = @material_color
      assign_panel_tag(front_group, name)

      front_face = front_group.entities.add_face(points)
      return unless front_face

      front_face.material = @material_color
      front_face.back_material = @material_color
      front_face.pushpull(extrusion)

      x_min = points.map { |point| point[0] }.min
      x_max = points.map { |point| point[0] }.max
      z_min = points.map { |point| point[2] }.min
      z_max = points.map { |point| point[2] }.max
      front_width = x_max - x_min
      return front_group if front_width <= 0 || @groove_width <= 0 || @groove_spacing <= 0 || @groove_depth <= 0

      front_surface = front_group.entities.grep(Sketchup::Face).find do |face|
        y_values = face.vertices.map { |vertex| vertex.position.y }
        y_values.uniq.length == 1 && (y_values.first - points.first[1]).abs < 0.001
      end
      return front_group unless front_surface

      lamella_step = @groove_width + @groove_spacing
      return front_group if lamella_step <= 0

      side_margin = [@groove_spacing / 2.0, front_width / 4.0].min
      start_x = x_min + side_margin
      end_x = x_max - side_margin
      return front_group if end_x <= start_x

      groove_depth = [[@groove_depth, 0].max, @front_thickness * 0.95].min
      return front_group if groove_depth <= 0

      y = points.first[1]
      pushpull_distance = front_surface.normal.y > 0 ? groove_depth : -groove_depth

      x_position = start_x
      while x_position < end_x
        lamella_right = [x_position + @groove_width, end_x].min
        gap_left = lamella_right
        gap_right = [gap_left + @groove_spacing, end_x].min

        if gap_right > gap_left
          groove_face = front_group.entities.add_face(
            [gap_left, y, z_min],
            [gap_right, y, z_min],
            [gap_right, y, z_max],
            [gap_left, y, z_max]
          )

          if groove_face
            groove_face.material = @material_color
            groove_face.back_material = @material_color
            groove_face.pushpull(pushpull_distance)
          end
        end

        x_position += lamella_step
      end

      front_group
    end

    def draw_frame_front_leaf(name:, points:, entities: @cabinet_entities, extrusion: -@front_thickness)
      x_min = points.map { |point| point[0] }.min
      x_max = points.map { |point| point[0] }.max
      z_min = points.map { |point| point[2] }.min
      z_max = points.map { |point| point[2] }.max
      y = points.first[1]

      front_width = x_max - x_min
      front_height = z_max - z_min
      frame_width = [@frame_width, front_width / 2.0, front_height / 2.0].min
      inner_panel_thickness = [[@frame_inner_thickness, 0].max, @front_thickness].min
      inner_recess_depth = [@front_thickness - inner_panel_thickness, 0].max

      return draw_named_panel(name: name, points: points, thickness: @front_thickness, extrusion: extrusion, entities: entities) if frame_width <= 0

      frame_group = draw_frame_with_offset(
        name: "#{name} Ramka",
        outer_points: points,
        frame_width: frame_width,
        extrusion: extrusion,
        entities: entities
      )

      inner_x_min = x_min + frame_width
      inner_x_max = x_max - frame_width
      inner_z_min = z_min + frame_width
      inner_z_max = z_max - frame_width
      return frame_group if inner_x_max <= inner_x_min || inner_z_max <= inner_z_min

      bevel_inset = frame_inner_bevel_inset(
        frame_width: frame_width,
        recess_depth: inner_recess_depth,
        inner_width: inner_x_max - inner_x_min,
        inner_height: inner_z_max - inner_z_min
      )

      inner_x_min += bevel_inset
      inner_x_max -= bevel_inset
      inner_z_min += bevel_inset
      inner_z_max -= bevel_inset
      return frame_group if inner_x_max <= inner_x_min || inner_z_max <= inner_z_min

      inner_front_y = y + inner_recess_depth
      inner_points = [
        [inner_x_min, inner_front_y, inner_z_min],
        [inner_x_max, inner_front_y, inner_z_min],
        [inner_x_max, inner_front_y, inner_z_max],
        [inner_x_min, inner_front_y, inner_z_max]
      ]

      draw_frame_inner_transition(
        name: "#{name} Przejście",
        front_y: y,
        inner_y: inner_front_y,
        front_rect: [
          [x_min + frame_width, y, z_min + frame_width],
          [x_max - frame_width, y, z_min + frame_width],
          [x_max - frame_width, y, z_max - frame_width],
          [x_min + frame_width, y, z_max - frame_width]
        ],
        inner_rect: inner_points
      )

      unless inner_panel_thickness <= 0
        # Wnętrze osadzamy od tylnej strony frontu (przy korpusie),
        # dzięki czemu od frontu otrzymujemy efekt wnęki o zadanej głębokości.
        draw_named_panel(name: "#{name} Wnętrze", points: inner_points, thickness: inner_panel_thickness, extrusion: -inner_panel_thickness)
      end

      frame_group
    end

    def frame_inner_bevel_inset(frame_width:, recess_depth:, inner_width:, inner_height:)
      return 0 if recess_depth <= 0

      max_inset = [inner_width / 4.0, inner_height / 4.0].min
      desired = [frame_width * 0.2, recess_depth * 0.6].min
      [[desired, 0].max, max_inset].min
    end

    def draw_frame_inner_transition(name:, front_y:, inner_y:, front_rect:, inner_rect:)
      return if inner_y <= front_y

      transition_group = @cabinet_entities.add_group
      transition_group.name = name
      transition_group.material = @material_color
      assign_panel_tag(transition_group, name)

      entities = transition_group.entities

      4.times do |index|
        front_start = front_rect[index]
        front_end = front_rect[(index + 1) % 4]
        inner_end = inner_rect[(index + 1) % 4]
        inner_start = inner_rect[index]

        face = entities.add_face(front_start, front_end, inner_end, inner_start)
        next unless face

        face.material = @material_color
        face.back_material = @material_color
      end
    end

    def draw_frame_with_offset(name:, outer_points:, frame_width:, extrusion:, entities: @cabinet_entities)
      frame_group = entities.add_group
      frame_group.name = name
      frame_group.material = @material_color
      assign_panel_tag(frame_group, name)

      entities = frame_group.entities
      outer_face = entities.add_face(outer_points)
      return unless outer_face
      outer_face.material = @material_color
      outer_face.back_material = @material_color

      x_min = outer_points.map { |point| point[0] }.min
      x_max = outer_points.map { |point| point[0] }.max
      z_min = outer_points.map { |point| point[2] }.min
      z_max = outer_points.map { |point| point[2] }.max
      y = outer_points.first[1]

      inner_points = [
        [x_min + frame_width, y, z_min + frame_width],
        [x_max - frame_width, y, z_min + frame_width],
        [x_max - frame_width, y, z_max - frame_width],
        [x_min + frame_width, y, z_max - frame_width]
      ]

      inner_face = entities.add_face(inner_points)
      inner_face.erase! if inner_face&.valid?

      frame_face = entities.grep(Sketchup::Face).max_by(&:area)
      return unless frame_face

      frame_face.pushpull(extrusion)
      entities.grep(Sketchup::Face).each do |face|
        face.material = @material_color
        face.back_material = @material_color
      end

      frame_group
    end


    def draw_front_handle(front_points, front_group: nil)
      return unless @front_handle.to_s.casecmp('j').zero?

      handle_definition = front_handle_definition
      return unless handle_definition

      left_x = front_points.map { |point| point[0] }.min
      right_x = front_points.map { |point| point[0] }.max
      bottom_z = front_points.map { |point| point[2] }.min
      top_z = front_points.map { |point| point[2] }.max
      y = front_points[0][1]

      insertion_point = Geom::Point3d.new(right_x, y, handle_insertion_z(bottom_z: bottom_z, top_z: top_z))
      rotation_y = Geom::Transformation.rotation(ORIGIN, Y_AXIS, 0.degrees)
      transform = Geom::Transformation.translation(insertion_point) * rotation_y
      target_entities = front_group ? front_group.entities : @cabinet_entities
      existing_entities = target_entities.to_a

      handle_instance = target_entities.add_instance(handle_definition, transform)
      handle_instance.explode

      handle_entities = target_entities.to_a - existing_entities
      stretch_handle_with_pushpull(handle_entities: handle_entities, left_x: left_x, right_x: right_x)
      apply_handle_material(handle_entities)
    end

    def handle_insertion_z(bottom_z:, top_z:)
      case @front_handle_position
      when 'gora'
        top_z
      when 'srodek'
        (bottom_z + top_z) / 2.0
      else
        bottom_z
      end
    end

    def stretch_handle_with_pushpull(handle_entities:, left_x:, right_x:)
      return if handle_entities.empty?

      handle_faces = handle_entities.grep(Sketchup::Face)
      return if handle_faces.empty?

      handle_bounds = handle_faces.map(&:bounds)
      handle_min_x = handle_bounds.map { |bounds| bounds.min.x }.min
      handle_max_x = handle_bounds.map { |bounds| bounds.max.x }.max
      return if handle_min_x.nil? || handle_max_x.nil?

      align_right = right_x - handle_max_x
      if align_right.abs > 0.001
        move_right = Geom::Transformation.translation([align_right, 0, 0])
        handle_entities.each { |entity| entity.transform!(move_right) if entity.respond_to?(:transform!) && entity.valid? }
      end

      aligned_min_x = handle_min_x + align_right
      extension = aligned_min_x - left_x
      return if extension <= 0.001

      left_cap = handle_faces
                 .select(&:valid?)
                 .select { |face| face.normal.x.abs > 0.9 }
                 .select { |face| (face.bounds.min.x - aligned_min_x).abs < 0.5 }
                 .max_by(&:area)
      return unless left_cap

      pushpull_distance = left_cap.normal.x < 0 ? extension : -extension
      left_cap.pushpull(pushpull_distance)
    end

    def apply_handle_material(handle_entities)
      handle_entities.grep(Sketchup::Face).each do |face|
        next unless face.valid?

        face.material = @material_color
        face.back_material = @material_color
      end
    end

    def front_handle_definition
      return @front_handle_definition if defined?(@front_handle_definition)

      handle_path = File.expand_path('../assets/handles/uchwyt-j.skp', __dir__)
      @front_handle_definition = if File.exist?(handle_path)
                                   @model.definitions.load(handle_path)
                                 end
    rescue StandardError => e
      puts "Nie udało się wczytać uchwytu J: #{e.message}"
      @front_handle_definition = nil
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

    def opening_direction_tag(suffix = nil)
      tag_name = "[L]#{@nazwa_szafki}_kierunek-otwarcia"
      tag_name = "#{tag_name}_#{suffix}" if suffix
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
          [[right_x, y, top_z], [left_x, y, bottom_z]],
          [[left_x, y, bottom_z], [right_x, y, bottom_z]]
        ]
      else
        []
      end
    end

    def draw_drawers
      return unless @filling == 'drawers'
      return if @drawer_count <= 0

      drawer_gap = @front_technological_gap
      available_height = @height - ((@drawer_count + 1) * drawer_gap)
      drawer_width = @width - (2 * drawer_gap)
      return if available_height <= 0 || drawer_width <= 0

      drawer_heights = if @drawers_asymmetric && @drawer_count > 1
        first_height = @first_drawer_height
        remaining_height = available_height - first_height
        other_drawers_count = @drawer_count - 1
        other_height = remaining_height / other_drawers_count.to_f
        [first_height] + Array.new(other_drawers_count, other_height)
      else
        equal_height = available_height / @drawer_count.to_f
        Array.new(@drawer_count, equal_height)
      end

      return if drawer_heights.any? { |height| height <= 0 }

      drawers_tag = opening_direction_tag('szuflady')
      ordered_heights = if @drawers_asymmetric && @drawer_count > 1
        drawer_heights.reverse
      else
        drawer_heights
      end
      current_z = drawer_gap

      ordered_heights.each_with_index do |drawer_height, index|
        z_bottom = current_z
        z_top = z_bottom + drawer_height

        points = [
          [drawer_gap, -@front_thickness, z_bottom],
          [drawer_gap + drawer_width, -@front_thickness, z_bottom],
          [drawer_gap + drawer_width, -@front_thickness, z_top],
          [drawer_gap, -@front_thickness, z_top]
        ]

        draw_named_panel(name: "Front Szuflady #{index + 1}", points: points, thickness: @front_thickness, extrusion: -@front_thickness)

        marker_segments = front_opening_marker_segments(points, 'wysów')
        next if marker_segments.empty?

        marker_group = @cabinet_entities.add_group
        marker_group.name = "[L]#{@nazwa_szafki}_kierunek-otwarcia_szuflada-#{index + 1}"
        marker_group.layer = drawers_tag

        marker_segments.each do |start_point, end_point|
          marker_group.entities.add_line(start_point, end_point)
        end

        current_z = z_top + drawer_gap
      end
    end

    def draw_shelves
      return unless @filling == 'shelves'
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
          y_max: @internal_depth,
          z: shelf_z
        )

        draw_named_panel(name: "Shelf #{i + 1}", points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
      end
    end

def draw_blend_left
  return unless @blend_left_value > 0

  has_front_surface = front_surface_enabled?
  max_depth = @blend_left_depth_value > 0 ? @blend_left_depth_value : @internal_depth + (has_front_surface ? @front_thickness : 0)
  y_offset = has_front_surface ? -@front_thickness : 0
  blend_bottom_z = @panel_thickness
  blend_top_z = @height
  return if blend_top_z <= blend_bottom_z

  points = [
    [0, y_offset, blend_bottom_z],
    [0, y_offset, blend_top_z],
    [0, max_depth + y_offset, blend_top_z],
    [0, max_depth + y_offset, blend_bottom_z]
  ]

  draw_named_panel(name: 'Blend Left', points: points, thickness: @blend_left_value, extrusion: @blend_left_value)
end

def draw_blend_right
  return unless @blend_right_value > 0

  has_front_surface = front_surface_enabled?
  y_offset = has_front_surface ? -@front_thickness : 0
  x = @width + @blend_right_value
  max_depth = @blend_right_depth_value > 0 ? @blend_right_depth_value : @internal_depth + (has_front_surface ? @front_thickness : 0)
  blend_bottom_z = @panel_thickness
  blend_top_z = @height
  return if blend_top_z <= blend_bottom_z

  points = [
    [x, y_offset, blend_bottom_z],
    [x, y_offset, blend_top_z],
    [x, max_depth + y_offset, blend_top_z],
    [x, max_depth + y_offset, blend_bottom_z]
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

      has_front_surface = front_surface_enabled?
      y_offset = (has_front_surface ? -@front_thickness : 0) + @cokol_gorny_offset_value
      cokol_gorny_thickness = has_front_surface ? @front_thickness : @panel_thickness
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
      draw_drawers
      draw_shelves
      draw_interior_sections
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
