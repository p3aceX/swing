package com.google.crypto.tink.shaded.protobuf;

import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public final class l0 extends n0 {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f3816b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ l0(Unsafe unsafe, int i4) {
        super(unsafe);
        this.f3816b = i4;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final boolean c(Object obj, long j4) {
        switch (this.f3816b) {
            case 0:
                if (o0.f3826g) {
                    if (o0.h(obj, j4) == 0) {
                    }
                } else if (o0.i(obj, j4) == 0) {
                }
                break;
            default:
                if (o0.f3826g) {
                    if (o0.h(obj, j4) == 0) {
                    }
                } else if (o0.i(obj, j4) == 0) {
                }
                break;
        }
        return false;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final byte d(Object obj, long j4) {
        switch (this.f3816b) {
            case 0:
                if (!o0.f3826g) {
                }
                break;
            default:
                if (!o0.f3826g) {
                }
                break;
        }
        return o0.i(obj, j4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final double e(Object obj, long j4) {
        switch (this.f3816b) {
        }
        return Double.longBitsToDouble(h(obj, j4));
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final float f(Object obj, long j4) {
        switch (this.f3816b) {
        }
        return Float.intBitsToFloat(g(obj, j4));
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void k(Object obj, long j4, boolean z4) {
        switch (this.f3816b) {
            case 0:
                if (!o0.f3826g) {
                    o0.m(obj, j4, z4 ? (byte) 1 : (byte) 0);
                } else {
                    o0.l(obj, j4, z4 ? (byte) 1 : (byte) 0);
                }
                break;
            default:
                if (!o0.f3826g) {
                    o0.m(obj, j4, z4 ? (byte) 1 : (byte) 0);
                } else {
                    o0.l(obj, j4, z4 ? (byte) 1 : (byte) 0);
                }
                break;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void l(Object obj, long j4, byte b5) {
        switch (this.f3816b) {
            case 0:
                if (!o0.f3826g) {
                    o0.m(obj, j4, b5);
                } else {
                    o0.l(obj, j4, b5);
                }
                break;
            default:
                if (!o0.f3826g) {
                    o0.m(obj, j4, b5);
                } else {
                    o0.l(obj, j4, b5);
                }
                break;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void m(Object obj, long j4, double d5) {
        switch (this.f3816b) {
            case 0:
                p(obj, j4, Double.doubleToLongBits(d5));
                break;
            default:
                p(obj, j4, Double.doubleToLongBits(d5));
                break;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void n(Object obj, long j4, float f4) {
        switch (this.f3816b) {
            case 0:
                o(obj, Float.floatToIntBits(f4), j4);
                break;
            default:
                o(obj, Float.floatToIntBits(f4), j4);
                break;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final boolean s() {
        switch (this.f3816b) {
        }
        return false;
    }
}
