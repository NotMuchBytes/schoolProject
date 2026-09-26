class_name VillageEnvironment
extends Node3D

const COMMON_TREE_SCENES: Array[PackedScene] = [
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/CommonTree_2.gltf"),
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/CommonTree_3.gltf"),
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/CommonTree_5.gltf")
]
const ROCK_SCENES: Array[PackedScene] = [
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Rock_Medium_1.gltf"),
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Rock_Medium_2.gltf"),
	preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Rock_Medium_3.gltf")
]
const BUSH_SCENE: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Bush_Common.gltf")
const FLOWER_BUSH_SCENE: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Bush_Common_Flowers.gltf")
const MEDITERRANEAN_PLANT_SCENE: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Plant_1_Big.gltf")
const TEMPLE_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekTemple.glb")
const HOUSE_A_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekHouse_A.glb")
const HOUSE_B_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekHouse_B.glb")
const WORKSHOP_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekWorkshop.glb")
const MARKET_STALL_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/MarketStall.glb")
const STONE_ROAD_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneRoad_Straight.glb")
const STONE_ROAD_CORNER_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneRoad_Corner.glb")
const STONE_PLAZA_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StonePlaza.glb")
const DIRT_PATH_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/DirtPath_Straight.glb")
const DIRT_PATH_CURVE_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/DirtPath_Curve.glb")
const LOW_WALL_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/LowStoneWall.glb")
const STONE_WALL_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneWall_Straight.glb")
const STONE_WALL_CORNER_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneWall_Corner.glb")
const STONE_PLATFORM_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/environment/StonePlatform.glb")
const AMPHORA_A_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/Amphora_A.glb")
const AMPHORA_B_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/Amphora_B.glb")
const AMPHORA_C_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/Amphora_C.glb")
const CLAY_JAR_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/ClayJar.glb")
const BASKET_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/Basket.glb")
const WOOD_BENCH_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodBench.glb")
const WOOD_CRATE_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodCrate.glb")
const WOOD_TABLE_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodTable.glb")
const STONE_BENCH_SCENE: PackedScene = preload("res://assets/generated/ancient_greek/props/StoneBench.glb")

const SURFACE_SANDSTONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/sandstone_surface.png")
const SURFACE_LIMESTONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/limestone_surface.png")
const SURFACE_PLASTER: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/plaster_surface.png")
const SURFACE_TERRACOTTA: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/terracotta_surface.png")
const SURFACE_EARTH: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/earth_surface.png")
const SURFACE_ROAD_STONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/road_stone_surface.png")
const SURFACE_WOOD: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/wood_surface.png")
const SURFACE_CLAY: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/clay_surface.png")
const SURFACE_PLASTER_WARM: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/plaster_warm_surface.png")
const OPEN_WORLD_PLASTER: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/aged_plaster_v2.png")
const OPEN_WORLD_EARTH: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/packed_earth_v2.png")
const OPEN_WORLD_WOOD: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_olive_wood_v2.png")
const OPEN_WORLD_ROOF: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_roof_tiles_v2.png")
const OPEN_WORLD_LIMESTONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/worn_limestone_v2.png")

var sandstone: StandardMaterial3D
var pale_stone: StandardMaterial3D
var white_plaster: StandardMaterial3D
var terracotta: StandardMaterial3D
var path_stone: StandardMaterial3D
var earth: StandardMaterial3D
var cliff_rock: StandardMaterial3D
var sea_blue: StandardMaterial3D
var olive_green: StandardMaterial3D
var olive_dark: StandardMaterial3D
var wood: StandardMaterial3D
var door_blue: StandardMaterial3D
var pottery: StandardMaterial3D
var warm_plaster: StandardMaterial3D
var distant_stone: StandardMaterial3D
var beach_sand: StandardMaterial3D
var worn_limestone: StandardMaterial3D
var aged_plaster: StandardMaterial3D
var weathered_roof: StandardMaterial3D
var olive_wood: StandardMaterial3D
var packed_earth: StandardMaterial3D
var dark_drain_stone: StandardMaterial3D

var _box_mesh_cache: Dictionary = {}
var _cylinder_mesh_cache: Dictionary = {}
var _sphere_mesh_cache: Dictionary = {}
var _merged_scene_mesh_cache: Dictionary = {}


func _ready() -> void:
	_create_materials()
	_create_landscape()
	_create_paths_and_square()
	_create_houses()
	_create_expanded_districts()
	_create_temple()
	_create_architectural_details()
	_create_quality_detail_pass()
	_create_visible_boundaries()
	_create_background_world()
	_create_vegetation_and_props()


func _create_materials() -> void:
	sandstone = _make_material(Color.WHITE, 0.93, SURFACE_SANDSTONE, Vector3.ONE * 0.55)
	pale_stone = _make_material(Color.WHITE, 0.88, SURFACE_LIMESTONE, Vector3.ONE * 0.7)
	white_plaster = _make_material(Color.WHITE, 0.9, SURFACE_PLASTER, Vector3.ONE * 0.5)
	terracotta = _make_material(Color.WHITE, 0.86, SURFACE_TERRACOTTA, Vector3.ONE * 0.65)
	path_stone = _make_material(Color.WHITE, 0.94, SURFACE_ROAD_STONE, Vector3.ONE * 0.8)
	earth = _make_material(Color.WHITE, 0.97, SURFACE_EARTH, Vector3.ONE * 0.42)
	cliff_rock = _make_material(Color(0.72, 0.68, 0.62), 1.0, SURFACE_SANDSTONE, Vector3.ONE * 0.28)
	sea_blue = _make_material(Color(0.035, 0.31, 0.58, 0.88), 0.22)
	sea_blue.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sea_blue.metallic = 0.12
	olive_green = _make_material(Color(0.25, 0.38, 0.16), 0.96)
	olive_dark = _make_material(Color(0.16, 0.27, 0.1), 0.97)
	wood = _make_material(Color.WHITE, 0.98, SURFACE_WOOD, Vector3.ONE * 0.85)
	door_blue = _make_material(Color(0.08, 0.29, 0.42), 0.86)
	pottery = _make_material(Color.WHITE, 0.9, SURFACE_CLAY, Vector3.ONE * 0.85)
	warm_plaster = _make_material(Color(0.96, 0.88, 0.73), 0.94, SURFACE_PLASTER_WARM, Vector3.ONE * 0.48)
	distant_stone = _make_material(Color(0.56, 0.51, 0.44), 1.0, SURFACE_SANDSTONE, Vector3.ONE * 0.26)
	beach_sand = _make_material(Color(0.92, 0.76, 0.52), 0.98, SURFACE_EARTH, Vector3.ONE * 0.32)
	# The open-world texture set is reserved for the close-range hero dressing so
	# facades and paths gain readable material age without touching imported art.
	worn_limestone = _make_material(Color(0.94, 0.91, 0.83), 0.79, OPEN_WORLD_LIMESTONE, Vector3.ONE * 0.72)
	aged_plaster = _make_material(Color(0.96, 0.86, 0.69), 0.91, OPEN_WORLD_PLASTER, Vector3.ONE * 0.56)
	weathered_roof = _make_material(Color(0.79, 0.36, 0.20), 0.84, OPEN_WORLD_ROOF, Vector3.ONE * 0.62)
	olive_wood = _make_material(Color(0.31, 0.20, 0.10), 0.82, OPEN_WORLD_WOOD, Vector3.ONE * 0.72)
	packed_earth = _make_material(Color(0.53, 0.39, 0.23), 0.96, OPEN_WORLD_EARTH, Vector3.ONE * 0.42)
	dark_drain_stone = _make_material(Color(0.24, 0.25, 0.24), 0.92, OPEN_WORLD_LIMESTONE, Vector3.ONE * 0.38)


