// GO HOME 모션 플랫폼 - 조인트 연결부 상세 도면
// 클레비스 브라켓 + 로드엔드 베어링 + 연결핀
// 단위: mm

/* [조인트 규격] */
// 클레비스 브라켓
clevis_width = 80;
clevis_depth = 50;
clevis_height = 40;
clevis_thickness = 10;
clevis_gap = 35;  // 로드엔드가 들어갈 틈

// 연결핀
pin_diameter = 20;
pin_length = 80;

// 로드엔드 베어링 (SA20T/K)
rod_end_body_width = 30;
rod_end_body_height = 44;
rod_end_ball_outer = 35;
rod_end_ball_inner = 20;
rod_end_thread = 20;  // M20
rod_end_thread_length = 30;

// 마운트 플레이트
mount_plate_size = 200;
mount_plate_thickness = 12;

// 액추에이터 연결부
act_rod_diameter = 30;

/* [표시 옵션] */
show_exploded = false;  // 분해도
explode_distance = 40;
show_cross_section = false;  // 단면도

/* [색상] */
color_clevis = [0.4, 0.4, 0.45];
color_rod_end = [0.7, 0.5, 0.2];
color_pin = [0.8, 0.8, 0.8];
color_mount = [0.3, 0.3, 0.35];
color_washer = [0.6, 0.6, 0.6];
color_snap_ring = [0.2, 0.2, 0.2];

$fn = 50;

// =============================================
// 메인: 전체 조인트 조립도
// =============================================

if (show_cross_section) {
    difference() {
        joint_assembly();
        translate([0, -200, -100])
        cube([400, 400, 400]);
    }
} else {
    joint_assembly();
}

module joint_assembly() {
    exp = show_exploded ? explode_distance : 0;

    // 1. 마운트 플레이트 (프레임에 용접)
    translate([0, 0, -mount_plate_thickness/2 - exp*2])
    color(color_mount)
    mount_plate();

    // 2. 클레비스 브라켓
    translate([0, 0, 0])
    color(color_clevis)
    clevis_bracket();

    // 3. 로드엔드 베어링
    translate([0, 0, clevis_height + exp])
    color(color_rod_end)
    rod_end_bearing();

    // 4. 연결 핀
    translate([0, 0, clevis_height])
    rotate([0, 90, 0])
    color(color_pin)
    connection_pin();

    // 5. 와셔 (양쪽)
    for (side = [-1, 1]) {
        translate([side * (clevis_width/2 - clevis_thickness + 3 + exp/2), 0, clevis_height])
        rotate([0, 90, 0])
        color(color_washer)
        washer();
    }

    // 6. 스냅링 (양쪽)
    for (side = [-1, 1]) {
        translate([side * (pin_length/2 - 3 + exp), 0, clevis_height])
        rotate([0, 90, 0])
        color(color_snap_ring)
        snap_ring();
    }

    // 7. 액추에이터 로드 (위쪽으로 연결)
    translate([0, 0, clevis_height + rod_end_body_height + rod_end_thread_length + exp*2])
    color([0.6, 0.6, 0.65])
    actuator_rod_end();
}

// =============================================
// 클레비스 브라켓 (U자형)
// =============================================

module clevis_bracket() {
    difference() {
        union() {
            // 베이스 플레이트
            translate([0, 0, clevis_thickness/2])
            cube([clevis_width, clevis_depth, clevis_thickness], center=true);

            // U자 좌측 벽
            translate([-(clevis_width/2 - clevis_thickness/2), 0, clevis_height/2 + clevis_thickness/2])
            cube([clevis_thickness, clevis_depth, clevis_height - clevis_thickness], center=true);

            // U자 우측 벽
            translate([(clevis_width/2 - clevis_thickness/2), 0, clevis_height/2 + clevis_thickness/2])
            cube([clevis_thickness, clevis_depth, clevis_height - clevis_thickness], center=true);
        }

        // 핀 홀 (양쪽 벽)
        translate([0, 0, clevis_height])
        rotate([0, 90, 0])
        cylinder(h=clevis_width + 10, d=pin_diameter + 2, center=true);

        // 베이스 볼트 홀 4개
        for (dx = [-25, 25]) {
            for (dy = [-15, 15]) {
                translate([dx, dy, 0])
                cylinder(h=clevis_thickness + 10, d=12, center=true);
            }
        }
    }
}

// =============================================
// 로드엔드 베어링 (SA20T/K)
// =============================================

