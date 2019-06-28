package kha3d;

import js.html.Console;
import kha.FastFloat;
import kha.math.Vector3;
import kha.Canvas;
import kha.System;
import kha.Image;
import kha.math.FastMatrix4;
import kha.graphics4.Graphics;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.math.FastVector3;
import kha.Shaders;

class Scene {
	//public static var heightMap: HeightMap = null;
	public static var meshes: Array<MeshObject> = [];
	public static var splines: Array<SplineMesh> = [];
	public static var lights: Array<FastVector3> = [];

	// PDBikeForest:
	public static var land_grid_mesh: LandGridMesh;
	public static var street_mesh   : StreetNetMesh;

	public static var instancedStructure: VertexStructure;
	static var instancedVertexBuffer: VertexBuffer;
	static var mesh_pipeline: PipelineState; // Vormals nur "pipeline"
	static var mvp: ConstantLocation;
	static var texUnit: TextureUnit;

	static var colors: Image;
	static var depth: Image;
	static var normals: Image;
	static var image: Image;

	static var render_w: Int;
	static var render_h: Int;

	public static function init(_render_w: Int, _render_h: Int) {
		render_w = _render_w;
		render_h = _render_h;

		Lights.init();

		instancedStructure = new VertexStructure();
		instancedStructure.add("meshpos", VertexData.Float3);
		instancedStructure.add("yrotate", VertexData.Float1);

		instancedVertexBuffer = new VertexBuffer(meshes.length, instancedStructure, Usage.DynamicUsage, 1);

		mesh_pipeline = new PipelineState();
		mesh_pipeline.inputLayout = [meshes[0].mesh.structure, instancedStructure];
		mesh_pipeline.vertexShader = Shaders.mesh_vert;
		mesh_pipeline.fragmentShader = Shaders.mesh_frag;
		mesh_pipeline.depthWrite = true;
		mesh_pipeline.depthMode = CompareMode.Less;
		mesh_pipeline.cullMode = CounterClockwise;//Clockwise;
		mesh_pipeline.compile();
		
		mvp = mesh_pipeline.getConstantLocation("mvp");
		texUnit = mesh_pipeline.getTextureUnit("erde1");

		colors = depth = Image.createRenderTarget(render_w, render_h, RGBA32, Depth32Stencil8);
		normals = Image.createRenderTarget(render_w, render_h, RGBA32, NoDepthAndStencil);
		image = Image.createRenderTarget(render_w, render_h, RGBA32, NoDepthAndStencil);

		TextureViewer.init();

		Shadows.init();
	}

	static function setBuffers(g: Graphics, mesh: Mesh): Void {
		g.setIndexBuffer(mesh.indexBuffer);
		g.setVertexBuffers([mesh.vertexBuffer, instancedVertexBuffer]);
	}

	static function draw(g: Graphics, mesh: Mesh, instanceCount: Int): Void {
		g.drawIndexedVerticesInstanced(instanceCount, 0, mesh.indexBuffer.count());
	}

	public static function renderMeshes(g: Graphics, mvp: FastMatrix4, mv: FastMatrix4, vp: FastMatrix4, comboMatrix: FastMatrix4, image: Image, rotate_all: FastFloat): Void {
		//var planes = Culling.perspectiveToPlanes(vp);
		//var planes = Culling.perspectiveToPlanes(comboMatrix);
	//public static function renderMeshes(g: Graphics, mvp: FastMatrix4, mv: FastMatrix4, vp: FastMatrix4, image: Image): Void {
		g.setPipeline(mesh_pipeline);
		g.setMatrix(Scene.mvp, mvp);
		g.setTexture(texUnit, image);

		var planes = Culling.perspectiveToPlanes(vp);
		
		var instanceIndex = 0;
		var lastMesh: Mesh = null;
		var b2 = null;
		for (mesh in meshes) {
			if (Culling.aabbInFrustum(planes, mesh.pos, mesh.pos)) {
				if (mesh.mesh != lastMesh) {
					if (instanceIndex > 0) {
						instancedVertexBuffer.unlock();
						draw(g, lastMesh, instanceIndex);
					}
					setBuffers(g, mesh.mesh);
					b2 = instancedVertexBuffer.lock();
					instanceIndex = 0;
					lastMesh = mesh.mesh;
				}
				b2.set(instanceIndex * 4 + 0, mesh.pos.x);
				b2.set(instanceIndex * 4 + 1, mesh.pos.y);
				b2.set(instanceIndex * 4 + 2, mesh.pos.z);
				b2.set(instanceIndex * 4 + 3, rotate_all);//mesh.yrotate);
				++instanceIndex;
			}
		}

		if (instanceIndex > 0) {
			instancedVertexBuffer.unlock();
			draw(g, lastMesh, instanceIndex);
		}
	}

