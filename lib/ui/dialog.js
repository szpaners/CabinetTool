function switchTab(element, tabName) {
    console.log('switchTab called with:', element, tabName);
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');
    element.classList.add('active');
    updateCabinetPreview();
}

function getActiveTabId() {
    const activeTab = document.querySelector('.tab-content.active');
    return activeTab ? activeTab.id : 'dimensions';
}

function findTabButton(tabName) {
    return Array.from(document.querySelectorAll('.tab')).find(tab => tab.getAttribute('onclick')?.includes(`'${tabName}'`));
}

function normalizeFrontType(rawFrontType) {
    const frontType = rawFrontType || 'flat';
    if (frontType === 'rama') return 'frame';
    if (['ryflowany', 'grooved', 'lamelowany'].includes(frontType)) return 'lamella';
    return frontType;
}

function setFormData(params) {
    if (!params) return;

    console.log(params);

    const selectedFrontType = normalizeFrontType(params.front_type);

    document.getElementById('width').value = params.width;
    document.getElementById('height').value = params.height;
    document.getElementById('depth').value = params.depth;
    document.getElementById('kitchen_base_checkbox').checked = !!params.kitchen_base_enabled;
    document.getElementById('connector_width').value = params.connector_width || 100;
    document.getElementById('panel_thickness').value = params.panel_thickness;
    document.getElementById('front_thickness').value = params.front_thickness;
    document.getElementById('back_thickness').value = params.back_thickness;
    document.getElementById('nazwa_szafki').value = params.nazwa_szafki || 'szafka';
    document.getElementById('color').value = params.color;
    document.getElementById('filling').value = params.filling;
    document.getElementById('shelf_count').value = params.shelf_count;
    document.getElementById('drawer_count').value = params.drawer_count || 1;
    document.getElementById('drawers_asymmetric_checkbox').checked = !!params.drawers_asymmetric;
    document.getElementById('first_drawer_height').value = params.first_drawer_height || 100;
    document.getElementById('front_checkbox').checked = !!params.front_enabled;
    document.getElementById('front_technological_gap').value = params.front_technological_gap || 0;
    document.getElementById('front_quantity').value = params.front_quantity || 1;
    document.getElementById('front_type').value = selectedFrontType;
    document.getElementById('front_handle').value = params.front_handle || 'J';
    document.getElementById('frame_width').value = params.frame_width || 20;
    document.getElementById('frame_inner_thickness').value = params.frame_inner_thickness || params.frame_inner_depth || 2;
    document.getElementById('groove_width').value = params.groove_width || 12;
    document.getElementById('groove_spacing').value = params.groove_spacing || 8;
    document.getElementById('groove_depth').value = params.groove_depth || 3;
    document.getElementById('front_opening_direction').value = params.front_opening_direction || 'prawo';

    document.getElementById('corner_width').value = params.width;
    document.getElementById('corner_height').value = params.height;
    document.getElementById('corner_depth').value = params.depth;
    document.getElementById('corner_panel_thickness').value = params.panel_thickness;
    document.getElementById('corner_front_thickness').value = params.front_thickness;
    document.getElementById('corner_back_thickness').value = params.back_thickness;
    document.getElementById('corner_nazwa_szafki').value = params.nazwa_szafki || 'szafka narożna';
    document.getElementById('corner_color').value = params.color;
    document.getElementById('corner_filling').value = ['none', 'shelves'].includes(params.filling) ? params.filling : 'none';
    document.getElementById('corner_shelf_count').value = params.shelf_count || 1;
    document.getElementById('corner_blend_left_checkbox').checked = Number(params.blend_left_value || 0) > 0;
    document.getElementById('corner_blend_right_checkbox').checked = Number(params.blend_right_value || 0) > 0;
    document.getElementById('corner_blend_left_depth_checkbox').checked = Number(params.blend_left_depth_value || 0) > 0;
    document.getElementById('corner_blend_right_depth_checkbox').checked = Number(params.blend_right_depth_value || 0) > 0;
    document.getElementById('corner_blend_left_value').value = params.blend_left_value || 0;
    document.getElementById('corner_blend_right_value').value = params.blend_right_value || 0;
    document.getElementById('corner_blend_left_depth_value').value = params.blend_left_depth_value || 0;
    document.getElementById('corner_blend_right_depth_value').value = params.blend_right_depth_value || 0;
    document.getElementById('corner_cokol_dolny_checkbox').checked = Number(params.cokol_dolny_value || 0) > 0;
    document.getElementById('corner_cokol_dolny_value').value = params.cokol_dolny_value || 0;
    document.getElementById('corner_cokol_dolny_offset_value').value = params.cokol_dolny_offset_value || 0;

    document.getElementById('blend_left').checked = Number(params.blend_left_value || 0) > 0;
    document.getElementById('blend_right').checked = Number(params.blend_right_value || 0) > 0;
    document.getElementById('blend_left_depth_checkbox').checked = Number(params.blend_left_depth_value || 0) > 0;
    document.getElementById('blend_right_depth_checkbox').checked = Number(params.blend_right_depth_value || 0) > 0;
    document.getElementById('blend_left_value').value = params.blend_left_value || 0;
    document.getElementById('blend_right_value').value = params.blend_right_value || 0;
    document.getElementById('blend_left_depth_value').value = params.blend_left_depth_value || 0;
    document.getElementById('blend_right_depth_value').value = params.blend_right_depth_value || 0;

    document.getElementById('cokol_dolny_checkbox').checked = Number(params.cokol_dolny_value || 0) > 0;
    document.getElementById('cokol_gorny_checkbox').checked = Number(params.cokol_gorny_value || 0) > 0;
    document.getElementById('cokol_dolny_value').value = params.cokol_dolny_value || 0;
    document.getElementById('cokol_gorny_value').value = params.cokol_gorny_value || 0;
    document.getElementById('cokol_dolny_offset_value').value = params.cokol_dolny_offset_value || 0;
    document.getElementById('cokol_gorny_offset_value').value = params.cokol_gorny_offset_value || 0;

    if (window.WardrobeTab) {
        window.WardrobeTab.setFormData(params);
    }

    toggleFrontSection();
    toggleKitchenBaseSection();
    updateFrontType();
    toggleFrontOpeningDirectionLock();
    updateFillingOptions();
    toggleBlendInput('left');
    toggleBlendInput('right');
    toggleBlendLeftDepthInput();
    toggleBlendRightDepthInput();
    toggleCokolDolnyInput();
    toggleCokolGornyInput();
    updateCornerFillingOptions();
    toggleCornerCokolDolnyInput();
    toggleCornerBlendInput('left');
    toggleCornerBlendInput('right');
    toggleCornerBlendDepthInput('left');
    toggleCornerBlendDepthInput('right');

    const targetTab = params.cabinet_type === 'wardrobe' ? 'materials' : params.cabinet_type === 'corner' ? 'corner' : 'dimensions';
    const targetButton = findTabButton(targetTab);
    if (targetButton) switchTab(targetButton, targetTab);

    updateCabinetPreview();
}

