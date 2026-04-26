package d1;

import com.google.crypto.tink.shaded.protobuf.InterfaceC0318x;

/* JADX INFO: loaded from: classes.dex */
public enum r0 implements InterfaceC0318x {
    UNKNOWN_PREFIX(0),
    TINK(1),
    LEGACY(2),
    RAW(3),
    CRUNCHY(4),
    UNRECOGNIZED(-1);


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3921a;

    r0(int i4) {
        this.f3921a = i4;
    }

    public static r0 a(int i4) {
        if (i4 == 0) {
            return UNKNOWN_PREFIX;
        }
        if (i4 == 1) {
            return TINK;
        }
        if (i4 == 2) {
            return LEGACY;
        }
        if (i4 == 3) {
            return RAW;
        }
        if (i4 != 4) {
            return null;
        }
        return CRUNCHY;
    }

    public final int b() {
        if (this != UNRECOGNIZED) {
            return this.f3921a;
        }
        throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
    }
}
