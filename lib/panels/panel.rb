module CabinetBuilder
  class Panel < NamedPanel
    def initialize(config)
      super(config, name: config[:name])
    end
  end
end
