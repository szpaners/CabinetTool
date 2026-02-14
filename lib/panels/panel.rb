module CabinetBuilder
  class Panel < BasePanel
    def initialize(config)
      super(config)
      @thickness = config[:thickness]
    end
  end
end
