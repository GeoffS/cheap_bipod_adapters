// Copyright (C) 2025 Geoff Sobering

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program (see the LICENSE file in this directory).  
// If not, see <https://www.gnu.org/licenses/>.

include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>
include <../OpenSCAD_Lib/torus.scad>

layerThickness = 0.2;

recessAdjX = 2;

mountClampOffsetFromFrontZ = 33;
mountClampOffsetFromRearZ = 26;

mountOD = 41.0;
mountCZ = 3.955;
mountZ = mountClampOffsetFromFrontZ + mountClampOffsetFromRearZ + 2*mountCZ;
echo(str("mountZ = ", mountZ));

mountClampX = 2.5 + recessAdjX;
mountClampY = 17.5; //8; //7;
mountClampZ = mountZ + 2; //11;

mountClampCtrPosZ = mountClampOffsetFromRearZ; //mountZ/2; //(mountZ-mountClampZ)/2;

ringScrewHoleDia = 3.4;
ringScrewHoleX = 19;
m3NutDriverOD = 12;
// ringScrewNutDia = 6.4;
ringOD = 13.3;
ringBaseOD = 7.5;
ringBaseExtraX = 0.0; //1.3;
ringX = 3.5;
ringRecessX = 5 + recessAdjX;

ringBaseX = -ringOD/2-ringBaseExtraX;

ringShiftX = -2.5;

zipTieDia = 20;
zipTieChannelDia = 5;
startingAngle = 4.5;

module itemModule()
{
	difference()
	{
		mountExterior();
	}
}

module zipTieSlotTrim(a)
{
	doubleY() rotate([0,0,-a]) tcu([0, 0, -200], 400);
}

module mountExterior()
{
	difference()
	{
		mountOffsetX = 2;
		translate([mountOffsetX,0,0]) difference()
		{
			simpleChamferedCylinderDoubleEnded(d=mountOD, h=mountZ, cz=mountCZ);

			// Take the sharp edge off the clamp recess:
			tcu([mountOD/2-2.5, -200, -200], 400);

			// Barrel groove:
			barrelGrooveDia = 40;
			translate([0, 0, -100]) difference()
			{
				// cylinder(d=barrelGrooveDia, h=400, $fn=4);
				hull() doubleY() rotate([0,0,-36]) tcu([-400, 0, 0], [400, nothing, 400]);

				// Take the sharp edge off the bottom of the barrel-grove:
				tcu([-1.5, -200, -200], 400);
			}

			// Take the sharp edge off the top of the barrel-grove:
			tcu([-400-barrelGrooveDia/2 +4.3, -200, -200], 400);

			// Create the zip-tie slots:
			translate([0, 0, mountClampCtrPosZ]) doubleZ() translate([0, 0, mountClampZ/4]) 
			{
				torus3a(outsideDiameter=zipTieDia, circleDiameter=zipTieChannelDia);

				doubleY()
				{
					slotTube(startingAngle=startingAngle, angleIncrement=0, shift=0);
					slotTube(startingAngle=startingAngle, angleIncrement=-20, shift=4);
					slotTube(startingAngle=startingAngle, angleIncrement=-47, shift=5);
				}
			}
		}

		// Test-print top trim:
		// tcu([-400+4, -200, -200], 400);

		attachmentXform()
		{
			// Mount clamp recess:
			// //    Full length:
			// tcu([-mountClampX, -mountClampY/2, -mountClampZ/2], [mountClampX+10, mountClampY, mountClampZ]);
			//    Just the center:
			tx = nothing;
			y = mountClampY;
			translate([-tx-mountClampX, -y/2, 0]) hull()
			{
				x = 20;
				z = 20;
				tcu([0, 0, -z/2], [tx, y, z]);
				tcu([x, 0, -(z+x)/2], [tx, y, z+x]);
			}

			// Clamp crosspiece recess:
			clampCrosspieceRecessDia = 6;
			translate([-clampCrosspieceRecessDia/2,0,0]) rotate([90,0,0]) rotate([0,0,22.5]) tcy([0,0,-mountClampY/2], d=clampCrosspieceRecessDia, h=mountClampY, $fn=8);

			// Ring recess:
			translate([ringOD/2-ringRecessX+ringShiftX, 0, 0]) 
			{
				translate([-0.2,0,0]) rotate([90,0,0]) hull() torus3(outsideDiameter=ringOD, circleDiameter=ringX);
				translate([ringBaseX,0,0]) rotate([0,90,0]) cylinder(d=ringBaseOD, h=20);
			}

			// Screw hole:
			translate([-ringScrewHoleX,0,0]) rotate([0,90,0]) cylinder(d=ringScrewHoleDia, h=20);

			// Nut driver/socket recess:
			ringScrewHoleZ = 30;
			translate([-ringScrewHoleX+7-ringScrewHoleZ+ringShiftX, 0, 0]) rotate([0,90,0]) translate([0,0,ringScrewHoleZ-20]) hull()
			{
				cylinder(d=m3NutDriverOD, h=20);
				x = m3NutDriverOD + 0.5;
				y = 4;
				z = 20;
				tcu([-x/2, -y/2, 0], [x,y,z]);
			}
		}
	}
}

module slotTube(startingAngle, angleIncrement, shift)
{
	hull()
	{
		rotate([0,0,startingAngle+0.05]) translate([0,-zipTieDia/2+zipTieChannelDia/2,0]) rotate([0,-90,0])
		{
			translate([0,0,shift]) cylinder(d=zipTieChannelDia, h=100);
		}

		rotate([0,0,startingAngle+angleIncrement]) translate([0,-zipTieDia/2+zipTieChannelDia/2,0]) rotate([0,-90,0])
		{
			cylinder(d=zipTieChannelDia, h=100);
		}
	}
}

module attachmentXform()
{
	translate([mountOD/2, 0, mountClampCtrPosZ]) children();
}

module torusSlot(insideDiameter, outsideShift, circleDiameter)
{
	echo("torusSlot insideDiameter, outsideShift, circleDiameter", insideDiameter, outsideShift, circleDiameter);
  	circleRadius = circleDiameter/2;
	
  	rotate_extrude(convexity = 4)
		translate([insideDiameter/2-circleRadius, 0, 0]) projection() translate([0,0,-0.5]) hull()
		{
			cylinder(r = circleRadius, h=1);
			translate([outsideShift,0,0]) cylinder(r = circleRadius, h=1);
		}
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
	// tcu([-200, -200, mountClampCtrPosZ-nothing], 400);
	// tcu([-200, -200, mountClampCtrPosZ-400+nothing], 400);
	// tcu([-200, -200, -nothing], 400);
	
	// tcu([-200, -200, mountClampCtrPosZ+mountClampZ/4-d], 400);
}

if(developmentRender)
{
	display() itemModule();
	// displayGhost() Crossman2240XL_Receiver_Tube();
	displayGhost() MaxBarrelDia();

	//display() translate([0,0,-2]) torusSlot(outsideDiameter=40, insideDiameter=10, circleDiameter=4);
}
else
{
	itemModule();
}

barrelOffsetZ = 20;
barrelZ = mountZ + 2*barrelOffsetZ;
module Crossman2240XL_Receiver_Tube()
{
	dia = 22.4;
	%tcy([-17, 0, -barrelOffsetZ], d=dia, h=barrelZ);
}

module MaxBarrelDia()
{
	dia = 19;
	tcy([-14.2, 0, -barrelOffsetZ], d=dia, h=barrelZ);
}
