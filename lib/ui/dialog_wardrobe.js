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
    frontHandle: 'wardrobe_front_handle',
    frontHandlePosition: 'wardrobe_front_handle_position',
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

  function updateHandlePositionOptions() {
    const handleInput = byId(form.frontHandle);
    const positionInput = byId(form.frontHandlePosition);
    if (!handleInput || !positionInput) return;

    const isJHandle = handleInput.value.toLowerCase() === 'j';

    Array.from(positionInput.options).forEach((option) => {
      const shouldDisable = isJHandle && option.value === 'środek';
      option.disabled = shouldDisable;
      option.hidden = shouldDisable;
    });

    if (isJHandle && positionInput.value === 'środek') {
      positionInput.value = 'dół';
    }
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

  function updateHalfConfigUi(sectionRow, side) {
    const fillingInput = sectionRow.querySelector(`[data-field="split_${side}_filling"]`);
    const paramInput = sectionRow.querySelector(`[data-field="split_${side}_param"]`);
    const paramLabel = sectionRow.querySelector(`[data-field="split_${side}_param_label"]`);
    const paramHint = sectionRow.querySelector(`[data-field="split_${side}_param_hint"]`);
    const drawerFrontReductionGroup = sectionRow.querySelector(`[data-field="split_${side}_drawer_front_reduction_group"]`);
    const drawerFrontReductionInput = sectionRow.querySelector(`[data-field="split_${side}_drawer_front_reduction"]`);
    const drawerWidthReductionGroup = sectionRow.querySelector(`[data-field="split_${side}_drawer_width_reduction_group"]`);
    const drawerWidthReductionInput = sectionRow.querySelector(`[data-field="split_${side}_drawer_width_reduction"]`);
    const drawerBoxHeightOffsetGroup = sectionRow.querySelector(`[data-field="split_${side}_drawer_box_height_offset_group"]`);
    const drawerBoxHeightOffsetInput = sectionRow.querySelector(`[data-field="split_${side}_drawer_box_height_offset"]`);
    if (!fillingInput || !paramInput || !paramLabel || !paramHint) return;

    const config = SECTION_FILLINGS[fillingInput.value] || SECTION_FILLINGS.none;
    paramLabel.textContent = `${side === 'left' ? 'Lewa' : 'Prawa'} połówka - ${config.label}`;
    paramHint.textContent = config.hint;
    paramInput.min = config.min;

    if (fillingInput.value === 'none') {
      paramInput.value = 0;
      paramInput.disabled = true;
    } else {
      paramInput.disabled = false;
      if (Number(paramInput.value || 0) < config.min) {
        paramInput.value = config.defaultValue;
      }
    }

    const isDrawers = fillingInput.value === 'drawers';
    drawerFrontReductionGroup?.classList.toggle('is-hidden', !isDrawers);
    drawerWidthReductionGroup?.classList.toggle('is-hidden', !isDrawers);
    drawerBoxHeightOffsetGroup?.classList.toggle('is-hidden', !isDrawers);

    if (isDrawers) {
      if (drawerFrontReductionInput && Number(drawerFrontReductionInput.value || 0) < 0) drawerFrontReductionInput.value = 0;
      if (drawerWidthReductionInput && Number(drawerWidthReductionInput.value || 0) < 0) drawerWidthReductionInput.value = 40;
      if (drawerBoxHeightOffsetInput && Number(drawerBoxHeightOffsetInput.value || 0) < 0) drawerBoxHeightOffsetInput.value = 40;
    }
  }

  function syncSplitWidths(sectionRow, sourceSide = null) {
    const leftWidthInput = sectionRow.querySelector('[data-field="split_left_width"]');
    const rightWidthInput = sectionRow.querySelector('[data-field="split_right_width"]');
    if (!leftWidthInput || !rightWidthInput) return;

    const cabinetWidth = Math.max(Number(byId(form.width).value || 0), 0);
    if (cabinetWidth <= 0) return;

    const parseRaw = (raw) => {
      if (raw === null || raw === undefined || raw === '') return null;
      const numeric = Number(raw);
      return Number.isFinite(numeric) ? Math.max(numeric, 0) : null;
    };

    const leftRaw = leftWidthInput.value;
    const rightRaw = rightWidthInput.value;
    let left = parseRaw(leftRaw);
    let right = parseRaw(rightRaw);

    if (sourceSide === 'left' && left !== null) {
      right = Math.max(cabinetWidth - left, 0);
      rightWidthInput.value = right.toFixed(1);
    } else if (sourceSide === 'right' && right !== null) {
      left = Math.max(cabinetWidth - right, 0);
      leftWidthInput.value = left.toFixed(1);
    }
  }

  function updateSectionParamUi(sectionRow) {
    const filling = sectionRow.querySelector('[data-field="filling"]').value;
    const paramLabel = sectionRow.querySelector('[data-field="param_label"]');
    const paramInput = sectionRow.querySelector('[data-field="param"]');
    const hint = sectionRow.querySelector('[data-field="param_hint"]');
    const mainFillingGroup = sectionRow.querySelector('[data-field="main_filling_group"]');
    const mainParamGroup = sectionRow.querySelector('[data-field="main_param_group"]');
    const drawerFrontReductionGroup = sectionRow.querySelector('[data-field="drawer_front_reduction_group"]');
    const drawerFrontReductionInput = sectionRow.querySelector('[data-field="drawer_front_reduction"]');
    const drawerWidthReductionGroup = sectionRow.querySelector('[data-field="drawer_width_reduction_group"]');
    const drawerWidthReductionInput = sectionRow.querySelector('[data-field="drawer_width_reduction"]');
    const drawerBoxHeightOffsetGroup = sectionRow.querySelector('[data-field="drawer_box_height_offset_group"]');
    const drawerBoxHeightOffsetInput = sectionRow.querySelector('[data-field="drawer_box_height_offset"]');
    const splitEnabledInput = sectionRow.querySelector('[data-field="split_enabled"]');
    const splitLeftWidthGroup = sectionRow.querySelector('[data-field="split_left_width_group"]');
    const splitLeftWidthInput = sectionRow.querySelector('[data-field="split_left_width"]');
    const splitRightWidthGroup = sectionRow.querySelector('[data-field="split_right_width_group"]');
    const splitRightWidthInput = sectionRow.querySelector('[data-field="split_right_width"]');
    const splitHint = sectionRow.querySelector('[data-field="split_hint"]');
    const splitHalvesGroup = sectionRow.querySelector('[data-field="split_halves_group"]');
    const splitLeftFillingGroup = sectionRow.querySelector('[data-field="split_left_filling_group"]');
    const splitLeftParamGroup = sectionRow.querySelector('[data-field="split_left_param_group"]');
    const splitRightFillingGroup = sectionRow.querySelector('[data-field="split_right_filling_group"]');
    const splitRightParamGroup = sectionRow.querySelector('[data-field="split_right_param_group"]');
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

    if (drawerFrontReductionGroup && drawerFrontReductionInput) {
      drawerFrontReductionGroup.classList.toggle('is-hidden', filling !== 'drawers');
      if (filling === 'drawers' && Number(drawerFrontReductionInput.value || 0) < 0) {
        drawerFrontReductionInput.value = 0;
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

    if (splitEnabledInput && splitLeftWidthGroup && splitLeftWidthInput && splitRightWidthGroup && splitRightWidthInput) {
      const splitEnabled = splitEnabledInput.checked;
      splitLeftWidthGroup.classList.toggle('is-hidden', !splitEnabled);
      splitRightWidthGroup.classList.toggle('is-hidden', !splitEnabled);
      splitHalvesGroup?.classList.toggle('is-hidden', !splitEnabled);
      splitLeftFillingGroup?.classList.toggle('is-hidden', !splitEnabled);
      splitLeftParamGroup?.classList.toggle('is-hidden', !splitEnabled);
      splitRightFillingGroup?.classList.toggle('is-hidden', !splitEnabled);
      splitRightParamGroup?.classList.toggle('is-hidden', !splitEnabled);

      mainFillingGroup?.classList.toggle('is-hidden', splitEnabled);
      mainParamGroup?.classList.toggle('is-hidden', splitEnabled);
      drawerFrontReductionGroup?.classList.toggle('is-hidden', splitEnabled || filling !== 'drawers');
      drawerWidthReductionGroup?.classList.toggle('is-hidden', splitEnabled || filling !== 'drawers');
      drawerBoxHeightOffsetGroup?.classList.toggle('is-hidden', splitEnabled || filling !== 'drawers');

      const leftFilling = sectionRow.querySelector('[data-field="split_left_filling"]');
      const rightFilling = sectionRow.querySelector('[data-field="split_right_filling"]');
      const leftParam = sectionRow.querySelector('[data-field="split_left_param"]');
      const rightParam = sectionRow.querySelector('[data-field="split_right_param"]');

      if (splitEnabled) {
        splitLeftWidthInput.min = 1;
        splitRightWidthInput.min = 1;
        syncSplitWidths(sectionRow);

        if (sectionRow.dataset.splitInitialized !== 'true' && leftFilling && rightFilling && leftParam && rightParam) {
          leftFilling.value = filling;
          rightFilling.value = filling;
          leftParam.value = paramInput.value || 0;
          rightParam.value = paramInput.value || 0;
          sectionRow.dataset.splitInitialized = 'true';
        }
      } else {
        splitLeftWidthInput.value = '';
        splitRightWidthInput.value = '';
        sectionRow.dataset.splitInitialized = 'false';
      }

      updateHalfConfigUi(sectionRow, 'left');
      updateHalfConfigUi(sectionRow, 'right');

      if (splitHint) {
        const cabinetWidth = Math.max(Number(byId(form.width).value || 0), 0);
        const left = Math.max(Number(splitLeftWidthInput.value || 0), 0);
        const right = Math.max(Number(splitRightWidthInput.value || 0), 0);

        if (!splitEnabled) {
          splitHint.textContent = 'Wpisz jedną szerokość - druga uzupełni się automatycznie.';
        } else if (splitLeftWidthInput.value !== '' || splitRightWidthInput.value !== '') {
          splitHint.textContent = `Szerokości: lewa ${left.toFixed(1)} mm / prawa ${right.toFixed(1)} mm`;
        } else {
          const half = cabinetWidth / 2.0;
          splitHint.textContent = `Po równo: ${half.toFixed(1)} mm + ${half.toFixed(1)} mm`;
        }
      }
    }
  }

  function sectionRows() {
    return Array.from(byId(form.sectionsList).querySelectorAll('[data-section-row]'));
  }


  function sectionInputRows() {
    return sectionRows();
  }

  function readSectionFromRow(sectionRow, index) {
    const filling = sectionRow.querySelector('[data-field="filling"]').value;
    const height = Math.max(Number(sectionRow.querySelector('[data-field="height"]').value || 0), 0);
    const paramValue = Math.max(Number(sectionRow.querySelector('[data-field="param"]').value || 0), 0);
    const drawerFrontReduction = Math.max(Number(sectionRow.querySelector('[data-field="drawer_front_reduction"]').value || 0), 0);
    const drawerWidthReduction = Math.max(Number(sectionRow.querySelector('[data-field="drawer_width_reduction"]').value || 40), 0);
    const drawerBoxHeightOffset = Math.max(Number(sectionRow.querySelector('[data-field="drawer_box_height_offset"]').value || 40), 0);
    const splitEnabled = !!sectionRow.querySelector('[data-field="split_enabled"]').checked;
    const splitLeftWidthRaw = sectionRow.querySelector('[data-field="split_left_width"]').value;
    const splitRightWidthRaw = sectionRow.querySelector('[data-field="split_right_width"]').value;
    const splitLeftWidth = splitLeftWidthRaw === '' ? null : Math.max(Number(splitLeftWidthRaw || 0), 0);
    const splitRightWidth = splitRightWidthRaw === '' ? null : Math.max(Number(splitRightWidthRaw || 0), 0);
    const cabinetWidth = Math.max(Number(byId(form.width).value || 0), 0);
    const splitFirstWidth = splitLeftWidth !== null ? splitLeftWidth : (splitRightWidth !== null ? Math.max(cabinetWidth - splitRightWidth, 0) : null);
    const splitLeftFilling = sectionRow.querySelector('[data-field="split_left_filling"]').value;
    const splitRightFilling = sectionRow.querySelector('[data-field="split_right_filling"]').value;
    const splitLeftParam = Math.max(Number(sectionRow.querySelector('[data-field="split_left_param"]').value || 0), 0);
    const splitRightParam = Math.max(Number(sectionRow.querySelector('[data-field="split_right_param"]').value || 0), 0);
    const splitLeftDrawerFrontReduction = Math.max(Number(sectionRow.querySelector('[data-field="split_left_drawer_front_reduction"]').value || 0), 0);
    const splitLeftDrawerWidthReduction = Math.max(Number(sectionRow.querySelector('[data-field="split_left_drawer_width_reduction"]').value || 40), 0);
    const splitLeftDrawerBoxHeightOffset = Math.max(Number(sectionRow.querySelector('[data-field="split_left_drawer_box_height_offset"]').value || 40), 0);
    const splitRightDrawerFrontReduction = Math.max(Number(sectionRow.querySelector('[data-field="split_right_drawer_front_reduction"]').value || 0), 0);
    const splitRightDrawerWidthReduction = Math.max(Number(sectionRow.querySelector('[data-field="split_right_drawer_width_reduction"]').value || 40), 0);
    const splitRightDrawerBoxHeightOffset = Math.max(Number(sectionRow.querySelector('[data-field="split_right_drawer_box_height_offset"]').value || 40), 0);

    const splitLeftConfig = {
      filling: splitLeftFilling,
      param: splitLeftParam,
      drawer_front_reduction: splitLeftDrawerFrontReduction,
      drawer_width_reduction: splitLeftDrawerWidthReduction,
      drawer_box_height_offset: splitLeftDrawerBoxHeightOffset
    };

    const splitRightConfig = {
      filling: splitRightFilling,
      param: splitRightParam,
      drawer_front_reduction: splitRightDrawerFrontReduction,
      drawer_width_reduction: splitRightDrawerWidthReduction,
      drawer_box_height_offset: splitRightDrawerBoxHeightOffset
    };

    const params = {
      top_panel: sectionRow.querySelector('[data-field="top_panel"]').checked,
      split_enabled: splitEnabled,
      split_first_width: splitEnabled ? splitFirstWidth : null,
      split_left_width: splitEnabled ? splitLeftWidth : null,
      split_right_width: splitEnabled ? splitRightWidth : null,
      split_left: splitEnabled ? splitLeftConfig : null,
      split_right: splitEnabled ? splitRightConfig : null
    };

    if (filling === 'drawers') {
      params.drawer_count = Math.max(Math.round(paramValue), 1);
      params.drawer_front_reduction = drawerFrontReduction;
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
    const nicheHeight = Math.max(cabinetHeight - cokolDolny - cokolGorny, 0);

    const usedHeight = sectionInputRows().reduce((sum, row) => sum + readSectionFromRow(row, 0).height, 0);
    const remaining = nicheHeight - usedHeight;


    const remainingLabel = byId(form.sectionsRemaining);
    remainingLabel.textContent = `Pozostała wysokość: ${remaining.toFixed(1)} mm (wnęka: ${nicheHeight.toFixed(1)} mm)`;
    remainingLabel.classList.toggle('is-error', remaining < 0);

    return { nicheHeight, remaining };
  }

  function addSection(section = {}) {
    const template = byId(form.sectionTemplate);
    const row = template.content.firstElementChild.cloneNode(true);

    row.dataset.splitInitialized = section.params?.split_enabled ? 'true' : 'false';

    row.querySelector('[data-field="height"]').value = section.height || 400;
    row.querySelector('[data-field="filling"]').value = section.filling || 'none';

    const topPanelInput = row.querySelector('[data-field="top_panel"]');
    topPanelInput.checked = !!section.params?.top_panel;

    const splitEnabledInput = row.querySelector('[data-field="split_enabled"]');
    splitEnabledInput.checked = !!section.params?.split_enabled;

    const splitLeftWidthInput = row.querySelector('[data-field="split_left_width"]');
    const splitRightWidthInput = row.querySelector('[data-field="split_right_width"]');
    const splitLeftWidth = section.params?.split_left_width;
    const splitRightWidth = section.params?.split_right_width;
    const splitFirstWidth = section.params?.split_first_width;
    if (splitLeftWidth !== null && splitLeftWidth !== undefined) {
      splitLeftWidthInput.value = splitLeftWidth;
    } else if (splitFirstWidth !== null && splitFirstWidth !== undefined) {
      splitLeftWidthInput.value = splitFirstWidth;
    } else {
      splitLeftWidthInput.value = '';
    }

    if (splitRightWidth !== null && splitRightWidth !== undefined) {
      splitRightWidthInput.value = splitRightWidth;
    } else if (splitFirstWidth !== null && splitFirstWidth !== undefined) {
      const cabinetWidth = Math.max(Number(byId(form.width).value || 0), 0);
      splitRightWidthInput.value = Math.max(cabinetWidth - Number(splitFirstWidth || 0), 0).toFixed(1);
    } else {
      splitRightWidthInput.value = '';
    }

    const splitLeftFillingInput = row.querySelector('[data-field="split_left_filling"]');
    const splitRightFillingInput = row.querySelector('[data-field="split_right_filling"]');
    const splitLeftParamInput = row.querySelector('[data-field="split_left_param"]');
    const splitRightParamInput = row.querySelector('[data-field="split_right_param"]');
    splitLeftFillingInput.value = section.params?.split_left?.filling || section.filling || 'none';
    splitRightFillingInput.value = section.params?.split_right?.filling || section.filling || 'none';
    splitLeftParamInput.value = section.params?.split_left?.param ?? 0;
    splitRightParamInput.value = section.params?.split_right?.param ?? 0;
    row.querySelector('[data-field="split_left_drawer_front_reduction"]').value = section.params?.split_left?.drawer_front_reduction ?? section.params?.split_left?.drawer_front_height ?? section.params?.drawer_front_reduction ?? section.params?.drawer_front_height ?? 0;
    row.querySelector('[data-field="split_left_drawer_width_reduction"]').value = section.params?.split_left?.drawer_width_reduction ?? section.params?.drawer_width_reduction ?? 40;
    row.querySelector('[data-field="split_left_drawer_box_height_offset"]').value = section.params?.split_left?.drawer_box_height_offset ?? section.params?.drawer_box_height_offset ?? 40;
    row.querySelector('[data-field="split_right_drawer_front_reduction"]').value = section.params?.split_right?.drawer_front_reduction ?? section.params?.split_right?.drawer_front_height ?? section.params?.drawer_front_reduction ?? section.params?.drawer_front_height ?? 0;
    row.querySelector('[data-field="split_right_drawer_width_reduction"]').value = section.params?.split_right?.drawer_width_reduction ?? section.params?.drawer_width_reduction ?? 40;
    row.querySelector('[data-field="split_right_drawer_box_height_offset"]').value = section.params?.split_right?.drawer_box_height_offset ?? section.params?.drawer_box_height_offset ?? 40;

    const paramInput = row.querySelector('[data-field="param"]');
    if (section.filling === 'drawers') {
      paramInput.value = section.params?.drawer_count || 3;
      row.querySelector('[data-field="drawer_front_reduction"]').value = section.params?.drawer_front_reduction ?? section.params?.drawer_front_height ?? 0;
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

    row.querySelectorAll('[data-field="split_left_filling"], [data-field="split_right_filling"]').forEach((select) => {
      select.addEventListener('change', () => {
        updateSectionParamUi(row);
        updateRemainingHeight();
        window.updateCabinetPreview?.();
      });
    });

    row.querySelector('[data-field="split_left_width"]').addEventListener('input', () => {
      syncSplitWidths(row, 'left');
      updateSectionParamUi(row);
      updateRemainingHeight();
      window.updateCabinetPreview?.();
    });

    row.querySelector('[data-field="split_right_width"]').addEventListener('input', () => {
      syncSplitWidths(row, 'right');
      updateSectionParamUi(row);
      updateRemainingHeight();
      window.updateCabinetPreview?.();
    });

    row.querySelectorAll('input').forEach((input) => {
      const onValueChange = () => {
        updateSectionParamUi(row);
        updateRemainingHeight();
        window.updateCabinetPreview?.();
      };

      input.addEventListener('input', onValueChange);
      input.addEventListener('change', onValueChange);
    });



    row.querySelector('[data-action="remove"]').addEventListener('click', () => {
      row.remove();
      updateRemainingHeight();
      window.updateCabinetPreview?.();
    });

    const list = byId(form.sectionsList);
    list.appendChild(row);
    updateRemainingHeight();
  }

  function collectInteriorSections() {
    return sectionInputRows().map((row, index) => readSectionFromRow(row, index));
  }

  function applyVisibilityState() {
    updateFrontVisibility();
    updateFrontTypeVisibility();
    updateFrontOpeningDirectionLock();
    updateHandlePositionOptions();
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
    byId(form.frontHandle).value = params.front_handle || 'J';
    byId(form.frontHandlePosition).value = params.front_handle_position || 'dół';
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
      front_handle: byId(form.frontHandle).value,
      front_handle_position: byId(form.frontHandlePosition).value,
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
      form.frontHandle,
      form.frontHandlePosition,
      form.frontQuantity,
      form.cokolDolnyCheckbox,
      form.cokolGornyCheckbox,
      form.blendLeftCheckbox,
      form.blendRightCheckbox,
      form.width,
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
        sectionRows().forEach(updateSectionParamUi);
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
      if (section.params.split_enabled) {
        const cabinetWidth = Math.max(Number(byId(form.width).value || 0), 0);
        const firstWidth = section.params.split_left_width ?? section.params.split_first_width;
        const rightWidth = section.params.split_right_width;

        if (firstWidth !== null && firstWidth !== undefined) {
          if (firstWidth <= 0 || firstWidth >= cabinetWidth) return true;
        }

        if (rightWidth !== null && rightWidth !== undefined) {
          if (rightWidth <= 0 || rightWidth >= cabinetWidth) return true;
        }

        const splitSides = [section.params.split_left, section.params.split_right];
        const invalidSplit = splitSides.some((side) => {
          if (!side) return true;
          if (side.filling === 'drawers') {
            return Number(side.param || 0) < 1 || Number(side.drawer_front_reduction || 0) < 0 || Number(side.drawer_width_reduction || 0) < 0 || Number(side.drawer_box_height_offset || 0) < 0;
          }
          if (side.filling === 'shelves') return Number(side.param || 0) < 1;
          if (side.filling === 'rod') return Number(side.param || 0) < 0 || Number(side.param || 0) > section.height;
          return false;
        });
        if (invalidSplit) return true;
      }

      if (section.filling === 'drawers') {
        return Number(section.params.drawer_count || 0) < 1 || Number(section.params.drawer_front_reduction || 0) < 0 || Number(section.params.drawer_width_reduction || 0) < 0 || Number(section.params.drawer_box_height_offset || 0) < 0;
      }
      if (section.filling === 'shelves') return Number(section.params.shelf_count || 0) < 1;
      if (section.filling === 'rod') return Number(section.params.rod_offset || 0) < 0 || Number(section.params.rod_offset || 0) > section.height;
      return false;
    });

    if (invalid) {
      alert('Sprawdź konfigurację sekcji: wysokości > 0, podział sekcji mieści się w szerokości szafy, liczby elementów >= 1 i parametry w granicach sekcji.');
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
