class_name Lesson2CityEnvironment
extends Node3D

const HOUSE_A := preload("res://assets/generated/ancient_greek/architecture/GreekHouse_A.glb")
const HOUSE_B := preload("res://assets/generated/ancient_greek/architecture/GreekHouse_B.glb")
const WORKSHOP := preload("res://assets/generated/ancient_greek/architecture/GreekWorkshop.glb")
const TEMPLE := preload("res://assets/generated/ancient_greek/architecture/GreekTemple.glb")
const STALL := preload("res://assets/generated/ancient_greek/architecture/MarketStall.glb")
const ROAD := preload("res://assets/generated/ancient_greek/environment/StoneRoad_Straight.glb")
const PLAZA := preload("res://assets/generated/ancient_greek/environment/StonePlaza.glb")
const WALL := preload("res://assets/generated/ancient_greek/environment/StoneWall_Straight.glb")
const LOW_WALL := preload("res://assets/generated/ancient_greek/environment/LowStoneWall.glb")
const AMPHORA_A := preload("res://assets/generated/ancient_greek/props/Amphora_A.glb")
const AMPHORA_B := preload("res://assets/generated/ancient_greek/props/Amphora_B.glb")
const BASKET := preload("res://assets/generated/ancient_greek/props/Basket.glb")
const CRATE := preload("res://assets/generated/ancient_greek/props/WoodCrate.glb")
const TABLE := preload("res://assets/generated/ancient_greek/props/WoodTable.glb")
const BENCH := preload("res://assets/generated/ancient_greek/props/StoneBench.glb")
const SPOT_SCRIPT := preload("res://scripts/interaction/lesson2_interaction_spot.gd")

# The three belief destinations share one readable temple-front row. Keeping
# this just in front of the temple facade makes every socket reachable from the
# forecourt instead of burying its Area3D inside the temple's collision volume.
const BELIEF_PLINTH_Z := -31.75

var _earth: StandardMaterial3D
var _stone: StandardMaterial3D
var _marble: StandardMaterial3D
var _wood: StandardMaterial3D
var _bronze: StandardMaterial3D
var _water: StandardMaterial3D
var _wool: StandardMaterial3D
var _animal_hide: StandardMaterial3D
var _leaf: StandardMaterial3D
var _plaster: StandardMaterial3D
var _terracotta: StandardMaterial3D
var _paint_red: StandardMaterial3D
var _paint_blue: StandardMaterial3D
var _ochre: StandardMaterial3D
var _crop_gold: StandardMaterial3D
var _vine: StandardMaterial3D
var _charcoal: StandardMaterial3D
var _linen: StandardMaterial3D
var _fire: StandardMaterial3D
var _mechanisms: Dictionary = {}
var _mechanism_tweens: Dictionary = {}
var _merged_scene_mesh_cache: Dictionary = {}


func _ready() -> void:
	_create_materials()
	_build_continuous_city()
	_build_activity_landmarks()
	_build_street_and_district_details()
	_build_boundary_silhouette()
	_build_dressing()
	_build_mission_props()
	_build_interaction_spots()


func _create_materials() -> void:
	_earth = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/packed_earth_v2.png",
		Color(0.82, 0.66, 0.44), 0.94
	)
	_stone = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/worn_limestone_v2.png",
		Color(0.86, 0.82, 0.68), 0.88
	)
	_marble = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/marble_surface.png",
		Color(0.94, 0.91, 0.79), 0.78
	)
	_wood = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_olive_wood_v2.png",
		Color(0.48, 0.29, 0.16), 0.9
	)
	_bronze = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/bronze_surface.png",
		Color(0.52, 0.32, 0.12), 0.58
	)
	_bronze.metallic = 0.58
	_water = StandardMaterial3D.new()
	_water.albedo_color = Color(0.055, 0.28, 0.38, 0.92)
	_water.metallic = 0.12
	_water.roughness = 0.28
	_water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_wool = StandardMaterial3D.new()
	_wool.albedo_color = Color(0.86, 0.82, 0.69)
	_wool.roughness = 0.96
	_animal_hide = StandardMaterial3D.new()
	_animal_hide.albedo_color = Color(0.25, 0.13, 0.075)
	_animal_hide.roughness = 0.92
	_leaf = StandardMaterial3D.new()
	_leaf.albedo_color = Color(0.24, 0.34, 0.12)
	_leaf.roughness = 0.94
	_plaster = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/aged_plaster_v2.png",
		Color(0.88, 0.78, 0.61), 0.91
	)
	_terracotta = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/weathered_roof_tiles_v2.png",
		Color(0.62, 0.25, 0.12), 0.86
	)
	_paint_red = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/paint_red_surface.png",
		Color(0.66, 0.16, 0.11), 0.82
	)
	_paint_blue = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/paint_blue_surface.png",
		Color(0.12, 0.31, 0.43), 0.80
	)
	_ochre = StandardMaterial3D.new()
	_ochre.albedo_color = Color(0.72, 0.49, 0.20)
	_ochre.roughness = 0.90
	_crop_gold = StandardMaterial3D.new()
	_crop_gold.albedo_color = Color(0.68, 0.53, 0.18)
	_crop_gold.roughness = 0.97
	_vine = StandardMaterial3D.new()
	_vine.albedo_color = Color(0.22, 0.29, 0.08)
	_vine.roughness = 0.96
	_charcoal = StandardMaterial3D.new()
	_charcoal.albedo_color = Color(0.10, 0.075, 0.055)
	_charcoal.roughness = 0.98
	_linen = _textured_material(
		"res://assets/generated/ancient_greek/environment/surfaces/open_world/aged_linen_canvas_v2.png",
		Color(0.86, 0.76, 0.58), 0.94
	)
	_fire = StandardMaterial3D.new()
	_fire.albedo_color = Color(1.0, 0.46, 0.08)
	_fire.emission_enabled = true
	_fire.emission = Color(1.0, 0.20, 0.025)
	_fire.emission_energy_multiplier = 2.2
	_fire.roughness = 0.42


func _build_continuous_city() -> void:
	_make_box("Ground", Vector3(0, -0.35, -25), Vector3(76, 0.7, 112), _earth, true)
	# A single road spine and cross-streets connect every activity as one city.
	_make_box("MainRoad", Vector3(0, 0.015, -25), Vector3(7.5, 0.08, 105), _stone, false)
	for z in [15.0, -4.0, -24.0, -44.0, -65.0]:
		_make_box("CrossRoad", Vector3(0, 0.02, z), Vector3(56, 0.09, 5.8), _stone, false)
	# Physical walls and dressed gates replace invisible level edges.
	_make_box("WestWallCollision", Vector3(-38, 1.4, -25), Vector3(1.2, 2.8, 112), _stone, true)
	_make_box("EastWallCollision", Vector3(38, 1.4, -25), Vector3(1.2, 2.8, 112), _stone, true)
	_make_box("NorthWallCollision", Vector3(0, 1.4, 31), Vector3(76, 2.8, 1.2), _stone, true)
	_make_box("SouthWallCollision", Vector3(0, 1.4, -81), Vector3(76, 2.8, 1.2), _stone, true)
	# The long textured collision walls already form an unbroken boundary. Sparse
	# hero segments add authored detail without paying for dozens of 18-part GLBs.
	for z in range(-72, 25, 16):
		_instance(WALL, Vector3(-37.4, 0, float(z)), Vector3(0, PI * 0.5, 0))
		_instance(WALL, Vector3(37.4, 0, float(z)), Vector3(0, PI * 0.5, 0))
	for x in range(-32, 33, 16):
		_instance(WALL, Vector3(float(x), 0, 30.4), Vector3.ZERO)
		_instance(WALL, Vector3(float(x), 0, -80.4), Vector3.ZERO)
	# Residential frontage makes the long route read as a lived-in district.
	var homes := [
		[-18, 20, HOUSE_A, 0.05], [18, 20, HOUSE_B, -0.05],
		[-27, 10, HOUSE_B, 0.08], [27, 9, HOUSE_A, -0.08],
		[-27, -13, HOUSE_A, 0.06], [27, -18, HOUSE_B, -0.04],
		[-27, -35, HOUSE_B, 0.09], [27, -35, HOUSE_A, -0.07],
		[-28, -58, HOUSE_A, 0.04], [28, -57, HOUSE_B, -0.06],
		[-29, -73, HOUSE_B, 0.06], [29, -73, HOUSE_A, -0.05]
	]
	for home in homes:
		_instance(home[2], Vector3(home[0], 0, home[1]), Vector3(0, home[3], 0))
		_make_box("HouseCollision", Vector3(home[0], 2.0, home[1]), Vector3(7.3, 4.0, 6.2), _earth, true, false)


