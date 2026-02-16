(function() {
  const SECTION_FILLINGS = {
    none: { label: 'Parametr', hint: 'Brak parametru', min: 0, defaultValue: 0 },
    drawers: { label: 'Liczba szuflad', hint: 'Ilość szuflad w sekcji', min: 1, defaultValue: 3 },
    shelves: { label: 'Liczba półek', hint: 'Ilość półek w sekcji', min: 1, defaultValue: 4 },
    rod: { label: 'Offset drążka (mm)', hint: 'Offset drążka od dołu sekcji (mm)', min: 0, defaultValue: 200 }
  };

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
    blendRightDepthValue: 'wardrobe_blend_right_depth_value',
    sectionsList: 'wardrobe_sections_list',
    sectionTemplate: 'wardrobe_section_template',
    addSection: 'wardrobe_add_section',
    sectionsFillRemaining: 'wardrobe_sections_fill_remaining',
    sectionsRemaining: 'wardrobe_sections_remaining'
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
    element.classList.toggle('is-hidden', !visible);
  }

  function updateFrontVisibility() {
    setVisible(form.frontOptions, byId(form.frontEnabled).checked);
  }

  function updateFrontTypeVisibility() {
    const frontType = byId(form.frontType).value;
    setVisible(form.frameWidthGroup, frontType === 'frame');
    setVisible(form.frameInnerThicknessGroup, frontType === 'frame');
    setVisible(form.grooveWidthGroup, frontType === 'lamella');
    setVisible(form.grooveSpacingGroup, frontType === 'lamella');
    setVisible(form.grooveDepthGroup, frontType === 'lamella');
  }

  function updateFrontOpeningDirectionLock() {
    byId(form.frontOpeningDirection).disabled = Number(byId(form.frontQuantity).value || 1) === 2;
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
    setVisible(form.blendLeftGroup, byId(form.blendLeftCheckbox).checked);
    setVisible(form.blendLeftDepthGroup, byId(form.blendLeftCheckbox).checked);
    setVisible(form.blendRightGroup, byId(form.blendRightCheckbox).checked);
    setVisible(form.blendRightDepthGroup, byId(form.blendRightCheckbox).checked);
  }

  function updateSectionParamUi(sectionRow) {
    const filling = sectionRow.querySelector('[data-field="filling"]').value;
    const paramLabel = sectionRow.querySelector('[data-field="param_label"]');
    const paramInput = sectionRow.querySelector('[data-field="param"]');
    const hint = sectionRow.querySelector('[data-field="param_hint"]');
    const drawerFrontHeightGroup = sectionRow.querySelector('[data-field="drawer_front_height_group"]');
    const drawerFrontHeightInput = sectionRow.querySelector('[data-field="drawer_front_height"]');
    const drawerWidthReductionGroup = sectionRow.querySelector('[data-field="drawer_width_reduction_group"]');
    const drawerWidthReductionInput = sectionRow.querySelector('[data-field="drawer_width_reduction"]');
    const drawerBoxHeightOffsetGroup = sectionRow.querySelector('[data-field="drawer_box_height_offset_group"]');
    const drawerBoxHeightOffsetInput = sectionRow.querySelector('[data-field="drawer_box_height_offset"]');
    const config = SECTION_FILLINGS[filling] || SECTION_FILLINGS.none;

    paramLabel.textContent = config.label;
    paramInput.min = config.min;
    if (filling === 'none') {
      paramInput.value = 0;
      paramInput.disabled = true;
    } else {
      paramInput.disabled = false;
      if (Number(paramInput.value || 0) < config.min) {
        paramInput.value = config.defaultValue;
      }
    }

    hint.textContent = config.hint;

    if (drawerFrontHeightGroup && drawerFrontHeightInput) {
      drawerFrontHeightGroup.classList.toggle('is-hidden', filling !== 'drawers');
      if (filling === 'drawers' && Number(drawerFrontHeightInput.value || 0) < 1) {
        drawerFrontHeightInput.value = 80;
      }
    }

    if (drawerWidthReductionGroup && drawerWidthReductionInput) {
      drawerWidthReductionGroup.classList.toggle('is-hidden', filling !== 'drawers');
      if (filling === 'drawers' && Number(drawerWidthReductionInput.value || 0) < 0) {
        drawerWidthReductionInput.value = 40;
      }
    }

    if (drawerBoxHeightOffsetGroup && drawerBoxHeightOffsetInput) {
      drawerBoxHeightOffsetGroup.classList.toggle('is-hidden', filling !== 'drawers');
      if (filling === 'drawers' && Number(drawerBoxHeightOffsetInput.value || 0) < 0) {
        drawerBoxHeightOffsetInput.value = 40;
      }
    }
  }

  function sectionRows() {
    return Array.from(byId(form.sectionsList).querySelectorAll('[data-section-row]'));
  }


  function isAutoRemainingRow(row) {
    return row.dataset.autoRemaining === 'true';
  }

  function sectionInputRows() {
    return sectionRows().filter((row) => !isAutoRemainingRow(row));
  }

  function readSectionFromRow(sectionRow, index) {
    const filling = sectionRow.querySelector('[data-field="filling"]').value;
    const height = Math.max(Number(sectionRow.querySelector('[data-field="height"]').value || 0), 0);
    const paramValue = Math.max(Number(sectionRow.querySelector('[data-field="param"]').value || 0), 0);
    const drawerFrontHeight = Math.max(Number(sectionRow.querySelector('[data-field="drawer_front_height"]').value || 0), 0);
    const drawerWidthReduction = Math.max(Number(sectionRow.querySelector('[data-field="drawer_width_reduction"]').value || 40), 0);
    const drawerBoxHeightOffset = Math.max(Number(sectionRow.querySelector('[data-field="drawer_box_height_offset"]').value || 40), 0);
    const params = {
      top_panel: sectionRow.querySelector('[data-field="top_panel"]').checked
    };

    if (filling === 'drawers') {
      params.drawer_count = Math.max(Math.round(paramValue), 1);
      params.drawer_front_height = Math.max(drawerFrontHeight, 1);
      params.drawer_width_reduction = drawerWidthReduction;
      params.drawer_box_height_offset = drawerBoxHeightOffset;
    }
    if (filling === 'shelves') params.shelf_count = Math.max(Math.round(paramValue), 1);
    if (filling === 'rod') params.rod_offset = paramValue;

    return {
      id: index + 1,
      height,
      filling,
      params
    };
  }

  function updateRemainingHeight() {
    const cabinetHeight = Math.max(Number(byId(form.height).value || 0), 0);
    const cokolDolny = byId(form.cokolDolnyCheckbox).checked ? Math.max(Number(byId(form.cokolDolnyValue).value || 0), 0) : 0;
    const cokolGorny = byId(form.cokolGornyCheckbox).checked ? Math.max(Number(byId(form.cokolGornyValue).value || 0), 0) : 0;
    const panelThickness = Math.max(Number(byId(form.panelThickness).value || 0), 0);
    const nicheHeight = Math.max(cabinetHeight - cokolDolny - cokolGorny - (2 * panelThickness), 0);

    const usedHeight = sectionInputRows().reduce((sum, row) => sum + readSectionFromRow(row, 0).height, 0);
    const remaining = nicheHeight - usedHeight;


    const autoRow = byId(form.sectionsList).querySelector('[data-auto-remaining="true"]');
    const fillRemaining = byId(form.sectionsFillRemaining).checked;
    if (autoRow) {
      autoRow.classList.remove('is-hidden');
      const autoHeightInput = autoRow.querySelector('[data-field="height"]');
      autoHeightInput.value = Math.max(remaining, 0).toFixed(1);
      autoHeightInput.disabled = true;

      const autoHint = autoRow.querySelector('[data-field="param_hint"]');
      if (autoHint) {
        autoHint.textContent = fillRemaining ? 'Sekcja będzie dodana automatycznie przy zapisie.' : 'Sekcja podglądowa (wyłączona przy zapisie).';
      }
    }

    const remainingLabel = byId(form.sectionsRemaining);
    remainingLabel.textContent = `Pozostała wysokość: ${remaining.toFixed(1)} mm (wnęka: ${nicheHeight.toFixed(1)} mm)`;
    remainingLabel.classList.toggle('is-error', remaining < 0);

    return { nicheHeight, remaining };
  }

  function addSection(section = {}, options = {}) {
    const template = byId(form.sectionTemplate);
    const row = template.content.firstElementChild.cloneNode(true);

    const isAutoRemaining = !!options.autoRemaining;
    row.dataset.autoRemaining = isAutoRemaining ? 'true' : 'false';

    row.querySelector('[data-field="height"]').value = section.height || 400;
    row.querySelector('[data-field="filling"]').value = section.filling || 'none';

    const topPanelInput = row.querySelector('[data-field="top_panel"]');
    topPanelInput.checked = !!section.params?.top_panel;

    const paramInput = row.querySelector('[data-field="param"]');
    if (section.filling === 'drawers') {
      paramInput.value = section.params?.drawer_count || 3;
      row.querySelector('[data-field="drawer_front_height"]').value = section.params?.drawer_front_height || 80;
      row.querySelector('[data-field="drawer_width_reduction"]').value = section.params?.drawer_width_reduction ?? 40;
      row.querySelector('[data-field="drawer_box_height_offset"]').value = section.params?.drawer_box_height_offset ?? 40;
    } else if (section.filling === 'shelves') {
      paramInput.value = section.params?.shelf_count || 4;
    } else if (section.filling === 'rod') {
      paramInput.value = section.params?.rod_offset || 200;
    } else {
      paramInput.value = 0;
    }

    updateSectionParamUi(row);

    row.querySelector('[data-field="filling"]').addEventListener('change', () => {
      updateSectionParamUi(row);
      updateRemainingHeight();
      window.updateCabinetPreview?.();
    });

    row.querySelectorAll('input').forEach((input) => {
      input.addEventListener('input', () => {
        updateRemainingHeight();
        window.updateCabinetPreview?.();
      });
    });

    if (isAutoRemaining) {
      row.querySelector('[data-field="filling"]').disabled = true;
      row.querySelector('[data-field="param"]').disabled = true;
      row.querySelector('[data-field="drawer_front_height"]').disabled = true;
      row.querySelector('[data-field="drawer_width_reduction"]').disabled = true;
      row.querySelector('[data-field="drawer_box_height_offset"]').disabled = true;
      row.querySelector('[data-field="top_panel"]').disabled = true;
      row.querySelector('[data-action="remove"]').disabled = true;
      row.querySelector('[data-action="remove"]').classList.add('is-hidden');
    }

    row.querySelector('[data-action="remove"]').addEventListener('click', () => {
      row.remove();
      updateRemainingHeight();
      window.updateCabinetPreview?.();
    });

    const list = byId(form.sectionsList);
    const autoRow = list.querySelector('[data-auto-remaining="true"]');
    if (autoRow && !isAutoRemaining) {
      list.insertBefore(row, autoRow);
    } else {
      list.appendChild(row);
    }
    updateRemainingHeight();
  }

  function collectInteriorSections() {
    return sectionInputRows().map((row, index) => readSectionFromRow(row, index));
  }

  function applyVisibilityState() {
    updateFrontVisibility();
    updateFrontTypeVisibility();
    updateFrontOpeningDirectionLock();
    updateCokolVisibility();
    updateBlendVisibility();
    updateRemainingHeight();
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

    byId(form.sectionsList).innerHTML = '';
    const sections = Array.isArray(params.interior_sections) ? params.interior_sections : [];
    if (sections.length > 0) {
      sections.forEach((section) => addSection(section));
    } else {
      addSection({ height: 800, filling: 'none', params: {} });
      addSection({ height: 800, filling: 'none', params: {} });
    }

    addSection({ height: 0, filling: 'none', params: {} }, { autoRemaining: true });
    byId(form.sectionsFillRemaining).checked = params.interior_sections_fill_remaining !== false;

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
      cokol_gorny_offset_value: cokolGornyEnabled ? byId(form.cokolGornyOffsetValue).value : 0,
      interior_sections_fill_remaining: byId(form.sectionsFillRemaining).checked,
      interior_sections: collectInteriorSections()
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
      form.blendRightCheckbox,
      form.height,
      form.panelThickness,
      form.cokolDolnyValue,
      form.cokolGornyValue,
      form.sectionsFillRemaining
    ].forEach((id) => {
      byId(id).addEventListener('change', () => {
        applyVisibilityState();
        updatePreview();
      });
      byId(id).addEventListener('input', () => {
        updateRemainingHeight();
      });
    });

    byId(form.addSection).addEventListener('click', () => {
      addSection();
      updatePreview();
    });

    document.querySelectorAll('#materials input, #materials select').forEach((element) => {
      element.addEventListener('input', updatePreview);
      element.addEventListener('change', updatePreview);
    });
  }


  function validateBeforeSave() {
    const { remaining } = updateRemainingHeight();
    if (remaining < 0) {
      alert('Suma wysokości sekcji przekracza wysokość wnęki.');
      return false;
    }

    const invalid = collectInteriorSections().find((section) => {
      if (section.height <= 0) return true;
      if (section.filling === 'drawers') {
        return Number(section.params.drawer_count || 0) < 1 || Number(section.params.drawer_front_height || 0) <= 0 || Number(section.params.drawer_width_reduction || 0) < 0 || Number(section.params.drawer_box_height_offset || 0) < 0;
      }
      if (section.filling === 'shelves') return Number(section.params.shelf_count || 0) < 1;
      if (section.filling === 'rod') return Number(section.params.rod_offset || 0) < 0 || Number(section.params.rod_offset || 0) > section.height;
      return false;
    });

    if (invalid) {
      alert('Sprawdź konfigurację sekcji: wysokości > 0, liczby elementów >= 1 i parametry w granicach sekcji.');
      return false;
    }

    return true;
  }

  window.WardrobeTab = {
    setFormData,
    buildSaveParams,
    bindEvents,
    applyVisibilityState,
    validateBeforeSave
  };
})();
