extends Node

var levelCode = "100x30~4T*67*924T*8*924T*15*0*6*4T0*8*924T4V0*5*4U4T0*3*4T*2*0*15*924T4V0*5*4U4T0*3*4T*2*0*15*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*3*930*4*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T*5*0*4*4T*2*4V0*5*934T0*3*4T*2*0*6*4T0*8*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*8*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*5*4T0*2*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*5*4T0*2*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*4*4X4T0*2*4T*2*4V0*4*4U4T*7*0*10*4X4T*2*0*2*4T*2*4V0*4*4U4V0*4*4T*2*0*9*4X4T*3*4V0924T4V0*4*934T*7*0*8*4X4T*4*4V0*2*4L4V0*6*4U4T04L4T*2*0*7*4X4T*5*4V0*2*4L4V0*6*4U4T04L4T*2*0*6*4X4T*6*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*8*4U4T*3*0*6*4T*7*4V0924T4V0*9*4T*8*0*3*4L0*6*4T*9*04T*10*04T*3*0*6*4V0*9*4T*10*0*3*4L0*16*4V0*2*4T*6*0*2*4T*3*0*16*8Z0*2*4T*6*0*2*924T*2*0*16*8Z0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*6*4T*9*04T*9*0*2*924T*2*0*6*924T*7*0*2*4T*7*0*4*4T*3*0*6*4V0*6*4U0*2*4T*7*0*4*4T*3*0*13*4U0*4*4L4T*4*0*4*924T*2*0*18*4L4T*4*0*6*4L0*16*4T*7*0*6*4L0*16*4T*7*0*6*4L0*18*4L4T*4*0*6*4L0*18*4L4T*4*0*6*4L0*18*4L4T*4*0*6*4L0*6*924T*8*04T*7*0*6*4L0*6*4V0*11*4L4T*4*0*6*4L0*16*4T*7*0*4*924T*2*0*16*4V0*2*4T*4*0*4*4T*3*0*16*4V0*2*4T*4*0*4*924T*2*0*16*924T*5*4V0*6*4L0*18*4L4T*3*4V0*6*4L0*6*924T*4*0*3*4T*8*4V0*6*4L0*6*4V0*11*4L4T*3*4V0*6*4L0*18*4L4T*3*4V0*6*4L0*16*924T*5*4V0*6*4L0*16*4T*6*4V0*6*4L0*15*4X4T*6*4V0*6*4L0*6*924T*3*0*4*4X4T*7*4V0*6*4L0*6*4T*4*0*3*4X4T*8*4V0*6*4L0*6*4T*4*0*3*4T*10*0*4*924T*2*0*5*4U4T4V0*5*4T0*5*4T*4*0*4*4T*3*0*5*4U4T4V0*5*4T*10*0*4*4T*3*0*11*4U4T*2*0*5*4T*4*0*4*4T*3*0*11*4U4T*11*0*4*4T*3*0*9*4T*3*4V0*6*4T*4*0*4*4T*3*0*9*4T*14*0*4*4T*15*4V0*6*4T*4*0*4*4T*26*0*8*4V0*7*4V0*8*4L4T*4*0*23*4U04L4T*4*0*6*4V0*6*4V0*11*4L4T*4*0*20*4U0*4*4L4T*4*0*9*4V0*15*4L4T*4*0*25*4L4T*4*0*12*4V0*12*4L4T*4*0*17*4U0*7*4L4T*4*0*8*4V0*13*4V0*2*4L4T*4*0*15*4V0*9*4L4T*24*0*5*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*3*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*6*4X4T*2*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4W4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*";
var levelCodeFull = "100x30~4T*67*924T*8*924T*15*0*6*4T0*8*924T4V0*5*4U4T0*3*4T*2*0*15*924T4V0*5*4U4T0*3*4T*2*0*15*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*3*930*4*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T*5*0*4*4T*2*4V0*5*934T0*3*4T*2*0*6*4T0*8*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*8*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*5*4T0*2*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*5*4T0*2*4T*2*4V0*5*4U4T0*3*4T*2*0*6*4T0*4*4X4T0*2*4T*2*4V0*4*4U4T*7*0*10*4X4T*2*0*2*4T*2*4V0*4*4U4V0*4*4T*2*0*9*4X4T*3*4V0924T4V0*4*934T*7*0*8*4X4T*4*4V0*2*4L4V0*6*4U4T04L4T*2*0*7*4X4T*5*4V0*2*4L4V0*6*4U4T04L4T*2*0*6*4X4T*6*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*9*4L4T*2*0*6*4T*7*4V0*2*4L4V0*8*4U4T*3*0*6*4T*7*4V0924T4V0*9*4T*8*0*3*4L0*6*4T*9*04T*10*04T*3*0*6*4V0*9*4T*10*0*3*4L0*16*4V0*2*4T*6*0*2*4T*3*0*16*8Z0*2*4T*6*0*2*924T*2*0*16*8Z0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*16*4V0*2*4T*6*0*4*4L0*6*4T*9*04T*9*0*2*924T*2*0*6*924T*7*0*2*4T*7*0*4*4T*3*0*6*4V0*6*4U0*2*4T*7*0*4*4T*3*0*13*4U0*4*4L4T*4*0*4*924T*2*0*18*4L4T*4*0*6*4L0*16*4T*7*0*6*4L0*16*4T*7*0*6*4L0*18*4L4T*4*0*6*4L0*18*4L4T*4*0*6*4L0*18*4L4T*4*0*6*4L0*6*924T*8*04T*7*0*6*4L0*6*4V0*11*4L4T*4*0*6*4L0*16*4T*7*0*4*924T*2*0*16*4V0*2*4T*4*0*4*4T*3*0*16*4V0*2*4T*4*0*4*924T*2*0*16*924T*5*4V0*6*4L0*18*4L4T*3*4V0*6*4L0*6*924T*4*0*3*4T*8*4V0*6*4L0*6*4V0*11*4L4T*3*4V0*6*4L0*18*4L4T*3*4V0*6*4L0*16*924T*5*4V0*6*4L0*16*4T*6*4V0*6*4L0*15*4X4T*6*4V0*6*4L0*6*924T*3*0*4*4X4T*7*4V0*6*4L0*6*4T*4*0*3*4X4T*8*4V0*6*4L0*6*4T*4*0*3*4T*10*0*4*924T*2*0*5*4U4T4V0*5*4T0*5*4T*4*0*4*4T*3*0*5*4U4T4V0*5*4T*10*0*4*4T*3*0*11*4U4T*2*0*5*4T*4*0*4*4T*3*0*11*4U4T*11*0*4*4T*3*0*9*4T*3*4V0*6*4T*4*0*4*4T*3*0*9*4T*14*0*4*4T*15*4V0*6*4T*4*0*4*4T*26*0*8*4V0*7*4V0*8*4L4T*4*0*23*4U04L4T*4*0*6*4V0*6*4V0*11*4L4T*4*0*20*4U0*4*4L4T*4*0*9*4V0*15*4L4T*4*0*25*4L4T*4*0*12*4V0*12*4L4T*4*0*17*4U0*7*4L4T*4*0*8*4V0*13*4V0*2*4L4T*4*0*15*4V0*9*4L4T*24*0*5*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*4*4L4T*25*0*3*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*6*4X4T*2*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4T*3*0*15*4T*6*0*6*4W4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*6*0*7*4T*2*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*0*15*4T*15*~1,88,776,0,0,Right|73,128,784,Diving%20%28Sliding%20distance%29%3A%0D%0D%2D%20Performed%20midair%3A%202%2D5%20tiles%0D%2D%20Performed%20walking%3A%202%20tiles%0D%2D%20Performed%20running%3A%203%20tiles%0D%2D%20Exception%3A%20Indefinitely%20on%20ice%20and%20downward%20slopes%20%28%7E%2B45%C2%B0%29|73,160,784,Upward%20slopes%20won%27t%20interfere%20with%20the%20sliding%20distance%2E%20As%20long%20as%20they%27re%20not%20too%20steep%20and%20not%20incomplete%2E|140,304,768,1,180|140,272,768,1,180|140,512,680,1,135|140,576,744,1,135|140,544,712,1,135|140,800,816,1,180|73,864,832,Forward%20flips%20allow%20you%20to%20cross%20pits%20that%20are%202%2D3%20tiles%20wide%2E%20The%20flip%20itself%20is%201%20tile%20in%20height%2E%0D%0DBackflips%20allow%20to%20reach%202%2E5%20tile%20high%20areas%2E|140,1152,704,1,135|140,1184,728,1,135|140,1216,752,1,135|73,1056,752,Like%20with%20walking%2E%20You%20can%20pass%20over%201%2E5%20tile%20wide%20gaps%20while%20diving%2E%0D%0DRunning%20would%20allow%20you%20to%20pass%202%20tile%20wide%20gaps%20even%2E|140,1456,816,1,180|140,1704,488,1,340|140,1520,488,1,340|140,1672,456,1,305|140,1624,440,1,280|140,1504,456,1,320|140,1472,432,1,300|140,1424,416,1,280|140,1296,496,1,340|140,1272,464,1,325|140,1240,432,1,310|140,1200,408,1,295|140,1160,392,1,280|73,704,512,For%20more%20narrow%20passages%20like%20this%20it%27s%20often%20only%20possible%20to%20pass%20these%20with%20a%20combination%20of%20running%20and%20spinning%2E%20%0D%0DIf%20executed%20precisely%20it%27s%20possible%20to%20cross%207%20tile%20wide%20gaps%20with%20this%20setup%2E|140,80,496,1,270|73,352,512,Interestingly%20enough%20there%27s%20exactly%20two%20falling%20curves%20when%20bumping%20into%20a%20wall%2E%20%0D%0DThis%20is%20determined%20at%20the%20moment%20of%20impact%2E%20Whether%20you%27re%20still%20holding%20the%20arrow%20key%20%28here%20left%29%20or%20not%2E|73,352,224,While%20running%20it%27s%20possible%20to%20run%20over%202%20tile%20wide%20gaps%2E%20%0D%0DTry%20falling%20back%20onto%20the%20brown%20tile%20for%20imaginary%20bonus%20points%2E|73,1808,736,Jump%20height%20%28basic%20jump%29%0D%0DNormal%3A%202%20Tiles%20heigh%0DDouble%3A%203%20Tiles%20heigh%0DTriple%3A%204%20Tiles%20heigh%0D%0DEach%20jump%20here%20is%20reduced%20by%20half%20a%20tile%2E%20This%20reduces%20the%20need%20to%20repeat%20jumps%20significantly%2E|73,1760,512,Also%20triple%20jumps%20don%27t%20necessarily%20need%20to%20be%20executed%20at%20the%20exact%20moment%20of%20landing%2E%20It%27s%20alright%20to%20move%20around%20a%20bit%20before%20jumping%20again%2E|140,976,496,1,340|140,952,464,1,325|140,920,432,1,310|140,880,408,1,295|140,840,392,1,280|73,799,224,From%20here%20on%20out%20it%27s%20useful%20to%20combine%20normal%20and%20triple%20jumps%20with%20spinning%20to%20make%20it%20past%20the%20gaps%2E%0D%0D|73,1060,222,When%20combining%20a%20normal%20jump%20with%20spinning%20you%27re%20usually%20able%20to%20travel%20further%20horizontally%20than%20doing%20so%20with%20a%20double%20jump%2E%20%0D%28Unless%20you%20spin%20repeatedly%2E%20Then%20it%27s%20about%20the%20same%20distance%2E%29|73,2016,224,There%27s%20actually%20two%20different%20methods%20for%20spinning%0D%0DThe%20usual%20method%20is%20done%20by%20pressing%20x%2E%0D%0DBut%20if%20you%20ever%20need%20to%20fall%20down%20slowly%2C%20you%20need%20to%20press%20the%20right%20and%20left%20arrows%20repeatedly%2E|73,2592,864,Water%2C%20Fludd%20and%20Enemy%20related%20things%20I%20can%20add%20later%20on%2C%20when%20it%27s%20required%2E%20This%20level%20can%20easily%20be%20extended%20anytime%2E|6,2704,768|73,1424,832,Try%20backflipping%20over%20these%20two%20gaps%2E%20%3A%20%29~7~5~Testing%20Grounds";