func _build_activity_landmarks() -> void:
	# Civic square.
	for x in [-5.5, 5.5]:
		for z in [15.5, 10.0]:
			_instance(PLAZA, Vector3(x, 0.02, z))
	_make_box("CivicDais", Vector3(0, 0.16, 12.5), Vector3(5.5, 0.32, 2.4), _marble, true)
	# Farm, press, workshop, market, and harbour visually trace one product route.
	_make_box("FarmBeds", Vector3(-16, 0.05, 0), Vector3(16, 0.1, 12), _earth, false)
	for x in [-21.0, -16.0, -11.0]:
		_make_box("CropRow", Vector3(x, 0.2, 0), Vector3(2.4, 0.4, 9.0), _wood, false)
	_instance(WORKSHOP, Vector3(15, 0, -2), Vector3(0, PI, 0))
	_make_box("WorkshopCollision", Vector3(15, 1.5, -2), Vector3(6.5, 3.0, 5.8), _earth, true, false)
	for x in [-9.0, -3.0, 3.0, 9.0]:
		_instance(STALL, Vector3(x, 0, -15), Vector3.ZERO)
	_make_box("HarbourWater", Vector3(27, 0.06, -7), Vector3(18, 0.08, 16), _water, false)
	_make_box("Quay", Vector3(18, 0.18, -7), Vector3(4, 0.36, 16), _stone, true)
	# The quay is deliberately substantial, so provide a broad side ramp for the
	# crate route instead of leaving a vertical ledge in the player's path.
	_make_access_ramp("QuayAccessRamp", Vector3(14.6, 0, -12.5), 2.8, 2.8, 0.36, _stone, -PI * 0.5)
	# The follow-the-cargo target sits offshore; a broad, collidable timber pier
	# gives it a believable and gap-free route instead of relying on the seabed.
	# Match its walking surface to the quay so the join has no step collision.
	_make_box("LoadingPier", Vector3(25.3, 0.18, -7), Vector3(11.0, 0.36, 2.7), _wood, true)
	for pier_x in [20.5, 23.0, 25.5, 28.0, 30.5]:
		_make_box("PierJoint", Vector3(pier_x, 0.375, -7), Vector3(0.08, 0.03, 2.62), _charcoal, false)
	# Society courtyard.
	_make_box("SocietyCourt", Vector3(15, 0.08, -26), Vector3(17, 0.16, 13), _stone, false)
	_instance(TABLE, Vector3(15, 0.1, -26))
	# Temple precinct.
	_instance(TEMPLE, Vector3(0, 0, -39), Vector3(0, PI, 0))
	_make_box("TempleCollision", Vector3(0, 2.6, -39), Vector3(13.2, 5.2, 14.0), _earth, true, false)
	# Theatre: orchestra circle, stage, actors' line and semicircular stepped seating.
	_make_cylinder("Orchestra", Vector3(-14, 0.08, -51), 5.4, 0.16, _stone, true)
	_make_box("TheatreStage", Vector3(-14, 0.45, -57), Vector3(11, 0.9, 3.0), _wood, true)
	for ring in range(4):
		var radius := 7.0 + ring * 1.55
		for index in range(11):
			var angle := lerpf(-2.72, -0.42, float(index) / 10.0)
			var pos := Vector3(-14 + cos(angle) * radius, 0.3 + ring * 0.33, -51 + sin(angle) * radius)
			_make_box("TheatreSeat", pos, Vector3(1.6, 0.5, 1.1), _stone, true)
	# Library and author-card exhibit.
	_instance(HOUSE_B, Vector3(15, 0, -51), Vector3(0, PI, 0))
	_make_box("LibraryCollision", Vector3(15, 2.0, -51), Vector3(7.4, 4.0, 6.9), _earth, true, false)
	for x in [11.5, 15.0, 18.5]:
		_instance(TABLE, Vector3(x, 0, -46.7), Vector3.ZERO, Vector3(0.65, 0.65, 0.65))
	# Sculptor/viewpoint.
	_make_box("Viewpoint", Vector3(0, 0.35, -61), Vector3(10, 0.7, 6), _marble, true)
	# A shallow stone ramp keeps the raised model court reachable without a jump.
	# It rises toward -Z and overlaps the platform edge slightly so there is no
	# collision seam at the landing.
	_make_access_ramp("ViewpointAccessRamp", Vector3(0, 0, -56.55), 3.8, 3.1, 0.7, _marble)
	_make_cylinder("MarbleStatue", Vector3(-2, 1.0, -63.1), 0.55, 2.0, _marble, true)
	_make_cylinder("BronzeStatue", Vector3(2, 1.0, -63.1), 0.55, 2.0, _bronze, true)
	# Sports yard and integrated running lane.
	_make_box("SportsYard", Vector3(-15, 0.04, -70), Vector3(23, 0.08, 14), _earth, false)
	for lane_x in [-22.0, -18.5, -15.0, -11.5, -8.0]:
		_make_box("Lane", Vector3(lane_x, 0.07, -70), Vector3(0.12, 0.03, 12), _stone, false)
	# Jordan archive is a source-bound exhibit/diorama, not a literal reconstruction.
	_make_box("JordanArchive", Vector3(16, 0.25, -69), Vector3(18, 0.5, 16), _stone, true)
	# The archive table is also raised. Give the marker-tray side a broad,
	# walkable approach instead of requiring the player to jump onto the slab.
	_make_access_ramp("JordanArchiveAccessRamp", Vector3(9.5, 0, -59.7), 4.2, 2.8, 0.5, _stone)
	_make_box("QasrAlAbdDiorama", Vector3(16, 1.1, -70), Vector3(7.0, 2.2, 5.0), _marble, false)
	for x in [13.2, 18.8]:
		for z in [-71.8, -68.2]:
			_make_cylinder("DioramaColumn", Vector3(x, 2.5, z), 0.32, 3.0, _stone, false)


func _build_street_and_district_details() -> void:
	_build_street_details()
	_dress_agora()
	_dress_farm()
	_dress_workshop_market_and_harbour()
	_dress_society_and_temple()
	_dress_theatre_library_and_viewpoint()
	_dress_sports_and_jordan()


func _build_street_details() -> void:
	# Slightly raised road shoulders and drains make the city spine feel laid by
	# hand without changing its reliable, flat traversal surface.
	for x in [-4.05, 4.05]:
		_make_box("RoadDrain", Vector3(x, 0.065, -25), Vector3(0.34, 0.05, 104), _charcoal, false)
		_make_box("RoadCurb", Vector3(x + sign(x) * 0.32, 0.11, -25), Vector3(0.30, 0.16, 104), _stone, false)
	for z in range(-75, 27, 5):
		_make_box("RoadJoint", Vector3(0, 0.072, float(z)), Vector3(7.35, 0.025, 0.075), _charcoal, false)
	# Narrow residential lanes terminate at doors and courtyards, visually tying
	# the homes to the main route instead of leaving them as isolated props.
	for lane_data in [
		[-18.0, 20.0, 22.0], [18.0, 20.0, 22.0],
		[-27.0, 9.0, 30.0], [27.0, 9.0, 30.0],
		[-27.0, -13.0, 30.0], [27.0, -18.0, 30.0],
		[-27.0, -35.0, 30.0], [27.0, -35.0, 30.0],
		[-28.0, -58.0, 31.0], [28.0, -57.0, 31.0],
		[-29.0, -73.0, 32.0], [29.0, -73.0, 32.0],
	]:
		var lane_x := float(lane_data[0]) * 0.52
		var lane_width := float(lane_data[2])
		_make_box("ResidentialLane", Vector3(lane_x, 0.047, float(lane_data[1])), Vector3(lane_width, 0.035, 1.65), _stone, false)
	# Corner stones make the five cross streets legible from the long sightline.
	for z in [15.0, -4.0, -24.0, -44.0, -65.0]:
		for x in [-4.75, 4.75]:
			_make_box("CornerStone", Vector3(x, 0.13, z - 2.45), Vector3(1.0, 0.18, 0.50), _marble, false)
			_make_box("CornerStone", Vector3(x, 0.13, z + 2.45), Vector3(1.0, 0.18, 0.50), _marble, false)


func _dress_agora() -> void:
	# A colonnaded edge and civic banners frame the spawn plaza while keeping the
	# centre open for the four tablet routes and the final ceremony.
	for x in [-9.0, -6.0, 6.0, 9.0]:
		_make_column(Vector3(x, 0, 20.5), 2.8, _stone)
	_make_box("AgoraLintelWest", Vector3(-7.5, 2.82, 20.5), Vector3(4.9, 0.32, 0.55), _stone, false)
	_make_box("AgoraLintelEast", Vector3(7.5, 2.82, 20.5), Vector3(4.9, 0.32, 0.55), _stone, false)
	for banner_data in [[-7.5, _paint_red], [7.5, _paint_blue]]:
		_make_box("CivicBanner", Vector3(float(banner_data[0]), 2.0, 20.28), Vector3(1.05, 1.35, 0.08), banner_data[1], false)
	for pos in [Vector3(-9.0, 0, 12.5), Vector3(9.0, 0, 12.5), Vector3(-9.0, 0, 16.5), Vector3(9.0, 0, 16.5)]:
		_make_brazier(pos, false)
	# Low civic notice slabs add scale without competing with interaction tablets.
	for x in [-10.8, 10.8]:
		_make_box("AgoraNoticeBase", Vector3(x, 0.35, 15.0), Vector3(1.8, 0.70, 1.2), _stone, false)
		_make_box("AgoraNoticePanel", Vector3(x, 1.28, 15.0), Vector3(1.35, 1.15, 0.22), _marble, false)


func _dress_farm() -> void:
	# Three visibly different crop bands support the grain/olive/grape activity.
	for x in [-22.0, -20.5]:
		for z in [-3.1, -1.3, 0.5, 2.3, 4.1]:
			_make_crop_clump(Vector3(x, 0.22, z), _crop_gold, 0.78)
	# Vineyard trellises sit beside, not across, the playable collection route.
	for z in [-3.5, -0.8, 1.9, 4.6]:
		_make_box("VinePost", Vector3(-12.5, 0.82, z), Vector3(0.12, 1.64, 0.12), _wood, false)
		_make_box("VinePost", Vector3(-10.0, 0.82, z), Vector3(0.12, 1.64, 0.12), _wood, false)
		_make_box("VineRail", Vector3(-11.25, 1.32, z), Vector3(2.62, 0.10, 0.10), _wood, false)
		for x in [-12.0, -11.2, -10.4]:
			_make_sphere("VineLeaves", Vector3(x, 1.18, z), Vector3(0.52, 0.40, 0.38), _vine, 8)
	# Irrigation channel and tools sell the edge as a maintained working farm.
	_make_box("IrrigationChannel", Vector3(-24.3, 0.06, 0.0), Vector3(0.55, 0.10, 11.0), _charcoal, false)
	_make_box("WaterTrough", Vector3(-26.0, 0.35, 5.0), Vector3(2.4, 0.70, 1.15), _stone, false)
	_make_box("TroughWater", Vector3(-26.0, 0.71, 5.0), Vector3(2.05, 0.04, 0.78), _water, false)
	_make_tool_rack(Vector3(-17.8, 0, 5.2), 0.0)
	for z in [-5.4, 5.5]:
		_make_box("FarmBoundaryWall", Vector3(-18.0, 0.42, z), Vector3(9.0, 0.84, 0.42), _stone, false)