function saveCabinet() {
    const activeTab = getActiveTabId();

    if (activeTab === 'materials') {
        if (window.WardrobeTab && typeof window.WardrobeTab.validateBeforeSave === 'function' && !window.WardrobeTab.validateBeforeSave()) {
            return;
        }

        const params = window.WardrobeTab ? window.WardrobeTab.buildSaveParams() : {};
        window.sketchup.saveCabinet(JSON.stringify(params));
        return;
    }

    if (activeTab === 'corner') {
        const filling = document.getElementById('corner_filling').value;
        const params = {
            cabinet_type: 'corner',
            width: document.getElementById('corner_width').value,
            height: document.getElementById('corner_height').value,
            depth: document.getElementById('corner_depth').value,
            kitchen_base_enabled: false,
            connector_width: 0,
            panel_thickness: document.getElementById('corner_panel_thickness').value,
            front_thickness: document.getElementById('corner_front_thickness').value,
            back_thickness: document.getElementById('corner_back_thickness').value,
            nazwa_szafki: document.getElementById('corner_nazwa_szafki').value,
            color: document.getElementById('corner_color').value,
            filling,
            shelf_count: filling === 'shelves' ? document.getElementById('corner_shelf_count').value : 0,
            drawer_count: 0,
            drawers_asymmetric: false,
            first_drawer_height: 0,
            front_enabled: false,
            front_technological_gap: 0,
            front_quantity: 1,
            front_type: 'flat',
            front_handle: 'brak',
            frame_width: 20,
            frame_inner_thickness: 2,
            groove_width: 12,
            groove_spacing: 8,
            groove_depth: 3,
            front_opening_direction: 'prawo',
            blend_left_value: document.getElementById('corner_blend_left_checkbox').checked ? document.getElementById('corner_blend_left_value').value : 0,
            blend_right_value: document.getElementById('corner_blend_right_checkbox').checked ? document.getElementById('corner_blend_right_value').value : 0,
            blend_left_depth_value: document.getElementById('corner_blend_left_depth_checkbox').checked ? document.getElementById('corner_blend_left_depth_value').value : 0,
            blend_right_depth_value: document.getElementById('corner_blend_right_depth_checkbox').checked ? document.getElementById('corner_blend_right_depth_value').value : 0,
            cokol_dolny_value: document.getElementById('corner_cokol_dolny_checkbox').checked ? document.getElementById('corner_cokol_dolny_value').value : 0,
            cokol_gorny_value: 0,
            cokol_dolny_offset_value: document.getElementById('corner_cokol_dolny_checkbox').checked ? document.getElementById('corner_cokol_dolny_offset_value').value : 0,
            cokol_gorny_offset_value: 0
        };

        window.sketchup.saveCabinet(JSON.stringify(params));
        return;
    }

    const params = {
        cabinet_type: 'kitchen',
        width: document.getElementById('width').value,
        height: document.getElementById('height').value,
        depth: document.getElementById('depth').value,
        kitchen_base_enabled: document.getElementById('kitchen_base_checkbox').checked,
        connector_width: document.getElementById('kitchen_base_checkbox').checked ? document.getElementById('connector_width').value : 0,
        panel_thickness: document.getElementById('panel_thickness').value,
        front_thickness: document.getElementById('front_thickness').value,
        back_thickness: document.getElementById('back_thickness').value,
        nazwa_szafki: document.getElementById('nazwa_szafki').value,
        color: document.getElementById('color').value,
        filling: document.getElementById('filling').value,
        shelf_count: document.getElementById('shelf_count').value,
        drawer_count: document.getElementById('drawer_count').value,
        drawers_asymmetric: document.getElementById('drawers_asymmetric_checkbox').checked,
        first_drawer_height: document.getElementById('first_drawer_height').value,
        front_enabled: document.getElementById('front_checkbox').checked,
        front_technological_gap: document.getElementById('front_checkbox').checked ? document.getElementById('front_technological_gap').value : 0,
        front_quantity: document.getElementById('front_quantity').value,
        front_type: document.getElementById('front_type').value,
        front_handle: document.getElementById('front_handle').value,
        frame_width: document.getElementById('frame_width').value,
        frame_inner_thickness: document.getElementById('frame_inner_thickness').value,
        groove_width: document.getElementById('groove_width').value,
        groove_spacing: document.getElementById('groove_spacing').value,
        groove_depth: document.getElementById('groove_depth').value,
        front_opening_direction: document.getElementById('front_opening_direction').value,
        blend_left_value: document.getElementById('blend_left').checked ? document.getElementById('blend_left_value').value : 0,
        blend_right_value: document.getElementById('blend_right').checked ? document.getElementById('blend_right_value').value : 0,
        blend_left_depth_value: document.getElementById('blend_left_depth_checkbox').checked ? document.getElementById('blend_left_depth_value').value : 0,
        blend_right_depth_value: document.getElementById('blend_right_depth_checkbox').checked ? document.getElementById('blend_right_depth_value').value : 0,
        cokol_dolny_value: document.getElementById('cokol_dolny_checkbox').checked ? document.getElementById('cokol_dolny_value').value : 0,
        cokol_gorny_value: document.getElementById('cokol_gorny_checkbox').checked ? document.getElementById('cokol_gorny_value').value : 0,
        cokol_dolny_offset_value: document.getElementById('cokol_dolny_checkbox').checked ? document.getElementById('cokol_dolny_offset_value').value : 0,
        cokol_gorny_offset_value: document.getElementById('cokol_gorny_checkbox').checked ? document.getElementById('cokol_gorny_offset_value').value : 0
    };

    const filling = document.getElementById('filling').value;
    if (filling === 'shelves') {
        params.shelf_count = document.getElementById('shelf_count').value;
        params.drawer_count = 0;
        params.drawers_asymmetric = false;
        params.first_drawer_height = 0;
    } else if (filling === 'drawers') {
        params.shelf_count = 0;
        params.drawer_count = document.getElementById('drawer_count').value;
        params.drawers_asymmetric = document.getElementById('drawers_asymmetric_checkbox').checked;
        params.first_drawer_height = params.drawers_asymmetric ? document.getElementById('first_drawer_height').value : 0;
        params.front_enabled = true;
    } else {
        params.shelf_count = 0;
        params.drawer_count = 0;
        params.drawers_asymmetric = false;
        params.first_drawer_height = 0;
    }

    window.sketchup.saveCabinet(JSON.stringify(params));
}

