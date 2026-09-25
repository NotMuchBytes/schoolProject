class_name HistoricalStageEnvironment
extends Node3D

enum StageType { ATHENS, SPARTA, MACEDON }

@export var stage_type: StageType = StageType.ATHENS

const TEMPLE: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekTemple.glb")
const HOUSE_A: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekHouse_A.glb")
const HOUSE_B: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekHouse_B.glb")
const WORKSHOP: PackedScene = preload("res://assets/generated/ancient_greek/architecture/GreekWorkshop.glb")
const MARKET_STALL: PackedScene = preload("res://assets/generated/ancient_greek/architecture/MarketStall.glb")
const PLAZA: PackedScene = preload("res://assets/generated/ancient_greek/environment/StonePlaza.glb")
const ROAD: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneRoad_Straight.glb")
const STONE_WALL: PackedScene = preload("res://assets/generated/ancient_greek/environment/StoneWall_Straight.glb")
const DIRT_PATH: PackedScene = preload("res://assets/generated/ancient_greek/environment/DirtPath_Straight.glb")
const BENCH: PackedScene = preload("res://assets/generated/ancient_greek/props/StoneBench.glb")
const WOOD_BENCH: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodBench.glb")
const CRATE: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodCrate.glb")
const TABLE: PackedScene = preload("res://assets/generated/ancient_greek/props/WoodTable.glb")
const AMPHORA_A: PackedScene = preload("res://assets/generated/ancient_greek/props/Amphora_A.glb")
const AMPHORA_B: PackedScene = preload("res://assets/generated/ancient_greek/props/Amphora_B.glb")
const TREE_A: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/CommonTree_2.gltf")
const TREE_B: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/CommonTree_5.gltf")
const ROCK_A: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Rock_Medium_1.gltf")
const ROCK_B: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Rock_Medium_3.gltf")
const BUSH: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Bush_Common.gltf")
const FLOWER_BUSH: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Bush_Common_Flowers.gltf")
const GRASS_WISPY: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Grass_Wispy_Short.gltf")
const PEBBLE_A: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/Pebble_Round_2.gltf")
const TWISTED_TREE: PackedScene = preload("res://assets/external/nature/Stylized Nature MegaKit[Standard]/glTF/TwistedTree_2.gltf")
const SURFACE_EARTH: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/earth_surface.png")
const SURFACE_SANDSTONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/sandstone_surface.png")
const SURFACE_ROAD: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/road_stone_surface.png")
const SURFACE_WOOD: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/wood_surface.png")
const SURFACE_PLASTER: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/plaster_warm_surface.png")
const SURFACE_TERRACOTTA: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/terracotta_surface.png")
const SURFACE_OPEN_EARTH: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/packed_earth_v2.png")
const SURFACE_OPEN_STONE: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/worn_limestone_v2.png")
const SURFACE_OPEN_WOOD: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_olive_wood_v2.png")
const SURFACE_OPEN_PLASTER: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/aged_plaster_v2.png")
const SURFACE_OPEN_ROOF: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_roof_tiles_v2.png")
const SURFACE_OPEN_CANVAS: Texture2D = preload("res://assets/generated/ancient_greek/environment/surfaces/open_world/aged_linen_canvas_v2.png")

const PLAYABLE_HALF_X := 29.0
const PLAYABLE_HALF_Z := 29.0
const WALL_SEGMENT_SPACING := 4.0

var _earth: StandardMaterial3D
var _sandstone: StandardMaterial3D
var _road_stone: StandardMaterial3D
var _dark_stone: StandardMaterial3D
var _wood: StandardMaterial3D
var _gate_wood: StandardMaterial3D
var _plaster: StandardMaterial3D
var _terracotta: StandardMaterial3D
var _distant_stone: StandardMaterial3D
var _cloth_red: StandardMaterial3D
var _cloth_blue: StandardMaterial3D
var _cloth_purple: StandardMaterial3D
var _bronze: StandardMaterial3D
var _dust: StandardMaterial3D
var _sand: StandardMaterial3D
var _yard_earth: StandardMaterial3D
var _dark_opening: StandardMaterial3D
var _fire: StandardMaterial3D
var _smoke: StandardMaterial3D

var _visual_box_cache: Dictionary = {}
var _visual_cylinder_cache: Dictionary = {}
# Imported GLTFs often contain one MeshInstance per authored submesh.  Cache one
# flattened mesh per source scene so every placed prop remains a single visible
# node while retaining the source materials and transforms.
var _merged_scene_mesh_cache: Dictionary = {}


func _ready() -> void:
	_create_materials()
	# A continuous 58 x 58 metre collision slab makes every stage almost twice the
	# former playable area. Broad terrain overlaps the slab on every side so the
	# physical edge is always concealed by the authored wall or palisade.
	# Athens and Sparta still fit safely inside their separate 70 metre scene cells.
	_make_visual_box("DistantTerrain", Vector3(0, -0.92, -8.0), Vector3(69, 1.25, 184), _earth)
	_make_visual_box("FarNorthTerrace", Vector3(0, 1.2, -72.0), Vector3(69, 4.0, 54.0), _distant_stone)
	_make_visual_box("FarWestTerrace", Vector3(-33.0, 0.4, -7.0), Vector3(4.0, 2.6, 158.0), _distant_stone)
	_make_visual_box("FarEastTerrace", Vector3(33.0, 0.4, -7.0), Vector3(4.0, 2.6, 158.0), _distant_stone)
	_make_box(
		"ReliableGround",
		Vector3(0, -0.3, 0),
		Vector3(PLAYABLE_HALF_X * 2.0, 0.6, PLAYABLE_HALF_Z * 2.0),
		_earth
	)
	_create_visible_boundaries()
	match stage_type:
		StageType.ATHENS:
			_build_athens()
		StageType.SPARTA:
			_build_sparta()
		StageType.MACEDON:
			_build_macedon()
	_create_background_world()
	_add_landscape_dressing()


func _create_materials() -> void:
	# The original kit used 64 px colour swatches. These shared, high-resolution
	# surfaces preserve the established palette while adding readable stone grain,
	# worn plaster and timber detail at the player's normal camera distance.
	_earth = _material(Color(0.88, 0.75, 0.54), 0.96, SURFACE_OPEN_EARTH, 0.23)
	_sandstone = _material(Color(1.0, 0.93, 0.78), 0.90, SURFACE_OPEN_STONE, 0.34)
	_road_stone = _material(Color(0.82, 0.79, 0.71), 0.93, SURFACE_OPEN_STONE, 0.47)
	_dark_stone = _material(Color(0.48, 0.43, 0.36), 0.98, SURFACE_OPEN_STONE, 0.39)
	_wood = _material(Color(0.62, 0.42, 0.25), 0.95, SURFACE_OPEN_WOOD, 0.45)
	# Gates are a landmark, not a shadowed facade: retain the same timber grain
	# but lift the mid-tone so Sparta's south exit remains readable in captures.
	# The source timber albedo is intentionally dark; a >1 tint keeps this broad,
	# north-facing gate readable without making every smaller wood prop too bright.
	_gate_wood = _material(Color(1.32, 1.02, 0.72), 0.86, SURFACE_OPEN_WOOD, 0.42)
	_plaster = _material(Color(0.96, 0.86, 0.68), 0.93, SURFACE_OPEN_PLASTER, 0.32)
	_terracotta = _material(Color(0.74, 0.27, 0.14), 0.91, SURFACE_OPEN_ROOF, 0.42)
	_distant_stone = _material(Color(0.55, 0.49, 0.40), 1.0, SURFACE_OPEN_STONE, 0.24)
	_dust = _material(Color(0.78, 0.61, 0.39), 0.99, SURFACE_OPEN_EARTH, 0.34)
	_sand = _material(Color(0.91, 0.78, 0.56), 0.98, SURFACE_OPEN_EARTH, 0.29)
	_yard_earth = _material(Color(0.66, 0.50, 0.33), 0.99, SURFACE_OPEN_EARTH, 0.39)
	# Saturated linen tint keeps faction banners and tents legible without making
	# the aged canvas look emissive or synthetic.
	_cloth_red = _material(Color(0.70, 0.24, 0.13), 0.90, SURFACE_OPEN_CANVAS, 0.46)
	_cloth_blue = _material(Color(0.18, 0.43, 0.68), 0.89, SURFACE_OPEN_CANVAS, 0.46)
	_cloth_purple = _material(Color(0.51, 0.21, 0.61), 0.90, SURFACE_OPEN_CANVAS, 0.46)
	_bronze = _material(Color(0.48, 0.29, 0.11), 0.62, SURFACE_OPEN_STONE, 1.15)
	_dark_opening = _solid_material(Color(0.035, 0.028, 0.025), 0.98)
	_fire = _solid_material(Color(1.0, 0.20, 0.025), 0.28)
	_fire.emission_enabled = true
	_fire.emission = Color(1.0, 0.075, 0.008)
	_fire.emission_energy_multiplier = 4.2
	_smoke = _solid_material(Color(0.16, 0.14, 0.13, 0.34), 1.0)
	_smoke.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_smoke.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_smoke.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED


