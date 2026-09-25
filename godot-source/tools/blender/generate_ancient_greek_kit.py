"""Generate the original low-poly Ancient Greek art kit as game-ready GLB files.

Run from the project root with:
    blender --background --factory-startup --python tools/blender/generate_ancient_greek_kit.py

The script deliberately uses only Blender primitives and generated meshes/materials.
It does not download, copy, or depend on external art assets.
"""

from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Vector


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_ROOT = PROJECT_ROOT / "assets" / "generated" / "ancient_greek"

PALETTE = {
    "limestone": (0.74, 0.68, 0.56, 1.0),
    "marble": (0.86, 0.83, 0.74, 1.0),
    "sandstone": (0.63, 0.49, 0.32, 1.0),
    "plaster": (0.84, 0.80, 0.68, 1.0),
    "plaster_warm": (0.72, 0.63, 0.49, 1.0),
    "terracotta": (0.55, 0.20, 0.09, 1.0),
    "terracotta_light": (0.70, 0.31, 0.15, 1.0),
    "wood": (0.25, 0.12, 0.045, 1.0),
    "wood_light": (0.40, 0.23, 0.10, 1.0),
    "clay": (0.61, 0.25, 0.105, 1.0),
    "clay_dark": (0.42, 0.13, 0.055, 1.0),
    "earth": (0.40, 0.29, 0.17, 1.0),
    "road_stone": (0.52, 0.48, 0.40, 1.0),
    "fabric_cream": (0.76, 0.68, 0.49, 1.0),
    "fabric_blue": (0.08, 0.24, 0.43, 1.0),
    "fabric_red": (0.43, 0.12, 0.075, 1.0),
    "fabric_green": (0.11, 0.30, 0.23, 1.0),
    "fabric_white": (0.82, 0.79, 0.68, 1.0),
    "fabric_ochre": (0.62, 0.34, 0.10, 1.0),
    "paint_blue": (0.07, 0.22, 0.34, 1.0),
    "paint_red": (0.48, 0.13, 0.075, 1.0),
    "bronze": (0.48, 0.30, 0.10, 1.0),
    "skin": (0.55, 0.31, 0.18, 1.0),
    "skin_light": (0.63, 0.39, 0.23, 1.0),
    "hair_dark": (0.075, 0.035, 0.018, 1.0),
    "hair_gray": (0.25, 0.23, 0.20, 1.0),
    "leather": (0.20, 0.075, 0.028, 1.0),
    "dark_opening": (0.055, 0.040, 0.028, 1.0),
}

MATERIALS: dict[str, bpy.types.Material] = {}
ACTIVE_ROOT: bpy.types.Object | None = None


def clear_scene() -> None:
    global MATERIALS, ACTIVE_ROOT
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in (
        bpy.data.meshes,
        bpy.data.curves,
        bpy.data.armatures,
        bpy.data.materials,
        bpy.data.actions,
    ):
        for block in list(collection):
            if block.users == 0:
                collection.remove(block)
    MATERIALS = {}
    ACTIVE_ROOT = None


def begin_asset(asset_name: str) -> bpy.types.Object:
    global ACTIVE_ROOT
    clear_scene()
    ACTIVE_ROOT = bpy.data.objects.new(asset_name, None)
    bpy.context.collection.objects.link(ACTIVE_ROOT)
    return ACTIVE_ROOT


def material(name: str, color: tuple[float, float, float, float], roughness: float = 0.82) -> bpy.types.Material:
    if name in MATERIALS:
        return MATERIALS[name]
    mat = bpy.data.materials.new(f"AGK_{name}")
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = 0.0
        if name not in {"dark_opening", "eyes"}:
            texture_node = mat.node_tree.nodes.new("ShaderNodeTexImage")
            texture_node.name = "Original low-resolution surface texture"
            texture_node.image = generated_texture(name, color)
            texture_node.interpolation = "Linear"
            mat.node_tree.links.new(texture_node.outputs["Color"], bsdf.inputs["Base Color"])
    MATERIALS[name] = mat
    return mat


def generated_texture(name: str, base: tuple[float, float, float, float]) -> bpy.types.Image:
    image_name = "AGK_Surface_" + name
    existing = bpy.data.images.get(image_name)
    if existing is not None:
        return existing

    size = 64
    image = bpy.data.images.new(image_name, width=size, height=size, alpha=True)
    seed = sum((index + 1) * ord(character) for index, character in enumerate(name))
    pixels: list[float] = []
    for y in range(size):
        for x in range(size):
            broad = math.sin((x + seed) * 0.19) * 0.035 + math.cos((y - seed) * 0.23) * 0.035
            grain = math.sin((x * 17 + y * 31 + seed) * 0.41) * 0.025
            detail = broad + grain
            if name.startswith("wood"):
                detail += math.sin((y + seed) * 0.55 + math.sin(x * 0.12)) * 0.075
            elif name.startswith("fabric"):
                detail += (0.022 if x % 4 == 0 else 0.0) + (0.018 if y % 4 == 0 else 0.0)
            elif name in {"limestone", "marble", "sandstone", "road_stone"}:
                detail += math.sin((x + y + seed) * 0.11) * 0.045
                if (x * 3 + y * 5 + seed) % 47 == 0:
                    detail -= 0.10
            elif name in {"terracotta", "terracotta_light", "clay", "clay_dark"}:
                detail += math.sin((x * 5 - y * 3 + seed) * 0.22) * 0.04
            elif name in {"plaster", "plaster_warm"}:
                detail *= 0.55
            r = min(1.0, max(0.0, base[0] * (1.0 + detail)))
            g = min(1.0, max(0.0, base[1] * (1.0 + detail)))
            b = min(1.0, max(0.0, base[2] * (1.0 + detail)))
            pixels.extend((r, g, b, base[3]))
    image.pixels.foreach_set(pixels)
    image.update()
    texture_dir = OUTPUT_ROOT / "environment" / "surfaces"
    texture_dir.mkdir(parents=True, exist_ok=True)
    image.filepath_raw = str(texture_dir / f"{name}_surface.png")
    image.file_format = "PNG"
    image.save()
    return image


def mat(name: str) -> bpy.types.Material:
    return material(name, PALETTE[name])


def _parent(obj: bpy.types.Object, parent: bpy.types.Object | None = None) -> bpy.types.Object:
    obj.parent = parent if parent is not None else ACTIVE_ROOT
    return obj


def _apply_scale_and_bevel(obj: bpy.types.Object, bevel: float) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0.0:
        modifier = obj.modifiers.new("Small edge wear", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)