func _create_landscape() -> void:
	# One uninterrupted ground volume now supports the central story route and both
	# side quarters. Keeping a single top surface removes seams between districts.
	_make_box("DistantMainland", Vector3(0, -1.0, -45), Vector3(190, 1.45, 150), earth, false)
	_make_box("WesternTerraceMass", Vector3(-68, 1.0, -18), Vector3(52, 4.0, 100), distant_stone, false)
	_make_box("EasternTerraceMass", Vector3(68, 1.0, -18), Vector3(52, 4.0, 100), distant_stone, false)
	_make_box("NorthernHillMass", Vector3(0, 3.0, -78), Vector3(170, 7.0, 50), distant_stone, false)
	# Separate terrain slabs meet exactly at z=16 instead of occupying the same plane.
	_make_box("VillageGround", Vector3(0, -0.3, -11.5), Vector3(82, 0.6, 55), earth)
	_make_box("Beach", Vector3(0, -0.15, 19), Vector3(82, 0.3, 6), beach_sand)
	_make_box("TemplePlateau", Vector3(0, 1.6, -30), Vector3(30, 3.2, 16), sandstone, false)
	# Collision-only plateau pieces preserve the stair opening without duplicate visible faces.
	_make_collision_box("TemplePlateauFloor", Vector3(0, 3.08, -30.65), Vector3(30, 0.24, 14.7))
	_make_collision_box("PlateauFrontWest", Vector3(-8.85, 1.6, -22.5), Vector3(12.3, 3.2, 1.0))
	_make_collision_box("PlateauFrontEast", Vector3(8.85, 1.6, -22.5), Vector3(12.3, 3.2, 1.0))
	_make_collision_box("PlateauSideWest", Vector3(-14.6, 1.6, -30), Vector3(0.8, 3.2, 15))
	_make_collision_box("PlateauSideEast", Vector3(14.6, 1.6, -30), Vector3(0.8, 3.2, 15))
	_make_collision_box("PlateauRear", Vector3(0, 1.6, -37.5), Vector3(30, 3.2, 1.0))
	_make_collision_box("GroundBeachSeam", Vector3(0, -0.11, 16), Vector3(82, 0.22, 0.8))
	_make_collision_box("StairBottomLanding", Vector3(0, -0.04, -16.05), Vector3(5.6, 0.12, 0.8))
	_make_water()

	for i in range(10):
		var step_height := float(i + 1) * 0.32
		var step_z := -16.7 - float(i) * 0.66
		_make_box(
			"TempleStair%02d" % i,
			Vector3(0, step_height * 0.5, step_z),
			Vector3(5.4, step_height, 0.82),
			pale_stone,
			false
		)
	_make_stair_ramp()


func _create_paths_and_square() -> void:
	_make_external_prop("VillageSquare", Vector3(0, 0.004, 3.2), STONE_PLAZA_SCENE, Vector3(2.0, 0.30, 2.0), 0.0, false)
	_make_external_prop("UpperCourtyard", Vector3(0, 0.004, -12.4), STONE_PLAZA_SCENE, Vector3(1.42, 0.30, 0.72), 0.0, false)

	for i in range(3):
		_make_external_prop(
			"HarborRoad%02d" % i,
			Vector3(0, 0.005, 7.2 + float(i) * 4.0),
			STONE_ROAD_SCENE,
			Vector3(0.82, 0.30, 1.02),
			0.0,
			false
		)
	for i in range(4):
		_make_external_prop(
			"TempleRoad%02d" % i,
			Vector3(0, 0.005, -1.0 - float(i) * 4.0),
			STONE_ROAD_SCENE,
			Vector3(0.82, 0.30, 1.02),
			0.0,
			false
		)
	# Close the visual gap between the final road tile and the first stair landing.
	_make_external_prop(
		"TempleRoadConnector",
		Vector3(0, 0.006, -15.45),
		STONE_ROAD_SCENE,
		Vector3(0.82, 0.30, 0.24),
		0.0,
		false
	)
	for side in [-1.0, 1.0]:
		for i in range(2):
			_make_external_prop(
				"SideRoad_%d_%d" % [int(side), i],
				Vector3(side * (4.1 + float(i) * 4.0), 0.005, 3.2),
				STONE_ROAD_SCENE,
				Vector3(0.52, 0.30, 1.02),
				PI * 0.5,
				false
			)
		_make_external_prop(
			"UpperDirtPath_%d" % int(side),
			Vector3(side * 6.5, 0.004, -9.0),
			DIRT_PATH_SCENE,
			Vector3(0.45, 0.32, 2.5),
			PI * 0.5,
			false
		)

	# Low masonry edges make every path constraint readable in the world.
	_make_wall_segment("SquareWallWestSouth", Vector3(-6.1, 0, 0.9), 3.1, PI * 0.5, Vector3(0.45, 0.9, 3.1))
	_make_wall_segment("SquareWallWestNorth", Vector3(-6.1, 0, 5.2), 1.2, PI * 0.5, Vector3(0.45, 0.9, 1.2))
	# Short east returns leave the pottery apprentice's loop physically open while
	# retaining a readable edge around the square.
	_make_wall_segment("SquareWallEastSouth", Vector3(6.1, 0, -0.2), 0.8, PI * 0.5, Vector3(0.45, 0.9, 0.8))
	_make_wall_segment("SquareWallEastNorth", Vector3(6.1, 0, 7.3), 0.8, PI * 0.5, Vector3(0.45, 0.9, 0.8))
	_make_wall_segment("UpperWallWestNorth", Vector3(-3.2, 0, -13.1), 4.8, PI * 0.5, Vector3(0.4, 0.76, 4.8))
	_make_wall_segment("UpperWallWestSouth", Vector3(-3.2, 0, -7.6), 2.2, PI * 0.5, Vector3(0.4, 0.76, 2.2))
	_make_wall_segment("UpperWallEastNorth", Vector3(3.2, 0, -13.1), 4.8, PI * 0.5, Vector3(0.4, 0.76, 4.8))
	_make_wall_segment("UpperWallEastSouth", Vector3(3.2, 0, -7.6), 2.2, PI * 0.5, Vector3(0.4, 0.76, 2.2))

func _create_houses() -> void:
	# Every facade and courtyard faces the central route instead of arbitrary north/south axes.
	_make_generated_building("HarborHouseWest", Vector3(-11, 0, 11), Vector3(6.4, 3.2, 5.2), HOUSE_A_SCENE, 0.93, PI * 0.5)
	_make_generated_building("HarborHouseEast", Vector3(11, 0, 10), Vector3(6.0, 2.8, 5.0), HOUSE_B_SCENE, 0.82, -PI * 0.5)
	_make_generated_workshop("SquareWorkshop", Vector3(-12, 0, 0.5), 1.0, PI * 0.5)
	_make_generated_building("SquareHouseEast", Vector3(13, 0, -1), Vector3(6.5, 3.2, 5.5), HOUSE_B_SCENE, 0.86, -PI * 0.5)
	_make_generated_building("UpperHouseWest", Vector3(-11, 0, -11), Vector3(7.0, 3.0, 5.0), HOUSE_A_SCENE, 0.98, PI * 0.5)
	_make_generated_building("UpperHouseEast", Vector3(11, 0, -12), Vector3(6.5, 3.8, 5.0), HOUSE_B_SCENE, 0.90, -PI * 0.5)

	_make_external_prop("AgoraMarketStall", Vector3(-4.55, 0, 5.0), MARKET_STALL_SCENE, Vector3.ONE, 0.0, true)
	_make_collision_box("AgoraMarketTableCollision", Vector3(-4.55, 0.52, 4.95), Vector3(3.2, 1.04, 1.05))


