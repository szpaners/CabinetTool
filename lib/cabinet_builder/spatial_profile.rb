module CabinetBuilder
  module CabinetSpatialProfile
    private

    def refresh_spatial_profile
      @depth = @depth_total
      @front_extension = front_surface_enabled? ? @front_thickness : 0
      @corpus_depth = [@depth_total - @front_extension, @back_thickness].max
      @internal_depth = [@corpus_depth - @back_thickness, 0].max
    end

    def front_surface_enabled?
      @front_enabled || @filling == 'drawers'
    end
  end
end