def add_box(
    name: str,
    location: tuple[float, float, float],
    dimensions: tuple[float, float, float],
    material_value: bpy.types.Material,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
    bevel: float = 0.025,
    parent: bpy.types.Object | None = None,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    obj.data.materials.append(material_value)
    _apply_scale_and_bevel(obj, bevel)
    return _parent(obj, parent)


def add_cylinder(
    name: str,
    location: tuple[float, float, float],
    radius: float,
    depth: float,
    material_value: bpy.types.Material,
    vertices: int = 10,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
    bevel: float = 0.015,
    radius_top: float | None = None,
    parent: bpy.types.Object | None = None,
) -> bpy.types.Object:
    if radius_top is None or abs(radius_top - radius) < 0.0001:
        bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation)
    else:
        bpy.ops.mesh.primitive_cone_add(
            vertices=vertices,
            radius1=radius,
            radius2=radius_top,
            depth=depth,
            location=location,
            rotation=rotation,
        )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material_value)
    _apply_scale_and_bevel(obj, bevel)
    return _parent(obj, parent)


def add_sphere(
    name: str,
    location: tuple[float, float, float],
    dimensions: tuple[float, float, float],
    material_value: bpy.types.Material,
    segments: int = 12,
    rings: int = 6,
    parent: bpy.types.Object | None = None,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    obj.data.materials.append(material_value)
    _apply_scale_and_bevel(obj, 0.0)
    return _parent(obj, parent)


def add_torus(
    name: str,
    location: tuple[float, float, float],
    major_radius: float,
    minor_radius: float,
    material_value: bpy.types.Material,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
    parent: bpy.types.Object | None = None,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major_radius,
        minor_radius=minor_radius,
        major_segments=12,
        minor_segments=4,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material_value)
    return _parent(obj, parent)


def add_mesh(
    name: str,
    vertices: list[tuple[float, float, float]],
    faces: list[tuple[int, ...]],
    material_value: bpy.types.Material,
    parent: bpy.types.Object | None = None,
    bevel: float = 0.0,
) -> bpy.types.Object:
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material_value)
    _parent(obj, parent)
    if bevel > 0.0:
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        modifier = obj.modifiers.new("Small edge wear", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
    return obj


def add_trapezoid_prism(
    name: str,
    z_bottom: float,
    z_top: float,
    bottom_width: float,
    top_width: float,
    bottom_depth: float,
    top_depth: float,
    material_value: bpy.types.Material,
    location_xy: tuple[float, float] = (0.0, 0.0),
    parent: bpy.types.Object | None = None,
    bevel: float = 0.015,
) -> bpy.types.Object:
    x, y = location_xy
    bw, tw = bottom_width * 0.5, top_width * 0.5
    bd, td = bottom_depth * 0.5, top_depth * 0.5
    verts = [
        (x - bw, y - bd, z_bottom), (x + bw, y - bd, z_bottom),
        (x + bw, y + bd, z_bottom), (x - bw, y + bd, z_bottom),
        (x - tw, y - td, z_top), (x + tw, y - td, z_top),
        (x + tw, y + td, z_top), (x - tw, y + td, z_top),
    ]
    faces = [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
    return add_mesh(name, verts, faces, material_value, parent, bevel)


def add_extruded_polygon(
    name: str,
    points: list[tuple[float, float]],
    z_bottom: float,
    z_top: float,
    material_value: bpy.types.Material,
) -> bpy.types.Object:
    count = len(points)
    verts = [(x, y, z_bottom) for x, y in points] + [(x, y, z_top) for x, y in points]
    faces: list[tuple[int, ...]] = [tuple(reversed(range(count))), tuple(range(count, count * 2))]
    for index in range(count):
        nxt = (index + 1) % count
        faces.append((index, nxt, count + nxt, count + index))
    return add_mesh(name, verts, faces, material_value, bevel=0.015)


def add_pediment(name: str, y: float, width: float, base_z: float, height: float, depth: float, material_value: bpy.types.Material) -> None:
    front_y, back_y = y - depth * 0.5, y + depth * 0.5
    verts = [
        (-width * 0.5, front_y, base_z), (width * 0.5, front_y, base_z), (0.0, front_y, base_z + height),
        (-width * 0.5, back_y, base_z), (width * 0.5, back_y, base_z), (0.0, back_y, base_z + height),
    ]
    faces = [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    add_mesh(name, verts, faces, material_value, bevel=0.025)


def add_gable_roof(name: str, width: float, depth: float, base_z: float, rise: float, material_value: bpy.types.Material) -> None:
    slope_length = math.sqrt((width * 0.5) ** 2 + rise**2)
    pitch = math.atan2(rise, width * 0.5)
    add_box(
        name + "Left",
        (-width * 0.25, 0.0, base_z + rise * 0.5),
        (slope_length + 0.15, depth, 0.18),
        material_value,
        rotation=(0.0, -pitch, 0.0),
        bevel=0.015,
    )
    add_box(
        name + "Right",
        (width * 0.25, 0.0, base_z + rise * 0.5),
        (slope_length + 0.15, depth, 0.18),
        material_value,
        rotation=(0.0, pitch, 0.0),
        bevel=0.015,
    )
    add_cylinder(name + "Ridge", (0.0, 0.0, base_z + rise + 0.07), 0.09, depth, material_value, 8, rotation=(math.pi * 0.5, 0.0, 0.0), bevel=0.0)


def add_curve_tube(
    name: str,
    points: list[tuple[float, float, float]],
    radius: float,
    material_value: bpy.types.Material,
    parent: bpy.types.Object | None = None,
) -> bpy.types.Object:
    curve_data = bpy.data.curves.new(name + "Curve", "CURVE")
    curve_data.dimensions = "3D"
    curve_data.resolution_u = 1
    curve_data.bevel_depth = radius
    curve_data.bevel_resolution = 0
    curve_data.resolution_u = 1
    spline = curve_data.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for point, value in zip(spline.points, points):
        point.co = (*value, 1.0)
    obj = bpy.data.objects.new(name, curve_data)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material_value)
    _parent(obj, parent)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj.select_set(False)
    return obj


def export_asset(category: str, filename: str, animations: bool = False) -> None:
    output_dir = OUTPUT_ROOT / category
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / f"{filename}.glb"
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=str(filepath),
        export_format="GLB",
        use_selection=True,
        export_yup=True,
        export_apply=True,
        export_materials="EXPORT",
        export_animations=animations,
        export_animation_mode="ACTIONS" if animations else "ACTIVE_ACTIONS",
        export_skins=animations,
        export_lights=False,
        export_cameras=False,
        export_extras=True,
    )
    print(f"GENERATED {filepath.relative_to(PROJECT_ROOT)}")


def create_temple() -> None:
    begin_asset("GreekTemple")
    stone, marble, roof = mat("limestone"), mat("marble"), mat("terracotta")
    for index, (width, depth, height) in enumerate(((14.0, 15.0, 0.22), (13.2, 14.2, 0.20), (12.4, 13.4, 0.18))):
        add_box(f"StylobateStep{index + 1}", (0.0, 0.0, 0.11 + index * 0.20), (width, depth, height), stone, bevel=0.035)
    floor_z = 0.60
    add_box("TempleFloor", (0.0, 0.0, floor_z), (11.8, 12.8, 0.16), marble, bevel=0.025)

    column_positions: set[tuple[float, float]] = set()
    for x in (-5.0, -2.5, 0.0, 2.5, 5.0):
        column_positions.add((x, -5.8))
        column_positions.add((x, 5.8))
    for y in (-3.85, -1.92, 0.0, 1.92, 3.85):
        column_positions.add((-5.0, y))
        column_positions.add((5.0, y))
    for index, (x, y) in enumerate(sorted(column_positions)):
        add_cylinder(f"ColumnBase{index:02d}A", (x, y, 0.76), 0.50, 0.14, stone, 12, bevel=0.018)
        add_cylinder(f"ColumnBase{index:02d}B", (x, y, 0.87), 0.44, 0.12, marble, 12, bevel=0.018)
        add_cylinder(f"Column{index:02d}", (x, y, 2.60), 0.39, 3.75, marble, 12, radius_top=0.30, bevel=0.018)
        add_box(f"Capital{index:02d}A", (x, y, 4.52), (0.82, 0.82, 0.16), marble, bevel=0.025)
        add_box(f"Capital{index:02d}B", (x, y, 4.66), (1.0, 1.0, 0.15), stone, bevel=0.025)

    add_box("EntablatureFront", (0.0, -5.8, 4.93), (11.8, 0.72, 0.50), stone, bevel=0.025)
    add_box("EntablatureBack", (0.0, 5.8, 4.93), (11.8, 0.72, 0.50), stone, bevel=0.025)
    add_box("EntablatureLeft", (-5.0, 0.0, 4.93), (0.72, 11.6, 0.50), stone, bevel=0.025)
    add_box("EntablatureRight", (5.0, 0.0, 4.93), (0.72, 11.6, 0.50), stone, bevel=0.025)
    # Restrained painted bands make the sanctuary read as a maintained civic temple.
    add_box("FrontBlueFrieze", (0.0, -6.18, 4.90), (10.9, 0.06, 0.13), mat("paint_blue"), bevel=0.008)
    add_box("FrontRedFrieze", (0.0, -6.19, 5.08), (10.9, 0.055, 0.07), mat("paint_red"), bevel=0.006)
    add_box("BackBlueFrieze", (0.0, 6.18, 4.90), (10.9, 0.06, 0.13), mat("paint_blue"), bevel=0.008)
    add_pediment("FrontPediment", -5.82, 11.8, 5.18, 1.55, 0.58, marble)
    add_pediment("BackPediment", 5.82, 11.8, 5.18, 1.55, 0.58, marble)
    add_gable_roof("TempleRoof", 12.2, 12.2, 5.30, 1.55, roof)

    # Cella walls deliberately stop below the roof and use an open doorway.
    add_box("CellaBack", (0.0, 4.0, 2.55), (6.2, 0.35, 3.75), stone)
    add_box("CellaLeft", (-3.0, 0.5, 2.55), (0.35, 7.2, 3.75), stone)
    add_box("CellaRight", (3.0, 0.5, 2.55), (0.35, 7.2, 3.75), stone)
    add_box("CellaFrontLeft", (-2.05, -3.0, 2.55), (1.9, 0.35, 3.75), stone)
    add_box("CellaFrontRight", (2.05, -3.0, 2.55), (1.9, 0.35, 3.75), stone)
    add_box("CellaDoorLintel", (0.0, -3.0, 4.15), (2.2, 0.35, 0.55), stone)
    add_box("SanctumShadow", (0.0, -2.78, 2.25), (1.82, 0.08, 2.95), mat("dark_opening"), bevel=0.0)
    add_box("DoorThreshold", (0.0, -3.35, 0.73), (2.15, 0.72, 0.18), marble, bevel=0.025)
    add_box("OfferingAltarBase", (0.0, -1.76, 0.91), (1.05, 0.72, 0.24), marble, bevel=0.025)
    add_trapezoid_prism("OfferingAltar", 1.02, 1.52, 0.78, 0.58, 0.54, 0.44, stone, location_xy=(0.0, -1.76), bevel=0.025)
    add_sphere("FrontAcroterion", (0.0, -5.96, 6.92), (0.34, 0.22, 0.45), marble, 10, 5)
    add_sphere("BackAcroterion", (0.0, 5.96, 6.92), (0.34, 0.22, 0.45), marble, 10, 5)
    export_asset("architecture", "GreekTemple")


def create_house_a() -> None:
    begin_asset("GreekHouse_A")
    plaster, stone, timber, roof, opening = mat("plaster"), mat("limestone"), mat("wood"), mat("terracotta"), mat("dark_opening")
    add_box("Foundation", (0.0, 0.0, 0.14), (6.4, 5.2, 0.28), stone)
    add_box("BackWall", (0.0, 2.42, 1.65), (6.0, 0.36, 3.0), plaster)
    add_box("LeftWall", (-2.82, 0.0, 1.65), (0.36, 4.5, 3.0), plaster)
    add_box("RightWall", (2.82, 0.0, 1.65), (0.36, 4.5, 3.0), plaster)
    add_box("FrontLeft", (-2.12, -2.25, 1.65), (1.4, 0.36, 3.0), plaster)
    add_box("FrontCenter", (0.05, -2.25, 1.65), (1.1, 0.36, 3.0), plaster)
    add_box("FrontRight", (2.15, -2.25, 1.65), (1.34, 0.36, 3.0), plaster)
    add_box("DoorLintel", (-1.05, -2.25, 2.72), (1.0, 0.36, 0.86), plaster)
    add_box("WindowSill", (1.0, -2.25, 0.72), (0.8, 0.36, 1.14), plaster)
    add_box("WindowLintel", (1.0, -2.25, 2.38), (0.8, 0.36, 1.54), plaster)
    add_box("WoodDoor", (-1.05, -2.46, 1.05), (0.84, 0.12, 1.85), timber, bevel=0.015)
    add_box("DoorFrameLeft", (-1.52, -2.48, 1.18), (0.12, 0.13, 2.15), stone, bevel=0.015)
    add_box("DoorFrameRight", (-0.58, -2.48, 1.18), (0.12, 0.13, 2.15), stone, bevel=0.015)
    add_box("DoorFrameTop", (-1.05, -2.48, 2.25), (1.06, 0.13, 0.14), stone, bevel=0.015)
    add_box("WindowShadow", (1.0, -2.45, 1.62), (0.66, 0.10, 0.65), opening, bevel=0.0)
    add_box("WindowSillStone", (1.0, -2.50, 1.26), (0.90, 0.22, 0.12), stone, bevel=0.02)
    add_gable_roof("TerracottaRoof", 6.7, 5.4, 3.16, 1.05, roof)
    export_asset("architecture", "GreekHouse_A")


def create_house_b() -> None:
    begin_asset("GreekHouse_B")
    plaster, stone, timber, roof = mat("plaster_warm"), mat("limestone"), mat("wood"), mat("terracotta")
    add_box("HouseFoundation", (-1.0, 1.0, 0.13), (6.4, 4.8, 0.26), stone)
    add_box("RearBlock", (-1.0, 1.75, 1.55), (6.0, 2.8, 2.85), plaster)
    add_box("RearDoor", (-1.0, 0.31, 1.05), (0.95, 0.12, 1.9), timber, bevel=0.015)
    add_box("RearDoorLintel", (-1.0, 0.24, 2.08), (1.18, 0.20, 0.15), stone, bevel=0.02)
    add_gable_roof("HouseRoof", 6.35, 3.2, 3.0, 0.92, roof)
    # Courtyard opens toward the viewer and gives this house a different footprint.
    add_box("CourtyardLeftWall", (-3.05, -1.55, 0.82), (0.42, 3.8, 1.38), stone)
    add_box("CourtyardRightWall", (1.05, -1.55, 0.82), (0.42, 3.8, 1.38), stone)
    add_box("CourtyardFrontLeft", (-2.28, -3.30, 0.82), (1.55, 0.42, 1.38), stone)
    add_box("CourtyardFrontRight", (0.28, -3.30, 0.82), (1.55, 0.42, 1.38), stone)
    add_box("CourtyardGateLintel", (-1.0, -3.30, 1.45), (1.0, 0.42, 0.22), stone)
    add_amphora_form("CourtyardAmphoraA", (-2.35, -1.65, 0.0), 0.62, "A")
    add_amphora_form("CourtyardAmphoraB", (-1.70, -1.85, 0.0), 0.50, "B")
    export_asset("architecture", "GreekHouse_B")


def create_workshop() -> None:
    begin_asset("GreekWorkshop")
    plaster, stone, timber, roof, cloth = mat("plaster"), mat("limestone"), mat("wood"), mat("terracotta"), mat("fabric_cream")
    add_box("Foundation", (0.0, 0.0, 0.12), (6.5, 5.2, 0.24), stone)
    add_box("BackWall", (0.0, 2.35, 1.55), (6.1, 0.38, 2.85), plaster)
    add_box("LeftWall", (-2.88, 0.5, 1.55), (0.38, 3.9, 2.85), plaster)
    add_box("RightWall", (2.88, 0.5, 1.55), (0.38, 3.9, 2.85), plaster)
    add_box("FlatRoof", (0.0, 0.55, 3.03), (6.35, 4.3, 0.25), roof)
    add_box("OpenFrontLintel", (0.0, -1.55, 2.65), (6.0, 0.32, 0.52), timber)
    for x in (-2.65, 2.65):
        add_cylinder(f"AwningPost{x}", (x, -2.55, 1.35), 0.10, 2.7, timber, 8)
    add_box("FabricAwning", (0.0, -2.10, 2.72), (5.7, 2.0, 0.12), cloth, rotation=(0.10, 0.0, 0.0), bevel=0.01)
    add_box("CounterTop", (0.0, -1.25, 1.05), (4.3, 0.75, 0.18), timber)
    for x in (-1.8, 1.8):
        add_box(f"CounterLeg{x}", (x, -1.25, 0.53), (0.18, 0.55, 0.95), timber)
    add_box("StorageShelf", (1.75, 1.70, 1.15), (2.0, 0.45, 0.12), timber)
    add_amphora_form("WorkshopJarA", (-1.9, 1.65, 0.0), 0.70, "C")
    add_amphora_form("WorkshopJarB", (-1.15, 1.75, 0.0), 0.55, "B")
    export_asset("architecture", "GreekWorkshop")


def create_market_stall() -> None:
    begin_asset("MarketStall")
    timber, cloth, clay = mat("wood"), mat("fabric_red"), mat("clay")
    for x in (-1.65, 1.65):
        for y in (-0.75, 0.75):
            add_cylinder(f"Post{x}_{y}", (x, y, 1.35), 0.085, 2.7, timber, 8)
    add_box("Canopy", (0.0, 0.0, 2.67), (3.7, 2.15, 0.12), cloth, rotation=(0.0, 0.045, 0.0), bevel=0.01)
    add_box("TableTop", (0.0, -0.05, 1.0), (3.1, 1.05, 0.16), timber)
    for x in (-1.25, 1.25):
        add_box(f"TableLeg{x}", (x, -0.05, 0.50), (0.16, 0.75, 0.9), timber)
    add_basket_form("MarketBasket", (-0.90, -0.04, 1.10), 0.72)
    add_amphora_form("MarketPotA", (0.25, -0.05, 1.08), 0.45, "A", base_z=1.08)
    add_amphora_form("MarketPotB", (0.92, -0.05, 1.08), 0.40, "B", base_z=1.08)
    export_asset("architecture", "MarketStall")


def add_stone_pavers(points: list[tuple[float, float]], prefix: str = "Paver") -> None:
    stone_a, stone_b = mat("road_stone"), mat("limestone")
    for index, (x, y) in enumerate(points):
        width = 0.82 + (index % 3) * 0.07
        depth = 0.74 + (index % 2) * 0.09
        stone = stone_a if index % 3 else stone_b
        add_box(
            f"{prefix}{index:02d}",
            (x, y, 0.115 + (index % 2) * 0.008),
            (width, depth, 0.11),
            stone,
            rotation=(0.0, 0.0, ((index % 3) - 1) * 0.035),
            bevel=0.025,
        )


def create_road_straight() -> None:
    begin_asset("StoneRoad_Straight")
    add_box("RoadBed", (0.0, 0.0, 0.05), (4.0, 4.0, 0.10), mat("sandstone"), bevel=0.01)
    points = [(x, y) for y in (-1.45, -0.48, 0.48, 1.45) for x in (-1.45, -0.48, 0.48, 1.45)]
    add_stone_pavers(points)
    export_asset("environment", "StoneRoad_Straight")


def create_road_corner() -> None:
    begin_asset("StoneRoad_Corner")
    outline = [(-2.0, -2.0), (2.0, -2.0), (2.0, 0.0), (0.0, 0.0), (0.0, 2.0), (-2.0, 2.0)]
    add_extruded_polygon("CornerRoadBed", outline, 0.0, 0.10, mat("sandstone"))
    points = []
    for y in (-1.45, -0.48, 0.48, 1.45):
        for x in (-1.45, -0.48, 0.48, 1.45):
            if x <= -0.05 or y <= -0.05:
                points.append((x, y))
    add_stone_pavers(points)
    export_asset("environment", "StoneRoad_Corner")


def create_stone_plaza() -> None:
    begin_asset("StonePlaza")
    add_box("PlazaBed", (0.0, 0.0, 0.06), (6.0, 6.0, 0.12), mat("sandstone"), bevel=0.015)
    points = [(x, y) for y in (-2.35, -1.4, -0.47, 0.47, 1.4, 2.35) for x in (-2.35, -1.4, -0.47, 0.47, 1.4, 2.35)]
    add_stone_pavers(points, "PlazaStone")
    export_asset("environment", "StonePlaza")


def create_dirt_path_straight() -> None:
    begin_asset("DirtPath_Straight")
    add_box("CompactedEarth", (0.0, 0.0, 0.04), (3.0, 4.0, 0.08), mat("earth"), bevel=0.03)
    for index, y in enumerate((-1.65, -0.8, 0.0, 0.8, 1.65)):
        for side in (-1.0, 1.0):
            add_sphere(f"EdgePebble{index}_{side}", (side * 1.34, y, 0.09), (0.28, 0.35, 0.16), mat("road_stone"), 8, 4)
    export_asset("environment", "DirtPath_Straight")


def create_dirt_path_curve() -> None:
    begin_asset("DirtPath_Curve")
    outer = [(-2.0, -2.0), (1.7, -2.0), (1.7, -0.2), (-0.2, -0.2), (-0.2, 1.7), (-2.0, 1.7)]
    add_extruded_polygon("CurvedCompactedEarth", outer, 0.0, 0.08, mat("earth"))
    edge_points = [(-1.75, -1.7), (-0.8, -1.7), (0.3, -1.7), (1.35, -1.7), (1.35, -0.55), (-0.55, 0.3), (-0.55, 1.35), (-1.7, 1.35)]
    for index, (x, y) in enumerate(edge_points):
        add_sphere(f"CurvePebble{index}", (x, y, 0.09), (0.30, 0.34, 0.16), mat("road_stone"), 8, 4)
    export_asset("environment", "DirtPath_Curve")


def create_stone_stairs() -> None:
    begin_asset("StoneStairs")
    stone = mat("limestone")
    step_count = 6
    for index in range(step_count):
        # Every tread is a separate solid block; faces meet without coplanar overlap.
        step_depth = 0.58
        height = 0.22 * (index + 1)
        y = -1.45 + index * step_depth
        add_box(f"Step{index + 1}", (0.0, y, height * 0.5), (4.0, step_depth, height), stone, bevel=0.025)
    export_asset("environment", "StoneStairs")


def create_stone_platform() -> None:
    begin_asset("StonePlatform")
    stone, marble = mat("limestone"), mat("marble")
    add_box("LowerCourse", (0.0, 0.0, 0.12), (6.0, 6.0, 0.24), stone)
    add_box("MiddleCourse", (0.0, 0.0, 0.30), (5.6, 5.6, 0.16), stone)
    add_box("PlatformTop", (0.0, 0.0, 0.45), (5.2, 5.2, 0.14), marble)
    export_asset("environment", "StonePlatform")


def add_wall_blocks(name: str, length: float, height: float, axis: str = "X", offset: tuple[float, float] = (0.0, 0.0)) -> None:
    stone_a, stone_b = mat("limestone"), mat("sandstone")
    courses = max(1, round(height / 0.42))
    block_length = 0.78
    blocks = max(1, math.ceil(length / block_length))
    ox, oy = offset
    for course in range(courses):
        z = 0.21 + course * 0.42
        stagger = 0.36 if course % 2 else 0.0
        for index in range(blocks):
            coordinate = -length * 0.5 + 0.40 + index * block_length + stagger
            if coordinate > length * 0.5 - 0.18:
                continue
            dimensions = (0.72, 0.52, 0.36) if axis == "X" else (0.52, 0.72, 0.36)
            location = (ox + coordinate, oy, z) if axis == "X" else (ox, oy + coordinate, z)
            add_box(f"{name}_{course}_{index}", location, dimensions, stone_a if (course + index) % 3 else stone_b, bevel=0.035)


def create_wall_straight() -> None:
    begin_asset("StoneWall_Straight")
    add_wall_blocks("WallBlock", 4.0, 1.7)
    export_asset("environment", "StoneWall_Straight")


def create_wall_corner() -> None:
    begin_asset("StoneWall_Corner")
    add_wall_blocks("CornerX", 4.0, 1.7, "X", (0.0, 0.0))
    # The second run begins beyond the first wall thickness, avoiding duplicate faces.
    add_wall_blocks("CornerY", 3.5, 1.7, "Y", (-1.75, 2.0))
    export_asset("environment", "StoneWall_Corner")


def create_wall_end() -> None:
    begin_asset("StoneWall_End")
    add_wall_blocks("EndWall", 2.8, 1.7)
    add_box("FinishedEndCap", (1.46, 0.0, 0.85), (0.24, 0.62, 1.72), mat("limestone"), bevel=0.045)
    export_asset("environment", "StoneWall_End")


def create_low_wall() -> None:
    begin_asset("LowStoneWall")
    add_wall_blocks("LowWall", 4.0, 0.8)
    add_box("Coping", (0.0, 0.0, 0.88), (4.05, 0.62, 0.14), mat("limestone"), bevel=0.035)
    export_asset("environment", "LowStoneWall")


def lathe_mesh(
    name: str,
    profile: list[tuple[float, float]],
    material_value: bpy.types.Material,
    segments: int = 12,
    location: tuple[float, float, float] = (0.0, 0.0, 0.0),
) -> bpy.types.Object:
    verts: list[tuple[float, float, float]] = []
    for radius, z in profile:
        for index in range(segments):
            angle = math.tau * index / segments
            verts.append((location[0] + radius * math.cos(angle), location[1] + radius * math.sin(angle), location[2] + z))
    faces: list[tuple[int, ...]] = []
    rows = len(profile)
    for row in range(rows - 1):
        for index in range(segments):
            nxt = (index + 1) % segments
            a = row * segments + index
            b = row * segments + nxt
            c = (row + 1) * segments + nxt
            d = (row + 1) * segments + index
            faces.append((a, b, c, d))
    faces.append(tuple(reversed(range(segments))))
    top_start = (rows - 1) * segments
    faces.append(tuple(top_start + index for index in range(segments)))
    return add_mesh(name, verts, faces, material_value, bevel=0.008)


def add_amphora_form(
    name: str,
    location: tuple[float, float, float],
    scale: float,
    variant: str,
    base_z: float | None = None,
) -> bpy.types.Object:
    x, y, given_z = location
    z = given_z if base_z is None else base_z
    profiles = {
        "A": [(0.11, 0.0), (0.23, 0.12), (0.32, 0.40), (0.27, 0.68), (0.14, 0.82), (0.13, 1.02), (0.20, 1.07)],
        "B": [(0.14, 0.0), (0.29, 0.16), (0.35, 0.48), (0.22, 0.76), (0.12, 0.86), (0.12, 1.00), (0.18, 1.04)],
        "C": [(0.18, 0.0), (0.34, 0.12), (0.38, 0.42), (0.31, 0.70), (0.18, 0.82), (0.18, 0.96), (0.24, 1.00)],
    }
    profile = [(radius * scale, height * scale) for radius, height in profiles[variant]]
    vessel = lathe_mesh(name, profile, mat("clay" if variant != "B" else "terracotta_light"), 12, (x, y, z))
    body_radius = (0.32 if variant == "A" else 0.35) * scale
    neck_z = z + 0.76 * scale
    for side in (-1.0, 1.0):
        points = [
            (x + side * 0.12 * scale, y, neck_z + 0.18 * scale),
            (x + side * (body_radius + 0.11 * scale), y, neck_z + 0.08 * scale),
            (x + side * (body_radius + 0.12 * scale), y, neck_z - 0.22 * scale),
            (x + side * body_radius, y, neck_z - 0.34 * scale),
        ]
        add_curve_tube(f"{name}Handle{'L' if side < 0 else 'R'}", points, 0.035 * scale, mat("clay"))
    return vessel


def add_basket_form(name: str, location: tuple[float, float, float], scale: float = 1.0) -> None:
    x, y, z = location
    add_cylinder(name + "Body", (x, y, z + 0.22 * scale), 0.38 * scale, 0.44 * scale, mat("wood_light"), 12, radius_top=0.46 * scale)
    add_torus(name + "Rim", (x, y, z + 0.45 * scale), 0.43 * scale, 0.035 * scale, mat("wood"))
    add_curve_tube(
        name + "Handle",
        [(x - 0.38 * scale, y, z + 0.42 * scale), (x - 0.24 * scale, y, z + 0.82 * scale), (x, y, z + 0.95 * scale), (x + 0.24 * scale, y, z + 0.82 * scale), (x + 0.38 * scale, y, z + 0.42 * scale)],
        0.035 * scale,
        mat("wood"),
    )


def create_amphora(filename: str, variant: str) -> None:
    begin_asset(filename)
    add_amphora_form(filename, (0.0, 0.0, 0.0), 1.0, variant)
    export_asset("props", filename)


def create_clay_jar() -> None:
    begin_asset("ClayJar")
    profile = [(0.24, 0.0), (0.42, 0.12), (0.48, 0.48), (0.39, 0.78), (0.25, 0.88), (0.28, 0.96)]
    lathe_mesh("ClayJar", profile, mat("clay_dark"), 12)
    add_torus("JarRim", (0.0, 0.0, 0.96), 0.27, 0.04, mat("clay"))
    export_asset("props", "ClayJar")


def create_basket() -> None:
    begin_asset("Basket")
    add_basket_form("Basket", (0.0, 0.0, 0.0), 1.0)
    export_asset("props", "Basket")


def add_table_geometry(bench: bool = False, stone: bool = False) -> None:
    material_value = mat("limestone") if stone else mat("wood")
    if bench:
        add_box("Seat", (0.0, 0.0, 0.62), (2.2, 0.58, 0.18), material_value)
        for x in (-0.82, 0.82):
            add_box(f"Leg{x}", (x, 0.0, 0.30), (0.28, 0.46, 0.56), material_value)
    else:
        add_box("TableTop", (0.0, 0.0, 0.95), (2.3, 1.15, 0.18), material_value)
        for x in (-0.88, 0.88):
            for y in (-0.38, 0.38):
                add_box(f"Leg{x}_{y}", (x, y, 0.46), (0.18, 0.18, 0.88), material_value)


def create_wood_table() -> None:
    begin_asset("WoodTable")
    add_table_geometry()
    export_asset("props", "WoodTable")


def create_wood_bench() -> None:
    begin_asset("WoodBench")
    add_table_geometry(bench=True)
    export_asset("props", "WoodBench")


def create_wood_crate() -> None:
    begin_asset("WoodCrate")
    timber, dark = mat("wood_light"), mat("wood")
    # Slatted, rope-era storage box with no metal or modern hardware.
    for index, z in enumerate((0.18, 0.50, 0.82)):
        add_box(f"FrontSlat{index}", (0.0, -0.48, z), (1.15, 0.10, 0.25), timber)
        add_box(f"BackSlat{index}", (0.0, 0.48, z), (1.15, 0.10, 0.25), timber)
    for side in (-0.52, 0.52):
        add_box(f"Side{side}", (side, 0.0, 0.50), (0.10, 0.90, 0.92), timber)
    for x in (-0.47, 0.47):
        add_box(f"FrontBrace{x}", (x, -0.55, 0.50), (0.10, 0.10, 1.02), dark)
    add_box("CrateBottom", (0.0, 0.0, 0.06), (1.15, 1.0, 0.12), dark)
    export_asset("props", "WoodCrate")


def create_stone_bench() -> None:
    begin_asset("StoneBench")
    add_table_geometry(bench=True, stone=True)
    export_asset("props", "StoneBench")


def create_humanoid_armature(name: str) -> bpy.types.Object:
    armature_data = bpy.data.armatures.new(name + "Skeleton")
    armature = bpy.data.objects.new(name + "Armature", armature_data)
    bpy.context.collection.objects.link(armature)
    _parent(armature)
    armature.show_in_front = True
    bpy.context.view_layer.objects.active = armature
    armature.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")

    def bone(bone_name: str, head: tuple[float, float, float], tail: tuple[float, float, float], parent_name: str | None = None) -> None:
        edit_bone = armature_data.edit_bones.new(bone_name)
        edit_bone.head = head
        edit_bone.tail = tail
        if parent_name:
            edit_bone.parent = armature_data.edit_bones[parent_name]

    bone("Root", (0.0, 0.0, 0.02), (0.0, 0.0, 0.18))
    bone("Hips", (0.0, 0.0, 0.82), (0.0, 0.0, 1.00), "Root")
    bone("Spine", (0.0, 0.0, 1.00), (0.0, 0.0, 1.43), "Hips")
    bone("Neck", (0.0, 0.0, 1.43), (0.0, 0.0, 1.55), "Spine")
    bone("Head", (0.0, 0.0, 1.55), (0.0, 0.0, 1.82), "Neck")
    bone("UpperArm.L", (-0.30, 0.0, 1.40), (-0.30, 0.0, 1.02), "Spine")
    bone("UpperArm.R", (0.30, 0.0, 1.40), (0.30, 0.0, 1.02), "Spine")
    bone("UpperLeg.L", (-0.15, 0.0, 0.83), (-0.15, 0.0, 0.12), "Hips")
    bone("UpperLeg.R", (0.15, 0.0, 0.83), (0.15, 0.0, 0.12), "Hips")
    bpy.ops.object.mode_set(mode="OBJECT")
    armature.select_set(False)
    return armature


def parent_to_bone(obj: bpy.types.Object, armature: bpy.types.Object, bone_name: str) -> None:
    world_transform = obj.matrix_world.copy()
    obj.parent = armature
    obj.parent_type = "BONE"
    obj.parent_bone = bone_name
    obj.matrix_world = world_transform


def add_face_and_hair(
    armature: bpy.types.Object,
    hair_material: bpy.types.Material,
    skin_material: bpy.types.Material,
    beard: bool = False,
    hair_style: str = "short",
) -> None:
    head = add_sphere("Head", (0.0, 0.0, 1.66), (0.35, 0.32, 0.40), skin_material, 12, 7)
    neck = add_cylinder("Neck", (0.0, 0.0, 1.47), 0.075, 0.16, skin_material, 8)
    parent_to_bone(head, armature, "Head")
    parent_to_bone(neck, armature, "Neck")

    if hair_style == "cropped":
        hair_dims, hair_loc = (0.37, 0.33, 0.16), (0.0, 0.01, 1.82)
    elif hair_style == "wavy":
        hair_dims, hair_loc = (0.40, 0.35, 0.24), (0.0, 0.02, 1.79)
    else:
        hair_dims, hair_loc = (0.38, 0.34, 0.20), (0.0, 0.01, 1.80)
    hair = add_sphere("Hair", hair_loc, hair_dims, hair_material, 10, 5)
    parent_to_bone(hair, armature, "Head")

    eye_material = material("eyes", (0.025, 0.018, 0.012, 1.0), 0.65)
    for side in (-1.0, 1.0):
        eye = add_sphere(f"Eye{'L' if side < 0 else 'R'}", (side * 0.060, -0.157, 1.69), (0.026, 0.022, 0.026), eye_material, 8, 4)
        parent_to_bone(eye, armature, "Head")
    nose = add_cylinder("Nose", (0.0, -0.183, 1.64), 0.030, 0.075, skin_material, 6, rotation=(math.pi * 0.5, 0.0, 0.0), bevel=0.0)
    parent_to_bone(nose, armature, "Head")

    if beard:
        beard_obj = add_trapezoid_prism(
            "Beard",
            1.38,
            1.64,
            0.12,
            0.26,
            0.07,
            0.07,
            hair_material,
            location_xy=(0.0, -0.185),
            bevel=0.008,
        )
        parent_to_bone(beard_obj, armature, "Head")


def add_character_limbs(
    armature: bpy.types.Object,
    skin_material: bpy.types.Material,
    sleeve_material: bpy.types.Material,
    long_sleeves: bool,
    leg_visible_height: float,
) -> None:
    for side, label in ((-1.0, "L"), (1.0, "R")):
        x = side * 0.34
        sleeve_depth = 0.34 if long_sleeves else 0.26
        sleeve_z = 1.24 if long_sleeves else 1.31
        sleeve = add_cylinder(f"Sleeve{label}", (x, 0.0, sleeve_z), 0.115, sleeve_depth, sleeve_material, 8, radius_top=0.10)
        forearm_material = sleeve_material if long_sleeves else skin_material
        forearm = add_cylinder(f"Forearm{label}", (x, 0.0, 0.98), 0.075, 0.40, forearm_material, 8, radius_top=0.065)
        hand = add_sphere(f"Hand{label}", (x, -0.005, 0.75), (0.14, 0.13, 0.17), skin_material, 8, 4)
        for obj in (sleeve, forearm, hand):
            parent_to_bone(obj, armature, f"UpperArm.{label}")

        leg_z = 0.09 + leg_visible_height * 0.5
        leg = add_cylinder(f"Leg{label}", (side * 0.15, 0.0, leg_z), 0.09, leg_visible_height, skin_material, 8, radius_top=0.10)
        sandal = add_box(f"Sandal{label}", (side * 0.15, -0.055, 0.055), (0.20, 0.34, 0.09), mat("leather"), bevel=0.018)
        strap = add_box(f"SandalStrap{label}", (side * 0.15, -0.12, 0.15), (0.19, 0.07, 0.16), mat("leather"), bevel=0.012)
        for obj in (leg, sandal, strap):
            parent_to_bone(obj, armature, f"UpperLeg.{label}")


def add_belt(armature: bpy.types.Object, z: float, material_value: bpy.types.Material) -> None:
    belt_front = add_box("BeltFront", (0.0, -0.195, z), (0.65, 0.055, 0.075), material_value, bevel=0.012)
    belt_back = add_box("BeltBack", (0.0, 0.195, z), (0.65, 0.055, 0.075), material_value, bevel=0.012)
    parent_to_bone(belt_front, armature, "Hips")
    parent_to_bone(belt_back, armature, "Hips")


def build_character_mesh(role: str, armature: bpy.types.Object) -> None:
    skin = mat("skin_light" if role == "recipient" else "skin")
    leather = mat("leather")
    if role == "player":
        cloth, accent, hair = mat("fabric_blue"), mat("fabric_ochre"), mat("hair_dark")
        torso = add_trapezoid_prism("ChitonTorso", 1.04, 1.48, 0.58, 0.70, 0.34, 0.38, cloth)
        skirt = add_trapezoid_prism("KneeLengthChiton", 0.58, 1.07, 0.80, 0.61, 0.42, 0.35, cloth)
        hem = add_box("OchreHem", (0.0, -0.225, 0.61), (0.74, 0.035, 0.075), accent, bevel=0.008)
        cloak = add_trapezoid_prism("ShortCloak", 0.90, 1.43, 0.48, 0.30, 0.055, 0.045, accent, location_xy=(-0.12, 0.235), bevel=0.006)
        for obj, bone_name in ((torso, "Spine"), (skirt, "Hips"), (hem, "Hips"), (cloak, "Spine")):
            parent_to_bone(obj, armature, bone_name)
        clasp = add_sphere("BronzeCloakClasp", (-0.24, -0.20, 1.39), (0.09, 0.04, 0.09), mat("bronze"), 8, 4)
        parent_to_bone(clasp, armature, "Spine")
        add_belt(armature, 1.04, leather)
        add_character_limbs(armature, skin, cloth, False, 0.55)
        add_face_and_hair(armature, hair, skin, False, "short")
    elif role == "teacher":
        cloth, accent, hair = mat("fabric_red"), mat("fabric_cream"), mat("hair_gray")
        torso = add_trapezoid_prism("LongChitonTorso", 1.05, 1.49, 0.60, 0.72, 0.36, 0.39, cloth)
        robe = add_trapezoid_prism("LongChitonSkirt", 0.16, 1.08, 0.92, 0.62, 0.50, 0.36, cloth)
        hem = add_box("CreamRobeHem", (0.0, -0.26, 0.20), (0.84, 0.04, 0.08), accent, bevel=0.008)
        himation = add_box("HimationFront", (-0.12, -0.225, 1.02), (0.22, 0.055, 0.88), accent, rotation=(0.0, -0.20, 0.0), bevel=0.01)
        back_cloak = add_trapezoid_prism("HimationBack", 0.44, 1.45, 0.72, 0.46, 0.05, 0.05, accent, location_xy=(0.07, 0.245), bevel=0.006)
        for obj, bone_name in ((torso, "Spine"), (robe, "Hips"), (hem, "Hips"), (himation, "Spine"), (back_cloak, "Spine")):
            parent_to_bone(obj, armature, bone_name)
        add_belt(armature, 1.06, leather)
        add_character_limbs(armature, skin, cloth, True, 0.20)
        add_face_and_hair(armature, hair, skin, True, "wavy")
    else:
        cloth, accent, hair = mat("fabric_white"), mat("fabric_green"), mat("hair_dark")
        torso = add_trapezoid_prism("CivilianChitonTorso", 1.04, 1.48, 0.60, 0.70, 0.35, 0.39, cloth)
        skirt = add_trapezoid_prism("CivilianChitonSkirt", 0.46, 1.07, 0.84, 0.62, 0.46, 0.36, cloth)
        sash = add_box("GreenSash", (0.13, -0.225, 1.12), (0.18, 0.05, 0.70), accent, rotation=(0.0, 0.24, 0.0), bevel=0.008)
        shoulder = add_trapezoid_prism("ShoulderDrape", 0.78, 1.44, 0.50, 0.34, 0.045, 0.045, accent, location_xy=(0.10, 0.235), bevel=0.006)
        for obj, bone_name in ((torso, "Spine"), (skirt, "Hips"), (sash, "Spine"), (shoulder, "Spine")):
            parent_to_bone(obj, armature, bone_name)
        add_belt(armature, 1.04, accent)
        add_character_limbs(armature, skin, cloth, False, 0.43)
        add_face_and_hair(armature, hair, skin, False, "cropped")


def add_action(armature: bpy.types.Object, action_name: str, cycle: list[tuple[int, float]], strength: float) -> None:
    action = bpy.data.actions.new(action_name)
    action.use_fake_user = True
    armature.animation_data_create()
    armature.animation_data.action = action
    scene = bpy.context.scene
    for pose_bone in armature.pose.bones:
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = (0.0, 0.0, 0.0)
        pose_bone.location = (0.0, 0.0, 0.0)
    for frame, phase in cycle:
        left = math.sin(phase) * strength
        right = -left
        armature.pose.bones["UpperArm.L"].rotation_euler.x = left
        armature.pose.bones["UpperArm.R"].rotation_euler.x = right
        armature.pose.bones["UpperLeg.L"].rotation_euler.x = right * 0.82
        armature.pose.bones["UpperLeg.R"].rotation_euler.x = left * 0.82
        armature.pose.bones["Spine"].rotation_euler.y = math.sin(phase * 2.0) * strength * 0.045
        armature.pose.bones["Head"].rotation_euler.y = -math.sin(phase * 2.0) * strength * 0.025
        if action_name == "Idle":
            armature.pose.bones["Spine"].rotation_euler.x = math.sin(phase) * 0.018
        for bone_name in ("UpperArm.L", "UpperArm.R", "UpperLeg.L", "UpperLeg.R", "Spine", "Head"):
            armature.pose.bones[bone_name].keyframe_insert("rotation_euler", frame=frame, group=bone_name)
        scene.frame_set(frame)
    action.frame_start = float(cycle[0][0])
    action.frame_end = float(cycle[-1][0])
    armature.animation_data.action = None


def create_character(filename: str, role: str) -> None:
    begin_asset(filename)
    armature = create_humanoid_armature(filename)
    build_character_mesh(role, armature)
    add_action(armature, "Idle", [(1, 0.0), (20, math.pi * 0.5), (40, math.pi * 2.0)], 0.05)
    if role == "player":
        add_action(armature, "Walk", [(1, 0.0), (8, math.pi * 0.5), (15, math.pi), (22, math.pi * 1.5), (29, math.pi * 2.0)], 0.52)
        add_action(armature, "Run", [(1, 0.0), (5, math.pi * 0.5), (9, math.pi), (13, math.pi * 1.5), (17, math.pi * 2.0)], 0.78)
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 40
    bpy.context.scene.frame_set(1)
    export_asset("characters", filename, animations=True)


def generate_all() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    creators = [
        create_temple,
        create_house_a,
        create_house_b,
        create_workshop,
        create_market_stall,
        create_road_straight,
        create_road_corner,
        create_stone_plaza,
        create_dirt_path_straight,
        create_dirt_path_curve,
        create_stone_stairs,
        create_stone_platform,
        create_wall_straight,
        create_wall_corner,
        create_wall_end,
        create_low_wall,
        lambda: create_amphora("Amphora_A", "A"),
        lambda: create_amphora("Amphora_B", "B"),
        lambda: create_amphora("Amphora_C", "C"),
        create_clay_jar,
        create_basket,
        create_wood_table,
        create_wood_bench,
        create_wood_crate,
        create_stone_bench,
        lambda: create_character("PlayerMessenger", "player"),
        lambda: create_character("Teacher", "teacher"),
        lambda: create_character("TempleRecipient", "recipient"),
    ]
    for creator in creators:
        creator()
    print(f"COMPLETE: generated {len(creators)} assets in {OUTPUT_ROOT}")


if __name__ == "__main__":
    generate_all()
