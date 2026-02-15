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
    document.getElementById('blend_left_value').value = params.blend_left_value;
    document.getElementById('blend_right_value').value = params.blend_right_value;
    document.getElementById('blend_left_depth_value').value = params.blend_left_depth_value;
    document.getElementById('blend_right_depth_value').value = params.blend_right_depth_value;
    document.getElementById('front_checkbox').checked = !!params.front_enabled;
    document.getElementById('front_technological_gap').value = params.front_technological_gap || 0;
    document.getElementById('front_quantity').value = params.front_quantity || 1;

    toggleFrontSection();

    // Pokaż/ukryj inputy na podstawie parametrów
    if (params.filling === 'shelves') {
        document.getElementById('shelf-count-group').style.display = 'block';
        document.getElementById('shelf_count').value = params.shelf_count || 1;
    } else {
        document.getElementById('shelf-count-group').style.display = 'none';
    }

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
        front_enabled: document.getElementById('front_checkbox').checked,
        front_technological_gap: document.getElementById('front_checkbox').checked ? document.getElementById('front_technological_gap').value : 0,
        front_quantity: document.getElementById('front_quantity').value,
        blend_left_value: document.getElementById('blend_left').checked ? document.getElementById('blend_left_value').value : 0,
        blend_right_value: document.getElementById('blend_right').checked ? document.getElementById('blend_right_value').value : 0,
        blend_left_depth_value: document.getElementById('blend_left_depth_checkbox').checked ? document.getElementById('blend_left_depth_value').value : 0,
        blend_right_depth_value: document.getElementById('blend_right_depth_checkbox').checked ? document.getElementById('blend_right_depth_value').value : 0
    };


    const filling = document.getElementById('filling').value;
    if (filling === 'shelves') {
        params.shelf_count = document.getElementById('shelf_count').value;
    } else {
        params.shelf_count = 0;
    }

    window.sketchup.saveCabinet(JSON.stringify(params));
}

function updateFillingOptions() {
    const filling = document.getElementById('filling').value;
    const shelfCountGroup = document.getElementById('shelf-count-group');
    if (filling === 'shelves') {
        shelfCountGroup.style.display = 'block';
    } else {
        shelfCountGroup.style.display = 'none';
    }
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
}

function toggleBlendLeftDepthInput() {
    const checkbox = document.getElementById('blend_left_depth_checkbox');
    const input = document.getElementById('blend_left_depth_input');
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }
}

function toggleBlendRightDepthInput() {
    const checkbox = document.getElementById('blend_right_depth_checkbox');
    const input = document.getElementById('blend_right_depth_input');
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }
}

function toggleCokolInput() {
    const checkbox = document.getElementById('cokol_checkbox');
    const input = document.getElementById('cokol_input');
    if (checkbox.checked) {
        input.classList.remove('is-hidden');
    } else {
        input.classList.add('is-hidden');
    }
}

function toggleFrontSection() {
    const checkbox = document.getElementById('front_checkbox');
    const section = document.getElementById('front_section');
    if (checkbox.checked) {
        section.classList.remove('is-hidden');
    } else {
        section.classList.add('is-hidden');
    }
}

function updateFrontType() {
    const frontType = document.getElementById('front_type').value;
    const frameWidthGroup = document.getElementById('frame_width_group');
    if (frontType === 'rama') {
        frameWidthGroup.style.display = 'block';
    } else {
        frameWidthGroup.style.display = 'none';
    }
}

document.getElementById('front_type').addEventListener('change', updateFrontType);

window.addEventListener('DOMContentLoaded', () => {
    if (window.sketchup && typeof window.sketchup.dialogReady === 'function') {
        window.sketchup.dialogReady();
    }
});