	public static function renderGBuffer(mvp: FastMatrix4, mv: FastMatrix4, vp: FastMatrix4, comboMatrix: FastMatrix4, meshImage: Image, splineImage: Image, rotate_all: FastFloat) {//, heightsImage: Image) {
		var g = colors.g4;
		g.begin([normals]);
		g.clear(0xff00ffff, Math.POSITIVE_INFINITY);
		//if (heightMap != null) {
		//	heightMap.render(g, mvp, mv);
		//}
		// PDBikeForest
		if (land_grid_mesh != null) {
			land_grid_mesh.render(g, mvp);
		}
		if (street_mesh != null) {
			street_mesh.render(g, mvp);
		}
		//
		//for (spline in splines) {
		//	spline.render(g, mvp, mv, splineImage, heightsImage);
		//}
		renderMeshes(g, mvp, mv, vp, comboMatrix, meshImage, rotate_all);
		g.end();
	}

	public static function renderImage(suneye: FastVector3, sunat: FastVector3, mvp: FastMatrix4, inv: FastMatrix4, sunMvp: FastMatrix4) {
		var g = image.g4;
		g.begin();
		g.clear(0);
		var sunDir = suneye.sub(sunat);
		sunDir.normalize();
		Lights.render(g, colors, normals, depth, Shadows.shadowMap, inv, sunMvp, mvp, sunDir);
		g.end();
	}

	public static function render1(position: FastVector3, direction: FastVector3, rotate_all: FastFloat) {
	//public static function render(frame: Canvas, position: Vector3, direction: Vector3) {
		meshes.sort(function (a, b) {
			return a.mesh.id - b.mesh.id;
		});

		var model = FastMatrix4.identity(); // FastMatrix4.rotationY(Scheduler.time());
		var view = FastMatrix4.lookAt(position, position.add(direction), new FastVector3(0, 1, 0));
		var projection = FastMatrix4.perspectiveProjection(45, render_w / render_h, 0.1, 550.0);

		var suneye = new FastVector3(position.x + 50.0, 150.0, position.z - 100.0);
		var sunat = new FastVector3(position.x, 0, position.z);
		var sunview = FastMatrix4.lookAt(suneye, sunat, new FastVector3(0, 0, 1));
		var sunprojection = FastMatrix4.orthogonalProjection(-100, 100, -100, 100, 1.0, 300.0);

		var mv = view.multmat(model);
		var mvp = projection.multmat(view).multmat(model);
		var inv = mvp.inverse();

		var comboMatrix = projection.multmat( view );
		//var comboMatrix =  projection.multmat( mv );

		var sunMvp = sunprojection.multmat(sunview).multmat(model);

		Shadows.render(sunMvp);

		var mesh0_texture: Image = null; if (meshes.length >= 1) mesh0_texture = meshes[0].texture;
		var spline0_texture: Image = null; if (splines.length >= 1) spline0_texture = splines[0].texture;
		Scene.renderGBuffer(mvp, mv, projection.multmat(view), comboMatrix, mesh0_texture, spline0_texture, rotate_all);//, heightMap.heightsImage);
		
		Scene.renderImage(suneye, sunat, mvp, inv, sunMvp);
	}

	public static function render2(g4: Graphics, position: FastVector3, direction: FastVector3) {
		var debug_w: Int = render_w * 2;
		var debug_h: Int = render_h * 2;
		TextureViewer.render(g4, colors, false, 0, 0, debug_w, debug_h);
		TextureViewer.render(g4, depth, true, debug_w, 0, debug_w, debug_h);
		//TextureViewer.render(g, shadowMap, true, 0, 0, 1, 1);
		TextureViewer.render(g4, normals, false, 0, debug_h, debug_w, debug_h);
		TextureViewer.render(g4, image, false, debug_w, debug_h, debug_w, debug_h);
	}
}
