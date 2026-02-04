// GO HOME 4DOF 모션 플랫폼 - 알루미늄 프로파일 버전
// 버전: 3.0 (4DOF + 바닥 직접 앵커 + 알루미늄 프로파일)
// 단위: mm

/* [메인 치수] */
// 상부 플랫폼 크기
platform_width = 1800;   // X방향 (좌우)
platform_depth = 2000;   // Y방향 (전후)

// 액추에이터 배치
act_spacing_x = 1400;    // 좌우 간격
act_spacing_y = 1600;    // 전후 간격

// 액추에이터 사양
act_stroke = 200;        // 스트로크
act_body_length = 300;   // 본체 길이
act_diameter = 80;       // 본체 직경
act_rod_diameter = 30;   // 로드 직경

// 알루미늄 프로파일 규격
profile_size = 80;       // 8080 프로파일
profile_slot = 10;       // 슬롯 폭

// 조인트 규격
clevis_width = 80;
clevis_height = 50;
pin_diameter = 20;

/* [표시 옵션] */
show_floor = true;
show_platform = true;
show_actuators = true;
show_joints = true;
show_seats = true;
show_dimensions = true;
show_brackets = true;

// 현재 자세 (애니메이션용)
pitch_angle = 0;     // -10 ~ +10
roll_angle = 0;      // -10 ~ +10
heave_offset = 0;    // -50 ~ +50

/* [색상] */
color_profile = [0.75, 0.75, 0.78];      // 알루미늄 실버
color_bracket = [0.3, 0.3, 0.35];        // 브라켓 다크그레이
color_floor_plate = [0.4, 0.4, 0.45];    // 바닥 플레이트
color_actuator_body = [0.2, 0.2, 0.8];
color_actuator_rod = [0.7, 0.7, 0.7];
color_joint = [0.8, 0.6, 0.2];
color_seat = [0.9, 0.3, 0.3, 0.5];
color_top_plate = [0.85, 0.85, 0.88];

$fn = 30;

// =============================================
// 메인 조립
// =============================================

main_assembly();

module main_assembly() {
    // 바닥 (콘크리트)
    if (show_floor) {
        color([0.6, 0.6, 0.6, 0.3])
        translate([0, 0, -15])
        cube([2500, 2800, 30], center=true);
    }

    // 바닥 마운트 플레이트 4개
    floor_mounts();

    // 플랫폼 높이 계산
    platform_z = act_body_length + act_stroke/2 + 50 + heave_offset;

    // 상부 플랫폼
    if (show_platform) {
        translate([0, 0, platform_z])
        rotate([pitch_angle, roll_angle, 0])
        {
            platform_frame();

            // 좌석 표시
            if (show_seats) {
                seat_layout();
            }
        }
    }

    // 액추에이터 4개
    if (show_actuators) {
        actuator_assembly(platform_z);
    }

    // 치수 표시
    if (show_dimensions) {
        dimension_annotations();
    }
}

// =============================================
// 바닥 마운트 플레이트
// =============================================

module floor_mounts() {
    positions = get_actuator_positions();

    for (pos = positions) {
        translate([pos[0], pos[1], 0])
        floor_mount_plate();
    }
}

module floor_mount_plate() {
    plate_size = 250;
    plate_thickness = 15;

    // 마운트 플레이트
    color(color_floor_plate)
    translate([0, 0, plate_thickness/2])
    difference() {
        cube([plate_size, plate_size, plate_thickness], center=true);

        // 앵커 볼트 구멍 4개 (M16)
        for (dx = [-90, 90]) {
            for (dy = [-90, 90]) {
                translate([dx, dy, 0])
                cylinder(h=plate_thickness+2, d=18, center=true);
            }
        }

        // 중앙 조인트 구멍
        cylinder(h=plate_thickness+2, d=30, center=true);
    }

    // 앵커 볼트 표시
    color([1, 0.5, 0])
    for (dx = [-90, 90]) {
        for (dy = [-90, 90]) {
            translate([dx, dy, -40])
            cylinder(h=60, d=16);
        }
    }
}

// =============================================
// 알루미늄 프로파일 플랫폼
// =============================================

module platform_frame() {
    // 프레임 높이 (프로파일 + 상판)
    frame_z = -profile_size - 10;

