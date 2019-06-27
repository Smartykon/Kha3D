package kha3d;

import kha.FastFloat;
import kha.math.FastVector3;
import kha.Image;

class MeshObject {
	public var mesh: Mesh;
	public var texture: Image;
	public var pos: FastVector3;
	public var yrotate: FastFloat;

	public function new(mesh: Mesh, texture: Image, pos: FastVector3, yrotate: FastFloat) {
		this.mesh = mesh;
		this.texture = texture;
		this.pos = pos;
		this.yrotate = yrotate;
	}
}
