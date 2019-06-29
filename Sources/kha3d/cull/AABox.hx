package kha3d.cull;

// Quelle:
// http://www.lighthouse3d.com/tutorials/view-frustum-culling/

import kha.FastFloat;
import kha.math.FastVector3;

class AABox {
	public var corner: FastVector3;
	public var x: FastFloat;
    public var y: FastFloat;
    public var z: FastFloat;

    static public function new1(corner: FastVector3, x: FastFloat, y: FastFloat, z: FastFloat): AABox {
        var b: AABox = new AABox();
        b.setBox(corner, x, y, z);
        return b;
    }

    public function new() {
        corner = new FastVector3(0.0, 0.0, 0.0);
        x = 1.0;
        y = 1.0;
        z = 1.0;
    }

    public function setBox(corner: FastVector3, x: FastFloat, y: FastFloat, z: FastFloat) {
        this.corner.setFrom(corner);
        if (x < 0.0) {
            x = -x;
            this.corner.x -= x;
        }
        if (y < 0.0) {
            y = -y;
            this.corner.y -= y;
        }
        if (z < 0.0) {
            z = -z;
            this.corner.z -= z;
        }
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function getVertexP(normal: FastVector3): FastVector3 {
        var res: FastVector3 = new FastVector3(corner.x, corner.y, corner.z);
        if (normal.x > 0) res.x += x;
        if (normal.y > 0) res.y += y;
        if (normal.z > 0) res.z += z;
        return res;
    }

    public function getVertexN(normal: FastVector3): FastVector3 {
        var res: FastVector3 = new FastVector3(corner.x, corner.y, corner.z);
        if (normal.x < 0) res.x += x;
        if (normal.y < 0) res.y += y;
        if (normal.z < 0) res.z += z;
        return res;
    }
}
