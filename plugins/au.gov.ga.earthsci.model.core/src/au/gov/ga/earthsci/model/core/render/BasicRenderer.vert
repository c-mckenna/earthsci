#version 110

// Vertex shader for the BasicRenderer
//
// Takes vertices in geographic decimal degrees coordinates and projects them into 
// cartesian coordinates
// 
// @author Michael de Hoog (michael.dehoog@ga.gov.au)
// @author James Navin (james.navin@ga.gov.au)
 
uniform float opacity; // Opacity in range [0,1] 

uniform float radius; //globe radius
uniform float es; //eccentricity squared
uniform float ve; //vertical exaggeration
uniform float zNodata; //nodata mask encoded in Z values

varying float mask;

vec3 geodeticToCartesian(vec3 geodetic, vec4 cosSinLatLon)
{
    float rpm = radius / sqrt(1.0 - es * cosSinLatLon.y * cosSinLatLon.y);
    float x = (rpm + geodetic.z) * cosSinLatLon.x * cosSinLatLon.w;
    float y = (rpm * (1.0 - es) + geodetic.z) * cosSinLatLon.y;
    float z = (rpm + geodetic.z) * cosSinLatLon.x * cosSinLatLon.z;
    return vec3(x, y, z);
}
 
void main(void)
{
	vec3 geodetic = vec3(radians(gl_Vertex.xy), ve * gl_Vertex.z);
	
	// Mask will be 0 where Z == zNodata; 1 everywhere else.
	mask = 1 - step(zNodata, gl_Vertex.z) * step(gl_Vertex.z, zNodata); 
	
	//calculate the sine and cosine of the latitude/longitude angles
	vec4 cosSinLatLon = vec4(cos(geodetic.y), sin(geodetic.y), cos(geodetic.x), sin(geodetic.x));
	
	//project the geodetic coordinates to cartesian space
	vec3 cartesian = geodeticToCartesian(geodetic, cosSinLatLon);

	gl_FrontColor = vec4(gl_Color.rgb, gl_Color.a * opacity);

	//output the vertex position
	gl_Position = gl_ModelViewProjectionMatrix * vec4(cartesian, 1.0);
}