func _dress_workshop_market_and_harbour() -> void:
	# Workshop yard: a kiln, timber rack, cooling basin and tool silhouettes.
	_make_cylinder("WorkshopKiln", Vector3(22.0, 0.85, -1.0), 1.15, 1.70, _terracotta, false)
	_make_sphere("KilnDome", Vector3(22.0, 1.72, -1.0), Vector3(1.17, 0.72, 1.17), _terracotta, 10)
	_make_box("KilnMouth", Vector3(20.84, 0.62, -1.0), Vector3(0.08, 0.72, 0.64), _charcoal, false)
	_make_timber_stack(Vector3(10.3, 0, 1.7), PI * 0.5)
	_make_box("WorkshopBasin", Vector3(20.8, 0.28, -4.2), Vector3(1.7, 0.56, 1.2), _stone, false)
	_make_box("WorkshopBasinWater", Vector3(20.8, 0.57, -4.2), Vector3(1.4, 0.03, 0.9), _water, false)
	_make_tool_rack(Vector3(11.0, 0, -0.4), PI * 0.5)
	# Cloth shade, produce tables and pottery clusters unify the market frontage.
	for stall_x in [-9.0, -3.0, 3.0, 9.0]:
		var cloth_material: Material = _paint_red if int(stall_x) % 2 != 0 else _ochre
		_make_box("MarketRunner", Vector3(stall_x, 1.58, -14.25), Vector3(3.0, 0.06, 1.3), cloth_material, false)
		for jar_x in [-0.55, 0.0, 0.55]:
			_make_simple_amphora(Vector3(stall_x + jar_x, 0, -12.8), 0.55, _terracotta if jar_x == 0.0 else _ochre)
	_make_box("MarketShadeLine", Vector3(0, 2.65, -13.8), Vector3(19.0, 0.06, 0.06), _wood, false)
	for x in [-8.0, -4.0, 0.0, 4.0, 8.0]:
		_make_box("MarketPennant", Vector3(x, 2.35, -13.78), Vector3(0.62, 0.48, 0.04), _paint_blue if int(x) % 8 == 0 else _paint_red, false)
	# Harbour furniture establishes an actual loading edge and preserves the clear
	# approach to the drop and follow spots.
	for z in [-13.0, -9.0, -5.0, -1.0]:
		_make_bollard(Vector3(19.25, 0.38, z))
	_make_box("QuayWarehouse", Vector3(31.7, 1.7, 1.0), Vector3(8.0, 3.4, 5.0), _plaster, true)
	_make_box("QuayWarehouseRoof", Vector3(31.7, 3.55, 1.0), Vector3(8.5, 0.36, 5.5), _terracotta, false)
	_make_box("WarehouseDoor", Vector3(27.66, 1.05, 1.0), Vector3(0.08, 2.1, 1.65), _wood, false)
	var harbour_crane := _make_crane(Vector3(23.2, 0.2, -12.7))
	_mechanisms["trade_harbour_drop"] = harbour_crane
	_mechanisms["trade_dock_follow"] = harbour_crane
	_make_timber_stack(Vector3(23.5, 0.2, -2.0), 0.0)


func _dress_society_and_temple() -> void:
	# Archive court furniture makes the social records read as a working civic
	# space. All pieces remain outside the central circulation loop.
	for z in [-30.8, -21.2]:
		for x in [8.0, 22.0]:
			_make_column(Vector3(x, 0.1, z), 2.45, _stone)
	_make_box("ArchiveLintelWest", Vector3(8.0, 2.62, -26.0), Vector3(0.45, 0.30, 10.0), _stone, false)
	_make_box("ArchiveLintelEast", Vector3(22.0, 2.62, -26.0), Vector3(0.45, 0.30, 10.0), _stone, false)
	_make_scroll_rack(Vector3(22.6, 0.1, -26.0), PI * 0.5)
	_make_scroll_rack(Vector3(15.0, 0.1, -31.6), 0.0)
	for pos in [Vector3(9.0, 0.0, -22.0), Vector3(21.0, 0.0, -30.0)]:
		_make_brazier(pos, false)
	# Temple forecourt with an axial approach, offering tables and cypress trees.
	_make_box("TempleProcessionalPath", Vector3(0, 0.075, -31.5), Vector3(5.4, 0.055, 8.0), _marble, false)
	for x in [-8.5, 8.5]:
		_make_column(Vector3(x, 0.0, -32.5), 2.9, _stone)
		_make_cypress(Vector3(x, 0, -39.0), 3.8)
	_make_box("TempleOfferingTableWest", Vector3(-7.0, 0.75, -35.0), Vector3(2.2, 1.5, 1.2), _marble, false)
	_make_box("TempleOfferingTableEast", Vector3(7.0, 0.75, -35.0), Vector3(2.2, 1.5, 1.2), _marble, false)
	for x in [-3.8, 3.8]:
		_make_brazier(Vector3(x, 0.0, -33.8), true)
	_build_deity_forecourt()


func _build_deity_forecourt() -> void:
	# The textbook triad is presented as one intentional exhibit rather than as
	# floating quest text. Apollo owns the centre and is slightly taller so the
	# missing middle destination remains unmistakable behind the temple guide.
	var deity_displays := [
		["belief_zeus_plinth", "zeus", Vector3(-5.0, 0.0, BELIEF_PLINTH_Z), "زيوس", "الإله الرئيس"],
		["belief_apollo_plinth", "apollo", Vector3(0.0, 0.0, BELIEF_PLINTH_Z), "أبولو", "إله الشمس"],
		["belief_athena_plinth", "athena", Vector3(5.0, 0.0, BELIEF_PLINTH_Z), "أثينا", "إلهة الحكمة"],
	]
	for display_data in deity_displays:
		_make_deity_plinth(
			str(display_data[0]), str(display_data[1]), display_data[2] as Vector3,
			str(display_data[3]), str(display_data[4])
		)


func _dress_theatre_library_and_viewpoint() -> void:
	# Theatre wing flats, painted cloth and mask stands give the stage a readable
	# rehearsal identity while its centre remains open for gameplay.
	_make_box("TheatreStageBack", Vector3(-14, 2.1, -58.1), Vector3(11.5, 3.3, 0.35), _plaster, false)
	for x in [-18.6, -14.0, -9.4]:
		_make_column(Vector3(x, 0.9, -57.7), 2.6, _stone)
	_make_box("TheatreFrieze", Vector3(-14, 3.62, -57.7), Vector3(11.3, 0.36, 0.55), _paint_red, false)
	var curtain := _make_box("TheatreCurtain", Vector3(-14, 2.18, -57.45), Vector3(3.4, 2.2, 0.10), _paint_blue, false)
	curtain.scale.y = 0.12
	_mechanisms["theatre_curtain"] = curtain
	_mechanisms["theatre_orchestra"] = curtain
	_mechanisms["theatre_stage"] = curtain
	_make_mask_stand(Vector3(-18.2, 0.9, -55.8), true)
	_make_mask_stand(Vector3(-9.8, 0.9, -55.8), false)
	for pos in [Vector3(-22.7, 0.1, -48.0), Vector3(-5.3, 0.1, -48.0)]:
		_make_brazier(pos, false)
	# Library forecourt: scroll cabinets and a blue linen canopy focus attention
	# on the three thinker desks.
	_make_box("LibraryCanopy", Vector3(15.0, 2.65, -46.8), Vector3(10.0, 0.09, 3.0), _paint_blue, false)
	for x in [10.4, 19.6]:
		_make_box("LibraryCanopyPost", Vector3(x, 1.35, -46.8), Vector3(0.14, 2.7, 0.14), _wood, false)
	_make_scroll_rack(Vector3(9.2, 0.0, -49.0), PI * 0.5)
	_make_scroll_rack(Vector3(20.8, 0.0, -49.0), -PI * 0.5)
	# A physical model table and scaffold turn the architecture viewpoint into a
	# workshop rather than two disconnected statue cylinders.
	_make_box("CityModelTable", Vector3(0, 0.92, -58.1), Vector3(6.3, 0.28, 3.2), _wood, false)
	var model := Node3D.new()
	model.name = "CityModelReveal"
	model.position = Vector3(0, 1.1, -58.1)
	add_child(model)
	_add_box_to(model, "ModelWall", Vector3(0, 0.28, -1.05), Vector3(5.3, 0.55, 0.25), _stone)
	_add_box_to(model, "ModelAgora", Vector3(-1.5, 0.12, 0.25), Vector3(1.6, 0.24, 1.1), _marble)
	_add_box_to(model, "ModelTemple", Vector3(0.55, 0.32, 0.15), Vector3(1.5, 0.64, 1.2), _plaster)
	_add_box_to(model, "ModelTheatre", Vector3(2.0, 0.18, 0.35), Vector3(0.9, 0.36, 1.35), _terracotta)
	model.scale = Vector3(0.06, 0.06, 0.06)
	_mechanisms["city_model"] = model
	_mechanisms["arch_model"] = model
	_make_scaffold(Vector3(5.0, 0.0, -61.0))


func _dress_sports_and_jordan() -> void:
	# Starting posts, boundary rope and training equipment give the course an
	# athletic identity without putting collision into the running line.
	for z in [-76.1, -63.9]:
		_make_box("SportsBoundary", Vector3(-15, 0.35, z), Vector3(23.2, 0.08, 0.08), _linen, false)
		for x in [-26.3, -3.7]:
			_make_box("SportsBoundaryPost", Vector3(x, 0.48, z), Vector3(0.15, 0.96, 0.15), _wood, false)
	for x in [-22.0, -18.5, -15.0, -11.5, -8.0]:
		_make_box("StartingBlock", Vector3(x, 0.16, -75.3), Vector3(0.75, 0.30, 0.45), _stone, false)
	_make_box("TrainingSandPit", Vector3(-27.8, 0.09, -69.6), Vector3(2.2, 0.08, 6.8), _ochre, false)
	_make_timber_stack(Vector3(-4.8, 0, -68.5), PI * 0.5)
	# The Jordan exhibit is explicitly framed as a later-period learning display.
	# Open linen shade bands frame the archive without turning the playable
	# exhibit into a dark, low-ceilinged room for the third-person camera.
	for shade_data in [[-74.8, _linen], [-69.0, _paint_blue], [-63.2, _linen]]:
		var shade_material: Material = shade_data[1]
		_make_box("JordanCanopyShade", Vector3(16, 4.15, float(shade_data[0])), Vector3(19.0, 0.12, 2.5), shade_material, false)
	_make_box("JordanCanopyBeamWest", Vector3(7.3, 4.02, -69), Vector3(0.22, 0.22, 16.2), _wood, false)
	_make_box("JordanCanopyBeamEast", Vector3(24.7, 4.02, -69), Vector3(0.22, 0.22, 16.2), _wood, false)
	for x in [7.3, 24.7]:
		for z in [-76.7, -61.3]:
			_make_column(Vector3(x, 0.45, z), 3.7, _stone)
	_make_box("JordanExhibitBorderNorth", Vector3(16, 0.58, -61.2), Vector3(18.4, 0.65, 0.45), _bronze, false)
	_make_box("JordanExhibitBorderSouth", Vector3(16, 0.58, -76.8), Vector3(18.4, 0.65, 0.45), _bronze, false)
	_make_box("JordanExhibitBorderWest", Vector3(6.9, 0.58, -69), Vector3(0.45, 0.65, 16.0), _bronze, false)
	_make_box("JordanExhibitBorderEast", Vector3(25.1, 0.58, -69), Vector3(0.45, 0.65, 16.0), _bronze, false)
	_make_box("JordanPeriodPlaque", Vector3(16, 2.0, -76.45), Vector3(7.2, 1.15, 0.18), _marble, false)
	_make_brazier(Vector3(8.4, 0.5, -62.5), false)
	_make_brazier(Vector3(23.6, 0.5, -62.5), false)