func _create_expanded_districts() -> void:
	# The old side gates were only a painted promise. These quarters are now part of
	# the same walkable ground as the agora, with a clear cross street at z=3.2.
	for side in [-1.0, 1.0]:
		var district_name := "West" if side < 0.0 else "East"
		var inward_yaw: float = -PI * 0.5 * float(side)
		var outward_yaw: float = PI * 0.5 * float(side)

		for index in range(6):
			_make_external_prop(
				"%sCrossStreet%02d" % [district_name, index],
				Vector3(side * (12.1 + float(index) * 4.0), 0.006, 3.2),
				STONE_ROAD_SCENE,
				Vector3(0.68, 0.30, 1.02),
				PI * 0.5,
				false
			)
		_make_external_prop(
			"%sStreetCorner" % district_name,
			Vector3(side * 29.0, 0.008, 3.2),
			STONE_ROAD_CORNER_SCENE,
			Vector3(0.82, 0.30, 0.82),
			0.0 if side < 0.0 else PI * 0.5,
			false
		)
		_make_external_prop(
			"%sDistrictPlaza" % district_name,
			Vector3(side * 29.0, 0.004, 3.2),
			STONE_PLAZA_SCENE,
			Vector3(1.25, 0.30, 1.12),
			0.0,
			false
		)
		for index in range(11):
			_make_external_prop(
				"%sLongStreet%02d" % [district_name, index],
				Vector3(side * 29.0, 0.006, 15.0 - float(index) * 4.0),
				STONE_ROAD_SCENE,
				Vector3(0.72, 0.30, 1.02),
				0.0,
				false
			)
		_make_external_prop(
			"%sSacredLane" % district_name,
			Vector3(side * 21.0, 0.005, -26.0),
			DIRT_PATH_SCENE,
			Vector3(0.48, 0.30, 2.1),
			PI * 0.5,
			false
		)
		_make_external_prop(
			"%sSacredLaneCurve" % district_name,
			Vector3(side * 27.0, 0.006, -26.0),
			DIRT_PATH_CURVE_SCENE,
			Vector3(0.55, 0.30, 0.55),
			-PI * 0.5 if side < 0.0 else 0.0,
			false
		)

		# Buildings deliberately alternate height, footprint and facade direction so
		# the expanded area reads as an evolved settlement rather than copied rows.
		_make_generated_building(
			"%sHarborOuterHouse" % district_name,
			Vector3(side * 35.2, 0, 13.2),
			Vector3(6.2, 3.4, 5.2),
			HOUSE_A_SCENE if side < 0.0 else HOUSE_B_SCENE,
			0.90,
			inward_yaw
		)
		_make_generated_building(
			"%sHarborInnerHouse" % district_name,
			Vector3(side * 22.4, 0, 13.0),
			Vector3(5.6, 3.0, 4.8),
			HOUSE_B_SCENE if side < 0.0 else HOUSE_A_SCENE,
			0.80,
			outward_yaw
		)
		_make_generated_workshop(
			"%sCraftWorkshop" % district_name,
			Vector3(side * 35.0, 0, 3.0),
			0.88,
			inward_yaw
		)
		_make_generated_building(
			"%sMidOuterHouse" % district_name,
			Vector3(side * 35.0, 0, -7.4),
			Vector3(6.0, 3.6, 5.2),
			HOUSE_B_SCENE if side < 0.0 else HOUSE_A_SCENE,
			0.87,
			inward_yaw
		)
		_make_generated_building(
			"%sMidInnerHouse" % district_name,
			Vector3(side * 22.4, 0, -8.2),
			Vector3(5.8, 3.2, 5.0),
			HOUSE_A_SCENE if side < 0.0 else HOUSE_B_SCENE,
			0.84,
			outward_yaw
		)
		_make_generated_building(
			"%sNorthOuterHouse" % district_name,
			Vector3(side * 35.0, 0, -18.2),
			Vector3(6.4, 3.9, 5.4),
			HOUSE_A_SCENE,
			0.94,
			inward_yaw
		)
		_make_generated_building(
			"%sNorthInnerHouse" % district_name,
			Vector3(side * 22.6, 0, -19.0),
			Vector3(5.8, 3.45, 5.0),
			HOUSE_B_SCENE,
			0.84,
			outward_yaw
		)

		_make_external_prop(
			"%sGardenPlatform" % district_name,
			Vector3(side * 28.8, 0.01, -27.5),
			STONE_PLATFORM_SCENE,
			Vector3(0.92, 0.55, 0.92),
			0.0,
			false
		)
		_make_district_well("%sGardenWell" % district_name, Vector3(side * 28.8, 0, -27.5))
		_make_market_pergola(
			"%sMarketPergola" % district_name,
			Vector3(side * 31.9, 0, 7.2),
			inward_yaw
		)

		# Low garden edges guide players without turning the new districts into a maze.
		_make_wall_segment(
			"%sGardenWallNorth" % district_name,
			Vector3(side * 29.0, 0, -31.3),
			5.6,
			0.0,
			Vector3(5.6, 0.72, 0.38)
		)
		_make_wall_segment(
			"%sGardenWallOuter" % district_name,
			Vector3(side * 37.5, 0, -27.6),
			7.4,
			PI * 0.5,
			Vector3(0.38, 0.72, 7.4)
		)


func _create_temple() -> void:
	var temple_center := Vector3(0, 3.2, -30.2)
	_make_external_prop("ClassicalGreekTemple", temple_center, TEMPLE_SCENE, Vector3.ONE, 0.0, true)
	_make_collision_box("TempleStepLower", temple_center + Vector3(0, 0.11, 0), Vector3(14.0, 0.22, 15.0))
	_make_collision_box("TempleStepMiddle", temple_center + Vector3(0, 0.31, 0), Vector3(13.2, 0.20, 14.2))
	_make_collision_box("TempleStepUpper", temple_center + Vector3(0, 0.51, 0), Vector3(12.4, 0.18, 13.4))
	_make_collision_box("TempleCella", temple_center + Vector3(0, 2.55, -0.4), Vector3(6.2, 3.75, 7.4))

	var column_positions: Array[Vector2] = []
	for x in [-5.0, -2.5, 0.0, 2.5, 5.0]:
		column_positions.append(Vector2(x, -5.8))
		column_positions.append(Vector2(x, 5.8))
	for z in [-3.85, -1.92, 0.0, 1.92, 3.85]:
		column_positions.append(Vector2(-5.0, z))
		column_positions.append(Vector2(5.0, z))
	for i in range(column_positions.size()):
		var point := column_positions[i]
		_make_collision_cylinder(
			"TempleColumnCollision%02d" % i,
			temple_center + Vector3(point.x, 2.60, -point.y),
			0.40,
			3.75
		)


func _create_architectural_details() -> void:
	# Two staggered courses turn the bare plateau slab into a readable ashlar retaining wall.
	_make_box("TempleRetainingBackingWest", Vector3(-8.85, 1.58, -22.08), Vector3(12.30, 3.12, 0.18), path_stone, false)
	_make_box("TempleRetainingBackingEast", Vector3(8.85, 1.58, -22.08), Vector3(12.30, 3.12, 0.18), path_stone, false)
	var retaining_x_positions := [-12.45, -8.55, -4.65, 4.65, 8.55, 12.45]
	for course in range(2):
		for index in range(retaining_x_positions.size()):
			var x: float = retaining_x_positions[index]
			_make_external_prop(
				"TempleRetaining_%d_%d" % [course, index],
				Vector3(x + (0.12 if course == 1 else 0.0), float(course) * 1.58, -22.16),
				STONE_WALL_SCENE,
				Vector3(0.98, 0.94, 0.72),
				0.0,
				true
			)


func _create_quality_detail_pass() -> void:
	# This is deliberately visual-only: the named buildings, story corridors,
	# navigation floor and all existing collision volumes remain authoritative.
	_create_street_finishings()
	_create_facade_finishings()
	_create_harbor_finishings()
	_create_edge_dressing()


func _create_street_finishings() -> void:
	# A low curb, inset drain and dusty shoulder make the route legible in close
	# third-person views without narrowing any patrol route.
	var route_sections := [8.3, 12.2, 15.9, -0.9, -4.8, -8.7, -12.6]
	for section_index in range(route_sections.size()):
		var street_z: float = route_sections[section_index]
		for side in [-1.0, 1.0]:
			var curb_x: float = float(side) * 2.88
			_make_box(
				"RouteCurb_%02d_%d" % [section_index, int(side)],
				Vector3(curb_x, 0.115, street_z),
				Vector3(0.24, 0.23, 3.42),
				worn_limestone,
				false
			)
			_make_box(
				"RouteDrain_%02d_%d" % [section_index, int(side)],
				Vector3(side * 2.59, 0.025, street_z),
				Vector3(0.16, 0.05, 3.25),
				dark_drain_stone,
				false
			)
			if section_index % 2 == 0:
				_make_box(
					"RouteShoulder_%02d_%d" % [section_index, int(side)],
					Vector3(side * 3.23, 0.012, street_z),
					Vector3(0.42, 0.025, 3.28),
					packed_earth,
					false
				)

	# The cross-street gets small, broken limestone returns instead of a repeated
	# concrete-looking edge.  The central square stays clear for its dialogue beats.
	for side in [-1.0, 1.0]:
		for index in range(3):
			var street_x: float = float(side) * (14.2 + float(index) * 7.0)
			for edge_z in [1.18, 5.22]:
				_make_box(
					"DistrictCurb_%d_%d_%.0f" % [int(side), index, edge_z],
					Vector3(street_x, 0.105, edge_z),
					Vector3(3.35, 0.21, 0.22),
					worn_limestone,
					false
				)


func _create_facade_finishings() -> void:
	# A constrained hero pass layers sills, shutters, canvas awnings and a tiled
	# roof lip onto the imported architecture.  The different dimensions/variants
	# keep the settlement from reading as a row of cloned boxes.
	var facades := [
		["HarborHouseWest", Vector3(-11, 0, 11), Vector3(6.4, 3.2, 5.2), PI * 0.5],
		["HarborHouseEast", Vector3(11, 0, 10), Vector3(6.0, 2.8, 5.0), -PI * 0.5],
		["SquareWorkshop", Vector3(-12, 0, 0.5), Vector3(6.0, 3.1, 5.4), PI * 0.5],
		["SquareHouseEast", Vector3(13, 0, -1), Vector3(6.5, 3.2, 5.5), -PI * 0.5],
		["UpperHouseWest", Vector3(-11, 0, -11), Vector3(7.0, 3.0, 5.0), PI * 0.5],
		["UpperHouseEast", Vector3(11, 0, -12), Vector3(6.5, 3.8, 5.0), -PI * 0.5]
	]
	for side in [-1.0, 1.0]:
		var district_name := "West" if side < 0.0 else "East"
		var inward_yaw: float = -PI * 0.5 * side
		var outward_yaw: float = PI * 0.5 * side
		facades.append(["%sHarborOuter" % district_name, Vector3(side * 35.2, 0, 13.2), Vector3(6.2, 3.4, 5.2), inward_yaw])
		facades.append(["%sHarborInner" % district_name, Vector3(side * 22.4, 0, 13.0), Vector3(5.6, 3.0, 4.8), outward_yaw])
		facades.append(["%sMidOuter" % district_name, Vector3(side * 35.0, 0, -7.4), Vector3(6.0, 3.6, 5.2), inward_yaw])
		facades.append(["%sMidInner" % district_name, Vector3(side * 22.4, 0, -8.2), Vector3(5.8, 3.2, 5.0), outward_yaw])
		facades.append(["%sNorthOuter" % district_name, Vector3(side * 35.0, 0, -18.2), Vector3(6.4, 3.9, 5.4), inward_yaw])
		facades.append(["%sNorthInner" % district_name, Vector3(side * 22.6, 0, -19.0), Vector3(5.8, 3.45, 5.0), outward_yaw])
	for facade_index in range(facades.size()):
		var entry: Array = facades[facade_index]
		_dress_facade(entry[0], entry[1], entry[2], entry[3], facade_index)