function updateFillingOptions() {
    const filling = document.getElementById('filling').value;
    const shelfCountGroup = document.getElementById('shelf-count-group');
    const drawerCountGroup = document.getElementById('drawer-count-group');
    const drawersAsymmetricGroup = document.getElementById('drawers-asymmetric-group');
    const firstDrawerHeightGroup = document.getElementById('first-drawer-height-group');
    const frontCheckbox = document.getElementById('front_checkbox');
    const frontSection = document.getElementById('front_section');
    const frontQuantity = document.getElementById('front_quantity');
    const frontOpeningDirection = document.getElementById('front_opening_direction');

    if (filling === 'shelves') {
        shelfCountGroup.style.display = 'block';
        drawerCountGroup.style.display = 'none';
        drawersAsymmetricGroup.style.display = 'none';
        firstDrawerHeightGroup.style.display = 'none';
        frontCheckbox.disabled = false;
        frontQuantity.disabled = false;
        frontOpeningDirection.disabled = false;
        toggleFrontSection();
        toggleFrontOpeningDirectionLock();
    } else if (filling === 'drawers') {
        shelfCountGroup.style.display = 'none';
        drawerCountGroup.style.display = 'block';
        drawersAsymmetricGroup.style.display = 'block';
        frontCheckbox.checked = true;
        frontCheckbox.disabled = true;
        frontQuantity.value = 1;
        frontQuantity.disabled = true;
        frontOpeningDirection.value = 'wysów';
        frontOpeningDirection.disabled = true;
        frontSection.classList.remove('is-hidden');
        toggleAsymmetricDrawerInput();
    } else {
        shelfCountGroup.style.display = 'none';
        drawerCountGroup.style.display = 'none';
        drawersAsymmetricGroup.style.display = 'none';
        firstDrawerHeightGroup.style.display = 'none';
        frontCheckbox.disabled = false;
        frontQuantity.disabled = false;
        frontOpeningDirection.disabled = false;
        toggleFrontSection();
        toggleFrontOpeningDirectionLock();
    }

    updateCabinetPreview();
}