module rod_end_bearing() {
    // 본체 (직사각형 부분)
    difference() {
        // 외부 하우징
        hull() {
            translate([0, 0, rod_end_body_height/2])
            cube([rod_end_body_width, rod_end_body_width*0.8, rod_end_body_height], center=true);
        }

        // 구면 베어링 공간
        translate([0, 0, rod_end_body_height/2])
        sphere(d=rod_end_ball_outer);

        // 핀 홀
        rotate([0, 90, 0])
        cylinder(h=rod_end_body_width + 10, d=pin_diameter, center=true);
    }

    // 구면 베어링 (내부 볼)
    translate([0, 0, rod_end_body_height/2])
    difference() {
        color([0.85, 0.7, 0.3])
        sphere(d=rod_end_ball_outer - 4);

        // 내부 구멍
        sphere(d=rod_end_ball_inner + 5);

        // 핀 홀
        rotate([0, 90, 0])
        cylinder(h=50, d=pin_diameter, center=true);
    }

    // 나사부 (위로 연장)
    translate([0, 0, rod_end_body_height])
    difference() {
        cylinder(h=rod_end_thread_length, d=rod_end_thread);
        // 나사산 표현 (간략화)
        for (z = [5:5:rod_end_thread_length-5]) {
            translate([0, 0, z])
            rotate_extrude()
            translate([rod_end_thread/2 - 1, 0, 0])
            circle(d=2);
        }
    }
}

// =============================================
// 연결 핀 (SCM440 고강도)
// =============================================

module connection_pin() {
    difference() {
        union() {
            // 메인 핀
            cylinder(h=pin_length, d=pin_diameter, center=true);

            // 헤드 (한쪽)
            translate([0, 0, -pin_length/2 + 3])
            cylinder(h=6, d=pin_diameter + 6);
        }

        // 스냅링 홈 (양쪽)
        for (z = [-pin_length/2 + 5, pin_length/2 - 5]) {
            translate([0, 0, z])
            rotate_extrude()
            translate([pin_diameter/2 - 1, 0, 0])
            square([3, 2], center=true);
        }
    }
}

// =============================================
// 와셔
// =============================================

module washer() {
    difference() {
        cylinder(h=3, d=pin_diameter + 12, center=true);
        cylinder(h=5, d=pin_diameter + 1, center=true);
    }
}

// =============================================
// 스냅링 (외측용)
// =============================================

module snap_ring() {
    difference() {
        cylinder(h=2, d=pin_diameter + 8, center=true);
        cylinder(h=4, d=pin_diameter - 2, center=true);
        // 열림 부분
        translate([0, pin_diameter/2 + 2, 0])
        cube([4, 10, 5], center=true);
    }
}

// =============================================
// 마운트 플레이트
// =============================================

module mount_plate() {
    difference() {
        cube([mount_plate_size, mount_plate_size, mount_plate_thickness], center=true);

        // 볼트 홀 4개 (모서리)
        for (dx = [-70, 70]) {
            for (dy = [-70, 70]) {
                translate([dx, dy, 0])
                cylinder(h=mount_plate_thickness + 2, d=14, center=true);
            }
        }

        // 중앙 홀 (클레비스 볼트용)
        for (dx = [-25, 25]) {
            for (dy = [-15, 15]) {
                translate([dx, dy, 0])
                cylinder(h=mount_plate_thickness + 2, d=14, center=true);
            }
        }
    }
}

// =============================================
// 액추에이터 로드 끝단
// =============================================

module actuator_rod_end() {
    // 로드
    cylinder(h=100, d=act_rod_diameter);

    // 암나사부 (로드엔드와 체결)
    translate([0, 0, -5])
    difference() {
        cylinder(h=15, d=act_rod_diameter + 5);
        cylinder(h=20, d=rod_end_thread, center=true);
    }
}

// =============================================
// 치수 표시용 모듈
// =============================================

module dimension_line(start, end, text_str, offset=30) {
    dir = end - start;
    len = norm(dir);
    angle = atan2(dir[1], dir[0]);

    translate(start)
    rotate([0, 0, angle]) {
        // 선
        color([0, 0, 0])
        translate([0, offset, 0])
        cube([len, 0.5, 0.5]);

        // 화살표
        for (x = [0, len]) {
            translate([x, offset, 0])
            rotate([0, 0, x == 0 ? 0 : 180])
            linear_extrude(height=1)
            polygon([[0, 0], [-5, 3], [-5, -3]]);
        }

        // 치수 텍스트
        translate([len/2, offset + 10, 0])
        color([0, 0, 0])
        linear_extrude(height=1)
        text(text_str, size=8, halign="center");
    }
}

// =============================================
// 개별 부품 뷰 (주석 해제하여 사용)
// =============================================

// 클레비스만 보기
// clevis_bracket();

// 로드엔드만 보기
// rod_end_bearing();

// 핀만 보기
// connection_pin();

// 분해도 보기 (상단 show_exploded = true로 변경)