func _dress_facade(name: String, ground_position: Vector3, size: Vector3, yaw: float, variant: int) -> void:
	var front := Vector3(0, 0, size.z * 0.5 + 0.13).rotated(Vector3.UP, yaw)
	var sill_height := 1.52 + float(variant % 2) * 0.16
	var shutter_x := size.x * (0.23 if variant % 3 != 0 else 0.29)
	_make_box(name + "FacadeApron", ground_position + front + Vector3.UP * 0.35, Vector3(size.x * 0.88, 0.32, 0.12), aged_plaster, false, yaw)
	_make_box(name + "SillWest", ground_position + front + Vector3(-shutter_x, sill_height, 0).rotated(Vector3.UP, yaw), Vector3(0.98, 0.13, 0.24), worn_limestone, false, yaw)
	_make_box(name + "SillEast", ground_position + front + Vector3(shutter_x, sill_height, 0).rotated(Vector3.UP, yaw), Vector3(0.98, 0.13, 0.24), worn_limestone, false, yaw)
	_make_box(name + "ShutterWest", ground_position + front + Vector3(-shutter_x, sill_height + 0.43, 0.035).rotated(Vector3.UP, yaw), Vector3(0.16, 0.92, 0.09), olive_wood, false, yaw)
	_make_box(name + "ShutterEast", ground_position + front + Vector3(shutter_x, sill_height + 0.43, 0.035).rotated(Vector3.UP, yaw), Vector3(0.16, 0.92, 0.09), olive_wood, false, yaw)
	# Keep a shallow doorway canopy, but leave the imported pitched roof untouched.
	# The previous full-building "roof lip" intersected the roof planes and looked
	# like a floating black slab from the third-person camera.
	_make_box(name + "Awning", ground_position + front * 1.35 + Vector3.UP * (2.34 + float(variant % 3) * 0.09), Vector3(size.x * 0.62, 0.12, 0.74 + float(variant % 2) * 0.18), weathered_roof, false, yaw)


func _create_harbor_finishings() -> void:
	# Quay caps, bollards and a pair of canvas work shelters establish a working
	# harbor without creating new walkable land or changing the sea boundary.
	for index in range(5):
		var quay_x := -16.0 + float(index) * 8.0
		_make_box("HarborQuayCap%02d" % index, Vector3(quay_x, 0.16, 19.9), Vector3(5.1, 0.32, 0.72), worn_limestone, false)
		_make_cylinder("HarborBollard%02d" % index, Vector3(quay_x + 1.45, 0.43, 19.15), 0.18, 0.58, olive_wood, false)
	for side in [-1.0, 1.0]:
		var shelter_position := Vector3(side * 15.8, 0, 16.9)
		_make_box("HarborShelterPost_%d" % int(side), shelter_position + Vector3(0, 1.08, 0), Vector3(0.16, 2.16, 0.16), olive_wood, false)
		_make_box("HarborShelterCanopy_%d" % int(side), shelter_position + Vector3(0, 2.08, 0.2), Vector3(2.25, 0.11, 1.16), aged_plaster, false)


func _create_edge_dressing() -> void:
	# Layered outcrops physically explain the playable envelope and hide the hard
	# retaining-bank silhouettes from street-level cameras.
	for side in [-1.0, 1.0]:
		for index in range(4):
			var edge_z := -29.0 + float(index) * 14.0
			_make_rock(
				"BoundaryOutcrop_%d_%02d" % [int(side), index],
				Vector3(side * 42.4, 2.2 + float(index % 2) * 0.55, edge_z),
				Vector3(2.6 + float(index % 2) * 0.55, 3.2, 3.1),
				false
			)
	for index in range(5):
		_make_rock(
			"NorthRidgeOutcrop%02d" % index,
			Vector3(-32.0 + float(index) * 16.0, 4.4 + float(index % 2), -40.8),
			Vector3(4.2, 3.8 + float(index % 3) * 0.5, 3.2),
			false
		)


func _create_visible_boundaries() -> void:
	# The physical envelope follows the enlarged ground exactly. Every collider has
	# a visible masonry wall, closed gate, or rock bank directly in front of it.
	_make_collision_box("WestDistrictBoundary", Vector3(-41.15, 1.65, -8.5), Vector3(0.9, 3.8, 61.0))
	_make_collision_box("EastDistrictBoundary", Vector3(41.15, 1.65, -8.5), Vector3(0.9, 3.8, 61.0))
	_make_collision_box("NorthRidgeBoundary", Vector3(0, 3.5, -38.85), Vector3(82.0, 6.0, 1.1))
	_make_box("WestRetainingBank", Vector3(-43.2, 1.35, -8.5), Vector3(4.2, 3.8, 62.0), distant_stone, false)
	_make_box("EastRetainingBank", Vector3(43.2, 1.35, -8.5), Vector3(4.2, 3.8, 62.0), distant_stone, false)
	_make_box("NorthRetainingBank", Vector3(0, 3.0, -41.4), Vector3(86, 5.0, 5.0), distant_stone, false)

	for side in [-1.0, 1.0]:
		var segment_index := 0
		for wall_z in range(-36, 21, 4):
			# Leave a clean architectural recess for the closed outer gate.
			if wall_z in [0, 4]:
				continue
			_make_external_prop(
				"DistrictWall_%d_%02d" % [int(side), segment_index],
				Vector3(side * 40.65, 0, float(wall_z)),
				STONE_WALL_SCENE,
				Vector3(0.98, 1.18, 0.86),
				PI * 0.5,
				true
			)
			segment_index += 1
		_make_city_gate("DistrictGate_%d" % int(side), Vector3(side * 40.62, 0, 2.5), 0.0)
		_make_external_prop(
			"DistrictNorthCorner_%d" % int(side),
			Vector3(side * 40.62, 0, -38.55),
			STONE_WALL_CORNER_SCENE,
			Vector3(0.96, 1.18, 0.96),
			PI if side < 0.0 else PI * 0.5,
			true
		)
		_make_external_prop(
			"HarborWallCorner_%d" % int(side),
			Vector3(side * 40.62, 0, 21.55),
			STONE_WALL_CORNER_SCENE,
			Vector3(0.96, 0.82, 0.96),
			-PI * 0.5 if side < 0.0 else 0.0,
			true
		)

	for index in range(21):
		var north_wall_x := -40.0 + float(index) * 4.0
		_make_external_prop(
			"NorthDistrictWall%02d" % index,
			Vector3(north_wall_x, 0, -38.55),
			STONE_WALL_SCENE,
			Vector3(0.98, 1.18, 0.86),
			0.0,
			true
		)

	# A continuous masonry sea wall closes the beach without an invisible edge.
	_make_collision_box("HarborSeaBoundary", Vector3(0, 0.56, 21.75), Vector3(82.0, 1.12, 0.72))
	for index in range(21):
		var wall_x := -40.0 + float(index) * 4.0
		_make_external_prop(
			"HarborSeaWallVisual%02d" % index,
			Vector3(wall_x, 0.0, 21.75),
			STONE_WALL_SCENE,
			Vector3(0.98, 0.68, 0.82),
			0.0,
			true
		)

	for z in range(-34, 20, 7):
		_make_rock("WestRock%d" % z, Vector3(-43.0, 2.8, float(z)), Vector3(2.7, 3.0, 2.9), false)
		_make_rock("EastRock%d" % z, Vector3(43.0, 2.6, float(z)), Vector3(2.8, 2.8, 2.8), false)
	_make_rock("HarborHeadlandWest", Vector3(-45.0, 0.2, 25.0), Vector3(6.8, 4.8, 7.0), false)
	_make_rock("HarborHeadlandEast", Vector3(45.0, 0.2, 25.0), Vector3(6.8, 4.8, 7.0), false)