onready var ldTileMap = $TileMap;
#var ldTileMap = TileMap.new();

var levelWidth = "";
var levelHeight = "";
var tileNum = 0;

func place_tile(tileID):
	var x = floor(float(tileNum) / float(levelHeight))
	var y = tileNum%levelHeight
	ldTileMap.set_cell(x, y, $"/root/TileRef".tile_ref[tileID] - 1);
	

func _ready():
	var readPhase = 0;
	var readNum = 0;
	var tileID = "";
	var currentChar;
	var multiplier;
	
#	ldTileMap.tile_set = load("res://Tilesets/Bricks.tres");
#	ldTileMap.mode = TileMap.MODE_SQUARE;
#	ldTileMap.cell_size = Vector2(32, 32);
#	ldTileMap.cell_quadrant_size = 16;
	
	#for (var i = 1; i <= string_length(levelCode); ++i)
	var n = 0;
	while n < levelCode.length():
		currentChar = levelCode.substr(n, 1);
		match readPhase:
			0:
				if currentChar == "x":
					levelWidth = int(levelWidth);
					readPhase += 1;
				else:
					levelWidth += currentChar;
			1:
				if currentChar == "~":
					levelHeight = int(levelHeight);
					readPhase += 1;
				else:
					levelHeight += currentChar;
			2:
				tileID += currentChar;
				readNum+=1;
				if readNum == 2 || tileID == "0":
					readNum = 0;
					if levelCode.substr(n+1, 1) == "*":
						readPhase += 1;
						n += 1;
						multiplier = "";
					else:
						place_tile(tileID);
						tileNum += 1;
						tileID = "";
			3:
				multiplier += currentChar;
				if levelCode.substr(n+1, 1) == "*":
					for _i in range(int(multiplier)):
						place_tile(tileID);
						tileNum += 1;
					tileID = "";
					readPhase -= 1;
					n += 1;
		n += 1; #Increment
	
	#$"/root/LevelDesigner".add_child(ldTileMap);
