package androidx.datastore.preferences.protobuf;

import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public final class e0 extends g0 {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f2966b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ e0(Unsafe unsafe, int i4) {
        super(unsafe);
        this.f2966b = i4;
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final boolean c(Object obj, long j4) {
        switch (this.f2966b) {
            case 0:
                if (!h0.f2984g) {
                }
                break;
            default:
                if (!h0.f2984g) {
                }
                break;
        }
        return h0.c(obj, j4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final double d(Object obj, long j4) {
        switch (this.f2966b) {
        }
        return Double.longBitsToDouble(g(obj, j4));
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final float e(Object obj, long j4) {
        switch (this.f2966b) {
        }
        return Float.intBitsToFloat(f(obj, j4));
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void j(Object obj, long j4, boolean z4) {
        switch (this.f2966b) {
            case 0:
                if (!h0.f2984g) {
                    h0.l(obj, j4, z4 ? (byte) 1 : (byte) 0);
                } else {
                    h0.k(obj, j4, z4 ? (byte) 1 : (byte) 0);
                }
                break;
            default:
                if (!h0.f2984g) {
                    h0.l(obj, j4, z4 ? (byte) 1 : (byte) 0);
                } else {
                    h0.k(obj, j4, z4 ? (byte) 1 : (byte) 0);
                }
                break;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void k(Object obj, long j4, byte b5) {
        switch (this.f2966b) {
            case 0:
                if (!h0.f2984g) {
                    h0.l(obj, j4, b5);
                } else {
                    h0.k(obj, j4, b5);
                }
                break;
            default:
                if (!h0.f2984g) {
                    h0.l(obj, j4, b5);
                } else {
                    h0.k(obj, j4, b5);
                }
                break;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void l(Object obj, long j4, double d5) {
        switch (this.f2966b) {
            case 0:
                o(obj, j4, Double.doubleToLongBits(d5));
                break;
            default:
                o(obj, j4, Double.doubleToLongBits(d5));
                break;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void m(Object obj, long j4, float f4) {
        switch (this.f2966b) {
            case 0:
                n(obj, Float.floatToIntBits(f4), j4);
                break;
            default:
                n(obj, Float.floatToIntBits(f4), j4);
                break;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final boolean r() {
        switch (this.f2966b) {
        }
        return false;
    }
}