func _create_background_world() -> void:
	# Beyond the new outer wall, raised scenery continues the streets into low-cost
	# silhouettes. It sits on the terrace masses and cannot be reached by the player.
	for side in [-1.0, 1.0]:
		for index in range(8):
			_make_external_prop(
				"OuterStreet_%d_%02d" % [int(side), index],
				Vector3(side * (44.5 + float(index) * 4.0), 3.0, 2.5),
				STONE_ROAD_SCENE,
				Vector3(0.68, 0.28, 1.0),
				PI * 0.5,
				false
			)
		for index in range(6):
			var district_x: float = side * (49.0 if index < 3 else 58.0 + float(index % 2) * 6.5)
			_make_background_house(
				"OuterHouse_%d_%02d" % [int(side), index],
				Vector3(district_x, 3.0, 15.0 - float(index) * 8.2),
				Vector3(6.0 + float(index % 2), 3.2 + float(index % 3) * 0.55, 5.4),
				-PI * 0.5 * side,
				index
			)
		_make_external_prop(
			"OuterWorkshop_%d" % int(side),
			Vector3(side * 50.0, 3.0, -12.0),
			WORKSHOP_SCENE,
			Vector3.ONE * 0.82,
			-PI * 0.5 * side,
			false
		)

	var hill_house_x := [-27.0, -19.0, -10.5, 10.0, 19.0, 27.0]
	for index in range(hill_house_x.size()):
		_make_background_house(
			"HillQuarter%02d" % index,
			Vector3(float(hill_house_x[index]), 6.45 + float(index % 2) * 0.35, -52.0 - float(index % 2) * 5.5),
			Vector3(6.3, 3.7 + float(index % 3) * 0.45, 5.3),
			0.0,
			index + 8
		)
	_make_external_prop("DistantHillTemple", Vector3(-23.0, 7.0, -71.0), TEMPLE_SCENE, Vector3.ONE * 0.34, 0.12, false)

	# Continue the beach and coastal headlands laterally; the animated water plane
	# reaches the fog horizon and distant islands break up the sea silhouette.
	_make_box("OuterBeachWest", Vector3(-66, -0.18, 20), Vector3(50, 0.25, 9), beach_sand, false)
	_make_box("OuterBeachEast", Vector3(66, -0.18, 20), Vector3(50, 0.25, 9), beach_sand, false)
	var island_positions := [
		Vector3(-74, -1.8, 115), Vector3(-25, -2.0, 145),
		Vector3(39, -1.9, 128), Vector3(92, -2.2, 164)
	]
	for index in range(island_positions.size()):
		_make_external_prop(
			"DistantIsland%02d" % index,
			island_positions[index],
			ROCK_SCENES[index % ROCK_SCENES.size()],
			Vector3(12.0 + float(index % 2) * 5.0, 7.0 + float(index % 3), 10.0),
			float(index) * 0.65,
			false
		)

	# Irregular low-poly ridges hide the far terrain slabs and replace the old
	# single rectangular north wall with an atmospheric mountain silhouette.
	for index in range(8):
		_make_external_prop(
			"NorthernMountain%02d" % index,
			Vector3(-63.0 + float(index) * 18.0, 5.5 + float(index % 2), -88.0 - float(index % 3) * 5.0),
			ROCK_SCENES[index % ROCK_SCENES.size()],
			Vector3(9.5, 8.0 + float(index % 3) * 1.2, 8.8),
			float(index) * 0.57,
			false
		)


func _make_water() -> void:
	var water := MeshInstance3D.new()
	water.name = "MediterraneanSea"
	water.position = Vector3(0, -0.48, 165)
	var plane := PlaneMesh.new()
	plane.size = Vector2(420, 300)
	plane.subdivide_width = 72
	plane.subdivide_depth = 52
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
void vertex() {
	float wave_a = sin(VERTEX.x * 0.085 + TIME * 0.65) * 0.055;
	float wave_b = sin(VERTEX.z * 0.12 - TIME * 0.48) * 0.038;
	float wave_c = sin((VERTEX.x + VERTEX.z) * 0.19 + TIME * 0.92) * 0.018;
	VERTEX.y += wave_a + wave_b + wave_c;
}
void fragment() {
	float broad_ripple = sin(UV.x * 34.0 + UV.y * 19.0 + TIME * 0.35) * 0.5 + 0.5;
	float fine_ripple = sin(UV.x * 114.0 - UV.y * 83.0 - TIME * 1.7) * 0.5 + 0.5;
	float shore_foam = 1.0 - smoothstep(0.015, 0.085, UV.y);
	vec3 deep_water = vec3(0.018, 0.16, 0.28);
	vec3 sunlit_water = vec3(0.055, 0.39, 0.61);
	ALBEDO = mix(deep_water, sunlit_water, broad_ripple * 0.32 + fine_ripple * 0.08);
	ALBEDO = mix(ALBEDO, vec3(0.72, 0.84, 0.79), shore_foam * (0.17 + fine_ripple * 0.12));
	ROUGHNESS = mix(0.17, 0.31, fine_ripple);
	METALLIC = 0.18;
	ALPHA = 0.95;
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	plane.material = shader_material
	water.mesh = plane
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)


func _make_district_well(name: String, ground_position: Vector3) -> void:
	_make_cylinder(name + "Foot", ground_position + Vector3.UP * 0.11, 1.08, 0.22, path_stone, true)
	_make_cylinder(name + "Drum", ground_position + Vector3.UP * 0.53, 0.78, 0.70, pale_stone, true)
	_make_cylinder(name + "Lip", ground_position + Vector3.UP * 0.91, 0.94, 0.16, sandstone, false)
	_make_box(name + "PostWest", ground_position + Vector3(-0.82, 1.55, 0), Vector3(0.18, 1.55, 0.18), wood, true)
	_make_box(name + "PostEast", ground_position + Vector3(0.82, 1.55, 0), Vector3(0.18, 1.55, 0.18), wood, true)
	_make_box(name + "Crossbeam", ground_position + Vector3(0, 2.30, 0), Vector3(2.05, 0.18, 0.18), wood, false)
	var spindle := _make_cylinder(name + "Spindle", ground_position + Vector3(0, 1.55, 0), 0.075, 1.72, wood, false)
	spindle.rotation.z = PI * 0.5


func _make_market_pergola(name: String, ground_position: Vector3, yaw: float) -> void:
	var post_offsets := [
		Vector3(-1.35, 1.15, -0.88), Vector3(1.35, 1.15, -0.88),
		Vector3(-1.35, 1.15, 0.88), Vector3(1.35, 1.15, 0.88)
	]
	for index in range(post_offsets.size()):
		var offset: Vector3 = post_offsets[index].rotated(Vector3.UP, yaw)
		_make_box(
			name + "Post%02d" % index,
			ground_position + offset,
			Vector3(0.18, 2.30, 0.18),
			wood,
			true,
			yaw
		)
	_make_box(name + "HeaderA", ground_position + Vector3.UP * 2.28, Vector3(3.1, 0.20, 0.18), wood, false, yaw)
	_make_box(name + "HeaderB", ground_position + Vector3.UP * 2.28, Vector3(3.1, 0.20, 0.18), wood, false, yaw + PI * 0.5)
	for slat_index in range(5):
		var local_offset := Vector3(0, 2.42, -0.76 + float(slat_index) * 0.38)
		_make_box(
			name + "RoofSlat%02d" % slat_index,
			ground_position + local_offset.rotated(Vector3.UP, yaw),
			Vector3(3.0, 0.10, 0.16),
			wood,
			false,
			yaw
		)


func _make_city_gate(name: String, ground_position: Vector3, yaw: float) -> void:
	var side_offset := Vector3(0, 0, 2.0).rotated(Vector3.UP, yaw)
	_make_box(name + "PierA", ground_position + side_offset + Vector3.UP * 1.65, Vector3(1.25, 3.3, 1.25), pale_stone, false, yaw)
	_make_box(name + "PierB", ground_position - side_offset + Vector3.UP * 1.65, Vector3(1.25, 3.3, 1.25), pale_stone, false, yaw)
	_make_box(name + "Lintel", ground_position + Vector3.UP * 3.0, Vector3(1.25, 0.55, 5.25), pale_stone, false, yaw)
	_make_box(name + "TimberDoor", ground_position + Vector3.UP * 1.28, Vector3(0.28, 2.56, 2.9), wood, false, yaw)