function toggleAsymmetricDrawerInput() {
    const filling = document.getElementById('filling').value;
    const checkbox = document.getElementById('drawers_asymmetric_checkbox');
    const input = document.getElementById('first-drawer-height-group');

    if (filling === 'drawers' && checkbox.checked) {
        input.style.display = 'block';
    } else {
        input.style.display = 'none';
    }

    updateCabinetPreview();
}

document.getElementById('filling').addEventListener('change', updateFillingOptions);
document.getElementById('corner_filling').addEventListener('change', updateCornerFillingOptions);

function updateCornerFillingOptions() {
    const filling = document.getElementById('corner_filling').value;
    const shelfGroup = document.getElementById('corner_shelf_count_group');
    shelfGroup.classList.toggle('is-hidden', filling !== 'shelves');

    updateCabinetPreview();
}

function toggleCornerCokolDolnyInput() {
    const enabled = document.getElementById('corner_cokol_dolny_checkbox').checked;
    document.getElementById('corner_cokol_dolny_group').classList.toggle('is-hidden', !enabled);
    document.getElementById('corner_cokol_dolny_offset_group').classList.toggle('is-hidden', !enabled);

    updateCabinetPreview();
}

function toggleCornerBlendInput(side) {
    const enabled = document.getElementById(`corner_blend_${side}_checkbox`).checked;
    document.getElementById(`corner_blend_${side}_group`).classList.toggle('is-hidden', !enabled);

    updateCabinetPreview();
}

function toggleCornerBlendDepthInput(side) {
    const enabled = document.getElementById(`corner_blend_${side}_depth_checkbox`).checked;
    document.getElementById(`corner_blend_${side}_depth_group`).classList.toggle('is-hidden', !enabled);

    updateCabinetPreview();
}

function closeDialog() {
    console.log('closeDialog called');
    window.sketchup.closeDialog();
}

function toggleBlendInput(side) {
    const checkbox = document.getElementById(`blend_${side}`);
    const input = document.getElementById(`blend_${side}_input`);
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }

    updateCabinetPreview();
}

function toggleBlendLeftDepthInput() {
    const checkbox = document.getElementById('blend_left_depth_checkbox');
    const input = document.getElementById('blend_left_depth_input');
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }

    updateCabinetPreview();
}

function toggleBlendRightDepthInput() {
    const checkbox = document.getElementById('blend_right_depth_checkbox');
    const input = document.getElementById('blend_right_depth_input');
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }

    updateCabinetPreview();
}

function toggleCokolDolnyInput() {
    const checkbox = document.getElementById('cokol_dolny_checkbox');
    const input = document.getElementById('cokol_dolny_input');
    const offsetInput = document.getElementById('cokol_dolny_offset_input');
    if (checkbox.checked) {
        input.style.display = 'block';
        offsetInput.style.display = 'block';
    } else {
        input.style.display = 'none';
        offsetInput.style.display = 'none';
    }

    updateCabinetPreview();
}

function toggleCokolGornyInput() {
    const checkbox = document.getElementById('cokol_gorny_checkbox');
    const input = document.getElementById('cokol_gorny_input');
    const offsetInput = document.getElementById('cokol_gorny_offset_input');
    if (checkbox.checked) {
        input.style.display = 'block';
        offsetInput.style.display = 'block';
    } else {
        input.style.display = 'none';
        offsetInput.style.display = 'none';
    }

    updateCabinetPreview();
}

function toggleFrontSection() {
    const checkbox = document.getElementById('front_checkbox');
    const section = document.getElementById('front_section');
    if (checkbox.checked) {
        section.classList.remove('is-hidden');
    } else {
        section.classList.add('is-hidden');
    }

    updateCabinetPreview();
}

function toggleKitchenBaseSection() {
    const checkbox = document.getElementById('kitchen_base_checkbox');
    const group = document.getElementById('connector_width_group');
    if (checkbox.checked) {
        group.classList.remove('is-hidden');
    } else {
        group.classList.add('is-hidden');
    }

    updateCabinetPreview();
}

function toggleFrontOpeningDirectionLock() {
    const frontQuantity = document.getElementById('front_quantity');
    const openingDirection = document.getElementById('front_opening_direction');
    const shouldLockDirection = Number(frontQuantity.value) === 2;

    openingDirection.disabled = shouldLockDirection;

    updateCabinetPreview();
}

function updateFrontType() {
    const frontType = document.getElementById('front_type').value;
    const frameWidthGroup = document.getElementById('frame_width_group');
    const frameInnerThicknessGroup = document.getElementById('frame_inner_thickness_group');
    const grooveWidthGroup = document.getElementById('groove_width_group');
    const grooveSpacingGroup = document.getElementById('groove_spacing_group');
    const grooveDepthGroup = document.getElementById('groove_depth_group');
    if (frontType === 'frame') {
        frameWidthGroup.style.display = 'block';
        frameInnerThicknessGroup.style.display = 'block';
        grooveWidthGroup.style.display = 'none';
        grooveSpacingGroup.style.display = 'none';
        grooveDepthGroup.style.display = 'none';
    } else if (frontType === 'lamella') {
        frameWidthGroup.style.display = 'none';
        frameInnerThicknessGroup.style.display = 'none';
        grooveWidthGroup.style.display = 'block';
        grooveSpacingGroup.style.display = 'block';
        grooveDepthGroup.style.display = 'block';
    } else {
        frameWidthGroup.style.display = 'none';
        frameInnerThicknessGroup.style.display = 'none';
        grooveWidthGroup.style.display = 'none';
        grooveSpacingGroup.style.display = 'none';
        grooveDepthGroup.style.display = 'none';
    }

    updateCabinetPreview();
}


