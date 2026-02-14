module CabinetBuilder
  class NamedPanel < BasePanel
    def initialize(config, name:)
      super(config.merge(name: name))
      @thickness = config[:thickness]
    end
  end
end
