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
  # Menu item handler
  def self.activate
    tool_menu = UI.menu("Plugins")
timestamp = Time.now.strftime("%M_%S")
    tool_menu.add_item("Draw Kitchen Cabinet (#{timestamp})") {
      dialog = CabinetDialog::CabinetPropertiesDialog.new
      dialog.show
    }
  end
end

# Only load the plugin when SketchUp is running
if Sketchup.version.to_i >= 26
timestamp = Time.now.strftime("%M_%S")
puts "#{PluginConfig::PLUGIN_NAME} loaded for SketchUp 2026 (#{timestamp})"
  KitchenCabinetPlugin.activate
else
puts "This plugin requires SketchUp 2026 or later"
end