function pointsToString(points) {
    return points.map(point => `${point[0]},${point[1]}`).join(' ');
}

function createSvgElement(name, attributes = {}) {
    const element = document.createElementNS('http://www.w3.org/2000/svg', name);
    Object.entries(attributes).forEach(([key, value]) => {
        element.setAttribute(key, value);
    });
    return element;
}

function interpolateFrontY(top, height, factor) {
    return top + (height * factor);
}

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function createFrontBands(drawerCount, drawersAsymmetric, firstDrawerHeight) {
    if (drawerCount <= 1) {
        return [{ top: 0, height: 1 }];
    }

    if (!drawersAsymmetric) {
        const bandHeight = 1 / drawerCount;
        return Array.from({ length: drawerCount }, (_, index) => ({ top: index * bandHeight, height: bandHeight }));
    }

    const firstBand = Math.min(Math.max(firstDrawerHeight / 700, 0.14), 0.62);
    const restHeight = (1 - firstBand) / (drawerCount - 1);
    return [
        { top: 0, height: firstBand },
        ...Array.from({ length: drawerCount - 1 }, (_, index) => ({ top: firstBand + (index * restHeight), height: restHeight }))
    ];
}

function updateCabinetPreview() {
    const isWardrobeTab = getActiveTabId() === 'materials';
    const isCornerTab = getActiveTabId() === 'corner';

    const filling = isWardrobeTab ? 'none' : isCornerTab ? document.getElementById('corner_filling').value : document.getElementById('filling').value;
    const frontEnabled = isWardrobeTab
        ? document.getElementById('wardrobe_front_enabled').checked
        : isCornerTab
            ? false
        : (document.getElementById('front_checkbox').checked || filling === 'drawers');
    const frontQuantity = Number((isWardrobeTab ? document.getElementById('wardrobe_front_quantity').value : document.getElementById('front_quantity').value) || 1);
    const frontType = isWardrobeTab ? document.getElementById('wardrobe_front_type').value : document.getElementById('front_type').value;
    const frameWidth = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_frame_width').value : document.getElementById('frame_width').value) || 0), 0);
    const frameInnerThickness = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_frame_inner_thickness').value : document.getElementById('frame_inner_thickness').value) || 0), 0);
    const grooveWidth = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_groove_width').value : document.getElementById('groove_width').value) || 0), 0);
    const grooveSpacing = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_groove_spacing').value : document.getElementById('groove_spacing').value) || 0), 0);
    const grooveDepth = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_groove_depth').value : document.getElementById('groove_depth').value) || 0), 0);
    const frontThickness = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_front_thickness').value : document.getElementById('front_thickness').value) || 0), 0);
    const openingDirection = isWardrobeTab ? document.getElementById('wardrobe_front_opening_direction').value : document.getElementById('front_opening_direction').value;
    const drawerCount = Math.max(Number(document.getElementById('drawer_count').value || 1), 1);
    const shelfCount = Math.max(Number((isCornerTab ? document.getElementById('corner_shelf_count').value : document.getElementById('shelf_count').value) || 1), 1);
    const firstDrawerHeight = Math.max(Number(document.getElementById('first_drawer_height').value || 100), 1);
    const drawersAsymmetric = document.getElementById('drawers_asymmetric_checkbox').checked;

    const cabinetWidth = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_width').value : isCornerTab ? document.getElementById('corner_width').value : document.getElementById('width').value) || 600), 1);
    const cabinetHeight = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_height').value : isCornerTab ? document.getElementById('corner_height').value : document.getElementById('height').value) || 800), 1);
    const cabinetDepth = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_depth').value : isCornerTab ? document.getElementById('corner_depth').value : document.getElementById('depth').value) || 300), 1);
    const panelThickness = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_panel_thickness').value : isCornerTab ? document.getElementById('corner_panel_thickness').value : document.getElementById('panel_thickness').value) || 18), 0);

    const blendLeftEnabled = isWardrobeTab ? document.getElementById('wardrobe_blend_left_checkbox').checked : isCornerTab ? document.getElementById('corner_blend_left_checkbox').checked : document.getElementById('blend_left').checked;
    const blendRightEnabled = isWardrobeTab ? document.getElementById('wardrobe_blend_right_checkbox').checked : isCornerTab ? document.getElementById('corner_blend_right_checkbox').checked : document.getElementById('blend_right').checked;
    const blendLeftValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_blend_left_value').value : isCornerTab ? document.getElementById('corner_blend_left_value').value : document.getElementById('blend_left_value').value) || 0), 0);
    const blendRightValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_blend_right_value').value : isCornerTab ? document.getElementById('corner_blend_right_value').value : document.getElementById('blend_right_value').value) || 0), 0);
    const blendLeftDepthEnabled = isWardrobeTab ? document.getElementById('wardrobe_blend_left_checkbox').checked : isCornerTab ? document.getElementById('corner_blend_left_depth_checkbox').checked : document.getElementById('blend_left_depth_checkbox').checked;
    const blendRightDepthEnabled = isWardrobeTab ? document.getElementById('wardrobe_blend_right_checkbox').checked : isCornerTab ? document.getElementById('corner_blend_right_depth_checkbox').checked : document.getElementById('blend_right_depth_checkbox').checked;
    const blendLeftDepthValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_blend_left_depth_value').value : isCornerTab ? document.getElementById('corner_blend_left_depth_value').value : document.getElementById('blend_left_depth_value').value) || 0), 0);
    const blendRightDepthValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_blend_right_depth_value').value : isCornerTab ? document.getElementById('corner_blend_right_depth_value').value : document.getElementById('blend_right_depth_value').value) || 0), 0);

    const cokolDolnyEnabled = isWardrobeTab ? document.getElementById('wardrobe_cokol_dolny_checkbox').checked : isCornerTab ? document.getElementById('corner_cokol_dolny_checkbox').checked : document.getElementById('cokol_dolny_checkbox').checked;
    const cokolGornyEnabled = isWardrobeTab ? document.getElementById('wardrobe_cokol_gorny_checkbox').checked : false;
    const cokolDolnyValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_cokol_dolny_value').value : isCornerTab ? document.getElementById('corner_cokol_dolny_value').value : document.getElementById('cokol_dolny_value').value) || 0), 0);
    const cokolGornyValue = Math.max(Number((isWardrobeTab ? document.getElementById('wardrobe_cokol_gorny_value').value : 0) || 0), 0);

    const shadowGroup = document.getElementById('preview_iso_shadow');
    const cabinetGroup = document.getElementById('preview_iso_cabinet');
    const detailsGroup = document.getElementById('preview_iso_details');
    const frontGroup = document.getElementById('preview_iso_front');
    const summary = document.getElementById('preview_summary');

    shadowGroup.innerHTML = '';
    cabinetGroup.innerHTML = '';
    detailsGroup.innerHTML = '';
    frontGroup.innerHTML = '';
    summary.innerHTML = '';

    const maxDimension = Math.max(cabinetWidth, cabinetHeight, cabinetDepth);
    const frontWidth = clamp((cabinetWidth / maxDimension) * 170, 90, 170);
    const frontHeight = clamp((cabinetHeight / maxDimension) * 150, 80, 150);
    const depthOffsetX = clamp((cabinetDepth / maxDimension) * 85, 30, 80);
    const depthOffsetY = depthOffsetX * 0.58;

    const projectedWidth = frontWidth + depthOffsetX;
    const frontLeft = clamp((340 - projectedWidth) / 2 - 6, 20, 180);
    const frontBottom = 186;
    const frontTop = frontBottom - frontHeight;

    const A = [frontLeft, frontTop];
    const B = [frontLeft + frontWidth, frontTop];
    const C = [frontLeft + frontWidth, frontBottom];
    const D = [frontLeft, frontBottom];
    const At = [A[0] + depthOffsetX, A[1] - depthOffsetY];
    const Bt = [B[0] + depthOffsetX, B[1] - depthOffsetY];
    const Ct = [C[0] + depthOffsetX, C[1] - depthOffsetY];

    const sideInsetRatio = panelThickness / cabinetWidth;
    const sideInsetFront = clamp(frontWidth * sideInsetRatio, 2, frontWidth / 4);
    const sideInsetTop = clamp(depthOffsetX * sideInsetRatio, 1, depthOffsetX / 3);
    const topFrontLeft = [A[0] + sideInsetFront, A[1]];
    const topFrontRight = [B[0] - sideInsetFront, B[1]];
    const topBackRight = [Bt[0] - sideInsetTop, Bt[1]];
    const topBackLeft = [At[0] + sideInsetTop, At[1]];

    shadowGroup.appendChild(createSvgElement('polygon', {
        class: 'iso-shadow',
        points: pointsToString([[D[0] + 10, D[1] + 10], [C[0] + 30, C[1] + 14], [Ct[0] + 20, Ct[1] + 18], [D[0] + 44, D[1] + 14]])
    }));

    cabinetGroup.appendChild(createSvgElement('polygon', { class: 'iso-face-top', points: pointsToString([topFrontLeft, topFrontRight, topBackRight, topBackLeft]) }));
    cabinetGroup.appendChild(createSvgElement('polygon', { class: 'iso-face-side', points: pointsToString([B, C, Ct, Bt]) }));
    cabinetGroup.appendChild(createSvgElement('polygon', { class: 'iso-face-front', points: pointsToString([A, B, C, D]) }));

    if (cokolGornyEnabled) {
        const topPlinthHeight = clamp((cokolGornyValue / cabinetHeight) * frontHeight, 4, 20);
        const topFront = [[A[0], A[1] - topPlinthHeight], [B[0], B[1] - topPlinthHeight], [B[0], B[1]], [A[0], A[1]]];
        const topSide = [[B[0], B[1] - topPlinthHeight], [Bt[0], Bt[1] - topPlinthHeight], [Bt[0], Bt[1]], [B[0], B[1]]];
        detailsGroup.appendChild(createSvgElement('polygon', { class: 'iso-aux', points: pointsToString(topFront) }));
        detailsGroup.appendChild(createSvgElement('polygon', { class: 'iso-aux', points: pointsToString(topSide) }));
    }

    if (cokolDolnyEnabled) {
        const bottomPlinthHeight = clamp((cokolDolnyValue / cabinetHeight) * frontHeight, 4, 22);
        const bottomFront = [[D[0], D[1]], [C[0], C[1]], [C[0], C[1] + bottomPlinthHeight], [D[0], D[1] + bottomPlinthHeight]];
        detailsGroup.appendChild(createSvgElement('polygon', { class: 'iso-aux', points: pointsToString(bottomFront) }));
    }

    if (blendLeftEnabled) {
        const leftLength = blendLeftDepthEnabled ? blendLeftDepthValue : blendLeftValue;
        const leftDepthRatio = clamp(leftLength / cabinetDepth, 0.1, 1);
        const leftBackTop = [A[0] + (depthOffsetX * leftDepthRatio), A[1] - (depthOffsetY * leftDepthRatio)];
        const leftBackBottom = [D[0] + (depthOffsetX * leftDepthRatio), D[1] - (depthOffsetY * leftDepthRatio)];

        detailsGroup.appendChild(createSvgElement('polygon', {
            class: 'iso-aux',
            points: pointsToString([[A[0], A[1]], leftBackTop, leftBackBottom, [D[0], D[1]]])
        }));
    }

    if (blendRightEnabled) {
        const rightLength = blendRightDepthEnabled ? blendRightDepthValue : blendRightValue;
        const rightDepthRatio = clamp(rightLength / cabinetDepth, 0.1, 1);
        const frontStartTop = B;
        const frontStartBottom = C;
        const rightEndTop = [B[0] + (depthOffsetX * rightDepthRatio), B[1] - (depthOffsetY * rightDepthRatio)];
        const rightEndBottom = [C[0] + (depthOffsetX * rightDepthRatio), C[1] - (depthOffsetY * rightDepthRatio)];

        detailsGroup.appendChild(createSvgElement('polygon', {
            class: 'iso-aux',
            points: pointsToString([frontStartTop, rightEndTop, rightEndBottom, frontStartBottom])
        }));
    }

    if (!frontEnabled && filling === 'shelves') {
        for (let i = 1; i <= shelfCount; i += 1) {
            const y = A[1] + (frontHeight * i / (shelfCount + 1));
            detailsGroup.appendChild(createSvgElement('line', {
                class: 'iso-line', x1: A[0] + 6, y1: y, x2: B[0] - 6, y2: y
            }));
        }
    }

    const bands = createFrontBands(drawerCount, drawersAsymmetric, firstDrawerHeight);

    if (filling === 'drawers') {
        bands.forEach(band => {
            const top = interpolateFrontY(A[1], frontHeight, band.top) + 4;
            const bottom = interpolateFrontY(A[1], frontHeight, band.top + band.height) - 4;
            frontGroup.appendChild(createSvgElement('rect', {
                class: 'iso-front-segment',
                x: A[0] + 5,
                y: top,
                width: frontWidth - 10,
                height: Math.max(bottom - top, 10),
                rx: 2
            }));
        });
    } else if (frontEnabled && frontQuantity === 2) {
        frontGroup.appendChild(createSvgElement('line', {
            class: 'iso-line', x1: A[0] + frontWidth / 2, y1: A[1] + 4, x2: A[0] + frontWidth / 2, y2: D[1] - 4
        }));
        frontGroup.appendChild(createSvgElement('text', {
            class: 'iso-arrow', x: A[0] + frontWidth * 0.25, y: A[1] + frontHeight / 2
        })).textContent = '←';
        frontGroup.appendChild(createSvgElement('text', {
            class: 'iso-arrow', x: A[0] + frontWidth * 0.75, y: A[1] + frontHeight / 2
        })).textContent = '→';
    } else if (frontEnabled) {
        const arrow = openingDirection === 'lewo' ? '←' : openingDirection === 'góra' ? '↑' : openingDirection === 'dół' ? '↓' : openingDirection === 'wysów' ? '⇅' : '→';
        frontGroup.appendChild(createSvgElement('text', {
            class: 'iso-arrow', x: A[0] + frontWidth / 2, y: A[1] + frontHeight / 2
        })).textContent = arrow;
    }

    if (frontEnabled && filling !== 'drawers' && frontType === 'frame') {
        const frameInset = clamp((frameWidth / Math.max(cabinetWidth, cabinetHeight)) * Math.min(frontWidth, frontHeight), 4, Math.min(frontWidth, frontHeight) / 4);
        const innerWidth = Math.max(frontWidth - (2 * frameInset), 10);
        const innerHeight = Math.max(frontHeight - (2 * frameInset), 10);
        const recessMm = Math.max(frontThickness - frameInnerThickness, 0);
        const recessPx = clamp((recessMm / Math.max(cabinetDepth, 1)) * depthOffsetX, 0, 10);

        frontGroup.appendChild(createSvgElement('rect', {
            class: 'iso-line',
            x: A[0] + frameInset,
            y: A[1] + frameInset,
            width: innerWidth,
            height: innerHeight,
            fill: 'none'
        }));

        frontGroup.appendChild(createSvgElement('rect', {
            class: 'iso-aux',
            x: A[0] + frameInset,
            y: A[1] + frameInset + recessPx,
            width: innerWidth,
            height: Math.max(innerHeight - recessPx, 6),
            fill: 'rgba(0,0,0,0.08)'
        }));
    } else if (frontEnabled && filling !== 'drawers' && frontType === 'lamella') {
        const lamellaStepMm = grooveWidth + grooveSpacing;
        if (lamellaStepMm > 0 && grooveWidth > 0) {
            const lamellaWidthPx = clamp((grooveWidth / cabinetWidth) * frontWidth, 2, frontWidth / 2);
            const lamellaGapPx = Math.max((grooveSpacing / cabinetWidth) * frontWidth, 0);
            const lamellaStepPx = lamellaWidthPx + lamellaGapPx;
            const sideMarginPx = clamp(lamellaGapPx / 2, 0, frontWidth / 4);
            const grooveShadeOpacity = clamp(grooveDepth / Math.max(frontThickness, 1), 0.12, 0.5);
            const startX = A[0] + sideMarginPx;
            const endX = B[0] - sideMarginPx;

            for (let x = startX; x < endX; x += lamellaStepPx) {
                const lamellaRight = Math.min(x + lamellaWidthPx, endX);
                const lamellaWidthCurrent = lamellaRight - x;
                if (lamellaWidthCurrent <= 0) {
                    continue;
                }

                frontGroup.appendChild(createSvgElement('rect', {
                    class: 'iso-aux',
                    x,
                    y: A[1] + 4,
                    width: lamellaWidthCurrent,
                    height: Math.max(frontHeight - 8, 6),
                    fill: 'rgba(255,255,255,0.14)'
                }));

                frontGroup.appendChild(createSvgElement('line', {
                    class: 'iso-line',
                    x1: x,
                    y1: A[1] + 4,
                    x2: x,
                    y2: D[1] - 4,
                    'stroke-opacity': '0.65'
                }));

                if (lamellaRight < endX && lamellaGapPx > 0) {
                    frontGroup.appendChild(createSvgElement('rect', {
                        class: 'iso-aux',
                        x: lamellaRight,
                        y: A[1] + 4,
                        width: Math.min(lamellaGapPx, endX - lamellaRight),
                        height: Math.max(frontHeight - 8, 6),
                        fill: `rgba(0,0,0,${grooveShadeOpacity.toFixed(2)})`
                    }));
                }
            }
        }
    }

    const chips = [
        `Widok: izometryczny`,
        `Wypełnienie: ${filling === 'shelves' ? `półki (${shelfCount})` : filling === 'drawers' ? `szuflady (${drawerCount})` : 'brak'}`,
        `Front: ${frontEnabled ? (filling === 'drawers' ? 'szuflady-fronty' : `${frontQuantity} szt.`) : 'brak'}`,
        `Otwarcie: ${openingDirection}`
    ];

    chips.forEach(label => {
        const chip = document.createElement('span');
        chip.className = 'preview-chip';
        chip.textContent = label;
        summary.appendChild(chip);
    });
}

