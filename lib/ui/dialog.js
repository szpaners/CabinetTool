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
}


function setFormData(params) {
    if (!params) return;

    console.log(params);

document.getElementById('width').value = params.width;
    document.getElementById('height').value = params.height;
    document.getElementById('depth').value = params.depth;
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
    document.getElementById('blend_left_value').value = params.blend_left_value;
    document.getElementById('blend_right_value').value = params.blend_right_value;
    document.getElementById('blend_left_depth_value').value = params.blend_left_depth_value;
    document.getElementById('blend_right_depth_value').value = params.blend_right_depth_value;
    document.getElementById('front_checkbox').checked = !!params.front_enabled;
    document.getElementById('front_technological_gap').value = params.front_technological_gap || 0;
    document.getElementById('front_quantity').value = params.front_quantity || 1;
    document.getElementById('front_opening_direction').value = params.front_opening_direction || 'prawo';

    toggleFrontSection();
    toggleFrontOpeningDirectionLock();

    // Pokaż/ukryj inputy na podstawie parametrów
    updateFillingOptions();

    if (params.cokol_value && params.cokol_value > 0) {
        document.getElementById('cokol_checkbox').checked = true;
        document.getElementById('cokol_input').style.display = 'block';
        document.getElementById('cokol_value').value = params.cokol_value;
    }

    if (params.blend_right_value && params.blend_right_value > 0) {
        document.getElementById('blend_right').checked = true;
        document.getElementById('blend_right_input').style.display = 'block';
        document.getElementById('blend_right_input').classList.remove('is-hidden');
        document.getElementById('blend_right_value').value = params.blend_right_value;
    }

    if (params.blend_left_value && params.blend_left_value > 0) {
        document.getElementById('blend_left').checked = true;
        document.getElementById('blend_left_input').style.display = 'block';
        document.getElementById('blend_left_input').classList.remove('is-hidden');
        document.getElementById('blend_left_value').value = params.blend_left_value;
    }

    if (params.blend_left_depth_value && params.blend_left_depth_value > 0) {
        document.getElementById('blend_left_depth_checkbox').checked = true;
        document.getElementById('blend_left_depth_input').classList.remove('is-hidden');
        document.getElementById('blend_left_depth_value').value = params.blend_left_depth_value;
    }

if (params.blend_right_depth_value && params.blend_right_depth_value > 0) {
        document.getElementById('blend_right_depth_checkbox').checked = true;
        document.getElementById('blend_right_depth_input').classList.remove('is-hidden');
        document.getElementById('blend_right_depth_value').value = params.blend_right_depth_value;
    }

    if (params.cokol_dolny_value && params.cokol_dolny_value > 0) {
        document.getElementById('cokol_dolny_checkbox').checked = true;
        document.getElementById('cokol_dolny_input').style.display = 'block';
        document.getElementById('cokol_dolny_offset_input').style.display = 'block';
        document.getElementById('cokol_dolny_value').value = params.cokol_dolny_value;
    }

    document.getElementById('cokol_dolny_offset_value').value = params.cokol_dolny_offset_value || 0;

    if (params.cokol_gorny_value && params.cokol_gorny_value > 0) {
        document.getElementById('cokol_gorny_checkbox').checked = true;
        document.getElementById('cokol_gorny_input').style.display = 'block';
        document.getElementById('cokol_gorny_offset_input').style.display = 'block';
        document.getElementById('cokol_gorny_value').value = params.cokol_gorny_value;
    }

    document.getElementById('cokol_gorny_offset_value').value = params.cokol_gorny_offset_value || 0;

    updateCabinetPreview();
}

function saveCabinet() {
const params = {
        width: document.getElementById('width').value,
        height: document.getElementById('height').value,
        depth: document.getElementById('depth').value,
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
    if (frontType === 'rama') {
        frameWidthGroup.style.display = 'block';
    } else {
        frameWidthGroup.style.display = 'none';
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
    const filling = document.getElementById('filling').value;
    const frontEnabled = document.getElementById('front_checkbox').checked || filling === 'drawers';
    const frontQuantity = Number(document.getElementById('front_quantity').value || 1);
    const openingDirection = document.getElementById('front_opening_direction').value;
    const drawerCount = Math.max(Number(document.getElementById('drawer_count').value || 1), 1);
    const shelfCount = Math.max(Number(document.getElementById('shelf_count').value || 1), 1);
    const firstDrawerHeight = Math.max(Number(document.getElementById('first_drawer_height').value || 100), 1);
    const drawersAsymmetric = document.getElementById('drawers_asymmetric_checkbox').checked;

    const cabinetWidth = Math.max(Number(document.getElementById('width').value || 600), 1);
    const cabinetHeight = Math.max(Number(document.getElementById('height').value || 800), 1);
    const cabinetDepth = Math.max(Number(document.getElementById('depth').value || 300), 1);

    const blendLeftEnabled = document.getElementById('blend_left').checked;
    const blendRightEnabled = document.getElementById('blend_right').checked;
    const blendLeftValue = Math.max(Number(document.getElementById('blend_left_value').value || 0), 0);
    const blendRightValue = Math.max(Number(document.getElementById('blend_right_value').value || 0), 0);
    const blendLeftDepthEnabled = document.getElementById('blend_left_depth_checkbox').checked;
    const blendRightDepthEnabled = document.getElementById('blend_right_depth_checkbox').checked;
    const blendLeftDepthValue = Math.max(Number(document.getElementById('blend_left_depth_value').value || 0), 0);
    const blendRightDepthValue = Math.max(Number(document.getElementById('blend_right_depth_value').value || 0), 0);

    const cokolDolnyEnabled = document.getElementById('cokol_dolny_checkbox').checked;
    const cokolGornyEnabled = document.getElementById('cokol_gorny_checkbox').checked;
    const cokolDolnyValue = Math.max(Number(document.getElementById('cokol_dolny_value').value || 0), 0);
    const cokolGornyValue = Math.max(Number(document.getElementById('cokol_gorny_value').value || 0), 0);

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

    shadowGroup.appendChild(createSvgElement('polygon', {
        class: 'iso-shadow',
        points: pointsToString([[D[0] + 10, D[1] + 10], [C[0] + 30, C[1] + 14], [Ct[0] + 20, Ct[1] + 18], [D[0] + 44, D[1] + 14]])
    }));

    cabinetGroup.appendChild(createSvgElement('polygon', { class: 'iso-face-top', points: pointsToString([A, B, Bt, At]) }));
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

window.addEventListener('DOMContentLoaded', () => {
    toggleFrontOpeningDirectionLock();
    updateFillingOptions();

    document.querySelectorAll('input, select').forEach(element => {
        element.addEventListener('input', updateCabinetPreview);
        element.addEventListener('change', updateCabinetPreview);
    });

    updateCabinetPreview();

    if (window.sketchup && typeof window.sketchup.dialogReady === 'function') {
        window.sketchup.dialogReady();
    }
});