func _make_background_house(
	name: String,
	ground_position: Vector3,
	size: Vector3,
	yaw: float,
	variant: int
) -> void:
	var wall_material := warm_plaster if variant % 3 != 1 else sandstone
	var body := _make_box(name + "Body", ground_position + Vector3.UP * size.y * 0.5, size, wall_material, false, yaw)
	var roof := _make_box(
		name + "Roof",
		ground_position + Vector3.UP * (size.y + 0.18),
		Vector3(size.x + 0.56, 0.36 + float(variant % 2) * 0.06, size.z + 0.52),
		weathered_roof,
		false,
		yaw
	)
	var door_offset := Vector3(0, 1.0, size.z * 0.505).rotated(Vector3.UP, yaw)
	var door := _make_box(name + "Door", ground_position + door_offset, Vector3(1.0, 2.0, 0.14), wood, false, yaw)
	var roof_ridge := _make_box(
		name + "RoofRidge",
		ground_position + Vector3.UP * (size.y + 0.43 + float(variant % 2) * 0.06),
		Vector3(0.20, 0.16, size.z + 0.66),
		weathered_roof,
		false,
		yaw
	)
	_set_external_shadow(body, false)
	_set_external_shadow(roof, false)
	_set_external_shadow(door, false)
	_set_external_shadow(roof_ridge, false)

func _create_vegetation_and_props() -> void:
	var tree_positions := [
		Vector3(-6.8, 0, 16.2), Vector3(6.4, 0, 15.6), Vector3(-7.7, 0, 6.6),
		Vector3(10.2, 0, 6.0), Vector3(-6.0, 0, -6.2), Vector3(6.2, 0, -7.2),
		Vector3(-10, 3.2, -25), Vector3(10, 3.2, -25)
	]
	for i in range(tree_positions.size()):
		_make_olive_tree("OliveTree%02d" % i, tree_positions[i])

	_make_external_prop("BushLowerWest", Vector3(-8.0, 0, 6.5), BUSH_SCENE, Vector3.ONE * 0.72, 0.35, false)
	_make_external_prop("BushLowerEast", Vector3(11.2, 0, 3.5), FLOWER_BUSH_SCENE, Vector3.ONE * 0.68, -0.55, false)
	_make_external_prop("BushUpperWest", Vector3(-5.6, 0, -13.3), BUSH_SCENE, Vector3.ONE * 0.65, 1.1, false)
	_make_external_prop("PlantHarbor", Vector3(-5.0, 0, 10.5), MEDITERRANEAN_PLANT_SCENE, Vector3.ONE * 0.5, -0.3, false)
	_make_external_prop("PlantResidential", Vector3(5.2, 0, -5.0), MEDITERRANEAN_PLANT_SCENE, Vector3.ONE * 0.46, 0.65, false)
	_make_external_prop("PlantStairWest", Vector3(-3.65, 0, -15.75), MEDITERRANEAN_PLANT_SCENE, Vector3.ONE * 0.42, 0.15, false)
	_make_external_prop("PlantStairEast", Vector3(3.65, 0, -15.75), MEDITERRANEAN_PLANT_SCENE, Vector3.ONE * 0.38, -0.55, false)
	_make_external_prop("FlowerUpperWest", Vector3(-7.0, 3.2, -24.3), FLOWER_BUSH_SCENE, Vector3.ONE * 0.40, 0.4, false)
	_make_external_prop("FlowerUpperEast", Vector3(7.0, 3.2, -24.3), FLOWER_BUSH_SCENE, Vector3.ONE * 0.40, -0.4, false)
	_make_external_prop("FlowerSquareWest", Vector3(-6.75, 0, 1.5), FLOWER_BUSH_SCENE, Vector3.ONE * 0.42, 0.2, false)
	_make_external_prop("FlowerSquareEast", Vector3(6.65, 0, 5.0), FLOWER_BUSH_SCENE, Vector3.ONE * 0.38, -0.7, false)
	_make_external_prop("AmphoraMarketA", Vector3(-5.70, 0, 4.05), AMPHORA_A_SCENE, Vector3.ONE * 0.78, 0.2, true)
	_make_external_prop("AmphoraMarketB", Vector3(-3.25, 0, 4.15), AMPHORA_B_SCENE, Vector3.ONE * 0.84, -0.3, true)
	_make_external_prop("AmphoraMarketStorage", Vector3(-5.65, 0, 5.85), AMPHORA_C_SCENE, Vector3.ONE * 0.72, 0.4, true)
	_make_external_prop("AmphoraSquare", Vector3(4.7, 0, 2.2), AMPHORA_A_SCENE, Vector3.ONE * 0.85, -0.2, true)
	_make_external_prop("AmphoraUpper", Vector3(4.25, 0, -11.8), AMPHORA_B_SCENE, Vector3.ONE * 0.80, 0.5, true)
	_make_external_prop("ClayJarWorkshop", Vector3(-9.6, 0, 1.7), CLAY_JAR_SCENE, Vector3.ONE * 0.75, 0.0, true)
	_make_external_prop("MarketBasket", Vector3(-4.10, 0, 6.15), BASKET_SCENE, Vector3.ONE * 0.80, 0.0, true)
	_make_external_prop("MarketBasketStack", Vector3(-5.10, 0, 3.35), BASKET_SCENE, Vector3.ONE * 0.68, 0.35, true)
	_make_external_prop("HarborCrateA", Vector3(7.30, 0, 12.6), WOOD_CRATE_SCENE, Vector3.ONE * 0.78, 0.08, true)
	_make_external_prop("HarborCrateB", Vector3(8.05, 0, 12.75), WOOD_CRATE_SCENE, Vector3.ONE * 0.62, -0.12, true)
	_make_external_prop("WorkshopTable", Vector3(-8.65, 0, 2.55), WOOD_TABLE_SCENE, Vector3.ONE * 0.82, PI * 0.5, true)
	_make_prop_with_box_collision("WestBench", Vector3(-7.8, 0, 0.7), WOOD_BENCH_SCENE, Vector3.ONE, PI * 0.5, Vector3(0.6, 0.7, 2.2))
	_make_prop_with_box_collision("EastStoneBench", Vector3(11.0, 0, 2.0), STONE_BENCH_SCENE, Vector3.ONE, PI * 0.5, Vector3(0.6, 0.7, 2.2))
	_make_prop_with_box_collision("WorkshopCrate", Vector3(-8.9, 0, -1.0), WOOD_CRATE_SCENE, Vector3.ONE * 0.85, 0.1, Vector3(1.0, 0.9, 1.0))

	# Purposeful micro-scenes make the residential, harbor and sacred districts
	# readable without adding new gameplay.
	_make_external_prop("ResidentialTable", Vector3(8.7, 0, -8.8), WOOD_TABLE_SCENE, Vector3.ONE * 0.72, PI * 0.5, true)
	_make_collision_box("ResidentialTableCollision", Vector3(8.7, 0.42, -8.8), Vector3(1.0, 0.84, 1.9))
	_make_external_prop("ResidentialBasket", Vector3(9.6, 0, -7.8), BASKET_SCENE, Vector3.ONE * 0.66, 0.2, true)
	_make_external_prop("ResidentialJar", Vector3(9.9, 0, -9.2), CLAY_JAR_SCENE, Vector3.ONE * 0.68, -0.25, true)
	_make_external_prop("TempleOfferingWest", Vector3(-4.25, 3.2, -24.3), AMPHORA_C_SCENE, Vector3.ONE * 0.68, 0.2, true)
	_make_external_prop("TempleOfferingEast", Vector3(4.6, 3.2, -24.1), AMPHORA_A_SCENE, Vector3.ONE * 0.72, -0.2, true)
	_make_external_prop("TempleBenchWest", Vector3(-8.2, 3.2, -26.0), STONE_BENCH_SCENE, Vector3.ONE * 0.88, PI * 0.5, true)
	_make_external_prop("TempleBenchEast", Vector3(8.2, 3.2, -26.0), STONE_BENCH_SCENE, Vector3.ONE * 0.88, PI * 0.5, true)
	_make_external_prop("HarborCargoTable", Vector3(-10.2, 0, 14.5), WOOD_TABLE_SCENE, Vector3.ONE * 0.74, PI * 0.5, true)
	_make_collision_box("HarborCargoTableCollision", Vector3(-10.2, 0.42, 14.5), Vector3(1.0, 0.84, 1.9))
	_make_external_prop("HarborCargoJar", Vector3(-11.2, 0, 14.0), CLAY_JAR_SCENE, Vector3.ONE * 0.76, 0.1, true)

	_create_expanded_district_props()