func _build_athens() -> void:
	# Broad, irregular compacted-earth aprons soften the old tile-on-a-box look.
	# They remain visual-only, so the single reliable ground slab still owns physics.
	_make_ground_patch(
		"AgoraEarthApron", Vector3(0, 0.006, 2.0),
		PackedVector2Array([
			Vector2(-18.5, -10.0), Vector2(-12.0, -15.0), Vector2(-3.5, -16.0),
			Vector2(8.0, -14.8), Vector2(18.0, -9.0), Vector2(19.5, 5.0),
			Vector2(14.0, 15.2), Vector2(3.0, 17.0), Vector2(-9.0, 16.0),
			Vector2(-19.0, 9.0)
		]), _dust
	)
	_make_visual_box("ProcessionalRoadShoulder", Vector3(0, 0.010, 6.8), Vector3(4.8, 0.025, 41.5), _sand, 0.0, false)
	_make_visual_box("AgoraCrossStreetShoulder", Vector3(0, 0.009, 11.0), Vector3(43.5, 0.022, 4.7), _sand, 0.0, false)
	_make_visual_box("SacredStreetShoulder", Vector3(0, 0.009, -21.0), Vector3(37.5, 0.022, 4.6), _dust, 0.0, false)
	_make_external("CivicPlaza", Vector3(0, 0.01, 0), PLAZA, Vector3(2.75, 0.34, 2.75), 0.0)
	_make_external("TempleOfWisdom", Vector3(0, 0, -13.0), TEMPLE, Vector3.ONE * 0.62, 0.0)
	_make_collision_box("TempleCollision", Vector3(0, 1.55, -13.2), Vector3(4.0, 3.1, 4.5))
	_make_external("WestHouse", Vector3(-13.0, 0, -1.5), HOUSE_A, Vector3.ONE * 0.86, PI * 0.5)
	_make_collision_box("WestHouseCollision", Vector3(-13.0, 1.9, -1.5), Vector3(5.2, 3.8, 5.8), PI * 0.5)
	_make_external("EastHouse", Vector3(13.0, 0, 0.0), HOUSE_B, Vector3.ONE * 0.78, -PI * 0.5)
	_make_collision_box("EastHouseCollision", Vector3(13.0, 1.75, 0.0), Vector3(5.2, 3.5, 5.8), -PI * 0.5)
	for index in range(10):
		_make_external(
			"ProcessionalRoad%02d" % index,
			Vector3(0, 0.015, 25.0 - float(index) * 4.0),
			ROAD,
			Vector3(0.85, 0.3, 1.0),
			0.0
		)
	for side in [-1.0, 1.0]:
		_make_external("AssemblyBench%dA" % int(side), Vector3(side * 5.4, 0, 1.8), BENCH, Vector3.ONE, PI * 0.5)
		_make_collision_box("AssemblyBenchCollision%dA" % int(side), Vector3(side * 5.4, 0.36, 1.8), Vector3(0.75, 0.72, 2.2))
		_make_external("AssemblyBench%dB" % int(side), Vector3(side * 5.4, 0, -1.2), BENCH, Vector3.ONE, PI * 0.5)
		_make_collision_box("AssemblyBenchCollision%dB" % int(side), Vector3(side * 5.4, 0.36, -1.2), Vector3(0.75, 0.72, 2.2))
	_make_external("SpeakerTable", Vector3(0, 0, -5.1), TABLE, Vector3.ONE * 0.82, 0.0)
	_make_collision_box("SpeakerTableCollision", Vector3(0, 0.45, -5.1), Vector3(2.2, 0.9, 1.0))
	_make_external("AthensAmphoraA", Vector3(-7.5, 0, -6.0), AMPHORA_A, Vector3.ONE * 0.82, 0.25)
	_make_external("AthensAmphoraB", Vector3(7.2, 0, 5.4), AMPHORA_B, Vector3.ONE * 0.8, -0.3)
	_make_external("AgoraFlowerWest", Vector3(-7.4, 0, 5.6), FLOWER_BUSH, Vector3.ONE * 0.48, 0.4)
	_make_external("AgoraFlowerEast", Vector3(7.2, 0, -5.7), FLOWER_BUSH, Vector3.ONE * 0.44, -0.5)
	_make_external("AgoraMarket", Vector3(-7.4, 0, 8.0), MARKET_STALL, Vector3.ONE * 0.92, PI * 0.5)
	_make_collision_box("AgoraMarketCollision", Vector3(-7.4, 0.52, 8.0), Vector3(1.3, 1.04, 3.0))
	_make_external("AgoraGoodsTable", Vector3(7.2, 0, 7.5), TABLE, Vector3.ONE * 0.76, PI * 0.5)
	_make_collision_box("AgoraGoodsTableCollision", Vector3(7.2, 0.42, 7.5), Vector3(1.0, 0.84, 1.9))
	_make_external("AgoraGoodsAmphora", Vector3(6.7, 0, 8.7), AMPHORA_A, Vector3.ONE * 0.72, 0.2)
	_make_colonnade("WestStoa", Vector3(-15.5, 0, -1.5), 18.0, PI * 0.5, _sandstone)
	_make_colonnade("EastStoa", Vector3(15.5, 0, -1.5), 18.0, PI * 0.5, _sandstone)
	for side in [-1.0, 1.0]:
		for index in range(5):
			_make_external(
				"AgoraSideStreet_%d_%d" % [int(side), index],
				Vector3(side * (8.0 + float(index) * 4.0), 0.012, 11.0),
				ROAD,
				Vector3(0.72, 0.28, 1.0),
				PI * 0.5
			)

	# Outer residential lanes make the agora read as the centre of a real polis,
	# rather than a single set surrounded by empty terrain. All new structures sit
	# outside the established story/NPC footprint and have simple reliable hulls.
	var quarter_buildings := [
		["WestPottersHouse", Vector3(-23.0, 0, 16.5), HOUSE_A, 0.78, PI * 0.5],
		["WestWeaversHouse", Vector3(-22.6, 0, 4.1), HOUSE_B, 0.74, PI * 0.5 + 0.035],
		["WestOliveHouse", Vector3(-23.2, 0, -9.2), HOUSE_A, 0.76, PI * 0.5 - 0.025],
		["EastScribeHouse", Vector3(23.0, 0, 15.0), HOUSE_B, 0.76, -PI * 0.5],
		["EastMerchantHouse", Vector3(22.7, 0, 2.6), HOUSE_A, 0.80, -PI * 0.5 - 0.03],
		["EastBronzeHouse", Vector3(23.2, 0, -10.2), HOUSE_B, 0.72, -PI * 0.5 + 0.04],
		["WestArchiveHouse", Vector3(-16.8, 0, -17.2), HOUSE_B, 0.70, 0.06],
		["EastArchiveHouse", Vector3(17.8, 0, -17.7), HOUSE_A, 0.71, -0.05],
	]
	for building_data in quarter_buildings:
		_make_playable_building(
			str(building_data[0]),
			building_data[1] as Vector3,
			building_data[2] as PackedScene,
			Vector3.ONE * float(building_data[3]),
			float(building_data[4]),
			Vector3(5.0, 3.5, 5.5)
		)

	_make_playable_stall("SouthMarketWest", Vector3(-14.0, 0, 20.0), PI * 0.5, 0.90)
	_make_playable_stall("SouthMarketEast", Vector3(14.0, 0, 20.0), -PI * 0.5, 0.90)
	_make_external("SouthMarketCrate", Vector3(-12.3, 0, 18.8), CRATE, Vector3.ONE * 0.62, 0.15)
	_make_external("SouthMarketJarA", Vector3(12.5, 0, 18.8), AMPHORA_A, Vector3.ONE * 0.68, -0.2)
	_make_external("SouthMarketJarB", Vector3(13.3, 0, 18.5), AMPHORA_B, Vector3.ONE * 0.58, 0.25)

	# A cross street and votive court continue behind the temple. The shrine is
	# offset far enough from the temple hull to leave two broad walking routes.
	for index in range(9):
		_make_external(
			"SacredCrossStreet%02d" % index,
			Vector3(-16.0 + float(index) * 4.0, 0.012, -21.0),
			ROAD,
			Vector3(0.70, 0.27, 1.0),
			PI * 0.5
		)
	_make_monument("AthenianVotiveMonument", Vector3(0, 0, -22.8), _sandstone, _bronze)
	_make_fountain("AgoraFountain", Vector3(15.0, 0, 15.0), _sandstone)
	_make_banner("TempleBannerWest", Vector3(-3.7, 0, -12.0), 3.1, _cloth_blue, 0.0)
	_make_banner("TempleBannerEast", Vector3(3.7, 0, -12.0), 3.1, _cloth_blue, 0.0)
	_make_street_clutter("WestPottersClutter", Vector3(-18.4, 0, 12.8), 0.12)
	_make_street_clutter("EastMerchantClutter", Vector3(18.0, 0, 6.8), -0.32)