    translate([0, 0, frame_z]) {
        // === 외곽 프레임 ===

        // 종빔 2개 (Y방향) - 좌우
        for (x = [-platform_width/2 + profile_size/2, platform_width/2 - profile_size/2]) {
            translate([x, 0, profile_size/2])
            rotate([-90, 0, 0])
            color(color_profile)
            alu_profile_8080(platform_depth - profile_size);
        }

        // 횡빔 2개 (X방향) - 전후
        for (y = [-platform_depth/2 + profile_size/2, platform_depth/2 - profile_size/2]) {
            translate([0, y, profile_size/2])
            rotate([0, 90, 0])
            color(color_profile)
            alu_profile_8080(platform_width - profile_size*2);
        }

        // === 보강 횡빔 3개 ===
        for (y = [-500, 0, 500]) {
            translate([0, y, profile_size/2])
            rotate([0, 90, 0])
            color(color_profile)
            alu_profile_8080(platform_width - profile_size*2);
        }

        // === 직각 브라켓 (코너 8개 + 보강 연결 6개) ===
        if (show_brackets) {
            // 코너 브라켓
            corner_positions = [
                [-platform_width/2 + profile_size, -platform_depth/2 + profile_size, 0],
                [platform_width/2 - profile_size, -platform_depth/2 + profile_size, 180],
                [-platform_width/2 + profile_size, platform_depth/2 - profile_size, 0],
                [platform_width/2 - profile_size, platform_depth/2 - profile_size, 180]
            ];

            for (pos = corner_positions) {
                translate([pos[0], pos[1], profile_size])
                rotate([0, 0, pos[2]])
                color(color_bracket)
                corner_bracket();
            }
        }

        // === 상판 (체커플레이트 또는 합판) ===
        translate([0, 0, profile_size + 6])
        color(color_top_plate)
        cube([platform_width - 20, platform_depth - 20, 12], center=true);

        // === 액추에이터 연결 마운트 ===
        for (pos = get_actuator_positions()) {
            translate([pos[0], pos[1], 0])
            actuator_top_mount();
        }
    }
}

// =============================================
// 8080 알루미늄 프로파일
// =============================================

module alu_profile_8080(length) {
    // 8080 프로파일 단면
    linear_extrude(height=length, center=true)
    alu_profile_2d();
}

module alu_profile_2d() {
    size = profile_size;
    wall = 3;
    slot_width = 10;
    slot_depth = 8;

    difference() {
        // 외곽
        square([size, size], center=true);

        // 중앙 구멍
        circle(d=12);

        // 4면 슬롯
        for (angle = [0, 90, 180, 270]) {
            rotate([0, 0, angle])
            translate([0, size/2 - slot_depth/2, 0])
            square([slot_width, slot_depth + 1], center=true);
        }

        // 내부 경량화 홈 (4개)
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([dx * size/4, dy * size/4, 0])
                square([size/3, size/3], center=true);
            }
        }
    }
}

// =============================================
// 직각 브라켓
// =============================================

module corner_bracket() {
    bracket_size = 80;
    thickness = 8;

    difference() {
        union() {
            // L자 형태
            cube([bracket_size, thickness, bracket_size]);
            cube([thickness, bracket_size, bracket_size]);
        }

        // 볼트 구멍
        for (i = [20, 60]) {
            // 수평면
            translate([i, thickness/2, -1])
            cylinder(h=bracket_size+2, d=9);
            // 수직면
            translate([thickness/2, i, 40])
            rotate([0, 90, 0])
            cylinder(h=bracket_size, d=9);
        }

        // 경량화 컷
        translate([30, -1, 30])
        cube([40, thickness+2, 40]);
    }
}

// =============================================
// 액추에이터 상부 마운트
// =============================================

module actuator_top_mount() {
    plate_size = 150;
    plate_thickness = 12;

    color(color_bracket)
    translate([0, 0, -plate_thickness/2])
    difference() {
        cube([plate_size, plate_size, plate_thickness], center=true);

        // 프로파일 연결 볼트
        for (dx = [-50, 50]) {
            for (dy = [-50, 50]) {
                translate([dx, dy, 0])
                cylinder(h=plate_thickness+2, d=9, center=true);
            }
        }

        // 조인트 연결 구멍
        cylinder(h=plate_thickness+2, d=25, center=true);
    }
}

// =============================================
// 액추에이터 조립
// =============================================

module actuator_assembly(platform_z) {
    positions = get_actuator_positions();

