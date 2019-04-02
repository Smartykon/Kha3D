package kha3d;

import kha.FastFloat;
import kha.math.FastVector3;

class Plane {
	public var normal: FastVector3;
	public var d: FastFloat;

	public function new() {
		normal = new FastVector3();
	}

	public function normalize() {
		var mag: FastFloat;
		mag = Math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
		normal.x = normal.x / mag;
		normal.y = normal.y / mag;
		normal.z = normal.z / mag;
		d = d / mag;
	}

	public function normalizeN() {
		// Nur die Normale
		var mag: FastFloat;
		mag = Math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
		normal.x = normal.x / mag;
		normal.y = normal.y / mag;
		normal.z = normal.z / mag;
	}
}
