package kha3d.cull;

import kha.FastFloat;
import kha.math.FastVector3;

/* ------------------------------------------------------

 View Frustum - Lighthouse3D

 Quelle:
 http://www.lighthouse3d.com/tutorials/view-frustum-culling/

  -----------------------------------------------------*/

//#include "FrustumG.h"
//#include <math.h>

//#include <GL/glut.h>

//#define ANG2RAD 3.14159265358979323846/180.0

enum FrustumGSide {
    TOP;
    BOTTOM;
    LEFT;
    RIGHT;
    NEARP;
    FARP;
}

enum FrustumGWhere {
    OUTSIDE;
    INTERSECT;
    INSIDE;
}

class FrustumG {
	public var pl: Array<Plane>;

    private static final ANG2RAD: FastFloat = 3.14159265358979323846/180.0;

	public var ntl: FastVector3;
    public var ntr: FastVector3;
    public var nbl: FastVector3;
    public var nbr: FastVector3;
    public var ftl: FastVector3;
    public var ftr: FastVector3;
    public var fbl: FastVector3;
    public var fbr: FastVector3;
	public var nearD: FastFloat;
    public var farD: FastFloat;
    public var ratio: FastFloat;
    public var angle: FastFloat;
    public var tang: FastFloat;
	public var nw: FastFloat;
    public var nh: FastFloat;
    public var fw: FastFloat;
    public var fh: FastFloat;

    public function new() {
        pl = new Array<Plane>();
        for (i in 0...6) pl.push(new Plane());
    }

    public function setCamInternals(angle: FastFloat, ratio: FastFloat, nearD: FastFloat, farD: FastFloat) {
        this.ratio = ratio;
        this.angle = angle;
        this.nearD = nearD;
        this.farD = farD;

        tang = Math.tan(angle * ANG2RAD * 0.5);
        nh = nearD * tang;
        nw = nh * ratio; 
        fh = farD  * tang;
        fw = fh * ratio;
    }

    public function setCamDef(p: FastVector3, l: FastVector3, u: FastVector3) {
        var dir,nc,fc,X,Y,Z: FastVector3;

        Z = p.sub(l);
        Z.normalize();

        X = u.cross(Z);
        X.normalize();

        Y = Z.cross(X);

        nc = p.sub(Z.mult(nearD));
        fc = p.sub(Z.mult(farD));

        ntl = nc.add(Y.mult(nh)).sub(X.mult(nw));
        ntr = nc.add(Y.mult(nh)).add(X.mult(nw));
        nbl = nc.sub(Y.mult(nh)).sub(X.mult(nw));
        nbr = nc.sub(Y.mult(nh)).add(X.mult(nw));

        ftl = fc.add(Y.mult(fh)).sub(X.mult(fw));
        ftr = fc.add(Y.mult(fh)).add(X.mult(fw));
        fbl = fc.sub(Y.mult(fh)).sub(X.mult(fw));
        fbr = fc.sub(Y.mult(fh)).add(X.mult(fw));

        pl[FrustumGSide.TOP.getIndex()].set3Points(ntr,ntl,ftl);
        pl[FrustumGSide.BOTTOM.getIndex()].set3Points(nbl,nbr,fbr);
        pl[FrustumGSide.LEFT.getIndex()].set3Points(ntl,nbl,fbl);
        pl[FrustumGSide.RIGHT.getIndex()].set3Points(nbr,ntr,fbr);
        pl[FrustumGSide.NEARP.getIndex()].set3Points(ntl,ntr,nbr);
        pl[FrustumGSide.FARP.getIndex()].set3Points(ftr,ftl,fbl);
    }

    public function pointInFrustum(p: FastVector3): FrustumGWhere {
        var result: FrustumGWhere = FrustumGWhere.INSIDE;
        for (i in 0...6) {
            if (pl[i].distance(p) < 0.0)
                return FrustumGWhere.OUTSIDE;
        }
        return result;
    }