func _create_expanded_district_props() -> void:
	var district_tree_positions: Array[Vector3] = [
		Vector3(-18.0, 0, 17.3), Vector3(18.0, 0, 17.3),
		Vector3(-18.0, 0, -2.2), Vector3(18.0, 0, -2.2),
		Vector3(-17.8, 0, -29.0), Vector3(17.8, 0, -29.0),
		Vector3(-31.6, 0, 18.0), Vector3(31.6, 0, 18.0),
		Vector3(-31.2, 0, -13.0), Vector3(31.2, 0, -13.0),
		Vector3(-34.0, 0, -28.0), Vector3(34.0, 0, -28.0)
	]
	for index in range(district_tree_positions.size()):
		_make_olive_tree("DistrictOlive%02d" % index, district_tree_positions[index])

	var district_bush_positions: Array[Vector3] = [
		Vector3(-19.0, 0, 10.0), Vector3(19.0, 0, 10.0),
		Vector3(-25.5, 0, 17.5), Vector3(25.5, 0, 17.5),
		Vector3(-25.0, 0, -14.0), Vector3(25.0, 0, -14.0),
		Vector3(-32.8, 0, -23.4), Vector3(32.8, 0, -23.4),
		Vector3(-24.5, 0, -29.4), Vector3(24.5, 0, -29.4)
	]
	for index in range(district_bush_positions.size()):
		_make_external_prop(
			"DistrictBush%02d" % index,
			district_bush_positions[index],
			FLOWER_BUSH_SCENE if index % 3 == 0 else BUSH_SCENE,
			Vector3.ONE * (0.48 + float(index % 3) * 0.07),
			float(index) * 0.47,
			false
		)

	for side in [-1.0, 1.0]:
		var district_name := "West" if side < 0.0 else "East"
		var inward_yaw: float = -PI * 0.5 * float(side)
		_make_external_prop(
			"%sDistrictMarketStall" % district_name,
			Vector3(side * 25.3, 0, 6.8),
			MARKET_STALL_SCENE,
			Vector3.ONE * 0.88,
			inward_yaw,
			true
		)
		_make_collision_box(
			"%sDistrictMarketCounter" % district_name,
			Vector3(side * 25.3, 0.50, 6.8),
			Vector3(3.0, 1.0, 0.85),
			inward_yaw
		)
		_make_prop_with_box_collision(
			"%sDistrictBench" % district_name,
			Vector3(side * 25.0, 0, 0.0),
			STONE_BENCH_SCENE,
			Vector3.ONE * 0.90,
			0.0,
			Vector3(2.1, 0.66, 0.62)
		)
		_make_external_prop(
			"%sCourtyardTable" % district_name,
			Vector3(side * 25.2, 0, -13.0),
			WOOD_TABLE_SCENE,
			Vector3.ONE * 0.72,
			0.0,
			true
		)
		_make_collision_box(
			"%sCourtyardTableCollision" % district_name,
			Vector3(side * 25.2, 0.42, -13.0),
			Vector3(1.8, 0.84, 1.0)
		)

		_make_external_prop("%sHarborCrateA" % district_name, Vector3(side * 33.2, 0, 17.2), WOOD_CRATE_SCENE, Vector3.ONE * 0.72, 0.12 * side, true)
		_make_external_prop("%sHarborCrateB" % district_name, Vector3(side * 34.1, 0, 17.35), WOOD_CRATE_SCENE, Vector3.ONE * 0.56, -0.20 * side, true)
		_make_external_prop("%sMarketAmphoraA" % district_name, Vector3(side * 23.8, 0, 7.8), AMPHORA_A_SCENE, Vector3.ONE * 0.72, 0.2 * side, true)
		_make_external_prop("%sMarketAmphoraB" % district_name, Vector3(side * 24.2, 0, 5.6), AMPHORA_C_SCENE, Vector3.ONE * 0.66, -0.3 * side, true)
		_make_external_prop("%sCourtyardBasket" % district_name, Vector3(side * 24.2, 0, -12.0), BASKET_SCENE, Vector3.ONE * 0.68, 0.25 * side, true)
		_make_external_prop("%sGardenJar" % district_name, Vector3(side * 31.2, 0, -26.0), CLAY_JAR_SCENE, Vector3.ONE * 0.70, -0.2 * side, true)
		_make_external_prop("%sGardenPlant" % district_name, Vector3(side * 26.5, 0, -28.0), MEDITERRANEAN_PLANT_SCENE, Vector3.ONE * 0.48, 0.4 * side, false)

	# High-ground silhouettes remain non-playable and do not need individual trunks.
	var ridge_tree_positions: Array[Vector3] = [
		Vector3(-15.0, 6.5, -48.0), Vector3(15.5, 6.5, -50.0),
		Vector3(-34.0, 6.5, -52.0), Vector3(34.0, 6.5, -49.0)
	]
	for index in range(ridge_tree_positions.size()):
		_make_external_prop(
			"RidgeOlive%02d" % index,
			ridge_tree_positions[index],
			COMMON_TREE_SCENES[index % COMMON_TREE_SCENES.size()],
			Vector3.ONE * (0.27 + float(index % 3) * 0.025),
			float(index) * 0.71,
			false
		)


func _make_house(name: String, ground_position: Vector3, size: Vector3, wall_material: StandardMaterial3D) -> void:
	var center := ground_position + Vector3(0, size.y * 0.5, 0)
	_make_box(name, center, size, wall_material)
	_make_box(name + "Roof", center + Vector3(0, size.y * 0.5 + 0.18, 0), Vector3(size.x + 0.45, 0.36, size.z + 0.45), terracotta, false)
	_make_box(name + "Door", ground_position + Vector3(0, 1.05, size.z * 0.505), Vector3(1.05, 2.1, 0.12), door_blue, false)
	_make_box(name + "WindowLeft", ground_position + Vector3(-size.x * 0.28, 2.05, size.z * 0.51), Vector3(0.7, 0.7, 0.1), door_blue, false)
	_make_box(name + "WindowRight", ground_position + Vector3(size.x * 0.28, 2.05, size.z * 0.51), Vector3(0.7, 0.7, 0.1), door_blue, false)


func _make_olive_tree(name: String, ground_position: Vector3) -> void:
	var tree_index := posmod(name.hash(), COMMON_TREE_SCENES.size())
	var tree_scale := 0.39 + float(tree_index) * 0.025
	var tree_root := _make_external_prop(
		name,
		ground_position,
		COMMON_TREE_SCENES[tree_index],
		Vector3.ONE * tree_scale,
		deg_to_rad(float(posmod(name.hash(), 300))),
		true
	)
	var trunk_body := StaticBody3D.new()
	trunk_body.name = "TrunkCollision"
	trunk_body.position = Vector3(0, 0.85, 0)
	tree_root.add_child(trunk_body)
	var collision_shape := CollisionShape3D.new()
	var trunk_shape := CylinderShape3D.new()
	trunk_shape.radius = 0.24
	trunk_shape.height = 1.7
	collision_shape.shape = trunk_shape
	trunk_body.add_child(collision_shape)


func _make_amphora(name: String, ground_position: Vector3, scale_factor: float) -> void:
	_make_sphere(name + "Body", ground_position + Vector3(0, 0.46 * scale_factor, 0), Vector3(0.34, 0.46, 0.34) * scale_factor, pottery, false)
	_make_cylinder(name + "Neck", ground_position + Vector3(0, 0.82 * scale_factor, 0), 0.14 * scale_factor, 0.34 * scale_factor, pottery, false)
	_make_cylinder(name + "Rim", ground_position + Vector3(0, 1.01 * scale_factor, 0), 0.2 * scale_factor, 0.07 * scale_factor, pottery, false)


func _make_generated_building(
	name: String,
	ground_position: Vector3,
	collision_size: Vector3,
	scene: PackedScene,
	uniform_scale: float,
	yaw: float
) -> void:
	_make_external_prop(name + "Visual", ground_position, scene, Vector3.ONE * uniform_scale, yaw, true)
	_make_collision_box(
		name + "Collision",
		ground_position + Vector3(0, collision_size.y * 0.5, 0),
		collision_size,
		yaw
	)


func _make_generated_workshop(name: String, ground_position: Vector3, uniform_scale: float, yaw: float) -> void:
	_make_external_prop(name + "Visual", ground_position, WORKSHOP_SCENE, Vector3.ONE * uniform_scale, yaw, true)
	_make_collision_box(name + "BackCollision", ground_position + Vector3(0, 1.55, -2.65).rotated(Vector3.UP, yaw), Vector3(6.2, 3.1, 0.42), yaw)
	_make_collision_box(name + "LeftCollision", ground_position + Vector3(-3.0, 1.55, 0).rotated(Vector3.UP, yaw), Vector3(0.42, 3.1, 5.4), yaw)
	_make_collision_box(name + "RightCollision", ground_position + Vector3(3.0, 1.55, 0).rotated(Vector3.UP, yaw), Vector3(0.42, 3.1, 5.4), yaw)
	_make_collision_box(name + "CounterCollision", ground_position + Vector3(0, 0.52, 1.25).rotated(Vector3.UP, yaw), Vector3(4.3, 1.04, 0.75), yaw)


