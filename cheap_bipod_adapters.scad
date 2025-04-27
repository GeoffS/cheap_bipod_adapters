include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>
include <../OpenSCAD_Lib/torus.scad>

layerThickness = 0.2;

mountOD = 37.5;
mountZ = 18; //70;
mountCZ = 4;

mountClampX = 3.5;
mountClampY = 17.5; //8; //7;
mountClampZ = 11;

mountClampCtrPosZ = mountZ/2; //(mountZ-mountClampZ)/2;

ringScrewHoleDia = 3.4;
ringScrewHoleX = 17;
ringScrewNutDia = 6.2;
ringOD = 13.3;
ringBaseOD = 7.5;
ringBaseExtraX = 1.3;
ringX = 3.5;
ringRecessX = 5;

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
		rotate([0,0,22.5]) simpleChamferedCylinderDoubleEnded(d=mountOD, h=mountZ, cz =mountCZ, $fn=8);

		attachmentXform()
		{
			// Mount clamp recess:
			//tcu([-mountClampX, -mountClampY/2, -mountClampZ/2], [mountClampX+10, mountClampY, mountClampZ]);
			tcu([-mountClampX, -200, -200], 400);

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

	// Sacrificial layer:
	attachmentXform() translate([ringOD/2-ringRecessX+ringBaseX-layerThickness,0,0]) rotate([0,90,0]) cylinder(d=ringScrewHoleDia+2, h=layerThickness);
}

module attachmentXform()
{
	translate([mountOD/2 ,0, mountClampCtrPosZ]) children();
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
	// tcu([-200, -200, mountClampCtrPosZ-nothing], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	rotate([0,90,0]) itemModule();
}