func _build_sparta() -> void:
	# Sparta is deliberately austere, but not a single featureless stone rectangle.
	# Packed dirt, a pale wrestling pit and a worn central drill lane give the yard
	# human scale without changing any established NPC route or trigger.
	_make_box("TrainingYard", Vector3(0, 0.015, -1.0), Vector3(30, 0.10, 38), _yard_earth)
	_make_ground_patch(
		"WestWrestlingPit", Vector3(-8.2, 0.071, 3.0),
		PackedVector2Array([
			Vector2(-4.4, -5.0), Vector2(3.7, -5.4), Vector2(5.0, -2.0),
			Vector2(4.4, 4.2), Vector2(1.4, 5.4), Vector2(-4.5, 4.5),
			Vector2(-5.2, 0.6)
		]), _sand
	)
	_make_ground_patch(
		"EastDrillEarth", Vector3(8.0, 0.072, -2.0),
		PackedVector2Array([
			Vector2(-4.2, -7.0), Vector2(4.2, -6.5), Vector2(4.8, 5.8),
			Vector2(2.5, 7.2), Vector2(-4.4, 6.4), Vector2(-5.0, -1.8)
		]), _dust
	)
	_make_visual_box("CentralDrillLane", Vector3(0, 0.073, 2.5), Vector3(4.4, 0.018, 27.5), _road_stone, 0.0, false)
	for lane_side in [-1.0, 1.0]:
		_make_visual_box(
			"DrillLaneEdge_%d" % int(lane_side),
			Vector3(lane_side * 2.35, 0.075, 2.5), Vector3(0.13, 0.025, 27.5),
			_sandstone, 0.0, false
		)
	for index in range(8):
		_make_external(
			"SpartaEntryPath%02d" % index,
			Vector3(0, 0.02, 25.0 - float(index) * 4.0),
			DIRT_PATH,
			Vector3(0.82, 0.30, 1.0),
			0.0
		)
	_make_external("Barracks", Vector3(0, 0, -13.2), WORKSHOP, Vector3.ONE * 1.12, 0.0)
	_make_collision_box("BarracksBack", Vector3(0, 1.7, -15.7), Vector3(7.0, 3.4, 0.6))
	_make_collision_box("BarracksWest", Vector3(-3.2, 1.7, -13.2), Vector3(0.6, 3.4, 5.5))
	_make_collision_box("BarracksEast", Vector3(3.2, 1.7, -13.2), Vector3(0.6, 3.4, 5.5))
	_make_external("SpartaWestHouse", Vector3(-13.2, 0, 1.0), HOUSE_A, Vector3.ONE * 0.75, PI * 0.5)
	_make_collision_box("SpartaWestHouseCollision", Vector3(-13.2, 1.65, 1.0), Vector3(4.2, 3.3, 5.1), PI * 0.5)
	_make_external("SpartaEastHouse", Vector3(13.0, 0, 1.0), HOUSE_A, Vector3.ONE * 0.75, -PI * 0.5)
	_make_collision_box("SpartaEastHouseCollision", Vector3(13.0, 1.65, 1.0), Vector3(4.2, 3.3, 5.1), -PI * 0.5)
	for row in range(3):
		for side in [-1.0, 1.0]:
			_make_cylinder(
				"TrainingPost_%d_%d" % [row, int(side)],
				Vector3(side * 5.2, 0.85, 5.5 - float(row) * 4.0),
				0.18,
				1.7,
				_wood
			)
	_make_external("TrainerBench", Vector3(0, 0, -7.8), WOOD_BENCH, Vector3.ONE, 0.0)
	_make_collision_box("TrainerBenchCollision", Vector3(0, 0.35, -7.8), Vector3(2.2, 0.7, 0.7))
	_make_external("TrainingCrateA", Vector3(-8.0, 0, -7.0), CRATE, Vector3.ONE * 0.8, 0.1)
	_make_collision_box("TrainingCrateACollision", Vector3(-8.0, 0.42, -7.0), Vector3(0.9, 0.84, 0.9))
	_make_external("TrainingCrateB", Vector3(-7.1, 0, -7.2), CRATE, Vector3.ONE * 0.62, -0.2)
	_make_external("SpartaSupplyAmphora", Vector3(7.5, 0, -7.2), AMPHORA_B, Vector3.ONE * 0.76, 0.25)
	_make_external("WestEquipmentBench", Vector3(-7.2, 0, 8.0), WOOD_BENCH, Vector3.ONE, PI * 0.5)
	_make_collision_box("WestEquipmentBenchCollision", Vector3(-7.2, 0.35, 8.0), Vector3(0.7, 0.7, 2.2))
	_make_external("EastEquipmentBench", Vector3(7.2, 0, 8.0), WOOD_BENCH, Vector3.ONE, PI * 0.5)
	_make_collision_box("EastEquipmentBenchCollision", Vector3(7.2, 0.35, 8.0), Vector3(0.7, 0.7, 2.2))
	_make_training_rack("WestTrainingRack", Vector3(-7.5, 0, -2.0))
	_make_training_rack("EastTrainingRack", Vector3(7.5, 0, -2.0))
	for side in [-1.0, 1.0]:
		for index in range(7):
			_make_external(
				"SpartaSidePath_%d_%02d" % [int(side), index],
				Vector3(side * 18.0, 0.012, 24.0 - float(index) * 7.0),
				DIRT_PATH,
				Vector3(0.66, 0.3, 1.75),
				0.0
			)

	# Two disciplined outer training lanes surround the story yard. They remain
	# clear of the scripted trainee routes while adding a believable full compound.
	for side in [-1.0, 1.0]:
		_make_training_rack("OuterTrainingRack_%d_North" % int(side), Vector3(side * 13.8, 0, -9.0))
		_make_training_rack("OuterTrainingRack_%d_South" % int(side), Vector3(side * 13.8, 0, 12.5))
		for index in range(4):
			_make_cylinder(
				"AgilityPost_%d_%02d" % [int(side), index],
				Vector3(side * (11.8 + float(index % 2) * 2.0), 0.55, 5.0 - float(index) * 3.6),
				0.14,
				1.1,
				_wood
			)

	var compound_buildings := [
		["WestMessHouse", Vector3(-23.0, 0, 16.0), HOUSE_A, 0.75, PI * 0.5],
		["WestArmoury", Vector3(-22.5, 0, 2.3), WORKSHOP, 0.84, PI * 0.5 + 0.03],
		["WestSoldierHouse", Vector3(-23.2, 0, -11.8), HOUSE_A, 0.70, PI * 0.5 - 0.035],
		["EastMessHouse", Vector3(23.2, 0, 15.7), HOUSE_A, 0.77, -PI * 0.5 - 0.03],
		["EastArmoury", Vector3(22.6, 0, 2.8), WORKSHOP, 0.80, -PI * 0.5 + 0.04],
		["EastSoldierHouse", Vector3(23.1, 0, -11.1), HOUSE_A, 0.73, -PI * 0.5],
	]
	for building_data in compound_buildings:
		_make_playable_building(
			str(building_data[0]),
			building_data[1] as Vector3,
			building_data[2] as PackedScene,
			Vector3.ONE * float(building_data[3]),
			float(building_data[4]),
			Vector3(5.2, 3.4, 5.8)
		)

	_make_playable_building(
		"WestRearBarracks", Vector3(-10.5, 0, -22.0), WORKSHOP,
		Vector3.ONE * 0.80, 0.0, Vector3(5.4, 3.4, 5.0)
	)
	_make_playable_building(
		"EastRearBarracks", Vector3(10.5, 0, -22.0), WORKSHOP,
		Vector3.ONE * 0.80, 0.0, Vector3(5.4, 3.4, 5.0)
	)
	_make_external("OuterSupplyCrateA", Vector3(-16.0, 0, -15.0), CRATE, Vector3.ONE * 0.72, 0.12)
	_make_external("OuterSupplyCrateB", Vector3(-15.1, 0, -15.3), CRATE, Vector3.ONE * 0.58, -0.2)
	_make_external("OuterSupplyJar", Vector3(15.7, 0, -15.0), AMPHORA_B, Vector3.ONE * 0.72, 0.18)
	_make_banner("BarracksBannerWest", Vector3(-2.5, 0, -11.2), 3.0, _cloth_red, 0.0)
	_make_banner("BarracksBannerEast", Vector3(2.5, 0, -11.2), 3.0, _cloth_red, 0.0)
	_make_street_clutter("WestArmouryClutter", Vector3(-17.8, 0, -4.5), 0.24)
	_make_street_clutter("EastMessClutter", Vector3(18.0, 0, 13.5), -0.42)
	_dress_sparta_perimeter()


