package V1;

import I.C0053n;
import J3.i;
import Q3.F;
import Q3.O;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.view.Surface;
import com.swing.live.R;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.atomic.AtomicBoolean;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class e implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2186a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ f f2187b;

    public /* synthetic */ e(f fVar, int i4) {
        this.f2186a = i4;
        this.f2187b = fVar;
    }

    @Override // I3.a
    public final Object a() {
        int i4 = 1;
        switch (this.f2186a) {
            case 0:
                f fVar = this.f2187b;
                fVar.f2194d.v();
                fVar.f2194d.g(2, 2, fVar.getHolder().getSurface(), null);
                fVar.f2193c.v();
                C0053n c0053n = fVar.f2193c;
                int i5 = fVar.f2200q;
                int i6 = fVar.f2201r;
                C0053n c0053n2 = fVar.f2194d;
                c0053n.getClass();
                c0053n.g(i5, i6, null, (EGLContext) c0053n2.f706b);
                fVar.f2194d.p();
                J1.c cVar = fVar.f2192b;
                Context context = fVar.getContext();
                i.d(context, "getContext(...)");
                int i7 = fVar.f2200q;
                int i8 = fVar.f2201r;
                cVar.getClass();
                cVar.e = context;
                cVar.f783a = i7;
                cVar.f784b = i8;
                J1.b bVar = (J1.b) cVar.f785c;
                bVar.e = i7;
                bVar.f772f = i8;
                int iP = H0.a.p(H0.a.E(context, R.raw.simple_vertex), H0.a.E(context, R.raw.camera_fragment));
                bVar.f776j = iP;
                bVar.f779m = GLES20.glGetAttribLocation(iP, "aPosition");
                bVar.f780n = GLES20.glGetAttribLocation(bVar.f776j, "aTextureCoord");
                bVar.f777k = GLES20.glGetUniformLocation(bVar.f776j, "uMVPMatrix");
                bVar.f778l = GLES20.glGetUniformLocation(bVar.f776j, "uSTMatrix");
                bVar.f778l = GLES20.glGetUniformLocation(bVar.f776j, "uSTMatrix");
                int[] iArr = bVar.f773g;
                H0.a.s(iArr, iArr.length, true);
                SurfaceTexture surfaceTexture = new SurfaceTexture(iArr[0]);
                bVar.f781o = surfaceTexture;
                surfaceTexture.setDefaultBufferSize(i7, i8);
                bVar.f782p = new Surface(bVar.f781o);
                C0747k c0747k = bVar.f771d;
                J1.a.a(i7, i8, (int[]) c0747k.f6831b, (int[]) c0747k.f6832c, (int[]) c0747k.f6833d);
                J1.e eVar = (J1.e) cVar.f786d;
                eVar.f802k = i7;
                eVar.f803l = i8;
                eVar.f796d = ((int[]) bVar.f771d.f6833d)[0];
                int iP2 = H0.a.p(H0.a.E(context, R.raw.simple_vertex), H0.a.E(context, R.raw.simple_fragment));
                eVar.e = iP2;
                eVar.f799h = GLES20.glGetAttribLocation(iP2, "aPosition");
                eVar.f800i = GLES20.glGetAttribLocation(eVar.e, "aTextureCoord");
                eVar.f797f = GLES20.glGetUniformLocation(eVar.e, "uMVPMatrix");
                eVar.f798g = GLES20.glGetUniformLocation(eVar.e, "uSTMatrix");
                eVar.f801j = GLES20.glGetUniformLocation(eVar.e, "uSampler");
                ((AtomicBoolean) cVar.f788g).set(true);
                fVar.f2191a.set(true);
                SurfaceTexture surfaceTexture2 = ((J1.b) fVar.f2192b.f785c).f781o;
                i.d(surfaceTexture2, "getSurfaceTexture(...)");
                surfaceTexture2.setOnFrameAvailableListener(fVar);
                b bVar2 = fVar.f2190C;
                e eVar2 = new e(fVar, i4);
                bVar2.getClass();
                if (bVar2.f2180a) {
                    bVar2.f2183d = true;
                    X3.e eVar3 = O.f1596a;
                    bVar2.f2181b = F.s(F.b(X3.d.f2437c), null, new a(bVar2, eVar2, null), 3);
                }
                break;
            default:
                f fVar2 = this.f2187b;
                ThreadPoolExecutor threadPoolExecutor = fVar2.f2188A;
                if (threadPoolExecutor != null) {
                    threadPoolExecutor.execute(new d(fVar2, 1));
                }
                break;
        }
        return w3.i.f6729a;
    }
}
