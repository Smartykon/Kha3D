package kha3d;

import kha.FastFloat;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha3d.ogex.OgexData;

class Mesh {
	static var currentId = 0;
	public var id: Int;
	public var structure: VertexStructure;
	public var vertexBuffer: VertexBuffer;
	public var indexBuffer: IndexBuffer;

	private function new() {
	}

	public static function fromOgex(data: OgexData): Mesh {
		var mesh: Mesh = new Mesh();
		mesh.id = currentId++;
		
		var vertices = data.geometryObjects[0].mesh.vertexArrays[0].values;
		var normals = data.geometryObjects[0].mesh.vertexArrays[1].values;
		var texcoords = data.geometryObjects[0].mesh.vertexArrays[2].values;
		var indices = data.geometryObjects[0].mesh.indexArray.values;
		
		mesh.structure = new VertexStructure();
		mesh.structure.add("pos", VertexData.Float3);
		mesh.structure.add("normal", VertexData.Float3);
		mesh.structure.add("texcoord", VertexData.Float2);

		mesh.vertexBuffer = new VertexBuffer(vertices.length, mesh.structure, Usage.StaticUsage);
		var buffer = mesh.vertexBuffer.lock();
		for (i in 0...Std.int(vertices.length / 3)) {
			buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
			buffer.set(i * 8 + 1, vertices[i * 3 + 1]);
			buffer.set(i * 8 + 2, vertices[i * 3 + 2]);
			buffer.set(i * 8 + 3, normals[i * 3 + 0]);
			buffer.set(i * 8 + 4, normals[i * 3 + 1]);
			buffer.set(i * 8 + 5, normals[i * 3 + 2]);
			buffer.set(i * 8 + 6, texcoords[i * 2 + 0]);
			buffer.set(i * 8 + 7, texcoords[i * 2 + 1]);
		}
		mesh.vertexBuffer.unlock();
		
		mesh.indexBuffer = new IndexBuffer(indices.length, Usage.StaticUsage);
		var ibuffer = mesh.indexBuffer.lock();
		for (i in 0...indices.length) {
			ibuffer[i] = indices[i];
		}
		mesh.indexBuffer.unlock();

		return mesh;
	}

	public static function fromPly(data: PlyData, xo: Int, yo: Int, scale: FastFloat): Mesh {
		var mesh: Mesh = new Mesh();
		mesh.id = currentId++;

		// zo automatisch
		var zo: Int = 2;
		if ((xo == zo) || (yo == zo)) zo--;
		if ((xo == zo) || (yo == zo)) zo--;

		var vertices = data.va.coords;
		var colors   = data.va.colors;
		var normals  = data.va.normals;
		//var normals = data.geometryObjects[0].mesh.vertexArrays[1].values;
		//var texcoords = data.geometryObjects[0].mesh.vertexArrays[2].values;
		var indices = data.ia.values;
		
		mesh.structure = new VertexStructure();
		mesh.structure.add("pos", VertexData.Float3);
		mesh.structure.add("normal", VertexData.Float3); // Sind zumindest nicht in Ply-Dateien aus MagicaVoxel. Müssten noch extra berechnet werden.
		//mesh.structure.add("texcoord", VertexData.Float2); // ply-Dateien aus MagicaVoxel sind untexturiert.
		mesh.structure.add("colors", VertexData.Float3);

		mesh.vertexBuffer = new VertexBuffer(vertices.length, mesh.structure, Usage.StaticUsage);
		var buffer = mesh.vertexBuffer.lock();
		for (i in 0...Std.int(vertices.length / 3)) {
			buffer.set(i * 9 + 0, vertices[i * 3 + xo] * scale);
			buffer.set(i * 9 + 1, vertices[i * 3 + yo] * scale);
			buffer.set(i * 9 + 2, vertices[i * 3 + zo] * scale);

			buffer.set(i * 9 + 3, normals[i * 3 + 0]);
			buffer.set(i * 9 + 4, normals[i * 3 + 1]);
			buffer.set(i * 9 + 5, normals[i * 3 + 2]);
			var cols: UInt = colors[i];
			buffer.set(i * 9 + 6, ( cols        & 255) * (1.0 / 255.0));//texcoords[i * 2 + 0]);
			buffer.set(i * 9 + 7, ((cols >>  8) & 255) * (1.0 / 255.0));//texcoords[i * 2 + 1]);
			buffer.set(i * 9 + 8, ((cols >> 16) & 255) * (1.0 / 255.0));//texcoords[i * 2 + 1]);
		}
		mesh.vertexBuffer.unlock();
		
		mesh.indexBuffer = new IndexBuffer(indices.length, Usage.StaticUsage);
		var ibuffer = mesh.indexBuffer.lock();
		for (i in 0...indices.length) {
			ibuffer[i] = indices[i];
		}
		mesh.indexBuffer.unlock();

		return mesh;
	}
}