func _build_boundary_silhouette() -> void:
	# Gate towers make the real colliders feel intentional and leave the central
	# road unobstructed. Distant landforms break the hard rectangular skyline.
	for gate_z in [29.5, -79.5]:
		for x in [-6.2, 6.2]:
			_make_box("GateTower", Vector3(x, 2.25, gate_z), Vector3(4.3, 4.5, 3.4), _stone, false)
			_make_box("GateTowerCap", Vector3(x, 4.68, gate_z), Vector3(4.8, 0.38, 3.9), _terracotta, false)
		_make_box("GateLintel", Vector3(0, 4.35, gate_z), Vector3(8.2, 0.55, 1.15), _stone, false)
	for z in [-71.0, -55.0, -39.0, -23.0, -7.0, 9.0, 24.0]:
		_make_cypress(Vector3(-35.2, 0, z), 4.2 + fposmod(abs(z), 1.3))
		_make_cypress(Vector3(35.2, 0, z + 4.0), 4.0 + fposmod(abs(z), 1.1))
	# Exterior hills are purely scenery beyond the physical city walls.
	for hill_data in [
		[-45.0, -70.0, 10.0, 5.0], [-47.0, -45.0, 12.0, 6.0], [-45.0, -15.0, 9.0, 4.5],
		[45.0, -60.0, 11.0, 5.5], [48.0, -30.0, 14.0, 6.0], [45.0, 5.0, 10.0, 5.0],
	]:
		_make_sphere("DistantHill", Vector3(float(hill_data[0]), 1.2, float(hill_data[1])), Vector3(float(hill_data[2]), float(hill_data[3]), 8.0), _earth, 8)
	# Boundary-side facade strips hide repetitive wall runs but are inaccessible.
	for z in [-66.0, -48.0, -28.0, -8.0, 12.0]:
		_make_boundary_house(Vector3(-33.6, 0, z), true, int(abs(z)) % 2 == 0)
		_make_boundary_house(Vector3(33.6, 0, z + 7.0), false, int(abs(z)) % 2 != 0)


func _build_dressing() -> void:
	for pos in [Vector3(-20, 0, -5), Vector3(-16, 0, -5), Vector3(-7, 0, -13), Vector3(8, 0, -13), Vector3(21, 0.2, -7)]:
		_instance(BASKET, pos)
	for pos in [Vector3(12, 0, -5), Vector3(18, 0, -5), Vector3(20, 0.2, -11), Vector3(22, 0.2, -3)]:
		_instance(CRATE, pos)
	for pos in [Vector3(-5, 0, 10), Vector3(5, 0, 10), Vector3(-6, 0, -37), Vector3(6, 0, -37), Vector3(9, 0.5, -66), Vector3(23, 0.5, -66)]:
		_instance(BENCH, pos)
	for pos in [Vector3(12, 0, -14), Vector3(14, 0, -14), Vector3(19, 0.2, -6), Vector3(17.5, 0, -25)]:
		_instance(AMPHORA_A if int(pos.x) % 2 == 0 else AMPHORA_B, pos)
	# Livestock and orchard silhouettes make the agricultural edge readable as
	# a working district rather than three abstract crop boxes.
	_make_livestock("SheepA", Vector3(-28, 0, 3), false, 0.2)
	_make_livestock("SheepB", Vector3(-25.5, 0, -1), false, -0.7)
	_make_livestock("Cattle", Vector3(-29, 0, -5), true, 0.8)
	for pos in [Vector3(-19, 0, 3), Vector3(-16, 0, 3), Vector3(-13, 0, 3)]:
		_make_orchard_tree(pos)
	# Two small unreachable boat silhouettes make the external-trade destination
	# visible while the collidable quay remains the safe playable edge.
	_make_harbour_boat(Vector3(28, 0.12, -3), -0.10)
	_make_harbour_boat(Vector3(31, 0.10, -11), 0.16)
	for label_data in [
		[Vector3(0, 2.2, 18), "الساحة العامة"], [Vector3(-16, 2.0, 5), "الزراعة"],
		[Vector3(15, 2.4, 2), "الورشة"], [Vector3(0, 2.0, -12), "السوق والمرفأ"],
		[Vector3(15, 2.0, -24), "المجتمع"], [Vector3(0, 4.8, -32), "المعبد"],
		[Vector3(-14, 2.0, -45), "المسرح"], [Vector3(15, 2.2, -46), "المكتبة"],
		[Vector3(-15, 2.0, -64), "ساحة الرياضة"], [Vector3(16, 3.6, -69), "آثار الأردن — مجسّم تعليمي"]
	]:
		_make_label(label_data[0], label_data[1])


func _build_mission_props() -> void:
	# Civic tablets and the final seven-emblem board are physical world objects.
	var civic_sources := [
		["politics_monarchy", -6.0, 12.0], ["politics_athens", 6.0, 12.0],
		["politics_sparta", -6.0, 17.0], ["politics_despotism", 6.0, 17.0],
	]
	for source_data in civic_sources:
		var civic_tablet := _make_box(
			"CivicTablet", Vector3(float(source_data[1]), 0.38, float(source_data[2])),
			Vector3(1.1, 0.16, 0.75), _bronze, false
		)
		_mechanisms[str(source_data[0])] = civic_tablet
	_make_box("FinalEmblemBoard", Vector3(0, 0.75, 9.5), Vector3(6.6, 1.5, 0.35), _wood, true)
	var emblem_names := ["Politics", "Economy", "Society", "Beliefs", "Culture", "Sport", "Heritage"]
	var emblem_colors := [
		Color(0.33, 0.53, 0.78), Color(0.76, 0.52, 0.20), Color(0.47, 0.66, 0.42),
		Color(0.62, 0.45, 0.72), Color(0.78, 0.35, 0.28), Color(0.25, 0.66, 0.68),
		Color(0.86, 0.72, 0.30),
	]
	for index in emblem_names.size():
		var emblem := MeshInstance3D.new()
		emblem.name = "Emblem" + emblem_names[index]
		emblem.position = Vector3(-2.7 + index * 0.9, 0.82, 9.72)
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.28
		mesh.bottom_radius = 0.28
		mesh.height = 0.10
		mesh.radial_segments = 20
		var emblem_material := StandardMaterial3D.new()
		emblem_material.albedo_color = emblem_colors[index]
		emblem_material.metallic = 0.28
		emblem_material.roughness = 0.52
		mesh.material = emblem_material
		emblem.mesh = mesh
		emblem.rotation.x = PI * 0.5
		emblem.visible = false
		add_child(emblem)
	# Processing stations, workshop materials, archive tablets and temple symbols.
	_make_cylinder("GrainMill", Vector3(-22, 0.65, -5), 1.0, 1.3, _stone, true)
	_make_box("OlivePress", Vector3(-15, 0.65, -5), Vector3(3.2, 1.3, 2.2), _wood, true)
	var mill_mechanism := Node3D.new()
	mill_mechanism.name = "GrainMillMechanism"
	mill_mechanism.position = Vector3(-22, 1.35, -5)
	add_child(mill_mechanism)
	_add_cylinder_to(mill_mechanism, "TurningStone", Vector3(0, 0.18, 0), 0.82, 0.36, _marble, 20)
	_add_box_to(mill_mechanism, "MillHandle", Vector3(0.9, 0.55, 0), Vector3(1.8, 0.13, 0.13), _wood)
	_add_box_to(mill_mechanism, "HandleGrip", Vector3(1.72, 0.86, 0), Vector3(0.14, 0.72, 0.14), _wood)
	_mechanisms["farm_mill"] = mill_mechanism
	var press_mechanism := Node3D.new()
	press_mechanism.name = "OlivePressMechanism"
	press_mechanism.position = Vector3(-15, 1.28, -5)
	add_child(press_mechanism)
	_add_box_to(press_mechanism, "PressUprightLeft", Vector3(-1.18, 1.05, 0), Vector3(0.22, 2.10, 0.22), _wood)
	_add_box_to(press_mechanism, "PressUprightRight", Vector3(1.18, 1.05, 0), Vector3(0.22, 2.10, 0.22), _wood)
	var press_beam := _add_box_to(press_mechanism, "PressBeam", Vector3(0, 1.70, 0), Vector3(2.7, 0.24, 0.35), _wood)
	_add_cylinder_to(press_mechanism, "OliveBasket", Vector3(0, 0.24, 0), 0.65, 0.35, _terracotta, 16)
	_mechanisms["farm_press"] = press_beam
	var workshop_sources := [
		["industry_wood", Vector3(11, 0.45, -5), _wood],
		["industry_metal", Vector3(15, 0.45, -5), _bronze],
		["industry_clay", Vector3(19, 0.45, -5), _earth],
	]
	for source_data in workshop_sources:
		var source_material: Material = source_data[2]
		var workshop_material := _make_box(
			"WorkshopMaterial", source_data[1] as Vector3, Vector3(1.1, 0.9, 1.1), source_material, false
		)
		_mechanisms[str(source_data[0])] = workshop_material
	var local_trade_crate := _make_box("TradeLocalCrateVisual", Vector3(-7, 0.43, -14), Vector3(0.95, 0.86, 0.95), _wood, false)
	var overseas_trade_crate := _make_box("TradeExternalCrateVisual", Vector3(7, 0.43, -14), Vector3(0.95, 0.86, 0.95), _wood, false)
	_mechanisms["trade_local_crate"] = local_trade_crate
	_mechanisms["trade_external_crate"] = overseas_trade_crate
	var society_display := Node3D.new()
	society_display.name = "SocietyDisplayReveal"
	society_display.position = Vector3(15, 0.32, -23.8)
	add_child(society_display)
	for layer in range(4):
		_add_box_to(
			society_display,
			"SocietyTier%d" % layer,
			Vector3(0, 0.22 + layer * 0.34, 0),
			Vector3(4.4 - layer * 0.72, 0.25, 1.0),
			_stone if layer < 2 else _marble
		)
	society_display.scale = Vector3(0.06, 0.06, 0.06)
	_mechanisms["society_display"] = society_display
	# Keep the portable symbols distinct from their destinations. Apollo is
	# forward on the centre axis instead of hidden directly behind TempleGuide.
	var belief_sources := [
		["belief_zeus", "zeus", Vector3(-8.0, 0.45, -28.0)],
		["belief_apollo", "apollo", Vector3(0.0, 0.45, -26.8)],
		["belief_athena", "athena", Vector3(8.0, 0.45, -28.0)],
	]
	for source_data in belief_sources:
		_make_belief_token(str(source_data[0]), str(source_data[1]), source_data[2] as Vector3)
	var chorus_prop := _make_mask_stand(Vector3(-18, 0, -50), false)
	chorus_prop.name = "TheatreChorusProp"
	chorus_prop.scale = Vector3(0.72, 0.72, 0.72)
	_mechanisms["theatre_chorus"] = chorus_prop
	var thinker_sources := [
		["ideas_plato", Vector3(11, 0.35, -45)],
		["ideas_aristotle", Vector3(15, 0.35, -45)],
		["ideas_herodotus", Vector3(19, 0.35, -45)],
	]
	for source_data in thinker_sources:
		var thinker_tablet := _make_box(
			"ThinkerTablet", source_data[1] as Vector3, Vector3(1.2, 0.18, 0.8), _marble, false
		)
		_mechanisms[str(source_data[0])] = thinker_tablet
	var architecture_sources := [
		["arch_wall", Vector3(-4, 0.88, -61), Vector3(0.85, 0.36, 0.52), _stone],
		["arch_agora", Vector3(-2, 0.84, -61), Vector3(0.92, 0.22, 0.72), _marble],
		["arch_temple", Vector3(2, 0.93, -61), Vector3(0.92, 0.52, 0.72), _plaster],
		["arch_theatre", Vector3(4, 0.88, -61), Vector3(0.92, 0.36, 0.72), _terracotta],
	]
	for source_data in architecture_sources:
		var piece_material: Material = source_data[3]
		var model_piece := _make_box(
			"ArchitectureModelPiece", source_data[1] as Vector3, source_data[2] as Vector3, piece_material, false
		)
		_mechanisms[str(source_data[0])] = model_piece
	_make_box("JordanMapTable", Vector3(16, 1.0, -64), Vector3(11.0, 0.35, 5.0), _wood, true)
	var jordan_surface := _make_box("JordanMapReveal", Vector3(16, 1.195, -64), Vector3(10.3, 0.06, 4.3), _paint_blue, false)
	_mechanisms["jordan_map"] = jordan_surface
	var marker_tray := _make_box("JordanMarkerTray", Vector3(9.0, 0.78, -67.5), Vector3(2.6, 0.28, 1.5), _wood, false)
	_mechanisms["jordan_marker_tray"] = marker_tray
	_make_box("JordanMarkerTrayInset", Vector3(9.0, 0.94, -67.5), Vector3(2.2, 0.05, 1.1), _bronze, false)
	for marker_index in range(5):
		_make_cylinder("JordanTrayToken", Vector3(8.25 + marker_index * 0.37, 1.05, -67.5), 0.12, 0.08, _marble, false)
	var jordan_markers := [
		["Amman", 11.0, "عمّان / فيلادلفيا"], ["Pella", 13.5, "طبقة فحل / بيلا"],
		["Gadara", 16.0, "أم قيس / جدارا"], ["Gerasa", 18.5, "جرش / جراسا"],
		["Heshbon", 21.0, "حسبان / حشبون"],
	]
	for marker_data in jordan_markers:
		var marker := MeshInstance3D.new()
		marker.name = "JordanMap" + str(marker_data[0])
		marker.position = Vector3(float(marker_data[1]), 1.26, -64)
		var marker_mesh := CylinderMesh.new()
		marker_mesh.top_radius = 0.32
		marker_mesh.bottom_radius = 0.32
		marker_mesh.height = 0.12
		marker_mesh.radial_segments = 18
		var marker_material := StandardMaterial3D.new()
		marker_material.albedo_color = Color(0.20, 0.82, 0.92)
		marker_material.emission_enabled = true
		marker_material.emission = Color(0.08, 0.48, 0.62)
		marker_material.emission_energy_multiplier = 1.5
		marker_mesh.material = marker_material
		marker.mesh = marker_mesh
		marker.visible = false
		add_child(marker)
		var marker_label := Label3D.new()
		marker_label.name = marker.name + "Label"
		marker_label.position = Vector3(float(marker_data[1]), 1.75, -64)
		marker_label.text = str(marker_data[2])
		marker_label.font_size = 24
		marker_label.outline_size = 6
		marker_label.modulate = Color(0.76, 0.95, 1.0)
		marker_label.outline_modulate = Color(0.02, 0.06, 0.09, 0.95)
		marker_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker_label.pixel_size = 0.005
		marker_label.visibility_range_end = 14.0
		marker_label.visible = false
		add_child(marker_label)