func _build_macedon() -> void:
	_make_box("AssemblyStone", Vector3(0, 0.015, -1.0), Vector3(24, 0.10, 22), _road_stone)
	_make_external("CommandHall", Vector3(0, 0, -13.0), WORKSHOP, Vector3.ONE * 1.14, 0.0)
	_make_collision_box("CommandHallBack", Vector3(0, 1.75, -15.6), Vector3(7.0, 3.5, 0.65))
	_make_collision_box("CommandHallWest", Vector3(-3.25, 1.75, -13.0), Vector3(0.65, 3.5, 5.6))
	_make_collision_box("CommandHallEast", Vector3(3.25, 1.75, -13.0), Vector3(0.65, 3.5, 5.6))
	_make_a_frame_tent("WestCanopy", Vector3(-10.5, 0, 0.0), 1.02, PI * 0.5, _cloth_red, true)
	_make_a_frame_tent("EastCanopy", Vector3(10.5, 0, 0.0), 1.02, -PI * 0.5, _cloth_purple, true)
	for index in range(9):
		_make_external(
			"MacedonRoad%02d" % index,
			Vector3(0, 0.02, 25.0 - float(index) * 4.0),
			ROAD,
			Vector3(0.9, 0.3, 1.0),
			0.0
		)
	_make_external("CampaignTable", Vector3(0, 0, -6.3), TABLE, Vector3.ONE, 0.0)
	_make_collision_box("CampaignTableCollision", Vector3(0, 0.48, -6.3), Vector3(2.35, 0.96, 1.15))
	_make_external("CampaignCrateA", Vector3(-4.0, 0, -7.0), CRATE, Vector3.ONE * 0.78, 0.1)
	_make_collision_box("CampaignCrateACollision", Vector3(-4.0, 0.42, -7.0), Vector3(0.9, 0.84, 0.9))
	_make_external("CampaignAmphora", Vector3(4.0, 0, -7.0), AMPHORA_A, Vector3.ONE * 0.8, 0.2)
	_make_external("CanopySupplyCrate", Vector3(8.3, 0, 2.4), CRATE, Vector3.ONE * 0.7, -0.15)
	_make_external("CanopySupplyJar", Vector3(-8.3, 0, -2.5), AMPHORA_B, Vector3.ONE * 0.72, 0.2)
	_make_a_frame_tent("ForwardCanopyWest", Vector3(-10.8, 0, 9.0), 0.92, PI * 0.5, _cloth_red, true)
	_make_a_frame_tent("ForwardCanopyEast", Vector3(10.8, 0, 9.0), 0.92, -PI * 0.5, _cloth_purple, true)
	for index in range(3):
		_make_external(
			"WestSupplyCrate%02d" % index,
			Vector3(-8.7 + float(index % 2) * 0.9, 0, 5.7 + float(index) * 0.72),
			CRATE,
			Vector3.ONE * (0.58 + float(index) * 0.06),
			float(index) * 0.18
		)
	_make_training_rack("MacedonWeaponRack", Vector3(7.7, 0, -6.0))

	# The expanded encampment is arranged in two ordered tent streets beyond the
	# scripted central cast. Tents, annexes and watch platforms have simple hulls;
	# the longitudinal paths remain broad enough for running and camera movement.
	for side in [-1.0, 1.0]:
		for index in range(4):
			var tent_position := Vector3(side * 21.5, 0, 18.0 - float(index) * 10.0)
			_make_a_frame_tent(
				"OuterCampaignTent_%d_%02d" % [int(side), index],
				tent_position,
				0.92 + float(index % 2) * 0.06,
				-PI * 0.5 * side,
				_cloth_red if (index + int(side > 0.0)) % 2 == 0 else _cloth_purple,
				true
			)
			_make_external(
				"OuterTentSupply_%d_%02d" % [int(side), index],
				tent_position + Vector3(-1.8 * side, 0, 2.0),
				CRATE if index % 2 == 0 else AMPHORA_A,
				Vector3.ONE * 0.62,
				float(index) * 0.28
			)
		for index in range(7):
			_make_external(
				"CampSidePath_%d_%02d" % [int(side), index],
				Vector3(side * 16.0, 0.012, 24.0 - float(index) * 7.0),
				DIRT_PATH,
				Vector3(0.68, 0.28, 1.72),
				0.0
			)

	_make_playable_building(
		"WestCommandAnnex", Vector3(-10.5, 0, -22.0), WORKSHOP,
		Vector3.ONE * 0.80, 0.0, Vector3(5.3, 3.4, 5.0)
	)
	_make_playable_building(
		"EastCommandAnnex", Vector3(10.5, 0, -22.0), WORKSHOP,
		Vector3.ONE * 0.80, 0.0, Vector3(5.3, 3.4, 5.0)
	)
	_make_guard_tower("SouthWestWatch", Vector3(-25.5, 0, 24.8), _wood, _cloth_purple)
	_make_guard_tower("SouthEastWatch", Vector3(25.5, 0, 24.8), _wood, _cloth_purple)
	_make_campfire("WestCampfire", Vector3(-14.8, 0, 9.0))
	_make_campfire("EastCampfire", Vector3(14.8, 0, -7.5))
	_make_banner("CommandBannerWest", Vector3(-2.5, 0, -11.0), 3.1, _cloth_purple, 0.0)
	_make_banner("CommandBannerEast", Vector3(2.5, 0, -11.0), 3.1, _cloth_purple, 0.0)


func _create_background_world() -> void:
	# The first backdrop layer reads as inaccessible streets immediately outside
	# the playable square; the second layer provides a skyline and terrain depth.
	match stage_type:
		StageType.ATHENS:
			_build_athens_background()
		StageType.SPARTA:
			_build_sparta_background()
		StageType.MACEDON:
			_build_macedon_background()
	_build_horizon_ridges()
	for index in range(7):
		_make_external(
			"RoadBeyondSouthGate%02d" % index,
			Vector3(0, -0.26, 32.0 + float(index) * 4.0),
			ROAD,
			Vector3(0.84, 0.28, 1.0),
			0.0,
			false
		)


func _build_athens_background() -> void:
	for side in [-1.0, 1.0]:
		for index in range(5):
			var height := 3.2 + float((index + int(abs(side))) % 3) * 0.55
			_make_background_house(
				"AthensSideQuarter_%d_%02d" % [int(side), index],
				Vector3(side * (32.5 + float(index % 2) * 1.0), 0, 16.0 - float(index) * 9.0),
				Vector3(6.0, height, 5.2),
				-PI * 0.5 * side,
				index
			)
	var north_x := [-17.5, -10.0, -3.7, 3.8, 10.5, 17.6]
	for index in range(north_x.size()):
		_make_background_house(
			"AthensNorthQuarter%02d" % index,
			Vector3(float(north_x[index]), 0.1 + float(index % 2) * 0.35, -37.0 - float(index % 2) * 2.3),
			Vector3(5.8, 3.6 + float(index % 3) * 0.45, 5.0),
			0.0,
			index + 5
		)
	_make_external("DistantAcropolisTemple", Vector3(14.0, 5.0, -61.0), TEMPLE, Vector3.ONE * 0.34, -0.08, false)
	_make_visual_box("DistantAcropolis", Vector3(14.0, 3.2, -61.0), Vector3(21.0, 4.6, 15.0), _distant_stone, 0.0, false)
	_make_external("OuterAgoraStallWest", Vector3(-32.0, 0, 6.5), MARKET_STALL, Vector3.ONE * 0.82, PI * 0.5, false)
	_make_external("OuterAgoraStallEast", Vector3(32.0, 0, 8.5), MARKET_STALL, Vector3.ONE * 0.82, -PI * 0.5, false)


func _build_sparta_background() -> void:
	for side in [-1.0, 1.0]:
		for index in range(4):
			_make_background_house(
				"SpartaCompound_%d_%02d" % [int(side), index],
				Vector3(side * (32.5 + float(index % 2)), 0, 15.0 - float(index) * 11.0),
				Vector3(6.4, 3.0 + float(index % 2) * 0.45, 6.2),
				-PI * 0.5 * side,
				index + 12
			)
	_make_external("DistantSpartaBarracks", Vector3(0, 3.1, -54.0), WORKSHOP, Vector3.ONE * 0.86, 0.0, false)
	_make_visual_box("SpartaBarracksTerrace", Vector3(0, 1.5, -54.0), Vector3(22.0, 3.0, 14.0), _distant_stone, 0.0, false)
	for side in [-1.0, 1.0]:
		_make_colonnade(
			"DistantDrillShelter_%d" % int(side),
			Vector3(side * 18.0, 0, -39.0),
			10.0,
			0.0,
			_dark_stone,
			false
		)
	_make_visual_box("SpartaOuterYard", Vector3(0, -0.20, 40.0), Vector3(38.0, 0.22, 20.0), _road_stone, 0.0, false)