func _make_wall_segment(name: String, ground_position: Vector3, length: float, yaw: float, collision_size: Vector3) -> void:
	_make_external_prop(
		name + "Visual",
		ground_position + Vector3(0, -0.03, 0),
		LOW_WALL_SCENE,
		Vector3(length / 4.05, collision_size.y / 0.92, 0.75),
		yaw,
		true
	)
	_make_collision_box(name + "Collision", ground_position + Vector3(0, collision_size.y * 0.5, 0), collision_size)


func _make_prop_with_box_collision(
	name: String,
	ground_position: Vector3,
	scene: PackedScene,
	scale_value: Vector3,
	yaw: float,
	collision_size: Vector3
) -> void:
	_make_external_prop(name, ground_position, scene, scale_value, yaw, true)
	_make_collision_box(name + "Collision", ground_position + Vector3(0, collision_size.y * 0.5, 0), collision_size)


func _make_material(
	color: Color,
	roughness_value: float,
	texture: Texture2D = null,
	uv_scale: Vector3 = Vector3.ONE
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	if texture != null:
		material.albedo_texture = texture
		material.uv1_triplanar = true
		material.uv1_world_triplanar = true
		material.uv1_scale = uv_scale
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _make_box(name: String, position: Vector3, size: Vector3, material: StandardMaterial3D, collision: bool = true, yaw: float = 0.0) -> Node3D:
	var root: Node3D
	if collision:
		root = StaticBody3D.new()
	else:
		root = Node3D.new()
	root.name = name
	root.position = position
	root.rotation.y = yaw
	add_child(root)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _get_box_mesh(size, material)
	_configure_shadow(mesh_instance, material)
	root.add_child(mesh_instance)

	if collision:
		var collision_shape := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
		root.add_child(collision_shape)
	return root


func _make_cylinder(name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D, collision: bool = true) -> Node3D:
	var root: Node3D
	if collision:
		root = StaticBody3D.new()
	else:
		root = Node3D.new()
	root.name = name
	root.position = position
	add_child(root)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _get_cylinder_mesh(radius, height, material)
	_configure_shadow(mesh_instance, material)
	root.add_child(mesh_instance)

	if collision:
		var collision_shape := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		collision_shape.shape = shape
		root.add_child(collision_shape)
	return root


func _make_sphere(name: String, position: Vector3, scale_value: Vector3, material: StandardMaterial3D, collision: bool) -> Node3D:
	var root: Node3D
	if collision:
		root = StaticBody3D.new()
	else:
		root = Node3D.new()
	root.name = name
	root.position = position
	add_child(root)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _get_sphere_mesh(material)
	_configure_shadow(mesh_instance, material)
	mesh_instance.scale = scale_value
	root.add_child(mesh_instance)

	if collision:
		var collision_shape := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = maxf(scale_value.x, maxf(scale_value.y, scale_value.z))
		collision_shape.shape = shape
		root.add_child(collision_shape)
	return root


func _make_rock(name: String, position: Vector3, scale_value: Vector3, collision: bool) -> void:
	var rock_index := posmod(name.hash(), ROCK_SCENES.size())
	var model_scale := Vector3(
		scale_value.x * 0.65,
		scale_value.y * 0.75,
		scale_value.z * 0.65
	)
	var rock_root := _make_external_prop(
		name,
		position,
		ROCK_SCENES[rock_index],
		model_scale,
		deg_to_rad(float(posmod(name.hash(), 360))),
		true
	)
	if collision:
		var body := StaticBody3D.new()
		body.name = "RockCollision"
		rock_root.add_child(body)
		var collision_shape := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = maxf(scale_value.x, scale_value.z)
		collision_shape.position.y = scale_value.y * 0.45
		collision_shape.shape = shape
		body.add_child(collision_shape)


func _make_external_prop(
	name: String,
	position: Vector3,
	scene: PackedScene,
	scale_value: Vector3,
	yaw: float,
	casts_shadow: bool
) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.position = position
	root.rotation.y = yaw
	add_child(root)
	var model := MeshInstance3D.new()
	model.name = "Model"
	model.mesh = _get_merged_scene_mesh(scene)
	model.scale = scale_value
	root.add_child(model)
	model.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	return root


func _get_merged_scene_mesh(scene: PackedScene) -> ArrayMesh:
	var cache_key := scene.resource_path
	if _merged_scene_mesh_cache.has(cache_key):
		return _merged_scene_mesh_cache[cache_key] as ArrayMesh

	var scene_instance := scene.instantiate()
	var surface_groups: Dictionary = {}
	_collect_external_surfaces(scene_instance, Transform3D.IDENTITY, surface_groups)
	var merged_mesh := ArrayMesh.new()
	for group_variant in surface_groups.values():
		var group: Dictionary = group_variant
		var surface_tool := SurfaceTool.new()
		var entries: Array = group["entries"]
		for entry_variant in entries:
			var entry: Dictionary = entry_variant
			surface_tool.append_from(
				entry["mesh"] as Mesh,
				entry["surface_index"] as int,
				entry["transform"] as Transform3D
			)
		var new_surface_index := merged_mesh.get_surface_count()
		surface_tool.commit(merged_mesh)
		var surface_material := group["material"] as Material
		if surface_material != null:
			merged_mesh.surface_set_material(new_surface_index, surface_material)

	scene_instance.free()
	_merged_scene_mesh_cache[cache_key] = merged_mesh
	return merged_mesh


func _collect_external_surfaces(
	node: Node,
	parent_transform: Transform3D,
	surface_groups: Dictionary
) -> void:
	var accumulated_transform := parent_transform
	if node is Node3D:
		accumulated_transform = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var source_mesh := mesh_instance.mesh
		if source_mesh != null:
			for surface_index in range(source_mesh.get_surface_count()):
				var surface_material := mesh_instance.get_active_material(surface_index)
				var material_key := (
					str(surface_material.get_instance_id())
					if surface_material != null
					else "no_material"
				)
				if not surface_groups.has(material_key):
					surface_groups[material_key] = {
						"material": surface_material,
						"entries": []
					}
				var group: Dictionary = surface_groups[material_key]
				var entries: Array = group["entries"]
				entries.append({
					"mesh": source_mesh,
					"surface_index": surface_index,
					"transform": accumulated_transform
				})
	for child in node.get_children():
		_collect_external_surfaces(child, accumulated_transform, surface_groups)


func _set_external_shadow(node: Node, enabled: bool) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			if enabled
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
	for child in node.get_children():
		_set_external_shadow(child, enabled)


func _make_collision_box(name: String, position: Vector3, size: Vector3, yaw: float = 0.0) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.position = position
	body.rotation.y = yaw
	add_child(body)
	var collision_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	body.add_child(collision_shape)


func _make_collision_cylinder(name: String, position: Vector3, radius: float, height: float) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.position = position
	add_child(body)
	var collision_shape := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision_shape.shape = shape
	body.add_child(collision_shape)


func _get_box_mesh(size: Vector3, material: StandardMaterial3D) -> BoxMesh:
	var key := "%s:%s" % [material.get_instance_id(), size]
	if not _box_mesh_cache.has(key):
		var mesh := BoxMesh.new()
		mesh.size = size
		mesh.material = material
		_box_mesh_cache[key] = mesh
	return _box_mesh_cache[key] as BoxMesh


func _get_cylinder_mesh(radius: float, height: float, material: StandardMaterial3D) -> CylinderMesh:
	var key := "%s:%.3f:%.3f" % [material.get_instance_id(), radius, height]
	if not _cylinder_mesh_cache.has(key):
		var mesh := CylinderMesh.new()
		mesh.top_radius = radius * 0.88
		mesh.bottom_radius = radius
		mesh.height = height
		mesh.radial_segments = 14
		mesh.material = material
		_cylinder_mesh_cache[key] = mesh
	return _cylinder_mesh_cache[key] as CylinderMesh


func _get_sphere_mesh(material: StandardMaterial3D) -> SphereMesh:
	var key := str(material.get_instance_id())
	if not _sphere_mesh_cache.has(key):
		var mesh := SphereMesh.new()
		mesh.radius = 1.0
		mesh.height = 2.0
		mesh.radial_segments = 12
		mesh.rings = 7
		mesh.material = material
		_sphere_mesh_cache[key] = mesh
	return _sphere_mesh_cache[key] as SphereMesh


func _configure_shadow(mesh_instance: MeshInstance3D, material: StandardMaterial3D) -> void:
	if material in [path_stone, sea_blue, door_blue, pottery, olive_green, olive_dark]:
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _make_stair_ramp() -> void:
	# A hidden sloped collider lets CharacterBody3D walk smoothly over the visible steps.
	var body := StaticBody3D.new()
	body.name = "TempleStairRamp"
	body.position = Vector3(0, 1.52, -19.72)
	body.rotation.x = 0.43
	add_child(body)
	var collision_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(5.5, 0.28, 7.9)
	collision_shape.shape = shape
	body.add_child(collision_shape)