func _build_interaction_spots() -> void:
	# Politics: collect four civic tablets and carry them back to the agora display.
	_make_spot("politics_monarchy", Vector3(-6, 0, 12), "لوح الملكية")
	_make_spot("politics_athens", Vector3(6, 0, 12), "لوح أثينا")
	_make_spot("politics_sparta", Vector3(-6, 0, 17), "لوح إسبرطة")
	_make_spot("politics_despotism", Vector3(6, 0, 17), "لوح الحكم الاستبدادي")
	_make_spot("politics_display", Vector3(0, 0, 10.5), "ضع الألواح على العرض المدني")
	# Economy: real movement from crop rows to processing and market.
	_make_spot("farm_grain", Vector3(-21, 0, 0), "اجمع عينة حبوب")
	_make_spot("farm_olives", Vector3(-16, 0, 0), "اجمع الزيتون")
	_make_spot("farm_grapes", Vector3(-11, 0, 0), "اجمع العنب")
	_make_spot("farm_mill", Vector3(-22, 0, -5), "شغّل مطحنة الحبوب")
	_make_spot("farm_press", Vector3(-15, 0, -5), "استخدم معصرة الزيتون")
	_make_spot("farm_market_delivery", Vector3(-5, 0, -12), "سلّم المنتجات إلى السوق")
	# Industry: one-item carry state connects raw materials to craft stations.
	_make_spot("industry_wood", Vector3(11, 0, -5), "احمل الخشب")
	_make_spot("industry_metal", Vector3(15, 0, -5), "احمل المعدن")
	_make_spot("industry_clay", Vector3(19, 0, -5), "احمل الطين")
	_make_spot("industry_ship", Vector3(11, 0, -9), "محطة السفن")
	_make_spot("industry_tools", Vector3(15, 0, -9), "محطة الأدوات")
	_make_spot("industry_pottery", Vector3(19, 0, -9), "محطة الفخار")
	# Trade: physically route local and overseas goods.
	_make_spot("trade_local_crate", Vector3(-7, 0, -14), "صندوق السوق المحلي")
	_make_spot("trade_external_crate", Vector3(7, 0, -14), "صندوق المرفأ")
	_make_spot("trade_market_drop", Vector3(-2, 0, -17), "سلّم البضاعة المحلية")
	_make_spot("trade_harbour_drop", Vector3(20, 0.4, -7), "سلّم البضاعة البحرية")
	_make_spot("trade_dock_follow", Vector3(29, 0, -7), "اتبع الشحنة إلى الرصيف")
	# Society: gather records from lived spaces, then rebuild the archive display.
	_make_spot("society_official", Vector3(11, 0.2, -23), "سجل الطبقة الحاكمة")
	_make_spot("society_merchant", Vector3(19, 0.2, -23), "سجل التجار والأثرياء")
	_make_spot("society_common", Vector3(11, 0.2, -29), "سجل العامة")
	_make_spot("society_enslaved", Vector3(19, 0.2, -29), "سجل المحرومين من المواطنة")
	_make_spot("society_women_rights", Vector3(15, 0.2, -29), "وثيقة الملكية والميراث والتعليم")
	_make_spot("society_display", Vector3(15, 0.2, -23.8), "أعد بناء سجل المجتمع")
	# Beliefs: the source symbols form a separate arc, then snap to the three
	# always-visible, named temple plinths. Gameplay IDs remain unchanged.
	_make_spot("belief_zeus", Vector3(-8.0, 0, -28.0), "رمز زيوس")
	_make_spot("belief_apollo", Vector3(0.0, 0, -26.8), "رمز أبولو")
	_make_spot("belief_athena", Vector3(8.0, 0, -28.0), "رمز أثينا")
	_make_spot("belief_zeus_plinth", Vector3(-5.0, 0, BELIEF_PLINTH_Z), "ضع رمز زيوس — الإله الرئيس")
	_make_spot("belief_apollo_plinth", Vector3(0.0, 0, BELIEF_PLINTH_Z), "ضع رمز أبولو — إله الشمس")
	_make_spot("belief_athena_plinth", Vector3(5.0, 0, BELIEF_PLINTH_Z), "ضع رمز أثينا — إلهة الحكمة")
	# Theatre discovery and rehearsal.
	_make_spot("theatre_actor_a", Vector3(-16, 0.9, -56), "اعثر على ممثل التراجيديا")
	_make_spot("theatre_actor_b", Vector3(-12, 0.9, -56), "اعثر على ممثل الكوميديا")
	_make_spot("theatre_chorus", Vector3(-18, 0, -50), "موضع الجوقة")
	_make_spot("theatre_orchestra", Vector3(-14, 0, -51), "الأوركسترا")
	_make_spot("theatre_stage", Vector3(-14, 1.0, -56), "خشبة المسرح")
	# Thinkers: carry each tablet to the corresponding library desk.
	_make_spot("ideas_plato", Vector3(11, 0, -45), "لوح أفلاطون")
	_make_spot("ideas_aristotle", Vector3(15, 0, -45), "لوح أرسطو")
	_make_spot("ideas_herodotus", Vector3(19, 0, -45), "لوح هيرودوتس")
	_make_spot("ideas_plato_desk", Vector3(11, 0, -48), "الجمهورية والقوانين")
	_make_spot("ideas_aristotle_desk", Vector3(15, 0, -48), "السياسة")
	_make_spot("ideas_herodotus_desk", Vector3(19, 0, -48), "الحروب الفارسية")
	# Architecture model and sculpture workshop.
	_make_spot("arch_wall", Vector3(-4, 0.7, -61), "قطعة السور")
	_make_spot("arch_agora", Vector3(-2, 0.7, -61), "قطعة الساحة")
	_make_spot("arch_temple", Vector3(2, 0.7, -61), "قطعة المعبد")
	_make_spot("arch_theatre", Vector3(4, 0.7, -61), "قطعة المسرح")
	_make_spot("arch_model", Vector3(0, 0.7, -58), "أكمل نموذج المدينة")
	_make_spot("arch_sculpture", Vector3(0, 0.7, -64), "افحص الرخام والبرونز")
	# Sports course.
	_make_spot("sport_start", Vector3(-22, 0, -70), "ابدأ تدريب الجري")
	_make_spot("sport_cp_1", Vector3(-15, 0, -75), "١")
	_make_spot("sport_cp_2", Vector3(-8, 0, -70), "٢")
	_make_spot("sport_cp_3", Vector3(-15, 0, -65), "٣")
	# Jordan map markers and final heritage location.
	_make_spot("jordan_marker_tray", Vector3(9, 0.6, -67.5), "خذ علامة مدينة")
	_make_spot("jordan_amman", Vector3(11, 1.2, -64), "عمّان / فيلادلفيا")
	_make_spot("jordan_pella", Vector3(13.5, 1.2, -64), "طبقة فحل / بيلا")
	_make_spot("jordan_gadara", Vector3(16, 1.2, -64), "أم قيس / جدارا")
	_make_spot("jordan_gerasa", Vector3(18.5, 1.2, -64), "جرش / جراسا")
	_make_spot("jordan_heshbon", Vector3(21, 1.2, -64), "حسبان / حشبون")
	_make_spot("jordan_qasr", Vector3(16, 0.6, -70), "قصر العبد — عراق الأمير")
	_make_spot("final_board", Vector3(0, 0, 8.5), "ضع شعارات الرحلة")


