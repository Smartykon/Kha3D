package kha3d.cull;

// Quelle:
// http://www.lighthouse3d.com/tutorials/view-frustum-culling/

import js.html.Console;
import kha.FastFloat;
import kha.math.FastVector3;

class Plane {
	public var normal: FastVector3;
    public var point: FastVector3;
	public var d: FastFloat;

    public function new() {
        point = new FastVector3(0.0, 0.0, 0.0);
    }

    public static function new1(v1: FastVector3, v2: FastVector3, v3: FastVector3): Plane {
        var p: Plane = new Plane();
        p.set3Points(v1,v2,v3);
        return p;
    }

    public function set3Points(v1: FastVector3, v2: FastVector3, v3: FastVector3) {
        var aux1: FastVector3;
        var aux2: FastVector3;

        aux1 = v1.sub(v2);
        aux2 = v3.sub(v2);

        normal = aux2.cross(aux1);

        normal.normalize();
        point.setFrom(v2);
        d = -(normal.dot(point));
    }

    public function setNormalAndPoint(normal: FastVector3, point: FastVector3) {
        this.normal.setFrom(normal);
        this.normal.normalize();
        d = -(this.normal.dot(point));
    }

     public function setCoefficients(a: FastFloat, b: FastFloat, c: FastFloat, d: FastFloat) {
        // set the normal vector
        normal = new FastVector3(a,b,c);
        //compute the lenght of the vector
        var l: FastFloat = normal.dot(normal);
        // normalize the vector
        normal = new FastVector3(a/l,b/l,c/l);
        // and divide d by th length as well
        this.d = d/l;
    }

    public function distance(p: FastVector3): FastFloat {
        return (d + normal.dot(p));
    }

    public function print() {
        Console.log("Plane(" + "Vec3(" + normal.x + ", " + normal.y + ", " + normal.z + "), " + d + ")");
    }
}
