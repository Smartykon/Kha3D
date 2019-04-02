package kha3d;

import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.FastFloat;
import kha.math.FastMatrix4;
import kha.Image;
import kha.Shaders;
import kha.System;

class TextureViewer {
	static var pipeline: PipelineState;
	static var vertexBuffer: VertexBuffer;
	static var indexBuffer: IndexBuffer;
	static var tex: TextureUnit;
	static var isDepth: ConstantLocation;
	static var projectionMatrix: FastMatrix4;
	static var projectionLocation: ConstantLocation;

	public static function init() {
		var structure = new VertexStructure();
		structure.add("pos", Float2);
		structure.add("tex", Float2);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.texdebug_vert;
		pipeline.fragmentShader = Shaders.texdebug_frag;
		pipeline.compile();

		vertexBuffer = new VertexBuffer(4, structure, DynamicUsage);
		var vertices = vertexBuffer.lock();
		vertices.set(0, -1); vertices.set(1, -1); vertices.set(2, 0); vertices.set(3, 0);
		vertices.set(4, 1); vertices.set(5, -1); vertices.set(6, 1); vertices.set(7, 0);
		vertices.set(8, -1); vertices.set(9, 1); vertices.set(10, 0); vertices.set(11, 1);
		vertices.set(12, 1); vertices.set(13, 1); vertices.set(14, 1); vertices.set(15, 1);
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(6, StaticUsage);
		var indices = indexBuffer.lock();
		indices.set(0, 0); indices.set(1, 1); indices.set(2, 2);
		indices.set(3, 1); indices.set(4, 3); indices.set(5, 2);
		indexBuffer.unlock();

		tex = pipeline.getTextureUnit("image");
		isDepth = pipeline.getConstantLocation("isDepth");
		projectionLocation = pipeline.getConstantLocation("projectionMatrix");

		projectionMatrix = FastMatrix4.orthogonalProjection(0.0, System.windowWidth(0), System.windowHeight(0), 0.0, 0.1, 550.0);
	}

	public static function render(g: Graphics, image: Image, depth: Bool, x: Float, y: Float, w: Float, h: Float) {
		var vertices = vertexBuffer.lock();
		vertices.set( 0, x    ); vertices.set( 1, y    ); vertices.set( 2, 0); vertices.set( 3, 1);
		vertices.set( 4, x + w); vertices.set( 5, y    ); vertices.set( 6, 1); vertices.set( 7, 1);
		vertices.set( 8, x    ); vertices.set( 9, y + h); vertices.set(10, 0); vertices.set(11, 0);
		vertices.set(12, x + w); vertices.set(13, y + h); vertices.set(14, 1); vertices.set(15, 0);
		vertexBuffer.unlock();

		g.setPipeline(pipeline);
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		var bilinear: Bool = false;
		g.setTextureParameters(tex, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
		g.setMatrix(projectionLocation, projectionMatrix);
		if (depth) {
			g.setTextureDepth(tex, image);
		}
		else {
			g.setTexture(tex, image);
		}
		g.setBool(isDepth, depth);
		g.drawIndexedVertices();
	}
}