document.getElementById('front_type').addEventListener('change', updateFrontType);
document.getElementById('front_quantity').addEventListener('change', toggleFrontOpeningDirectionLock);
document.getElementById('frame_width').addEventListener('input', updateCabinetPreview);
document.getElementById('frame_inner_thickness').addEventListener('input', updateCabinetPreview);
document.getElementById('groove_width').addEventListener('input', updateCabinetPreview);
document.getElementById('groove_spacing').addEventListener('input', updateCabinetPreview);
document.getElementById('groove_depth').addEventListener('input', updateCabinetPreview);

window.addEventListener('DOMContentLoaded', () => {
    toggleKitchenBaseSection();
    toggleFrontOpeningDirectionLock();
    updateFrontType();
    updateFillingOptions();
    updateCornerFillingOptions();
    toggleCornerCokolDolnyInput();
    toggleCornerBlendInput('left');
    toggleCornerBlendInput('right');
    toggleCornerBlendDepthInput('left');
    toggleCornerBlendDepthInput('right');

    document.querySelectorAll('#dimensions input, #dimensions select').forEach(element => {
        element.addEventListener('input', updateCabinetPreview);
        element.addEventListener('change', updateCabinetPreview);
    });

    document.querySelectorAll('#corner input, #corner select').forEach(element => {
        element.addEventListener('input', updateCabinetPreview);
        element.addEventListener('change', updateCabinetPreview);
    });

    if (window.WardrobeTab) {
        window.WardrobeTab.bindEvents(updateCabinetPreview);
        window.WardrobeTab.applyVisibilityState();
    }

    updateCabinetPreview();

    if (window.sketchup && typeof window.sketchup.dialogReady === 'function') {
        window.sketchup.dialogReady();
    }
});
