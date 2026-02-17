require 'json'

module CabinetBuilder
  module CabinetMetadata
    CABINET_DICT = 'cabinet_tool'.freeze
    METADATA_FIELDS = {
      'width_mm' => :@width,
      'height_mm' => :@height_total,
      'depth_mm' => :@depth,
      'panel_thickness_mm' => :@panel_thickness,
      'back_thickness_mm' => :@back_thickness,
      'front_technological_gap_mm' => :@front_technological_gap,
      'first_drawer_height_mm' => :@first_drawer_height,
      'front_thickness' => :@front_thickness,
      'blend_left_value_mm' => :@blend_left_value,
      'blend_right_value_mm' => :@blend_right_value,
      'blend_left_depth_value_mm' => :@blend_left_depth_value,
      'blend_right_depth_value_mm' => :@blend_right_depth_value,
      'cokol_dolny_value_mm' => :@cokol_dolny_value,
      'cokol_gorny_value_mm' => :@cokol_gorny_value,
      'cokol_dolny_offset_value_mm' => :@cokol_dolny_offset_value,
      'cokol_gorny_offset_value_mm' => :@cokol_gorny_offset_value,
      'frame_width_mm' => :@frame_width,
      'frame_inner_thickness_mm' => :@frame_inner_thickness,
      'groove_width_mm' => :@groove_width,
      'groove_spacing_mm' => :@groove_spacing,
      'groove_depth_mm' => :@groove_depth,
      'connector_width_mm' => :@connector_width
    }.freeze

    LEGACY_BLEND_KEYS = {
      'blend_left_value' => { mm: 'blend_left_value_mm', legacy: 'blend_left_value' },
      'blend_right_value' => { mm: 'blend_right_value_mm', legacy: 'blend_right_value' },
      'blend_left_depth_value' => { mm: 'blend_left_depth_value_mm', legacy: 'blend_left_depth_value' },
      'blend_right_depth_value' => { mm: 'blend_right_depth_value_mm', legacy: 'blend_right_depth_value' }
    }.freeze

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def read_params_from_group(group)
        return nil unless group

        {
          'width' => group.get_attribute(CABINET_DICT, 'width_mm', CabinetDimensions::CABINET_WIDTH.to_mm),
          'height' => group.get_attribute(
            CABINET_DICT,
            'height_total_mm',
            group.get_attribute(CABINET_DICT, 'height_mm', CabinetDimensions::CABINET_HEIGHT.to_mm)
          ),
          'depth' => group.get_attribute(CABINET_DICT, 'depth_mm', CabinetDimensions::CABINET_DEPTH.to_mm),
          'panel_thickness' => group.get_attribute(CABINET_DICT, 'panel_thickness_mm', CabinetDimensions::PANEL_THICKNESS.to_mm),
          'back_thickness' => group.get_attribute(CABINET_DICT, 'back_thickness_mm', CabinetDimensions::PANEL_THICKNESS_BACK.to_mm),
          'nazwa_szafki' => group.get_attribute(CABINET_DICT, 'nazwa_szafki', 'szafka'),
          'color' => group.get_attribute(CABINET_DICT, 'color', CabinetDimensions::DEFAULT_COLOR),
          'cabinet_type' => group.get_attribute(CABINET_DICT, 'cabinet_type', 'kitchen'),
          'filling' => group.get_attribute(CABINET_DICT, 'filling', 'none'),
          'shelf_count' => group.get_attribute(CABINET_DICT, 'shelf_count', 0),
          'drawer_count' => group.get_attribute(CABINET_DICT, 'drawer_count', 0),
          'drawers_asymmetric' => group.get_attribute(CABINET_DICT, 'drawers_asymmetric', false),
          'first_drawer_height' => group.get_attribute(CABINET_DICT, 'first_drawer_height_mm', 0),
          'front_enabled' => group.get_attribute(CABINET_DICT, 'front_enabled', false),
          'front_thickness' => group.get_attribute(CABINET_DICT, 'front_thickness', CabinetDimensions::FRONT_THICKNESS),
          'front_technological_gap' => group.get_attribute(CABINET_DICT, 'front_technological_gap_mm', 0),
          'front_quantity' => group.get_attribute(CABINET_DICT, 'front_quantity', 1),
          'front_type' => group.get_attribute(CABINET_DICT, 'front_type', 'flat'),
          'frame_width' => group.get_attribute(CABINET_DICT, 'frame_width_mm', 20),
          'frame_inner_thickness' => group.get_attribute(CABINET_DICT, 'frame_inner_thickness_mm', group.get_attribute(CABINET_DICT, 'frame_inner_depth_mm', 2)),
          'groove_width' => group.get_attribute(CABINET_DICT, 'groove_width_mm', 12),
          'groove_spacing' => group.get_attribute(CABINET_DICT, 'groove_spacing_mm', 8),
          'groove_depth' => group.get_attribute(CABINET_DICT, 'groove_depth_mm', 3),
          'front_opening_direction' => group.get_attribute(CABINET_DICT, 'front_opening_direction', 'prawo'),
          'kitchen_base_enabled' => group.get_attribute(CABINET_DICT, 'kitchen_base_enabled', false),
          'connector_width' => group.get_attribute(CABINET_DICT, 'connector_width_mm', 100),
          'blend_left_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_left_value']),
          'blend_right_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_right_value']),
          'blend_left_depth_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_left_depth_value']),
          'blend_right_depth_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_right_depth_value']),
          'cokol_dolny_value' => group.get_attribute(CABINET_DICT, 'cokol_dolny_value_mm', 0),
          'cokol_gorny_value' => group.get_attribute(CABINET_DICT, 'cokol_gorny_value_mm', 0),
          'cokol_dolny_offset_value' => group.get_attribute(CABINET_DICT, 'cokol_dolny_offset_value_mm', 0),
          'cokol_gorny_offset_value' => group.get_attribute(CABINET_DICT, 'cokol_gorny_offset_value_mm', 0),
          'interior_sections_fill_remaining' => group.get_attribute(CABINET_DICT, 'interior_sections_fill_remaining', true),
          'interior_sections' => read_interior_sections(group)
        }
      end

      def find_selected_cabinet_group
        model = Sketchup.active_model
        return nil unless model

        model.selection.each do |entity|
          group = find_cabinet_group_for_entity(entity)
          return group if group
        end

        nil
      end

      def find_cabinet_group_for_entity(entity)
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

      def read_interior_sections(group)
        raw_json = group.get_attribute(CABINET_DICT, 'interior_sections_json', '[]')
        sections = JSON.parse(raw_json)
        normalize_legacy_section_params(sections)
      rescue JSON::ParserError
        []
      end

      def normalize_legacy_section_params(sections)
        return [] unless sections.is_a?(Array)

        sections.each do |section|
          next unless section.is_a?(Hash)

          filling = section['filling'].to_s
          params = section['params']
          next unless params.is_a?(Hash)

          if filling == 'drawers'
            params['drawer_count'] = normalize_legacy_count(params['drawer_count'])
          elsif filling == 'shelves'
            params['shelf_count'] = normalize_legacy_count(params['shelf_count'])
          end

          normalize_split_side_legacy!(params, 'split_left')
          normalize_split_side_legacy!(params, 'split_right')
        end

        sections
      end

      def normalize_split_side_legacy!(params, key)
        side = params[key]
        return unless side.is_a?(Hash)

        filling = side['filling'].to_s
        param = side['param']

        if filling == 'drawers' || filling == 'shelves'
          side['param'] = normalize_legacy_count(param)
        end
      end

      def normalize_legacy_count(raw_count)
        count = raw_count.to_i
        return count if count <= 20

        recovered = (count / 25.4).round
        recovered > 0 ? recovered : count
      end

      def read_blend_value_mm(group, keys)
        mm_value = group.get_attribute(CABINET_DICT, keys[:mm], nil)
        return mm_value if mm_value

        legacy_value = group.get_attribute(CABINET_DICT, keys[:legacy], 0)
        legacy_value.to_l.to_mm.round(2)
      end
    end

    private

    def save_metadata
      @group.set_attribute(CABINET_DICT, 'is_cabinet', true)
      save_mm_attributes
      @group.set_attribute(CABINET_DICT, 'height_total_mm', @height_total.to_l.to_mm.round)
      @group.set_attribute(CABINET_DICT, 'nazwa_szafki', @nazwa_szafki)
      @group.set_attribute(CABINET_DICT, 'color', @color)
      @group.set_attribute(CABINET_DICT, 'cabinet_type', @cabinet_type)
      @group.set_attribute(CABINET_DICT, 'filling', @filling)
      @group.set_attribute(CABINET_DICT, 'shelf_count', @shelf_count)
      @group.set_attribute(CABINET_DICT, 'drawer_count', @drawer_count)
      @group.set_attribute(CABINET_DICT, 'drawers_asymmetric', @drawers_asymmetric)
      @group.set_attribute(CABINET_DICT, 'front_enabled', @front_enabled)
      @group.set_attribute(CABINET_DICT, 'front_quantity', @front_quantity)
      @group.set_attribute(CABINET_DICT, 'front_type', @front_type)
      @group.set_attribute(CABINET_DICT, 'front_opening_direction', @front_opening_direction)
      @group.set_attribute(CABINET_DICT, 'kitchen_base_enabled', @kitchen_base_enabled)
      @group.set_attribute(CABINET_DICT, 'interior_sections_fill_remaining', @interior_sections_fill_remaining)
      @group.set_attribute(CABINET_DICT, 'interior_sections_json', serialized_interior_sections)
    end


    def serialized_interior_sections
      payload = @interior_sections.map do |section|
        params = serialize_section_params(section.params)

        {
          id: section.id,
          height: section.height.to_l.to_mm.round,
          y_bottom: section.y_bottom.to_l.to_mm.round,
          filling: section.filling,
          params: params
        }
      end

      JSON.generate(payload)
    end

    def serialize_section_params(params)
      params.each_with_object({}) do |(key, value), result|
        normalized_key = key.to_s

        result[normalized_key] = case normalized_key
                                 when 'rod_offset', 'drawer_front_height', 'split_first_width', 'split_left_width', 'split_right_width'
                                   value.nil? ? nil : value.to_l.to_mm.round
                                 when 'split_left', 'split_right'
                                   serialize_split_side(value)
                                 else
                                   value
                                 end
      end
    end

    def serialize_split_side(value)
      return nil unless value.is_a?(Hash)

      value.each_with_object({}) do |(key, raw), result|
        normalized_key = key.to_s
        result[normalized_key] = if normalized_key == 'param' && value['filling'].to_s == 'rod'
                                   raw.nil? ? nil : raw.to_l.to_mm.round
                                 elsif %w[drawer_front_height drawer_width_reduction drawer_box_height_offset].include?(normalized_key)
                                   raw.nil? ? nil : raw.to_l.to_mm.round
                                 else
                                   raw
                                 end
      end
    end

    def save_mm_attributes
      METADATA_FIELDS.each do |attribute_key, instance_var|
        length_value = instance_variable_get(instance_var)
        @group.set_attribute(CABINET_DICT, attribute_key, length_value.to_l.to_mm.round)
      end
    end
  end
end
