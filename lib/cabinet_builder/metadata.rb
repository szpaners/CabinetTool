module CabinetBuilder
  module CabinetMetadata
    CABINET_DICT = 'cabinet_tool'.freeze
    METADATA_FIELDS = {
      'width_mm' => :@width,
      'height_mm' => :@height,
      'depth_mm' => :@depth,
      'panel_thickness_mm' => :@panel_thickness,
      'back_thickness_mm' => :@back_thickness,
      'front_technological_gap_mm' => :@front_technological_gap,
      'front_thickness' => :@front_thickness,
      'blend_left_value_mm' => :@blend_left_value,
      'blend_right_value_mm' => :@blend_right_value,
      'blend_left_depth_value_mm' => :@blend_left_depth_value,
      'blend_right_depth_value_mm' => :@blend_right_depth_value,
      'cokol_dolny_value_mm' => :@cokol_dolny_value,
      'cokol_gorny_value_mm' => :@cokol_gorny_value
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
          'height' => group.get_attribute(CABINET_DICT, 'height_mm', CabinetDimensions::CABINET_HEIGHT.to_mm),
          'depth' => group.get_attribute(CABINET_DICT, 'depth_mm', CabinetDimensions::CABINET_DEPTH.to_mm),
          'panel_thickness' => group.get_attribute(CABINET_DICT, 'panel_thickness_mm', CabinetDimensions::PANEL_THICKNESS.to_mm),
          'back_thickness' => group.get_attribute(CABINET_DICT, 'back_thickness_mm', CabinetDimensions::PANEL_THICKNESS_BACK.to_mm),
          'nazwa_szafki' => group.get_attribute(CABINET_DICT, 'nazwa_szafki', 'szafka'),
          'color' => group.get_attribute(CABINET_DICT, 'color', CabinetDimensions::DEFAULT_COLOR),
          'filling' => group.get_attribute(CABINET_DICT, 'filling', 'none'),
          'shelf_count' => group.get_attribute(CABINET_DICT, 'shelf_count', 0),
          'front_enabled' => group.get_attribute(CABINET_DICT, 'front_enabled', false),
          'front_thickness' => group.get_attribute(CABINET_DICT, 'front_thickness', CabinetDimensions::FRONT_THICKNESS),
          'front_technological_gap' => group.get_attribute(CABINET_DICT, 'front_technological_gap_mm', 0),
          'blend_left_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_left_value']),
          'blend_right_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_right_value']),
          'blend_left_depth_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_left_depth_value']),
          'blend_right_depth_value' => read_blend_value_mm(group, LEGACY_BLEND_KEYS['blend_right_depth_value']),
          'cokol_dolny_value' => group.get_attribute(CABINET_DICT, 'cokol_dolny_value_mm', 0),
          'cokol_gorny_value' => group.get_attribute(CABINET_DICT, 'cokol_gorny_value_mm', 0)
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
      @group.set_attribute(CABINET_DICT, 'nazwa_szafki', @nazwa_szafki)
      @group.set_attribute(CABINET_DICT, 'color', @color)
      @group.set_attribute(CABINET_DICT, 'filling', @filling)
      @group.set_attribute(CABINET_DICT, 'shelf_count', @shelf_count)
      @group.set_attribute(CABINET_DICT, 'front_enabled', @front_enabled)
    end

def save_mm_attributes
  METADATA_FIELDS.each do |attribute_key, instance_var|
    length_value = instance_variable_get(instance_var)
    @group.set_attribute(CABINET_DICT, attribute_key, length_value.to_l.to_mm.round)
  end
    end
  end
end
