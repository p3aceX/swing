package D2;

import android.R;
import android.content.Context;
import android.graphics.Matrix;
import android.util.TypedValue;
import android.view.MotionEvent;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;

/* JADX INFO: renamed from: D2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0026a {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final Matrix f177f = new Matrix();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final io.flutter.embedding.engine.renderer.j f178a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final v f179b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f180c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashMap f181d = new HashMap();
    public int e;

    public C0026a(io.flutter.embedding.engine.renderer.j jVar, boolean z4) {
        this.f178a = jVar;
        if (v.f258d == null) {
            v.f258d = new v(1);
        }
        this.f179b = v.f258d;
        this.f180c = z4;
    }

    public static int b(int i4) {
        if (i4 == 0) {
            return 4;
        }
        if (i4 != 1) {
            if (i4 == 5) {
                return 4;
            }
            if (i4 != 6) {
                if (i4 == 2) {
                    return 5;
                }
                if (i4 != 7) {
                    if (i4 == 3) {
                        return 0;
                    }
                    if (i4 != 8) {
                        return -1;
                    }
                }
                return 3;
            }
        }
        return 6;
    }

    /*  JADX ERROR: JadxRuntimeException in pass: IfRegionVisitor
        jadx.core.utils.exceptions.JadxRuntimeException: Can't remove SSA var: r14v7 int, still in use, count: 2, list:
          (r14v7 int) from 0x00a3: IF  (r14v7 int) == (-1 int)  -> B:4:0x000f A[HIDDEN] (LINE:164)
          (r14v7 int) from 0x00a9: PHI (r14v2 int) = (r14v1 int), (r14v7 int) binds: [B:42:0x00a7, B:40:0x00a3] A[DONT_GENERATE, DONT_INLINE]
        	at jadx.core.utils.InsnRemover.removeSsaVar(InsnRemover.java:162)
        	at jadx.core.utils.InsnRemover.unbindResult(InsnRemover.java:127)
        	at jadx.core.dex.visitors.regions.TernaryMod.makeTernaryInsn(TernaryMod.java:114)
        	at jadx.core.dex.visitors.regions.TernaryMod.processRegion(TernaryMod.java:62)
        	at jadx.core.dex.visitors.regions.TernaryMod.visitRegion(TernaryMod.java:53)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseIterativeStepInternal(DepthRegionTraversal.java:77)
        	at jadx.core.dex.visitors.regions.DepthRegionTraversal.traverseIterativeStepInternal(DepthRegionTraversal.java:82)
        */
    public final void a(android.view.MotionEvent r29, int r30, int r31, int r32, android.graphics.Matrix r33, java.nio.ByteBuffer r34, android.content.Context r35) {
        /*
            Method dump skipped, instruction units count: 644
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.C0026a.a(android.view.MotionEvent, int, int, int, android.graphics.Matrix, java.nio.ByteBuffer, android.content.Context):void");
    }

    public final int c(Context context) {
        if (this.e == 0) {
            TypedValue typedValue = new TypedValue();
            if (!context.getTheme().resolveAttribute(R.attr.listPreferredItemHeight, typedValue, true)) {
                return 48;
            }
            this.e = (int) typedValue.getDimension(context.getResources().getDisplayMetrics());
        }
        return this.e;
    }

    public final void d(MotionEvent motionEvent, Matrix matrix) {
        int actionMasked = motionEvent.getActionMasked();
        int iB = b(motionEvent.getActionMasked());
        char c5 = 5;
        boolean z4 = actionMasked == 0 || actionMasked == 5;
        boolean z5 = !z4 && (actionMasked == 1 || actionMasked == 6);
        int toolType = motionEvent.getToolType(motionEvent.getActionIndex());
        if (toolType == 1) {
            c5 = 0;
        } else if (toolType == 2) {
            c5 = 2;
        } else if (toolType == 3) {
            c5 = 1;
        } else if (toolType == 4) {
            c5 = 3;
        }
        int i4 = (z5 && c5 == 0) ? 1 : 0;
        int pointerCount = motionEvent.getPointerCount();
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect((pointerCount + i4) * 288);
        byteBufferAllocateDirect.order(ByteOrder.LITTLE_ENDIAN);
        if (z4) {
            a(motionEvent, motionEvent.getActionIndex(), iB, 0, matrix, byteBufferAllocateDirect, null);
        } else if (z5) {
            for (int i5 = 0; i5 < pointerCount; i5++) {
                if (i5 != motionEvent.getActionIndex() && motionEvent.getToolType(i5) == 1) {
                    a(motionEvent, i5, 5, 1, matrix, byteBufferAllocateDirect, null);
                }
            }
            a(motionEvent, motionEvent.getActionIndex(), iB, 0, matrix, byteBufferAllocateDirect, null);
            if (i4 != 0) {
                a(motionEvent, motionEvent.getActionIndex(), 2, 0, matrix, byteBufferAllocateDirect, null);
            }
        } else {
            for (int i6 = 0; i6 < pointerCount; i6++) {
                a(motionEvent, i6, iB, (pointerCount << 8) | 2, matrix, byteBufferAllocateDirect, null);
            }
        }
        if (byteBufferAllocateDirect.position() % 288 != 0) {
            throw new AssertionError("Packet position is not on field boundary");
        }
        this.f178a.f4535a.dispatchPointerDataPacket(byteBufferAllocateDirect, byteBufferAllocateDirect.position());
    }
}