# Non-blocking visual hooks used by the mission controller. They deliberately
# contain no story state: a save can safely call them again after restoring its
# own progression.
func play_mission_animation(action_id: String) -> void:
	match action_id:
		"farm_mill":
			var mill := _mechanisms.get("farm_mill") as Node3D
			if mill == null:
				return
			var mill_tween := _new_mechanism_tween("farm_mill")
			mill_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
			mill_tween.tween_property(mill, "rotation:y", mill.rotation.y + TAU * 2.0, 1.45)
		"farm_press":
			var beam := _mechanisms.get("farm_press") as Node3D
			if beam == null:
				return
			var press_tween := _new_mechanism_tween("farm_press")
			press_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			press_tween.tween_property(beam, "rotation:z", -0.24, 0.38)
			press_tween.tween_interval(0.28)
			press_tween.tween_property(beam, "rotation:z", 0.08, 0.42)
			press_tween.tween_property(beam, "rotation:z", 0.0, 0.20)
		"society_display":
			_reveal_mechanism("society_display", 0.62)
		"belief_zeus_plinth", "belief_apollo_plinth", "belief_athena_plinth":
			var plinth := _mechanisms.get(action_id) as Node3D
			if plinth == null:
				return
			var completion_glow := plinth.get_node_or_null("CompletionGlow") as MeshInstance3D
			if completion_glow != null:
				completion_glow.visible = true
			var belief_tween := _new_mechanism_tween(action_id)
			belief_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			belief_tween.tween_property(plinth, "scale", Vector3(1.08, 1.08, 1.08), 0.28)
			belief_tween.tween_property(plinth, "scale", Vector3.ONE, 0.30)
		"theatre_orchestra", "theatre_stage":
			var curtain := _mechanisms.get(action_id) as Node3D
			if curtain == null:
				return
			curtain.visible = true
			var theatre_tween := _new_mechanism_tween("theatre")
			theatre_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			theatre_tween.tween_property(curtain, "scale:y", 1.0, 0.62)
			var rest_rotation := curtain.rotation.y
			theatre_tween.tween_property(curtain, "rotation:y", rest_rotation + 0.035, 0.18)
			theatre_tween.tween_property(curtain, "rotation:y", rest_rotation, 0.18)
		"arch_model", "city_model":
			_reveal_mechanism("arch_model", 0.72)
		"jordan_map":
			var map_surface := _mechanisms.get("jordan_map") as Node3D
			if map_surface == null:
				return
			map_surface.visible = true
			var map_tween := _new_mechanism_tween("jordan_map")
			map_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			map_tween.tween_property(map_surface, "scale", Vector3(1.035, 1.0, 1.035), 0.32)
			map_tween.tween_property(map_surface, "scale", Vector3.ONE, 0.46)
		"jordan_marker_tray":
			var tray := _mechanisms.get("jordan_marker_tray") as Node3D
			if tray == null:
				return
			var tray_tween := _new_mechanism_tween("jordan_marker_tray")
			tray_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tray_tween.tween_property(tray, "scale", Vector3(1.08, 1.08, 1.08), 0.24)
			tray_tween.tween_property(tray, "scale", Vector3.ONE, 0.20)
		"trade_harbour_drop", "trade_dock_follow":
			var crane := _mechanisms.get(action_id) as Node3D
			if crane == null:
				return
			var rest_yaw := crane.rotation.y
			var crane_tween := _new_mechanism_tween("harbour_crane")
			crane_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			crane_tween.tween_property(crane, "rotation:y", rest_yaw - 0.32, 0.58)
			crane_tween.tween_interval(0.20)
			crane_tween.tween_property(crane, "rotation:y", rest_yaw, 0.62)


func set_mission_prop_state(action_id: String, state: String) -> void:
	var node := _mechanisms.get(action_id) as Node3D
	if node == null and action_id == "city_model":
		node = _mechanisms.get("arch_model") as Node3D
	if node == null:
		return
	match state:
		"hidden":
			node.visible = false
		"reset":
			node.visible = true
			if action_id in ["society_display", "arch_model", "city_model"]:
				node.scale = Vector3(0.06, 0.06, 0.06)
			elif action_id in ["theatre_orchestra", "theatre_stage"]:
				node.scale.y = 0.12
		"available", "visible":
			node.visible = true
		"active":
			node.visible = true
			play_mission_animation(action_id)
		"placed", "revealed", "complete", "completed":
			node.visible = true
			if action_id in ["society_display", "arch_model", "city_model", "theatre_orchestra", "theatre_stage"]:
				node.scale = Vector3.ONE


func get_mission_prop_anchor(action_id: String) -> Node3D:
	return _mechanisms.get(action_id) as Node3D


func _reveal_mechanism(action_id: String, duration: float) -> void:
	var node := _mechanisms.get(action_id) as Node3D
	if node == null:
		return
	node.visible = true
	var reveal_tween := _new_mechanism_tween(action_id)
	reveal_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	reveal_tween.tween_property(node, "scale", Vector3(1.06, 1.06, 1.06), duration)
	reveal_tween.tween_property(node, "scale", Vector3.ONE, 0.18)


func _new_mechanism_tween(key: String) -> Tween:
	var previous := _mechanism_tweens.get(key) as Tween
	if previous != null and previous.is_valid():
		previous.kill()
	var tween := create_tween()
	_mechanism_tweens[key] = tween
	return tween


func _make_deity_plinth(
	action_id: String, identity: String, pos: Vector3, name_ar: String, role_ar: String
) -> Node3D:
	var plinth := Node3D.new()
	plinth.name = "DeityDisplay" + identity.to_pascal_case()
	plinth.position = pos
	plinth.set_meta("belief_action_id", action_id)
	plinth.set_meta("deity_name_ar", name_ar)
	plinth.set_meta("deity_role_ar", role_ar)
	plinth.set_meta("non_blocking", true)
	add_child(plinth)

	# Broad stonework and a dark plaque give the small placed token an obvious
	# home without adding a StaticBody to the main temple approach.
	_add_box_to(plinth, "LowerStep", Vector3(0, 0.12, 0), Vector3(2.85, 0.24, 1.75), _stone)
	_add_box_to(plinth, "UpperStep", Vector3(0, 0.31, 0), Vector3(2.35, 0.18, 1.40), _marble)
	_add_cylinder_to(plinth, "OfferingSocket", Vector3(0, 0.56, 0.12), 0.56, 0.42, _bronze, 24)
	_add_box_to(plinth, "IdentityStele", Vector3(0, 1.62, -0.48), Vector3(1.75, 2.45, 0.18), _marble)
	var figure := Node3D.new()
	figure.name = identity.to_pascal_case() + "Figure"
	figure.position.z = -0.31
	plinth.add_child(figure)
	_add_cylinder_to(figure, "Robe", Vector3(0, 1.33, 0), 0.42, 1.36, _marble, 18)
	_add_box_to(figure, "Shoulders", Vector3(0, 1.72, 0.01), Vector3(1.04, 0.24, 0.34), _marble)
	_add_sphere_to(figure, "Head", Vector3(0, 2.12, 0.02), Vector3(0.33, 0.39, 0.31), _marble)
	_add_deity_emblem(figure, identity)

	var is_apollo := identity == "apollo"
	var plaque_y := 3.38 if is_apollo else 3.18
	var name_color := Color(1.0, 0.84, 0.28) if is_apollo else Color(0.96, 0.85, 0.55)
	_add_box_to(plinth, "NamePlaque", Vector3(0, plaque_y - 0.14, 0.31), Vector3(2.95, 0.92, 0.12), _charcoal)
	_add_box_to(plinth, "PlaqueTopRule", Vector3(0, plaque_y + 0.32, 0.38), Vector3(2.95, 0.055, 0.05), _bronze)
	_add_deity_label(plinth, "NameArabic", Vector3(0, plaque_y + 0.04, 0.40), name_ar, 42 if is_apollo else 38, name_color, 0.0075)
	_add_deity_label(plinth, "RoleArabic", Vector3(0, plaque_y - 0.28, 0.40), role_ar, 24, Color(0.96, 0.92, 0.80), 0.006)

	var glow := _add_cylinder_to(plinth, "CompletionGlow", Vector3(0, 0.025, 0), 1.48, 0.035, _fire, 32)
	glow.visible = false
	_mechanisms[action_id] = plinth
	return plinth


func _add_deity_emblem(figure: Node3D, identity: String) -> void:
	match identity:
		"apollo":
			# The large sun behind the central figure follows the textbook role
			# and remains visible above the guide from the normal approach camera.
			var sun := _add_cylinder_to(figure, "SunDisk", Vector3(0, 2.15, -0.12), 0.62, 0.09, _fire, 28)
			sun.rotation.x = PI * 0.5
			for ray_index in range(8):
				var angle := float(ray_index) * TAU / 8.0
				var ray := _add_box_to(
					figure, "SunRay%d" % ray_index,
					Vector3(cos(angle) * 0.79, 2.15 + sin(angle) * 0.79, -0.10),
					Vector3(0.09, 0.31, 0.08), _fire
				)
				ray.rotation.z = PI * 0.5 - angle
			_add_sphere_to(figure, "GoldenHair", Vector3(0, 2.19, 0.04), Vector3(0.38, 0.43, 0.34), _bronze)
		"zeus":
			_add_box_to(figure, "Beard", Vector3(0, 1.94, 0.24), Vector3(0.36, 0.43, 0.18), _marble)
			var bolt_upper := _add_box_to(figure, "LightningUpper", Vector3(0.52, 1.64, 0.28), Vector3(0.14, 0.72, 0.12), _bronze)
			bolt_upper.rotation.z = -0.42
			var bolt_lower := _add_box_to(figure, "LightningLower", Vector3(0.39, 1.16, 0.28), Vector3(0.14, 0.66, 0.12), _bronze)
			bolt_lower.rotation.z = 0.52
		"athena":
			var shield := _add_cylinder_to(figure, "WisdomShield", Vector3(0.45, 1.45, 0.25), 0.47, 0.10, _paint_blue, 24)
			shield.rotation.x = PI * 0.5
			_add_cylinder_to(figure, "ShieldBoss", Vector3(0.45, 1.45, 0.32), 0.13, 0.08, _bronze, 18).rotation.x = PI * 0.5
			_add_box_to(figure, "HelmetCrest", Vector3(0, 2.54, 0.03), Vector3(0.14, 0.48, 0.32), _paint_blue)


