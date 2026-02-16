(function() {
  const form = {
    width: 'wardrobe_width',
    height: 'wardrobe_height',
    depth: 'wardrobe_depth',
    panelThickness: 'wardrobe_panel_thickness',
    backThickness: 'wardrobe_back_thickness',
    frontThickness: 'wardrobe_front_thickness',
    name: 'wardrobe_nazwa_szafki',
    color: 'wardrobe_color',
    frontEnabled: 'wardrobe_front_enabled',
    frontOptions: 'wardrobe_front_options',
    frontQuantity: 'wardrobe_front_quantity',
    frontOpeningDirection: 'wardrobe_front_opening_direction',
    frontType: 'wardrobe_front_type',
    frontGap: 'wardrobe_front_technological_gap',
    frameWidth: 'wardrobe_frame_width',
    frameInnerThickness: 'wardrobe_frame_inner_thickness',
    grooveWidth: 'wardrobe_groove_width',
    grooveSpacing: 'wardrobe_groove_spacing',
    grooveDepth: 'wardrobe_groove_depth',
    frameWidthGroup: 'wardrobe_frame_width_group',
    frameInnerThicknessGroup: 'wardrobe_frame_inner_thickness_group',
    grooveWidthGroup: 'wardrobe_groove_width_group',
    grooveSpacingGroup: 'wardrobe_groove_spacing_group',
    grooveDepthGroup: 'wardrobe_groove_depth_group',
    cokolDolnyCheckbox: 'wardrobe_cokol_dolny_checkbox',
    cokolDolnyGroup: 'wardrobe_cokol_dolny_group',
    cokolDolnyOffsetGroup: 'wardrobe_cokol_dolny_offset_group',
    cokolDolnyValue: 'wardrobe_cokol_dolny_value',
    cokolDolnyOffsetValue: 'wardrobe_cokol_dolny_offset_value',
    cokolGornyCheckbox: 'wardrobe_cokol_gorny_checkbox',
    cokolGornyGroup: 'wardrobe_cokol_gorny_group',
    cokolGornyOffsetGroup: 'wardrobe_cokol_gorny_offset_group',
    cokolGornyValue: 'wardrobe_cokol_gorny_value',
    cokolGornyOffsetValue: 'wardrobe_cokol_gorny_offset_value',
    blendLeftCheckbox: 'wardrobe_blend_left_checkbox',
    blendLeftGroup: 'wardrobe_blend_left_group',
    blendLeftDepthGroup: 'wardrobe_blend_left_depth_group',
    blendLeftValue: 'wardrobe_blend_left_value',
    blendLeftDepthValue: 'wardrobe_blend_left_depth_value',
    blendRightCheckbox: 'wardrobe_blend_right_checkbox',
    blendRightGroup: 'wardrobe_blend_right_group',
    blendRightDepthGroup: 'wardrobe_blend_right_depth_group',
    blendRightValue: 'wardrobe_blend_right_value',
    blendRightDepthValue: 'wardrobe_blend_right_depth_value'
  };

  function byId(id) {
    return document.getElementById(id);
  }

  function normalizeFrontType(rawFrontType) {
    const frontType = rawFrontType || 'flat';
    if (frontType === 'rama') return 'frame';
    if (['ryflowany', 'grooved', 'lamelowany'].includes(frontType)) return 'lamella';
    return frontType;
  }

  function setVisible(id, visible) {
    const element = byId(id);
    if (!element) return;

    if (visible) {
      element.classList.remove('is-hidden');
    } else {
      element.classList.add('is-hidden');
    }
  }

  function updateFrontVisibility() {
    const enabled = byId(form.frontEnabled).checked;
    setVisible(form.frontOptions, enabled);
  }

  function updateFrontTypeVisibility() {
    const frontType = byId(form.frontType).value;
    const isFrame = frontType === 'frame';
    const isLamella = frontType === 'lamella';

    setVisible(form.frameWidthGroup, isFrame);
    setVisible(form.frameInnerThicknessGroup, isFrame);
    setVisible(form.grooveWidthGroup, isLamella);
    setVisible(form.grooveSpacingGroup, isLamella);
    setVisible(form.grooveDepthGroup, isLamella);
  }

  function updateFrontOpeningDirectionLock() {
    const frontQuantity = Number(byId(form.frontQuantity).value || 1);
    const direction = byId(form.frontOpeningDirection);
    direction.disabled = frontQuantity === 2;
  }

  function updateCokolVisibility() {
    const cokolDolnyEnabled = byId(form.cokolDolnyCheckbox).checked;
    const cokolGornyEnabled = byId(form.cokolGornyCheckbox).checked;

    setVisible(form.cokolDolnyGroup, cokolDolnyEnabled);
    setVisible(form.cokolDolnyOffsetGroup, cokolDolnyEnabled);
    setVisible(form.cokolGornyGroup, cokolGornyEnabled);
    setVisible(form.cokolGornyOffsetGroup, cokolGornyEnabled);
  }

  function updateBlendVisibility() {
    const blendLeftEnabled = byId(form.blendLeftCheckbox).checked;
    const blendRightEnabled = byId(form.blendRightCheckbox).checked;

    setVisible(form.blendLeftGroup, blendLeftEnabled);
    setVisible(form.blendLeftDepthGroup, blendLeftEnabled);
    setVisible(form.blendRightGroup, blendRightEnabled);
    setVisible(form.blendRightDepthGroup, blendRightEnabled);
  }

  function applyVisibilityState() {
    updateFrontVisibility();
    updateFrontTypeVisibility();
    updateFrontOpeningDirectionLock();
    updateCokolVisibility();
    updateBlendVisibility();
  }

  function setFormData(params) {
    byId(form.width).value = params.width;
    byId(form.height).value = params.height;
    byId(form.depth).value = params.depth;
    byId(form.panelThickness).value = params.panel_thickness;
    byId(form.backThickness).value = params.back_thickness;
    byId(form.frontThickness).value = params.front_thickness;
    byId(form.name).value = params.nazwa_szafki || 'szafa';
    byId(form.color).value = params.color;

    byId(form.frontEnabled).checked = !!params.front_enabled;
    byId(form.frontQuantity).value = params.front_quantity || 1;
    byId(form.frontOpeningDirection).value = params.front_opening_direction || 'prawo';
    byId(form.frontType).value = normalizeFrontType(params.front_type);
    byId(form.frontGap).value = params.front_technological_gap || 0;
    byId(form.frameWidth).value = params.frame_width || 20;
    byId(form.frameInnerThickness).value = params.frame_inner_thickness || params.frame_inner_depth || 2;
    byId(form.grooveWidth).value = params.groove_width || 12;
    byId(form.grooveSpacing).value = params.groove_spacing || 8;
    byId(form.grooveDepth).value = params.groove_depth || 3;

    byId(form.cokolDolnyCheckbox).checked = Number(params.cokol_dolny_value || 0) > 0;
    byId(form.cokolDolnyValue).value = params.cokol_dolny_value || 0;
    byId(form.cokolDolnyOffsetValue).value = params.cokol_dolny_offset_value || 0;

    byId(form.cokolGornyCheckbox).checked = Number(params.cokol_gorny_value || 0) > 0;
    byId(form.cokolGornyValue).value = params.cokol_gorny_value || 0;
    byId(form.cokolGornyOffsetValue).value = params.cokol_gorny_offset_value || 0;

    byId(form.blendLeftCheckbox).checked = Number(params.blend_left_value || 0) > 0;
    byId(form.blendLeftValue).value = params.blend_left_value || 0;
    byId(form.blendLeftDepthValue).value = params.blend_left_depth_value || 0;

    byId(form.blendRightCheckbox).checked = Number(params.blend_right_value || 0) > 0;
    byId(form.blendRightValue).value = params.blend_right_value || 0;
    byId(form.blendRightDepthValue).value = params.blend_right_depth_value || 0;

    applyVisibilityState();
  }

  function buildSaveParams() {
    const cokolDolnyEnabled = byId(form.cokolDolnyCheckbox).checked;
    const cokolGornyEnabled = byId(form.cokolGornyCheckbox).checked;
    const blendLeftEnabled = byId(form.blendLeftCheckbox).checked;
    const blendRightEnabled = byId(form.blendRightCheckbox).checked;

    return {
      cabinet_type: 'wardrobe',
      width: byId(form.width).value,
      height: byId(form.height).value,
      depth: byId(form.depth).value,
      kitchen_base_enabled: false,
      connector_width: 0,
      panel_thickness: byId(form.panelThickness).value,
      front_thickness: byId(form.frontThickness).value,
      back_thickness: byId(form.backThickness).value,
      nazwa_szafki: byId(form.name).value,
      color: byId(form.color).value,
      filling: 'none',
      shelf_count: 0,
      drawer_count: 0,
      drawers_asymmetric: false,
      first_drawer_height: 0,
      front_enabled: byId(form.frontEnabled).checked,
      front_technological_gap: byId(form.frontGap).value,
      front_quantity: byId(form.frontQuantity).value,
      front_type: byId(form.frontType).value,
      frame_width: byId(form.frameWidth).value,
      frame_inner_thickness: byId(form.frameInnerThickness).value,
      groove_width: byId(form.grooveWidth).value,
      groove_spacing: byId(form.grooveSpacing).value,
      groove_depth: byId(form.grooveDepth).value,
      front_opening_direction: byId(form.frontOpeningDirection).value,
      blend_left_value: blendLeftEnabled ? byId(form.blendLeftValue).value : 0,
      blend_right_value: blendRightEnabled ? byId(form.blendRightValue).value : 0,
      blend_left_depth_value: blendLeftEnabled ? byId(form.blendLeftDepthValue).value : 0,
      blend_right_depth_value: blendRightEnabled ? byId(form.blendRightDepthValue).value : 0,
      cokol_dolny_value: cokolDolnyEnabled ? byId(form.cokolDolnyValue).value : 0,
      cokol_gorny_value: cokolGornyEnabled ? byId(form.cokolGornyValue).value : 0,
      cokol_dolny_offset_value: cokolDolnyEnabled ? byId(form.cokolDolnyOffsetValue).value : 0,
      cokol_gorny_offset_value: cokolGornyEnabled ? byId(form.cokolGornyOffsetValue).value : 0
    };
  }

  function bindEvents(updatePreview) {
    [
      form.frontEnabled,
      form.frontType,
      form.frontQuantity,
      form.cokolDolnyCheckbox,
      form.cokolGornyCheckbox,
      form.blendLeftCheckbox,
      form.blendRightCheckbox
    ].forEach((id) => {
      byId(id).addEventListener('change', () => {
        applyVisibilityState();
        updatePreview();
      });
    });

    document.querySelectorAll('#materials input, #materials select').forEach((element) => {
      element.addEventListener('input', updatePreview);
      element.addEventListener('change', updatePreview);
    });
  }

  window.WardrobeTab = {
    setFormData,
    buildSaveParams,
    bindEvents,
    applyVisibilityState
  };
})();