    public function sphereInFrustum(p: FastVector3, raio: FastFloat): FrustumGWhere {
        var result: FrustumGWhere = FrustumGWhere.INSIDE;
        var distance: FastFloat;
        for (i in 0...6) {
            distance = pl[i].distance(p);
            if (distance < -raio)
                return FrustumGWhere.OUTSIDE;
            else if (distance < raio)
                result = FrustumGWhere.INTERSECT;
        }
        return result;
    }

    public function boxInFrustum(b: AABox): FrustumGWhere {
        var result: FrustumGWhere = FrustumGWhere.INSIDE;
        for (i in 0...6) {
            if (pl[i].distance(b.getVertexP(pl[i].normal)) < 0.0)
                return FrustumGWhere.OUTSIDE;
            else if (pl[i].distance(b.getVertexN(pl[i].normal)) < 0.0)
                result = FrustumGWhere.INTERSECT;
        }
        return result;
    }

    /*public function drawPoints() {
        glBegin(GL_POINTS);

            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(nbl.x,nbl.y,nbl.z);
            glVertex3f(nbr.x,nbr.y,nbr.z);

            glVertex3f(ftl.x,ftl.y,ftl.z);
            glVertex3f(ftr.x,ftr.y,ftr.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);

        glEnd();
    }*/

    /*public function drawLines() {
        glBegin(GL_LINE_LOOP);
        //near plane
            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(nbl.x,nbl.y,nbl.z);
        glEnd();

        glBegin(GL_LINE_LOOP);
        //far plane
            glVertex3f(ftr.x,ftr.y,ftr.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);
        glEnd();

        glBegin(GL_LINE_LOOP);
        //bottom plane
            glVertex3f(nbl.x,nbl.y,nbl.z);
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
        glEnd();

        glBegin(GL_LINE_LOOP);
        //top plane
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);
            glVertex3f(ftr.x,ftr.y,ftr.z);
        glEnd();

        glBegin(GL_LINE_LOOP);
        //left plane
            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(nbl.x,nbl.y,nbl.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);
        glEnd();

        glBegin(GL_LINE_LOOP);
        // right plane
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(ftr.x,ftr.y,ftr.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);

        glEnd();
    }*/

    /*public function drawPlanes() {
        glBegin(GL_QUADS);

        //near plane
            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(nbl.x,nbl.y,nbl.z);

        //far plane
            glVertex3f(ftr.x,ftr.y,ftr.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);

        //bottom plane
            glVertex3f(nbl.x,nbl.y,nbl.z);
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);

        //top plane
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);
            glVertex3f(ftr.x,ftr.y,ftr.z);

        //left plane

            glVertex3f(ntl.x,ntl.y,ntl.z);
            glVertex3f(nbl.x,nbl.y,nbl.z);
            glVertex3f(fbl.x,fbl.y,fbl.z);
            glVertex3f(ftl.x,ftl.y,ftl.z);

        // right plane
            glVertex3f(nbr.x,nbr.y,nbr.z);
            glVertex3f(ntr.x,ntr.y,ntr.z);
            glVertex3f(ftr.x,ftr.y,ftr.z);
            glVertex3f(fbr.x,fbr.y,fbr.z);

        glEnd();
    }*/

    /*public function drawNormals() {
        Vec3 a,b;

        glBegin(GL_LINES);

            // near
            a = (ntr + ntl + nbr + nbl) * 0.25;
            b = a + pl[NEARP].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);

            // far
            a = (ftr + ftl + fbr + fbl) * 0.25;
            b = a + pl[FARP].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);

            // left
            a = (ftl + fbl + nbl + ntl) * 0.25;
            b = a + pl[LEFT].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);
            
            // right
            a = (ftr + nbr + fbr + ntr) * 0.25;
            b = a + pl[RIGHT].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);
            
            // top
            a = (ftr + ftl + ntr + ntl) * 0.25;
            b = a + pl[TOP].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);
            
            // bottom
            a = (fbr + fbl + nbr + nbl) * 0.25;
            b = a + pl[BOTTOM].normal;
            glVertex3f(a.x,a.y,a.z);
            glVertex3f(b.x,b.y,b.z);

        glEnd();
    }*/
}