func _make_belief_token(action_id: String, identity: String, pos: Vector3) -> Node3D:
	var token := Node3D.new()
	token.name = "Belief" + identity.to_pascal_case() + "SymbolVisual"
	token.position = pos
	add_child(token)
	_add_cylinder_to(token, "TokenBase", Vector3.ZERO, 0.48, 0.16, _bronze, 22)
	match identity:
		"apollo":
			var sun := _add_cylinder_to(token, "SunSymbol", Vector3(0, 0.55, 0), 0.31, 0.09, _fire, 20)
			sun.rotation.x = PI * 0.5
		"zeus":
			var bolt := _add_box_to(token, "LightningSymbol", Vector3(0, 0.48, 0), Vector3(0.14, 0.72, 0.13), _bronze)
			bolt.rotation.z = -0.42
		"athena":
			var shield := _add_cylinder_to(token, "WisdomSymbol", Vector3(0, 0.48, 0), 0.31, 0.09, _paint_blue, 20)
			shield.rotation.x = PI * 0.5
	_mechanisms[action_id] = token
	return token


func _add_deity_label(
	parent: Node3D, name_value: String, pos: Vector3, text_value: String,
	font_size_value: int, color: Color, pixel_size_value: float
) -> Label3D:
	var label := Label3D.new()
	label.name = name_value
	label.position = pos
	label.text = text_value
	label.font_size = font_size_value
	label.outline_size = 7
	label.modulate = color
	label.outline_modulate = Color(0.025, 0.02, 0.015, 0.98)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = pixel_size_value
	label.visibility_range_end = 36.0
	parent.add_child(label)
	return label


func _make_spot(id: String, position_value: Vector3, label_text: String) -> void:
	var area := Area3D.new()
	area.name = id.to_pascal_case()
	area.position = position_value
	area.collision_layer = 0
	area.collision_mask = 1
	area.set_script(SPOT_SCRIPT)
	area.set("spot_id", id)
	area.set("label_ar", label_text)
	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	# Most tasks get generous controller-friendly reach. Dense Jordan and belief
	# clusters stay tighter so adjacent labels never steal one another's input.
	shape.radius = (
		2.15 if id.begins_with("belief_")
		else 2.45 if id.begins_with("jordan_")
		else 2.75
	)
	shape_node.position.y = 1.0
	shape_node.shape = shape
	area.add_child(shape_node)
	var marker := Label3D.new()
	marker.name = "Marker"
	marker.position.y = 2.4
	marker.text = "◆\n" + label_text
	marker.font_size = 28
	marker.outline_size = 7
	marker.modulate = Color(1, 0.78, 0.24)
	marker.outline_modulate = Color(0.04, 0.03, 0.02, 0.95)
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.pixel_size = 0.006
	marker.fixed_size = false
	marker.visibility_range_end = 18.0
	area.add_child(marker)
	add_child(area)


func _instance(scene: PackedScene, pos: Vector3, rot: Vector3 = Vector3.ZERO, scale_value: Vector3 = Vector3.ONE) -> Node3D:
	# Generated GLBs contain many tiny MeshInstance children. Collapse each asset
	# to one cached ArrayMesh so repeated houses, walls and props preserve their
	# materials and silhouette without hundreds of scene-tree/render objects.
	var node := Node3D.new()
	node.name = scene.resource_path.get_file().get_basename()
	node.position = pos
	node.rotation = rot
	node.scale = scale_value
	add_child(node)
	var model := MeshInstance3D.new()
	model.name = "Model"
	model.mesh = _get_merged_scene_mesh(scene)
	model.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if "/props/" in scene.resource_path
		else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	)
	node.add_child(model)
	return node


func _get_merged_scene_mesh(scene: PackedScene) -> ArrayMesh:
	var cache_key := scene.resource_path
	if _merged_scene_mesh_cache.has(cache_key):
		return _merged_scene_mesh_cache[cache_key] as ArrayMesh
	var source := scene.instantiate()
	var surface_groups: Dictionary = {}
	_collect_scene_surfaces(source, Transform3D.IDENTITY, surface_groups)
	var merged := ArrayMesh.new()
	for group_variant in surface_groups.values():
		var group: Dictionary = group_variant
		var surface_tool := SurfaceTool.new()
		var entries: Array = group["entries"]
		for entry_variant in entries:
			var entry: Dictionary = entry_variant
			surface_tool.append_from(
				entry["mesh"] as Mesh,
				int(entry["surface_index"]),
				entry["transform"] as Transform3D
			)
		var surface_index := merged.get_surface_count()
		surface_tool.commit(merged)
		var surface_material := group["material"] as Material
		if surface_material != null:
			merged.surface_set_material(surface_index, surface_material)
	source.free()
	_merged_scene_mesh_cache[cache_key] = merged
	return merged


func _collect_scene_surfaces(node: Node, parent_transform: Transform3D, surface_groups: Dictionary) -> void:
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
				var group: Dictionary = surface_groups[material_key]
				var entries: Array = group["entries"]
				entries.append({
					"mesh": source_mesh,
					"surface_index": surface_index,
					"transform": accumulated_transform,
				})
	for child in node.get_children():
		_collect_scene_surfaces(child, accumulated_transform, surface_groups)


func _make_box(name_value: String, pos: Vector3, size: Vector3, material: Material, collision: bool, visible: bool = true) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = name_value
	mesh_node.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	mesh_node.mesh = mesh
	mesh_node.visible = visible
	add_child(mesh_node)
	if collision:
		var body := StaticBody3D.new()
		body.name = name_value + "Body"
		body.position = pos
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		body.add_child(shape_node)
		add_child(body)
	return mesh_node


func _make_access_ramp(name_value: String, pos: Vector3, width: float, run: float, rise: float, material: Material, yaw: float = 0.0) -> MeshInstance3D:
	var angle := atan2(rise, run)
	var slope_length := sqrt(run * run + rise * rise)
	var thickness := 0.16
	var center_y := rise * 0.5 - cos(angle) * thickness * 0.5 + 0.015
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = name_value
	mesh_node.position = Vector3(pos.x, center_y, pos.z)
	mesh_node.rotation = Vector3(angle, yaw, 0.0)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, thickness, slope_length)
	mesh.material = material
	mesh_node.mesh = mesh
	add_child(mesh_node)

	var body := StaticBody3D.new()
	body.name = name_value + "Body"
	body.position = mesh_node.position
	body.rotation = mesh_node.rotation
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = mesh.size
	shape_node.shape = shape
	body.add_child(shape_node)
	add_child(body)
	return mesh_node


func _make_cylinder(name_value: String, pos: Vector3, radius: float, height: float, material: Material, collision: bool) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.material = material
	node.mesh = mesh
	add_child(node)
	if collision:
		var body := StaticBody3D.new()
		body.position = pos
		var shape_node := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		shape_node.shape = shape
		body.add_child(shape_node)
		add_child(body)
	return node


func _make_label(pos: Vector3, text_value: String) -> void:
	var label := Label3D.new()
	label.position = pos
	label.text = text_value
	label.font_size = 34
	label.outline_size = 8
	label.modulate = Color(0.98, 0.82, 0.44)
	label.outline_modulate = Color(0.04, 0.03, 0.02, 0.96)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.008
	label.fixed_size = false
	label.visibility_range_begin = 5.0
	label.visibility_range_end = 28.0
	label.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	add_child(label)


func _make_livestock(name_value: String, pos: Vector3, cattle: bool, yaw: float) -> void:
	var animal := Node3D.new()
	animal.name = name_value
	animal.position = pos
	animal.rotation.y = yaw
	add_child(animal)
	var body_scale := Vector3(1.75, 0.95, 0.85) if cattle else Vector3(1.2, 0.72, 0.72)
	_add_animal_box(animal, "Body", Vector3(0, 0.9, 0), body_scale, _animal_hide if cattle else _wool)
	_add_animal_box(animal, "Head", Vector3(body_scale.x * 0.58, 1.02, 0), Vector3(0.48, 0.52, 0.50), _animal_hide)
	for x in [-body_scale.x * 0.32, body_scale.x * 0.32]:
		for z in [-body_scale.z * 0.28, body_scale.z * 0.28]:
			_add_animal_box(animal, "Leg", Vector3(x, 0.38, z), Vector3(0.15, 0.72, 0.15), _animal_hide)
	if cattle:
		_add_animal_box(animal, "Horn", Vector3(1.18, 1.28, -0.25), Vector3(0.34, 0.08, 0.08), _marble)
		_add_animal_box(animal, "Horn", Vector3(1.18, 1.28, 0.25), Vector3(0.34, 0.08, 0.08), _marble)


func _add_animal_box(parent: Node3D, name_value: String, pos: Vector3, size: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)


func _make_orchard_tree(pos: Vector3) -> void:
	var tree := Node3D.new()
	tree.name = "OliveTree"
	tree.position = pos
	add_child(tree)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.26
	trunk_mesh.height = 2.2
	trunk_mesh.radial_segments = 8
	trunk_mesh.material = _wood
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.1
	tree.add_child(trunk)
	for crown_pos in [Vector3(0, 2.35, 0), Vector3(-0.48, 2.15, 0.1), Vector3(0.45, 2.2, -0.12)]:
		var crown := MeshInstance3D.new()
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 0.72
		crown_mesh.height = 1.15
		crown_mesh.radial_segments = 10
		crown_mesh.rings = 6
		crown_mesh.material = _leaf
		crown.mesh = crown_mesh
		crown.position = crown_pos
		tree.add_child(crown)


func _make_harbour_boat(pos: Vector3, yaw: float) -> void:
	var boat := Node3D.new()
	boat.name = "TradeBoat"
	boat.position = pos
	boat.rotation.y = yaw
	add_child(boat)
	_add_animal_box(boat, "Hull", Vector3(0, 0.28, 0), Vector3(5.0, 0.65, 1.45), _wood)
	_add_animal_box(boat, "Mast", Vector3(0, 1.75, 0), Vector3(0.16, 3.0, 0.16), _wood)
	_add_animal_box(boat, "Sail", Vector3(0.12, 2.05, 0), Vector3(0.08, 2.2, 2.4), _wool)


