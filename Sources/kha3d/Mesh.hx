package kha3d;

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

	public static function fromPly(data: PlyData): Mesh {
		var mesh: Mesh = new Mesh();
		mesh.id = currentId++;

		var vertices = data.va.coords;
		//var normals = data.geometryObjects[0].mesh.vertexArrays[1].values;
		//var texcoords = data.geometryObjects[0].mesh.vertexArrays[2].values;
		var indices = data.ia.values;
		
		mesh.structure = new VertexStructure();
		mesh.structure.add("pos", VertexData.Float3);
		mesh.structure.add("normal", VertexData.Float3); // Sind zumindest nicht in Ply-Dateien aus MagicaVoxel. Müssten noch extra berechnet werden.
		mesh.structure.add("texcoord", VertexData.Float2); // ply-Dateien aus MagicaVoxel sind untexturiert.

		mesh.vertexBuffer = new VertexBuffer(vertices.length, mesh.structure, Usage.StaticUsage);
		var buffer = mesh.vertexBuffer.lock();
		for (i in 0...Std.int(vertices.length / 3)) {
			//buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
			//buffer.set(i * 8 + 1, vertices[i * 3 + 1]);
			//buffer.set(i * 8 + 2, vertices[i * 3 + 2]);

			// Für MagicaVoxel: Koordinaten etwas umsortieren...
			buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
			buffer.set(i * 8 + 1, vertices[i * 3 + 2]);
			buffer.set(i * 8 + 2, vertices[i * 3 + 1]);

			buffer.set(i * 8 + 3, 0.0);//normals[i * 3 + 0]);
			buffer.set(i * 8 + 4, 1.0);//normals[i * 3 + 1]);
			buffer.set(i * 8 + 5, 0.0);//normals[i * 3 + 2]);
			buffer.set(i * 8 + 6, 0.0);//texcoords[i * 2 + 0]);
			buffer.set(i * 8 + 7, 0.0);//texcoords[i * 2 + 1]);
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