func _build_macedon_background() -> void:
	for side in [-1.0, 1.0]:
		for index in range(4):
			_make_a_frame_tent(
				"CampaignTent_%d_%02d" % [int(side), index],
				Vector3(side * (32.5 + float(index % 2) * 1.2), 0, 15.0 - float(index) * 10.5),
				0.92 + float(index % 2) * 0.08,
				-PI * 0.5 * side,
				_cloth_red if index % 2 == 0 else _cloth_purple,
				false
			)
			_make_external(
				"CampaignSupply_%d_%02d" % [int(side), index],
				Vector3(side * 31.0, 0, 13.0 - float(index) * 10.0),
				CRATE,
				Vector3.ONE * 0.66,
				float(index) * 0.23,
				false
			)
	_make_visual_box("DistantCommandTerrace", Vector3(0, 1.6, -55.0), Vector3(24.0, 3.2, 14.0), _distant_stone, 0.0, false)
	_make_external("DistantCommandHall", Vector3(0, 3.22, -55.0), WORKSHOP, Vector3.ONE * 0.92, 0.0, false)


func _build_horizon_ridges() -> void:
	var ridge_positions := [
		Vector3(-28.0, 2.2, -70.0), Vector3(-15.5, 3.0, -76.0),
		Vector3(-2.0, 2.4, -72.0), Vector3(12.0, 3.1, -77.0),
		Vector3(27.0, 2.0, -69.0)
	]
	for index in range(ridge_positions.size()):
		_make_external(
			"HorizonRidge%02d" % index,
			ridge_positions[index],
			ROCK_A if index % 2 == 0 else ROCK_B,
			Vector3(5.8 + float(index % 2), 5.0 + float(index % 3) * 0.8, 5.4),
			float(index) * 0.62,
			false
		)


func _make_background_house(
	name_value: String,
	ground_position: Vector3,
	size: Vector3,
	yaw: float,
	variant: int
) -> void:
	var wall_material := _plaster if variant % 3 != 1 else _sandstone
	_make_visual_box(
		name_value + "Body",
		ground_position + Vector3.UP * size.y * 0.5,
		size,
		wall_material,
		yaw,
		false
	)
	_make_visual_box(
		name_value + "Roof",
		ground_position + Vector3.UP * (size.y + 0.18),
		Vector3(size.x + 0.5, 0.36, size.z + 0.5),
		_terracotta,
		yaw,
		false
	)
	var door_offset := Vector3(0, 1.0, size.z * 0.505).rotated(Vector3.UP, yaw)
	_make_visual_box(
		name_value + "Door",
		ground_position + door_offset,
		Vector3(1.0, 2.0, 0.14),
		_wood,
		yaw,
		false
	)


func _make_ground_patch(name_value: String, ground_position: Vector3, points: PackedVector2Array, material: Material) -> MeshInstance3D:
	# Visual-only compacted earth overlays deliberately leave ReliableGround as the
	# sole physics floor. A bounded patch also avoids fragile triangulation seams.
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for point in points:
		minimum = minimum.min(point)
		maximum = maximum.max(point)
	var patch_size := maximum - minimum
	var patch_center := (minimum + maximum) * 0.5
	return _make_visual_box(
		name_value,
		ground_position + Vector3(patch_center.x, 0, patch_center.y),
		Vector3(patch_size.x, 0.018, patch_size.y),
		material,
		0.0,
		false
	)


func _make_street_clutter(name_value: String, ground_position: Vector3, yaw: float) -> void:
	# Small market-group silhouettes add lived-in density without introducing
	# collision on the established civilian routes.
	_make_visual_box(name_value + "Crate", ground_position + Vector3(-0.42, 0.28, 0.08), Vector3(0.54, 0.56, 0.54), _wood, yaw, true)
	_make_visual_box(name_value + "Jar", ground_position + Vector3(0.32, 0.26, -0.18), Vector3(0.38, 0.52, 0.38), _terracotta, yaw, false)
	_make_visual_box(name_value + "AwningRoll", ground_position + Vector3(0.04, 0.56, 0.42), Vector3(0.96, 0.12, 0.26), _cloth_blue, yaw, false)


func _dress_sparta_perimeter() -> void:
	# Broken stone and restrained storage distinguish the hard military compound
	# from Athens' denser civic edge while staying beyond active drill lanes.
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		_make_external(
			"SpartaPerimeterRock%02d" % index,
			Vector3(side * (22.5 + float(index % 3) * 1.4), 0, 19.5 - float(index / 2) * 15.0),
			ROCK_A if index % 3 == 0 else ROCK_B,
			Vector3.ONE * (0.72 + float(index % 2) * 0.12),
			float(index) * 0.47,
			false
		)


func _make_playable_building(
	name_value: String,
	ground_position: Vector3,
	scene: PackedScene,
	scale_value: Vector3,
	yaw: float,
	collision_size: Vector3
) -> void:
	_make_external(name_value, ground_position, scene, scale_value, yaw)
	_make_collision_box(
		name_value + "Collision",
		ground_position + Vector3.UP * collision_size.y * 0.5,
		collision_size,
		yaw
	)


func _make_playable_stall(name_value: String, ground_position: Vector3, yaw: float, scale_value: float) -> void:
	_make_external(name_value, ground_position, MARKET_STALL, Vector3.ONE * scale_value, yaw)
	# The imported stall presents its narrow counter axis after a quarter turn.
	_make_collision_box(
		name_value + "Collision",
		ground_position + Vector3.UP * 0.56,
		Vector3(1.55, 1.12, 3.25)
	)


func _make_a_frame_tent(
	name_value: String,
	ground_position: Vector3,
	scale_value: float,
	yaw: float,
	canvas_material: Material,
	with_collision: bool
) -> Node3D:
	# A continuous ridge and two pitched canvas leaves make these read as actual
	# campaign tents at close range, unlike the former market-stall stand-in.
	# Keep the root and its optional collider named exactly like the former prop
	# so dialogue paths, triggers and the world audit remain stable.
	var root := Node3D.new()
	root.name = name_value
	root.position = ground_position
	root.rotation.y = yaw
	add_child(root)
	var half_width := 1.45 * scale_value
	var ridge_height := 2.18 * scale_value
	var depth := 3.25 * scale_value
	var pitch := atan2(ridge_height, half_width)
	var roof_length := sqrt(half_width * half_width + ridge_height * ridge_height)
	_make_visual_box_child_rotated(
		root, "CanvasWest", Vector3(-half_width * 0.5, ridge_height * 0.5, 0),
		Vector3(roof_length, 0.075, depth), canvas_material, Vector3(0, 0, pitch), with_collision
	)
	_make_visual_box_child_rotated(
		root, "CanvasEast", Vector3(half_width * 0.5, ridge_height * 0.5, 0),
		Vector3(roof_length, 0.075, depth), canvas_material, Vector3(0, 0, -pitch), with_collision
	)
	_make_visual_box_child(root, "RidgePole", Vector3(0, ridge_height, 0), Vector3(0.12, 0.12, depth + 0.14), _wood, with_collision)
	_make_tent_end_child(root, "FrontGable", depth * 0.505, half_width, ridge_height, canvas_material, true, with_collision)
	_make_tent_end_child(root, "RearGable", -depth * 0.505, half_width, ridge_height, canvas_material, false, with_collision)
	# A dark, correctly proportioned opening reads as an entrance without the old
	# rectangular flap protruding beyond the triangular canvas silhouette.
	_make_visual_box_child(
		root, "Entrance", Vector3(0, ridge_height * 0.27, depth * 0.515),
		Vector3(half_width * 0.64, ridge_height * 0.54, 0.045), _dark_opening, with_collision
	)
	_make_visual_box_child(
		root, "EntranceLintel", Vector3(0, ridge_height * 0.55, depth * 0.525),
		Vector3(half_width * 0.76, 0.075, 0.055), _wood, with_collision
	)
	for side in [-1.0, 1.0]:
		_make_visual_box_child(root, "Stake%d" % int(side), Vector3(side * (half_width + 0.22), 0.11, depth * 0.42), Vector3(0.10, 0.22, 0.10), _wood, with_collision)
	if with_collision:
		_make_collision_box(
			name_value + "Collision",
			ground_position + Vector3.UP * (ridge_height * 0.36),
			Vector3(half_width * 1.92, ridge_height * 0.72, depth * 0.90),
			yaw
		)
	return root


