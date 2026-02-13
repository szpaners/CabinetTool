# SketchUp 2026 Kitchen Cabinet Plugin
# This plugin draws a simple kitchen cabinet without fronts or backs

require_relative 'lib/cabinet_dimensions'
require_relative 'lib/cabinet_builder'
require_relative 'config/plugin_config'
require_relative 'lib/panels/bottom_panel'
require_relative 'lib/panels/top_panel'
require_relative 'lib/panels/left_panel'
require_relative 'lib/panels/right_panel'
require_relative 'lib/panels/back_panel'
require_relative 'lib/ui/cabinet_dialog'

module KitchenCabinetPlugin
  def self.activate
    tool_menu = UI.menu('Plugins')
    timestamp = Time.now.strftime('%M_%S')

    tool_menu.add_item("Draw Kitchen Cabinet (#{timestamp})") do
      dialog = CabinetDialog::CabinetPropertiesDialog.new
      dialog.show
    end

    UI.add_context_menu_handler do |menu|
      selected_group = CabinetBuilder::Cabinet.find_selected_cabinet_group
      next unless selected_group

      menu.add_separator
      menu.add_item('Edytuj szafkę') do
        initial_params = CabinetBuilder::Cabinet.read_params_from_group(selected_group)
        dialog = CabinetDialog::CabinetPropertiesDialog.new(edit_target: selected_group, initial_params: initial_params)
        dialog.show
      end
    end
  end
end

if Sketchup.version.to_i >= 26
  timestamp = Time.now.strftime('%M_%S')
  puts "#{PluginConfig::PLUGIN_NAME} loaded for SketchUp 2026 (#{timestamp})"
  KitchenCabinetPlugin.activate
else
  puts 'This plugin requires SketchUp 2026 or later'
end
