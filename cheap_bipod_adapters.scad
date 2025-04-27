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

recessAdjX = 5;

mountOD = 37.5;
mountZ = 23; //70;
mountCZ = 4;

mountClampX = 2.5 + recessAdjX;
mountClampY = 17.5; //8; //7;
mountClampZ = 11;

mountClampCtrPosZ = mountZ/2; //(mountZ-mountClampZ)/2;

ringScrewHoleDia = 3.4;
ringScrewHoleX = 19;
ringScrewNutDia = 6.4;
ringOD = 13.3;
ringBaseOD = 7.5;
ringBaseExtraX = 1.3;
ringX = 3.5;
ringRecessX = 5 + recessAdjX;

ringBaseX = -ringOD/2-ringBaseExtraX;

module itemModule()
{
	difference()
	{
		mountExterior();
	}
}

module mountExterior()
{
	difference()
	{
		scale([1.0, 1.4, 1.0]) rotate([0,0,22.5]) simpleChamferedCylinderDoubleEnded(d=mountOD, h=mountZ, cz =mountCZ, $fn=8);

		// Temporary top trim:
		tcu([-400, -200, -200], 400);

		attachmentXform()
		{
			// Mount clamp recess:
			tcu([-mountClampX, -mountClampY/2, -mountClampZ/2], [mountClampX+10, mountClampY, mountClampZ]);
			//tcu([-mountClampX, -200, -200], 400);

			// Ring recess:
			translate([ringOD/2-ringRecessX, 0, 0]) 
			{
				rotate([90,0,0]) hull() torus3(outsideDiameter=ringOD, circleDiameter=ringX);
				translate([ringBaseX,0,0]) rotate([0,90,0]) cylinder(d=ringBaseOD, h=20);
			}

			// Screw hole:
			translate([-ringScrewHoleX,0,0]) rotate([0,90,0]) cylinder(d=ringScrewHoleDia, h=20);

			// Nut recess:
			holeZ = 30;
			translate([-ringScrewHoleX+4-holeZ, 0, 0]) rotate([0,90,0]) 
			{
				// Nut recess:
				cylinder(d=ringScrewNutDia, h=holeZ, $fn=6);
				// Access recess:
				tcy([0,0,-5], d=ringScrewNutDia+1, h=holeZ);
			}
		}
	}

	// Sacrificial layers:
	attachmentXform() 
	{
		// Bottom of nut recess:
		translate([ringOD/2-ringRecessX+ringBaseX-layerThickness,0,0]) rotate([0,90,0]) cylinder(d=ringScrewHoleDia+2, h=layerThickness);
		// Top of clamp recess:
		translate([-mountClampX-layerThickness, 0, 0]) rotate([0,90,0]) cylinder(d=12, h=layerThickness);
	}

}

module attachmentXform()
{
	translate([mountOD/2 ,0, mountClampCtrPosZ]) children();
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
	tcu([-200, -200, mountClampCtrPosZ-nothing], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	rotate([0,90,0]) itemModule();
}