func _add_box_to(parent: Node3D, name_value: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node


func _add_cylinder_to(
	parent: Node3D,
	name_value: String,
	pos: Vector3,
	radius: float,
	height: float,
	material: Material,
	segments: int = 14
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.material = material
	node.mesh = mesh
	parent.add_child(node)
	return node


func _add_sphere_to(
	parent: Node3D, name_value: String, pos: Vector3, size: Vector3, material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	node.scale = size
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh.material = material
	node.mesh = mesh
	parent.add_child(node)
	return node


func _make_sphere(name_value: String, pos: Vector3, size: Vector3, material: Material, segments: int = 10) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = pos
	node.scale = size
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = segments
	mesh.rings = maxi(4, segments / 2)
	mesh.material = material
	node.mesh = mesh
	add_child(node)
	return node


func _make_column(pos: Vector3, height: float, material: Material) -> void:
	_make_cylinder("ColumnBase", pos + Vector3(0, 0.13, 0), 0.38, 0.26, material, false)
	_make_cylinder("ColumnShaft", pos + Vector3(0, height * 0.5 + 0.16, 0), 0.25, height, material, false)
	_make_box("ColumnCapital", pos + Vector3(0, height + 0.24, 0), Vector3(0.88, 0.24, 0.88), material, false)


func _make_brazier(pos: Vector3, lit: bool) -> void:
	var brazier := Node3D.new()
	brazier.name = "TempleBrazier" if lit else "CityBrazier"
	brazier.position = pos
	add_child(brazier)
	_add_cylinder_to(brazier, "Foot", Vector3(0, 0.10, 0), 0.30, 0.20, _stone, 12)
	_add_cylinder_to(brazier, "Stem", Vector3(0, 0.53, 0), 0.12, 0.70, _bronze, 10)
	_add_cylinder_to(brazier, "Bowl", Vector3(0, 0.92, 0), 0.48, 0.18, _bronze, 14)
	var ember := _add_cylinder_to(brazier, "Embers", Vector3(0, 1.04, 0), 0.34, 0.06, _charcoal, 12)
	if lit:
		var flame := MeshInstance3D.new()
		flame.name = "Flame"
		flame.position = Vector3(0, 1.25, 0)
		var flame_mesh := SphereMesh.new()
		flame_mesh.radius = 0.20
		flame_mesh.height = 0.62
		flame_mesh.radial_segments = 8
		flame_mesh.rings = 5
		flame_mesh.material = _fire
		flame.mesh = flame_mesh
		brazier.add_child(flame)
		var light := OmniLight3D.new()
		light.name = "FireGlow"
		light.position = Vector3(0, 1.32, 0)
		light.light_color = Color(1.0, 0.55, 0.25)
		light.light_energy = 0.55
		light.omni_range = 4.2
		light.shadow_enabled = false
		brazier.add_child(light)
	else:
		ember.material_override = _charcoal


func _make_crop_clump(pos: Vector3, material: Material, height: float) -> void:
	var crop := Node3D.new()
	crop.name = "CropClump"
	crop.position = pos
	add_child(crop)
	for offset in [Vector3(-0.18, 0, -0.13), Vector3(0.17, 0, -0.08), Vector3(0.0, 0, 0.18)]:
		_add_box_to(crop, "Stalk", offset + Vector3(0, height * 0.5, 0), Vector3(0.07, height, 0.07), material)
		_add_box_to(crop, "Ear", offset + Vector3(0, height + 0.08, 0), Vector3(0.16, 0.22, 0.10), material)


func _make_simple_amphora(pos: Vector3, scale_value: float, material: Material) -> void:
	var jar := Node3D.new()
	jar.name = "MarketAmphora"
	jar.position = pos
	jar.scale = Vector3.ONE * scale_value
	add_child(jar)
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.position.y = 0.52
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.42
	body_mesh.bottom_radius = 0.24
	body_mesh.height = 0.82
	body_mesh.radial_segments = 10
	body_mesh.material = material
	body.mesh = body_mesh
	jar.add_child(body)
	_add_cylinder_to(jar, "Neck", Vector3(0, 1.02, 0), 0.18, 0.32, material, 10)


func _make_tool_rack(pos: Vector3, yaw: float) -> void:
	var rack := Node3D.new()
	rack.name = "ToolRack"
	rack.position = pos
	rack.rotation.y = yaw
	add_child(rack)
	_add_box_to(rack, "LeftPost", Vector3(-0.8, 0.85, 0), Vector3(0.13, 1.70, 0.13), _wood)
	_add_box_to(rack, "RightPost", Vector3(0.8, 0.85, 0), Vector3(0.13, 1.70, 0.13), _wood)
	_add_box_to(rack, "Rail", Vector3(0, 1.25, 0), Vector3(1.75, 0.13, 0.13), _wood)
	for x in [-0.48, 0.0, 0.48]:
		var tool := _add_box_to(rack, "Tool", Vector3(x, 0.70, -0.08), Vector3(0.09, 1.05, 0.09), _bronze)
		tool.rotation.z = 0.18 * sign(x)


func _make_timber_stack(pos: Vector3, yaw: float) -> void:
	var stack := Node3D.new()
	stack.name = "TimberStack"
	stack.position = pos
	stack.rotation.y = yaw
	add_child(stack)
	for level in range(3):
		for side in [-0.33, 0.33]:
			_add_box_to(stack, "Timber", Vector3(0, 0.18 + level * 0.28, side), Vector3(3.0, 0.20, 0.20), _wood)


func _make_bollard(pos: Vector3) -> void:
	_make_cylinder("QuayBollard", pos, 0.22, 0.76, _stone, false)
	_make_cylinder("QuayBollardCap", pos + Vector3(0, 0.42, 0), 0.31, 0.12, _bronze, false)


func _make_crane(pos: Vector3) -> Node3D:
	var crane := Node3D.new()
	crane.name = "HarbourCrane"
	crane.position = pos
	add_child(crane)
	_add_box_to(crane, "Mast", Vector3(0, 2.1, 0), Vector3(0.34, 4.2, 0.34), _wood)
	var boom := _add_box_to(crane, "Boom", Vector3(1.45, 3.75, 0), Vector3(3.2, 0.24, 0.24), _wood)
	boom.rotation.z = -0.16
	_add_box_to(crane, "Rope", Vector3(2.85, 2.65, 0), Vector3(0.055, 2.15, 0.055), _charcoal)
	_add_box_to(crane, "Hook", Vector3(2.78, 1.55, 0), Vector3(0.30, 0.10, 0.10), _bronze)
	return crane


func _make_scroll_rack(pos: Vector3, yaw: float) -> void:
	var rack := Node3D.new()
	rack.name = "ScrollRack"
	rack.position = pos
	rack.rotation.y = yaw
	add_child(rack)
	_add_box_to(rack, "Back", Vector3(0, 1.05, 0.14), Vector3(2.6, 2.1, 0.20), _wood)
	for shelf_y in [0.38, 1.02, 1.66]:
		_add_box_to(rack, "Shelf", Vector3(0, shelf_y - 0.20, -0.10), Vector3(2.7, 0.12, 0.65), _wood)
		for x in [-0.88, -0.44, 0.0, 0.44, 0.88]:
			var scroll := _add_cylinder_to(rack, "Scroll", Vector3(x, shelf_y, -0.22), 0.10, 0.34, _linen, 8)
			scroll.rotation.z = PI * 0.5


func _make_mask_stand(pos: Vector3, tragic: bool) -> Node3D:
	var stand := Node3D.new()
	stand.name = "TragicMaskStand" if tragic else "ComicMaskStand"
	stand.position = pos
	add_child(stand)
	_add_cylinder_to(stand, "Post", Vector3(0, 0.82, 0), 0.09, 1.64, _wood, 8)
	_add_cylinder_to(stand, "Base", Vector3(0, 0.08, 0), 0.38, 0.16, _stone, 12)
	var mask := MeshInstance3D.new()
	mask.name = "Mask"
	mask.position = Vector3(0, 1.72, 0)
	mask.scale = Vector3(0.62, 0.78, 0.24)
	var mask_mesh := SphereMesh.new()
	mask_mesh.radius = 0.5
	mask_mesh.height = 1.0
	mask_mesh.radial_segments = 12
	mask_mesh.rings = 7
	mask_mesh.material = _terracotta if tragic else _marble
	mask.mesh = mask_mesh
	stand.add_child(mask)
	for eye_x in [-0.17, 0.17]:
		_add_box_to(stand, "Eye", Vector3(eye_x, 1.82, -0.24), Vector3(0.15, 0.08, 0.05), _charcoal)
	var mouth_height := 1.52 if tragic else 1.60
	_add_box_to(stand, "Mouth", Vector3(0, mouth_height, -0.25), Vector3(0.27, 0.07, 0.05), _charcoal)
	return stand


func _make_scaffold(pos: Vector3) -> void:
	var scaffold := Node3D.new()
	scaffold.name = "SculptorScaffold"
	scaffold.position = pos
	add_child(scaffold)
	for x in [-1.15, 1.15]:
		_add_box_to(scaffold, "Post", Vector3(x, 1.35, 0), Vector3(0.14, 2.7, 0.14), _wood)
	for y in [0.65, 1.45, 2.25]:
		_add_box_to(scaffold, "Rail", Vector3(0, y, 0), Vector3(2.5, 0.13, 0.13), _wood)
	_add_box_to(scaffold, "Platform", Vector3(0, 1.55, 0), Vector3(2.5, 0.12, 1.0), _wood)


func _make_cypress(pos: Vector3, height: float) -> void:
	_make_cylinder("CypressTrunk", pos + Vector3(0, height * 0.23, 0), 0.14, height * 0.46, _wood, false)
	var crown := MeshInstance3D.new()
	crown.name = "CypressCrown"
	crown.position = pos + Vector3(0, height * 0.64, 0)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.04
	mesh.bottom_radius = 0.80
	mesh.height = height * 0.72
	mesh.radial_segments = 10
	mesh.material = _leaf
	crown.mesh = mesh
	add_child(crown)


func _make_boundary_house(pos: Vector3, left_side: bool, blue_detail: bool) -> void:
	var house := Node3D.new()
	house.name = "BoundaryTownhouse"
	house.position = pos
	add_child(house)
	_add_box_to(house, "Facade", Vector3(0, 1.75, 0), Vector3(4.3, 3.5, 7.0), _plaster)
	var body := StaticBody3D.new()
	body.name = "BoundaryTownhouseBody"
	body.position = Vector3(0, 1.75, 0)
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.3, 3.5, 7.0)
	shape_node.shape = shape
	body.add_child(shape_node)
	house.add_child(body)
	var roof_left := _add_box_to(house, "RoofLeft", Vector3(-1.05, 3.72, 0), Vector3(2.5, 0.28, 7.5), _terracotta)
	var roof_right := _add_box_to(house, "RoofRight", Vector3(1.05, 3.72, 0), Vector3(2.5, 0.28, 7.5), _terracotta)
	roof_left.rotation.z = -0.16
	roof_right.rotation.z = 0.16
	var inward_x := 2.17 if left_side else -2.17
	_add_box_to(house, "Door", Vector3(inward_x, 1.05, 0.0), Vector3(0.08, 2.1, 1.15), _wood)
	var detail_material: Material = _paint_blue if blue_detail else _paint_red
	for window_z in [-2.15, 2.15]:
		_add_box_to(house, "Window", Vector3(inward_x, 2.45, window_z), Vector3(0.09, 0.72, 0.82), detail_material)


func _textured_material(path: String, tint: Color, roughness_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = roughness_value
	if ResourceLoader.exists(path):
		material.albedo_texture = load(path) as Texture2D
		material.uv1_scale = Vector3(0.24, 0.24, 0.24)
	return material