    for (i = [0:3]) {
        pos = positions[i];
        act_length = act_body_length + act_stroke/2;

        translate([pos[0], pos[1], 15]) {  // 마운트 플레이트 위
            // 하부 조인트
            if (show_joints) {
                color(color_joint)
                clevis_joint();
            }

            // 액추에이터
            translate([0, 0, clevis_height])
            actuator(act_length);

            // 상부 조인트
            if (show_joints) {
                translate([0, 0, clevis_height + act_length])
                color(color_joint)
                rotate([180, 0, 0])
                clevis_joint();
            }
        }

        // 액추에이터 번호
        color([0.2, 0.2, 0.2])
        translate([pos[0], pos[1], -35])
        linear_extrude(height=2)
        text(str("ACT", i+1), size=40, halign="center", valign="center");
    }
}

function get_actuator_positions() = [
    [-act_spacing_x/2, act_spacing_y/2],    // ACT1: 전방좌
    [act_spacing_x/2, act_spacing_y/2],     // ACT2: 전방우
    [-act_spacing_x/2, -act_spacing_y/2],   // ACT3: 후방좌
    [act_spacing_x/2, -act_spacing_y/2]     // ACT4: 후방우
];

// =============================================
// 클레비스 조인트
// =============================================

module clevis_joint() {
    // 간략화된 조인트
    difference() {
        union() {
            // 베이스
            cylinder(h=10, d=60);
            // U자 벽
            translate([0, 0, 10])
            difference() {
                cylinder(h=clevis_height-10, d=60);
                translate([0, 0, -1])
                cylinder(h=clevis_height, d=40);
            }
        }
        // 핀 홀
        translate([0, 0, clevis_height - 15])
        rotate([0, 90, 0])
        cylinder(h=80, d=pin_diameter+2, center=true);
    }

    // 로드엔드 볼
    translate([0, 0, clevis_height - 15])
    sphere(d=35);
}

// =============================================
// 액추에이터
// =============================================

module actuator(length) {
    body_len = length * 0.65;
    rod_len = length * 0.35;

    // 본체
    color(color_actuator_body)
    cylinder(h=body_len, d=act_diameter);

    // 로드
    color(color_actuator_rod)
    translate([0, 0, body_len])
    cylinder(h=rod_len, d=act_rod_diameter);

    // 마운트 링
    color([0.3, 0.3, 0.35])
    translate([0, 0, 20])
    difference() {
        cylinder(h=25, d=act_diameter + 15);
        translate([0, 0, -1])
        cylinder(h=30, d=act_diameter - 5);
    }
}

// =============================================
// 좌석 배치
// =============================================

module seat_layout() {
    seat_positions = [
        [-350, 500],   // 좌석 1
        [350, 500],    // 좌석 2
        [-350, 0],     // 좌석 3
        [350, 0],      // 좌석 4
        [0, -500]      // 좌석 5
    ];

    for (i = [0:4]) {
        pos = seat_positions[i];
        translate([pos[0], pos[1], 20])
        color(color_seat)
        seat_shape(i + 1);
    }
}

module seat_shape(num) {
    // 좌석 (원통형 표시)
    cylinder(h=400, d1=350, d2=300);

    // 번호
    translate([0, 0, 10])
    color([1, 1, 1])
    linear_extrude(height=3)
    text(str(num), size=80, halign="center", valign="center");
}

// =============================================
// 치수 표시
// =============================================

module dimension_annotations() {
    z = act_body_length + act_stroke/2 + 100;

    // 플랫폼 크기
    color([0, 0, 0]) {
        // 너비
        translate([0, platform_depth/2 + 150, z])
        rotate([90, 0, 0])
        linear_extrude(height=2)
        text(str(platform_width, " mm"), size=60, halign="center");

        // 깊이
        translate([platform_width/2 + 150, 0, z])
        rotate([90, 0, 90])
        linear_extrude(height=2)
        text(str(platform_depth, " mm"), size=60, halign="center");
    }

    // 액추에이터 간격
    color([0, 0, 0.8]) {
        translate([0, -act_spacing_y/2 - 100, 50])
        rotate([90, 0, 0])
        linear_extrude(height=2)
        text(str("X: ", act_spacing_x, "mm"), size=50, halign="center");

        translate([-act_spacing_x/2 - 150, 0, 50])
        rotate([90, 0, 90])
        linear_extrude(height=2)
        text(str("Y: ", act_spacing_y, "mm"), size=50, halign="center");
    }
}

// =============================================
// 개별 부품 보기
// =============================================

// 프로파일 단면만 보기
module show_profile_section() {
    scale(3)
    linear_extrude(height=10)
    alu_profile_2d();
}

// 브라켓만 보기
module show_bracket_only() {
    scale(2) corner_bracket();
}