func _make_tent_end_child(
	parent: Node3D,
	name_value: String,
	z_position: float,
	half_width: float,
	height: float,
	material: Material,
	front_facing: bool,
	casts_shadow: bool
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	var vertices := PackedVector3Array([
		Vector3(-half_width, 0.0, z_position),
		Vector3(half_width, 0.0, z_position),
		Vector3(0.0, height, z_position),
	])
	var normal := Vector3.BACK if front_facing else Vector3.FORWARD
	var normals := PackedVector3Array([normal, normal, normal])
	var uvs := PackedVector2Array([Vector2(0, 1), Vector2(1, 1), Vector2(0.5, 0)])
	var indices := PackedInt32Array([0, 1, 2] if front_facing else [2, 1, 0])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	mesh_instance.mesh = mesh
	parent.add_child(mesh_instance)
	return mesh_instance


func _make_monument(
	name_value: String,
	ground_position: Vector3,
	stone_material: Material,
	accent_material: Material
) -> void:
	_make_box(name_value + "LowerStep", ground_position + Vector3.UP * 0.14, Vector3(3.4, 0.28, 3.4), stone_material)
	_make_box(name_value + "UpperStep", ground_position + Vector3.UP * 0.38, Vector3(2.65, 0.24, 2.65), stone_material)
	_make_cylinder(name_value + "Column", ground_position + Vector3.UP * 1.62, 0.42, 2.25, stone_material)
	_make_box(name_value + "Capital", ground_position + Vector3.UP * 2.78, Vector3(1.15, 0.18, 1.15), stone_material)
	_make_cylinder(name_value + "OfferingBowl", ground_position + Vector3.UP * 3.04, 0.50, 0.24, accent_material)


func _make_fountain(name_value: String, ground_position: Vector3, material: Material) -> void:
	_make_box(name_value + "Apron", ground_position + Vector3.UP * 0.10, Vector3(3.6, 0.20, 3.6), _road_stone)
	_make_cylinder(name_value + "Basin", ground_position + Vector3.UP * 0.34, 1.38, 0.48, material)
	_make_cylinder(name_value + "Centre", ground_position + Vector3.UP * 0.90, 0.28, 0.78, _bronze)
	_make_cylinder(name_value + "Crown", ground_position + Vector3.UP * 1.34, 0.48, 0.12, material)


func _make_banner(
	name_value: String,
	ground_position: Vector3,
	height: float,
	cloth_material: Material,
	yaw: float
) -> void:
	var pole_position := ground_position + Vector3.UP * height * 0.5
	_make_cylinder(name_value + "Pole", pole_position, 0.045, height, _wood)
	var cloth_offset := Vector3(0.58, height - 0.88, 0).rotated(Vector3.UP, yaw)
	_make_visual_box(
		name_value + "Cloth",
		ground_position + cloth_offset,
		Vector3(1.02, 1.32, 0.055),
		cloth_material,
		yaw
	)
	var finial_offset := Vector3(0, height + 0.08, 0)
	_make_cylinder(name_value + "Finial", ground_position + finial_offset, 0.09, 0.16, _bronze)


func _make_guard_tower(
	name_value: String,
	ground_position: Vector3,
	structure_material: Material,
	accent_material: Material
) -> void:
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			_make_visual_box(
				name_value + "Post_%d_%d" % [int(x_sign), int(z_sign)],
				ground_position + Vector3(x_sign * 1.05, 1.25, z_sign * 1.05),
				Vector3(0.22, 2.5, 0.22),
				structure_material
			)
	_make_visual_box(name_value + "Deck", ground_position + Vector3.UP * 2.35, Vector3(2.8, 0.28, 2.8), structure_material)
	_make_visual_box(name_value + "Canopy", ground_position + Vector3.UP * 3.20, Vector3(3.1, 0.20, 3.1), accent_material)
	_make_collision_box(name_value + "Collision", ground_position + Vector3.UP * 1.2, Vector3(2.65, 2.4, 2.65))


func _make_campfire(name_value: String, ground_position: Vector3) -> void:
	_make_cylinder(name_value + "Hearth", ground_position + Vector3.UP * 0.09, 0.72, 0.18, _dark_stone)
	_make_visual_box(name_value + "LogA", ground_position + Vector3(0, 0.27, 0), Vector3(1.05, 0.16, 0.18), _wood, 0.62)
	_make_visual_box(name_value + "LogB", ground_position + Vector3(0, 0.29, 0), Vector3(1.05, 0.16, 0.18), _wood, -0.62)
	_make_cylinder(name_value + "Ember", ground_position + Vector3.UP * 0.40, 0.28, 0.22, _fire)
	for puff_index in range(3):
		var smoke := MeshInstance3D.new()
		smoke.name = "Smoke%02d" % puff_index
		var smoke_mesh := QuadMesh.new()
		smoke_mesh.size = Vector2(0.72 + float(puff_index) * 0.22, 0.70 + float(puff_index) * 0.28)
		smoke_mesh.material = _smoke
		smoke.mesh = smoke_mesh
		smoke.position = ground_position + Vector3(0.10 * float(puff_index - 1), 0.88 + float(puff_index) * 0.62, 0.06 * float(puff_index))
		smoke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(smoke)
	var fire_light := OmniLight3D.new()
	fire_light.name = name_value + "Light"
	fire_light.position = ground_position + Vector3.UP * 0.72
	fire_light.light_color = Color(1.0, 0.39, 0.12)
	fire_light.light_energy = 1.35
	fire_light.omni_range = 5.0
	fire_light.shadow_enabled = false
	add_child(fire_light)


func _make_colonnade(
	name_value: String,
	ground_position: Vector3,
	length: float,
	yaw: float,
	material: Material,
	casts_shadow: bool = true
) -> void:
	var root := Node3D.new()
	root.name = name_value
	root.position = ground_position
	root.rotation.y = yaw
	add_child(root)
	var column_count := maxi(3, int(length / 2.4))
	for index in range(column_count):
		var local_z := -length * 0.5 + (float(index) + 0.5) * length / float(column_count)
		_make_visual_box_child(
			root,
			"Column%02d" % index,
			Vector3(0, 1.35, local_z),
			Vector3(0.42, 2.7, 0.42),
			material,
			casts_shadow
		)
		if casts_shadow:
			_make_collision_box(
				name_value + "ColumnCollision%02d" % index,
				ground_position + Vector3(0, 1.35, local_z).rotated(Vector3.UP, yaw),
				Vector3(0.42, 2.7, 0.42),
				yaw
			)
	_make_visual_box_child(root, "Roof", Vector3(0, 2.9, 0), Vector3(2.2, 0.38, length + 0.6), _terracotta, casts_shadow)
	_make_visual_box_child(root, "Stylobate", Vector3(0, 0.16, 0), Vector3(2.5, 0.32, length + 0.4), _sandstone, casts_shadow)
	if casts_shadow:
		_make_collision_box(
			name_value + "StylobateCollision",
			ground_position + Vector3.UP * 0.16,
			Vector3(2.5, 0.32, length + 0.4),
			yaw
		)


func _make_training_rack(name_value: String, ground_position: Vector3) -> void:
	var root := Node3D.new()
	root.name = name_value
	root.position = ground_position
	add_child(root)
	_make_visual_box_child(root, "PostWest", Vector3(-0.85, 0.9, 0), Vector3(0.16, 1.8, 0.16), _wood, true)
	_make_visual_box_child(root, "PostEast", Vector3(0.85, 0.9, 0), Vector3(0.16, 1.8, 0.16), _wood, true)
	_make_visual_box_child(root, "Crossbar", Vector3(0, 1.55, 0), Vector3(2.0, 0.16, 0.16), _wood, true)
	_make_collision_box(name_value + "Collision", ground_position + Vector3(0, 0.9, 0), Vector3(2.0, 1.8, 0.25))


func _make_palisade(name_value: String, center: Vector3, length: float, yaw: float) -> void:
	var root := Node3D.new()
	root.name = name_value
	root.position = center
	root.rotation.y = yaw
	add_child(root)
	var post_count := maxi(4, int(length / 1.5))
	for index in range(post_count):
		var local_x := -length * 0.5 + (float(index) + 0.5) * length / float(post_count)
		var post_height := 2.48 + float(index % 4) * 0.14
		_make_tapered_post_child(root, "Post%02d" % index, Vector3(local_x, post_height * 0.5, 0), post_height, _wood, true)
	_make_visual_box_child(root, "RailLower", Vector3(0, 0.92, 0), Vector3(length, 0.16, 0.18), _wood, true)
	_make_visual_box_child(root, "RailUpper", Vector3(0, 1.65, 0), Vector3(length, 0.16, 0.18), _wood, true)


func _add_landscape_dressing() -> void:
	var tree_positions: Array[Vector3]
	var rock_positions: Array[Vector3]
	var bush_positions: Array[Vector3]
	match stage_type:
		StageType.ATHENS:
			tree_positions = [
				Vector3(-19.0, 0, 23.5), Vector3(19.0, 0, 23.0),
				Vector3(-19.0, 0, -21.5), Vector3(19.0, 0, -21.0),
				Vector3(-9.5, 0, 18.0), Vector3(9.5, 0, -18.5)
			]
			rock_positions = [Vector3(-26.0, 0, -24.0), Vector3(26.0, 0, -23.5)]
			bush_positions = [
				Vector3(-17.2, 0, 15.5), Vector3(17.0, 0, 20.0),
				Vector3(-9.0, 0, -19.0), Vector3(9.0, 0, -23.0)
			]
		StageType.SPARTA:
			tree_positions = [Vector3(-12.0, 0, 24.0), Vector3(12.0, 0, 24.0)]
			rock_positions = [
				Vector3(-26.0, 0, -24.0), Vector3(-19.0, 0, -25.0),
				Vector3(19.0, 0, -25.0), Vector3(26.0, 0, -23.0)
			]
			bush_positions = [Vector3(-20.0, 0, 23.0), Vector3(20.0, 0, 22.0)]
		StageType.MACEDON:
			tree_positions = [
				Vector3(-17.5, 0, -24.0), Vector3(17.5, 0, -24.0),
				Vector3(-26.0, 0, 3.0), Vector3(26.0, 0, -5.0)
			]
			rock_positions = [Vector3(-25.5, 0, -21.0), Vector3(25.5, 0, -20.0)]
			bush_positions = [Vector3(-18.0, 0, 23.0), Vector3(18.0, 0, 22.5)]

	for index in range(tree_positions.size()):
		_make_external(
			"BackdropTree%02d" % index,
			tree_positions[index],
			TREE_A if index % 2 == 0 else TREE_B,
			Vector3.ONE * (0.30 + float(index % 3) * 0.025),
			float(index) * 0.72
		)
		_make_collision_box(
			"BackdropTree%02dTrunkCollision" % index,
			tree_positions[index] + Vector3.UP * 1.2,
			Vector3(0.82, 2.4, 0.82)
		)
	for index in range(rock_positions.size()):
		_make_external(
			"BackdropRock%02d" % index,
			rock_positions[index],
			ROCK_A if index % 2 == 0 else ROCK_B,
			Vector3(1.55, 1.3, 1.45),
			float(index) * 0.9
		)
		_make_collision_box(
			"BackdropRock%02dCollision" % index,
			rock_positions[index] + Vector3.UP * 0.62,
			Vector3(2.2, 1.24, 2.0),
			float(index) * 0.9
		)
	for index in range(bush_positions.size()):
		_make_external(
			"BoundaryBush%02d" % index,
			bush_positions[index],
			FLOWER_BUSH if stage_type == StageType.ATHENS and index % 2 == 0 else BUSH,
			Vector3.ONE * (0.48 + float(index % 2) * 0.06),
			float(index) * 0.7
		)
	_dress_outer_viewline()


func _dress_outer_viewline() -> void:
	# These clusters sit beyond the collision perimeter, so they break up exposed
	# dirt and skyline from the playable square without changing a patrol route.
	match stage_type:
		StageType.SPARTA:
			_make_outer_berm("SpartaNorthBermWest", Vector3(-18.0, 0, -42.0), Vector3(16.0, 1.45, 5.0), _distant_stone)
			_make_outer_berm("SpartaNorthBermEast", Vector3(15.0, 0, -47.0), Vector3(19.0, 1.8, 6.5), _dark_stone)
			_make_outer_berm("SpartaSouthPracticeBank", Vector3(0, 0, 37.5), Vector3(26.0, 0.72, 3.6), _yard_earth)
			for index in range(5):
				var side := -1.0 if index % 2 == 0 else 1.0
				_make_external(
					"SpartaOuterRubble%02d" % index,
					Vector3(side * (33.0 + float(index % 2) * 2.0), 0, 20.0 - float(index) * 12.5),
					ROCK_A if index % 2 == 0 else ROCK_B,
					Vector3.ONE * (0.78 + float(index % 3) * 0.13),
					float(index) * 0.62,
					false
				)
			for index in range(4):
				_make_external(
					"SpartaDryScrub%02d" % index,
					Vector3(-34.0 + float(index) * 22.0, 0, -35.0 - float(index % 2) * 9.0),
					GRASS_WISPY if index % 2 == 0 else BUSH,
					Vector3.ONE * (0.62 + float(index % 2) * 0.10),
					float(index) * 0.48,
					false
				)
			_make_outer_supply_stack("SpartaOuterSupply", Vector3(34.0, 0, 23.5), _wood)
			_make_outer_watch_post("SpartaNorthWatch", Vector3(-35.0, 0, -29.0), _wood, _cloth_red)
		StageType.MACEDON:
			_make_outer_berm("MacedonNorthBermWest", Vector3(-17.0, 0, -42.0), Vector3(18.0, 1.35, 6.0), _distant_stone)
			_make_outer_berm("MacedonNorthBermEast", Vector3(18.0, 0, -46.0), Vector3(18.0, 1.65, 7.0), _dark_stone)
			_make_outer_berm("MacedonSouthRoadBerm", Vector3(0, 0, 38.5), Vector3(29.0, 0.70, 3.4), _yard_earth)
			for index in range(6):
				var side := -1.0 if index % 2 == 0 else 1.0
				_make_external(
					"MacedonOuterRock%02d" % index,
					Vector3(side * (33.5 + float(index % 3) * 1.7), 0, 23.0 - float(index) * 10.5),
					ROCK_A if index % 3 == 0 else ROCK_B,
					Vector3.ONE * (0.82 + float(index % 2) * 0.14),
					float(index) * 0.51,
					false
				)
			for index in range(5):
				_make_external(
					"MacedonDryScrub%02d" % index,
					Vector3(-34.0 + float(index) * 17.0, 0, -34.0 - float(index % 2) * 8.0),
					GRASS_WISPY if index % 2 == 0 else BUSH,
					Vector3.ONE * (0.64 + float(index % 2) * 0.10),
					float(index) * 0.44,
					false
				)
			_make_outer_supply_stack("MacedonOuterSupplyWest", Vector3(-34.0, 0, 22.5), _wood)
			_make_outer_supply_stack("MacedonOuterSupplyEast", Vector3(34.0, 0, 14.5), _wood)
			_make_outer_watch_post("MacedonNorthWatch", Vector3(35.0, 0, -28.0), _wood, _cloth_purple)


func _make_outer_berm(name_value: String, ground_position: Vector3, size: Vector3, material: Material) -> void:
	_make_visual_box(name_value + "Base", ground_position + Vector3.UP * size.y * 0.34, Vector3(size.x, size.y * 0.68, size.z), material, 0.0, false)
	_make_visual_box(name_value + "Crest", ground_position + Vector3(0.8, size.y * 0.76, -0.24), Vector3(size.x * 0.74, size.y * 0.34, size.z * 0.68), material, 0.06, false)


func _make_outer_supply_stack(name_value: String, ground_position: Vector3, material: Material) -> void:
	_make_visual_box(name_value + "CrateA", ground_position + Vector3(-0.42, 0.32, 0), Vector3(0.64, 0.64, 0.64), material, 0.14, false)
	_make_visual_box(name_value + "CrateB", ground_position + Vector3(0.34, 0.25, 0.14), Vector3(0.54, 0.50, 0.54), material, -0.12, false)
	_make_visual_box(name_value + "Roll", ground_position + Vector3(0.02, 0.72, -0.10), Vector3(0.88, 0.18, 0.32), _cloth_red if stage_type == StageType.SPARTA else _cloth_purple, 0.08, false)


func _make_outer_watch_post(name_value: String, ground_position: Vector3, structure_material: Material, banner_material: Material) -> void:
	var root := Node3D.new()
	root.name = name_value
	root.position = ground_position
	add_child(root)
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			_make_visual_box_child(root, "Post_%d_%d" % [int(x_sign), int(z_sign)], Vector3(x_sign * 0.72, 1.15, z_sign * 0.72), Vector3(0.16, 2.3, 0.16), structure_material, false)
	_make_visual_box_child(root, "Platform", Vector3(0, 2.12, 0), Vector3(2.05, 0.18, 2.05), structure_material, false)
	_make_visual_box_child(root, "Pennant", Vector3(0.12, 2.94, 0), Vector3(0.74, 0.82, 0.05), banner_material, false)


func _create_visible_boundaries() -> void:
	# Continuous colliders sit directly inside authored fortifications. Their
	# 58 metre footprint matches ReliableGround exactly, including all four corners.
	_make_collision_box(
		"NorthBoundaryCollision", Vector3(0, 1.4, -PLAYABLE_HALF_Z),
		Vector3(PLAYABLE_HALF_X * 2.0, 2.8, 0.9)
	)
	_make_collision_box(
		"SouthBoundaryCollision", Vector3(0, 1.4, PLAYABLE_HALF_Z),
		Vector3(PLAYABLE_HALF_X * 2.0, 2.8, 0.9)
	)
	_make_collision_box(
		"WestBoundaryCollision", Vector3(-PLAYABLE_HALF_X, 1.4, 0),
		Vector3(0.9, 2.8, PLAYABLE_HALF_Z * 2.0)
	)
	_make_collision_box(
		"EastBoundaryCollision", Vector3(PLAYABLE_HALF_X, 1.4, 0),
		Vector3(0.9, 2.8, PLAYABLE_HALF_Z * 2.0)
	)

	match stage_type:
		StageType.ATHENS:
			_make_masonry_perimeter("Athens", 1.22, _sandstone, _cloth_blue)
		StageType.SPARTA:
			_make_masonry_perimeter("Sparta", 1.08, _dark_stone, _cloth_red)
		StageType.MACEDON:
			_make_palisade("NorthCampPalisade", Vector3(0, 0, -28.55), 58.0, 0.0)
			_make_palisade("WestCampPalisade", Vector3(-28.55, 0, 0), 58.0, PI * 0.5)
			_make_palisade("EastCampPalisade", Vector3(28.55, 0, 0), 58.0, PI * 0.5)
			_make_palisade("SouthCampPalisadeWest", Vector3(-16.5, 0, 28.55), 25.0, 0.0)
			_make_palisade("SouthCampPalisadeEast", Vector3(16.5, 0, 28.55), 25.0, 0.0)
			_make_south_gate("Macedon", _wood, _cloth_purple)


func _make_masonry_perimeter(
	prefix: String,
	height_scale: float,
	gate_stone: Material,
	accent_material: Material
) -> void:
	for index in range(15):
		var coordinate := -28.0 + float(index) * WALL_SEGMENT_SPACING
		_make_external(
			prefix + "NorthWall%02d" % index,
			Vector3(coordinate, 0, -28.55),
			STONE_WALL,
			Vector3(0.98, height_scale, 0.82),
			0.0
		)
		# Leave one clean module for the gate instead of burying it in wall geometry.
		if index != 7:
			_make_external(
				prefix + "SouthWall%02d" % index,
				Vector3(coordinate, 0, 28.55),
				STONE_WALL,
				Vector3(0.98, height_scale, 0.82),
				0.0
			)
		_make_external(
			prefix + "WestWall%02d" % index,
			Vector3(-28.55, 0, coordinate),
			STONE_WALL,
			Vector3(0.98, height_scale, 0.82),
			PI * 0.5
		)
		_make_external(
			prefix + "EastWall%02d" % index,
			Vector3(28.55, 0, coordinate),
			STONE_WALL,
			Vector3(0.98, height_scale, 0.82),
			PI * 0.5
		)
	for corner_data in [
		["NorthWest", Vector3(-27.2, 0, -27.2)],
		["NorthEast", Vector3(27.2, 0, -27.2)],
		["SouthWest", Vector3(-27.2, 0, 27.2)],
		["SouthEast", Vector3(27.2, 0, 27.2)],
	]:
		_make_masonry_tower(prefix + str(corner_data[0]) + "Tower", corner_data[1] as Vector3, gate_stone)
	_make_south_gate(prefix, gate_stone, accent_material)


func _make_south_gate(prefix: String, pier_material: Material, accent_material: Material) -> void:
	var gate_z := PLAYABLE_HALF_Z - 0.52
	var gate_material: Material = _gate_wood if prefix == "Sparta" else _wood
	_make_visual_box(prefix + "GateWestPier", Vector3(-2.9, 1.9, gate_z), Vector3(1.55, 3.8, 1.55), pier_material)
	_make_visual_box(prefix + "GateEastPier", Vector3(2.9, 1.9, gate_z), Vector3(1.55, 3.8, 1.55), pier_material)
	_make_visual_box(prefix + "GateLintel", Vector3(0, 3.55, gate_z), Vector3(7.1, 0.62, 1.55), pier_material)
	_make_visual_box(prefix + "ClosedSouthGate", Vector3(0, 1.42, gate_z - 0.08), Vector3(4.3, 2.84, 0.34), gate_material)
	_make_visual_box(prefix + "GateBandTop", Vector3(0, 2.15, gate_z - 0.28), Vector3(4.4, 0.13, 0.12), accent_material)
	_make_visual_box(prefix + "GateBandBottom", Vector3(0, 0.72, gate_z - 0.28), Vector3(4.4, 0.13, 0.12), accent_material)
	_make_banner(prefix + "GateBannerWest", Vector3(-2.9, 0, gate_z - 0.82), 3.4, accent_material, 0.0)
	_make_banner(prefix + "GateBannerEast", Vector3(2.9, 0, gate_z - 0.82), 3.4, accent_material, 0.0)


func _make_masonry_tower(name_value: String, ground_position: Vector3, material: Material) -> void:
	_make_visual_box(name_value + "Body", ground_position + Vector3.UP * 1.75, Vector3(3.0, 3.5, 3.0), material)
	_make_visual_box(name_value + "Crown", ground_position + Vector3.UP * 3.62, Vector3(3.5, 0.28, 3.5), _terracotta)
	_make_collision_box(name_value + "Collision", ground_position + Vector3.UP * 1.75, Vector3(3.0, 3.5, 3.0))


func _make_external(
	name_value: String,
	position_value: Vector3,
	scene: PackedScene,
	scale_value: Vector3,
	yaw: float,
	casts_shadow: bool = true
) -> Node3D:
	var root := Node3D.new()
	root.name = name_value
	root.position = position_value
	root.rotation.y = yaw
	add_child(root)
	var model := MeshInstance3D.new()
	model.name = "Model"
	model.scale = scale_value
	model.mesh = _get_merged_scene_mesh(scene)
	model.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	root.add_child(model)
	return root


func _make_box(name_value: String, position_value: Vector3, size: Vector3, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	add_child(body)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body


func _make_visual_box(
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	yaw: float = 0.0,
	casts_shadow: bool = true
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.position = position_value
	mesh_instance.rotation.y = yaw
	mesh_instance.mesh = _get_visual_box_mesh(size, material)
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	add_child(mesh_instance)
	return mesh_instance


func _make_visual_box_child(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	casts_shadow: bool
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.position = position_value
	mesh_instance.mesh = _get_visual_box_mesh(size, material)
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	parent.add_child(mesh_instance)
	return mesh_instance


func _make_visual_box_child_rotated(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3,
	casts_shadow: bool
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.position = position_value
	mesh_instance.rotation = rotation_value
	mesh_instance.mesh = _get_visual_box_mesh(size, material)
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	parent.add_child(mesh_instance)
	return mesh_instance


func _make_tapered_post_child(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	height: float,
	material: Material,
	casts_shadow: bool
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.position = position_value
	mesh_instance.mesh = _get_visual_cylinder_mesh(0.14, 0.045, height, material)
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if casts_shadow
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	parent.add_child(mesh_instance)
	return mesh_instance


func _get_visual_box_mesh(size: Vector3, material: Material) -> BoxMesh:
	var key := "%s:%s" % [material.get_instance_id(), size]
	if not _visual_box_cache.has(key):
		var mesh := BoxMesh.new()
		mesh.size = size
		mesh.material = material
		_visual_box_cache[key] = mesh
	return _visual_box_cache[key] as BoxMesh


func _get_visual_cylinder_mesh(top_radius: float, bottom_radius: float, height: float, material: Material) -> CylinderMesh:
	var key := "%s:%.3f:%.3f:%.3f" % [material.get_instance_id(), top_radius, bottom_radius, height]
	if not _visual_cylinder_cache.has(key):
		var mesh := CylinderMesh.new()
		mesh.top_radius = top_radius
		mesh.bottom_radius = bottom_radius
		mesh.height = height
		mesh.radial_segments = 8
		mesh.material = material
		_visual_cylinder_cache[key] = mesh
	return _visual_cylinder_cache[key] as CylinderMesh


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
		for entry_variant in group["entries"] as Array:
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


func _collect_external_surfaces(node: Node, parent_transform: Transform3D, surface_groups: Dictionary) -> void:
	var accumulated_transform := parent_transform
	if node is Node3D:
		accumulated_transform = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var source_mesh := mesh_instance.mesh
		if source_mesh != null:
			for surface_index in range(source_mesh.get_surface_count()):
				var surface_material := mesh_instance.get_active_material(surface_index)
				var material_key := str(surface_material.get_instance_id()) if surface_material != null else "no_material"
				if not surface_groups.has(material_key):
					surface_groups[material_key] = {"material": surface_material, "entries": []}
				(surface_groups[material_key]["entries"] as Array).append({
					"mesh": source_mesh,
					"surface_index": surface_index,
					"transform": accumulated_transform
				})
	for child in node.get_children():
		_collect_external_surfaces(child, accumulated_transform, surface_groups)


func _make_collision_box(
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	yaw: float = 0.0
) -> void:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	body.rotation.y = yaw
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)


func _make_cylinder(
	name_value: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material
) -> void:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	add_child(body)
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.85
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.material = material
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)


func _material(
	tint: Color,
	roughness: float,
	texture: Texture2D,
	uv_scale: float
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.albedo_texture = texture
	material.roughness = roughness
	material.uv1_scale = Vector3.ONE * uv_scale
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _solid_material(tint: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = roughness
	if tint.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material
